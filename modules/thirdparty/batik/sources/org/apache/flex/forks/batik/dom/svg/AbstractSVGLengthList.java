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

import org.apache.flex.forks.batik.parser.LengthListHandler;
import org.apache.flex.forks.batik.parser.LengthListParser;
import org.apache.flex.forks.batik.parser.ParseException;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGLength;
import org.w3c.flex.forks.dom.svg.SVGLengthList;


/**
 * This class is the implementation of
 * <code>SVGLengthList</code>.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: AbstractSVGLengthList.java,v 1.6 2004/08/18 07:13:13 vhardy Exp $
 */
public abstract class AbstractSVGLengthList
    extends AbstractSVGList
    implements SVGLengthList {


    /**
     * This length list's direction.
     */
    protected short direction;

    /**
     * Separator for a length list.
     */
    public final static String SVG_LENGTH_LIST_SEPARATOR
        =" ";

    /**
     * Return the separator between values in the list.
     */
    protected String getItemSeparator(){
        return SVG_LENGTH_LIST_SEPARATOR;
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
     * return the element owning this SVGLengthList.
     */
    protected abstract Element getElement();

    /**
     * Creates a new SVGLengthList.
     */
    protected AbstractSVGLengthList(short direction) {
        super();
        this.direction = direction;
    }

    /**
     */
    public SVGLength initialize ( SVGLength newItem )
        throws DOMException, SVGException {

        return (SVGLength)initializeImpl(newItem);
    }

    /**
     */
    public SVGLength getItem ( int index )
        throws DOMException {

        return (SVGLength)getItemImpl(index);
    }

    /**
     */
    public SVGLength insertItemBefore ( SVGLength newItem, int index )
        throws DOMException, SVGException {

        return (SVGLength)insertItemBeforeImpl(newItem,index);
    }

    /**
     */
    public SVGLength replaceItem ( SVGLength newItem, int index )
        throws DOMException, SVGException {

        return (SVGLength)replaceItemImpl(newItem,index);
    }

    /**
     */
    public SVGLength removeItem ( int index )
        throws DOMException {

        return (SVGLength)removeItemImpl(index);
    }

    /**
     */
    public SVGLength appendItem ( SVGLength newItem )
        throws DOMException, SVGException {

        return (SVGLength) appendItemImpl(newItem);
    }

    /**
     */
    protected SVGItem createSVGItem(Object newItem){
        
        SVGLength l = (SVGLength)newItem;

        return new SVGLengthItem(l.getUnitType(), l.getValueInSpecifiedUnits(),direction);
    }
    
    /**
     * Parse the attribute associated with this SVGLengthList.
     *
     * @param value attribute value
     * @param handler list handler
     */
    protected void doParse(String value, ListHandler handler)
        throws ParseException{

        LengthListParser lengthListParser = new LengthListParser();
        
        LengthListBuilder builder = new LengthListBuilder(handler);
        
        lengthListParser.setLengthListHandler(builder);
        lengthListParser.parse(value);
        
    }

    /**
     * Check if the item is an SVGLength.
     */
    protected void checkItemType(Object newItem)
        throws SVGException {
        if ( !( newItem instanceof SVGLength ) ){
            createSVGException(SVGException.SVG_WRONG_TYPE_ERR,
                               "expected SVGLength",
                               null);
        }
    }

    /**
     * Representation of the item SVGLength.
     */
    protected class SVGLengthItem 
        extends AbstractSVGLength 
        implements SVGItem {

        /**
         * Default Constructor.
         */
        public SVGLengthItem(short type, float value,short direction){
            super(direction);
            this.unitType = type;
            this.value = value;
        }

        /**
         */
        protected SVGOMElement getAssociatedElement(){
            return (SVGOMElement)AbstractSVGLengthList.this.getElement();
        }

        /**
         * SVGLengthList this item belongs to.
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
     * Helper class to interface the <code>LengthListParser</code>
     * and the <code>ListHandler</code>
     */
    protected class LengthListBuilder
        implements LengthListHandler {

        /**
         * list handler.
         */
        protected ListHandler listHandler;

        //current value being parsed
        protected float currentValue;
        //current type being parsed
        protected short currentType;
        
        /**
         */
        public LengthListBuilder(ListHandler listHandler){
            this.listHandler = listHandler;
        }

        /**
         */
        public void startLengthList() 
            throws ParseException{

            listHandler.startList();
        }
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#startLength()}.
         */
        public void startLength() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_NUMBER;
            currentValue = 0.0f;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#lengthValue(float)}.
         */
        public void lengthValue(float v) throws ParseException {
            currentValue = v;
        }
        
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#em()}.
         */
        public void em() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_EMS;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#ex()}.
         */
        public void ex() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_EXS;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#in()}.
         */
        public void in() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_IN;
        }
        
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#cm()}.
         */
        public void cm() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_CM;
        }
        
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#mm()}.
         */
        public void mm() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_MM;
        }
        
        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#pc()}.
         */
        public void pc() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_PC;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#pt()}.
         */
        public void pt() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_EMS;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#px()}.
         */
        public void px() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_PX;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#percentage()}.
         */
        public void percentage() throws ParseException {
            currentType = SVGLength.SVG_LENGTHTYPE_PERCENTAGE;
        }

        /**
         * Implements {@link org.apache.flex.forks.batik.parser.LengthHandler#endLength()}.
         */
        public void endLength() throws ParseException {
            listHandler.item(new SVGLengthItem(currentType,currentValue,direction));
        }
        
        /**
         */
        public void endLengthList() 
            throws ParseException {
            listHandler.endList();
        }
    }
   
}
