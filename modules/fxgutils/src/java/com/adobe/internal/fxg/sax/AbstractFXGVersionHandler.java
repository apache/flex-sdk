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

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;

/**
 * An abstract implementation of FXGVersionHandler interface. It implements
 * interfaces to encapsulate FXG version specific information. It forms the base
 * class for the different FXGVersionHandlers. This allows the scanner to handle
 * different versions of fxg files by swapping different FXGVersionHandlers at
 * runtime depending on the fxg version of the input file.
 * 
 * @author Sujata Das
 */
public abstract class AbstractFXGVersionHandler implements FXGVersionHandler
{

    /**
     * A Map of URIs to a List of local element names.
     */
    protected Map<String, Set<String>> skippedElementsByURI = null;
    
    /**
     * A Map of URIs to a List of local element names that are not supported.
     */
    protected Map<String, Set<String>> unsupportedElementsByURI = null;
    
    /**
     * A Map of URIs to a Map of local element names to an FXGNode Class.
     */
    protected Map<String, Map<String, Class<? extends FXGNode>>> elementNodesByURI = null;

    // version of the FXGVersionHandler
    protected FXGVersion handlerVersion;

    /**
     * @return the FXGVersion of the handler
     */
    public FXGVersion getVersion()
    {
        return handlerVersion;
    }

    protected void init()
    {
    }

    /**
     * @param URI - namespace for the elements
     * @return a Set<String> of the elements that are registered to be skipped
     *         by the scanner
     */
    public Set<String> getSkippedElements(String URI)
    {
        init();
        if (skippedElementsByURI == null)
            return null;
        return skippedElementsByURI.get(URI);
    }
    
    /**
     * @param URI - namespace for the elements
     * @return a Set<String> of the elements that are to be 
     * ignored by the scanner and a warning is logged
     */
    public Set<String> getUnsupportedElements(String URI)
    {
        init();
        if (unsupportedElementsByURI == null)
            return null;
        return unsupportedElementsByURI.get(URI);
    }

    /**
     * @param URI
     * @return a Map<String, Class<? extends FXGNode>> that maps element names
     *         to Class that handles the element.
     */
    public Map<String, Class<? extends FXGNode>> getElementNodes(String URI)
    {
        init();
        if (elementNodesByURI == null)
            return null;

        return elementNodesByURI.get(URI);
    }

    /**
     * Registers names of elements that are to be skipped by the scanner
     * 
     * @param URI - namespace for the elements
     * @param skippedElements - Set of Strings that specify elements names that
     *        are to be scanned by scanner
     */
    public void registerSkippedElements(String URI, Set<String> skippedElements)
    {
        init();
        if (skippedElementsByURI == null)
        {
            skippedElementsByURI = new HashMap<String, Set<String>>(1);
            skippedElementsByURI.put(URI, skippedElements);
        }
        else
        {
            if (skippedElementsByURI.containsKey(URI))
            {
                Set<String> value = skippedElementsByURI.get(URI);
                value.addAll(skippedElements);
                skippedElementsByURI.put(URI, value);
            }
            else
            {
                skippedElementsByURI.put(URI, skippedElements);
            }
        }
    }
    
    /**
     * Registers mapping for the scanner to process elements and Classes that
     * handle the elements
     * 
     * @param URI - namespace for the elements
     * @param elementNodes - a Map containing mapping from elements names to
     *        Classes that handle the elements.
     */
    public void registerElementNodes(String URI,
            Map<String, Class<? extends FXGNode>> elementNodes)
    {
        init();
        if (elementNodesByURI == null)
        {
            elementNodesByURI = new HashMap<String, Map<String, Class<? extends FXGNode>>>(1);
            elementNodesByURI.put(URI, elementNodes);
        }
        else
        {
            if (elementNodesByURI.containsKey(URI))
            {
                Map<String, Class<? extends FXGNode>> value = elementNodesByURI.get(URI);
                value.putAll(elementNodes);
                elementNodesByURI.put(URI, value);
            }
            else
            {
                elementNodesByURI.put(URI, elementNodes);
            }
        }
    }
}
