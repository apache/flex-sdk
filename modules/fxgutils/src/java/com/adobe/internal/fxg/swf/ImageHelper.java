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

import java.awt.Image;
import java.awt.image.PixelGrabber;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import com.adobe.fxg.FXGVersion;
import com.adobe.internal.fxg.dom.AbstractFXGNode;
import com.adobe.internal.fxg.dom.BitmapGraphicNode;
import com.adobe.internal.fxg.dom.FillNode;
import com.adobe.internal.fxg.dom.fills.BitmapFillNode;
import com.adobe.internal.fxg.dom.types.FillMode;

import flash.graphics.images.ImageUtil;
import flash.swf.SwfConstants;
import flash.swf.Tag;
import flash.swf.TagValues;
import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineBitsLossless;
import flash.swf.tags.DefineShape;
import flash.swf.types.FillStyle;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.types.ShapeRecord;
import flash.swf.types.ShapeWithStyle;
import flash.swf.types.StraightEdgeRecord;
import flash.swf.types.StyleChangeRecord;
import flash.util.FileUtils;

/**
 * Utilities to help create SWF DefineBits and DefineBitsLossess image tags.
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public class ImageHelper
{
    
    /** The Constant MIME_GIF. */
    public static final String MIME_GIF = "image/gif";
    
    /** The Constant MIME_JPEG. */
    public static final String MIME_JPEG = "image/jpeg";
    
    /** The Constant MIME_JPG. */
    public static final String MIME_JPG = "image/jpg";
    
    /** The Constant MIME_PNG. */
    public static final String MIME_PNG = "image/png";

    /**
     * Creates a rectangle for the given width and height as a DefineShape. The
     * shape is painted with a bitmap FillStyle with the given DefineBits
     * tag. 
     * 
     * @param tag The DefineBits tag encoding the image.
     * @param node The BitmapGraphicNode.
      * @return A rectangle of given width and height as a DefineShape with a
     * bitmap fill. 
     */
    public static DefineShape createShapeForImage(DefineBits tag, BitmapGraphicNode node)
    {
    	double width = node.width;
    	double height = node.height;
    	boolean repeat = node.repeat;
    	FillMode fillMode = node.fillMode;
    	FXGVersion fileVersion = node.getFileVersion();

        // Use default width/height information if none specified
        if (Double.isNaN(width))
            width = tag.width;

        if (Double.isNaN(height))
            height = tag.height;

        // Create Fill Style
        Matrix matrix = new Matrix();
        matrix.scaleX = (int)(SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.scaleY = (int)(SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.hasScale = true; // Apply runtime scale of 20x for twips
        
        FillStyle fs = null;
        if (fileVersion.equalTo(FXGVersion.v1_0))
        {
        	if (repeat)
        		fs = new FillStyle(FillStyle.FILL_BITS, matrix, tag);
        	else
        		fs = new FillStyle(FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP, matrix, tag);
        }
        else
        {
        	if (fillMode.equals(FillMode.REPEAT))
        	{
        		fs = new FillStyle(FillStyle.FILL_BITS, matrix, tag);
        	}
        	else if (fillMode.equals(FillMode.CLIP))
        	{
        		fs = new FillStyle(FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP, matrix, tag);
        	}
        	else if (fillMode.equals(FillMode.SCALE))
        	{
        		//override the scale for matrix
                matrix.scaleX = (int)StrictMath.rint((width*SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE)/(double)tag.width);
                matrix.scaleY = (int)StrictMath.rint((height*SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE)/(double)tag.height);
        		
        		//fill style does not matter much since the entire area is filled with bitmap
        		fs = new FillStyle(FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP, matrix, tag);
        	}
        }

        // Apply Fill Styles
        ShapeWithStyle sws = new ShapeWithStyle();
        sws.fillstyles = new ArrayList<FillStyle>(1);
        sws.fillstyles.add(fs);

        // Build Raw SWF Shape
        List<ShapeRecord> shapeRecords = ShapeHelper.rectangle(width, height);
        ShapeHelper.setStyles(shapeRecords, 0, 1, 0);
        sws.shapeRecords = shapeRecords;
        

        // Wrap up into a SWF DefineShape Tag
        DefineShape defineShape = new DefineShape(Tag.stagDefineShape4);
        defineShape.bounds = TypeHelper.rect(width, height);
        defineShape.edgeBounds = defineShape.bounds;
        defineShape.shapeWithStyle = sws;
        

        return defineShape;
    }
    
    /**
     * Determines whether the bitmap image should be clipped.
     * 
     * @param node The BitmapGraphicNode.
     * @param imageTag the image tag
     * 
     * @return boolean if bitmap should be clipped.
     */    
    public static boolean bitmapImageNeedsClipping(DefineBits imageTag, BitmapGraphicNode node)
    {
    	if (((node.getFileVersion().equalTo(FXGVersion.v1_0)) && !node.repeat) ||
    			(node.fillMode.equals(FillMode.CLIP)))
    	{
    		if ((imageTag.width < node.width) || (imageTag.height < node.height))
    			return true;
    	}
    	
    	return false;
    	
    }
    
    /**
     * Determines whether the bitmap fill mode is repeat. 
     * 
     * @param node The BitmapFillNode.
     * @return boolean if bitmap should repeat. 
     */    
    public static boolean bitmapFillModeIsRepeat(BitmapFillNode node)
    {
    	if (((node.getFileVersion().equalTo(FXGVersion.v1_0)) && node.repeat) ||
    			(node.fillMode.equals(FillMode.REPEAT)))
    	{
    		return true;
    	}
    	
    	return false;
    	
    }
 
    /**
     * Checks if bitmap fill is clipped.
     * 
     * @param fill the fill
     * 
     * @return true, if bitmap fill is clipped
     */
    public static boolean isBitmapFillWithClip(FillNode fill)
    {
        if (fill == null) 
    		return false;
    	
    	if (fill instanceof BitmapFillNode)
    	{
    		BitmapFillNode bFill = (BitmapFillNode) fill;
    		if (ImageHelper.bitmapFillModeIsRepeat(bFill))
    		{
    			return false;
    		}
    		else
    		{
    			if ((bFill.getFileVersion().equalTo(FXGVersion.v2_0)) && (bFill.fillMode == FillMode.SCALE))
    			{
    				if (Double.isNaN(bFill.scaleX) && Double.isNaN(bFill.scaleY) && 
    						Double.isNaN(bFill.x) && Double.isNaN(bFill.y) &&
    						(Double.isNaN(bFill.rotation) || Math.abs(bFill.rotation) < AbstractFXGNode.EPSILON) &&
    						bFill.matrix == null)
    					return false;
    				else
    					return true;
    			}
    			else
    			{
    				return true;
    			}
    		}    		
    		
    	}
    	return false;
    	
    }
    
    /**
     * Creates the define bits.
     * 
     * @param in the in
     * @param mimeType the mime type
     * 
     * @return the define bits
     * 
     * @throws IOException Signals that an I/O exception has occurred.
     */
    public static DefineBits createDefineBits(InputStream in, String mimeType) throws IOException
    {
        // TODO: Investigate faster mechanisms of getting image info and pixels
        byte[] bytes = FileUtils.toByteArray(in);
        Image image = ImageUtil.getImage(bytes);
        if (mimeType == null)
        {
            throw new IOException("Unsupported MIME type");
        }

        PixelGrabber pixelGrabber = null;
        try
        {
            pixelGrabber = ImageUtil.getPixelGrabber(image, null);
        }
        catch (Exception e)
        {
            throw new IOException("Error reading image");
        }

        int width = pixelGrabber.getWidth();
        int height = pixelGrabber.getHeight();

        // JPEG
        if (MIME_JPG.equals(mimeType) || MIME_JPEG.equals(mimeType))
        {
            DefineBits imageTag = new DefineBits(Tag.stagDefineBitsJPEG2);
            imageTag.data = bytes;
            imageTag.width = width;
            imageTag.height = height;
            return imageTag;
        }
        // PNG or GIF
        else if (MIME_PNG.equals(mimeType) || MIME_GIF.equals(mimeType))
        {
            int[] pixels = (int[])pixelGrabber.getPixels();
            DefineBitsLossless imageTag = createDefineBitsLossless(pixels, width, height);
            return imageTag;
        }
        else
        {
            throw new IOException("Unsupported MIME type: " + mimeType);
        }
    }

    /**
     * Creates the define bits lossless.
     * 
     * @param pixels the pixels
     * @param width the width
     * @param height the height
     * 
     * @return the define bits lossless
     */
    public static DefineBitsLossless createDefineBitsLossless(int[] pixels, int width, int height)
    {
        DefineBitsLossless defineBitsLossless = new DefineBitsLossless(TagValues.stagDefineBitsLossless2);
        defineBitsLossless.format = DefineBitsLossless.FORMAT_24_BIT_RGB;
        defineBitsLossless.width = width;
        defineBitsLossless.height = height;
        defineBitsLossless.data = new byte[pixels.length * 4];

        for (int i = 0; i < pixels.length; i++)
        {
            int offset = i * 4;
            int alpha = (pixels[i] >> 24) & 0xFF;
            defineBitsLossless.data[offset] = (byte)alpha;

            // Premultiply the alpha channel
            if (defineBitsLossless.data[offset] != 0)
            {
                int red = (pixels[i] >> 16) & 0xFF;
                defineBitsLossless.data[offset + 1] = (byte)((red * alpha) / 255);
                int green = (pixels[i] >> 8) & 0xFF;
                defineBitsLossless.data[offset + 2] = (byte)((green * alpha) / 255);
                int blue = pixels[i] & 0xFF;
                defineBitsLossless.data[offset + 3] = (byte)((blue * alpha) / 255);
            }
        }

        return defineBitsLossless;
    }

    /**
     * Create 9 sliced shape.
     * 
     * @param bitmap the bitmap
     * @param r the r
     * @param width the width
     * @param height the height
     * 
     * @return the define shape
     */
    public static DefineShape create9SlicedShape(DefineBits bitmap, Rect r, double width, double height)
    {
        // Use default width/height information if none specified
        if (Double.isNaN(width))
            width = bitmap.width;

        if (Double.isNaN(height))
            height = bitmap.height;

        int slt = r.xMin;
        int srt = r.xMax;
        int stt = r.yMin;
        int sbt = r.yMax;

        List<ShapeRecord> shapeRecords = new ArrayList<ShapeRecord>(50);
        ShapeWithStyle sws = new ShapeWithStyle();
        sws.fillstyles = new ArrayList<FillStyle>(9);
        sws.shapeRecords = shapeRecords;

        // Apply runtime scale of 20x for twips
        Matrix matrix = new Matrix();
        matrix.scaleX = (int)(SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.scaleY = (int)(SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.hasScale = true;

        // Create 9 identical fillstyles as a work around
        for (int i = 0; i < 9; i++)
        {
            FillStyle fs = new FillStyle(FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH, matrix, bitmap);
            sws.fillstyles.add(fs);
        }

        int dxa = slt;
        int dxb = srt - slt;
        int dxc = (int)(bitmap.width * SwfConstants.TWIPS_PER_PIXEL) - srt;

        int dya = stt;
        int dyb = sbt - stt;
        int dyc = (int)(bitmap.height * SwfConstants.TWIPS_PER_PIXEL) - sbt;

        // border
        shapeRecords.add(new StyleChangeRecord(0, dya, 0, 0, 1));
        shapeRecords.add(new StraightEdgeRecord(0, -dya));
        shapeRecords.add(new StraightEdgeRecord(dxa, 0));
        shapeRecords.add(new StyleChangeRecord(0, 0, 2));
        shapeRecords.add(new StraightEdgeRecord(dxb, 0));
        shapeRecords.add(new StyleChangeRecord(0, 0, 3));
        shapeRecords.add(new StraightEdgeRecord(dxc, 0));
        shapeRecords.add(new StraightEdgeRecord(0, dya));
        shapeRecords.add(new StyleChangeRecord(0, 0, 6));
        shapeRecords.add(new StraightEdgeRecord(0, dyb));
        shapeRecords.add(new StyleChangeRecord(0, 0 ,9));
        shapeRecords.add(new StraightEdgeRecord(0, dyc));
        shapeRecords.add(new StraightEdgeRecord(-dxc, 0));
        shapeRecords.add(new StyleChangeRecord(0, 0, 8));
        shapeRecords.add(new StraightEdgeRecord(-dxb, 0));
        shapeRecords.add(new StyleChangeRecord(0, 0, 7));
        shapeRecords.add(new StraightEdgeRecord(-dxa, 0));
        shapeRecords.add(new StraightEdgeRecord(0, -dyc));
        shapeRecords.add(new StyleChangeRecord(0, 0, 4));
        shapeRecords.add(new StraightEdgeRecord(0, -dyb));

        // down 1
        shapeRecords.add(new StyleChangeRecord(dxa, 0, 0, 2, 1));
        shapeRecords.add(new StraightEdgeRecord(0, dya));
        shapeRecords.add(new StyleChangeRecord(0, 5, 4));
        shapeRecords.add(new StraightEdgeRecord(0, dyb));
        shapeRecords.add(new StyleChangeRecord(0, 8, 7));
        shapeRecords.add(new StraightEdgeRecord(0, dyc));

        // down 2
        shapeRecords.add(new StyleChangeRecord(dxa + dxb, 0, 0, 3, 2));
        shapeRecords.add(new StraightEdgeRecord(0, dya));
        shapeRecords.add(new StyleChangeRecord(0, 6, 5));
        shapeRecords.add(new StraightEdgeRecord(0, dyb));
        shapeRecords.add(new StyleChangeRecord(0, 9, 8));
        shapeRecords.add(new StraightEdgeRecord(0, dyc));

        // right 1
        shapeRecords.add(new StyleChangeRecord(0, dya, 0, 1, 4));
        shapeRecords.add(new StraightEdgeRecord(dxa, 0));
        shapeRecords.add(new StyleChangeRecord(0, 2, 5));
        shapeRecords.add(new StraightEdgeRecord(dxb, 0));
        shapeRecords.add(new StyleChangeRecord(0, 3, 6));
        shapeRecords.add(new StraightEdgeRecord(dxc, 0));

        // right 2
        shapeRecords.add(new StyleChangeRecord(0, dya + dyb, 0, 4, 7));
        shapeRecords.add(new StraightEdgeRecord(dxa, 0));
        shapeRecords.add(new StyleChangeRecord(0, 5, 8));
        shapeRecords.add(new StraightEdgeRecord(dxb, 0));
        shapeRecords.add(new StyleChangeRecord(0, 6, 9));
        shapeRecords.add(new StraightEdgeRecord(dxc, 0));

        DefineShape shape = new DefineShape(TagValues.stagDefineShape4);
        shape.bounds = TypeHelper.rect(width, height);
        shape.edgeBounds = shape.bounds;
        shape.shapeWithStyle = sws;
        return shape;
    }

    /**
     * Guess mime type.
     * 
     * @param path the path
     * 
     * @return the string
     */
    public static String guessMimeType(String path)
    {
        if (path != null)
        {
            path = path.toLowerCase();
            if (path.endsWith(".png"))
                return MIME_PNG;
            if (path.endsWith(".gif"))
                return MIME_GIF;
            if (path.endsWith(".jpg"))
                return MIME_JPG;
            if (path.endsWith(".jpeg"))
                return MIME_JPEG;
        }

        return null;
    }
}
