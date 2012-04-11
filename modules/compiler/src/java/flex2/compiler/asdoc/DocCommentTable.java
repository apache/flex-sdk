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

package flex2.compiler.asdoc;

import java.util.List;
import java.util.Map;

/**
 * This interface defines methods for retrieving info based on packages and classes. 
 *
 */
public interface DocCommentTable
{
    /**
     * @return Map of all packages where key = package name, value = DocComment.
     */
    public Map getPackages();
    
    /**
     * Useful to retrieve all the class names from a package (since they must be unique
     * within a package).
     * 
     * @param packageName
     * @return Map of all classes and interfaces in a specific package where
     * key = class or interface name, value = DocComment.
     *
     */
    public Map getClassesAndInterfaces(String packageName);
    
    
    /**
     * @param className
     * @param packageName
     * @return all the DocComments associated with the specified class and package
     */
    public List getAllClassComments(String className, String packageName);
}
