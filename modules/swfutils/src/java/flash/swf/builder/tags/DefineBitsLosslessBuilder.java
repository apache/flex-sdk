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

package flash.swf.builder.tags;

import flash.swf.tags.DefineBitsLossless;
import flash.swf.TagValues;

/**
 * This class is used to construct a DefineBitsLossless SWF tag from a
 * array of pixels.
 *
 * @author Paul Reilly
 * @author Peter Farland
 */
public class DefineBitsLosslessBuilder
{
	private DefineBitsLosslessBuilder()
	{
	}

	public static DefineBitsLossless build(int[] pixels, int width, int height)
	{
		DefineBitsLossless defineBitsLossless = new DefineBitsLossless(TagValues.stagDefineBitsLossless2);
		defineBitsLossless.format = DefineBitsLossless.FORMAT_24_BIT_RGB;
		defineBitsLossless.width = width;
		defineBitsLossless.height = height;
		defineBitsLossless.data = new byte[pixels.length * 4];

		for (int i = 0; i < pixels.length; i++)
		{
			int offset = i * 4;
			int alpha = (pixels[i] >> 24) & 0xFF;
			defineBitsLossless.data[offset] = (byte)alpha;

			// [preilly] Ignore the other components if alpha is transparent.  This seems
			// to be a bug in the player.  Additionally, premultiply the alpha and the
			// colors, because the player expects this.
			if (defineBitsLossless.data[offset] != 0)
			{
				int red = (pixels[i] >> 16) & 0xFF;
				defineBitsLossless.data[offset + 1] = (byte)((red * alpha) / 255);
				int green = (pixels[i] >> 8) & 0xFF;
				defineBitsLossless.data[offset + 2] = (byte)((green * alpha) / 255);
				int blue = pixels[i] & 0xFF;
				defineBitsLossless.data[offset + 3] = (byte)((blue * alpha) / 255);
			}
		}

		return defineBitsLossless;
	}
}
