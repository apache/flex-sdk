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

import java.awt.Color;
import java.awt.Font;

import javax.swing.JEditorPane;
import javax.swing.event.UndoableEditEvent;
import javax.swing.event.UndoableEditListener;
import javax.swing.text.Element;
import javax.swing.undo.CannotRedoException;
import javax.swing.undo.CannotUndoException;
import javax.swing.undo.UndoManager;

/**
 * Simple Text Component to edit xml document with integrated undo / redo behaviour.
 * If you looking for how to create editor component with syntax highlight,
 * just create any JEditorPane and supply it with XMLEditoKit eg:
 * <pre>
 * JEditorPane editor = new JEditorPane();
 * editor.setEditorKitForContentType(XMLEditorKit.XML_MIME_TYPE, new XMLEditorKit();
 * editor.setContentType(XMLEditorKit.XML_MIME_TYPE);
 * </pre>
 *
 * @author <a href="mailto:tonny@kiyut.com">Tonny Kohar</a>
 * @version $Id$
 */
public class XMLTextEditor extends JEditorPane {

    protected UndoManager undoManager;
    
    /** Creates a new instance of XMLEditorPane */
    public XMLTextEditor() {
        super();
        XMLEditorKit kit = new XMLEditorKit();
        setEditorKitForContentType(XMLEditorKit.XML_MIME_TYPE, kit);
        setContentType(XMLEditorKit.XML_MIME_TYPE);
        setBackground(Color.white);
        //setFont(new Font("Monospaced", Font.PLAIN, 12));
                
        // add undoable edit
        undoManager = new UndoManager();
        UndoableEditListener undoableEditHandler = new UndoableEditListener() {
            public void undoableEditHappened(UndoableEditEvent e) {
                undoManager.addEdit(e.getEdit());
            }
        };
        getDocument().addUndoableEditListener(undoableEditHandler);
    }
    
    
    /** {@inheritDoc} */
    public void setText(String t) {
        super.setText(t);
        
        undoManager.discardAllEdits();
    }
    
    /** Undo */
    public void undo() {
        try {
            undoManager.undo();
        } catch (CannotUndoException ex) { }
    }
    
    /** Redo */
    public void redo() {
        try {
            undoManager.redo();
        } catch (CannotRedoException ex) { }
    }
    
    
    /** Move the cursor to the specified line
     * if exception occur cursor not change
     * @param line the specified line number
     */
    public void gotoLine(int line) {
        Element element =
            getDocument().getDefaultRootElement().getElement(line);
        if (element == null) { return; }
        int pos = element.getStartOffset();
        setCaretPosition(pos);
    }
}
