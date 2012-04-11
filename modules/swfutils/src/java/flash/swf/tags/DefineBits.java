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
 * This tag defines a bitmap character with JPEG compression. It
 * contains only the JPEG compressed image data (from the Frame Header
 * onward).  A separate JPEGTables tag contains the JPEG encoding data
 * used to encode this image (the Tables/Misc segment).  Note that
 * only one JPEGTables tag is allowed in a SWF file, and thus all
 * bitmaps defined with DefineBits must share common encoding
 * tables. <p>
 *
 * The data in this tag begins with the JPEG SOI marker 0xFF, 0xD8 and
 * ends with the EOI marker 0xFF, 0xD9. <p>
 *
 * DefineBits2 - includes all jpeg data <p>
 * DefineBits3 - includes all data plus a transparency map
 *
 * @since SWF1
 *
 * @author Clement Wong
 */
public class DefineBits extends DefineTag
{
    public DefineBits(int code)
    {
        super(code);
    }

    public void visit(flash.swf.TagHandler h)
	{
        if (code == stagDefineBitsJPEG2)
            h.defineBitsJPEG2(this);
        else
    		h.defineBits(this);
	}

	protected Tag getSimpleReference()
    {
        return jpegTables;
    }


	/** there is only one JPEG table in the entire movie */
    public GenericTag jpegTables;
	public byte[] data;

	// Only used by DefineBitsLossless subclass, but adding here to keep track
	// of the default width/height if discovered during JPEG creation...
	public int width;
	public int height;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineBits))
        {
            DefineBits defineBits = (DefineBits) object;

            if ( Arrays.equals(defineBits.data, this.data) &&
                (defineBits.width == this.width) &&
                (defineBits.height == this.height) &&
                 equals(defineBits.jpegTables,  this.jpegTables) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
