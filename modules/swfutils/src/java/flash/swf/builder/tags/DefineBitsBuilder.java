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

import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineSprite;
import flash.swf.tags.DefineShape;
import flash.swf.tags.PlaceObject;
import flash.swf.Tag;
import flash.swf.types.TagList;
import flash.swf.types.Matrix;
import flash.graphics.images.JPEGImage;

import java.io.IOException;

/**
 * This class is used to construct a DefineBits or DefineSprite SWF
 * tag from a JPEGImage.
 *
 * @author Paul Reilly
 * @author Peter Farland
 */
public class DefineBitsBuilder
{
	private DefineBitsBuilder()
	{
	}

	public static DefineBits build(JPEGImage image) throws IOException
	{
		DefineBits defineBits = new DefineBits(Tag.stagDefineBitsJPEG2);

		try
		{
			defineBits.data = image.getData();
		}
		finally
		{
			image.dispose();
		}

		return defineBits;
	}

    public static DefineBits build(String name, JPEGImage image)
    {
        DefineBits defineBits = null;
        try
        {
            defineBits = build(image);
            defineBits.name = name;
        }
        catch (IOException ex)
        {
            throw new RuntimeException("Error reading JPEG image " + image.getLocation() + ". " + ex.getMessage());
        }
        finally
        {
            image.dispose();
        }

        return defineBits;
    }

	public static DefineSprite buildSprite(String name, JPEGImage image)
	{
		TagList taglist = new TagList();

		try
		{
			DefineBits defineBits = build(image);
			taglist.defineBitsJPEG2(defineBits);

			DefineShape ds3 = ImageShapeBuilder.buildImage(defineBits, image.getWidth(), image.getHeight());
			taglist.defineShape3(ds3);

			PlaceObject po2 = new PlaceObject(ds3, 1);
			po2.setMatrix(new Matrix());
			// po2.setName(name);

			taglist.placeObject2(po2);
		}
		catch (IOException ex)
		{
			throw new RuntimeException("Error reading JPEG image " + image.getLocation() + ". " + ex.getMessage());
		}
		finally
		{
			image.dispose();
		}

		return defineSprite(name, taglist);
	}

	private static DefineSprite defineSprite(String name, TagList taglist)
	{
		DefineSprite defineSprite = new DefineSprite();
		defineSprite.framecount = 1;
		defineSprite.tagList = taglist;
		defineSprite.name = name;
		return defineSprite;
	}
}
