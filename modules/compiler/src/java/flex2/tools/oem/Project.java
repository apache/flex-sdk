/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.tools.oem;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import flex2.compiler.util.graph.Algorithms;
import flex2.compiler.util.graph.DependencyGraph;
import flex2.compiler.util.graph.Vertex;
import flex2.compiler.util.graph.Visitor;

/**
 * The <code>Project</code> class groups a number of <code>Builder</code> instances. For example, <code>Application</code>
 * and <code>Library</code>. These <code>Builder</code> instances
 * can be unrelated, or they can depend on each other. If they depend on each other, this class
 * provides dependency analysis and recommends build order.
 *
 * The <code>addBuilder()</code> method adds <code>Application</code> and <code>Library</code> instances
 * to the <code>Project</code>; for example:
 * 
 * <pre>
 * Library lib = new Library();
 * lib.setOutput(new File("foo.swc"));
 * 
 * Application app = new Application(new File("MyApp.mxml"));
 * app.setOutput(new File("MyApp.swf"));
 * 
 * p.addBuilder(lib);
 * p.addBuilder(app);
 * </pre>
 * 
 * To ensure that the <code>Application</code> uses the SWC archive that was built by the <code>Library</code>,
 * you can set the dependency by using the <code>dependsOn()</code> method; for example:
 * 
 * <pre>
 * p.dependsOn(app, lib);
 * </pre>
 * 
 * If all the <code>Builder</code> instances have pre-defined output destinations (for example, the 
 * <code>setOutput(File)</code> method was called), the <code>build(boolean)</code> method determines
 * the build order and builds the SWF and SWC files; for example:
 * 
 * <pre>
 * p.build(true);
 * </pre>
 * 
 * If you want the <code>Project</code> to provide the build order and you want to run the
 * build separately, use the <code>getBuildOrder()</code> method; for example:
 * 
 * <pre>
 * for (Iterator i = p.getBuildOrder(); i.hasNext(); )
 * {
 *     Object obj = i.next();
 *     if (obj instanceof Application)
 *     {
 *         Application app = (Application) obj;
 *         //...
 *     }
 *     else if (obj instanceof Library)
 *     {
 *         Library lib = (Library) obj;
 *         //...
 *     }
 * }
 * </pre>
 * 
 * @see flex2.tools.oem.Application
 * @see flex2.tools.oem.Library
 * @version 2.0.1
 * @author Clement Wong
 */
public class Project
{
    /**
     * Constructor.
     */
    public Project()
    {
        dependencies = new DependencyGraph<Builder>();
    }
    
    private DependencyGraph<Builder> dependencies;
    
    /**
     * Adds an <code>Application</code> or a <code>Library</code> to the <code>Project</code>.
     * 
     * @param builder An instance of the <code>Application</code> or a <code>Library</code> class.
     */
    public void addBuilder(Builder builder)
    {
        String name = Integer.toString(builder.hashCode());
        dependencies.put(name, builder);
        
        if (!dependencies.containsVertex(name))
        {
            dependencies.addVertex(new Vertex<String,Builder>(name));
        }
    }
    
    /**
     * Removes an <code>Application</code> or a <code>Library</code> from the <code>Project</code>.
     * 
     * @param builder An instance of the <code>Application</code> or a <code>Library</code> class.
     */
    public void removeBuilder(Builder builder)
    {
        String name = Integer.toString(builder.hashCode());
        dependencies.remove(name);
        dependencies.removeVertex(name);
    }
    
    /**
     * Instructs the <code>Project</code> that one <code>Builder</code> depends on the other.
     * Both <code>Builder</code> instances must first be added to this <code>Project</code>.
     * 
     * <p>
     * <code>builder1</code> depends on <code>builder2</code>.
     * 
     * @param builder1 A <code>Builder</code>. This <code>Builder</code> depends on the other.
     * @param builder2 A <code>Builder</code>.
     */
    public void dependsOn(Builder builder1, Builder builder2)
    {
        String head = Integer.toString(builder1.hashCode()), tail = Integer.toString(builder2.hashCode());
        if (!head.equals(tail) && dependencies.containsKey(head) && dependencies.containsKey(tail) &&
            !dependencies.dependencyExists(head, tail))
        {
            dependencies.addDependency(head, tail);
        }
    }

    /**
     * Gets the build order for the <code>Project</code>. The build order is determined by the dependencies among
     * <code>Builder</code> instances.
     * 
     * @return <code>Iterator</code> build order; the elements are either instance of the <code>Application</code> 
     * class or the <code>Library</code> class.
     */
    public Iterator<Builder> getBuildOrder()
    {
        final List<Builder> buildOrder = new ArrayList<Builder>(dependencies.size());
        
        Algorithms.topologicalSort(dependencies, new Visitor<Vertex<String,Builder>>()
        {   
            public void visit(Vertex<String,Builder> v)
            {
                String name = v.getWeight();
                buildOrder.add(dependencies.get(name));
            }
        });
        
        return buildOrder.iterator();
    }
    
    /**
     * Detects cyclical dependencies in this <code>Project</code>. This method returns the <code>Builder</code>
     * instances that are in cyclical dependencies. If there are no cyclical dependencies, this method 
     * returns <code>null</code>. 
     * 
     * <p>
     * The <code>Builder</code> instances in cyclical dependencies do not participate in
     * <code>build(boolean)</code>, <code>clean()</code> or <code>stop()</code> methods.
     * 
     * <p>
     * The <code>getBuildOrder()</code> method does not iterate over <code>Builder</code> instances that are in cyclical dependencies.
     * 
     * <p>
     * You should call this method at least once.
     * 
     * @return A set of <code>Builder</code> instances that are in cyclical dependencies.
     */
    public Set detectCycles()
    {
        Set builders = Algorithms.detectCycles(dependencies);
        if (builders != null && builders.size() == 0)
        {
            builders = null;
        }
        return builders;
    }
    
    /**
     * Builds the <code>Project</code>. If the input argument is <code>false</code>, the <code>build(boolean)</code> 
     * method rebuilds the <code>Project</code>. If the input argument is <code>true</code>, this method builds incrementally.
     * 
     * <p>
     * All the <code>Application</code> and <code>Library</code> objects
     * have their output destinations set with the <code>Application.setOutput()</code> and
     * <code>Library.setOutput/setDirectory()</code> methods.
     * 
     * @param incremental If <code>true</code>, build incrementally; if <code>false</code>, rebuild.
     * 
     * @throws IOException when an I/O error occurs in any one of the compilations.
     */
    public void build(boolean incremental) throws IOException
    {
        for (Iterator<Builder> i = getBuildOrder(); i.hasNext(); )
        {           
            Builder builder = i.next();
            if (builder != null)
            {
                builder.build(incremental);
            }
        }
    }
    
    /**
     * Deletes the <code>Application</code> and <code>Library</code> files in the <code>Project</code>.
     * <p>
     * The <code>clean()</code> method does not remove compiler options or reset the output location.
     */
    public void clean()
    {
        for (Iterator<Builder> i = getBuildOrder(); i.hasNext(); )
        {           
            Builder builder = i.next();
            if (builder != null)
            {
                builder.clean();
            }
        }
    }
    
    /**
     * Stops the <code>Project</code>. This method calls the <code>Application.stop()</code> and <code>Library.stop()</code> method
     * for each <code>Application</code> and <code>Library</code> in the <code>Project</code>.
     */
    public void stop()
    {
        for (Iterator<Builder> i = getBuildOrder(); i.hasNext(); )
        {           
            Builder builder = i.next();
            if (builder != null)
            {
                builder.stop();
            }
        }
    }
}

