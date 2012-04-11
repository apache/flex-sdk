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

package flash.swf.builder.tags;

import flash.swf.Tag;
import flash.swf.SwfConstants;
import flash.swf.builder.types.Point;
import flash.swf.builder.types.ShapeBuilder;
import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineShape;
import flash.swf.types.FillStyle;
import flash.swf.types.LineStyle;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.types.ShapeWithStyle;

import java.util.ArrayList;

/**
 * Simple utility class for building an Image as a Shape with a bitmap
 * fill style. This is a separate class to decouple image processing
 * from the main Shape/Graphics2D processing required by more
 * complicated SWF entities.
 *
 * @author Peter Farland
 */
public class ImageShapeBuilder
{
    private ImageShapeBuilder()
    {
    }

    public static DefineShape buildImage(DefineBits tag, int width, int height)
    {
        // Create Fill Style
        Matrix matrix = new Matrix();
        matrix.scaleX = (int)Math.rint(SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.scaleY = (int)Math.rint(SwfConstants.TWIPS_PER_PIXEL * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.hasScale = true; //Apply runtime scale of 20 (for twips)
        FillStyle fs = new FillStyle(FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP, matrix, tag);

        // Apply Fill Styles
        ShapeWithStyle sws = new ShapeWithStyle();
        sws.fillstyles = new ArrayList<FillStyle>();
        int fsIndex = sws.fillstyles.add(fs) ? sws.fillstyles.lastIndexOf(fs) + 1 : 0;
        sws.linestyles = new ArrayList<LineStyle>();

        // Build Raw SWF Shape
        ShapeBuilder builder = new ShapeBuilder(new Point());
        builder.setUseFillStyle0(true);
        builder.setCurrentFillStyle0(fsIndex);
        builder.move(0, 0);
        builder.straight(width, 0);
        builder.straight(width, height);
        builder.straight(0, height);
        builder.straight(0, 0);
        builder.correctRoundingErrors();
        sws.shapeRecords = builder.build().shapeRecords;

        // Wrap up into a SWF DefineShape Tag
        DefineShape defineShape = new DefineShape(Tag.stagDefineShape3);
        defineShape.bounds = new Rect(width * SwfConstants.TWIPS_PER_PIXEL, height * SwfConstants.TWIPS_PER_PIXEL);
        defineShape.shapeWithStyle = sws;

        return defineShape;
    }
}
