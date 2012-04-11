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
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.image.PixelGrabber;
import java.net.URL;
import java.net.URLConnection;

/**
 * Represents a JPEG image.  PixelGrabber is used to lookup the width
 * and height.
 *
 * @author Peter Farland
 */
public class JPEGImage extends BitmapImage
{
	public JPEGImage(String location, long modified, long length, InputStream inputStream)
        throws IOException
	{
        this.location = location;
        this.modified = modified;
        this.length = length;
        this.inputStream = inputStream;
        Image image = ImageUtil.getImage(getData());
    	init(image);
	}

	public JPEGImage(File imageFile)
	{
		try
		{
			location = imageFile.getAbsolutePath();
			modified = imageFile.lastModified();
			length = imageFile.length();
			inputStream = new FileInputStream(imageFile);

			Image image = Toolkit.getDefaultToolkit().getImage(location);

			init(image);
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
		catch (Exception ex)
		{
			throw new RuntimeException("Error reading image from file " + location + ". " + ex.getMessage());
		}
	}

	public JPEGImage(URL imageURL)
	{
		try
		{
			Image image = Toolkit.getDefaultToolkit().getImage(imageURL);
			inputStream = imageURL.openStream();

			URLConnection conn = imageURL.openConnection();
			location = imageURL.toString();
			modified = conn.getLastModified();
			length = conn.getContentLength();

			init(image);
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
		catch (Exception ex)
		{
			throw new RuntimeException("Error reading image from URL. " + location + ". " + ex.getMessage());
		}
	}

	public JPEGImage(InputStream is, long length)
	{
		inputStream = is;
		location = "Synthetic";
		modified = System.currentTimeMillis();
		this.length = length;
	}

	private void init(Image image)
	{
        PixelGrabber pixelGrabber = ImageUtil.getPixelGrabber(image, location);
		width = pixelGrabber.getWidth();
		height = pixelGrabber.getHeight();
	}

	public long getLength()
	{
		return length;
	}

	public byte[] getData() throws IOException
	{
		if (data == null)
		{
			data = FileUtils.toByteArray(inputStream, (int)length);
		}

		return data;
	}

	public void dispose()
	{
		try
		{
			inputStream.close();
		}
		catch (IOException ioe)
		{
		}
	}

	protected InputStream inputStream;
	protected long length;
	protected byte[] data;
}
