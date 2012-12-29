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

import java.awt.Graphics;

import javax.swing.text.BadLocationException;
import javax.swing.text.Element;
import javax.swing.text.PlainView;
import javax.swing.text.Segment;
import javax.swing.text.Utilities;

/**
 * View that uses the lexical information to determine the
 * style characteristics of the text that it renders.  This
 * simply colorizes the various tokens and assumes a constant
 * font family and size.
 *
 * @author <a href="mailto:tonny@kiyut.com">Tonny Kohar</a>
 * @version $Id$
 */
public class XMLView extends PlainView {

    protected XMLContext context = null;
    protected XMLScanner lexer = new XMLScanner();
    protected int tabSize = 4;
    
    /**
     * Construct a simple colorized view of XML
     * text.
     */
    public XMLView(XMLContext context, Element elem) {
        super(elem);
        this.context = context;
    }
    
    /** {@inheritDoc} */
    public int getTabSize() {
        return tabSize;
    }
    
    /** {@inheritDoc} */
    protected int drawUnselectedText(Graphics g, int x, int y, int p0, int p1)
            throws BadLocationException {

        XMLDocument doc = (XMLDocument)getDocument();
        XMLToken token = doc.getScannerStart(p0);
        
        String str = doc.getText(token.getStartOffset(),
                                 (p1-token.getStartOffset()) + 1);
        
        lexer.setString(str);
        lexer.reset();
        
        // read until p0
        int pos = token.getStartOffset();
        int ctx = token.getContext();
        int lastCtx = ctx;
        while (pos < p0) {
            pos = lexer.scan(ctx) + token.getStartOffset();
            lastCtx = ctx;
            ctx = lexer.getScanValue();
        }
        int mark = p0;
        
        while (pos < p1) {
            if (lastCtx != ctx) {
                //syntax = context.getSyntaxName(lastCtx);
                g.setColor(context.getSyntaxForeground(lastCtx));
                g.setFont(context.getSyntaxFont(lastCtx));
                Segment text = getLineBuffer();
                doc.getText(mark, pos - mark, text);
                x = Utilities.drawTabbedText(text, x, y, g, this, mark);
                mark = pos;
            }
            
            pos = lexer.scan(ctx) + token.getStartOffset();
            lastCtx = ctx;
            ctx = lexer.getScanValue();
            
        }
        
        // flush remaining
        //syntax = context.getSyntaxName(lastCtx);
        g.setColor(context.getSyntaxForeground(lastCtx));
        g.setFont(context.getSyntaxFont(lastCtx));
        Segment text = getLineBuffer();
        doc.getText(mark, p1 - mark, text);
        x = Utilities.drawTabbedText(text, x, y, g, this, mark);
        
        return x;
    }

//     XXX Reinstate this when Java 1.4 is required:
//
//     http://mail-archives.apache.org/mod_mbox/xmlgraphics-batik-dev/200711.mbox/%3cf75892d60711301037j5abc6760h37ee4491037f1b4a@mail.gmail.com%3e
//
//     /** Overriden to handle multi line node
//      * {@inheritDoc}
//      */
//     protected void updateDamage(javax.swing.event.DocumentEvent changes,
//                                 Shape a,
//                                 ViewFactory f) {
//         super.updateDamage(changes, a, f);
//         java.awt.Component host = getContainer();
//         host.repaint();
//     }
}
