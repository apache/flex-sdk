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

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedPathData;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGPathSegList;

/**
 * This class is the implementation of
 * the SVGAnimatedPathData interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: SVGOMAnimatedPathData.java,v 1.4 2004/08/18 07:13:14 vhardy Exp $
 */
public class SVGOMAnimatedPathData 
    implements SVGAnimatedPathData,
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
     * SVGPathSegList mapping the static 'd' attribute.
     */
    protected AbstractSVGPathSegList pathSegs;

    /**
     * Default value for the 'd' attribute.
     */
    protected String defaultValue;

    /**
     */
    public SVGOMAnimatedPathData(AbstractElement elt,
                                 String ns,
                                 String ln,
                                 String defaultValue){

        element = elt;
        namespaceURI = ns;
        localName = ln;
        this.defaultValue = defaultValue;
    }

    /**
     */
    public SVGPathSegList getAnimatedNormalizedPathSegList(){
        throw new RuntimeException("TODO :  getAnimatedNormalizedPathSegList() !!");
    }
          
    
    /**
     */
    public SVGPathSegList getAnimatedPathSegList(){
        throw new RuntimeException("TODO :  getAnimatedPathSegList() !!");
    }

    /**
     */
    public SVGPathSegList getNormalizedPathSegList(){
        throw new RuntimeException("TODO :  getNormalizedPathSegList() !!");
    }
          

    /**
     * return the SVGPathSegList mapping
     * the static 'd' attribute
     * of the element
     *
     * @return a path seg list.
     */
    public SVGPathSegList getPathSegList(){
        if ( pathSegs == null ){
            pathSegs = new SVGOMPathSegList();
        }
         return pathSegs;
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing && pathSegs != null) {
            pathSegs.invalidate();
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing && pathSegs != null) {
            pathSegs.invalidate();
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!changing && pathSegs != null) {
            pathSegs.invalidate();
        }
    }
    
    /**
     * SVGPointList implementation for the
     * static 'points' attribute of the element.
     */
    public class SVGOMPathSegList extends AbstractSVGPathSegList {

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
