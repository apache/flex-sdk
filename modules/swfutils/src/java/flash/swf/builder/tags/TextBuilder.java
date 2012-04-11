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

import flash.swf.tags.DefineTag;
import flash.swf.tags.DefineText;
import flash.swf.types.GlyphEntry;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.types.TextRecord;
import flash.swf.SwfConstants;
import flash.swf.SwfUtils;

import java.awt.Color;
import java.awt.geom.Rectangle2D;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

/**
 * This class is used to construct a DefineText SWF tag from a list of
 * FontBuilders.
 *
 * @author Peter Farland
 *         <p/>
 *         Modified by s. gong
 */
public class TextBuilder
        implements TagBuilder
{
    public TextBuilder(int code)
    {
        tag = new DefineText(code);
        fontBuilders = new ArrayList<FontBuilder>();
    }

    public DefineTag build()
    {
        if (tag.matrix == null)
            tag.matrix = new Matrix();

        return tag;
    }
    /**
     *
     * @param fontBuilder FontBuilder
     * @param height double
     * @param text String
     * @param color Color
     * @param xOffset int
     * @param yOffset int
     * @throws IOException
     */
    /**
     * add text
     */
    public void add(FontBuilder fontBuilder, double height, String text,
                    Color color, int xOffset, int yOffset) throws IOException
    {
        fontBuilders.add(fontBuilder);

        BufferedReader reader = new BufferedReader(new StringReader(text));
        String line;
        char[] chars;
        int yCount = 0;
        double t_width = 0.0f;
        double t_height = 0.0f;
        while (true)
        {
            line = reader.readLine();
            // Make sure we don't create empty TextRecords
            // A empty textRecord will crash Flash Player. Player Bug#57644
            if ((line == null) || (line.length() == 0))
                break;

            TextRecord tr = getStyleRecord(fontBuilder, height, color, xOffset,
                    (int)(yOffset +
                    yCount * height *
                    SwfConstants.TWIPS_PER_PIXEL));

            chars = line.toCharArray();
            tr.entries = new GlyphEntry[chars.length];
            double w = 0;
            for (int i = 0; i < chars.length; i++)
            {
                char c = chars[i];
                // preilly: According to Sherman Gong, we need to clone the font GlyphEntry, so
                // that the advance value can be mapped from the font's logical scale to the
                // text's physical scale.
                GlyphEntry ge = (GlyphEntry)fontBuilder.getGlyph(c).clone();
                ge.advance = (int)((ge.advance / 1024f) * tr.height);
                tr.entries[i] = ge;
                w += ge.advance;
            }
            if (w > t_width)
                t_width = w;
            tag.records.add(tr);
            yCount++;
        }
        t_height = yCount * height;

        double x1 = 0;
        double y1 = 0;
        double x2 = x1 + t_width;
        double y2 = y1 + t_height;
        x1 = x1 * SwfConstants.TWIPS_PER_PIXEL;
        x2 = x2 * SwfConstants.TWIPS_PER_PIXEL;
        y1 = y1 * SwfConstants.TWIPS_PER_PIXEL;
        y2 = y2 * SwfConstants.TWIPS_PER_PIXEL;
        /**
         *  If the values are greater than Max_value, then
         *  the results are not to be trusted.
         */
        if (x1 > Integer.MAX_VALUE)
            x1 = 0;
        if (x2 > Integer.MAX_VALUE)
            x2 = 0;
        if (y1 > Integer.MAX_VALUE)
            y1 = 0;
        if (y2 > Integer.MAX_VALUE)
            y2 = 0;

        tag.bounds = new Rect((int)x1, (int)x2, (int)y1, (int)y2);
    }

    /**
     * Description:  This version is the same as the straight add function
     * The difference is that we use java layout class to
     * calculate the bounding box.
     *
     * @param fontBuilder FontBuilder
     * @param height      double
     * @param text        String
     * @param color       Color
     * @param xOffset     int
     * @param yOffset     int
     * @param bounds      Rectangle2D
     * @throws IOException
     */
    public void addWithLayout(FontBuilder fontBuilder, double height, String text,
                              Color color, int xOffset, int yOffset, Rectangle2D bounds) throws IOException
    {
        fontBuilders.add(fontBuilder);

        BufferedReader reader = new BufferedReader(new StringReader(text));
        String line;
        char[] chars;
        int yCount = 0;
        while (true)
        {
            line = reader.readLine();
            // Make sure we don't create empty TextRecords
            // A empty textRecord will crash Flash Player. Player Bug #102948
            if ((line == null) || (line.length() == 0))
                break;
            TextRecord tr = getStyleRecord(fontBuilder, height, color, xOffset, (int)(yOffset + yCount * height * SwfConstants.TWIPS_PER_PIXEL));

            chars = line.toCharArray();
            tr.entries = new GlyphEntry[chars.length];
            for (int i = 0; i < chars.length; i++)
            {
                char c = chars[i];
                GlyphEntry ge = (GlyphEntry)fontBuilder.getGlyph(c).clone();
                ge.advance = (int)((ge.advance / 1024f) * tr.height);
                tr.entries[i] = ge;
            }
            tag.records.add(tr);
            yCount++;
        }
        /**
         *  on JDK1.4.x the bounds.getMinX() can returns values > bounds.getMaxX()
         *  and also return values > Interger.MAX_VALUE which can cause many
         *  problems when we encode the the position valures in the tagEncoder.
         *
         *  So we stay away from the getMinx, getMinxY methods, and also
         *  double check everything here.
         *
         */

        double x1 = bounds.getX();
        double y1 = bounds.getY();
        double rect_width = bounds.getWidth();
        double rect_height = bounds.getHeight();
        double x2 = x1 + rect_width;
        double y2 = y1 + rect_height;
        x1 = x1 * SwfConstants.TWIPS_PER_PIXEL;
        x2 = x2 * SwfConstants.TWIPS_PER_PIXEL;
        y1 = y1 * SwfConstants.TWIPS_PER_PIXEL;
        y2 = y2 * SwfConstants.TWIPS_PER_PIXEL;
        /**
         *  If the values are greater than Max_value, then
         *  the results are not to be trusted.
         */
        if (x1 > Integer.MAX_VALUE)
            x1 = 0;
        if (x2 > Integer.MAX_VALUE)
            x2 = 0;
        if (y1 > Integer.MAX_VALUE)
            y1 = 0;
        if (y2 > Integer.MAX_VALUE)
            y2 = 0;

        tag.bounds = new Rect((int)x1, (int)x2, (int)y1, (int)y2);
    }

    private TextRecord getStyleRecord(FontBuilder fontBuilder, double height,
                                      Color color, int xOffset, int yOffset)
    {
        TextRecord tr = new TextRecord();
        if (fontBuilder != null)
        {
            tr.setFont(fontBuilder.tag);
            tr.setHeight(SwfUtils.toTwips(height));
        }

        if (color != null)
        {
            int c = SwfUtils.colorToInt(color);
            tr.setColor(c);
        }

        if (xOffset > 0)
        {
            tr.setX(xOffset);
        }

        if (yOffset > 0)
        {
            tr.setY(yOffset);
        }
        return tr;
    }

    private DefineText tag;
    private List<FontBuilder> fontBuilders;
}
