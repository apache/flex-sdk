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

import java.util.Arrays;

import flash.swf.Tag;

/**
 * Represents a DefineFontInfo SWF tag.
 *
 * @since SWF1
 * @author Clement Wong
 */
public class DefineFontInfo extends Tag
{
    public DefineFontInfo(int code)
    {
        super(code);
    }

    public void visit(flash.swf.TagHandler h)
	{
        if (code == stagDefineFontInfo)
    		h.defineFontInfo(this);
        else
            h.defineFontInfo2(this);
	}

	protected Tag getSimpleReference()
    {
        return font;
    }

    public DefineFont1 font;
	public String name;
	public boolean shiftJIS;
	public boolean ansi;
	public boolean italic;
	public boolean bold;
	public boolean wideCodes; // not in equality check- sometimes determined from other vars at encoding time

    /** U16 if widecodes == true, U8 otherwise.  provides the character
     * values for each glyph in the font. */
	public char[] codeTable;

    /** langcode - valid for DefineFont2 only */
    public int langCode;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineFontInfo))
        {
            DefineFontInfo defineFontInfo = (DefineFontInfo) object;

            // [paul] Checking that the font fields are equal would
            // lead to an infinite loop, because DefineFont contains a
            // reference to it's DefineFontInfo.
            if ( equals(defineFontInfo.name, this.name) &&
                 (defineFontInfo.shiftJIS == this.shiftJIS) &&
                 (defineFontInfo.ansi == this.ansi) &&
                 (defineFontInfo.italic == this.italic) &&
                 (defineFontInfo.bold == this.bold) &&
                 Arrays.equals(defineFontInfo.codeTable, this.codeTable) &&
                 (defineFontInfo.langCode == this.langCode) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }    
}
