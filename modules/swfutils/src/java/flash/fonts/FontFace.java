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

package flash.fonts;

import java.util.HashMap;

import flash.swf.types.GlyphEntry;

/**
 * A face represents one style of a font from a single family. For
 * now, the font size is not considered in the face as a FontBuilder
 * does not depend on size to generate a DefineFont or DefineFont2
 * tag.
 *
 * @author Peter Farland
 */
public abstract class FontFace
{
	public static final int PLAIN	= 0;
	public static final int BOLD	= 1;
	public static final int ITALIC	= 2;

	public static final int SWF_EM_SQUARE = 1024;
	public static final int TTF_EM_SQUARE = 2048;

	public abstract GlyphEntry getGlyphEntry(char c);
	public abstract int getMissingGlyphCode();
	public abstract double getPointSize();
	public abstract String getFamily();
	public abstract int getAscent();
	public abstract int getDescent();
	public abstract int getLineGap();
	public abstract int getFirstChar();
	public abstract int getNumGlyphs();
	public abstract boolean canDisplay(char c);
	public abstract int getAdvance(char c);
	public abstract boolean isBold();
	public abstract boolean isItalic();
	public abstract double getEmScale();
	public abstract String getCopyright();
	public abstract void setCopyright(String c);
	public abstract String getTrademark();
	public abstract void setTrademark(String t);
	public abstract FSType getFSType();
	public abstract void setFSType(FSType t);
	public abstract String getPostscriptName();

    public void setProperty(String name, Object value)
    {
        properties.put(name, value);
    }

    public Object getProperty(String name)
    {
        return properties.get(name);
    }

    protected HashMap<String, Object> properties = new HashMap<String, Object>();
}