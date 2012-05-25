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

package flash.swf.builder.types;

import flash.swf.types.FillStyle;
import flash.swf.types.GradRecord;
import flash.swf.types.Matrix;
import flash.swf.types.Gradient;
import flash.swf.tags.DefineBitsLossless;
import flash.swf.builder.tags.DefineBitsLosslessBuilder;
import flash.swf.SwfConstants;
import flash.swf.SwfUtils;
import flash.graphics.images.LosslessImage;

import java.awt.Paint;
import java.awt.Color;
import java.awt.GradientPaint;
import java.awt.TexturePaint;
import java.awt.Image;
import java.awt.geom.Point2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;

import org.apache.flex.forks.batik.ext.awt.LinearGradientPaint;
import org.apache.flex.forks.batik.ext.awt.RadialGradientPaint;

/**
 * This class is used to construct a FillStyle from a Paint,
 * Rectangle2D, and AffineTransform object.
 *
 * @author Peter Farland
 */
public final class FillStyleBuilder
{
	private FillStyleBuilder()
	{
	}

	/**
	 * Utility method to create an appropriate <code>FillStyle</code> from a <code>Paint</code>.
	 * @param paint an AWT <code>Paint</code> instance
	 * @param bounds - required for gradient ratio calculation
	 * @return a new <code>FillStyle</code> representing the given paint
	 */
	public static FillStyle build(Paint paint, Rectangle2D bounds, AffineTransform transform)
	{
		FillStyle fs = null;

		if (paint != null)
		{
			double width = bounds.getWidth();
			double height = bounds.getHeight();

			if (paint instanceof Color)
			{
				fs = new FillStyle(SwfUtils.colorToInt((Color)paint));
			}
			else if (paint instanceof GradientPaint)
			{
				GradientPaint gp = (GradientPaint)paint;
				AffineTransform gt = objectBoundingBoxTransform(transform.transform(gp.getPoint1(), null),
						transform.transform(gp.getPoint2(), null),
						width,
						height,
						width,
						height);
				fs = new FillStyle();
				fs.matrix = MatrixBuilder.build(gt);

				fs.type = FillStyle.FILL_LINEAR_GRADIENT;

                fs.gradient = new Gradient();
                fs.gradient.records = new GradRecord[2];
				fs.gradient.records[0] = new GradRecord(0, SwfUtils.colorToInt(gp.getColor1())); //from left
				fs.gradient.records[1] = new GradRecord(255,  SwfUtils.colorToInt(gp.getColor2())); //to right
			}
			else if (paint instanceof LinearGradientPaint)
			{
				LinearGradientPaint lgp = (LinearGradientPaint)paint;
                Point2D start = lgp.getStartPoint();
				Point2D end = lgp.getEndPoint();

				AffineTransform gt = objectBoundingBoxTransform(start, end, width, height, width, height);

				fs = new FillStyle();
				fs.matrix = MatrixBuilder.build(gt);

				Color[] colors = lgp.getColors();
				float[] ratios = lgp.getFractions();

				if (colors.length == 0 || colors.length != ratios.length) //Invalid fill so we skip
				{
					return null;
				}
				else if (colors.length == 1) //Solid fill
				{
					return new FillStyle(SwfUtils.colorToInt(colors[0]));
				}
				else
				{
					fs.type = FillStyle.FILL_LINEAR_GRADIENT;

					//Maximum of 8 gradient control points records
					int len = ratios.length;
					if (len > 8)
						len = 8;
                    fs.gradient = new Gradient();
                    fs.gradient.records = new GradRecord[len];

					for (int i = 0; i < len; i++)
					{
						fs.gradient.records[i] = new GradRecord((int)Math.rint(255 * ratios[i]), SwfUtils.colorToInt(colors[i]));
					}

				}
			}
			else if (paint instanceof RadialGradientPaint)
			{
				RadialGradientPaint rgp = (RadialGradientPaint)paint;

				//Note: Flash doesn't support the focal point of a radial gradient
				//Point2D cp = rgp.getCenterPoint();
				//Point2D fp = rgp.getFocusPoint();
				double diameter = rgp.getRadius() * 2.0;
				double outerX = diameter * rgp.getTransform().getScaleX();
				double outerY = diameter * rgp.getTransform().getScaleY();

				AffineTransform gt = objectBoundingBoxTransform(null, null, width, height, outerX, outerY);
				fs = new FillStyle();
				fs.matrix = MatrixBuilder.build(gt);

				fs.type = FillStyle.FILL_RADIAL_GRADIENT;

				Color[] colors = rgp.getColors();
				float[] ratios = rgp.getFractions();

                fs.gradient = new Gradient();
                fs.gradient.records = new GradRecord[ratios.length <= 8 ? ratios.length : 8];
				for (int i = 0; i < ratios.length && i < 8; i++)
				{
					fs.gradient.records[i] = new GradRecord((int)Math.rint(255 * ratios[i]), SwfUtils.colorToInt(colors[i]));
				}

			}
			else if (paint instanceof TexturePaint)
			{
				TexturePaint tp = (TexturePaint)paint;
				Image image = tp.getImage();

	            LosslessImage losslessImage = new LosslessImage(image);
	            int imageWidth = losslessImage.getWidth();
	            int imageHeight = losslessImage.getHeight();
	            DefineBitsLossless tag = DefineBitsLosslessBuilder.build(losslessImage.getPixels(), imageWidth, imageHeight);

				//Apply Twips Scale of 20 x 20
				AffineTransform at = new AffineTransform();
				at.setToScale(SwfConstants.TWIPS_PER_PIXEL, SwfConstants.TWIPS_PER_PIXEL);
				Matrix matrix = MatrixBuilder.build(at);

				fs = new FillStyle(FillStyle.FILL_BITS, matrix, tag);
			}

		}

		return fs;
	}


	/**
	 * TODO: These methods need to be called based on which of two gradient transform methods we're applying.
	 * In SVG, these are known as:
	 * - userSpaceOnUse - apply gradient transform and use gradient points directly
	 * - objectBoundingBox - use the width/height from the target object then apply gradient transform
	 */
	private static AffineTransform objectBoundingBoxTransform(Point2D gp1, Point2D gp2, double width, double height, double scaleWidth, double scaleHeight)
	{
		AffineTransform at = new AffineTransform();

		//Translate gradient to the center of the bounded geometry
		at.translate(width / 2, height / 2);

		//Scale to Gradient Square (in twips)
		at.scale((scaleWidth * SwfConstants.TWIPS_PER_PIXEL / SwfConstants.GRADIENT_SQUARE),
				(scaleHeight * SwfConstants.TWIPS_PER_PIXEL / SwfConstants.GRADIENT_SQUARE));

		//Rotate gradient to match geometry
		if (gp1 != null && gp2 != null && (gp2.getX() - gp1.getX()) != 0)
		{
			double mx = gp2.getX() - gp1.getX();
			double my = gp2.getY() - gp1.getY();
			double gradient = my / mx;
			double angle = Math.atan(gradient);

			/*
			Handle the "arctan" problem - get a standard angle so that it is positive within 360 degrees
			wrt the positive x-axis in a counter-clockwise direction
			*/
			if (mx < 0)
				angle += Math.PI;
			else if (my < 0)
				angle += (Math.PI * 2.0);

			if (angle != 0)
				at.rotate(angle);
		}

		return at;
	}

	/**
	 * TODO: These methods need to be called based on which of two gradient transform methods we're applying.
	 * In SVG, these are known as:
	 * - userSpaceOnUse - apply gradient transform and use gradient points directly
	 * - objectBoundingBox - use the width/height from the target object then apply gradient transform
	private static AffineTransform userSpaceOnUseTransform(Point2D gp1, Point2D gp2, AffineTransform gt)
	{
		double angle = 0.0;

		if (gt != null)
		{
			gp1 = gt.transform(gp1, null);
			gp2 = gt.transform(gp2, null);
		}

		//Rotate gradient to match geometry
		if (gp1 != null && gp2 != null && gp2.getX() - gp1.getX() != 0)
		{
			double mx = gp2.getX() - gp1.getX();
			double my = gp2.getY() - gp1.getY();
			double gradient = my / mx;
			angle = StrictMath.atan(gradient);

			//Handle the "arctan" problem - get a standard angle so that it is a positive value less than
			//360 degrees with respect to the positive x-axis (in a counter-clockwise direction).
			if (mx < 0)
				angle += StrictMath.PI;
			else if (my < 0)
				angle += (StrictMath.PI * 2.0);
		}

		double width = StrictMath.abs(gp2.getX() - gp1.getX());
		double height = StrictMath.abs(gp2.getY() - gp1.getY());

		AffineTransform at = new AffineTransform();

		//Translate gradient to the center of the bounded geometry
		at.translate(width / 2, height / 2);

		//Scale to Gradient Square (in twips)
		at.scale((width * SwfUtils.TWIPS_PER_PIXEL / SwfUtils.GRADIENT_SQUARE),
				(height * SwfUtils.TWIPS_PER_PIXEL / SwfUtils.GRADIENT_SQUARE));

        //Rotate if we have a significant angle
		if (angle != 0.0)
			at.rotate(angle);

		return at;
	}
	*/
}
