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

import org.apache.flex.forks.batik.parser.NumberListHandler;
import org.apache.flex.forks.batik.parser.NumberListParser;
import org.apache.flex.forks.batik.parser.ParseException;

import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGNumber;
import org.w3c.dom.svg.SVGNumberList;

/**
 * This class is the implementation of {@link SVGNumberList}.
 *
 * @author <a href="mailto:tonny@kiyut.com">Tonny Kohar</a>
 * @version $Id: AbstractSVGNumberList.java 479349 2006-11-26 11:54:23Z cam $
 */
public abstract class AbstractSVGNumberList
        extends AbstractSVGList
        implements SVGNumberList {

    /**
     * Separator for a length list.
     */
    public static final String SVG_NUMBER_LIST_SEPARATOR
        = " ";

    /**
     * Return the separator between values in the list.
     */
    protected String getItemSeparator() {
        return SVG_NUMBER_LIST_SEPARATOR;
    }

    /**
     * Create an SVGException when the {@link #checkItemType(Object)} fails.
     */
    protected abstract SVGException createSVGException(short type,
                                                       String key,
                                                       Object[] args);

    /**
     * Returns the element associated with this SVGNumberList.
     */
    protected abstract Element getElement();

    /**
     * Creates a new SVGNumberList.
     */
    protected AbstractSVGNumberList() {
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#initialize(SVGNumber)}.
     */
    public SVGNumber initialize(SVGNumber newItem)
        throws DOMException, SVGException {

        return (SVGNumber)initializeImpl(newItem);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#getItem(int)}.
     */
    public SVGNumber getItem(int index) throws DOMException {

        return (SVGNumber)getItemImpl(index);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGNumberList#insertItemBefore(SVGNumber,int)}.
     */
    public SVGNumber insertItemBefore(SVGNumber newItem, int index)
        throws DOMException, SVGException {

        return (SVGNumber)insertItemBeforeImpl(newItem,index);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#replaceItem(SVGNumber,int)}.
     */
    public SVGNumber replaceItem(SVGNumber newItem, int index)
        throws DOMException, SVGException {

        return (SVGNumber)replaceItemImpl(newItem,index);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#removeItem(int)}.
     */
    public SVGNumber removeItem(int index) throws DOMException {
        return (SVGNumber)removeItemImpl(index);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#appendItem(SVGNumber)}.
     */
    public SVGNumber appendItem(SVGNumber newItem)
        throws DOMException, SVGException {

        return (SVGNumber)appendItemImpl(newItem);
    }

    /**
     * Creates a new {@link SVGNumberItem} from the given {@link SVGNumber}.
     */
    protected SVGItem createSVGItem(Object newItem) {
        SVGNumber l = (SVGNumber)newItem;
        return new SVGNumberItem(l.getValue());
    }

    /**
     * Parse the attribute associated with this SVGNumberList.
     * @param value attribute value
     * @param handler list handler
     */
    protected void doParse(String value, ListHandler handler)
        throws ParseException{

        NumberListParser NumberListParser = new NumberListParser();
        NumberListBuilder builder = new NumberListBuilder(handler);

        NumberListParser.setNumberListHandler(builder);
        NumberListParser.parse(value);
    }

    /**
     * Asserts that the given item object is an {@link SVGNumber}.
     */
    protected void checkItemType(Object newItem) throws SVGException {
        if (!(newItem instanceof SVGNumber)) {
            // XXX Fix error code.
            createSVGException(SVGException.SVG_WRONG_TYPE_ERR,
                               "expected SVGNumber",
                               null);
        }
    }

    /**
     * Representation of the item SVGNumber.
     */
    protected class SVGNumberItem extends AbstractSVGNumber implements SVGItem {

        /**
         * The {@link SVGNumberList} this item belongs to.
         */
        protected AbstractSVGList parentList;

        /**
         * Creates a new SVGNumberItem.
         */
        public SVGNumberItem(float value) {
            this.value = value;
        }

        /**
         * Returns a String representation of the number.
         */
        public String getValueAsString() {
            return Float.toString(value);
        }

        /**
         * Associates this item to the given {@link SVGNumberList}.
         */
        public void setParent(AbstractSVGList list) {
            parentList = list;
        }

        /**
         * Returns the list the item belongs to.
         */
        public AbstractSVGList getParent() {
            return parentList;
        }

        /**
         * Notifies the parent {@link SVGNumberList} that this item's value
         * has changed.
         */
        protected void reset() {
            if (parentList != null) {
                parentList.itemChanged();
            }
        }
    }

    /**
     * Helper class to interface the {@link NumberListParser} and the
     * {@link NumberListHandler}.
     */
    protected class NumberListBuilder implements NumberListHandler {

        /**
         * The ListHandler to notify of parsed numbers.
         */
        protected ListHandler listHandler;

        /**
         * The number just parsed.
         */
        protected float currentValue;

        /**
         * Creates a new NumberListBuilder.
         */
        public NumberListBuilder(ListHandler listHandler) {
            this.listHandler = listHandler;
        }

        /**
         * Implements {@link NumberListHandler#startNumberList()}.
         */
        public void startNumberList() throws ParseException{
            listHandler.startList();
        }

        /**
         * Implements {@link NumberListHandler#startNumber()}.
         */
        public void startNumber() throws ParseException {
            currentValue = 0.0f;
        }

        /**
         * Implements {@link NumberListHandler#numberValue(float)}.
         */
        public void numberValue(float v) throws ParseException {
            currentValue = v;
        }

        /**
         * Implements {@link NumberListHandler#endNumber()}.
         */
        public void endNumber() throws ParseException {
            listHandler.item(new SVGNumberItem(currentValue));
        }

        /**
         * Implements {@link NumberListHandler#endNumberList()}.
         */
        public void endNumberList() throws ParseException {
            listHandler.endList();
        }
    }
}
