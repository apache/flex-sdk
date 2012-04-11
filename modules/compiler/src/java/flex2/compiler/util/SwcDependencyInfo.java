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

import java.util.List;
import java.util.Set;

import flex2.compiler.util.graph.Vertex;

/**
 * Describes the dependency relationships between SWCs.  Dependencies
 * are created when a SWC A is compiled with SWC B on the external
 * library path (-external-library-path).  In this example SWC A is
 * dependent on SWC B because SWC A does not contain SWC B's classes.
 * When an application is compiled using SWC A, SWC B may also be
 * needed so to provide those classes.  If SWC A is used as an RSL,
 * SWC B will need to be loaded before SWC A if there is an
 * inheritance dependency between the two SWCs.
 * 
 * @author dloverin
 */
public interface SwcDependencyInfo
{
    /**
     * Test if one SWC is dependent on another.
     * 
     * @param swcLocation1 Location of first SWC in the file system.
     * @param swcLocation2 Location of second SWC in the file system.
     * @return True if the SWC at swcLocation1 is dependent on the SWC at 
     * swcLocation2.
     */
    boolean dependencyExists(String swcLocation1, String swcLocation2);
    
    /**
     * Test if there are cycles in the dependency info.
     * 
     * @return If there are no cylces any empty set will be returned. If there
     * are cycles the set will contain the SWCs that make up the cycle.
     */
    public Set<Vertex<String, SwcExternalScriptInfo>> detectCycles();

    /**
     * Get a list of all the SWCs in order of their relative dependencies. The list
     * is ordered from a SWC without dependencies to those with dependencies. A
     * SWC following another SWC in the list does not mean it is dependent on that
     * SWC, they may be dependent on the same SWC or SWCs. To get the list of SWCs a 
     * given SWC is dependent on see the getDependencies method.
     * 
     * @return An ordered list of SWC dependencies. Each String in the 
     * list is the location of a SWC in the file system. The first SWC in the list has no
     * dependencies. Each SWC in the list has at least the same dependencies as its 
     * predecessor and may be dependent on its predecessor as well. 
     * 
     * @see getDependencies
     */
    List<String> getSwcDependencyOrder();
    
    /**
     * Get the set of SWCs a given SWC is dependent on.
     * 
     * @param swcLocation
     * @return Set of Strings, where each String in the list is the location of a 
     * SWC in the file system.
     */
    Set<String> getDependencies(String swcLocation);
    
    /**
     * Additional information describing the external scripts a SWC contains as well as
     * what SWCs resolve the dependency.
     * 
     * @param swcLocation
     * @return SwcExternalScriptInfo
     */
    SwcExternalScriptInfo getSwcExternalScriptInfo(String swcLocation);
    
}
