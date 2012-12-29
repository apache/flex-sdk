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
package org.apache.flex.forks.batik.gvt.flow;

import java.awt.font.FontRenderContext;
import java.awt.font.TextAttribute;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.flex.forks.batik.gvt.font.GVTFont;
import org.apache.flex.forks.batik.gvt.font.GVTLineMetrics;

/**
 *
 * @version $Id: BlockInfo.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class BlockInfo {
    public static final int ALIGN_START  = 0;
    public static final int ALIGN_MIDDLE = 1;
    public static final int ALIGN_END    = 2;
    public static final int ALIGN_FULL   = 3;

    protected float   top;
    protected float   right;
    protected float   bottom;
    protected float   left;

    protected float   indent;

    protected int     alignment;

    protected float   lineHeight;
    protected List    fontList;
    protected Map     fontAttrs;
    protected float   ascent=-1;
    protected float   descent=-1;

    protected boolean flowRegionBreak;


    public BlockInfo(float top, float right, float bottom, float left,
                     float indent, int alignment, float lineHeight,
                     List fontList, Map fontAttrs,
                     boolean flowRegionBreak) {
        this.top    = top;
        this.right  = right;
        this.bottom = bottom;
        this.left   = left;

        this.indent = indent;

        this.alignment = alignment;

        this.lineHeight      = lineHeight;
        this.fontList        = fontList;
        this.fontAttrs       = fontAttrs;

        this.flowRegionBreak = flowRegionBreak;
    }

    public BlockInfo(float margin, int alignment) {
        setMargin(margin);
        this.indent = 0;
        this.alignment = alignment;
        this.flowRegionBreak = false;
    }

    public void setMargin(float margin) {
        this.top    = margin;
        this.right  = margin;
        this.bottom = margin;
        this.left   = margin;
    }

    public void initLineInfo(FontRenderContext frc) {
        float fontSize = 12;
        Float fsFloat = (Float)fontAttrs.get(TextAttribute.SIZE);
        if (fsFloat != null)
            fontSize = fsFloat.floatValue();

        Iterator i = fontList.iterator();
        while (i.hasNext()) {
            GVTFont font = (GVTFont)i.next();
            GVTLineMetrics lm = font.getLineMetrics("", frc);
            this.ascent = lm.getAscent();
            this.descent = lm.getDescent();
            break;
        }
        if (ascent == -1) {
            ascent  = fontSize * 0.8f;
            descent = fontSize * 0.2f;
        }
    }

    public float   getTopMargin()       { return top; }
    public float   getRightMargin()     { return right; }
    public float   getBottomMargin()    { return bottom; }
    public float   getLeftMargin()      { return left; }

    public float   getIndent()          { return indent; }

    public int     getTextAlignment()   { return alignment; }


    public float   getLineHeight()      { return lineHeight; }
    public List    getFontList()        { return fontList; }
    public Map     getFontAttrs()       { return fontAttrs; }
    public float   getAscent()          { return ascent; }
    public float   getDescent()         { return descent; }

    public boolean isFlowRegionBreak()  { return flowRegionBreak; }

}
