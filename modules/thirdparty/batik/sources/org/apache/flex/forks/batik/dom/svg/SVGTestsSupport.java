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
package org.apache.flex.forks.batik.dom.svg;

import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGStringList;

/**
 * This class provides support for SVGTests features.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGTestsSupport.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGTestsSupport {

    /**
     * Creates a new SVGTestsSupport object.
     */
    public SVGTestsSupport() {
    }

    /**
     * To implements {@link org.w3c.dom.svg.SVGTests#getRequiredFeatures()}.
     */
    public static SVGStringList getRequiredFeatures(Element elt) {
        throw new UnsupportedOperationException
            ("SVGTests.getRequiredFeatures is not implemented"); // XXX
    }

    /**
     * To implements {@link org.w3c.dom.svg.SVGTests#getRequiredExtensions()}.
     */
    public static SVGStringList getRequiredExtensions(Element elt) {
        throw new UnsupportedOperationException
            ("SVGTests.getRequiredExtensions is not implemented"); // XXX
    }

    /**
     * To implements {@link org.w3c.dom.svg.SVGTests#getSystemLanguage()}.
     */
    public static SVGStringList getSystemLanguage(Element elt) {
        throw new UnsupportedOperationException
            ("SVGTests.getSystemLanguage is not implemented"); // XXX
    }

    /**
     * To implements {@link org.w3c.dom.svg.SVGTests#hasExtension(String)}.
     */
    public static boolean hasExtension(Element elt, String extension) {
        throw new UnsupportedOperationException
            ("SVGTests.hasExtension is not implemented"); // XXX
    }
}
