/*

   Copyright 2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.dom;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.w3c.dom.Element;
import org.w3c.dom.css.CSSStyleDeclaration;

/**
 * This class represents an object which provides the computed styles
 * of the elements of a SVG document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSOMSVGViewCSS.java,v 1.4 2004/08/18 07:12:47 vhardy Exp $
 */
public class CSSOMSVGViewCSS extends CSSOMViewCSS {
    
    /**
     * Creates a new ViewCSS.
     */
    public CSSOMSVGViewCSS(CSSEngine engine) {
        super(engine);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.ViewCSS#getComputedStyle(Element,String)}.
     */
    public CSSStyleDeclaration getComputedStyle(Element elt,
                                                String pseudoElt) {
        if (elt instanceof CSSStylableElement) {
            return new CSSOMSVGComputedStyle(cssEngine,
                                             (CSSStylableElement)elt,
                                             pseudoElt);
        }
        return null;
    }
}
