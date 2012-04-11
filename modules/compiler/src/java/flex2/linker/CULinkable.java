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

package flex2.linker;

import flex2.compiler.CompilationUnit;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.Name;
import flex2.compiler.util.QName;

import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;

/**
 * Represents a CompilationUnit wrapper, which exposes only the
 * information used during dependency traversal.
 *
 * @author Roger Gonzalez
 */
public class CULinkable implements Linkable
{
    public CULinkable( CompilationUnit unit )
    {
        this.unit = unit;
        assert unit != null && unit.topLevelDefinitions != null : "Must have missed a forcedToStop() check after the most recent batch()";
        defs.addAll( unit.topLevelDefinitions.getStringSet() );
        addDeps( prereqs, unit.inheritance );
        addDeps( deps, unit.expressions );
        addDeps( deps, unit.namespaces );
        addDeps( deps, unit.types );
        deps.addAll( unit.extraClasses );
	    deps.addAll( unit.resourceBundles );	    
    }

    public String getName()
    {
        return unit.getSource().getName();
    }

    public CompilationUnit getUnit()
    {
        return unit;
    }

    public long getLastModified()
    {
        return unit.getSource().getLastModified();
    }

    public long getSize()
    {
        return unit.bytes.size();
    }

    public boolean hasDefinition( String defName )
    {
        return defs.contains( defName );
    }

    public Iterator<String> getDefinitions()
    {
        return defs.iterator();
    }

    public Iterator<String> getPrerequisites()
    {
        return prereqs.iterator();
    }

    public Iterator<String> getDependencies()
    {
        return deps.iterator();
    }

    public String toString()
    {
        return unit.getSource().getName();
    }

    public void addDep( String val )
    {
        deps.add( val );
    }

    public boolean dependsOn( String s )
    {
        return deps.contains( s ) || prereqs.contains( s );
    }

    public boolean isNative()
    {
        return unit.getSource().isInternal();
    }

    // todo - nuke this
    private void addDeps( Set<String> set, Set<Name> nameSet )
    {
        for (Name name : nameSet)
        {
            if (name instanceof QName)
            {
                set.add( name.toString() );
            }
        }
    }

    private final Set<String> defs = new HashSet<String>();
    private final Set<String> prereqs = new HashSet<String>();
    private final Set<String> deps = new HashSet<String>();
    private final CompilationUnit unit;
}
