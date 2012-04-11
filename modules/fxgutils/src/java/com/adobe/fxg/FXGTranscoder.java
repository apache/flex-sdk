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
package com.adobe.fxg;

import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGResourceResolver;

/**
 * Simple interface for a transcoder on an FXG DOM.
 */
public interface FXGTranscoder
{
    /**
     * Establishes the ResourceResolver implementation used to locate and load
     * resources such as embedded images for BitmapGraphic nodes.
     * 
     * @param resolver
     */
    public void setResourceResolver(FXGResourceResolver resolver);


    /**
     * Traverses the FXG DOM from the given node, returning a transcoded result.
     * 
     * @param node the node
     * 
     * @return the object
     */
	public Object transcode(FXGNode node);
}
