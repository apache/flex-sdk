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

package com.adobe.internal.fxg.swf;

import com.adobe.fxg.FXGVersion;
import com.adobe.internal.fxg.dom.ScalableGradientNode;
import com.adobe.internal.fxg.dom.fills.BitmapFillNode;
import com.adobe.internal.fxg.dom.transforms.MatrixNode;
import com.adobe.internal.fxg.dom.types.FillMode;
import com.adobe.internal.fxg.types.FXGMatrix;

import flash.swf.SwfConstants;
import flash.swf.types.CXFormWithAlpha;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.tags.DefineBits;


/**
 * Utilities to help create basic SWF data types.
 * 
 * @author Peter Farland
 * @author Kaushal Kantawala
 * @author Sujata Das
 */
public class TypeHelper
{
	
	/** The Constant GRADIENT_DIMENSION. */
	public static final double GRADIENT_DIMENSION = 1638.4;
	
    /**
     * Creates a SWF Rect from double precision coordinate pairs (in pixels)
     * that specify the top left corner (minX, minY) and the bottom right corner
     * (maxX, maxY). The values are converted into twips (1/20th of pixel) and
     * rounded to an integer as required by the SWF format.
     * 
     * @param minX The x-coordinate of the top left corner of the rectangle.
     * @param minY The y-coordinate of the top left corner of the rectangle.
     * @param maxX The x-coordinate of the bottom right corner of the rectangle.
     * @param maxY The y-coordinate of the bottom right corner of the rectangle.
     * @return A SWF Rect type representing the implied rectangle.
     */
    public static Rect rect(double minX, double minY, double maxX, double maxY)
    {
        Rect rect = new Rect();
        rect.xMin = (int)(minX * SwfConstants.TWIPS_PER_PIXEL);
        rect.yMin = (int)(minY * SwfConstants.TWIPS_PER_PIXEL);
        rect.xMax = (int)(maxX * SwfConstants.TWIPS_PER_PIXEL);
        rect.yMax = (int)(maxY * SwfConstants.TWIPS_PER_PIXEL);
        return rect;
    }

    /**
     * Creates a SWF Rect from double precision width and height (in pixels)
     * that imply the top left corner (0.0, 0.0) and the bottom right corner
     * (width, height). The values are converted into twips (1/20th of pixel)
     * and rounded to an integer as required by the SWF format.
     * 
     * @param width The width of the rectangle in pixels.
     * @param height The height of the rectangle in pixels.
     * @return A SWF Rect type representing the implied rectangle.
     */
    public static Rect rect(double width, double height)
    {
        Rect rect = new Rect();
        rect.xMax = (int)(width * SwfConstants.TWIPS_PER_PIXEL);
        rect.yMax = (int)(height * SwfConstants.TWIPS_PER_PIXEL);
        return rect;
    }

    /**
     * Method to generate a transform matrix for the radial gradient strokes and
     * fills. First the translation and scaling is applied and later the
     * rotation is applied. The scaling applied is the user specified value or
     * in its absence the dimensions of the geometry. This is multiplied by the
     * quotient of the number or twips per pixel and the number of twips on the
     * screen in a given orientation to get the correct scale fraction.
     * 
     * @param gradient the gradient
     * @param pathBounds the path bounds
     * 
     * @return a SWF Matrix to apply for a radial gradient.
     */
    public static Matrix radialGradientMatrix(ScalableGradientNode gradient, Rect pathBounds)
    {
        //support for node matrix 
        MatrixNode mtxNode = gradient.getMatrixNode();
        if (mtxNode != null)
        {
            double tx = mtxNode.tx;
            double ty = mtxNode.ty;
            FXGMatrix fxgMtx = new FXGMatrix(mtxNode.a, mtxNode.b, mtxNode.c, mtxNode.d, 0, 0);
            fxgMtx.scale(SwfConstants.TWIPS_PER_PIXEL/(float)SwfConstants.GRADIENT_SQUARE, SwfConstants.TWIPS_PER_PIXEL/(float)SwfConstants.GRADIENT_SQUARE);
            fxgMtx.translate(tx, ty);
            return fxgMtx.toSWFMatrix();
        }             
          
        double w = !Double.isNaN(gradient.getScaleX()) ? gradient.getScaleX()*SwfConstants.TWIPS_PER_PIXEL : pathBounds.getWidth();
        double h = !Double.isNaN(gradient.getScaleY()) ? gradient.getScaleY()*SwfConstants.TWIPS_PER_PIXEL: pathBounds.getHeight();
        double tx = (!Double.isNaN(gradient.getX()) ? gradient.getX() : (pathBounds.xMax + pathBounds.xMin) / (2.0*SwfConstants.TWIPS_PER_PIXEL));
        double ty = (!Double.isNaN(gradient.getY()) ? gradient.getY() :  (pathBounds.yMax + pathBounds.yMin) / (2.0*SwfConstants.TWIPS_PER_PIXEL));
            
        FXGMatrix matrix = new FXGMatrix();
        matrix.scale(w/SwfConstants.GRADIENT_SQUARE, h/SwfConstants.GRADIENT_SQUARE);
        if (!Double.isNaN(gradient.getRotation()) && (gradient.getRotation() != 0))
            matrix.rotate(gradient.getRotation());
        matrix.translate(tx, ty);
        
        return matrix.toSWFMatrix(); 
    }

    /**
     * Method to generate a transform matrix for the linear gradient strokes and
     * fills. First the translation and scaling is applied and later the
     * rotation is applied. The scaling applied is the user specified value or
     * in its absence the dimensions of the geometry. This is multiplied by the
     * quotient of the number or twips per pixel and the number of twips on the
     * screen in a given orientation to get the correct scale fraction.
     * 
     * @param gradient the gradient
     * @param pathBounds the path bounds
     * 
     * @return a SWF Matrix to apply for a linear gradient.
     */
    public static Matrix linearGradientMatrix(ScalableGradientNode gradient, Rect pathBounds) 
    {
 
        FXGMatrix matrix = new FXGMatrix();

        //support for node matrix 
        MatrixNode mtxNode = gradient.getMatrixNode();
        if (mtxNode != null)
        {
            matrix.translate(GRADIENT_DIMENSION/2.0, GRADIENT_DIMENSION/2.0);
            matrix.scale(1.0/GRADIENT_DIMENSION, 1.0/GRADIENT_DIMENSION);
            FXGMatrix nodeMatrix = new FXGMatrix(mtxNode);
            matrix.concat(nodeMatrix);
            return matrix.toSWFMatrix();
        }

        double width = (pathBounds.xMax - pathBounds.xMin) / (double)SwfConstants.TWIPS_PER_PIXEL; 
        double height = (pathBounds.yMax - pathBounds.yMin) / (double)SwfConstants.TWIPS_PER_PIXEL; 
        double scaleX = gradient.getScaleX();
        double rotation = gradient.getRotation();
        double tx = gradient.getX();
        double ty = gradient.getY();

        if (Double.isNaN(scaleX))
        {
            // Figure out the two sides
            if (rotation % 90 != 0)
            {           
                // Normalize angles with absolute value > 360 
                double normalizedAngle = rotation % 360;
                // Normalize negative angles
                if (normalizedAngle < 0)
                    normalizedAngle += 360;
                
                // Angles wrap at 180
                normalizedAngle %= 180;
                
                // Angles > 90 get mirrored
                if (normalizedAngle > 90)
                    normalizedAngle = 180 - normalizedAngle;
                
                double side = width;
                // Get the hypotenuse of the largest triangle that can fit in the bounds
                double hypotenuse = Math.sqrt(width * width + height * height);
                // Get the angle of that largest triangle
                double hypotenuseAngle =  Math.acos(width / hypotenuse) * 180 / Math.PI;
                
                // If the angle is larger than the hypotenuse angle, then use the height 
                // as the adjacent side of the triangle
                if (normalizedAngle > hypotenuseAngle)
                {
                    normalizedAngle = 90 - normalizedAngle;
                    side = height;
                }
                
                // Solve for the hypotenuse given an adjacent side and an angle. 
                scaleX = side / Math.cos(normalizedAngle / 180 * Math.PI);
            }
            else 
            {
                // Use either width or height based on the rotation
                scaleX = (rotation % 180) == 0 ? width : height;
            }
        } 
       
        // If only x or y is defined, force the other to be set to 0
        if (!Double.isNaN(tx) && Double.isNaN(ty))
            ty = 0;
        if (Double.isNaN(tx) && !Double.isNaN(ty))
            tx = 0;
        
        // If x and y are specified, then move the gradient so that the
        // top left corner is at 0,0
        if (!Double.isNaN(tx) && !Double.isNaN(ty))
            matrix.translate( SwfConstants.GRADIENT_SQUARE/(2.0*SwfConstants.TWIPS_PER_PIXEL), SwfConstants.GRADIENT_SQUARE/(2.0*SwfConstants.TWIPS_PER_PIXEL));
             
        // Force the scaleX to a minimum of 2. Values of 0 or 1 have undesired behavior 
        if (Math.abs(scaleX) < 2)
            scaleX = (scaleX  < 0) ? -2 : 2;
       
        // Scale the gradient in the x direction. The natural size is 1638.4px. No need
        // to scale the y direction because it is infinite
        scaleX = (scaleX*SwfConstants.TWIPS_PER_PIXEL)/ SwfConstants.GRADIENT_SQUARE;
        matrix.scale(scaleX, 1);
        
        if (!Double.isNaN(rotation)) 
            matrix.rotate(rotation);
        
        if (Double.isNaN(tx))
            tx = width / 2.0 + pathBounds.xMin/(double)SwfConstants.TWIPS_PER_PIXEL;
        if (Double.isNaN(ty))
            ty = height / 2.0 + + pathBounds.yMin/(double)SwfConstants.TWIPS_PER_PIXEL;
        matrix.translate(tx, ty); 
        
        return matrix.toSWFMatrix();
        
    }

    
    /**
     * Get Bitmap fill matrix.
     * 
     * @param fill the fill
     * @param img the img
     * @param pathBounds the path bounds
     * 
     * @return the fXG matrix
     */
    public static FXGMatrix bitmapFillMatrix(BitmapFillNode fill, DefineBits img, Rect pathBounds)
    {
        
        MatrixNode mtxNode = fill.matrix;
        if (mtxNode != null)
        {
            double tx = mtxNode.tx;
            double ty = mtxNode.ty;
            FXGMatrix fxgMtx = new FXGMatrix(mtxNode.a, mtxNode.b, mtxNode.c, mtxNode.d, 0, 0);
            fxgMtx.scale(SwfConstants.TWIPS_PER_PIXEL, SwfConstants.TWIPS_PER_PIXEL);
            fxgMtx.translate(tx, ty);
            return fxgMtx;
        }

        FXGMatrix matrix = new FXGMatrix();
        double tx;
        double ty;
        double scaleX;
        double scaleY;
        if ((fill.getFileVersion() != FXGVersion.v1_0) && (fill.fillMode.equals(FillMode.SCALE)))
        {
        	tx = (Double.isNaN(fill.x)) ? pathBounds.xMin/(double)SwfConstants.TWIPS_PER_PIXEL : fill.x;
        	ty = (Double.isNaN(fill.y)) ? pathBounds.yMin/(double)SwfConstants.TWIPS_PER_PIXEL : fill.y;
        	scaleX = (Double.isNaN(fill.scaleX)) ? (pathBounds.getWidth()/(double) img.width) : 
        											SwfConstants.TWIPS_PER_PIXEL * fill.scaleX;
        	scaleY = (Double.isNaN(fill.scaleY)) ? (pathBounds.getHeight()/(double) img.height) :
        											SwfConstants.TWIPS_PER_PIXEL * fill.scaleY;
        }
        else
        {
        	tx = (Double.isNaN(fill.x)) ? pathBounds.xMin/(double)SwfConstants.TWIPS_PER_PIXEL : fill.x;
        	ty = (Double.isNaN(fill.y)) ? pathBounds.yMin/(double)SwfConstants.TWIPS_PER_PIXEL : fill.y;
        	scaleX = (Double.isNaN(fill.scaleX)) ? SwfConstants.TWIPS_PER_PIXEL : SwfConstants.TWIPS_PER_PIXEL * fill.scaleX;
        	scaleY = (Double.isNaN(fill.scaleY)) ? SwfConstants.TWIPS_PER_PIXEL : SwfConstants.TWIPS_PER_PIXEL * fill.scaleY;   	
        }
    	double angle = fill.rotation;
    	while (angle < 0)
    		angle += 360;
    	angle %= 360;
        matrix.scale(scaleX, scaleY);
        matrix.rotate(angle);
        matrix.translate(tx, ty);

        return matrix;
        
    }

    /**
     * Creates a SWF CXFormWithAlpha type for the common scenario where only an
     * alpha multiplier has been specified. The double value is converted into
     * an 8.8 fixed integer as required by the SWF format.
     * 
     * @param alphaMultiplier The alpha multiplier value specified as a double
     *        in the range 0.0 to 1.0 (inclusive).
     * @return a SWF CXFormWithAlpha value for the specified alpha multiplier.
     */
    public static CXFormWithAlpha cxFormWithAlpha(double alphaMultiplier)
    {
        CXFormWithAlpha c = new CXFormWithAlpha();
        c.hasMult = true;
        c.alphaMultTerm = fixed8(alphaMultiplier);
        return c;
    }

    /**
     * Creates a SWF CXFormWithAlpha type for the given double precision values
     * for ARGB multipliers and offsets. The multiplier values are converted
     * into 8.8 fixed integers as required by the SWF format. The offset values
     * are converted into integers in the range 0 to 255.
     * 
     * @param alphaMultiplier - alpha channel multiplier
     * @param redMultiplier - red channel multiplier
     * @param greenMultiplier - green channel multiplier
     * @param blueMultiplier - blue channel multiplier
     * @param alphaOffset - alpha channel offset value in the range -255.0 to 255.0.
     * @param redOffset - red channel offset value in the range -255.0 to 255.0.
     * @param greenOffset - green channel offset value in the range -255.0 to 255.0.
     * @param blueOffset - blue channel offset value in the range -255.0 to 255.0.
     * @return a SWF CXFormWithAlpha value for the specified multipliers and
     *         offsets.
     */
    public static CXFormWithAlpha cxFormWithAlpha(double alphaMultiplier,
            double redMultiplier, double greenMultiplier,
            double blueMultiplier, double alphaOffset, double redOffset,
            double greenOffset, double blueOffset)
    {
        CXFormWithAlpha c = new CXFormWithAlpha();
        c.alphaMultTerm = fixed8(alphaMultiplier);
        c.redMultTerm = fixed8(redMultiplier);
        c.greenMultTerm = fixed8(greenMultiplier);
        c.blueMultTerm = fixed8(blueMultiplier);
        c.alphaAddTerm = (int)(alphaOffset);
        c.redAddTerm = (int)(redOffset);
        c.greenAddTerm = (int)(greenOffset);
        c.blueAddTerm = (int)(blueOffset);

        if (c.alphaAddTerm > 0 || c.redAddTerm > 0 || c.greenAddTerm > 0 || c.blueAddTerm > 0)
            c.hasAdd = true;

        if (c.alphaMultTerm > 0 || c.redMultTerm > 0 || c.greenMultTerm > 0 || c.blueMultTerm > 0)
            c.hasMult = true;

        return c;
    }

    /**
     * Converts a gradient ratio specified as a double in the range 0.0 to 1.0
     * to an integer in the range required by the SWF format between 0 and 255.
     * 
     * @param ratio A gradient entry ratio between 0.0 and 1.0.
     * @return A SWF gradient ratio ration between 0 and 255.
     */
    public static int gradientRatio(double ratio)
    {
        return (int)StrictMath.rint(ratio * 255);
    }

    /**
     * Adds alpha channel information to an RGB integer (in the highest 8 bits
     * of the 32 bit integer) to create an ARGB integer as required by the SWF
     * format.
     * 
     * @param color An RGB color value specified as an int.
     * @param alpha The alpha channel specified as a double in the range 0.0 to
     *        1.0.
     * @return An ARGB color value as an int.
     */
    public static int colorARGB(int color, double alpha)
    {
        int rgb = color & 0x00FFFFFF;
        int a = (int)StrictMath.rint(alpha * 255);
        int argb = rgb | (a << 24);
        return argb;
    }

    /**
     * Converts a double value into a 16.16 fixed integer required by some types
     * in the SWF format.
     * 
     * @param value the value
     * 
     * @return the int
     */
    public static int fixed(double value)
    {
        return (int)(value * SwfConstants.FIXED_POINT_MULTIPLE);
    }

    /**
     * Converts a double value into a 8.8 fixed integer required by some types
     * in the SWF format.
     * 
     * @param value the value
     * 
     * @return the int
     */
    public static int fixed8(double value)
    {
        return (int)(value * SwfConstants.FIXED_POINT_MULTIPLE_8) & 0xFFFF;
    }
}
