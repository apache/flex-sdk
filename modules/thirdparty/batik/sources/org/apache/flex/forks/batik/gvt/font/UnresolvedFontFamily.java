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

package org.apache.flex.forks.batik.gvt.font;

import java.text.AttributedCharacterIterator;
import java.util.Map;

/**
 * A font family class for unresolved fonts.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: UnresolvedFontFamily.java 475477 2006-11-15 22:44:28Z cam $
 */
public class UnresolvedFontFamily implements GVTFontFamily {

    protected GVTFontFace fontFace;

    /**
     * Constructs an UnresolvedFontFamily with the specified familyName.
     *
     * @param fontFace The name of the font family.
     */
    public UnresolvedFontFamily(GVTFontFace fontFace) {
        this.fontFace = fontFace;
    }

    /**
     * Constructs an UnresolvedFontFamily with the specified familyName.
     *
     * @param familyName The name of the font family.
     */
    public UnresolvedFontFamily(String familyName) {
        this(new GVTFontFace(familyName));
    }

    /**
     * Returns the font-face information for this font family.
     */
    public GVTFontFace getFontFace() {
        return fontFace;
    }

    /**
     * Returns the font family name.
     *
     * @return the family name.
     */
    public String getFamilyName() {
        return fontFace.getFamilyName();
    }

    /**
     * Derives a GVTFont object of the correct size. As this font family is yet
     * to be resolved this will always return null.
     *
     * @param size The required size of the derived font.
     * @param aci The character iterator that will be rendered using the derived
     * font.
     */
    public GVTFont deriveFont(float size, AttributedCharacterIterator aci) {
       return null;
    }


    /**
     * Derives a GVTFont object of the correct size from an attribute Map.
     * @param size  The required size of the derived font.
     * @param attrs The Attribute Map to get Values from.
     */
    public GVTFont deriveFont(float size, Map attrs) { return null; }
     
}
