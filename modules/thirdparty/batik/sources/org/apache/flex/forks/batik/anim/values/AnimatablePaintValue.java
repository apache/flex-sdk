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
package org.apache.flex.forks.batik.anim.values;

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

/**
 * An SVG paint value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatablePaintValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AnimatablePaintValue extends AnimatableColorValue {

    // Constants for paintType.
    public static final int PAINT_NONE              = 0;
    public static final int PAINT_CURRENT_COLOR     = 1;
    public static final int PAINT_COLOR             = 2;
    public static final int PAINT_URI               = 3;
    public static final int PAINT_URI_NONE          = 4;
    public static final int PAINT_URI_CURRENT_COLOR = 5;
    public static final int PAINT_URI_COLOR         = 6;
    public static final int PAINT_INHERIT           = 7;

    /**
     * The type of paint.
     */
    protected int paintType;

    /**
     * The URI of the referenced paint server.
     */
    protected String uri;

    /**
     * Creates a new, uninitialized AnimatablePaintValue.
     */
    protected AnimatablePaintValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatablePaintValue.
     */
    protected AnimatablePaintValue(AnimationTarget target, float r, float g,
                                   float b) {
        super(target, r, g, b);
    }

    /**
     * Creates a new AnimatablePaintValue for a 'none' value.
     */
    public static AnimatablePaintValue createNonePaintValue
            (AnimationTarget target) {
        AnimatablePaintValue v = new AnimatablePaintValue(target);
        v.paintType = PAINT_NONE;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a 'currentColor' value.
     */
    public static AnimatablePaintValue createCurrentColorPaintValue
            (AnimationTarget target) {
        AnimatablePaintValue v = new AnimatablePaintValue(target);
        v.paintType = PAINT_CURRENT_COLOR;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a color value.
     */
    public static AnimatablePaintValue createColorPaintValue
            (AnimationTarget target, float r, float g, float b) {
        AnimatablePaintValue v = new AnimatablePaintValue(target, r, g, b);
        v.paintType = PAINT_COLOR;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a URI reference.
     */
    public static AnimatablePaintValue createURIPaintValue
            (AnimationTarget target, String uri) {
        AnimatablePaintValue v = new AnimatablePaintValue(target);
        v.uri = uri;
        v.paintType = PAINT_URI;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a URI reference with a
     * 'none' fallback.
     */
    public static AnimatablePaintValue createURINonePaintValue
            (AnimationTarget target, String uri) {
        AnimatablePaintValue v = new AnimatablePaintValue(target);
        v.uri = uri;
        v.paintType = PAINT_URI_NONE;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a URI reference with a
     * 'currentColor' fallback.
     */
    public static AnimatablePaintValue createURICurrentColorPaintValue
            (AnimationTarget target, String uri) {
        AnimatablePaintValue v = new AnimatablePaintValue(target);
        v.uri = uri;
        v.paintType = PAINT_URI_CURRENT_COLOR;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a URI reference with a
     * color fallback.
     */
    public static AnimatablePaintValue createURIColorPaintValue
            (AnimationTarget target, String uri, float r, float g, float b) {
        AnimatablePaintValue v = new AnimatablePaintValue(target, r, g, b);
        v.uri = uri;
        v.paintType = PAINT_URI_COLOR;
        return v;
    }

    /**
     * Creates a new AnimatablePaintValue for a 'inherit' value.
     */
    public static AnimatablePaintValue createInheritPaintValue
            (AnimationTarget target) {
        AnimatablePaintValue v = new AnimatablePaintValue(target);
        v.paintType = PAINT_INHERIT;
        return v;
    }

    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to,
                                       float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatablePaintValue res;
        if (result == null) {
            res = new AnimatablePaintValue(target);
        } else {
            res = (AnimatablePaintValue) result;
        }

        if (paintType == PAINT_COLOR) {
            boolean canInterpolate = true;
            if (to != null) {
                AnimatablePaintValue toPaint = (AnimatablePaintValue) to;
                canInterpolate = toPaint.paintType == PAINT_COLOR;
            }
            if (accumulation != null) {
                AnimatablePaintValue accPaint =
                    (AnimatablePaintValue) accumulation;
                canInterpolate =
                    canInterpolate && accPaint.paintType == PAINT_COLOR;
            }
            if (canInterpolate) {
                res.paintType = PAINT_COLOR;
                return super.interpolate
                    (res, to, interpolation, accumulation, multiplier);
            }
        }

        int newPaintType;
        String newURI;
        float newRed, newGreen, newBlue;

        if (to != null && interpolation >= 0.5) {
            AnimatablePaintValue toValue = (AnimatablePaintValue) to;
            newPaintType = toValue.paintType;
            newURI = toValue.uri;
            newRed = toValue.red;
            newGreen = toValue.green;
            newBlue = toValue.blue;
        } else {
            newPaintType = paintType;
            newURI = uri;
            newRed = red;
            newGreen = green;
            newBlue = blue;
        }

        if (res.paintType != newPaintType
                || res.uri == null
                || !res.uri.equals(newURI)
                || res.red != newRed
                || res.green != newGreen
                || res.blue != newBlue) {
            res.paintType = newPaintType;
            res.uri = newURI;
            res.red = newRed;
            res.green = newGreen;
            res.blue = newBlue;
            res.hasChanged = true;
        }

        return res;
    }

    /**
     * Returns the type of paint this value represents.
     */
    public int getPaintType() {
        return paintType;
    }

    /**
     * Returns the paint server URI.
     */
    public String getURI() {
        return uri;
    }

    /**
     * Returns whether two values of this type can have their distance
     * computed, as needed by paced animation.
     */
    public boolean canPace() {
        return false;
    }

    /**
     * Returns the absolute distance between this value and the specified other
     * value.
     */
    public float distanceTo(AnimatableValue other) {
        return 0f;
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        return AnimatablePaintValue.createColorPaintValue(target, 0f, 0f, 0f);
    }

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        switch (paintType) {
            case PAINT_NONE:
                return "none";
            case PAINT_CURRENT_COLOR:
                return "currentColor";
            case PAINT_COLOR:
                return super.getCssText();
            case PAINT_URI:
                return "url(" + uri + ")";
            case PAINT_URI_NONE:
                return "url(" + uri + ") none";
            case PAINT_URI_CURRENT_COLOR:
                return "url(" + uri + ") currentColor";
            case PAINT_URI_COLOR:
                return "url(" + uri + ") " + super.getCssText();
            default: // PAINT_INHERIT
                return "inherit";
        }
    }
}
