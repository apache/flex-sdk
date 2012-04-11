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

import flash.graphics.g2d.GraphicContext;
import flash.swf.tags.DefineTag;
import flash.swf.tags.DefineShape;
import flash.swf.tags.DefineBits;
import flash.swf.builder.types.ShapeWithStyleBuilder;
import flash.swf.builder.types.Point;
import flash.swf.Tag;
import flash.swf.SwfConstants;
import flash.swf.types.FillStyle;
import flash.swf.types.LineStyle;
import flash.swf.types.Rect;
import flash.swf.types.ShapeRecord;
import flash.swf.types.StyleChangeRecord;
import flash.swf.types.StraightEdgeRecord;
import flash.swf.types.CurvedEdgeRecord;

import java.awt.Shape;
import java.util.List;
import java.util.Iterator;

/**
 * This class is used to construct a DefineShape SWF tag from a Shape.
 *
 * @author Peter Farland
 */
public final class DefineShapeBuilder implements TagBuilder
{
	private DefineShapeBuilder()
	{
		tag = new DefineShape(Tag.stagDefineShape3);
	}

	public DefineShapeBuilder(Shape shape, GraphicContext graphicContext, boolean outline, boolean fill)
	{
		this();
		sws = new ShapeWithStyleBuilder(shape, graphicContext, outline, fill);
	}

	public DefineShapeBuilder(Shape shape, Point origin, FillStyle fs, LineStyle ls, boolean fill)
	{
		this();
		sws = new ShapeWithStyleBuilder(shape, origin, fs, ls, fill);
	}

	public void join(Shape shape)
	{
        sws.join(shape);
	}

	public DefineTag build()
	{
		tag.shapeWithStyle = sws.build();
		tag.bounds = getBounds(tag.shapeWithStyle.shapeRecords, tag.shapeWithStyle.linestyles);
		return tag;
	}

	/**
	 * Utility method that calculates the minimum bounding rectangle that encloses a list
	 * of ShapeRecords, taking into account the possible maximum stroke width of any of the
	 * supplied linestyles.
	 * @param records
	 * @param lineStyles
	 * @return
	 */
	public static Rect getBounds(List records, List lineStyles)
	{
		if (records == null || records.size() == 0)
		{
			return new Rect();
		}
		else
		{
			int x1 = 0;
			int y1 = 0;
			int x2 = 0;
			int y2 = 0;
			int x = 0;
			int y = 0;
			boolean firstMove = true;

            Iterator it = records.iterator();
			while (it.hasNext())
			{
				ShapeRecord r = (ShapeRecord)it.next();
				if (r == null)
					continue;

				if (r instanceof StyleChangeRecord)
				{
					StyleChangeRecord scr = (StyleChangeRecord)r;
					x = scr.moveDeltaX;
					y = scr.moveDeltaY;
					if (firstMove)
					{
						x1 = x;
						y1 = y;
						x2 = x;
						y2 = y;
						firstMove = false;
					}
				}
				else if (r instanceof StraightEdgeRecord)
				{
					StraightEdgeRecord ser = (StraightEdgeRecord)r;
					x = x + ser.deltaX;
					y = y + ser.deltaY;
				}
				else if (r instanceof CurvedEdgeRecord)
				{
					CurvedEdgeRecord cer = (CurvedEdgeRecord)r;
					x = x + cer.controlDeltaX + cer.anchorDeltaX;
					y = y + cer.controlDeltaY + cer.anchorDeltaY;
				}

				if (x < x1) x1 = x;
				if (y < y1) y1 = y;
				if (x > x2) x2 = x;
				if (y > y2) y2 = y;
			}

			if (lineStyles != null && lineStyles.size() > 0)
			{
				it = lineStyles.iterator();
				int width = SwfConstants.TWIPS_PER_PIXEL;
				while (it.hasNext())
				{
					LineStyle ls = (LineStyle)it.next();
					if (ls == null)
						continue;
					else
					{
						if (width < ls.width)
						width = ls.width;
					}
				}

				double stroke = (int)Math.rint(width * 0.5);
				x1 = (int)Math.rint(x1 - stroke);
				y1 = (int)Math.rint(y1 - stroke);
				x2 = (int)Math.rint(x2 + stroke);
				y2 = (int)Math.rint(y2 + stroke);
			}

			return new Rect(x1, x2, y1, y2);
		}
	}

	public static DefineShape buildImage(DefineBits tag, int width, int height)
	{
		return ImageShapeBuilder.buildImage(tag, width, height);
	}

	private DefineShape tag;
	private ShapeWithStyleBuilder sws;
}
