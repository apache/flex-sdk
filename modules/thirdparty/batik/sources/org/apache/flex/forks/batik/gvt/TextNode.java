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
package org.apache.flex.forks.batik.gvt;

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.text.AttributedCharacterIterator;
import java.text.CharacterIterator;
import java.util.List;

import org.apache.flex.forks.batik.gvt.renderer.StrokingTextPainter;
import org.apache.flex.forks.batik.gvt.text.AttributedCharacterSpanIterator;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;
import org.apache.flex.forks.batik.gvt.text.Mark;
import org.apache.flex.forks.batik.gvt.text.TextHit;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;
import org.apache.flex.forks.batik.gvt.text.TextSpanLayout;

/**
 * A graphics node that represents text.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TextNode.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TextNode extends AbstractGraphicsNode implements Selectable {

    public static final 
        AttributedCharacterIterator.Attribute PAINT_INFO =
        GVTAttributedCharacterIterator.TextAttribute.PAINT_INFO;

    /**
     * Location of this text node (inherited, independent of explicit
     * X and Y attributes applied to children).
     */
    protected Point2D location = new Point2D.Float(0, 0);

    /**
     * Attributed Character Iterator describing the text
     */
    protected AttributedCharacterIterator aci;

    /**
     * The text of this <tt>TextNode</tt>.
     */
    protected String text;

    /**
     * The begin mark.
     */
    protected Mark beginMark = null;

    /**
     * The end mark.
     */
    protected Mark endMark = null;

    /**
     * The list of text runs.
     */
    protected List textRuns;

    /**
     * The text painter used to display the text of this text node.
     */
    protected TextPainter textPainter = StrokingTextPainter.getInstance();

    /**
     * Internal Cache: Bounds for this text node, without taking any of the
     * rendering attributes (e.g., stroke) into account
     */
    private Rectangle2D geometryBounds;

    /**
     * Internal Cache: Primitive Bounds.
     */
    private Rectangle2D primitiveBounds;

    /**
     * Internal Cache: the outline.
     */
    private Shape outline;

    /**
     * Constructs a new empty <tt>TextNode</tt>.
     */
    public TextNode() {
    }

    /**
     * Sets the text painter of this text node. If the specified text
     * painter is null, this text node will use its default text
     * painter (StrokingTextPainter.getInstance()).
     *
     * @param textPainter the text painter to use
     */
    public void setTextPainter(TextPainter textPainter) {
        if (textPainter == null) {
            this.textPainter = StrokingTextPainter.getInstance();
        } else {
            this.textPainter = textPainter;
        }
    }

    /**
     * Returns the text painter of this text node.
     */
    public TextPainter getTextPainter() {
        return textPainter;
    }

    /**
     * Returns a list of text runs.
     */
    public List getTextRuns() {
        return textRuns;
    }

    /**
     * Sets the list of text runs of this text node.
     *
     * @param textRuns the new list of text runs
     */
    public void setTextRuns(List textRuns) {
        this.textRuns = textRuns;
    }

    /**
     * Returns the text of this <tt>TextNode</tt> as a string.
     */
    public String getText() {

        if (text != null) 
            return text;

        if (aci == null) {
            text = "";
        } else {
            StringBuffer buf = new StringBuffer(aci.getEndIndex());
            for (char c = aci.first();
                 c != CharacterIterator.DONE;
                 c = aci.next()) {
                buf.append(c);
            }
            text = buf.toString();
        }
        return text;
    }

    /**
     * Sets the location of this text node.
     *
     * @param newLocation the new location of this text node
     */
    public void setLocation(Point2D newLocation){
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        this.location = newLocation;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the location of this text node.
     *
     * @return the location of this text node
     */
    public Point2D getLocation(){
        return location;
    }

    public void swapTextPaintInfo(TextPaintInfo newInfo, 
                                  TextPaintInfo oldInfo) {
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        oldInfo.set(newInfo);
        fireGraphicsNodeChangeCompleted();
    }
                                  

    /**
     * Sets the attributed character iterator of this text node.
     *
     * @param newAci the new attributed character iterator
     */
    public void setAttributedCharacterIterator
        (AttributedCharacterIterator newAci) {
        fireGraphicsNodeChangeStarted();
        invalidateGeometryCache();
        this.aci = newAci;
        text = null;
        textRuns = null;
        fireGraphicsNodeChangeCompleted();
    }

    /**
     * Returns the attributed character iterator of this text node.
     *
     * @return the attributed character iterator
     */
    public AttributedCharacterIterator getAttributedCharacterIterator(){
        return aci;
    }

    //
    // Geometric methods
    //

    /**
     * Invalidates this <tt>TextNode</tt>. This node and all its ancestors have
     * been informed that all its cached values related to its bounds must be
     * recomputed.
     */
    protected void invalidateGeometryCache() {
        super.invalidateGeometryCache();
        primitiveBounds = null;
        geometryBounds = null;
        outline = null;
    }

    /**
     * Returns the bounds of the area covered by this node's primitive paint.
     */
    public Rectangle2D getPrimitiveBounds(){
        if (primitiveBounds == null) {
            if (aci != null) {
                primitiveBounds = textPainter.getBounds2D(this);
            }
        }
        return primitiveBounds;
    }

    /**
     * Returns the bounds of the area covered by this node, without
     * taking any of its rendering attribute into account. That is,
     * exclusive of any clipping, masking, filtering or stroking, for
     * example.
     */
    public Rectangle2D getGeometryBounds(){
        if (geometryBounds == null){
            if (aci != null) {
                geometryBounds = textPainter.getGeometryBounds(this);
            }
        }
        return geometryBounds;
    }

    /**
     * Returns the bounds of the sensitive area covered by this node,
     * This includes the stroked area but does not include the effects
     * of clipping, masking or filtering.
     */
    public Rectangle2D getSensitiveBounds() {
        return getGeometryBounds();
    }

    /**
     * Returns the outline of this node.
     */
    public Shape getOutline() {
        if (outline == null) {
            if (aci != null) {
                outline = textPainter.getOutline(this);
            }
        }
        return outline;
    }

    /**
     * Return the marker for the character at index in this nodes
     * AttributedCharacterIterator.  Before Char indicates if the
     * Marker should be considered before or after char.
     */
    public Mark getMarkerForChar(int index, boolean beforeChar) {
        return textPainter.getMark(this, index, beforeChar);
    }

    //
    // Selection methods
    //
    public void setSelection(Mark begin, Mark end) {
        if ((begin.getTextNode() != this) ||
            (end.getTextNode() != this))
            throw new Error("Markers not from this TextNode");

        beginMark = begin;
        endMark   = end;
    }

    /**
     * Initializes the current selection to begin with the character at (x, y).
     * @param x the x coordinate of the start of the selection
     * @param y the y coordinate of the start of the selection
     */
    public boolean selectAt(double x, double y) {
        beginMark = textPainter.selectAt(x, y, this);
        return true; // assume this always changes selection, for now.
    }

    /**
     * Extends the current selection to the character at (x, y).
     * @param x the x coordinate of the end of the selection
     * @param y the y coordinate of the end of the selection
     */
    public boolean selectTo(double x, double y) {
        Mark tmpMark = textPainter.selectTo(x, y, beginMark);
        if (tmpMark == null)
            return false;
        if (tmpMark != endMark) {
            endMark = tmpMark;
            return true;
        }
        return false;
    }

    /**
     * Selects all the text in this TextNode.  The coordinates are ignored.
     * @param x the x coordinate of the point the selection was made
     * @param y the y coordinate of the point the selection was made
     */
    public boolean selectAll(double x, double y) {
        beginMark = textPainter.selectFirst(this);
        endMark   = textPainter.selectLast(this);
        return true; // assume this always changes selection, for now.
    }

    /**
     * Gets the current text selection.
     *
     * @return an object containing the selected content.
     */
    public Object getSelection() {
        Object o = null;
        if (aci == null) return o;

        int[] ranges = textPainter.getSelected(beginMark, endMark);

        // TODO: later we can return more complex things like
        // noncontiguous selections
        if ((ranges != null) && (ranges.length > 1)) {
            // make sure that they are in order
            if (ranges[0] > ranges[1]) {
                int temp = ranges[1];
                ranges[1] = ranges[0];
                ranges[0] = temp;
            }
            o = new AttributedCharacterSpanIterator
                (aci, ranges[0], ranges[1]+1);
        }
        return o;
    }

    /**
     * Returns the shape used to outline this text node.
     *
     * @return a Shape which encloses the current text selection.
     */
    public Shape getHighlightShape() {
        Shape highlightShape =
            textPainter.getHighlightShape(beginMark, endMark);
        AffineTransform t = getGlobalTransform();
        highlightShape = t.createTransformedShape(highlightShape);
        return highlightShape;
    }

    //
    // Drawing methods
    //

    /**
     * Paints this node without applying Filter, Mask, Composite, and clip.
     *
     * @param g2d the Graphics2D to use
     */
    public void primitivePaint(Graphics2D g2d) {
        //
        // DO NOT REMOVE: THE FOLLOWING IS A WORK AROUND
        // A BUG IN THE JDK 1.2 RENDERING PIPELINE WHEN
        // THE CLIP IS A RECTANGLE
        //
        Shape clip = g2d.getClip();
        if (clip != null && !(clip instanceof GeneralPath)) {
            g2d.setClip(new GeneralPath(clip));
        }
        // Paint the text
        textPainter.paint(this, g2d);
    }

    //
    // Geometric methods
    //

    /**
     * Returns true if the specified Point2D is inside the boundary of this
     * node, false otherwise.
     *
     * @param p the specified Point2D in the user space
     */
    public boolean contains(Point2D p) {
        // <!> FIXME: should put this code in TextPaint somewhere,
        // as pointer-events support - same problem with pointer-events
        // and ShapeNode
        if (!super.contains(p)) {
            return false;
        }
        List list = getTextRuns();
        // place coords in text node coordinate system
        for (int i = 0 ; i < list.size(); i++) {
            StrokingTextPainter.TextRun run =
                (StrokingTextPainter.TextRun)list.get(i);
            TextSpanLayout layout = run.getLayout();
            float x = (float)p.getX();
            float y = (float)p.getY();
            TextHit textHit = layout.hitTestChar(x, y);
            if (textHit != null && contains(p, layout.getBounds2D())) {
                return true;
            }
        }
        return false;
    }

    protected boolean contains(Point2D p, Rectangle2D b) {
        if (b == null || !b.contains(p)) {
            return false;
        }
        switch(pointerEventType) {
        case VISIBLE_PAINTED:
        case VISIBLE_FILL:
        case VISIBLE_STROKE:
        case VISIBLE:
            return isVisible;
        case PAINTED:
        case FILL:
        case STROKE:
        case ALL:
            return true;
        case NONE:
            return false;
        default:
            return false;
        }
    }

    /**
     * Defines where the text of a <tt>TextNode</tt> can be anchored
     * relative to its location.
     */
    public static final class Anchor implements java.io.Serializable {

        /**
         * The type of the START anchor.
         */
        public static final int ANCHOR_START  = 0;

        /**
         * The type of the MIDDLE anchor.
         */
        public static final int ANCHOR_MIDDLE = 1;

        /**
         * The type of the END anchor.
         */
        public static final int ANCHOR_END    = 2;

        /**
         * The anchor which enables the rendered characters to be aligned such
         * that the start of the text string is at the initial current text
         * location.
         */
        public static final Anchor START = new Anchor(ANCHOR_START);

        /**
         * The anchor which enables the rendered characters to be aligned such
         * that the middle of the text string is at the initial current text
         * location.
         */
        public static final Anchor MIDDLE = new Anchor(ANCHOR_MIDDLE);

        /**
         * The anchor which enables the rendered characters to be aligned such
         * that the end of the text string is at the initial current text
         * location.
         */
        public static final Anchor END = new Anchor(ANCHOR_END);

        /**
         * The anchor type.
         */
        private int type;

        /**
         * No instance of this class.
         */
        private Anchor(int type) {
            this.type = type;
        }

        /**
         * Returns the type of this anchor.
         */
        public int getType() {
            return type;
        }

        /**
         * This is called by the serialization code before it returns
         * an unserialized object. To provide for unicity of
         * instances, the instance that was read is replaced by its
         * static equivalent. See the serialiazation specification for
         * further details on this method's logic.
         */
        private Object readResolve() throws java.io.ObjectStreamException {
            switch(type){
            case ANCHOR_START:
                return START;
            case ANCHOR_MIDDLE:
                return MIDDLE;
            case ANCHOR_END:
                return END;
            default:
                throw new Error("Unknown Anchor type");
            }
        }
    }
}


