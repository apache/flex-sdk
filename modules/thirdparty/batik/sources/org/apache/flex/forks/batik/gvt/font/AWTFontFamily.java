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

import java.awt.Font;
import java.awt.font.TextAttribute;
import java.text.AttributedCharacterIterator;
import java.util.HashMap;
import java.util.Map;
import org.apache.flex.forks.batik.gvt.text.GVTAttributedCharacterIterator;

/**
 * A font family class for AWT fonts.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: AWTFontFamily.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AWTFontFamily implements GVTFontFamily {

    public static final 
        AttributedCharacterIterator.Attribute TEXT_COMPOUND_DELIMITER =
        GVTAttributedCharacterIterator.TextAttribute.TEXT_COMPOUND_DELIMITER;

    protected GVTFontFace fontFace;
    protected Font   font;

    /**
     * Constructs an AWTFontFamily with the specified familyName.
     *
     * @param fontFace The name of the font family.
     */
    public AWTFontFamily(GVTFontFace fontFace) {
        this.fontFace = fontFace;
    }

    /**
     * Constructs an AWTFontFamily with the specified familyName.
     *
     * @param familyName The name of the font family.
     */
    public AWTFontFamily(String familyName) {
        this(new GVTFontFace(familyName));
    }

    /**
     * Constructs an AWTFontFamily with the specified familyName.
     *
     * @param fontFace The name of the font family.
     */
    public AWTFontFamily(GVTFontFace fontFace, Font font) {
        this.fontFace = fontFace;
        this.font     = font;
    }

    /**
     * Returns the font family name.
     *
     * @return The family name.
     */
    public String getFamilyName() {
        return fontFace.getFamilyName();
    }

    /**
     * Returns the font-face information for this font family.
     */
    public GVTFontFace getFontFace() {
        return fontFace;
    }

    /**
     * Derives a GVTFont object of the correct size.
     *
     * @param size The required size of the derived font.
     * @param aci  The character iterator that will be rendered using
     *             the derived font.  
     */
    public GVTFont deriveFont(float size, AttributedCharacterIterator aci) {
        if (font != null)
            return new AWTGVTFont(font, size);

        return deriveFont(size, aci.getAttributes());
    }


    /**
     * Derives a GVTFont object of the correct size from an attribute Map.
     * @param size  The required size of the derived font.
     * @param attrs The Attribute Map to get Values from.
     */
    public GVTFont deriveFont(float size, Map attrs) {
        if (font != null)
            return new AWTGVTFont(font, size);

        Map fontAttributes = new HashMap(attrs);
        fontAttributes.put(TextAttribute.SIZE, new Float(size));
        fontAttributes.put(TextAttribute.FAMILY, fontFace.getFamilyName());
        fontAttributes.remove(TEXT_COMPOUND_DELIMITER);
        return new AWTGVTFont(fontAttributes);
    }
     
}
