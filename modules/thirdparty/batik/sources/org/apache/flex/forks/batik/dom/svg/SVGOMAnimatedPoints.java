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

import java.util.ArrayList;
import java.util.Iterator;

import org.apache.flex.forks.batik.anim.values.AnimatablePointListValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.apache.flex.forks.batik.parser.ParseException;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedPoints;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGPoint;
import org.w3c.dom.svg.SVGPointList;

/**
 * This class is the implementation of the SVGAnimatedPoints interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGOMAnimatedPoints.java 527382 2007-04-11 04:31:58Z cam $
 */
public class SVGOMAnimatedPoints
        extends AbstractSVGAnimatedValue
        implements SVGAnimatedPoints {

    /**
     * The base value.
     */
    protected BaseSVGPointList baseVal;

    /**
     * The animated value.
     */
    protected AnimSVGPointList animVal;

    /**
     * Whether the list is changing.
     */
    protected boolean changing;

    /**
     * Default value for the point list.
     */
    protected String defaultValue;

    /**
     * Creates a new SVGOMAnimatedPoints.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param defaultValue The default value if the attribute is not specified.
     */
    public SVGOMAnimatedPoints(AbstractElement elt,
                               String ns,
                               String ln,
                               String defaultValue) {
        super(elt, ns, ln);
        this.defaultValue = defaultValue;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedPoints#getPoints()}.
     */
    public SVGPointList getPoints() {
        if (baseVal == null) {
            baseVal = new BaseSVGPointList();
        }
        return baseVal;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedPoints#getAnimatedPoints()}.
     */
    public SVGPointList getAnimatedPoints() {
        if (animVal == null) {
            animVal = new AnimSVGPointList();
        }
        return animVal;
    }

    /**
     * Throws an exception if the points list value is malformed.
     */
    public void check() {
        if (!hasAnimVal) {
            if (baseVal == null) {
                baseVal = new BaseSVGPointList();
            }
            baseVal.revalidate();
            if (baseVal.missing) {
                throw new LiveAttributeException
                    (element, localName,
                     LiveAttributeException.ERR_ATTRIBUTE_MISSING, null);
            }
            if (baseVal.malformed) {
                throw new LiveAttributeException
                    (element, localName,
                     LiveAttributeException.ERR_ATTRIBUTE_MALFORMED,
                     baseVal.getValueAsString());
            }
        }
    }

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    public AnimatableValue getUnderlyingValue(AnimationTarget target) {
        SVGPointList pl = getPoints();
        int n = pl.getNumberOfItems();
        float[] points = new float[n * 2];
        for (int i = 0; i < n; i++) {
            SVGPoint p = pl.getItem(i);
            points[i * 2] = p.getX();
            points[i * 2 + 1] = p.getY();
        }
        return new AnimatablePointListValue(target, points);
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            AnimatablePointListValue animPointList =
                (AnimatablePointListValue) val;
            if (animVal == null) {
                animVal = new AnimSVGPointList();
            }
            animVal.setAnimatedValue(animPointList.getNumbers());
        }
        fireAnimatedAttributeListeners();
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
     * {@link SVGPointList} implementation for the base point list value.
     */
    protected class BaseSVGPointList extends AbstractSVGPointList {

        /**
         * Whether the attribute is missing.
         */
        protected boolean missing;

        /**
         * Whether the attribute is malformed.
         */
        protected boolean malformed;

        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short type, String key,
                                                  Object[] args) {
            return element.createDOMException(type, key, args);
        }

        /**
         * Create a SVGException.
         */
        protected SVGException createSVGException(short type, String key,
                                                  Object[] args) {

            return ((SVGOMElement)element).createSVGException(type, key, args);
        }

        /**
         * Returns the value of the DOM attribute containing the point list.
         */
        protected String getValueAsString() {
            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
            if (attr == null) {
                return defaultValue;
            }
            return attr.getValue();
        }

        /**
         * Sets the DOM attribute value containing the point list.
         */
        protected void setAttributeValue(String value) {
            try {
                changing = true;
                element.setAttributeNS(namespaceURI, localName, value);
            } finally {
                changing = false;
            }
        }

        /**
         * Resets the value of the associated attribute.
         */
        protected void resetAttribute() {
            super.resetAttribute();
            missing = false;
            malformed = false;
        }

        /**
         * Appends the string representation of the given {@link SVGItem} to
         * the DOM attribute.  This is called in response to an append to
         * the list.
         */
        protected void resetAttribute(SVGItem item) {
            super.resetAttribute(item);
            missing = false;
            malformed = false;
        }

        /**
         * Initializes the list, if needed.
         */
        protected void revalidate() {
            if (valid) {
                return;
            }

            valid = true;
            missing = false;
            malformed = false;

            String s = getValueAsString();
            if (s == null) {
                missing = true;
                return;
            }
            try {
                ListBuilder builder = new ListBuilder();

                doParse(s, builder);

                if (builder.getList() != null) {
                    clear(itemList);
                }
                itemList = builder.getList();
            } catch (ParseException e) {
                itemList = new ArrayList(1);
                malformed = true;
            }
        }
    }

    /**
     * {@link SVGPointList} implementation for the animated point list value.
     */
    protected class AnimSVGPointList extends AbstractSVGPointList {

        /**
         * Creates a new AnimSVGPointList.
         */
        public AnimSVGPointList() {
            itemList = new ArrayList(1);
        }

        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short type, String key,
                                                  Object[] args) {
            return element.createDOMException(type, key, args);
        }

        /**
         * Create a SVGException.
         */
        protected SVGException createSVGException(short type, String key,
                                                  Object[] args) {

            return ((SVGOMElement)element).createSVGException(type, key, args);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPointList#getNumberOfItems()}.
         */
        public int getNumberOfItems() {
            if (hasAnimVal) {
                return super.getNumberOfItems();
            }
            return getPoints().getNumberOfItems();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPointList#getItem(int)}.
         */
        public SVGPoint getItem(int index) throws DOMException {
            if (hasAnimVal) {
                return super.getItem(index);
            }
            return getPoints().getItem(index);
        }

        /**
         * Returns the value of the DOM attribute containing the point list.
         */
        protected String getValueAsString() {
            if (itemList.size() == 0) {
                return "";
            }
            StringBuffer sb = new StringBuffer( itemList.size() * 8 );
            Iterator i = itemList.iterator();
            if (i.hasNext()) {
                sb.append(((SVGItem) i.next()).getValueAsString());
            }
            while (i.hasNext()) {
                sb.append(getItemSeparator());
                sb.append(((SVGItem) i.next()).getValueAsString());
            }
            return sb.toString();
        }

        /**
         * Sets the DOM attribute value containing the point list.
         */
        protected void setAttributeValue(String value) {
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPointList#clear()}.
         */
        public void clear() throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPointList#initialize(SVGPoint)}.
         */
        public SVGPoint initialize(SVGPoint newItem)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGPointList#insertItemBefore(SVGPoint, int)}.
         */
        public SVGPoint insertItemBefore(SVGPoint newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGPointList#replaceItem(SVGPoint, int)}.
         */
        public SVGPoint replaceItem(SVGPoint newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPointList#removeItem(int)}.
         */
        public SVGPoint removeItem(int index) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPointList#appendItem(SVGPoint)}.
         */
        public SVGPoint appendItem(SVGPoint newItem) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.point.list", null);
        }

        /**
         * Sets the animated value.
         */
        protected void setAnimatedValue(float[] pts) {
            int size = itemList.size();
            int i = 0;
            while (i < size && i < pts.length / 2) {
                SVGPointItem p = (SVGPointItem) itemList.get(i);
                p.x = pts[i * 2];
                p.y = pts[i * 2 + 1];
                i++;
            }
            while (i < pts.length / 2) {
                appendItemImpl(new SVGPointItem(pts[i * 2], pts[i * 2 + 1]));
                i++;
            }
            while (size > pts.length / 2) {
                removeItemImpl(--size);
            }
        }

        /**
         * Resets the value of the associated attribute.  Does nothing, since
         * there is no attribute for an animated value.
         */
        protected void resetAttribute() {
        }

        /**
         * Resets the value of the associated attribute.  Does nothing, since
         * there is no attribute for an animated value.
         */
        protected void resetAttribute(SVGItem item) {
        }

        /**
         * Initializes the list, if needed.  Does nothing, since there is no
         * attribute to read the list from.
         */
        protected void revalidate() {
            valid = true;
        }
    }
}
