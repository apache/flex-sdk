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
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.adobe.fxg.dom.FXGNode;

import static com.adobe.fxg.FXGConstants.*;

/**
 * FXGVersionHandler for FXG 2.0
 * 
 * @author Sujata Das
 */
public class FXG_v2_0_Mobile_Handler extends FXG_v2_0_Handler
{
    
    private boolean initialized = false;

    protected FXG_v2_0_Mobile_Handler()
    {
        super();
    }

    /**
     * initializes the version handler with FXG 2.0 specific information
     * 
     * @override
     */
    protected void init()
    {
        if (initialized)
            return;

        Map<String, Class<? extends FXGNode>> elementNodes = new HashMap<String, Class<? extends FXGNode>>(DEFAULT_FXG_2_0_NODES.size() + 4);
        elementNodes.putAll(DEFAULT_FXG_2_0_NODES);
        elementNodesByURI = new HashMap<String, Map<String, Class<? extends FXGNode>>>(1);
        elementNodesByURI.put(FXG_NAMESPACE, elementNodes);

        // Skip <Private> by default for FXG 2.0
        HashSet<String> skippedElements = new HashSet<String>(1);
        skippedElements.add(FXG_PRIVATE_ELEMENT);
        skippedElementsByURI = new HashMap<String, Set<String>>(1);
        skippedElementsByURI.put(FXG_NAMESPACE, skippedElements);
               
        
        initialized = true;
    }
    

}
