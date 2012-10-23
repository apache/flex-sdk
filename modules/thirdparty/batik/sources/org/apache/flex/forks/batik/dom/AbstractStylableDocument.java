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

package org.apache.flex.forks.batik.dom;

import org.apache.flex.forks.batik.css.engine.CSSEngine;

import org.w3c.dom.css.DocumentCSS;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.DocumentType;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Element;
import org.w3c.dom.stylesheets.StyleSheetList;
import org.w3c.dom.views.DocumentView;
import org.w3c.dom.views.AbstractView;

/**
 * A Document that supports CSS styling.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: AbstractStylableDocument.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public abstract class AbstractStylableDocument extends AbstractDocument
    implements DocumentCSS,
               DocumentView {

    /**
     * The default view.
     */
    protected transient AbstractView defaultView;

    /**
     * The CSS engine.
     */
    protected transient CSSEngine cssEngine;


    protected AbstractStylableDocument() {
    }

    /**
     * Creates a new document.
     */
    protected AbstractStylableDocument(DocumentType dt,
                                       DOMImplementation impl) {
        super(dt, impl);
    }

    /**
     * Sets the CSS engine.
     */
    public void setCSSEngine(CSSEngine ctx) {
        cssEngine = ctx;
    }

    /**
     * Returns the CSS engine.
     */
    public CSSEngine getCSSEngine() {
        return cssEngine;
    }

    // DocumentStyle /////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.stylesheets.DocumentStyle#getStyleSheets()}.
     */
    public StyleSheetList getStyleSheets() {
        throw new RuntimeException(" !!! Not implemented");
    }

    // DocumentView ///////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link DocumentView#getDefaultView()}.
     * @return a ViewCSS object.
     */
    public AbstractView getDefaultView() {
        if (defaultView == null) {
            ExtensibleDOMImplementation impl;
            impl = (ExtensibleDOMImplementation)implementation;
            defaultView = impl.createViewCSS(this);
        }
        return defaultView;
    }

    /**
     * Clears the view CSS.
     */
    public void clearViewCSS() {
        defaultView = null;
        if (cssEngine != null) {
            cssEngine.dispose();
        }
        cssEngine = null;
    }

    // DocumentCSS ////////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements
     * {@link DocumentCSS#getOverrideStyle(Element,String)}.
     */
    public CSSStyleDeclaration getOverrideStyle(Element elt,
                                                String pseudoElt) {
        throw new RuntimeException(" !!! Not implemented");
    }
}
