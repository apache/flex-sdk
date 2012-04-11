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

package com.adobe.internal.fxg.sax;

import java.util.Map;
import java.util.Set;

import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;

/**
 * A FXGVersionHandler defines interfaces to encapsulate FXG version specific
 * information. It allows the scanner to handle different versions of fxg files
 * by swapping different FXGVersionHandlers at runtime depending on the fxg
 * version of the input file.
 * 
 * @author Sujata Das
 */
public interface FXGVersionHandler
{
    /**
     * @return the FXGVersion of the FXGVersionHandler
     */
    FXGVersion getVersion();

    /**
     * @param URI - namespace for the elements
     * @return a Set<String> of the elements that are registered to be skipped
     *         by the scanner
     */
    Set<String> getSkippedElements(String URI);
    
    /**
     * @param URI - namespace for the elements
     * @return a Set<String> of the elements that are to be ignored
     *         by the scanner and a warning is logged
     */
    Set<String> getUnsupportedElements(String URI);

    /**
     * @param URI
     * @return a Map<String, Class<? extends FXGNode>> that maps element names
     *         to Class that handles the element.
     */
    Map<String, Class<? extends FXGNode>> getElementNodes(String URI);

    /**
     * Registers names of elements that are to be skipped by the scanner
     * 
     * @param URI - namespace for the elements
     * @param skippedElements - Set of Strings that specify elements names that
     *        are to be scanned by scanner
     */
    void registerSkippedElements(String URI, Set<String> skippedElements);

    /**
     * Registers mapping for the scanner to process elements and Classes that
     * handle the elements
     * 
     * @param URI - namespace for the elements
     * @param elementNodes - a Map containing mapping from elements names to
     *        Classes that handle the elements.
     */
    void registerElementNodes(String URI,
            Map<String, Class<? extends FXGNode>> elementNodes);

}
