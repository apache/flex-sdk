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
package org.apache.flex.forks.batik.dom.svg12;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.svg.SVGStylableElement;
import org.apache.flex.forks.batik.util.SVG12Constants;
import org.w3c.dom.Node;

/**
 * This class implements a multiImage extension to SVG.
 *
 * The 'multiImage' element is similar to the 'image' element (supports
 * all the same attributes and properties) except.
 * <ol>
 *    <li>It can only be used to reference raster content (this is an
 *        implementation thing really)</li>
 *    <li>It has two addtional attributes: 'pixel-width' and
 *        'pixel-height' which are the maximum width and height of the
 *        image referenced by the xlink:href attribute.</li>
 *    <li>It can contain a child element 'subImage' which has only
 *        three attributes, pixel-width, pixel-height and xlink:href.
 *        The image displayed is the smallest image such that
 *        pixel-width and pixel-height are greater than or equal to the
 *        required image size for display.</li>
 * </ol>
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: SVGOMSubImageRefElement.java 475477 2006-11-15 22:44:28Z cam $ */
public class SVGOMSubImageRefElement extends SVGStylableElement {


    /**
     * Creates a new SubImageRefElement object.
     */
    protected SVGOMSubImageRefElement() {
    }

    /**
     * Creates a new SubImageRefElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMSubImageRefElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG12Constants.SVG_SUB_IMAGE_REF_TAG;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMSubImageRefElement();
    }
}
