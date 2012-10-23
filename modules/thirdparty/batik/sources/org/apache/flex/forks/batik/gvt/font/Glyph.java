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
package org.apache.flex.forks.batik.gvt.font;

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.font.GlyphMetrics;
import java.awt.geom.AffineTransform;
import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.Vector;
import java.util.List;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.text.TextPaintInfo;


/**
 * A Glyph describes a graphics node with some specific glyph rendering
 * attributes.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: Glyph.java 501844 2007-01-31 13:54:05Z dvholten $
 */
public class Glyph {

    private String unicode;
    private Vector names;
    private String orientation;
    private String arabicForm;
    private String lang;
    private Point2D horizOrigin;
    private Point2D vertOrigin;
    private float horizAdvX;
    private float vertAdvY;
    private int glyphCode;
    private AffineTransform transform;
    private Point2D.Float position;
    private GVTGlyphMetrics metrics;

    private Shape outline; // cache the glyph outline
    private Rectangle2D bounds; // cache the glyph bounds

    private TextPaintInfo tpi;
    private TextPaintInfo cacheTPI;
    private Shape dShape;
    private GraphicsNode glyphChildrenNode;


    /**
     * Constructs a Glyph with the specified parameters.
     */
    public Glyph(String unicode, List names,
                 String orientation, String arabicForm, String lang,
                 Point2D horizOrigin, Point2D vertOrigin, float horizAdvX,
                 float vertAdvY, int glyphCode,
                 TextPaintInfo tpi,
                 Shape dShape, GraphicsNode glyphChildrenNode) {

        if (unicode == null) {
            throw new IllegalArgumentException();
        }
        if (horizOrigin == null) {
            throw new IllegalArgumentException();
        }
        if (vertOrigin == null) {
            throw new IllegalArgumentException();
        }

        this.unicode = unicode;
        this.names = new Vector( names );
        this.orientation = orientation;
        this.arabicForm = arabicForm;
        this.lang = lang;
        this.horizOrigin = horizOrigin;
        this.vertOrigin = vertOrigin;
        this.horizAdvX = horizAdvX;
        this.vertAdvY = vertAdvY;
        this.glyphCode = glyphCode;
        this.position = new Point2D.Float(0,0);
        this.outline = null;
        this.bounds = null;


        this.tpi = tpi;
        this.dShape = dShape;
        this.glyphChildrenNode = glyphChildrenNode;
    }

    /**
     * Returns the unicode char or chars this glyph represents.
     *
     * @return The glyphs unicode value.
     */
    public String getUnicode() {
        return unicode;
    }

    /**
     * Returns the names of this glyph.
     *
     * @return The glyph names.
     */
    public Vector getNames() {
        return names;
    }

    /**
     * Returns the orientation of this glyph.
     * Indicates what inline-progression-direction this glyph
     * can be used in. Should be either "h" for horizontal only, "v" for vertical
     * only, or empty which indicates that the glyph can be used in both.
     *
     * @return The glyph orientation.
     */
    public String getOrientation() {
        return orientation;
    }

    /**
     * Returns which of the four possible arabic forms this glyph represents.
     * This is only used for arabic glyphs.
     *
     * @return The glyphs arabic form.
     */
    public String getArabicForm() {
        return arabicForm;
    }

    /**
     * Returns a comma separated list of languages this glyph can be used in.
     *
     * @return The glyph languages.
     */
    public String getLang() {
        return lang;
    }

    /**
     * Returns the horizontal origin of this glyph.
     *
     * @return The horizontal origin.
     */
    public Point2D getHorizOrigin() {
        return horizOrigin;
    }

    /**
     * Returns the vertical origin of this glyph.
     *
     * @return The vertical origin.
     */
    public Point2D getVertOrigin() {
        return vertOrigin;
    }

    /**
     * Returns the horizontal advance value.
     *
     * @return This glyph's horizontal advance.
     */
    public float getHorizAdvX() {
        return horizAdvX;
    }

    /**
     * Returns the vertical advance value.
     *
     * @return the glyph's vertical advance.
     */
    public float getVertAdvY() {
        return vertAdvY;
    }

    /**
     * Returns the glyphs unique code with resect to its font. This will be
     * the index into the font's list of glyphs.
     *
     * @return The glyph's unique code.
     */
    public int getGlyphCode() {
        return glyphCode;
    }

    /**
     * Returns the glpyh's transform.
     *
     * @return The glyph's transform.
     */
    public AffineTransform getTransform() {
        return transform;
    }

    /**
     * Sets the transform to be applied to this glyph.
     *
     * @param transform The transform to set.
     */
    public void setTransform(AffineTransform transform) {
        this.transform = transform;
        outline = null;
        bounds = null;
    }

    /**
     * Returns the position of this glyph.
     *
     * @return The glyph's position.
     */
    public Point2D getPosition() {
        return position;
    }

    /**
     * Sets the position of the glyph.
     *
     * @param position The new glyph position.
     */
    public void setPosition(Point2D position) {
        this.position.x = (float)position.getX();
        this.position.y = (float)position.getY();
        outline = null;
        bounds = null;
    }

    /**
     * Returns the metrics of this Glyph if it is used in a horizontal layout.
     *
     * @return The glyph metrics.
     */
    public GVTGlyphMetrics getGlyphMetrics() {
        if (metrics == null) {
            Rectangle2D gb = getGeometryBounds();

            metrics = new GVTGlyphMetrics
                (getHorizAdvX(), getVertAdvY(),
                 new Rectangle2D.Double(gb.getX()-position.getX(),
                                        gb.getY()-position.getY(),
                                        gb.getWidth(),gb.getHeight()),
                 GlyphMetrics.COMPONENT);
        }
        return metrics;
    }


    /**
     * Returns the metics of this Glyph with the specified kerning value
     * applied.
     *
     * @param hkern The horizontal kerning value to apply when calculating
     *              the glyph metrics.
     * @param vkern The horizontal vertical value to apply when calculating
     *              the glyph metrics.
     * @return The kerned glyph metics
     */
    public GVTGlyphMetrics getGlyphMetrics(float hkern, float vkern) {
        return new GVTGlyphMetrics(getHorizAdvX() - hkern,
                                   getVertAdvY() - vkern,
                                   getGeometryBounds(),
                                   GlyphMetrics.COMPONENT);

    }

    public Rectangle2D getGeometryBounds() {
        return getOutline().getBounds2D();
    }

    public Rectangle2D getBounds2D() {
        // Check if the TextPaintInfo has changed...
        if ((bounds != null) &&
            TextPaintInfo.equivilent(tpi, cacheTPI))
            return bounds;

        AffineTransform tr =
            AffineTransform.getTranslateInstance(position.getX(),
                                                 position.getY());
        if (transform != null) {
            tr.concatenate(transform);
        }

        Rectangle2D bounds = null;
        if ((dShape != null) && (tpi != null)) {
            if (tpi.fillPaint != null)
                bounds = tr.createTransformedShape(dShape).getBounds2D();

            if ((tpi.strokeStroke != null) && (tpi.strokePaint != null)) {
                Shape s = tpi.strokeStroke.createStrokedShape(dShape);
                Rectangle2D r = tr.createTransformedShape(s).getBounds2D();
                if (bounds == null) bounds = r;
                //else                bounds = r.createUnion(bounds);
                else                bounds.add( r );
            }
        }

        if (glyphChildrenNode != null) {
            Rectangle2D r = glyphChildrenNode.getTransformedBounds(tr);
            if (bounds == null) bounds = r;
            // else                bounds = r.createUnion(bounds);
            else                bounds.add( r );
        }
        if (bounds == null)
            bounds = new Rectangle2D.Double
                (position.getX(), position.getY(), 0, 0);

        cacheTPI = new TextPaintInfo(tpi);
        return bounds;
    }

    /**
     * Returns the outline of this glyph. This will be positioned correctly and
     * any glyph transforms will have been applied.
     *
     * @return the outline of this glyph.
     */
    public Shape getOutline() {
        if (outline == null) {
            AffineTransform tr =
                AffineTransform.getTranslateInstance(position.getX(),
                                                     position.getY());
            if (transform != null) {
                tr.concatenate(transform);
            }
            Shape glyphChildrenOutline = null;
            if (glyphChildrenNode != null) {
                glyphChildrenOutline = glyphChildrenNode.getOutline();
            }
            GeneralPath glyphOutline = null;
            if (dShape != null && glyphChildrenOutline != null) {
                glyphOutline = new GeneralPath(dShape);
                glyphOutline.append(glyphChildrenOutline, false);
            } else if (dShape != null && glyphChildrenOutline == null) {
                glyphOutline = new GeneralPath(dShape);
            } else if (dShape == null && glyphChildrenOutline != null) {
                glyphOutline = new GeneralPath(glyphChildrenOutline);
            } else {
                // must be a whitespace glyph, return an empty shape
                glyphOutline = new GeneralPath();
            }
            outline = tr.createTransformedShape(glyphOutline);
        }
        return outline;
    }

    /**
     * Draws this glyph.
     *
     * @param graphics2D The Graphics2D object to draw to.
     */
    public void draw(Graphics2D graphics2D) {
        AffineTransform tr =
            AffineTransform.getTranslateInstance(position.getX(),
                                                 position.getY());
        if (transform != null) {
            tr.concatenate(transform);
        }

        // paint the dShape first
        if ((dShape != null) && (tpi != null)) {
            Shape tShape = tr.createTransformedShape(dShape);
            if (tpi.fillPaint != null) {
                graphics2D.setPaint(tpi.fillPaint);
                graphics2D.fill(tShape);
            }

            // check if we need to draw the outline of this glyph
            if (tpi.strokeStroke != null && tpi.strokePaint != null) {
                graphics2D.setStroke(tpi.strokeStroke);
                graphics2D.setPaint(tpi.strokePaint);
                graphics2D.draw(tShape);
            }
        }

        // paint the glyph children nodes
        if (glyphChildrenNode != null) {
            glyphChildrenNode.setTransform(tr);
            glyphChildrenNode.paint(graphics2D);
        }
    }
}

