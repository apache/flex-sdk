/*

   Copyright 2000-2001,2003  The Apache Software Foundation 

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

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedTransformList;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGTransformList;

/**
 * This class is the implementation of
 * the SVGAnimatedTransformList interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGOMAnimatedTransformList.java,v 1.10 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMAnimatedTransformList 
    implements SVGAnimatedTransformList,
               LiveAttributeValue {

    /**
     * The associated element.
     */
    protected AbstractElement element;

    /**
     * The attribute's namespace URI.
     */
    protected String namespaceURI;

    /**
     * The attribute's local name.
     */
    protected String localName;

    /**
     * Whether the list is changing.
     */
    protected boolean changing;

    /**
     * SVGTransformList mapping the static 'transform' attribute.
     */
    protected AbstractSVGTransformList transformList;

    /**
     * Default value for the 'transform' attribute.
     */
    protected String defaultValue;

    /**
     */
    public SVGOMAnimatedTransformList(AbstractElement elt,
                                      String ns,
                                      String ln,
                                      String defaultValue){

        element = elt;
        namespaceURI = ns;
        localName = ln;
        this.defaultValue = defaultValue;
    }


    /**
     * return the SVGTransformList mapping
     * the static 'transform' attribute
     * of the element
     *
     * @return a transform list.
     */
    public SVGTransformList getBaseVal(){
        if ( transformList == null ){
            transformList = new SVGOMTransformList();
        }
         return transformList;
    }

    public SVGTransformList getAnimVal(){
        throw new RuntimeException("TODO :  getAnimVal() !!");
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing && transformList != null) {
            transformList.invalidate();
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing && transformList != null) {
            transformList.invalidate();
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!changing && transformList != null) {
            transformList.invalidate();
        }
    }
    
    /**
     * SVGTransformList implementation for the
     * static 'transform' attribute of the element.
     */
    public class SVGOMTransformList extends AbstractSVGTransformList {

        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short    type,
                                                  String   key,
                                                  Object[] args){
            return element.createDOMException(type,key,args);
        }

        /**
         * Create a SVGException.
         */
        protected SVGException createSVGException(short    type,
                                                  String   key,
                                                  Object[] args){

            return ((SVGOMElement)element).createSVGException(type,key,args);
        }

        /**
         * Retrieve the value of the attribute 'points'.
         */
        protected String getValueAsString(){
            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
            if (attr == null) {
                return defaultValue;
            }
            return attr.getValue();
        }

        /**
         * Set the value of the attribute 'points'
         */
        protected void setAttributeValue(String value){
            try{
                changing = true;
                element.setAttributeNS(namespaceURI, localName, value);
            }
            finally{
                changing = false;
            }
        }
    }
}
