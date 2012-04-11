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

package flash.graphics.images;

import flash.util.Trace;
import flash.util.FileUtils;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.image.PixelGrabber;
import java.net.URL;
import java.net.URLConnection;
import java.net.MalformedURLException;

/**
 * Represents a GIF/PNG image.  PixelGrabber is used to lookup the
 * width and height.
 *
 * @author Peter Farland
 */
public class LosslessImage extends BitmapImage
{
	public LosslessImage(File imageFile) throws MalformedURLException, IOException
	{
		this(imageFile.getName(), imageFile.toURL().openStream(), imageFile.lastModified());
    }

	public LosslessImage(String location, InputStream inputStream, long modified)
	{
        this.location = location;
		this.modified = modified;
        byte[] bytes = FileUtils.toByteArray(inputStream);
		Image image = ImageUtil.getImage(bytes);
        init(image);
	}

	public LosslessImage(URL imageURL)
	{
		Image image = Toolkit.getDefaultToolkit().getImage(imageURL);

		try
		{
			URLConnection conn = imageURL.openConnection();
			location = imageURL.toString();
			modified = conn.getLastModified();
		}
        catch (InternalError ie)
        {
            if (Trace.error)
            {
                ie.printStackTrace();
            }
            throw new InternalError("An error occurred because there is no graphics environment available.  Please set the headless-server setting in the configuration file to true.");
        }
        catch (NoClassDefFoundError ce)
        {
            if (Trace.error)
            {
                ce.printStackTrace();
            }
            throw new InternalError("An error occurred because there is no graphics environment available.  Please set the headless-server setting in the configuration file to true.");
        }
		catch (IOException ioe)
		{
			throw new RuntimeException("Error reading image from URL. " + ioe.getMessage());
		}

		init(image);
	}

	public LosslessImage(Image image)
	{
		location = "Synthetic";
		modified = System.currentTimeMillis();
		init(image);
	}

	private void init(Image image)
	{
        PixelGrabber pixelGrabber = ImageUtil.getPixelGrabber(image, location);

		width = pixelGrabber.getWidth();
		height = pixelGrabber.getHeight();
		Object p = pixelGrabber.getPixels();

		if (p != null)
		{
			Class ct = p.getClass().getComponentType();
			if (ct != null)
			{
				if (ct.equals(Integer.TYPE))
					pixels = (int[])p;
				else if (ct.equals(Byte.TYPE))
					throw new IllegalStateException("int[] of pixels expected, received byte[] instead.");
			}
		}
	}

	public int[] getPixels()
	{
		return pixels;
	}

	public void dispose()
	{

	}

	protected int[] pixels;
}
