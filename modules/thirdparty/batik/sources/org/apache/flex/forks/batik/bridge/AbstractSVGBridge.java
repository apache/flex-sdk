/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.util.SVGConstants;

/**
 * The base bridge class for SVG elements.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: AbstractSVGBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AbstractSVGBridge implements Bridge, SVGConstants {

    /**
     * Constructs a new abstract bridge for SVG elements.
     */
    protected AbstractSVGBridge() {}

    /**
     * Returns the SVG namespace URI.
     */
    public String getNamespaceURI() {
        return SVG_NAMESPACE_URI;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        // <!> FIXME: temporary fix for progressive implementation
        //System.out.println("use static bridge for: "+getLocalName());
        return this;
    }
}
