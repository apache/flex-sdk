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

package flex2.compiler.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import flex2.compiler.util.graph.Algorithms;
import flex2.compiler.util.graph.DependencyGraph;
import flex2.compiler.util.graph.Vertex;
import flex2.compiler.util.graph.Visitor;

/**
 * Implementation to store the swc dependency graph, hiding the actual
 * implementation details. Also stores the externs of a SWC which can
 * be retrieved later via the API.
 * 
 * @author dloverin
 */
class SwcDependencyInfoImpl implements SwcDependencyInfo
{
    private DependencyGraph<SwcExternalScriptInfo> dependencies;
    

    public SwcDependencyInfoImpl()
    {
        dependencies = new DependencyGraph<SwcExternalScriptInfo>();
    }
    
    public boolean dependencyExists(String swcLocation1, String swcLocation2)
    {
        return dependencies.dependencyExists(swcLocation1, swcLocation2);
    }

    public List<String> getSwcDependencyOrder()
    {
        final List<String> depOrder = new ArrayList<String>(dependencies.size());
        
        Algorithms.topologicalSort(dependencies, new Visitor<Vertex<String,SwcExternalScriptInfo>>()
        {   
            public void visit(Vertex<String,SwcExternalScriptInfo> v)
            {
                String name = v.getWeight();
                depOrder.add(name);
            }
        });
        
        return depOrder;
    }

    public Set<String> getDependencies(String swcLocation)
    {
        return dependencies.getDependencies(swcLocation);
    }

    public SwcExternalScriptInfo getSwcExternalScriptInfo(String swcLocation)
    {
        return dependencies.get(swcLocation);
    }

    /**
     * Add a map of a SWCs external symbols.
     * 
     * @param swcLocation A SWCs location in the file system.
     * @param externals A map of definitions that are not in a SWC. The definitions is the key
     * and the dependency type is the value.
     */
    public void addSwcExternals(String swcLocation, SwcExternalScriptInfo externals)
    {
        if (swcLocation == null || externals == null)
            throw new NullPointerException();

        String name = swcLocation;
        dependencies.put(name, externals);
        
        if (!dependencies.containsVertex(name))
        {
            dependencies.addVertex(new Vertex<String,SwcExternalScriptInfo>(name));
        }
    }
    
    /**
     * Add dependency that swc1 depends on swc2.
     * 
     * @param swc1
     * @param swc2
     */
    public void addDependency(String swcLocation1, String swcLocation2)
    {
        if (swcLocation1 == null || swcLocation2 == null)
            throw new NullPointerException();
        
        String head = swcLocation1;
        String tail = swcLocation2;
        if (!head.equals(tail) && dependencies.containsKey(head) && dependencies.containsKey(tail) &&
            !dependencies.dependencyExists(head, tail))
        {
            //System.out.println(swc1.getLocation() + " depends on " + swc2.getLocation());
            dependencies.addDependency(head, tail);
        }
    }

    public Set<Vertex<String, SwcExternalScriptInfo>> detectCycles()
    {
        return Algorithms.detectCycles(dependencies);        
    }

}
