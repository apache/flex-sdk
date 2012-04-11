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

import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
import java.util.Iterator;

/**
 * This represents the set of dependencies and their type for each
 * definition in a SWC.
 *
 * @author Roger Gonzalez
 */
public class SwcDependencySet
{
    public final static String INHERITANCE = "i";
    public final static String NAMESPACE = "n";
    public final static String SIGNATURE = "s";
    public final static String EXPRESSION = "e";

    public void addDependency( String type, String dep )
    {
        Set<String> deps = depTypeMap.get( type );

        if (deps == null)
        {
            deps = new HashSet<String>();
            depTypeMap.put( type, deps );
        }
        deps.add( dep );
    }

    public void addDependencies( String type, Iterator<String> deps )
    {
        while (deps.hasNext())
        {
            addDependency( type, deps.next());
        }
    }

    private Set<String> getDependencies( String type )
    {
        return depTypeMap.get( type );
    }

    public Iterator<String> getDependencyIterator( String type )
    {
        Set<String> deps = getDependencies( type );
        return (deps == null)? null : deps.iterator();
    }

    public Iterator<String> getTypeIterator()
    {
        return depTypeMap.keySet().iterator();
    }

    private Map<String, Set<String>> depTypeMap = new HashMap<String, Set<String>>();
}
