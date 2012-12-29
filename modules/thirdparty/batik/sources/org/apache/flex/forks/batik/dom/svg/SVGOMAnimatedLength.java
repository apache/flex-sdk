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

/**
 * This class provides an implementation of the {@link
 * org.w3c.dom.svg.SVGAnimatedLength} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedLength.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGOMAnimatedLength extends AbstractSVGAnimatedLength {

    /**
     * The default value if the attribute is not specified.
     */
    protected String defaultValue;

    /**
     * Creates a new SVGOMAnimatedLength.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param def The default value if the attribute is not specified.
     * @param dir The length's direction.
     * @param nonneg Whether the length must be non-negative.
     */
    public SVGOMAnimatedLength(AbstractElement elt,
                               String ns,
                               String ln,
                               String def,
                               short dir,
                               boolean nonneg) {
        super(elt, ns, ln, dir, nonneg);
        defaultValue = def;
    }

    /**
     * Returns the default value to use when the associated attribute
     * was not specified.
     */
    protected String getDefaultValue() {
        return defaultValue;
    }
}
