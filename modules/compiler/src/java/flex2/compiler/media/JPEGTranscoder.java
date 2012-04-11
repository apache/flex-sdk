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

package flex2.compiler.media;

import flash.swf.Tag;
import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineSprite;
import flash.swf.builder.tags.DefineBitsBuilder;
import flash.graphics.images.JPEGImage;

import java.util.Map;

import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.TranscoderException;

/**
 * Transcodes jpeg images into DefineBits tags for embedding.
 *
 * @author Roger Gonzalez
 */
public class JPEGTranscoder extends ImageTranscoder
{
    public JPEGTranscoder()
    {
        super(new String[]{MimeMappings.JPG, MimeMappings.JPEG}, DefineSprite.class, true);
    }

    public ImageInfo getImage( VirtualFile source, Map args ) throws TranscoderException
    {
        ImageTranscoder.ImageInfo info = new ImageInfo();
		JPEGImage image = null;

		try
		{
			image = new JPEGImage(source.getName(),
                                  source.getLastModified(),
                                  source.size(),
                                  source.getInputStream());
            info.width = image.getWidth();
            info.height = image.getHeight();
            DefineBits defineBits = new DefineBits(Tag.stagDefineBitsJPEG2);
            defineBits.data = image.getData();
            info.defineBits = defineBits;
        }
		catch (Exception ex)
		{
            throw new AbstractTranscoder.ExceptionWhileTranscoding( ex );
		}
		finally
		{
		    try
		    {
		        if (image != null)
		            image.dispose();
		    }
		    catch (Throwable t)
		    {
		    }
		}

        return info;
    }
}
