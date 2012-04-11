/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.graphics.g2d;

import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.font.GlyphVector;
import java.awt.font.TextLayout;
import java.awt.geom.*;
import java.awt.image.*;
import java.awt.image.renderable.RenderContext;
import java.awt.image.renderable.RenderableImage;
import java.text.AttributedCharacterIterator;
import java.util.Map;

/**
 * An abstract implementation of most of the <code>Graphics2D</code>
 * and <code>Graphics</code> APIs to help render Java AWT to
 * Macromedia Flash (SWF) format. Concrete extensions must implement
 * the {@link #draw(Shape)}, {@link #fill(Shape)} and {@link
 * #drawString(String, float, float)) methods, as these typically need
 * to be turned into physical SWF records.
 *
 * @author Peter Farland
 * @version 0.9
 */
public abstract class AbstractGraphics2D extends Graphics2D
{
	protected AbstractGraphics2D(GraphicContext context)
	{
		this.graphicContext = context;
	}

	/**
	 * Intersects the current <code>Clip</code> with the interior of the
     * specified <code>Shape</code> and sets the <code>Clip</code> to the
     * resulting intersection.  The specified <code>Shape</code> is
     * transformed with the current <code>Graphics2D</code>
     * <code>Transform</code> before being intersected with the current
     * <code>Clip</code>.  This method is used to make the current
     * <code>Clip</code> smaller.
	 * @param shape
	 * @see Graphics2D#clip(Shape)
	 */
	public void clip(Shape shape)
	{
		graphicContext.clip(shape);
	}

	/**
	 * <b style="color:orange">NOT YET IMPLEMENTED AS EXPECTED, CURRENTLY USING drawStringAsShape()</b><br />
	 * @param str the text to be rendered
	 * @param x baseline x co-ordinate
	 * @param y baseline y co-ordinate
	 * @see Graphics2D#drawString(String, int, int)
	 */
	public void drawString(String str, int x, int y)
	{
		drawString(str, (float)x, (float)y);
	}

	/**
	 * Renders the text of the specified iterator, using the <code>Graphics2D</code> context's
	 * current <code>Paint</code>. The iterator must specify a font for each character.
	 * @param iterator
	 * @param x baseline x co-ordinate
	 * @param y baseline y co-ordinate
	 * @see Graphics2D#drawString(AttributedCharacterIterator, int, int)
	 */
	public void drawString(AttributedCharacterIterator iterator, int x, int y)
	{
		drawString(iterator, (float)x, (float)y);
	}

	/**
	 * Renders the text of the specified iterator, using the <code>Graphics2D</code> context's
	 * current <code>Paint</code>. The iterator must specify a font for each character.
	 * @param iterator
	 * @param x baseline x co-ordinate
	 * @param y baseline y co-ordinate
	 * @see Graphics2D#drawString(AttributedCharacterIterator, float, float)
	 */
	public void drawString(AttributedCharacterIterator iterator, float x, float y)
	{
		TextLayout layout = new TextLayout(iterator, getFontRenderContext());
        layout.draw(this, x, y);
	}

	/**
	 * Renders the specified string as a series of AWT shapes, created using a
	 * glyph vector. The glyphs are converted a single outline and then rendered as closed SWF
	 * shape fills using the current graphic context to control anti-aliasing and foreground color.
	 * <p>
     * The baseline of the first character is at position (<i>x</i>, <i>y</i>)
	 * in the User Space.
	 * </p>
	 * @param str the string to be rendered
	 * @param x baseline x co-ordinate
	 * @param y baseline y co-ordinate
	 * @see Graphics2D#drawGlyphVector(GlyphVector, float, float)
	 */
	public void drawStringAsShape(String str, float x, float y)
	{
		GlyphVector gv = graphicContext.getFont().createGlyphVector(graphicContext.getFontRenderContext(), str);
		drawGlyphVector(gv, x, y);
	}

	/**
	 * The glyphs are converted to a single outline and then rendered as closed SWF shape fills
	 * using the current graphic context to control anti-aliasing and foreground color.
	 * @param gv the collection of glyphs
	 * @param x baseline x co-ordinate
	 * @param y baseline y co-ordinate
	 * @see Graphics2D#drawGlyphVector(GlyphVector, float, float)
	 */
	public void drawGlyphVector(GlyphVector gv, float x, float y)
	{
		Shape textOutline = gv.getOutline(x, y);
		fill(textOutline); //Fonts don't have an outline in SWF by default...
	}

	/**
	 *
	 * @param image
	 * @param xform
	 * @param obs
	 * @return
	 * @see Graphics2D#drawImage(Image, AffineTransform, ImageObserver)
	 */
	public boolean drawImage(Image image, AffineTransform xform, ImageObserver obs)
	{
		if (image != null)
		{
			//TODO: Process AffineTransform
			if (image instanceof BufferedImage)
			{
				Paint p = graphicContext.getPaint();
				Rectangle2D rect = new Rectangle2D.Double(0, 0, image.getWidth(obs), image.getHeight(obs));
				TexturePaint tp = new TexturePaint((BufferedImage)image, rect);
				graphicContext.setPaint(tp);
				fill(rect);
				graphicContext.setPaint(p);
			}
		}
		return false;
	}

	/**
	 * Renders a <code>BufferedImage</code> that is filtered with a {@link BufferedImageOp}.
     * The rendering attributes applied include the <code>Clip</code>, <code>Transform</code>
     * and <code>Composite</code> attributes.
	 * @param bi
	 * @param op
	 * @param x
	 * @param y
	 * @see Graphics2D#drawImage(BufferedImage, BufferedImageOp, int, int)
	 */
	public void drawImage(BufferedImage bi, BufferedImageOp op, int x, int y)
	{
		BufferedImage newBi = op.filter(bi, null);
     	drawImage(newBi, new AffineTransform(1.0, 0.0, 0.0, 1.0, x, y), null);
	}

	/**
	 *
	 * @param image
	 * @param tx
	 * @see Graphics2D#drawRenderedImage(RenderedImage, AffineTransform)
	 */
	public void drawRenderedImage(RenderedImage image, AffineTransform tx)
	{
		if (image != null)
		{
			BufferedImage bufferedImage = null;

			if(image instanceof BufferedImage)
			{
				bufferedImage = (BufferedImage)image;
			}
			else
			{
				ColorModel cm = image.getColorModel();
				Raster r = image.getData();
				WritableRaster wr = r.createCompatibleWritableRaster();
				bufferedImage = new BufferedImage(cm, wr, cm.isAlphaPremultiplied(), null);
			}

			drawImage(bufferedImage, tx, null);
		}
	}

	/**
	 *
	 * @param image
	 * @param tx
	 * @see Graphics2D#drawRenderableImage(RenderableImage, AffineTransform)
	 */
	public void drawRenderableImage(RenderableImage image, AffineTransform tx)
	{
		AffineTransform tx1 = graphicContext.getTransform();
		AffineTransform tx2 = new AffineTransform(tx);
		tx2.concatenate(tx1);
		RenderContext renderContext = new RenderContext(tx2);
		AffineTransform tx3;

		try
		{
			tx3 = tx1.createInverse();
		}
		catch (NoninvertibleTransformException e)
		{
			renderContext = new RenderContext(tx1);
			tx3 = new AffineTransform();
		}

		RenderedImage renderedimage = image.createRendering(renderContext);
		drawRenderedImage(renderedimage, tx3);
	}

	/**
	 * Gets the paint style from the current graphic context. Paints are used to fill in
	 * the center of shapes.
	 * @return the current paint style
	 * @see Graphics2D#getPaint()
	 */
	public Paint getPaint()
	{
		return graphicContext.getPaint();
	}

	/**
	 * Changes the paint of the current graphic context. Paints are used to fill in
	 * the center of shapes.
	 * @param paint the new paint style
	 * @see Graphics2D#setPaint(Paint)
	 */
	public void setPaint(Paint paint)
	{
		graphicContext.setPaint(paint);
	}

	/**
	 * Gets the stroke style from the current graphic context. Strokes are used to outline
	 * shape definitions.
	 * @return the current stroke style
	 * @see Graphics2D#getStroke()
	 */
	public Stroke getStroke()
	{
		return graphicContext.getStroke();
	}

	/**
	 * Changes the stroke of the current graphic context. Strokes are used to outline
	 * shape definitions.
	 * @param stroke the new stroke style
	 * @see Graphics2D#setStroke(Stroke)
	 */
	public void setStroke(Stroke stroke)
	{
		graphicContext.setStroke(stroke);
	}

	/**
	 * Translates the origin of the graphic context to the point (<i>x</i>, <i>y</i>)
	 * in the current co-ordinate system.  All coordinates used in subsequent
	 * rendering operations on this graphics context are relative to this new origin.
	 * @param x the <i>x</i> co-ordinate
	 * @param y the <i>y</i> co-ordinate
	 * @see Graphics2D#translate(int, int)
	 */
	public void translate(int x, int y)
	{
		graphicContext.translate(x, y);
	}

	/**
	 * Concatenates any current tranformation on the graphics context with an additional transform that
	 * translates the origin of the graphic context to the point (<i>x</i>, <i>y</i>)
	 * in the current coordinate system. All coordinates used in subsequent
	 * rendering operations on this graphics context are relative to this new origin.
	 * @param tx the <i>x</i> co-ordinate, in double precision
	 * @param ty the <i>y</i> co-ordinate, in double precision
	 * @see Graphics2D#translate(double, double)
	 */
	public void translate(double tx, double ty)
	{
		graphicContext.translate(tx, ty);
	}

	/**
	 * Concatenates a rotation transform to the current graphic context's transformation (if one exists).
	 * Subsequent rendering is rotated by the specified angle in radians (1 radian = angle-in-degrees / pi)
	 * relative to the previous origin.
	 * @param theta angle of rotation in radians
	 * @see Graphics2D#rotate(double)
	 */
	public void rotate(double theta)
	{
		graphicContext.rotate(theta);
	}

	/**
	 * Concatenates the current graphic context's transformation with a translated rotation.
	 * @param theta angle of rotation in radians, double precision
	 * @param x control point <i>x</i>-coordinate, double precision
	 * @param y control point <i>y</i>-coordinate, double precision
	 * @see Graphics2D#rotate(double, double, double)
	 */
	public void rotate(double theta, double x, double y)
	{
		graphicContext.rotate(theta, x, y);
	}

	/**
	 * Concatenates a scale transform to the current graphic context's transformation. Co-ordinates
	 * are scaled relatively by the amount specified on the x- and y- axes.
	 * @param sx
	 * @param sy
	 * @see Graphics2D#scale(double, double)
	 */
	public void scale(double sx, double sy)
	{
		graphicContext.scale(sx, sy);
	}

	/**
	 * Concatenates a shear transform to the current graphic context's transformation. Co-ordinates
	 * are sheared relatively by the multiplier amount specified on the x- and y- axes.
	 * @param shx
	 * @param shy
	 * @see Graphics2D#scale(double, double)
	 */
	public void shear(double shx, double shy)
	{
		graphicContext.shear(shx, shy);
	}

	/**
	 * This method concatenates the supplied transformation to any existing transform on the current
	 * graphic context.
	 * @param tx the additional transformation
	 * @see Graphics2D#transform(AffineTransform)
	 */
	public void transform(AffineTransform tx)
	{
		graphicContext.transform(tx);
	}

	/**
	 * Replaces the current transform in the graphic context.
	 * @param tx the new transformation
	 * @see Graphics2D#setTransform(AffineTransform)
	 */
	public void setTransform(AffineTransform tx)
	{
		graphicContext.setTransform(tx);
	}

	/**
	 * Gets the current transform in the graphic context.
	 * @return the current transform
	 * @see Graphics2D#getTransform()
	 */
	public AffineTransform getTransform()
	{
		return graphicContext.getTransform();
	}


	/**
	 * Gets the current background color from the graphic context.
	 * @return the current color
	 * @see Graphics2D#getBackground()
	 */
	public Color getBackground()
	{
		return graphicContext.getBackground();
	}

	/**
	 * Changes the current background color of the graphic context.
	 * @param color the new background color
	 * @see Graphics2D#setBackground(Color)
	 */
	public void setBackground(Color color)
	{
		graphicContext.setBackground(color);
	}

	/**
	 * Gets the current font render context from the graphic context. The font render context
	 * contains specific information for character glyphs, such as anti-aliasing.
	 * @return
	 * @see Graphics2D#getFontRenderContext()
	 */
	public FontRenderContext getFontRenderContext()
	{
		return graphicContext.getFontRenderContext();
	}

	/**
	 *
	 * @param rect
	 * @param shape
	 * @param onStroke
	 * @return
	 */
	public boolean hit(Rectangle rect, Shape shape, boolean onStroke)
	{
		if (onStroke)
            shape = graphicContext.getStroke().createStrokedShape(shape);

        shape = graphicContext.getTransform().createTransformedShape(shape);
        return shape.intersects(rect);
	}

	/**
	 * <b style="color:orange">TODO: NOT YET IMPLEMENTED</b>
	 * @return
	 */
	public GraphicsConfiguration getDeviceConfiguration()
	{
		return graphicContext.getDeviceConfiguration();
	}

	/**
	 *
	 * @param comp
	 */
	public void setComposite(Composite comp)
	{
		graphicContext.setComposite(comp);
	}

	/**
	 *
	 * @param hintKey
	 * @param hintValue
	 */
	public void setRenderingHint(RenderingHints.Key hintKey, Object hintValue)
	{
		graphicContext.setRenderingHint(hintKey, hintValue);
	}

	/**
	 *
	 * @param hintKey
	 * @return
	 */
	public Object getRenderingHint(RenderingHints.Key hintKey)
	{
		return graphicContext.getRenderingHint(hintKey);
	}

	/**
	 *
	 * @param hints
	 */
	public void setRenderingHints(Map hints)
	{
		graphicContext.setRenderingHints(hints);
	}

	/**
	 *
	 * @param hints
	 */
	public void addRenderingHints(Map hints)
	{
		graphicContext.addRenderingHints(hints);
	}

	/**
	 *
	 * @return
	 */
	public RenderingHints getRenderingHints()
	{
		return graphicContext.getRenderingHints();
	}

	/**
	 *
	 * @return
	 */
	public Composite getComposite()
	{
		return graphicContext.getComposite();
	}



	/**
	 * Examines the current paint from the the graphic context, if it is a Color it returns it,
	 * otherwise returns null.
	 *
	 * @return the current paint, if a color
	 * @see Graphics#getColor()
	 * @deprecated use getPaint instead of getColor
	 */
	public Color getColor()
	{
		Paint p = graphicContext.getPaint();

		if (p instanceof Color)
			return (Color)p;

		return null;
	}

	/**
	 * Changes the current paint of the graphic context to the supplied color.
	 * @param c the new color
	 * @see #setPaint(Paint)
	 * @deprecated use setPaint instead of setColor
	 */
	public void setColor(Color c)
	{
		graphicContext.setPaint(c);
	}

    /**
	 *
	 */
	public void setPaintMode()
	{
		graphicContext.setComposite(AlphaComposite.SrcOver);
	}

	/**
	 * <b style="color:orange">NOT YET IMPLEMENTED</b>
	 * @param c1
	 */
	public void setXORMode(Color c1)
	{
		throw new RuntimeException("Not yet supported");
	}

	/**
	 * Gets the current font from the graphic context.
	 * @return the current font
	 * @see Graphics#getFont()
	 */
	public Font getFont()
	{
		return graphicContext.getFont();
	}

	/**
	 * Changes the current font of the graphic context.
	 * @param font the new font
	 * @see Graphics#setFont(Font)
	 */
	public void setFont(Font font)
	{
		graphicContext.setFont(font);
	}

	/**
	 * @param f
	 * @return metrics for the specified font
	 */
	public FontMetrics getFontMetrics(Font f)
	{
        return graphicContext.getFontMetrics(f);
	}

	/**
	 *
	 * @return
	 */
	public Rectangle getClipBounds()
	{
		return graphicContext.getClipBounds();
	}

    /**
	 *
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 */
	public void clipRect(int x, int y, int width, int height)
	{
		 graphicContext.clipRect(x, y, width, height);
	}

	/**
	 *
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 */
	public void setClip(int x, int y, int width, int height)
	{
		graphicContext.setClip(x, y, width, height);
	}

	/**
	 * Gets the current clipping area.
	 * @return a <code>Shape</code> representing the clipping area.
	 */
	public Shape getClip()
	{
		 return graphicContext.getClip();
	}

	/**
	 * Sets the current clipping area to an arbitrary clip shape.
	 * @param clip
	 */
	public void setClip(Shape clip)
	{
		graphicContext.setClip(clip);
	}

	/**
	 * <b style="color:orange">NOT YET IMPLEMENTED</b>
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * @param dx
	 * @param dy
	 */
	public void copyArea(int x, int y, int width, int height, int dx, int dy)
	{
		throw new RuntimeException("Not yet supported");
	}

	/**
	 * Draws a line, using the current color and stroke, between the points
     * <code>(x1, y1)</code> and <code>(x2, y2)</code>
     * in this graphics context's coordinate system.
	 * @param x1 the first point's <i>x</i> coordinate.
     * @param y1 the first point's <i>y</i> coordinate.
     * @param x2 the second point's <i>x</i> coordinate.
     * @param y2 the second point's <i>y</i> coordinate.
	 * @see Graphics#drawLine(int, int, int, int)
	 */
	public void drawLine(int x1, int y1, int x2, int y2)
	{
		Line2D line = new Line2D.Double(x1, y1, x2, y2);
		draw(line);
	}

	/**
	 * Draws the interior fill of a rectangle from the point <code>(x, y)</code>
	 * extending horizontally by <code>x + width - 1</code>, and vertically by
	 * <code>y + height - 1</code>.
	 * @param x the origin <i>x</i> co-ordinate
	 * @param y the origin <i>y</i> co-ordinate
	 * @param width in pixels
	 * @param height in pixels
	 * @see Graphics#fillRect(int, int, int, int)
	 */
	public void fillRect(int x, int y, int width, int height)
	{
        Rectangle2D r = new Rectangle2D.Double(x, y, width, height);
		fill(r);
	}

	/**
	 * Clears the specified rectangle by filling it with the background
     * color of the current graphic context.
	 * @param x the origin <i>x</i> co-ordinate
	 * @param y the origin <i>y</i> co-ordinate
	 * @param width in pixels
	 * @param height in pixels
	 * @see Graphics#clearRect(int, int, int, int)
	 */
	public void clearRect(int x, int y, int width, int height)
	{
        Paint temp = graphicContext.getPaint();
		graphicContext.setPaint(graphicContext.getBackground());
		fillRect(x, y, width, height);
		graphicContext.setPaint(temp);
	}

	/**
	 * Draws the outline of a rectangle with round edges using the current color
	 * and stroke of the graphics context. The origin of the rectangle is set at
	 * <code>(x, y)</code> and <code>width</code> pixels wide and <code>height</code>
	 * pixels high.
     * @param x the origin <i>x</i> coordinate
     * @param y the origin <i>y</i> coordinate
     * @param width in pixels
     * @param height in pixels
     * @param arcWidth the horizontal diameter of the arc at the four corners
     * @param arcHeight the vertical diameter of the arc at the four corners
	 * @see Graphics#drawRoundRect(int, int, int, int, int, int)
	 */
	public void drawRoundRect(int x, int y, int width, int height, int arcWidth, int arcHeight)
	{
		RoundRectangle2D rr = new RoundRectangle2D.Double(x, y, width, height, arcWidth, arcHeight);
		draw(rr);
	}

	/**
	 * Paints the center of a rectangle with round edges using the current paint style of the graphics
	 * context.
     * @param x the origin <i>x</i> coordinate
     * @param y the origin <i>y</i> coordinate
     * @param width in pixels
     * @param height in pixels
     * @param arcWidth the horizontal diameter of the arc at the four corners
     * @param arcHeight the vertical diameter of the arc at the four corners
	 * @see Graphics#fillRoundRect(int, int, int, int, int, int)
	 */
	public void fillRoundRect(int x, int y, int width, int height, int arcWidth, int arcHeight)
	{
        RoundRectangle2D rr = new RoundRectangle2D.Double(x, y, width, height, arcWidth, arcHeight);
		fill(rr);
	}

    /**
	 * Draws the outline of a circle or ellipse that fits within the bounds of the
	 * specified rectangular  area with the current foreground color and stroke style from
	 * the graphic context.
	 * @param x the origin <i>x</i> coordinate
	 * @param y the origin <i>y</i> coordinate
	 * @param width in pixels
	 * @param height in pixels
	 * @see Graphics#drawOval(int, int, int, int)
	 */
	public void drawOval(int x, int y, int width, int height)
	{
        Ellipse2D e = new Ellipse2D.Double(x, y, width, height);
		draw(e);
	}

	/**
	 * Paints the center of a circle or ellipse that fits within the bounds of the
	 * specified rectangular area with the current paint style from the graphic context.
	 * @param x the origin <i>x</i> coordinate
	 * @param y the origin <i>y</i> coordinate
	 * @param width in pixels
	 * @param height in pixels
	 */
	public void fillOval(int x, int y, int width, int height)
	{
        Ellipse2D e = new Ellipse2D.Double(x, y, width, height);
		fill(e);
	}

	/**
	 * Draws the outline of an arc that fits within the bounds of the specified rectangular area with the
	 * current foreground color and stroke style of the graphic context.
	 * <p>
	 * The angles are specified relative to the non-square extents of
     * the bounding rectangle such that 45 degrees always falls on the
     * line from the center of the ellipse to the upper right corner of
     * the bounding rectangle.
	 * </p>
     * @param x the origin <i>x</i> co-ordinate
     * @param y the origin <i>y</i> co-ordinate
     * @param width the width of the arc to be drawn.
     * @param height the height of the arc to be drawn.
     * @param startAngle the beginning angle.
     * @param arcAngle the angular extent of the arc, relative to the start angle.
	 * @see Graphics#drawArc(int, int, int, int, int, int)
	 */
	public void drawArc(int x, int y, int width, int height, int startAngle, int arcAngle)
	{
		Arc2D a = new Arc2D.Double(x,y,width, height, startAngle, arcAngle, Arc2D.OPEN);
		draw(a);
	}

	/**
	 * Fills the center of an arc that fits within the bounds of the specified rectangular area with the
	 * current paint style of the graphic context.
     * @param x the <i>x</i> coordinate of the upper-left corner of the arc to be filled.
     * @param y the <i>y</i>  coordinate of the upper-left corner of the arc to be filled.
     * @param width the width of the arc to be filled.
     * @param height the height of the arc to be filled.
     * @param startAngle the beginning angle.
     * @param arcAngle the angular extent of the arc,relative to the start angle.
	 * @see Graphics#fillArc(int, int, int, int, int, int)
	 */
	public void fillArc(int x, int y, int width, int height, int startAngle, int arcAngle)
	{
        Arc2D a = new Arc2D.Double(x,y,width, height, startAngle, arcAngle, Arc2D.PIE);
		fill(a);
	}

	/**
	 * Draws a sequence of connected lines defined by arrays of <i>x</i> and <i>y</i> coordinates.
     * Each pair of (<i>x</i>, <i>y</i>) coordinates defines a point.
     * The figure is not closed if the first point differs from the last point.
	 * @param xPoints an array of <i>x</i> points
     * @param yPoints an array of <i>y</i> points
     * @param nPoints the total number of points
	 * @see Graphics#drawPolyline(int[], int[], int)
	 */
	public void drawPolyline(int xPoints[], int yPoints[], int nPoints)
	{
        Polygon p = new Polygon(xPoints, yPoints, nPoints);
		draw(p);
	}

	/**
	 * Draws a closed polygon defined by arrays of <i>x</i> and <i>y</i> coordinates with the current
	 * foreground color and stroke style of the graphic context.
     * Each pair of (<i>x</i>, <i>y</i>) coordinates defines a point.
	 * @param xPoints an array of <i>x</i> points
     * @param yPoints an array of <i>y</i> points
     * @param nPoints the total number of points
	 * @see Graphics#drawPolygon(int[], int[], int)
	 */
	public void drawPolygon(int xPoints[], int yPoints[], int nPoints)
	{
        Polygon p = new Polygon(xPoints, yPoints, nPoints);
		draw(p);
	}

	/**
	 * Fills the center a closed polygon defined by arrays of <i>x</i> and <i>y</i> coordinates with
	 * the current paint style of the graphic context.
     * Each pair of (<i>x</i>, <i>y</i>) coordinates defines a point.
	 * @param xPoints an array of <i>x</i> points
     * @param yPoints an array of <i>y</i> points
     * @param nPoints the total number of points
	 * @see Graphics#fillPolygon(int[], int[], int)
	 */
	public void fillPolygon(int xPoints[], int yPoints[], int nPoints)
	{
		Polygon p = new Polygon(xPoints, yPoints, nPoints);
		fill(p);
	}

	/**
	 * <b style="color:orange">NOT YET IMPLEMENTED</b>
	 * @param img
	 * @param x
	 * @param y
	 * @param observer
	 * @return
	 */
	public boolean drawImage(Image img, int x, int y, ImageObserver observer)
	{
		//TODO: Support drawImage
		throw new RuntimeException("drawImage(Image, int, int, ImageObserver) not yet supported");
		//return false;
	}

	/**
	 * <b style="color:orange">NOT YET IMPLEMENTED</b>
	 * @param image
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * @param observer
	 * @return
	 */
	public boolean drawImage(Image image, int x, int y, int width, int height, ImageObserver observer)
	{
		throw new RuntimeException("drawImage(Image, int, int, int, int, ImageObserver) not yet supported");
	}


	public boolean drawImage(Image img, int x, int y, Color bgcolor, ImageObserver observer)
	{
		 return drawImage(img, x, y, img.getWidth(null), img.getHeight(null),
                         bgcolor, observer);
	}


	public boolean drawImage(Image img, int x, int y, int width, int height, Color bgcolor, ImageObserver observer)
	{
		Paint paint = graphicContext.getPaint();
        graphicContext.setPaint(bgcolor);
        fillRect(x, y, width, height);
        graphicContext.setPaint(paint);
        drawImage(img, x, y, width, height, observer);

        return true;
	}


	public boolean drawImage(Image img, int dx1, int dy1, int dx2, int dy2, int sx1, int sy1, int sx2, int sy2,
							 ImageObserver observer)
	{
		BufferedImage src = new BufferedImage(img.getWidth(null), img.getHeight(null), BufferedImage.TYPE_INT_ARGB);
        Graphics2D g = src.createGraphics();
        g.drawImage(img, 0, 0, null);
        g.dispose();

        src = src.getSubimage(sx1, sy1, sx2-sx1, sy2-sy1);

        return drawImage(src, dx1, dy1, dx2-dx1, dy2-dy1, observer);
	}


	public boolean drawImage(Image img, int dx1, int dy1, int dx2, int dy2, int sx1, int sy1, int sx2, int sy2,
							 Color bgcolor, ImageObserver observer)
	{
		Paint paint = graphicContext.getPaint();
        graphicContext.setPaint(bgcolor);
        fillRect(dx1, dy1, dx2-dx1, dy2-dy1);
        graphicContext.setPaint(paint);
        return drawImage(img, dx1, dy1, dx2, dy2, sx1, sy1, sx2, sy2, observer);
	}

	/**
	 * Disposes of this graphics context and releases any system resources that it is using.
     * A <code>Graphics2D</code> object cannot be used after <code>dispose</code>has been called.
	 */
	public void dispose()
	{
        graphicContext = null;
	}

	protected GraphicContext graphicContext;
}
