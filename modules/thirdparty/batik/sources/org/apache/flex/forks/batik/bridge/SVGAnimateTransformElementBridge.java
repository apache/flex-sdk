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

import java.util.ArrayList;

import org.apache.flex.forks.batik.anim.AbstractAnimation;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.anim.TransformAnimation;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.anim.values.AnimatableTransformListValue;
import org.apache.flex.forks.batik.dom.svg.SVGOMTransform;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.svg.SVGTransform;

/**
 * Bridge class for the 'animateTransform' animation element.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGAnimateTransformElementBridge.java 496029 2007-01-14 04:00:34Z cam $
 */
public class SVGAnimateTransformElementBridge extends SVGAnimateElementBridge {

    /**
     * Returns 'animateTransform'.
     */
    public String getLocalName() {
        return SVG_ANIMATE_TRANSFORM_TAG;
    }

    /**
     * Returns a new instance of this bridge.
     */
    public Bridge getInstance() {
        return new SVGAnimateTransformElementBridge();
    }

    /**
     * Creates the animation object for the animation element.
     */
    protected AbstractAnimation createAnimation(AnimationTarget target) {
        short type = parseType();
        AnimatableValue from = null, to = null, by = null;
        if (element.hasAttributeNS(null, SVG_FROM_ATTRIBUTE)) {
            from = parseValue(element.getAttributeNS(null, SVG_FROM_ATTRIBUTE),
                              type, target);
        }
        if (element.hasAttributeNS(null, SVG_TO_ATTRIBUTE)) {
            to = parseValue(element.getAttributeNS(null, SVG_TO_ATTRIBUTE),
                            type, target);
        }
        if (element.hasAttributeNS(null, SVG_BY_ATTRIBUTE)) {
            by = parseValue(element.getAttributeNS(null, SVG_BY_ATTRIBUTE),
                            type, target);
        }
        return new TransformAnimation(timedElement,
                                      this,
                                      parseCalcMode(),
                                      parseKeyTimes(),
                                      parseKeySplines(),
                                      parseAdditive(),
                                      parseAccumulate(),
                                      parseValues(type, target),
                                      from,
                                      to,
                                      by,
                                      type);
    }

    /**
     * Returns the parsed 'type' attribute from the animation element.
     */
    protected short parseType() {
        String typeString = element.getAttributeNS(null, SVG_TYPE_ATTRIBUTE);
        if (typeString.equals("translate")) {
            return SVGTransform.SVG_TRANSFORM_TRANSLATE;
        } else if (typeString.equals("scale")) {
            return SVGTransform.SVG_TRANSFORM_SCALE;
        } else if (typeString.equals("rotate")) {
            return SVGTransform.SVG_TRANSFORM_ROTATE;
        } else if (typeString.equals("skewX")) {
            return SVGTransform.SVG_TRANSFORM_SKEWX;
        } else if (typeString.equals("skewY")) {
            return SVGTransform.SVG_TRANSFORM_SKEWY;
        }
        throw new BridgeException
            (ctx, element, ErrorConstants.ERR_ATTRIBUTE_VALUE_MALFORMED,
             new Object[] { SVG_TYPE_ATTRIBUTE, typeString });
    }

    /**
     * Parses a transform value.
     */
    protected AnimatableValue parseValue(String s, short type,
                                         AnimationTarget target) {
        float val1, val2 = 0, val3 = 0;
        int i = 0;
        char c = ',';
        int len = s.length();
        while (i < len) {
            c = s.charAt(i);
            if (c == ' ' || c == ',') {
                break;
            }
            i++;
        }
        val1 = Float.parseFloat(s.substring(0, i));
        if (i < len) {
            i++;
        }
        int count = 1;
        if (i < len && c == ' ') {
            while (i < len) {
                c = s.charAt(i);
                if (c != ' ') {
                    break;
                }
                i++;
            }
            if (c == ',') {
                i++;
            }
        }
        while (i < len && s.charAt(i) == ' ') {
            i++;
        }
        int j = i;
        if (i < len
                && type != SVGTransform.SVG_TRANSFORM_SKEWX
                && type != SVGTransform.SVG_TRANSFORM_SKEWY) {
            while (i < len) {
                c = s.charAt(i);
                if (c == ' ' || c == ',') {
                    break;
                }
                i++;
            }
            val2 = Float.parseFloat(s.substring(j, i));
            if (i < len) {
                i++;
            }
            count++;
            if (i < len && c == ' ') {
                while (i < len) {
                    c = s.charAt(i);
                    if (c != ' ') {
                        break;
                    }
                    i++;
                }
                if (c == ',') {
                    i++;
                }
            }
            while (i < len && s.charAt(i) == ' ') {
                i++;
            }
            j = i;
            if (i < len && type == SVGTransform.SVG_TRANSFORM_ROTATE) {
                while (i < len) {
                    c = s.charAt(i);
                    if (c == ',' || c == ' ') {
                        break;
                    }
                    i++;
                }
                val3 = Float.parseFloat(s.substring(j, i));
                if (i < len) {
                    i++;
                }
                count++;
                while (i < len && s.charAt(i) == ' ') {
                    i++;
                }
            }
        }

        if (i != len) {
            return null;
        }

        SVGOMTransform t = new SVGOMTransform();
        switch (type) {
            case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                if (count == 2) {
                    t.setTranslate(val1, val2);
                } else {
                    t.setTranslate(val1, 0f);
                }
                break;
            case SVGTransform.SVG_TRANSFORM_SCALE:
                if (count == 2) {
                    t.setScale(val1, val2);
                } else {
                    t.setScale(val1, val1);
                }
                break;
            case SVGTransform.SVG_TRANSFORM_ROTATE:
                if (count == 3) {
                    t.setRotate(val1, val2, val3);
                } else {
                    t.setRotate(val1, 0f, 0f);
                }
                break;
            case SVGTransform.SVG_TRANSFORM_SKEWX:
                t.setSkewX(val1);
                break;
            case SVGTransform.SVG_TRANSFORM_SKEWY:
                t.setSkewY(val1);
                break;
        }
        return new AnimatableTransformListValue(target, t);
    }

    /**
     * Returns the parsed 'values' attribute from the animation element.
     */
    protected AnimatableValue[] parseValues(short type,
                                            AnimationTarget target) {
        String valuesString = element.getAttributeNS(null,
                                                     SVG_VALUES_ATTRIBUTE);
        int len = valuesString.length();
        if (len == 0) {
            return null;
        }
        ArrayList values = new ArrayList(7);
        int i = 0, start = 0, end;
        char c;
outer:  while (i < len) {
            while (valuesString.charAt(i) == ' ') {
                i++;
                if (i == len) {
                    break outer;
                }
            }
            start = i++;
            if (i < len) {
                c = valuesString.charAt(i);
                while (c != ';') {
                    i++;
                    if (i == len) {
                        break;
                    }
                    c = valuesString.charAt(i);
                }
            }
            end = i++;
            String valueString = valuesString.substring(start, end);
            AnimatableValue value = parseValue(valueString, type, target);
            if (value == null) {
                throw new BridgeException
                    (ctx, element, ErrorConstants.ERR_ATTRIBUTE_VALUE_MALFORMED,
                     new Object[] { SVG_VALUES_ATTRIBUTE, valuesString });
            }
            values.add(value);
        }
        AnimatableValue[] ret = new AnimatableValue[values.size()];
        return (AnimatableValue[]) values.toArray(ret);
    }

    /**
     * Returns whether the animation element being handled by this bridge can
     * animate attributes of the specified type.
     * @param type one of the TYPE_ constants defined in {@link SVGTypes}.
     */
    protected boolean canAnimateType(int type) {
        return type == SVGTypes.TYPE_TRANSFORM_LIST;
    }
}
