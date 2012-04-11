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

import java.awt.*;
import java.awt.image.PixelGrabber;
import java.awt.image.ImageObserver;

/**
 * Utility methods for getting images.
 *
 * @author Brian Deitte
 */
// FIXME: there is more duplication in JPEGImage/LosslessImage that could be added here
public class ImageUtil
{
    public static Image getImage(byte[] bytes)
    {
        Image image;
        try
		{
            image = Toolkit.getDefaultToolkit().createImage(bytes);
        }
        catch (InternalError ie)
        {
            if (Trace.error)
            {
                ie.printStackTrace();
            }
            throw new InternalError("An error occurred because there is no graphics environment available.  Please set the headless-server setting in the Flex configuration file to true.");
        }
        catch (NoClassDefFoundError ce)
        {
            if (Trace.error)
            {
                ce.printStackTrace();
            }
            throw new InternalError("An error occurred because there is no graphics environment available.  Please set the headless-server setting in the Flex configuration file to true.");
        }
        return image;
    }

    public static PixelGrabber getPixelGrabber(Image image, String location)
    {
        PixelGrabber pixelGrabber = new PixelGrabber(image, 0, 0, -1, -1, true);

        try
        {
            pixelGrabber.grabPixels();
        }
        catch (InterruptedException interruptedException)
        {
	        if (Trace.error)
	        {
		        interruptedException.printStackTrace();
	        }
            throw new RuntimeException("Failed to grab pixels for image " + location);
        }

	    if (((pixelGrabber.getStatus() & ImageObserver.WIDTH) == 0) ||
			((pixelGrabber.getStatus() & ImageObserver.HEIGHT) == 0))
	    {
		    throw new RuntimeException("Failed to grab pixels for image " + location);
	    }

        return pixelGrabber;
    }
}
