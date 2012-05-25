/*

   Copyright 2000-2004  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.svg;

import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;

/**
 * This interface is the placeholder for SVG application informations.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGContext.java,v 1.15 2004/10/08 16:12:01 deweese Exp $
 */
public interface SVGContext {

    /**
     * Returns the size of a px CSS unit in millimeters.
     */
    float getPixelUnitToMillimeter();

    /**
     * Returns the size of a px CSS unit in millimeters.
     * This will be removed after next release.
     * @see #getPixelUnitToMillimeter()
     */
    float getPixelToMM();

    /**
     * Returns the tight bounding box in current user space (i.e.,
     * after application of the transform attribute, if any) on the
     * geometry of all contained graphics elements, exclusive of
     * stroke-width and filter effects).
     */
    Rectangle2D getBBox();

    /**
     * Returns the transform from the global transform space to pixels.
     */
    AffineTransform getScreenTransform();

    /**
     * Sets the transform to be used from the global transform space to pixels.
     */
    void setScreenTransform(AffineTransform at);

    /**
     * Returns the transformation matrix from current user units
     * (i.e., after application of the transform attribute, if any) to
     * the viewport coordinate system for the nearestViewportElement.
     */
    AffineTransform getCTM();

    /**
     * Returns the global transformation matrix from the current
     * element to the root.
     */
    AffineTransform getGlobalTransform();

    /**
     * Returns the width of the viewport which directly contains the
     * associated element.
     */
    float getViewportWidth();

    /**
     * Returns the height of the viewport which directly contains the
     * associated element.
     */
    float getViewportHeight();

    /**
     * Returns the font-size on the associated element.
     */
    float getFontSize();

}
