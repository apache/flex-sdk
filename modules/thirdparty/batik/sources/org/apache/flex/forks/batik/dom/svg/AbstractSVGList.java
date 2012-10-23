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

import org.apache.flex.forks.batik.parser.ParseException;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGException;


/**
 * This class is a base implementation for a live
 * list representation of SVG attributes.
 * <p>
 *   This class provides support for an SVG list representation of an
 *   attribute.  It implements basic list functionality that is common to all
 *   of the <code>SVG*List</code> interfaces.
 * </p>
 * <p>
 *   For a specific attribute, it requires an {@link #getValueAsString()
 *   attribute value}, a {@link #doParse(String,ListHandler) parser},
 *   and a method to {@link #createSVGItem(Object) create items}.
 * </p>
 * <p>
 *   Whenever the attribute changes outside of the control of the list, this
 *   list must be {@link #invalidate invalidated}.
 * </p>
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: AbstractSVGList.java 511565 2007-02-25 18:04:46Z dvholten $
 */
public abstract class AbstractSVGList {

    /**
     * Whether this list is valid.
     */
    protected boolean valid;

    /**
     * The list of items.
     */
    protected List itemList;

    /**
     * Returns the separator string to use when constructing a string
     * representation of the entire list.
     */
    protected abstract String getItemSeparator();

    /**
     * Creates an {@link SVGItem} object that has the same values as those
     * in the specified SVG object.
     *
     * @param newItem the SVG object
     * @return the newly created {@link SVGItem} object
     */
    protected abstract SVGItem createSVGItem(Object newItem);

    /**
     * Parses the given attribute value and informs the specified
     * {@link ListHandler} of the parsed list items.
     *
     * @param value the attribute value to be parsed
     * @param builder the object to be informed of the parsed list items
     */
    protected abstract void doParse(String value, ListHandler builder)
        throws ParseException;

    /**
     * Asserts that the given object is an appropriate SVG object for this list.
     */
    protected abstract void checkItemType(Object newItem)
        throws SVGException;

    /**
     * Returns the value of the DOM attribute containing the list.
     */
    protected abstract String getValueAsString();

    /**
     * Sets the DOM attribute value containing the number list.
     * @param value the String representation of the list, or null
     *              if the list contains no items
     */
    protected abstract void setAttributeValue(String value);

    /**
     * Create a DOM Exception.
     */
    protected abstract DOMException createDOMException(short type, String key,
                                                       Object[] args);

    /**
     * Returns the number of items in the list.
     */
    public int getNumberOfItems() {
        revalidate();
        if (itemList != null) {
            return itemList.size();
        }
        return 0;
    }

    /**
     * Removes all items from the list.
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR:
     *   Raised when the list cannot be modified.
     */
    public void clear() throws DOMException {
        revalidate();
        if (itemList != null) {
            // Remove all the items.
            clear(itemList);
            // Set the DOM attribute.
            resetAttribute();
        }
    }

    /**
     * Removes all items from the list and adds the specified item to
     * the list.
     *
     * @param newItem the item which should become the only member of the list.
     * @return the item being inserted into the list.
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR:
     *   Raised when the list cannot be modified.
     * @exception SVGException SVG_WRONG_TYPE_ERR:
     *   Raised if parameter newItem is the wrong type of object for the given
     *   list.
     */
    protected SVGItem initializeImpl(Object newItem)
        throws DOMException, SVGException {

        checkItemType(newItem);

        // Clear the list, creating it if it doesn't exist yet.
        if (itemList == null) {
            itemList = new ArrayList(1);
        } else {
            clear(itemList);
        }

        SVGItem item = removeIfNeeded(newItem);

        // Add the item.
        itemList.add(item);

        // Set the item's parent.
        item.setParent(this);

        // Update the DOM attribute.
        resetAttribute();

        return item;
    }

    /**
     * Returns the item from the list at the specified index.
     *
     * @param index The index of the item from the list which is to be returned.
     *   The first item is number 0.
     * @return The selected item.
     * @exception DOMException INDEX_SIZE_ERR:
     *   Raised if the index number is negative or greater than or equal to
     *   <code>numberOfItems</code>.
     */
    protected SVGItem getItemImpl(int index) throws DOMException {
        revalidate();

        if (index < 0 || itemList == null || index >= itemList.size()) {
            throw createDOMException
                (DOMException.INDEX_SIZE_ERR, "index.out.of.bounds",
                 new Object[] { new Integer(index) } );
        }

        return (SVGItem)itemList.get(index);
    }

    /**
     * Inserts a new item into the list at the specified position.
     * <p>
     *   The first item is number 0. If <code>newItem</code> is already in a
     *   list, it is removed from its previous list before it is inserted into
     *   this list.
     * </p>
     *
     * @param newItem The item which is to be inserted
     *   into the list.
     * @param index The index of the item before which
     *   the new item is to be inserted. The first item
     *   is number 0. If the index is equal to 0, then
     *   the new item is inserted at the front of the
     *   list. If the index is greater than or equal to
     *   <code>numberOfItems</code>, then the new item is appended
     *   to the end of the list.
     * @return The inserted item.
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR:
     *   Raised when the list cannot be modified.
     * @exception SVGException SVG_WRONG_TYPE_ERR:
     *   Raised if parameter <code>newItem</code> is the wrong type of
     *   object for the given list.
     */
    protected SVGItem insertItemBeforeImpl(Object newItem, int index)
        throws DOMException, SVGException {

        checkItemType(newItem);

        revalidate();
        if (index < 0) {
            throw createDOMException
                (DOMException.INDEX_SIZE_ERR, "index.out.of.bounds",
                 new Object[] { new Integer(index) } );
        }

        if (index > itemList.size()) {
            index = itemList.size();
        }

        SVGItem item = removeIfNeeded(newItem);

        // Insert the item at its position.
        itemList.add(index, item);

        // Set the item's parent.
        item.setParent(this);

        // Reset the DOM attribute.
        resetAttribute();

        return item;
    }

    /**
     * Replaces an existing item in the list with a new item.
     * <p>
     *   If <code>newItem</code> is already in a list, it is removed from its
     *   previous list before it is inserted into this list.
     * </p>
     *
     * @param newItem The item which is to be inserted
     *   into the list.
     * @param index The index of the item which is to
     *   be replaced. The first item is number 0.
     * @return The inserted item.
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR:
     *   Raised when the list cannot be modified.
     * @exception DOMException INDEX_SIZE_ERR:
     *   Raised if the index number is negative or greater
     *   than or equal to <code>numberOfItems</code>.
     * @exception SVGException SVG_WRONG_TYPE_ERR:
     *   Raised if parameter newItem is the wrong type
     *   of object for the given list.
     */
    protected SVGItem replaceItemImpl(Object newItem, int index)
        throws DOMException, SVGException {

        checkItemType(newItem);

        revalidate();
        if (index < 0 || index >= itemList.size()) {
            throw createDOMException
                (DOMException.INDEX_SIZE_ERR, "index.out.of.bounds",
                 new Object[] { new Integer(index) } );
        }

        SVGItem item = removeIfNeeded(newItem);

        // Replace the item in the list.
        itemList.set(index, item);

        // Set the item's parent.
        item.setParent(this);

        // Reset the DOM attribute.
        resetAttribute();

        return item;
    }

    /**
     * Removes an existing item from the list.
     *
     * @param index The index of the item which
     *   is to be removed. The first item is number 0.
     * @return The removed item.
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR:
     *   Raised when the list cannot be modified.
     * @exception DOMException INDEX_SIZE_ERR:
     *   Raised if the index number is negative or greater
     *   than or equal to <code>numberOfItems</code>.
     */
    protected SVGItem removeItemImpl(int index) throws DOMException {
        revalidate();

        if (index < 0 || index >= itemList.size()) {
            throw createDOMException
                (DOMException.INDEX_SIZE_ERR, "index.out.of.bounds",
                 new Object[] { new Integer(index) } );
        }

        SVGItem item = (SVGItem)itemList.remove(index);

        // Set the item to have no parent list.
        item.setParent(null);

        // Reset the DOM attribute.
        resetAttribute();

        return item;
    }

    /**
     * Inserts a new item at the end of the list.
     * If newItem is already in a list, it is removed from its previous list
     * before it is inserted into this list.
     *
     * @param newItem The item which is to be inserted into the list. The
     *   first item is number 0.
     * @return The inserted item.
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR:
     *   Raised when the list cannot be modified.
     * @exception SVGException SVG_WRONG_TYPE_ERR:
     *   Raised if parameter newItem is the wrong type of object for the given
     *   list.
     */
    protected SVGItem appendItemImpl(Object newItem)
        throws DOMException, SVGException {

        checkItemType(newItem);

        revalidate();

        SVGItem item = removeIfNeeded(newItem);

        itemList.add(item);

        // Set the item's parent.
        item.setParent(this);

        if (itemList.size() <= 1) {
            resetAttribute();
        } else {
            resetAttribute(item);
        }

        return item;
    }

    /**
     * Removes the specified object from its parent list if it is an item, or
     * creates a new item if the specified object is not an item.
     *
     * @param newItem an instance of {@link SVGItem} to remove from its parent
     *   list, or an SVG object for which a new {@link SVGItem} should be
     *   created
     * @return item the {@link SVGItem} just removed from its parent list, or
     *   the newly created {@link SVGItem}
     */
    protected SVGItem removeIfNeeded(Object newItem) {
        SVGItem item;
        if (newItem instanceof SVGItem) {
            // This is an existing item, so remove it from its parent list.
            item = (SVGItem)newItem;
            if (item.getParent() != null) {
                item.getParent().removeItem(item);
            }
        } else {
            // This must be an SVG object, so create a new SVGItem from it.
            item = createSVGItem(newItem);
        }
        return item;
    }

    /**
     * Initializes the list, if needed.
     */
    protected void revalidate() {
        if (valid) {
            return;
        }

        try {
            ListBuilder builder = new ListBuilder();

            doParse(getValueAsString(), builder);

            List parsedList = builder.getList();
            if (parsedList != null) {
                clear(itemList);
            }
            itemList = parsedList;
        } catch (ParseException e) {
            itemList = null;
        }
        valid = true;
    }

    /**
     * Sets the DOM attribute value to be the string representation of the
     * given list.
     */
    protected void setValueAsString(List value) throws DOMException {
        String finalValue = null;
        Iterator it = value.iterator();
        if (it.hasNext()) {
            SVGItem item = (SVGItem) it.next();
            StringBuffer buf = new StringBuffer( value.size() * 8 );
            buf.append(  item.getValueAsString() );
            while (it.hasNext()) {
                item = (SVGItem) it.next();
                buf.append(getItemSeparator());
                buf.append(item.getValueAsString());
            }
            finalValue = buf.toString();
        }
        setAttributeValue(finalValue);
        valid = true;
    }

    /**
     * Method to be called by a member {@link SVGItem} object when its value
     * changes.  This causes the DOM attribute to be reset.
     */
    public void itemChanged() {
        resetAttribute();
    }

    /**
     * Resets the value of the associated attribute.
     */
    protected void resetAttribute() {
        setValueAsString(itemList);
    }

    /**
     * Appends the string representation of the given {@link SVGItem} to
     * the DOM attribute.  This is called in response to an append to
     * the list.
     */
    protected void resetAttribute(SVGItem item) {
        String newValue = getValueAsString() + getItemSeparator() + item.getValueAsString();
        setAttributeValue( newValue );
        valid = true;
    }

    /**
     * Invalidates this list.
     */
    public void invalidate() {
        valid = false;
    }

    /**
     * Removes an item from the list.
     *
     * This operation takes place when an
     * item was already in one list and
     * is being added to another one.
     */
    protected void removeItem(SVGItem item) {
        if (itemList.contains(item)) {
            itemList.remove(item);
            item.setParent(null);
            resetAttribute();
        }
    }

    /**
     * Clears the list and sets the parent of the former list items to null.
     */
    protected void clear(List list) {
        if (list == null) {
            return;
        }
        Iterator it = list.iterator();
        while (it.hasNext()) {
            SVGItem item = (SVGItem)it.next();
            item.setParent(null);
        }
        list.clear();
    }

    /**
     * A class for receiving notification of parsed list items.
     */
    protected class ListBuilder implements ListHandler {

        /**
         * The list being built.
         */
        protected List list;

        /**
         * Returns the newly created list.
         */
        public List getList() {
            return list;
        }

        /**
         * Begins the construction of the list.
         */
        public void startList(){
            list = new ArrayList();
        }

        /**
         * Adds an item to the list.
         */
        public void item(SVGItem item) {
            item.setParent(AbstractSVGList.this);
            list.add(item);
        }

        /**
         * Ends the construction of the list.
         */
        public void endList() {
        }
    }
}
