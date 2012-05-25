/*

   Copyright 2004  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedPreserveAspectRatio;
import org.w3c.flex.forks.dom.svg.SVGPreserveAspectRatio;
import org.w3c.flex.forks.dom.svg.SVGException;

/**
 * This class implements the {@link SVGAnimatedPreserveAspectRatio} interface.
 *
 * @author  Tonny Kohar
 * @version $Id: SVGOMAnimatedPreserveAspectRatio.java,v 1.3 2005/03/27 08:58:32 cam Exp $
 */
public class SVGOMAnimatedPreserveAspectRatio 
    implements SVGAnimatedPreserveAspectRatio, LiveAttributeValue {
    /**
     * The associated element.
     */
    protected AbstractElement element;
    
    /**
     * Whether the value is changing.
     */
    protected boolean changing = false;
    
    /**
     * SVGPreserveAspectRatio mapping the static 'preserveAspectRatio'
     * attribute.
     */
    protected AbstractSVGPreserveAspectRatio preserveAspectRatio;
    
    
    /** Creates a new instance of SVGOMAnimatePreserveAspectRatio */
    public SVGOMAnimatedPreserveAspectRatio(AbstractElement elt)  {
        element = elt;
        preserveAspectRatio = new SVGOMPreserveAspectRatio();
        String attrValue = elt.getAttributeNS
            (null,SVGConstants.SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE);
        if (attrValue != null) {
            preserveAspectRatio.setValueAsString(attrValue);
        }
    }
    
    public void attrAdded(Attr node, String newv) {
        if (!changing) {
            preserveAspectRatio.setValueAsString(newv);
            // System.out.println("attr added: " + newv);
        }
    }
    
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing) {
            preserveAspectRatio.setValueAsString(newv);
        }
    }
    
    public void attrRemoved(Attr node, String oldv) {
        if (!changing) {
            preserveAspectRatio.reset();
        }
    }
    
    public SVGPreserveAspectRatio getAnimVal() {
        throw new RuntimeException("!!! TODO: getAnimVal()");
        
    }
    
    public SVGPreserveAspectRatio getBaseVal() {
        return preserveAspectRatio;
    }
    
    /** The implementation of SVGPreserveAspectRatio
     */
    public class SVGOMPreserveAspectRatio 
        extends AbstractSVGPreserveAspectRatio {
        
        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short    type,
                                                  String   key,
                                                  Object[] args){
            return element.createDOMException(type,key,args);
        }
        
        protected void setAttributeValue(String value) throws DOMException {
            try {
                changing = true;
                element.setAttributeNS
                    (null,SVGConstants.SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                     value);
            } finally {
                changing = false;
            }
        }
    }
}
