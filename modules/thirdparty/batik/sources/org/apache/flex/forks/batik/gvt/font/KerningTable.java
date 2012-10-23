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


/**
 * The KerningTable class holds a kerning table (a collection of Kern
 * elements). It provides a more convenient method of looking up kerning values
 * when laying out glyphs.
 *
 * @author <a href="mailto:dean.jackson@cmis.csiro.au">Dean Jackson</a>
 * @version $Id: KerningTable.java 475685 2006-11-16 11:16:05Z cam $ 
 */
public class KerningTable {

    private Kern[] entries;

    /**
     * Creates a KerningTable from an array of Kern entries.
     *
     * @param entries The array of Kern objects that represent the kerning
     * entries for the font that this kerning table belongs to.
     */
    public KerningTable(Kern[] entries) {
        this.entries = entries;
    }

    /**
     * Returns the amount of kerning that should be added between the given
     * glyphs. Returns 0 if the glyphs should not be kerned.
     *
     * @param glyphCode1 The id of the first glyph in the kerning pair
     * @param glyphCode2 The id of the second glyph in the kerning pair
     * @param glyphUnicode1 The unicode value of the first glyph in
     * the kerning pair
     * @param glyphUnicode2 The unicode vlaue of the second glyph in
     * the kerning pair
     * @return The amount of kerning to be added when laying out the glyphs 
     */
    public float getKerningValue(int glyphCode1, 
                                 int glyphCode2,
                                 String glyphUnicode1, 
                                 String glyphUnicode2) {
        for (int i = 0; i < entries.length; i++) {
            if (entries[i].matchesFirstGlyph(glyphCode1, glyphUnicode1) &&
                entries[i].matchesSecondGlyph(glyphCode2, glyphUnicode2)) {
                return entries[i].getAdjustValue();
            }
        }
        return 0f;
    }
}
