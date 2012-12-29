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
 * An interface for all font family classes.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: GVTFontFamily.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface GVTFontFamily {

    /**
     * Returns the font family name.
     *
     * @return The family name.
     */
    String getFamilyName();

    /**
     * Returns the FontFace for this fontFamily instance.
     */
    GVTFontFace getFontFace();

    /**
     * Derives a GVTFont object of the correct size.
     *
     * @param size The required size of the derived font.
     * @param aci The character iterator that will be rendered using
     * the derived font.
     */
    GVTFont deriveFont(float size, AttributedCharacterIterator aci);

    /**
     * Derives a GVTFont object of the correct size from an attribute Map.
     * @param size  The required size of the derived font.
     * @param attrs The Attribute Map to get Values from.
     */
    GVTFont deriveFont(float size, Map attrs);
     
}
