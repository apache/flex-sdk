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

import org.apache.flex.forks.batik.anim.values.AnimatableNumberListValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.apache.flex.forks.batik.parser.ParseException;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGAnimatedNumberList;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGNumber;
import org.w3c.dom.svg.SVGNumberList;

/**
 * This class is the implementation of the {@link SVGAnimatedNumberList}
 * interface.
 *
 * @author <a href="mailto:tonny@kiyut.com">Tonny Kohar</a>
 * @version $Id: SVGOMAnimatedNumberList.java 527382 2007-04-11 04:31:58Z cam $
 */
public class SVGOMAnimatedNumberList
    extends AbstractSVGAnimatedValue
    implements SVGAnimatedNumberList {

    /**
     * The base value.
     */
    protected BaseSVGNumberList baseVal;

    /**
     * The animated value.
     */
    protected AnimSVGNumberList animVal;

    /**
     * Whether the list is changing.
     */
    protected boolean changing;

    /**
     * Default value for the number list.
     */
    protected String defaultValue;

    /**
     * Whether empty length lists are allowed.
     */
    protected boolean emptyAllowed;

    /**
     * Creates a new SVGOMAnimatedNumberList.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param defaultValue The default value if the attribute is not specified.
     * @param emptyAllowed Whether an empty number list is allowed.
     */
    public SVGOMAnimatedNumberList(AbstractElement elt,
                                   String ns,
                                   String ln,
                                   String defaultValue,
                                   boolean emptyAllowed) {
        super(elt, ns, ln);
        this.defaultValue = defaultValue;
        this.emptyAllowed = emptyAllowed;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedNumberList#getBaseVal()}.
     */
    public SVGNumberList getBaseVal() {
        if (baseVal == null) {
            baseVal = new BaseSVGNumberList();
        }
        return baseVal;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedNumberList#getAnimVal()}.
     */
    public SVGNumberList getAnimVal() {
        if (animVal == null) {
            animVal = new AnimSVGNumberList();
        }
        return animVal;
    }

    /**
     * Throws an exception if the number list value is malformed.
     */
    public void check() {
        if (!hasAnimVal) {
            if (baseVal == null) {
                baseVal = new BaseSVGNumberList();
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
        SVGNumberList nl = getBaseVal();
        int n = nl.getNumberOfItems();
        float[] numbers = new float[n];
        for (int i = 0; i < n; i++) {
            numbers[i] = nl.getItem(n).getValue();
        }
        return new AnimatableNumberListValue(target, numbers);
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            AnimatableNumberListValue animNumList =
                (AnimatableNumberListValue) val;
            if (animVal == null) {
                animVal = new AnimSVGNumberList();
            }
            animVal.setAnimatedValue(animNumList.getNumbers());
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
     * {@link SVGNumberList} implementation for the base number list value.
     */
    public class BaseSVGNumberList extends AbstractSVGNumberList {

        /**
         * Whether the value is missing.
         */
        protected boolean missing;

        /**
         * Whether the value is malformed.
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
         * Returns the element owning the attribute with which this length
         * list is associated.
         */
        protected Element getElement() {
            return element;
        }

        /**
         * Returns the value of the DOM attribute containing the number list.
         */
        protected String getValueAsString() {
            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
            if (attr == null) {
                return defaultValue;
            }
            return attr.getValue();
        }

        /**
         * Sets the DOM attribute value containing the number list.
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
            boolean isEmpty = s != null && s.length() == 0;
            if (s == null || isEmpty && !emptyAllowed) {
                missing = true;
                return;
            }
            if (isEmpty) {
                itemList = new ArrayList(1);
            } else {
                try {
                    ListBuilder builder = new ListBuilder();

                    doParse(s, builder);

                    if (builder.getList() != null) {
                        clear(itemList);
                    }
                    itemList = builder.getList();
                } catch (ParseException e) {
                    itemList = new ArrayList(1);
                    valid = true;
                    malformed = true;
                }
            }
        }
    }

    /**
     * {@link SVGNumberList} implementation for the animated number list value.
     */
    protected class AnimSVGNumberList extends AbstractSVGNumberList {

        /**
         * Creates a new AnimSVGNumberList.
         */
        public AnimSVGNumberList() {
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
         * Returns the element owning this SVGNumberList.
         */
        protected Element getElement() {
            return element;
        }

        /**
         * <b>DOM</b>: Implements {@link SVGNumberList#getNumberOfItems()}.
         */
        public int getNumberOfItems() {
            if (hasAnimVal) {
                return super.getNumberOfItems();
            }
            return getBaseVal().getNumberOfItems();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGNumberList#getItem(int)}.
         */
        public SVGNumber getItem(int index) throws DOMException {
            if (hasAnimVal) {
                return super.getItem(index);
            }
            return getBaseVal().getItem(index);
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
         * <b>DOM</b>: Implements {@link SVGNumberList#clear()}.
         */
        public void clear() throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.number.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGNumberList#initialize(SVGNumber)}.
         */
        public SVGNumber initialize(SVGNumber newItem)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.number.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGNumberList#insertItemBefore(SVGNumber, int)}.
         */
        public SVGNumber insertItemBefore(SVGNumber newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.number.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGNumberList#replaceItem(SVGNumber, int)}.
         */
        public SVGNumber replaceItem(SVGNumber newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.number.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGNumberList#removeItem(int)}.
         */
        public SVGNumber removeItem(int index) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.number.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGNumberList#appendItem(SVGNumber)}.
         */
        public SVGNumber appendItem(SVGNumber newItem) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.number.list", null);
        }

        /**
         * Sets the animated value.
         */
        protected void setAnimatedValue(float[] values) {
            int size = itemList.size();
            int i = 0;
            while (i < size && i < values.length) {
                SVGNumberItem n = (SVGNumberItem) itemList.get(i);
                n.value = values[i];
                i++;
            }
            while (i < values.length) {
                appendItemImpl(new SVGNumberItem(values[i]));
                i++;
            }
            while (size > values.length) {
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
