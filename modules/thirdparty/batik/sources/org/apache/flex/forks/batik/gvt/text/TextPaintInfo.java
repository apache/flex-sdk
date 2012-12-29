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
package org.apache.flex.forks.batik.gvt.text;

import java.awt.Composite;
import java.awt.Paint;
import java.awt.Stroke;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: TextPaintInfo.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TextPaintInfo {
    public boolean   visible;
    public Paint     fillPaint;
    public Paint     strokePaint;
    public Stroke    strokeStroke;
    public Composite composite;
    
    public Paint  underlinePaint;
    public Paint  underlineStrokePaint;
    public Stroke underlineStroke;
    
    public Paint  overlinePaint;
    public Paint  overlineStrokePaint;
    public Stroke overlineStroke;
    
    public Paint  strikethroughPaint;
    public Paint  strikethroughStrokePaint;
    public Stroke strikethroughStroke;

    public int    startChar, endChar;

    public TextPaintInfo() { }
    
    public TextPaintInfo(TextPaintInfo pi) {
        set(pi);
    }

    public void set(TextPaintInfo pi) {
        if (pi == null) {
            this.fillPaint    = null;
            this.strokePaint  = null;
            this.strokeStroke = null;
            this.composite    = null;
        
            this.underlinePaint       = null;
            this.underlineStrokePaint = null;
            this.underlineStroke      = null;
        
            this.overlinePaint       = null;
            this.overlineStrokePaint = null;
            this.overlineStroke      = null;
        
            this.strikethroughPaint       = null;
            this.strikethroughStrokePaint = null;
            this.strikethroughStroke      = null;

            this.visible = false;
        } else {
            this.fillPaint    = pi.fillPaint;
            this.strokePaint  = pi.strokePaint;
            this.strokeStroke = pi.strokeStroke;
            this.composite    = pi.composite;
            
            this.underlinePaint       = pi.underlinePaint;
            this.underlineStrokePaint = pi.underlineStrokePaint;
            this.underlineStroke      = pi.underlineStroke;
            
            this.overlinePaint       = pi.overlinePaint;
            this.overlineStrokePaint = pi.overlineStrokePaint;
            this.overlineStroke      = pi.overlineStroke;

            this.strikethroughPaint       = pi.strikethroughPaint;
            this.strikethroughStrokePaint = pi.strikethroughStrokePaint;
            this.strikethroughStroke      = pi.strikethroughStroke;

            this.visible = pi.visible;
        }
    }

    public static boolean equivilent(TextPaintInfo tpi1, TextPaintInfo tpi2) {
        if (tpi1 == null) {
            if (tpi2 == null) return true;
            return false;
        } else if (tpi2 == null) return false;

        if ((tpi1.fillPaint == null) != (tpi2.fillPaint == null))
            return false;

        if (tpi1.visible != tpi2.visible) return false;
        
        boolean tpi1Stroke = ((tpi1.strokePaint != null) &&
                              (tpi1.strokeStroke != null));

        boolean tpi2Stroke = ((tpi2.strokePaint != null) &&
                              (tpi2.strokeStroke != null));

        return (tpi1Stroke == tpi2Stroke);

    }
}
