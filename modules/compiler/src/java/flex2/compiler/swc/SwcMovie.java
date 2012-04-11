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

package flex2.compiler.swc;

import flex2.linker.Linkable;
import flex2.linker.SimpleMovie;
import flex2.linker.LinkerException;
import flex2.linker.CULinkable;
import flex2.linker.DependencyWalker;
import flex2.linker.LinkerConfiguration;
import flex2.linker.FlexMovie;
import flex2.compiler.CompilationUnit;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.graph.Visitor;

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.LinkedList;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import flash.swf.Frame;
import flash.swf.tags.FrameLabel;

/**
 * This is similar to FlexMovie in that it cares about externs and
 * unresolved symbols, but unlike FlexMovie it tries to export all
 * CompilationUnits, not just ones that are referenced.
 *
 * @author Roger Gonzalez
 */
public class SwcMovie extends SimpleMovie
{
    private Set<String> externs;
	private Set<String> includes;
    private Set<String> unresolved;
	private SortedSet<String> resourceBundles;

    public SwcMovie( LinkerConfiguration linkerConfiguration )
    {
        super( linkerConfiguration );

        // C: SwcMovie should keep its own copy of externs, includes, unresolved and resourceBundles
        //    so that incremental compilation can do the single-compile-multiple-link scenario.
        externs = new HashSet<String>(linkerConfiguration.getExterns());
	    includes = new LinkedHashSet<String>(linkerConfiguration.getIncludes());
        unresolved = new HashSet<String>(linkerConfiguration.getUnresolved());
        generateLinkReport = linkerConfiguration.generateLinkReport();
        generateRBList = linkerConfiguration.generateRBList();

	    resourceBundles = new TreeSet<String>(linkerConfiguration.getResourceBundles());
    }
    public void generate( List<CompilationUnit> units ) throws LinkerException
    {
        List<CULinkable> linkables = new LinkedList<CULinkable>();

        for (Iterator<CompilationUnit> it = units.iterator(); it.hasNext();)
        {
            linkables.add( new CULinkable( it.next() ) );
        }

        frames = new ArrayList<Frame>();

        try
        {
            // If only linking in inheritance dependencies then add the root class to includes
            // so it ends up in the swc.
            if (getInheritanceDependenciesOnly() && rootClassName != null)
                includes.add(rootClassName);
                
            DependencyWalker.LinkState state = new DependencyWalker.LinkState( linkables, externs, includes, unresolved );
            final Frame frame = new Frame();

            DependencyWalker.traverse( null, state, true, true, getInheritanceDependenciesOnly(),
                                       new Visitor<Linkable>()
                                       {
                                           public void visit( Linkable o )
                                           {
                                               CULinkable l = (CULinkable) o;
                                               exportUnitOnFrame( l.getUnit(), frame, true );
                                           }
                                       } );

            frames.add( frame );
            if (Swc.FNORD)
            {
                // add some magic simpleminded tamperproofing to the SWC.  Alpha code won't add this, release will refuse to run without it.
                frame.label = new FrameLabel();
                frame.label.label = Integer.toString( SimpleMovie.getCodeHash( frame ) );
            }

            if (generateLinkReport)
            {
            	linkReport = DependencyWalker.dump( state );
            }
            if (generateRBList)
            {
            	rbList = FlexMovie.dumpRBList(resourceBundles);
            }

            if (unresolved.size() != 0)
            {
                for (Iterator<String> it = unresolved.iterator(); it.hasNext();)
                {
                    String u = it.next();
                    if (!externs.contains( u ))
                    {
                        ThreadLocalToolkit.log(  new LinkerException.UndefinedSymbolException( u ) );
                    }
                }
            }
            topLevelClass = formatSymbolClassName( rootClassName );
            
        }
        catch (LinkerException e)
        {
            ThreadLocalToolkit.log( e );
        }
    }
}
