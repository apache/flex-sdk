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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.util.ArrayList;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.gvt.Overlay;

import org.w3c.dom.Element;

/**
 * Manages element overlay on the canvas.
 *
 * @version $Id$
 */
public class ElementOverlayManager {

    /**
     * The color of the outline of the element overlay.
     */
    protected Color elementOverlayStrokeColor = Color.black;

    /**
     * The color of the element overlay.
     */
    protected Color elementOverlayColor = Color.white;

    /**
     * The xor mode.
     */
    protected boolean xorMode = true;

    /**
     * The canvas.
     */
    protected JSVGCanvas canvas;

    /**
     * The element overlay.
     */
    protected Overlay elementOverlay = new ElementOverlay();

    /**
     * Elements to paint.
     */
    protected ArrayList elements;

    /**
     * The controller for the element overlay.
     */
    protected ElementOverlayController controller;

    /**
     * Whether the ElementOverlay is enabled.
     */
    protected boolean isOverlayEnabled = true;

    /**
     * Constructor.
     *
     * @param canvas
     *            The parent canvas
     */
    public ElementOverlayManager(JSVGCanvas canvas) {
        this.canvas = canvas;
        elements = new ArrayList();
        canvas.getOverlays().add(elementOverlay);
    }

    /**
     * Adds an element to the element selection.
     *
     * @param elem
     *            The element to add
     */
    public void addElement(Element elem) {
        elements.add(elem);
    }

    /**
     * Removes the element from the element selection and adds its bound to the
     * 'dirty' region.
     *
     * @param elem
     *            The element to remove
     */
    public void removeElement(Element elem) {
        if (elements.remove(elem)) {
//            // Gets the area that should be repainted
//            Rectangle currentElementBounds = getElementBounds(elem);
//            if (dirtyArea == null) {
//                dirtyArea = currentElementBounds;
//            } else if (currentElementBounds != null) {
//                dirtyArea.add(currentElementBounds);
//            }
        }
    }

    /**
     * Removes all elements from the element selection list.
     */
    public void removeElements() {
        elements.clear();
        repaint();
    }

    /**
     * Get the current selection bounds.
     *
     * @return the current selection bounds
     */
    protected Rectangle getAllElementsBounds() {
        Rectangle resultBound = null;
        int n = elements.size();
        for (int i = 0; i < n; i++) {
            Element currentElement = (Element) elements.get(i);
            Rectangle currentBound = getElementBounds(currentElement);
            if (resultBound == null) {
                resultBound = currentBound;
            } else {
                resultBound.add(currentBound);
            }
        }
        return resultBound;
    }

    /**
     * The bounds of a given element.
     *
     * @param elem
     *            The given element
     * @return Rectangle bounds
     */
    protected Rectangle getElementBounds(Element elem) {
        return getElementBounds(canvas.getUpdateManager().getBridgeContext()
                .getGraphicsNode(elem));
    }

    /**
     * The bounds of a given graphics node.
     *
     * @param node
     *            The given graphics node
     * @return the bounds
     */
    protected Rectangle getElementBounds(GraphicsNode node) {
        if (node == null) {
            return null;
        }
        AffineTransform at = canvas.getRenderingTransform();
        Shape s = at.createTransformedShape(node.getOutline());
        return outset(s.getBounds(), 1);
    }

    /**
     * Increases the given rectangle area for a given amount of units in a
     * rectangle increasement manner.
     *
     * @param r
     *            The given rectangle
     * @param amount
     *            The given amount of units
     * @return <code>r</code>
     */
    protected Rectangle outset(Rectangle r, int amount) {
        r.x -= amount;
        r.y -= amount;
        r.width += 2 * amount;
        r.height += 2 * amount;
        return r;
    }

    /**
     * Repaints the canvas.
     */
    public void repaint() {
        canvas.repaint();
    }

    /**
     * The element overlay.
     */
    public class ElementOverlay implements Overlay {

        /**
         * Paints this overlay.
         */
        public void paint(Graphics g) {
            if (controller.isOverlayEnabled() && isOverlayEnabled()) {
                int n = elements.size();
                for (int i = 0; i < n; i++) {
                    Element currentElement = (Element) elements.get(i);
                    GraphicsNode nodeToPaint = canvas.getUpdateManager()
                            .getBridgeContext().getGraphicsNode(currentElement);
                    if (nodeToPaint != null) {
                        AffineTransform elementsAt =
                            nodeToPaint.getGlobalTransform();
                        Shape selectionHighlight = nodeToPaint.getOutline();
                        AffineTransform at = canvas.getRenderingTransform();
                        at.concatenate(elementsAt);
                        Shape s = at.createTransformedShape(selectionHighlight);
                        if (s == null) {
                            break;
                        }
                        Graphics2D g2d = (Graphics2D) g;
                        if (xorMode) {
                            g2d.setColor(Color.black);
                            g2d.setXORMode(Color.yellow);
                            g2d.fill(s);
                            g2d.draw(s);
                        } else {
                            g2d.setColor(elementOverlayColor);
                            g2d.setStroke(new BasicStroke(1.8f));
                            g2d.setColor(elementOverlayStrokeColor);
                            g2d.draw(s);
                        }
                    }
                }
            }
        }
    }

    /**
     * Gets the elementOverlayColor.
     *
     * @return the elementOverlayColor
     */
    public Color getElementOverlayColor() {
        return elementOverlayColor;
    }

    /**
     * Sets the color to use for the element overlay.
     *
     * @param selectionOverlayColor The new element overlay color.
     */
    public void setElementOverlayColor(Color selectionOverlayColor) {
        this.elementOverlayColor = selectionOverlayColor;
    }

    /**
     * Gets the elementOverlayStrokeColor.
     *
     * @return the elementOverlayStrokeColor
     */
    public Color getElementOverlayStrokeColor() {
        return elementOverlayStrokeColor;
    }

    /**
     * Sets the color to use for stroking the element overlay.
     *
     * @param selectionOverlayStrokeColor
     *   The new element overlay stroking color.
     */
    public void setElementOverlayStrokeColor
            (Color selectionOverlayStrokeColor) {
        this.elementOverlayStrokeColor = selectionOverlayStrokeColor;
    }

    /**
     * Gets the xorMode.
     *
     * @return the xorMode
     */
    public boolean isXorMode() {
        return xorMode;
    }

    /**
     * Sets the xor mode.
     *
     * @param xorMode
     *            the xorMode to set
     */
    public void setXorMode(boolean xorMode) {
        this.xorMode = xorMode;
    }

    /**
     * Gets the elementOverlay.
     *
     * @return the elementOverlay
     */
    public Overlay getElementOverlay() {
        return elementOverlay;
    }

    /**
     * Removes the elementOverlay.
     */
    public void removeOverlay() {
        canvas.getOverlays().remove(elementOverlay);
    }

    /**
     * Sets the element overlay controller.
     *
     * @param controller
     *            The element overlay controller
     */
    public void setController(ElementOverlayController controller) {
        this.controller = controller;
    }

    /**
     * If the element overlay is enabled.
     *
     * @return isOverlayEnabled
     */
    public boolean isOverlayEnabled() {
        return isOverlayEnabled;
    }

    /**
     * Enables / disables the Element overlay.
     */
    public void setOverlayEnabled(boolean isOverlayEnabled) {
        this.isOverlayEnabled = isOverlayEnabled;
    }
}
