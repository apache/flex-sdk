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

import flash.swf.tags.DefineEditText;
import flash.swf.tags.DefineTag;
import flash.swf.types.Rect;
import flash.swf.SwfConstants;
import flash.swf.SwfUtils;

import java.io.IOException;
import java.awt.Color;

/**
 * This class is used to construct a DefineEditText SWF tag from a
 * FontBuilder.
 *
 * @author Peter Farland
 */
public class EditTextBuilder implements TagBuilder
{
	public EditTextBuilder(FontBuilder builder, float height, boolean useOutlines, boolean readOnly, boolean noSelect)
	{
		tag = new DefineEditText();
        tag.height = (int)Math.rint(height*SwfConstants.TWIPS_PER_PIXEL);

		if (builder != null)
		{
			fontBuilder = builder;
			tag.hasFont = true;
		}

		tag.useOutlines = useOutlines;
		tag.readOnly = readOnly;
		tag.noSelect = noSelect;
	}

	public DefineTag build()
	{
		tag.font = fontBuilder.tag;
		if (tag.varName == null)
			tag.varName = "";

		if (tag.initialText == null)
			tag.initialText = "";

		if (tag.bounds == null)
			tag.bounds = new Rect();

		return tag;
	}

	public void setAutoSize(boolean b)
	{
		tag.autoSize = b;
	}

	public void setBorder(boolean b)
	{
		tag.border = b;
	}

	public void setVarName(String var)
	{
		tag.varName = var;
	}

	public void setMaxLength(int max)
	{
		tag.hasMaxLength = true;
		tag.maxLength = max;
	}

	public void setHtml(boolean b)
	{
		tag.html = b;
	}

	public void setColor(Color color)
	{
		if (color != null)
		{
			tag.hasTextColor = true;
			tag.color = SwfUtils.colorToInt(color);
		}
	}

    public void setLayout(int align, int leftMargin, int rightMargin, int indent, int leading)
	{
		tag.hasLayout = true;
		if (align < 0 || align > 3)
			throw new RuntimeException("Invalid alignment.");
		tag.align = align;
		tag.leftMargin = leftMargin;
		tag.rightMargin = rightMargin;
		tag.ident = indent;
		tag.leading = leading;
	}

	public void setBounds(Rect r)
	{
		tag.bounds = r;
	}


	public void setInitialText(String text) throws IOException
	{
		if (text != null)
		{
			tag.hasText = true;
			tag.initialText = text;

			if (tag.bounds == null)
			{
/*
				Font font = fontBuilder.getFont().deriveFont((float)tag.height/20);
				TextLayout layout = new TextLayout(text, font, fontBuilder.getFontRenderContext());
				Rectangle2D bs = layout.getBounds();
				tag.bounds = new Rect(SwfUtils.toTwips(bs.getMinX()),
										SwfUtils.toTwips(bs.getMaxX()),
										SwfUtils.toTwips(bs.getMinY()),
										SwfUtils.toTwips(bs.getMaxY()));
*/


				//TODO: need to find a better way to set the text bounds 
				tag.bounds.yMax = tag.bounds.yMax * 3; //The logical bounds includes padding above and below of the actual bounding box
				tag.bounds.xMax = tag.bounds.xMax * 2;
			}
		}
	}

	private DefineEditText tag;
	private FontBuilder fontBuilder;
}
