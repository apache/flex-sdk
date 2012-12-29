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
package org.apache.flex.forks.batik.dom.anim;

import org.apache.flex.forks.batik.anim.values.AnimatableValue;

import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGLength;

/**
 * An interface for targets of animation to provide context information.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimationTarget.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public interface AnimationTarget {

    // Constants for percentage interpretation.
    short PERCENTAGE_FONT_SIZE       = 0;
    short PERCENTAGE_VIEWPORT_WIDTH  = 1;
    short PERCENTAGE_VIEWPORT_HEIGHT = 2;
    short PERCENTAGE_VIEWPORT_SIZE   = 3;

    /**
     * Returns the element.
     */
    Element getElement();

    /**
     * Updates a property value in this target.
     */
    void updatePropertyValue(String pn, AnimatableValue val);

    /**
     * Updates an attribute value in this target.
     */
    void updateAttributeValue(String ns, String ln, AnimatableValue val);

    /**
     * Updates a 'other' animation value in this target.
     */
    void updateOtherValue(String type, AnimatableValue val);

    /**
     * Returns the underlying value of an animatable XML attribute.
     */
    AnimatableValue getUnderlyingValue(String ns, String ln);

    /**
     * Gets how percentage values are interpreted by the given attribute
     * or property.
     */
    short getPercentageInterpretation(String ns, String an, boolean isCSS);

    /**
     * Returns whether color interpolations should be done in linear RGB
     * color space rather than sRGB.
     */
    boolean useLinearRGBColorInterpolation();

    /**
     * Converts the given SVG length into user units.
     * @param v the SVG length value
     * @param type the SVG length units (one of the
     *             {@link SVGLength}.SVG_LENGTH_* constants)
     * @param pcInterp how to interpretet percentage values (one of the
     *             {@link AnimationTarget}.PERCENTAGE_* constants)
     * @return the SVG value in user units
     */
    float svgToUserSpace(float v, short type, short pcInterp);

    // Listeners

    /**
     * Adds a listener for changes to the given attribute value.
     */
    void addTargetListener(String ns, String an, boolean isCSS,
                           AnimationTargetListener l);

    /**
     * Removes a listener for changes to the given attribute value.
     */
    void removeTargetListener(String ns, String an, boolean isCSS,
                              AnimationTargetListener l);
}
