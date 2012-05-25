/*

   Copyright 2002-2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

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

import org.apache.flex.forks.batik.gvt.font.FontFamilyResolver;
import org.apache.flex.forks.batik.gvt.font.GVTFont;
import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.apache.flex.forks.batik.gvt.font.GVTLineMetrics;
import org.apache.flex.forks.batik.gvt.font.UnresolvedFontFamily;

public class BlockInfo {
    public final static int ALIGN_START  = 0;
    public final static int ALIGN_MIDDLE = 1;
    public final static int ALIGN_END    = 2;
    public final static int ALIGN_FULL   = 3;

    protected float   top;
    protected float   right;
    protected float   bottom;
    protected float   left;

    protected float   indent;

    protected int     alignment;

    protected float   lineHeight;
    protected List    fontFamilyList;
    protected Map     fontAttrs;
    protected float   ascent=-1;
    protected float   descent=-1;

    protected boolean flowRegionBreak;


    public BlockInfo(float top, float right, float bottom, float left,
                     float indent, int alignment, float lineHeight,
                     List fontFamilyList, Map fontAttrs, 
                     boolean flowRegionBreak) {
        this.top    = top;
        this.right  = right;
        this.bottom = bottom;
        this.left   = left;

        this.indent = indent;

        this.alignment = alignment;

        this.lineHeight       = lineHeight;
        this.fontFamilyList   = fontFamilyList;
        this.fontAttrs        = fontAttrs;

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

        Iterator i = fontFamilyList.iterator();
        while (i.hasNext()) {
            GVTFontFamily fontFamily = (GVTFontFamily)i.next();
            if (fontFamily instanceof UnresolvedFontFamily) {
                fontFamily = FontFamilyResolver.resolve
                    ((UnresolvedFontFamily)fontFamily);
            }
            if (fontFamily == null) continue;
            
            
            GVTFont font = fontFamily.deriveFont(fontSize, fontAttrs);
            GVTLineMetrics lm = font.getLineMetrics("", frc);
            this.ascent = lm.getAscent();
            this.descent = lm.getDescent();
            break;
        }
        if (ascent == -1) {
            ascent  = fontSize * .8f;
            descent = fontSize * .2f;
        }
    }

    public float   getTopMargin()       { return top; }
    public float   getRightMargin()     { return right; }
    public float   getBottomMargin()    { return bottom; }
    public float   getLeftMargin()      { return left; }

    public float   getIndent()          { return indent; }

    public int     getTextAlignment()   { return alignment; }


    public float   getLineHeight()      { return lineHeight; }
    public List    getFontFamilyList()  { return fontFamilyList; }
    public Map     getFontAttrs()       { return fontAttrs; }
    public float   getAscent()          { return ascent; }
    public float   getDescent()         { return descent; }

    public boolean isFlowRegionBreak()  { return flowRegionBreak; }

}
