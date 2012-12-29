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

import java.io.IOException;

import org.w3c.css.sac.CSSException;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.css.sac.SACMediaList;
import org.w3c.css.sac.SelectorList;

/**
 * This class implements the {@link org.w3c.css.sac.Parser} interface plus a
 * set of custom methods.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtendedParser.java 475685 2006-11-16 11:16:05Z cam $
 */
public interface ExtendedParser extends org.w3c.css.sac.Parser {
    
    /**
     * Parse a CSS style declaration (without '{' and '}').
     *
     * @param source The declaration.
     * @exception CSSException Any CSS exception, possibly
     *            wrapping another exception.
     * @exception java.io.IOException An IO exception from the parser,
     *            possibly from a byte stream or character stream
     *            supplied by the application.
     */
    void parseStyleDeclaration(String source) 
        throws CSSException, IOException;


    /**
     * Parse a CSS rule.
     *
     * @exception CSSException Any CSS exception, possibly
     *            wrapping another exception.
     * @exception java.io.IOException An IO exception from the parser,
     *            possibly from a byte stream or character stream
     *            supplied by the application.
     */
    void parseRule(String source) throws CSSException, IOException;
    
    /**
     * Parse a comma separated list of selectors.
     * 
     * 
     * @exception CSSException Any CSS exception, possibly
     *            wrapping another exception.
     * @exception java.io.IOException An IO exception from the parser,
     *            possibly from a byte stream or character stream
     *            supplied by the application.
     */    
    SelectorList parseSelectors(String source)
        throws CSSException, IOException;


    /**
     * Parse a CSS property value.
     * 
     * 
     * @exception CSSException Any CSS exception, possibly
     *            wrapping another exception.
     * @exception java.io.IOException An IO exception from the parser,
     *            possibly from a byte stream or character stream
     *            supplied by the application.
     */    
    LexicalUnit parsePropertyValue(String source)
        throws CSSException, IOException;

    
    /**
     * Parse a CSS media value.
     * 
     * 
     * @exception CSSException Any CSS exception, possibly
     *            wrapping another exception.
     * @exception java.io.IOException An IO exception from the parser,
     *            possibly from a byte stream or character stream
     *            supplied by the application.
     */    
    SACMediaList parseMedia(String mediaText)
        throws CSSException, IOException;

    /**
     * Parse a CSS priority value (e&#x2e;g&#x2e; "&#x21;important").
     * 
     * 
     * @exception CSSException Any CSS exception, possibly
     *            wrapping another exception.
     * @exception java.io.IOException An IO exception from the parser,
     *            possibly from a byte stream or character stream
     *            supplied by the application.
     */    
    boolean parsePriority(String source)
        throws CSSException, IOException;

}
