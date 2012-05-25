/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.svggen;

import java.awt.Composite;
import java.awt.Paint;
import java.awt.Rectangle;
import java.awt.image.BufferedImageOp;

/**
 * This implementation of the ExtensionHandler interface always
 * returns null Nodes. In other words, it does not support any
 * Java 2D API extensions.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: DefaultExtensionHandler.java,v 1.6 2004/08/18 07:14:59 vhardy Exp $
 * @see               org.apache.flex.forks.batik.svggen.ExtensionHandler
 */
public class DefaultExtensionHandler implements ExtensionHandler {
    /**
     * @param paint Custom Paint to be converted to SVG
     * @param generatorContext allows the handler to build DOM objects as needed.
     * @return an SVGPaintDescriptor
     */
    public SVGPaintDescriptor handlePaint(Paint paint,
                                          SVGGeneratorContext generatorContext) {
        return null;
    }

    /**
     * @param composite Custom Composite to be converted to SVG.
     * @param generatorContext allows the handler to build DOM objects as needed.
     * @return an SVGCompositeDescriptor which contains a valid SVG filter,
     * or null if the composite cannot be handled
     *
     */
    public SVGCompositeDescriptor handleComposite(Composite composite,
                                                  SVGGeneratorContext generatorContext) {
        return null;
    }

    /**
     * @param filter Custom filter to be converted to SVG.
     * @param filterRect Rectangle, in device space, that defines the area
     *        to which filtering applies. May be null, meaning that the
     *        area is undefined.
     * @param generatorContext allows the handler to build DOM objects as needed.
     * @return an SVGFilterDescriptor which contains a valid SVG filter,
     * or null if the composite cannot be handled
     */
    public SVGFilterDescriptor handleFilter(BufferedImageOp filter,
                                            Rectangle filterRect,
                                            SVGGeneratorContext generatorContext) {
        return null;
    }
}
