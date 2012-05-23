/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf.tags;

/**
 * A DefineFont tag defines the shape outlines of each glyph used in a
 * particular font.
 * <p>
 * The DefineFont tag id can be used by subsequent DefineText tags to refer
 * to the font definition. As with all SWF character ids, font ids must be
 * unique amongst all character ids in a SWF file.
 * <p>
 * The first version of DefineFont was introduced in SWF 1.
 * <p>
 * The second version, DefineFont2, was introduced in SWF 3.
 * <p>
 * The third version, DefineFont3, was introduced in SWF 8, along with
 * DefineFontAlignZones for advanced anti-aliasing.
 * <p>
 * In SWF 9, DefineFontName was introduced to record the formal font name
 * and copyright information for an embedded font.
 * <p>
 * The fourth version, DefineFont4, was introduced in SWF 10.  
 * <p>
 * Note that DefineFont tags cannot be used for dynamic text. Dynamic text
 * requires the DefineFont2 tag (or later).
 * 
 * @see DefineFont1
 * @see DefineFont2
 * @see DefineFont3
 * @see DefineFont4
 * 
 * @author Clement Wong
 * @author Peter Farland
 */
public abstract class DefineFont extends DefineTag
{
    protected DefineFont(int code)
    {
        super(code);
    }

    public DefineFontName license;

    public abstract String getFontName();
    public abstract boolean isBold();
    public abstract boolean isItalic();
}
