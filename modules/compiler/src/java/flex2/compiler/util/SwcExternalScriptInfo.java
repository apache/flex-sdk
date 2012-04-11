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

import java.util.Set;

/**
 * Information about how an external script is resolved.
 * 
 * @author dloverin
 */
public interface SwcExternalScriptInfo
{
    /**
     * 
     * @return The location of this SWC.
     */
    String getSwcLocation();
    
    /**
     * The set of dependency types found for this script.
     * 
     * @return Set of dependency types. One of 
     * <ul>
     * <li>"i" - inheritance</li>
     * <li>"n" - namespace</li>
     * <li>"s" - signature</li>
     * <li>"e" - expression</li>
     * </ul>
     */
    Set<String> getScriptDependencyTypes(String scriptName);
    
    /**
     * The set of SWCs an external script in this SWC was resolved in.
     * @return Set of Strings where each String is the location
     * of a SWC. 
     */
    Set<String> getSwcDependencies(String scriptName);
    
    /**
     * The set of external classes found in this SWC.
     * @return Set of Strings where each String is the name of an 
     * external class.
     */
    Set<String> getExternalScripts();
    
    /**
     * The set of external classes found in this SWC and resovled in 
     * resolvedSwcLocation.
     * @return Set of Strings where each String is the name of an 
     * external class.
     */
    Set<String> getExternalScripts(String resolvedSwcLocation);
}
