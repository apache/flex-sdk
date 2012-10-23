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

package org.apache.flex.forks.batik.swing.gvt;

import java.awt.Color;
import java.awt.Cursor;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.BasicStroke;
import java.awt.geom.AffineTransform;

import org.apache.flex.forks.batik.gvt.Selectable;
import org.apache.flex.forks.batik.gvt.event.EventDispatcher;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseEvent;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseListener;
import org.apache.flex.forks.batik.gvt.event.SelectionEvent;
import org.apache.flex.forks.batik.gvt.event.SelectionListener;
import org.apache.flex.forks.batik.gvt.text.ConcreteTextSelector;
import org.apache.flex.forks.batik.gvt.text.Mark;

/**
 * This class represents an object which manage GVT text nodes selection.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: TextSelectionManager.java 533275 2007-04-28 01:30:54Z deweese $
 */
public class TextSelectionManager {

    /**
     * The cursor indicating that a text selection operation is under way.
     */
    public static final Cursor TEXT_CURSOR = new Cursor(Cursor.TEXT_CURSOR);

    /**
     * The text selector.
     */
    protected ConcreteTextSelector textSelector;

    /**
     * The associated JGVTComponent.
     */
    protected AbstractJGVTComponent component;

    /**
     * The selection overlay.
     */
    protected Overlay selectionOverlay = new SelectionOverlay();

    /**
     * The mouse listener.
     */
    protected MouseListener mouseListener;

    /**
     * To store the previous cursor.
     */
    protected Cursor previousCursor;

    /**
     * The selection highlight.
     */
    protected Shape selectionHighlight;

    /**
     * The text selection listener.
     */
    protected SelectionListener textSelectionListener;

    /**
     * The color of the selection overlay.
     */
    protected Color selectionOverlayColor = new Color(100, 100, 255, 100);

    /**
     * The color of the outline of the selection overlay.
     */
    protected Color selectionOverlayStrokeColor = Color.white;

    /**
     * A flag bit that indicates whether or not the selection overlay is
     * painted in XOR mode.
     */
    protected boolean xorMode = false;

    /**
     * The current selection or null if there is none.
     */
    Object selection = null;

    /**
     * Creates a new TextSelectionManager.
     */
    public TextSelectionManager(AbstractJGVTComponent comp,
                                EventDispatcher ed) {
        textSelector = new ConcreteTextSelector();
        textSelectionListener = new TextSelectionListener();
        textSelector.addSelectionListener(textSelectionListener);
        mouseListener = new MouseListener();

        component = comp;
        component.getOverlays().add(selectionOverlay);

        ed.addGraphicsNodeMouseListener(mouseListener);
    }

    /**
     * Add a selection listener to be notified when the
     * text selection changes in the document.
     */
    public void addSelectionListener(SelectionListener sl) {
        textSelector.addSelectionListener(sl);
    }

    /**
     * Remove a selection listener to be notified when the
     * text selection changes in the document.
     */
    public void removeSelectionListener(SelectionListener sl) {
        textSelector.removeSelectionListener(sl);
    }

    /**
     * Sets the color of the selection overlay to the specified color.
     *
     * @param color the new color of the selection overlay
     */
    public void setSelectionOverlayColor(Color color) {
        selectionOverlayColor = color;
    }

    /**
     * Returns the color of the selection overlay.
     */
    public Color getSelectionOverlayColor() {
        return selectionOverlayColor;
    }

    /**
     * Sets the color of the outline of the selection overlay to the specified
     * color.
     *
     * @param color the new color of the outline of the selection overlay
     */
    public void setSelectionOverlayStrokeColor(Color color) {
        selectionOverlayStrokeColor = color;
    }

    /**
     * Returns the color of the outline of the selection overlay.
     */
    public Color getSelectionOverlayStrokeColor() {
        return selectionOverlayStrokeColor;
    }

    /**
     * Sets whether or not the selection overlay will be painted in XOR mode,
     * depending on the specified parameter.
     *
     * @param state true implies the selection overlay will be in XOR mode
     */
    public void setSelectionOverlayXORMode(boolean state) {
        xorMode = state;
    }

    /**
     * Returns true if the selection overlay is painted in XOR mode, false
     * otherwise.
     */
    public boolean isSelectionOverlayXORMode() {
        return xorMode;
    }

    /**
     * Returns the selection overlay.
     */
    public Overlay getSelectionOverlay() {
        return selectionOverlay;
    }

    /**
     * Returns the current text selection or null if there is none.
     */
    public Object getSelection() {
        return selection;
    }

    /**
     * Sets the selected text
     */
    public void setSelection(Mark start, Mark end) {
        textSelector.setSelection(start, end);
    }

    /**
     * Clears the selection.
     */
    public void clearSelection() {
        textSelector.clearSelection();
    }

    /**
     * To implement a GraphicsNodeMouseListener.
     */
    protected class MouseListener implements GraphicsNodeMouseListener {
        public void mouseClicked(GraphicsNodeMouseEvent evt) {
            if (evt.getSource() instanceof Selectable) {
                textSelector.mouseClicked(evt);
            }
        }

        public void mousePressed(GraphicsNodeMouseEvent evt) {
            if (evt.getSource() instanceof Selectable) {
                textSelector.mousePressed(evt);
            } else if (selectionHighlight != null) {
                textSelector.clearSelection();
            }
        }

        public void mouseReleased(GraphicsNodeMouseEvent evt) {
            textSelector.mouseReleased(evt);
        }

        public void mouseEntered(GraphicsNodeMouseEvent evt) {
            if (evt.getSource() instanceof Selectable) {
                textSelector.mouseEntered(evt);
                previousCursor = component.getCursor();
                if (previousCursor.getType() == Cursor.DEFAULT_CURSOR) {
                    component.setCursor(TEXT_CURSOR);
                }
            }
        }

        public void mouseExited(GraphicsNodeMouseEvent evt) {
            if (evt.getSource() instanceof Selectable) {
                textSelector.mouseExited(evt);
                if (component.getCursor() == TEXT_CURSOR) {
                    component.setCursor(previousCursor);
                }
            }
        }

        public void mouseDragged(GraphicsNodeMouseEvent evt) {
            if (evt.getSource() instanceof Selectable) {
                textSelector.mouseDragged(evt);
            }
        }

        public void mouseMoved(GraphicsNodeMouseEvent evt) { }
    }

    /**
     * To implements a selection listener.
     */
    protected class TextSelectionListener implements SelectionListener {
        public void selectionDone(SelectionEvent e) {
            selectionChanged(e);
            selection = e.getSelection();
        }
        public void selectionCleared(SelectionEvent e) {
            selectionStarted(e);
        }
        public void selectionStarted(SelectionEvent e) {
            if (selectionHighlight != null) {
                Rectangle r = getHighlightBounds();
                selectionHighlight = null;
                component.repaint(r);
            }
            selection = null;
        }
        public void selectionChanged(SelectionEvent e) {
            Rectangle r = null;
            AffineTransform at = component.getRenderingTransform();
            if (selectionHighlight != null) {
                r = at.createTransformedShape(selectionHighlight).getBounds();
                outset(r, 1);
            }

            selectionHighlight = e.getHighlightShape();
            if (selectionHighlight != null) {
                if (r != null) {
                    Rectangle r2 = getHighlightBounds();
                    r2.add( r );   // r2 = r2 union r
                    component.repaint( r2 );
                } else {
                    component.repaint(getHighlightBounds());
                }
            } else if (r != null) {
                component.repaint(r);
            }
        }

    }

    protected Rectangle outset(Rectangle r, int amount) {
        r.x -= amount;
        r.y -= amount;
        r.width  += 2*amount;
        r.height += 2*amount;
        return r;
    }

    /**
     * The highlight bounds.
     */
    protected Rectangle getHighlightBounds() {
        AffineTransform at = component.getRenderingTransform();
        Shape s = at.createTransformedShape(selectionHighlight);
        return outset(s.getBounds(), 1);
    }

    /**
     * The selection overlay.
     */
    protected class SelectionOverlay implements Overlay {

        /**
         * Paints this overlay.
         */
        public void paint(Graphics g) {
            if (selectionHighlight != null) {
                AffineTransform at = component.getRenderingTransform();
                Shape s = at.createTransformedShape(selectionHighlight);

                Graphics2D g2d = (Graphics2D)g;
                if (xorMode) {
                    g2d.setColor(Color.black);
                    g2d.setXORMode(Color.white);
                    g2d.fill(s);
                } else {
                    g2d.setColor(selectionOverlayColor);
                    g2d.fill(s);
                    if (selectionOverlayStrokeColor != null) {
                        g2d.setStroke(new BasicStroke(1.0f));
                        g2d.setColor(selectionOverlayStrokeColor);
                        g2d.draw(s);
                    }
                }
            }
        }
    }
}
