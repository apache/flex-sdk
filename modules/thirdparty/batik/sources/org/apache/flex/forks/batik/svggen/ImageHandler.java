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
package org.apache.flex.forks.batik.svggen;

import java.awt.Image;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderableImage;

import org.w3c.dom.Element;

/**
 * This interface allows the user of the Graphics2D SVG generator
 * to decide how to handle images that it renders. For example,
 * an implementation could decide to embed JPEG/PNG encoded images
 * into SVG source document using the data protocol (RFC 1521, paragraph 5.2)
 * Another option is to save images into JPEG/PNG files and store URI
 * in SVG source. <br>
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ImageHandler.java 478176 2006-11-22 14:50:50Z dvholten $
 * @see             org.apache.flex.forks.batik.svggen.SVGGraphics2D
 */
public interface ImageHandler extends SVGSyntax {
    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    void handleImage(Image image, Element imageElement,
                            SVGGeneratorContext generatorContext);

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    void handleImage(RenderedImage image, Element imageElement,
                            SVGGeneratorContext generatorContext);

    /**
     * The handler should set the xlink:href tag and the width and
     * height attributes.
     */
    void handleImage(RenderableImage image, Element imageElement,
                            SVGGeneratorContext generatorContext);
}
