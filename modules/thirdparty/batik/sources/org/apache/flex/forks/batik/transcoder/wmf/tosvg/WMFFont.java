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

package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

import java.awt.Font;

/**
 * Represent a WMF Font, encountered in a Metafile.
 *
 * @version $Id: WMFFont.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class WMFFont {
    public Font font;
    public int charset;
    public int underline = 0;
    public int strikeOut = 0;
    public int italic = 0;
    public int weight = 0;
    public int orientation = 0;
    public int escape = 0;

    public WMFFont(Font font, int charset) {
        this.font = font;
        this.charset = charset;
    }

    public WMFFont(Font font, int charset, int underline, int strikeOut,
        int italic, int weight, int orient, int escape) {

        this.font = font;
        this.charset = charset;
        this.underline = underline;
        this.strikeOut = strikeOut;
        this.italic = italic;
        this.weight = weight;
        this.orientation = orient;
        this.escape = escape;
    }
}
