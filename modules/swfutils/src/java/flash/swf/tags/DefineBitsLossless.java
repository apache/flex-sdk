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

import flash.swf.TagHandler;

/**
 * This class extends DefineBits by adding support for an array of
 * color data.
 *
 * @author Clement Wong
 */
public class DefineBitsLossless extends DefineBits
{
    public static final int FORMAT_8_BIT_COLORMAPPED = 3;
    public static final int FORMAT_15_BIT_RGB = 4;
    public static final int FORMAT_24_BIT_RGB = 5;

    public DefineBitsLossless(int code)
	{
		super(code);
	}

    public void visit(TagHandler h)
	{
        if (code == stagDefineBitsLossless)
    		h.defineBitsLossless(this);
        else
            h.defineBitsLossless2(this);
	}

	public int format;

    /**
     * DefineBitsLossLess:  array of 0x00RRGGBB
     * DefineBitsLossLess2: array of 0xAARRGGBB
     */
    public int[] colorData;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineBitsLossless))
        {
            DefineBitsLossless defineBitsLossless = (DefineBitsLossless) object;

            if ( (defineBitsLossless.format == this.format) &&
                 Arrays.equals(defineBitsLossless.colorData, this.colorData) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
