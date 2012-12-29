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
import java.util.List;

import org.apache.flex.forks.batik.anim.values.AnimatableTransformListValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.apache.flex.forks.batik.parser.ParseException;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedTransformList;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGTransform;
import org.w3c.dom.svg.SVGTransformList;

/**
 * This class is the implementation of the SVGAnimatedTransformList interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGOMAnimatedTransformList.java 594018 2007-11-12 04:17:41Z cam $
 */
public class SVGOMAnimatedTransformList
        extends AbstractSVGAnimatedValue
        implements SVGAnimatedTransformList {

    /**
     * The base value.
     */
    protected BaseSVGTransformList baseVal;

    /**
     * The animated value.
     */
    protected AnimSVGTransformList animVal;

    /**
     * Whether the list is changing.
     */
    protected boolean changing;

    /**
     * Default value for the 'transform' attribute.
     */
    protected String defaultValue;

    /**
     * Creates a new SVGOMAnimatedTransformList.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param defaultValue The default value if the attribute is not specified.
     */
    public SVGOMAnimatedTransformList(AbstractElement elt,
                                      String ns,
                                      String ln,
                                      String defaultValue) {
        super(elt, ns, ln);
        this.defaultValue = defaultValue;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedTransformList#getBaseVal()}.
     */
    public SVGTransformList getBaseVal() {
        if (baseVal == null) {
            baseVal = new BaseSVGTransformList();
        }
        return baseVal;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedTransformList#getAnimVal()}.
     */
    public SVGTransformList getAnimVal() {
        if (animVal == null) {
            animVal = new AnimSVGTransformList();
        }
        return animVal;
    }

    /**
     * Throws an exception if the points list value is malformed.
     */
    public void check() {
        if (!hasAnimVal) {
            if (baseVal == null) {
                baseVal = new BaseSVGTransformList();
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
        SVGTransformList tl = getBaseVal();
        int n = tl.getNumberOfItems();
        List v = new ArrayList(n);
        for (int i = 0; i < n; i++) {
            v.add(tl.getItem(i));
        }
        return new AnimatableTransformListValue(target, v);
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            AnimatableTransformListValue aval =
                (AnimatableTransformListValue) val;
            if (animVal == null) {
                animVal = new AnimSVGTransformList();
            }
            animVal.setAnimatedValue(aval.getTransforms());
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
     * {@link SVGTransformList} implementation for the base transform list value.
     */
    public class BaseSVGTransformList extends AbstractSVGTransformList {

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
         * Returns the value of the DOM attribute containing the transform list.
         */
        protected String getValueAsString() {
            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
            if (attr == null) {
                return defaultValue;
            }
            return attr.getValue();
        }

        /**
         * Sets the DOM attribute value containing the transform list.
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
     * {@link SVGTransformList} implementation for the animated transform list
     * value.
     */
    protected class AnimSVGTransformList extends AbstractSVGTransformList {

        /**
         * Creates a new AnimSVGTransformList.
         */
        public AnimSVGTransformList() {
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
         * <b>DOM</b>: Implements {@link SVGTransformList#getNumberOfItems()}.
         */
        public int getNumberOfItems() {
            if (hasAnimVal) {
                return super.getNumberOfItems();
            }
            return getBaseVal().getNumberOfItems();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransformList#getItem(int)}.
         */
        public SVGTransform getItem(int index) throws DOMException {
            if (hasAnimVal) {
                return super.getItem(index);
            }
            return getBaseVal().getItem(index);
        }

        /**
         * Returns the value of the DOM attribute containing the transform list.
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
         * Sets the DOM attribute value containing the transform list.
         */
        protected void setAttributeValue(String value) {
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransformList#clear()}.
         */
        public void clear() throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransformList#initialize(SVGTransform)}.
         */
        public SVGTransform initialize(SVGTransform newItem)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGTransformList#insertItemBefore(SVGTransform, int)}.
         */
        public SVGTransform insertItemBefore(SVGTransform newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGTransformList#replaceItem(SVGTransform, int)}.
         */
        public SVGTransform replaceItem(SVGTransform newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransformList#removeItem(int)}.
         */
        public SVGTransform removeItem(int index) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransformList#appendItem(SVGTransform)}.
         */
        public SVGTransform appendItem(SVGTransform newItem) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransformList#consolidate()}.
         */
        public SVGTransform consolidate() {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.transform.list", null);
        }

        /**
         * Sets the animated value to a list of transforms.
         */
        protected void setAnimatedValue(Iterator it) {
            int size = itemList.size();
            int i = 0;
            while (i < size && it.hasNext()) {
                SVGTransformItem t = (SVGTransformItem) itemList.get(i);
                t.assign((SVGTransform) it.next());
                i++;
            }
            while (it.hasNext()) {
                appendItemImpl(new SVGTransformItem((SVGTransform) it.next()));
                i++;
            }
            while (size > i) {
                removeItemImpl(--size);
            }
        }

        /**
         * Sets the animated value to a single transform.
         */
        protected void setAnimatedValue(SVGTransform transform) {
            int size = itemList.size();
            while (size > 1) {
                removeItemImpl(--size);
            }
            if (size == 0) {
                appendItemImpl(new SVGTransformItem(transform));
            } else {
                SVGTransformItem t = (SVGTransformItem) itemList.get(0);
                t.assign(transform);
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
