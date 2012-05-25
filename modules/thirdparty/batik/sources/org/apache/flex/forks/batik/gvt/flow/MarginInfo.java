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

public class MarginInfo {
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
    protected boolean fontSizeRelative;

    protected boolean flowRegionBreak;


    public MarginInfo(float top, float right, float bottom, float left,
                      float indent, int alignment, float lineHeight,
                      boolean fontSizeRelative, boolean flowRegionBreak) {
        this.top    = top;
        this.right  = right;
        this.bottom = bottom;
        this.left   = left;

        this.indent = indent;

        this.alignment = alignment;

        this.lineHeight = lineHeight;
        this.fontSizeRelative = fontSizeRelative;

        this.flowRegionBreak = flowRegionBreak;
    }

    public MarginInfo(float margin, int alignment) {
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

    public float   getTopMargin()       { return top; }
    public float   getRightMargin()     { return right; }
    public float   getBottomMargin()    { return bottom; }
    public float   getLeftMargin()      { return left; }

    public float   getIndent()          { return indent; }

    public int     getTextAlignment()   { return alignment; }


    public float   getLineHeight()      { return lineHeight; }
    public boolean isFontSizeRelative() { return fontSizeRelative; }

    public boolean isFlowRegionBreak()  { return flowRegionBreak; }
}
