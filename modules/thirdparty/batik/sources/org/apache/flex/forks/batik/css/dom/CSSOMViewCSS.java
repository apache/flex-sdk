/*

   Copyright 1999-2003  The Apache Software Foundation 

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
import org.w3c.dom.css.ViewCSS;
import org.w3c.dom.views.DocumentView;

/**
 * This class represents an object which provides the computed styles
 * of the elements of a document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSOMViewCSS.java,v 1.4 2004/10/30 18:38:04 deweese Exp $
 */
public class CSSOMViewCSS implements ViewCSS {
    
    /**
     * The associated CSS engine.
     */
    protected CSSEngine cssEngine;

    /**
     * Creates a new ViewCSS.
     */
    public CSSOMViewCSS(CSSEngine engine) {
        cssEngine = engine;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.views.AbstractView#getDocument()}.
     */
    public DocumentView getDocument() {
        return (DocumentView)cssEngine.getDocument();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.ViewCSS#getComputedStyle(Element,String)}.
     */
    public CSSStyleDeclaration getComputedStyle(Element elt,
                                                String pseudoElt) {
        if (elt instanceof CSSStylableElement) {
            return new CSSOMComputedStyle(cssEngine,
                                          (CSSStylableElement)elt,
                                          pseudoElt);
        }
        return null;
    }
 
}
