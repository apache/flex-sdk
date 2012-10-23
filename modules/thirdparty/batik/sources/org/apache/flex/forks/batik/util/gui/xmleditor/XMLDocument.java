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
package org.apache.flex.forks.batik.util.gui.xmleditor;

import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.Element;
import javax.swing.text.PlainDocument;

/**
 * A document that can be marked up using XML style.
 *
 * @author <a href="mailto:tonny@kiyut.com">Tonny Kohar</a>
 * @version $Id$
 */
public class XMLDocument extends PlainDocument {

    protected XMLScanner lexer;
    protected XMLContext context;
    
    protected XMLToken cacheToken = null;
    
    public XMLDocument() {
        this(new XMLContext());
    }

    /** Creates a new instance of XMLDocument 
     * @param context XMLContext
     */
    public XMLDocument(XMLContext context) {
        //super(context);
        this.context = context;
        lexer = new XMLScanner();
    }
    
    /** Return XMLToken
     * @param pos position
     * @return XMLToken
     */
    public XMLToken getScannerStart(int pos) throws BadLocationException {
        int ctx = XMLScanner.CHARACTER_DATA_CONTEXT;
        int offset = 0;
        int tokenOffset = 0;
        
        if (cacheToken != null) {
            if (cacheToken.getStartOffset() > pos) {
                cacheToken = null;
            } else {
                ctx = cacheToken.getContext();
                offset = cacheToken.getStartOffset();
                tokenOffset = offset;
                
                Element element = getDefaultRootElement();
                int line1 = element.getElementIndex(pos);
                int line2 = element.getElementIndex(offset);
                
                //if (pos - offset <= 1800 ) {
                if (line1 - line2 < 50) {
                    return cacheToken;
                }
            }
        }
        
        String str = getText(offset, pos - offset);
        lexer.setString(str);
        lexer.reset();
        
        // read until pos
        int lastCtx = ctx;
        int lastOffset = offset;
        while (offset < pos) {
            lastOffset = offset;
            lastCtx = ctx;
            
            offset = lexer.scan(ctx) + tokenOffset;
            ctx = lexer.getScanValue();
        }
        cacheToken = new XMLToken(lastCtx, lastOffset, offset);
        return cacheToken;
    }
    
    /** {@inheritDoc} */
    public void insertString(int offset, String str, AttributeSet a)
            throws BadLocationException {

        super.insertString(offset, str, a);
        
        if (cacheToken != null) {
            if (cacheToken.getStartOffset() >= offset) {
                cacheToken = null;
            }
        }
        
    }
    
    /** {@inheritDoc} */
    public void remove(int offs, int len) throws BadLocationException {
        super.remove(offs, len);
        
        if (cacheToken != null) {
            if (cacheToken.getStartOffset() >= offs) {
                cacheToken = null;
            }
        }
    }
    
    /**
     * Find the first occurrence of the specified String starting at the specified index.
     * @param str String to find
     * @param fromIndex
     * @param caseSensitive true or false
     * @return the offset if the string argument occurs as a substring, otherwise return -1
     * @throws BadLocationException if fromIndex was not a valid part of the document
     */
    public int find(String str, int fromIndex, boolean caseSensitive)
            throws BadLocationException {

        int offset = -1;
        int startOffset = -1;
        int len = 0;
        int charIndex = 0;
        
        Element rootElement = getDefaultRootElement();
        
        int elementIndex = rootElement.getElementIndex(fromIndex);
        if (elementIndex < 0) { return offset; }
        
        // set the initial charIndex
        charIndex = fromIndex -
            rootElement.getElement(elementIndex).getStartOffset();
        
        for (int i = elementIndex; i < rootElement.getElementCount(); i++) {
            Element element = rootElement.getElement(i);
            startOffset = element.getStartOffset();
            if (element.getEndOffset() > getLength()) {
               len = getLength() - startOffset;
            } else {
                len = element.getEndOffset() - startOffset;
            }
            
            String text = getText(startOffset, len);
            
            if (!caseSensitive) {
                text = text.toLowerCase();
                str = str.toLowerCase();
            }
            
            charIndex = text.indexOf(str, charIndex);
            if (charIndex != -1) {
                offset = startOffset + charIndex;
                break;
            }
            charIndex = 0;  // reset the charIndex
        }
        
        return offset;
    }
}
