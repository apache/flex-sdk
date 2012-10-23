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
package org.apache.flex.forks.batik.css.parser;

import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.DocumentHandler;
import org.w3c.css.sac.InputSource;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.css.sac.SACMediaList;
import org.w3c.css.sac.SelectorList;

/**
 * This class provides a default implementation of the SAC DocumentHandler.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultDocumentHandler.java 478283 2006-11-22 18:53:40Z dvholten $
 */
public class DefaultDocumentHandler implements DocumentHandler {
    /**
     * The instance of this class.
     */
    public static final DocumentHandler INSTANCE = new DefaultDocumentHandler();

    /**
     * Creates a new DefaultDocumentHandler.
     */
    protected DefaultDocumentHandler() {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#startDocument(InputSource)}.
     */
    public void startDocument(InputSource source)
        throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#endDocument(InputSource)}.
     */
    public void endDocument(InputSource source) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#comment(String)}.
     */
    public void comment(String text) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#ignorableAtRule(String)}.
     */
    public void ignorableAtRule(String atRule) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#namespaceDeclaration(String,String)}.
     */
    public void namespaceDeclaration(String prefix, String uri)
        throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * DocumentHandler#importStyle(String,SACMediaList,String)}.
     */
    public void importStyle(String       uri,
                            SACMediaList media,
                            String       defaultNamespaceURI)
        throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#startMedia(SACMediaList)}.
     */
    public void startMedia(SACMediaList media) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#endMedia(SACMediaList)}.
     */
    public void endMedia(SACMediaList media) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#startPage(String,String)}.
     */
    public void startPage(String name, String pseudo_page)
        throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#endPage(String,String)}.
     */
    public void endPage(String name, String pseudo_page) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#startFontFace()}.
     */
    public void startFontFace() throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#endFontFace()}.
     */
    public void endFontFace() throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#startSelector(SelectorList)}.
     */
    public void startSelector(SelectorList selectors) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#endSelector(SelectorList)}.
     */
    public void endSelector(SelectorList selectors) throws CSSException {
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.DocumentHandler#property(String,LexicalUnit,boolean)}.
     */
    public void property(String name, LexicalUnit value, boolean important)
        throws CSSException {
    }
}
