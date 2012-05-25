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

import flash.swf.tags.DefineShape;
import flash.swf.tags.PlaceObject;
import flash.swf.tags.DefineSprite;
import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineBitsLossless;
import flash.swf.builder.tags.DefineShapeBuilder;
import flash.swf.builder.tags.DefineBitsLosslessBuilder;
import flash.swf.builder.tags.DefineBitsBuilder;
import flash.swf.builder.tags.ImageShapeBuilder;
import flash.swf.builder.types.MatrixBuilder;
import flash.swf.types.TagList;
import flash.swf.types.Rect;
import flash.swf.types.Matrix;
import flash.swf.Tag;
import flash.graphics.images.LosslessImage;
import flash.graphics.images.JPEGImage;

import java.awt.Shape;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.Paint;
import java.awt.GradientPaint;
import java.awt.image.ImageObserver;
import java.awt.geom.AffineTransform;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.io.InputStream;
import java.io.IOException;

/**
 * A SWF specific implementation of Java2D's <code>Graphics2D</code>
 * API. Calls to this class are converted into a <code>TagList</code>
 * that can be used to construct a SWF Sprite.
 *
 * @author Peter Farland
 */
public class SpriteGraphics2D extends AbstractGraphics2D
{
	/**
	 * Constructor.
	 * Initializes a new GraphicContext and TagList.
	 *
	 * @param width
	 * @param height
	 */
	public SpriteGraphics2D(int width, int height)
	{
		super(new GraphicContext(width, height));
		this.width = width;
		this.height = height;
		init();
	}

	/**
	 * Optimized Constructor.
	 * Initializes a smaller GraphicContext and TagList, without FontMetrics support.
	 */
	public SpriteGraphics2D()
	{
		super(new GraphicContext());
		init();
	}

	private void init()
	{
		defineTags = new TagList();
		graphicContext.validateTransformStack();
		bounds = new Rect();
	}

	/**
	 * Private Constructor - used by create().
	 * @param swf2d
	 * @see #create()
	 */
	private SpriteGraphics2D(SpriteGraphics2D swf2d)
	{
		super((GraphicContext)swf2d.graphicContext.clone());
		defineTags = new TagList();
	}

	/**
	 * Draws only the outline of an AWT Shape in SWF vectors using the settings of the
	 * current graphics context and places it on the SWF display list. The current
	 * stroke and paint colors are used to render the shape.
	 * @param shape the shape to be drawn
	 * @see java.awt.Graphics2D#draw(java.awt.Shape)
	 */
	public void draw(Shape shape)
	{
		defineShape(shape, true, false);
	}

	/**
	 * Draws only the center of a closed AWT shape in SWF vectors using the settings of the
	 * current graphic context and places it on the SWF display list. The current paint
	 * is used to render the shape.
	 * @param shape
	 * @see java.awt.Graphics2D#fill(java.awt.Shape)
	 */
	public void fill(Shape shape)
	{
		defineShape(shape, false, true);
	}

	/**
	 * This method converts an AWT Shape into a SWF Shape and creates a DefineShape3 instance
	 * with an accompanying PlaceObject2 instance.
	 * <p>
	 * Two non-standard operations are performed to work around unavoidable issues. The first
	 * is to apply the current AffineTransform before rendering and moving the drawing pen
	 * origin to the first move command's location. The shape is correctly translated
	 * to its intended location on the client by using the PlaceObject2's matrix.
	 * </p>
	 * <p>
	 * The second issue is to deal with the incompatibility of SVGs viewport dimensions and
	 * SWF Sprite auto-scaling. We have to keep track of the minimum area required to contain
	 * the sprites manually, as using the viewport dimensions will produce unexpected scaling
	 * for developers.
	 * </p>
	 * @param shape
	 * @param draw
	 * @param fill
	 */
	private void defineShape(Shape shape, boolean draw, boolean fill)
	{
		Point2D oldPen = null;
		boolean isGradient = false;

		if (fill && isGradientFill(graphicContext.getPaint()))
			isGradient = true;

		if (isGradient)
		{
			shape = graphicContext.getTransform().createTransformedShape(shape);
			oldPen = graphicContext.setPen(getShapeStart(shape));
		}

		DefineShapeBuilder builder = new DefineShapeBuilder(shape, graphicContext, draw, fill);

		DefineShape ds3 = (DefineShape)builder.build();
		defineTags.defineShape3(ds3);

		Matrix matrix;

		if (isGradient)
		{
			double originX = graphicContext.getPen().getX();
			double originY = graphicContext.getPen().getY();
			matrix = MatrixBuilder.getTranslateInstance(originX, originY);
		}
		else
		{
		 	matrix = MatrixBuilder.build(graphicContext.getTransform());
		}

		applyBounds(ds3.bounds.xMin + matrix.translateX,
				ds3.bounds.yMin + matrix.translateY,
				ds3.bounds.xMax + matrix.translateX,
				ds3.bounds.yMax + matrix.translateY);

		PlaceObject po2 = new PlaceObject(Tag.stagPlaceObject2);
		po2.setMatrix(matrix);
		po2.setRef(ds3);
        po2.depth = depth++;

		if (isGradient)
			graphicContext.setPen(oldPen);

		defineTags.placeObject2(po2);
	}

	/**
	 * <b style="color:orange">NOT YET IMPLEMENTED AS DEFINED BELOW, CURRENTLY USING drawStringAsShape()</b><br />
	 * Renders the text specified as a series of SWF character glyphs,
	 * using the current graphic context to control anti-aliasing and color.
	 * Unique glyphs are stored in a SWF font definition, and the defined text
	 * references this by index.
	 * <p>
	 * The baseline of the first character is at position (<i>x</i>, <i>y</i>)
	 * in the User Space.
	 * </p>
	 * @param str the text to be rendered
	 * @param x baseline x co-ordinate
	 * @param y baseline y co-ordinate
	 * @see java.awt.Graphics2D#drawString(java.lang.String, float, float)
	 */
	public void drawString(String str, float x, float y)
	{
		drawStringAsShape(str, x, y);
	}

	public void drawString(String str, int x, int y)
	{
		super.drawString(str, x, y);
	}

	public boolean drawImage(Image image, AffineTransform at, ImageObserver obs)
	{
		if (image != null)
		{
		    LosslessImage losslessImage = new LosslessImage(image);
		    int width = losslessImage.getWidth();
		    int height = losslessImage.getHeight();
			DefineBitsLossless defineBits = DefineBitsLosslessBuilder.build(losslessImage.getPixels(), width, height);
			defineTags.defineBitsLossless2(defineBits);

			DefineShape ds3 = ImageShapeBuilder.buildImage(defineBits, defineBits.width, defineBits.height);
			defineTags.defineShape3(ds3);
			applyBounds(ds3.bounds.xMin, ds3.bounds.yMin, ds3.bounds.xMax, ds3.bounds.yMax);

			PlaceObject po2 = new PlaceObject(Tag.stagPlaceObject2);
			po2.setMatrix(MatrixBuilder.build(at));
			po2.setRef(ds3);
			po2.depth = depth++;

			defineTags.placeObject2(po2);
		}

		return false;
	}

	public boolean drawImage(Image image, int x, int y, ImageObserver observer)
	{
		AffineTransform at = graphicContext.getTransform();
		at.translate(x, y);
		return drawImage(image, at, observer);
	}

	public boolean drawImage(Image image, int x, int y, int width, int height, ImageObserver observer)
	{
		AffineTransform at = graphicContext.getTransform();
		at.translate(x, y);
		double sx = (double)width/(double)image.getWidth(observer);
		double sy = (double)height/(double)image.getHeight(observer);
		at.scale(sx, sy);
		return drawImage(image, at, observer);
	}

    /**
	 * Converts an AWT image into a SWF <code>DefineBitsLossless</code> tag and adds it to
	 * the Sprite <code>TagList</code> context.
	 *
	 * @param image - an AWT bitmapped image
	 * @param name - name to use in the corresponding <code>PlaceObject</code> tag
	 */
	public void drawNamedImage(Image image, String name)
	{
		if (image != null)
		{
            LosslessImage losslessImage = new LosslessImage(image);
            int width = losslessImage.getWidth();
            int height = losslessImage.getHeight();
            DefineBitsLossless defineBits = DefineBitsLosslessBuilder.build(losslessImage.getPixels(), width, height);
			defineTags.defineBitsLossless2(defineBits);

			DefineShape ds3 = ImageShapeBuilder.buildImage(defineBits, defineBits.width, defineBits.height);
			defineTags.defineShape3(ds3);
            applyBounds(ds3.bounds.xMin, ds3.bounds.yMin, ds3.bounds.xMax, ds3.bounds.yMax);

			PlaceObject po2 = new PlaceObject(ds3, depth++);
            po2.setMatrix(MatrixBuilder.build(graphicContext.getTransform()));
            po2.setName(name);

			defineTags.placeObject2(po2);
		}
	}


	/**
	 * Converts a JPEG binary input stream into a SWF <code>DefineBits</code> tag and adds it
	 * to the Sprite <code>TagList</code> context.
	 *
	 * @param inputStream - the raw JPEG binary stream
	 * @param length - number of bits to read from the stream
	 * @param width - width of the JPEG image in pixels
	 * @param height - height of the JPEG image in pixels
	 * @param name - name to use in the corresponding <code>PlaceObject</code> tag
	 * @throws IOException
	 */
	public void drawJPEG(InputStream inputStream, int length, int width, int height, String name) throws IOException
	{
        if (inputStream != null)
		{
			try
			{
                JPEGImage image = new JPEGImage(inputStream, length);
                DefineBits defineBits = new DefineBits(Tag.stagDefineBitsJPEG2);
                defineBits.data = image.getData();
				defineTags.defineBitsJPEG2(defineBits);

				DefineShape ds3 = ImageShapeBuilder.buildImage(defineBits, width, height);
				defineTags.defineShape3(ds3);
				applyBounds(ds3.bounds.xMin, ds3.bounds.yMin, ds3.bounds.xMax, ds3.bounds.yMax);

                PlaceObject po2 = new PlaceObject(ds3, depth++);
                po2.setMatrix(MatrixBuilder.build(graphicContext.getTransform()));
                po2.setName(name);

				defineTags.placeObject2(po2);
			}
			finally
			{
				try
				{
					inputStream.close();
				}
				catch (IOException e)
				{
				}
			}
		}
	}

	/**
	 * Creates a new <code>Graphics</code> object that is a copy of
	 * this <code>SpriteGraphics2D</code> object.
	 * @return a copy of this Graphics2D instance
	 */
	public Graphics create()
	{
		return new SpriteGraphics2D(this);
	}

	public TagList getTags()
	{
		return defineTags;
	}

	public int getWidth()
	{
		return width;
	}

	public int getHeight()
	{
		return height;
	}

	public DefineSprite defineSprite(String name)
	{
		DefineSprite defineSprite = new DefineSprite();
		defineSprite.framecount = 1;
		defineSprite.tagList = defineTags;
		defineSprite.name = name;
		return defineSprite;
	}

	private static boolean isGradientFill(Paint paint)
	{
		return (paint != null
				&& (paint instanceof GradientPaint
						|| paint.getClass().getName().equals("org.apache.flex.forks.batik.ext.awt.MultipleGradientPaint")));
	}

	/**
	 * When trying to negate gradient dilution in filled SWF shapes, it is useful to
	 * know where the left most point of the physical shape as this can be used to change
	 * the drawing origin to minimize non-drawing move commands contributing to the
	 * shape bounds.
	 *
	 * @param shape
	 * @return Point2D the minimum x,y position of this shape's bounds.
	 */
	private static Point2D getShapeStart(Shape shape)
	{
		if (shape != null)
		{
			Rectangle2D bounds = shape.getBounds2D();
			return new Point2D.Double(bounds.getMinX(), bounds.getMinY());
		}

		return new Point2D.Double(0, 0);
	}

	private void applyBounds(int x1, int y1, int x2, int y2)
	{
		if (x1 < bounds.xMin) bounds.xMin = x1;
		if (y1 < bounds.yMin) bounds.yMin = y1;
		if (x1 > bounds.xMax) bounds.xMax = x1;
		if (y1 > bounds.yMax) bounds.yMax = y1;
		if (x2 < bounds.xMin) bounds.xMin = x2;
		if (y2 < bounds.yMin) bounds.yMin = y2;
		if (x2 > bounds.xMax) bounds.xMax = x2;
		if (y2 > bounds.yMax) bounds.yMax = y2;
	}

	public Rect getBounds()
	{
		return bounds;
	}

	protected TagList defineTags;
	protected int depth = 1;
	protected int width;
	protected int height;
	protected Rect bounds;
}
