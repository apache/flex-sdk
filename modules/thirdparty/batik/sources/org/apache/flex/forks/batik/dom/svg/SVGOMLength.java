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

/**
 * Default implementation of SVGLength.
 *
 * This implementation is not linked to any
 * attribute in the Document. It is used
 * by the root element to return a default SVGLength.
 *
 * @see org.w3c.dom.svg.SVGSVGElement#createSVGLength()
 *
 * @author nicolas.socheleau@bitflash.com
 * @version $Id: SVGOMLength.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGOMLength extends AbstractSVGLength {

    /**
     * Element associated to this length.
     */
    protected AbstractElement element;

    /**
     * Default constructor.
     *
     * The direction of this length is undefined
     * and this length is not associated to any
     * attribute.
     */
    public SVGOMLength(AbstractElement elt){
        super(OTHER_LENGTH);
        element = elt;
    }

    /**
     */
    protected SVGOMElement getAssociatedElement(){
        return (SVGOMElement)element;
    }
}
