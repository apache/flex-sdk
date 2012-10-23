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

import org.apache.flex.forks.batik.gvt.font.GVTFont;
import org.apache.flex.forks.batik.gvt.font.GVTLineMetrics;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: WordInfo.java 475477 2006-11-15 22:44:28Z cam $
 */
class WordInfo {
    int      index = -1;
    float    ascent=-1, descent=-1, lineHeight=-1;
    GlyphGroupInfo [] glyphGroups=null;
    Object            flowLine=null;

    WordInfo(int index) {
        this.index = index;
    }

    WordInfo(int index,
             float ascent, float descent, float lineHeight,
             GlyphGroupInfo [] glyphGroups) {
        this.index   = index;
        this.ascent  = ascent;
        this.descent = descent;
        this.lineHeight  = lineHeight;
        this.glyphGroups = glyphGroups;
    }

    public int getIndex() { return index; }

    public float getAscent()             { return ascent; }
    public void  setAscent(float ascent) { this.ascent = ascent; }

    public float getDescent()              { return descent; }
    public void  setDescent(float descent) { this.descent = descent; }

    public void addLineMetrics(GVTFont font, GVTLineMetrics lm) {
        if (ascent < lm.getAscent())
            ascent = lm.getAscent();
        if (descent < lm.getDescent())
            descent = lm.getDescent();
    }


    public float getLineHeight()                 { return this.lineHeight; }
    public void  setLineHeight(float lineHeight) { 
        this.lineHeight = lineHeight; }
    public void  addLineHeight(float lineHeight) { 
        if (this.lineHeight < lineHeight) 
            this.lineHeight = lineHeight; 
    }

    public Object getFlowLine()         { return this.flowLine; }
    public void   setFlowLine(Object fl) { this.flowLine = fl; }

    public int getNumGlyphGroups() { 
        if (glyphGroups == null)
            return -1;
        return glyphGroups.length; 
    }
    public void setGlyphGroups(GlyphGroupInfo []glyphGroups) {
        this.glyphGroups = glyphGroups;
    }
    public GlyphGroupInfo getGlyphGroup(int idx) {
        if (glyphGroups == null) return null;
        return glyphGroups[idx]; 
    }
}
