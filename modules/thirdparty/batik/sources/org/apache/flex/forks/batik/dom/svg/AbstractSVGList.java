/*

   Copyright 2003-2004  The Apache Software Foundation 

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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.flex.forks.batik.parser.ParseException;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGException;


/**
 * This class is a base implementation for a live
 * list representation of SVG attributes.
 *
 * This classe provides support for a SVG List
 * representation of an attribute. It implements
 * the basic functionnalities.
 *
 * For a specific attribute, it requires a 
 * {@link #getValueAsString() attribute value},
 * a {@link #doParse(String,ListHandler) parser},
 * and the {@link #createSVGItem(Object) item creation}
 *
 * Whenever the attribute changes outside of
 * the control of the list, this list must be
 * {@link #invalidate invalidated }
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: AbstractSVGList.java,v 1.7 2005/03/27 08:58:32 cam Exp $
 */
public abstract class AbstractSVGList {

    /**
     * Whether this list is valid.
     */
    protected boolean valid;

    /**
     * List of item
     */
    protected List itemList;

    /**
     * Return the separator for the item is the list.
     *
     * @return separator of items in the list
     */
    protected abstract String getItemSeparator();

    /**
     * Return the item to be placed in the list.
     *
     * According to the parameter of the real SVGList
     * represented here by an <code>Object</code>
     * the implementation provide an item to be placed
     * in the list.
     *
     * @param newItem paramter of the modification method
     *   of the list
     *
     * @return an item to be placed in the list.
     */
    protected abstract SVGItem createSVGItem(Object newItem);

    /**
     * Parse the value of the attribute and build a list.
     *
     * Use a dedicated parser for the attribute and the list
     * handler to build the list.
     *
     * @param value value of the attribute to be parsed
     * @param builder list handler to create the list
     */
    protected abstract void doParse(String value, ListHandler builder)
        throws ParseException;

    /**
     * Check the type of the element added to the list.
     *
     * @param newItem object to test
     */
    protected abstract void checkItemType(Object newItem)
        throws SVGException;


    /**
     * Return the <code>String</code> value associated
     * to the attribute in the DOM.
     *
     * @return value of the attribute
     */
    protected abstract String getValueAsString();

    /**
     * Apply the changes of the list to the 
     * attribute this list represents.
     *
     * @param value new value of the attribute
     *   the value can be null if no item
     *   are present in the list.
     */
    protected abstract void setAttributeValue(String value);

    /**
     * Create a DOM Exception.
     */
    protected abstract DOMException createDOMException(short    type,
                                                       String   key,
                                                       Object[] args);

    /**
     * Creates a new AbstractSVGList.
     */
    protected AbstractSVGList() {
    }
                                
    /**
     * Return the number of items in the list.
     *
     * @return number of items in the list
     */
    public int getNumberOfItems( ){

        revalidate();

        if ( itemList != null ){
            return itemList.size();
        }
        else{
            return 0;
        }
    }

    /**
     * Clears all existing current items from 
     * the list, with the result being an empty 
     * list.
     * 
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR: 
     *   Raised when the listcannot be modified.
     */
    public void clear()
        throws DOMException {
        revalidate();
        if ( itemList != null ){
            //set parents to null
            clear(itemList);
            //set the DOM attribute
            resetAttribute();
        }
    }

    /**
     * Clears all existing current items from 
     * the list and re-initializes the list to 
     * hold the single item specified by the 
     * parameter.
     *
     * @param newItem The item which should 
     *   become the only member of the list.
     *
     * @return The item being inserted into the list.
     *
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR: 
     *   Raised when the list cannot be modified.
     * @exception SVGException SVG_WRONG_TYPE_ERR: 
     *   Raised if parameter newItem is the wrong 
     *   type of object for the given list.
     */
    protected SVGItem initializeImpl ( Object newItem )
        throws DOMException, SVGException {

        checkItemType(newItem);
        
        //create the list or clean it
        if ( itemList == null ) {
            itemList = new ArrayList(1);
        }
        else{
            //set the parents to null
            clear(itemList);
        }

        SVGItem item = removeIfNeeded(newItem);

        //add the item, the list contains nothing.
        itemList.add(item);

        //set the parent 
        item.setParent(this);

        //update the XML attribute
        resetAttribute();

        return( item );
    }

    /**
     * Returns the specified item from the list.
     *
     * @param index The index of the item 
     *   from the list which is to be returned. 
     *   The first item is number 0.
     * @return The selected item.
     *
     * @exception DOMException INDEX_SIZE_ERR: 
     *   Raised if the index number is negative or
     *   greater than or equal to numberOfItems.
     */
    protected SVGItem getItemImpl ( int index )
        throws DOMException {
        revalidate();

        if ( index < 0 || itemList == null || index >= itemList.size() ){
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                    "AbstractSVGList.getItem.OutOfBoundsException",
                    null);
        }

        return (SVGItem)itemList.get(index);
    }

    /**
     * Inserts a new item into the list at 
     * the specified position. 
     *
     * The first item is number 0. If newItem 
     * is already in a list, it is removed from 
     * its previous list before it is inserted into
     * this list.
     *
     * @param newItem The item which is to be inserted 
     *   into the list.
     * @param index The index of the item before which 
     *   the new item is to be inserted. The first item 
     *   is number 0. If the index is equal to 0, then 
     *   the new item is inserted at the front of the 
     *   list. If the index is greater than or equal to 
     *   numberOfItems, then the new item is appended 
     *   to the end of the list.
     *
     * @return The inserted item.
     *
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR: 
     *   Raised when the list cannot be modified.
     * @exception SVGException SVG_WRONG_TYPE_ERR: 
     *   Raised if parameter newItem is the wrong type of 
     *   object for the given list.
     */
    protected SVGItem insertItemBeforeImpl ( Object newItem, int index )
        throws DOMException, SVGException {

        checkItemType(newItem);

        revalidate();
        if ( index < 0 ) {
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                    "AbstractSVGList.insertItemBefore.OutOfBoundsException",
                    null);
        }
        
        if ( index > itemList.size() ){
            index = itemList.size();
        }

        SVGItem item = removeIfNeeded(newItem);

        //add the item at its position
        itemList.add(index,item);

        //set the parent
        item.setParent(this);

        resetAttribute();

        return( item );
    }


    /**
     * Replaces an existing item in the list with a 
     * new item. 
     * If newItem is already in a list, it is removed 
     * from its previous list before it is inserted 
     * into this list.
     *
     * @param newItem The item which is to be inserted 
     *   into the list.
     * @param index The index of the item which is to
     *   be replaced. The first item is number 0.
     *
     * @return The inserted item.
     *
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR: 
     *   Raised when the list cannot be modified.
     *                         INDEX_SIZE_ERR: 
     *   Raised if the index number is negative or greater 
     *   than or equal to numberOfItems.
     * @exception SVGException SVG_WRONG_TYPE_ERR: 
     *   Raised if parameter newItem is the wrong type 
     *   of object for the given list.
     */
    protected SVGItem replaceItemImpl ( Object newItem, int index )
        throws DOMException, SVGException {

        checkItemType(newItem);

        revalidate();
        if ( index < 0 || index >= itemList.size() ){
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                    "AbstractSVGList.replaceItem.OutOfBoundsException",
                    null);
        }

        SVGItem item = removeIfNeeded(newItem);

        //substitute the item 
        itemList.set(index,item);

        //set the parent
        item.setParent(this);

        resetAttribute();

        return( item );
    }
    
    /**
     * Removes an existing item from the list.
     *
     * @param index The index of the item which 
     *   is to be removed. The first item is number 0.
     *
     * @return The removed item.
     *
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR: 
     *   Raised when the list cannot be modified.
     *                         INDEX_SIZE_ERR: 
     *   Raised if the index number is negative or greater 
     *   than or equal to numberOfItems.
     */
    protected SVGItem removeItemImpl ( int index )
        throws DOMException {

        revalidate();
        if ( index < 0 || index >= itemList.size() ){
            throw createDOMException(DOMException.INDEX_SIZE_ERR,
                   "AbstractSVGList.removeItem.OutOfBoundsException",
                   null);
        }

        SVGItem item = (SVGItem)itemList.remove(index);
        
        //no parent assign to the item since removed
        item.setParent(null);
        
        resetAttribute();

        return( item );
    }
    
    /**
     * Inserts a new item at the end of the list. 
     * If newItem is already in a list, it is removed from
     * its previous list before it is inserted into this list.
     *
     * @param newItem The item which is to be inserted 
     *  into the list. The first item is number 0.
     *
     * @return The inserted item.
     *
     * @exception DOMException NO_MODIFICATION_ALLOWED_ERR: 
     *   Raised when the list cannot be modified.
     * @exception SVGException SVG_WRONG_TYPE_ERR: 
     *   Raised if parameter newItem is the wrong type 
     *   of object for the given list.
     */
    protected SVGItem appendItemImpl ( Object newItem )
        throws DOMException, SVGException {

        checkItemType(newItem);

        revalidate();

        SVGItem item = removeIfNeeded(newItem);

        itemList.add(item);

        //set the parent
        item.setParent(this);

        if ( itemList.size() <= 1 ){
            resetAttribute();
        }
        else{
            resetAttribute(item);
        }
        
        return( item );
    }

    /**
     * If the itemis already in another list,
     * then remove the item from its parent list.
     * If not, create a proper item for the
     * object representing the type of item
     * the list contains
     *
     * checkItemItem was preformed previously.
     *
     * @param newItem : item to be removed
     *  from its parent list potentially
     *
     * @return item to be inserted in the list.
     */
    protected SVGItem removeIfNeeded(Object newItem){

        SVGItem item = null;

        if ( newItem instanceof SVGItem ){
            //existing item, remove the item
            // first from its original list
            item = (SVGItem)newItem;
            if ( item.getParent() != null ){
                item.getParent().removeItem(item);
            }
        }
        else{
            item = createSVGItem( newItem );
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
        
        try{
            ListBuilder builder = new ListBuilder();

            doParse(getValueAsString(),builder);

            if ( builder.getList() != null ){
                clear(itemList);
            }
            itemList = builder.getList();
        }
        catch(ParseException e){
            itemList = null;
        }
        valid = true;
    }

    /**
     * Set the attribute value in the DOM.
     *
     * @param value list of item to be used as
     *   the new attribute value.
     */
    protected void setValueAsString(List value) throws DOMException {

        StringBuffer buf = null;
        Iterator it = value.iterator();
        while( it.hasNext() ){
            SVGItem item = ( SVGItem )it.next();

            if ( buf == null ){
                buf = new StringBuffer(item.getValueAsString());
            }
            else{
                buf.append(getItemSeparator());
                buf.append(item.getValueAsString());
            }
        }
        String finalValue = null;
        if ( buf == null ){
            finalValue = null;
        }
        else{
            finalValue = buf.toString();
        }
        setAttributeValue(finalValue);

        valid = true;
    }

    /**
     */
    public void itemChanged(){
        resetAttribute();
    }

    /**
     * Resets the value of the associated attribute.
     */
    protected void resetAttribute() {
        setValueAsString(itemList);
    }

    /**
     * Resets the value of the associated attribute.
     *
     * @param item : last item appended
     */
    protected void resetAttribute(SVGItem item) {
        StringBuffer buf = new StringBuffer(getValueAsString());
        buf.append(getItemSeparator());
        buf.append(item.getValueAsString());
        setAttributeValue(buf.toString());
        valid = true;
    }

    /**
     * Invalidates this list.
     */
    public void invalidate() {
        valid = false;
    }

    /**
     * Remove an item from the list.
     *
     * This operation takes place when an
     * item was already in one list and 
     * is being added to another one.
     *
     * @param item the item to be removed from 
     *   this list
     */
    protected void removeItem(SVGItem item){
        if ( itemList.contains(item) ){
            itemList.remove(item);
            item.setParent(null);
            resetAttribute();
        }
    } 

    /**
     * Clear the list and set the parent 
     * of the items to null.
     *
     * @param list to be cleared
     */
    protected void clear(List list){
        if ( list == null ){
            return;
        }

        Iterator it = list.iterator();

        while( it.hasNext() ){
            SVGItem item = (SVGItem)it.next();
            item.setParent(null);
        }

        list.clear();
    }

    /**
     * Local list handler implementation.
     *
     * This will contructs a list of item coming
     * out of the parser for the attribute.
     */
    protected class ListBuilder implements ListHandler {

        /**
         * the list to be build
         */
        protected List list;

        /// Default constructor.
        public ListBuilder(){
        }

        /**
         * Return the newly created list.
         * 
         * @return the created list
         */
        public List getList(){
            return list;
        }

        public void startList(){
            if ( list == null ){
                list = new ArrayList();
            }
        }

        public void item(SVGItem item){
            item.setParent(AbstractSVGList.this);
            list.add(item);
        }
        
        public void endList(){
        }
    }
}
