/*

   Copyright 2003  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.parser.NumberListHandler;
import org.apache.flex.forks.batik.parser.NumberListParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGNumber;
import org.w3c.flex.forks.dom.svg.SVGNumberList;


/**
 * This class is the implementation of
 * <code>SVGNumberList</code>.
 *
 * @author  tonny@kiyut.com
 */
public abstract class AbstractSVGNumberList extends AbstractSVGList implements SVGNumberList {
    
    /**
     * Separator for a length list.
     */
    public final static String SVG_NUMBER_LIST_SEPARATOR
        =" ";

    /**
     * Return the separator between values in the list.
     */
    protected String getItemSeparator(){
        return SVG_NUMBER_LIST_SEPARATOR;
    }
    
    /**
     * Create an SVGException when the checkItemType fails.
     *
     * @return SVGException
     */
    protected abstract SVGException createSVGException(short type,
                                                       String key,
                                                       Object[] args);

    /**
     * return the element owning this SVGNumberList.
     */
    protected abstract Element getElement();
    
    /**
     * Creates a new SVGNumberList.
     */
    protected AbstractSVGNumberList() {
        super();
    }

    /**
     */
    public SVGNumber initialize ( SVGNumber newItem )
        throws DOMException, SVGException {

        return (SVGNumber)initializeImpl(newItem);
    }

    /**
     */
    public SVGNumber getItem ( int index )
        throws DOMException {

        return (SVGNumber)getItemImpl(index);
    }
    
    /**
     */
    public SVGNumber insertItemBefore ( SVGNumber newItem, int index )
        throws DOMException, SVGException {

        return (SVGNumber)insertItemBeforeImpl(newItem,index);
    }

    /**
     */
    public SVGNumber replaceItem ( SVGNumber newItem, int index )
        throws DOMException, SVGException {

        return (SVGNumber)replaceItemImpl(newItem,index);
    }

    /**
     */
    public SVGNumber removeItem ( int index )
        throws DOMException {

        return (SVGNumber)removeItemImpl(index);
    }

    /**
     */
    public SVGNumber appendItem ( SVGNumber newItem )
        throws DOMException, SVGException {

        return (SVGNumber) appendItemImpl(newItem);
    }

    /**
     */
    protected SVGItem createSVGItem(Object newItem){
        
        SVGNumber l = (SVGNumber)newItem;

        return new SVGNumberItem(l.getValue());
    }
    
    /**
     * Parse the attribute associated with this SVGNumberList.
     *
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
     * Check if the item is an SVGNumber
     */
    protected void checkItemType(Object newItem)
        throws SVGException {
        if ( !( newItem instanceof SVGNumber ) ){
            createSVGException(SVGException.SVG_WRONG_TYPE_ERR,
                               "expected SVGNumber",
                               null);
        }
    }
    
    /**
     * Representation of the item SVGNumber.
     */
    protected class SVGNumberItem 
        extends AbstractSVGNumber 
        implements SVGItem {

        /**
         * Default Constructor.
         */
        public SVGNumberItem(float value){
            super();
            this.value = value;
        }
        
        public String getValueAsString(){
            return Float.toString(value);
        }

        /**
         * SVGNumberList this item belongs to.
         */
        protected AbstractSVGList parentList;

        /**
         * Associates an item to an SVGXXXList
         *
         * @param list list the item belongs to.
         */
        public void setParent(AbstractSVGList list){
            parentList = list;
        }

        /**
         * Return the list the item belongs to.
         *
         * @return list the item belongs to. This
         *   could be if the item belongs to no list.
         */
        public AbstractSVGList getParent(){
            return parentList;
        }

        /**
         * When the SVGLength changes, notify
         * its parent.
         */
        protected void reset(){
            if ( parentList != null ){
                parentList.itemChanged();
            }
        }
        
    }
    
    /**
     * Helper class to interface the <code>NumberListParser</code>
     * and the <code>NumberHandler</code>
     */
    protected class NumberListBuilder
        implements NumberListHandler {

        /**
         * list handler.
         */
        protected ListHandler listHandler;

        //current value being parsed
        protected float currentValue;
                
        /**
         */
        public NumberListBuilder(ListHandler listHandler){
            this.listHandler = listHandler;
        }

        /**
         */
        public void startNumberList() 
            throws ParseException{

            listHandler.startList();
        }
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.NumberListHandler#startNumber()}.
         */
        public void startNumber() throws ParseException {
            currentValue = 0.0f;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.NumberListHandler#numberValue(float)}.
         */
        public void numberValue(float v) throws ParseException {
            currentValue = v;
        }
        
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.NumberListHandler#endNumber()}.
         */
        public void endNumber() throws ParseException {
            listHandler.item(new SVGNumberItem(currentValue));
        }
        
        /**
         */
        public void endNumberList() 
            throws ParseException {
            listHandler.endList();
        }
    }
}
