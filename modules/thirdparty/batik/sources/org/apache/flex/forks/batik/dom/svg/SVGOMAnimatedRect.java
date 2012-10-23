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

import org.apache.flex.forks.batik.anim.values.AnimatableRectValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;
import org.apache.flex.forks.batik.parser.DefaultNumberListHandler;
import org.apache.flex.forks.batik.parser.NumberListParser;
import org.apache.flex.forks.batik.parser.ParseException;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedRect;
import org.w3c.dom.svg.SVGRect;

/**
 * Implementation of {@link SVGAnimatedRect}.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGOMAnimatedRect.java 579487 2007-09-26 06:40:16Z cam $
 */
public class SVGOMAnimatedRect
        extends AbstractSVGAnimatedValue
        implements SVGAnimatedRect {

    /**
     * The base value.
     */
    protected BaseSVGRect baseVal;

    /**
     * The animated value.
     */
    protected AnimSVGRect animVal;

    /**
     * Whether the value is changing.
     */
    protected boolean changing;

    /**
     * Default value.
     */
    protected String defaultValue;

    /**
     * Creates a new SVGOMAnimatedRect.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param def The default value for the attribute.
     */
    public SVGOMAnimatedRect(AbstractElement elt, String ns, String ln,
                             String def) {
        super(elt, ns, ln);
        defaultValue = def;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedRect#getBaseVal()}.
     */
    public SVGRect getBaseVal() {
        if (baseVal == null) {
            baseVal = new BaseSVGRect();
        }
        return baseVal;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedRect#getAnimVal()}.
     */
    public SVGRect getAnimVal() {
        if (animVal == null) {
            animVal = new AnimSVGRect();
        }
        return animVal;
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            AnimatableRectValue animRect = (AnimatableRectValue) val;
            if (animVal == null) {
                animVal = new AnimSVGRect();
            }
            animVal.setAnimatedValue(animRect.getX(), animRect.getY(),
                                     animRect.getWidth(), animRect.getHeight());
        }
        fireAnimatedAttributeListeners();
    }

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    public AnimatableValue getUnderlyingValue(AnimationTarget target) {
        SVGRect r = getBaseVal();
        return new AnimatableRectValue
            (target, r.getX(), r.getY(), r.getWidth(), r.getHeight());
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing && baseVal != null) {
            baseVal.invalidate();
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing && baseVal != null) {
            baseVal.invalidate();
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!changing && baseVal != null) {
            baseVal.invalidate();
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * This class represents the SVGRect returned by getBaseVal().
     */
    protected class BaseSVGRect extends SVGOMRect {

        /**
         * Whether this rect is valid.
         */
        protected boolean valid;
        
        /**
         * Invalidates this length.
         */
        public void invalidate() {
            valid = false;
        }

        /**
         * Resets the value of the associated attribute.
         */
        protected void reset() {
            try {
                changing = true;
                element.setAttributeNS
                    (namespaceURI, localName,
                     Float.toString(x) + ' ' + y + ' ' + w + ' ' + h);
            } finally {
                changing = false;
            }
        }

        /**
         * Initializes the length, if needed.
         */
        protected void revalidate() {
            if (valid) {
                return;
            }

            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);

            final String s = attr == null ? defaultValue : attr.getValue();
            final float[] numbers = new float[4];
            NumberListParser p = new NumberListParser();
            p.setNumberListHandler(new DefaultNumberListHandler() {
                protected int count;
                public void endNumberList() {
                    if (count != 4) {
                        throw new LiveAttributeException
                            (element, localName,
                             LiveAttributeException.ERR_ATTRIBUTE_MALFORMED,
                             s);
                    }
                }
                public void numberValue(float v) throws ParseException {
                    if (count < 4) {
                        numbers[count] = v;
                    }
                    if (v < 0 && (count == 2 || count == 3)) {
                        throw new LiveAttributeException
                            (element, localName,
                             LiveAttributeException.ERR_ATTRIBUTE_MALFORMED,
                             s);
                    }
                    count++;
                }
            });
            p.parse(s);
            x = numbers[0];
            y = numbers[1];
            w = numbers[2];
            h = numbers[3];

            valid = true;
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#getX()}.
         */
        public float getX() {
            revalidate();
            return x;
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#setX(float)}.
         */
        public void setX(float x) throws DOMException {
            this.x = x;
            reset();
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#getY()}.
         */
        public float getY() {
            revalidate();
            return y;
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#setY(float)}.
         */
        public void setY(float y) throws DOMException {
            this.y = y;
            reset();
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#getWidth()}.
         */
        public float getWidth() {
            revalidate();
            return w;
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#setWidth(float)}.
         */
        public void setWidth(float width) throws DOMException {
            this.w = width;
            reset();
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#getHeight()}.
         */
        public float getHeight() {
            revalidate();
            return h;
        }
        
        /**
         * <b>DOM</b>: Implements {@link SVGRect#setHeight(float)}.
         */
        public void setHeight(float height) throws DOMException {
            this.h = height;
            reset();
        }
    }

    /**
     * This class represents the SVGRect returned by getAnimVal().
     */
    protected class AnimSVGRect extends SVGOMRect {

        /**
         * <b>DOM</b>: Implements {@link SVGRect#getX()}.
         */
        public float getX() {
            if (hasAnimVal) {
                return super.getX();
            }
            return getBaseVal().getX();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#getY()}.
         */
        public float getY() {
            if (hasAnimVal) {
                return super.getY();
            }
            return getBaseVal().getY();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#getWidth()}.
         */
        public float getWidth() {
            if (hasAnimVal) {
                return super.getWidth();
            }
            return getBaseVal().getWidth();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#getHeight()}.
         */
        public float getHeight() {
            if (hasAnimVal) {
                return super.getHeight();
            }
            return getBaseVal().getHeight();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#setX(float)}.
         */
        public void setX(float value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.length",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#setY(float)}.
         */
        public void setY(float value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.length",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#setWidth(float)}.
         */
        public void setWidth(float value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.length",
                 null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGRect#setHeight(float)}.
         */
        public void setHeight(float value) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "readonly.length",
                 null);
        }

        /**
         * Sets the animated value.
         */
        protected void setAnimatedValue(float x, float y, float w, float h) {
            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;
        }
    }
}
