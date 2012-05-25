/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image.spi;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.ImageObserver;
import java.awt.image.RenderedImage;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.renderable.DeferRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.RedRable;
import org.apache.flex.forks.batik.util.ParsedURL;

/**
 * This Image tag registy entry is setup to wrap the core JDK
 * Image stream tools.  
 */
public class JDKRegistryEntry extends AbstractRegistryEntry 
    implements URLRegistryEntry {

    /**
     * The priority of this entry.
     * This entry should in most cases be the last entry.
     * but if one wishes one could set a priority higher and be called
     * afterwords
     */
    public final static float PRIORITY = 
        1000*MagicNumberRegistryEntry.PRIORITY;

    public JDKRegistryEntry() {
        super ("JDK", PRIORITY, new String[0], new String [] {"image/gif"});
    }

    /**
     * Check if the Stream references an image that can be handled by
     * this format handler.  The input stream passed in should be
     * assumed to support mark and reset.
     *
     * If this method throws a StreamCorruptedException then the
     * InputStream will be closed and a new one opened (if possible).
     *
     * This method should only throw a StreamCorruptedException if it
     * is unable to restore the state of the InputStream
     * (i.e. mark/reset fails basically).  
     */
    public boolean isCompatibleURL(ParsedURL purl) {
        try {
            new URL(purl.toString());
        } catch (MalformedURLException mue) {
            // No sense in trying it if we can't build a URL out of it.
            return false;
        }
        return true;
    }

    /**
     * Decode the URL into a RenderableImage
     *
     * @param purl URL of the image.
     * @param needRawData If true the image returned should not have
     *                    any default color correction the file may 
     *                    specify applied.  
     */
    public Filter handleURL(ParsedURL purl, boolean needRawData) {
        
        final URL url;
        try {
            url = new URL(purl.toString());
        } catch (MalformedURLException mue) {
            return null;
        }

        final DeferRable  dr  = new DeferRable();
        final String      errCode;
        final Object []   errParam;
        if (purl != null) {
            errCode  = ERR_URL_FORMAT_UNREADABLE;
            errParam = new Object[] {"JDK", url};
        } else {
            errCode  = ERR_STREAM_FORMAT_UNREADABLE;
            errParam = new Object[] {"JDK"};
        }

        Thread t = new Thread() {
                public void run() {
                    Filter filt = null;

                    Toolkit tk = Toolkit.getDefaultToolkit();
                    Image img = tk.createImage(url);

                    if (img != null) {
                        RenderedImage ri = loadImage(img, dr);
                        if (ri != null) {
                            filt = new RedRable(GraphicsUtil.wrap(ri));
                        }
                    }

                    if (filt == null)
                        filt = ImageTagRegistry.getBrokenLinkImage
                            (this, errCode, errParam);
                    
                    dr.setSource(filt);
                }
            };
        t.start();
        return dr;
    }

    // Stuff for Image Loading.
    public RenderedImage loadImage(Image img, final DeferRable  dr) {
        // In some cases the image will be a
        // BufferedImage (subclass of RenderedImage).
        if (img instanceof RenderedImage)
            return (RenderedImage)img;

        MyImgObs observer = new MyImgObs();
        Toolkit.getDefaultToolkit().prepareImage(img, -1, -1, observer);
        observer.waitTilWidthHeightDone();
        if (observer.imageError)
            return null;
        int width  = observer.width;
        int height = observer.height;
        dr.setBounds(new Rectangle2D.Double(0, 0, width, height));

        // Build the image to draw into.
        BufferedImage bi = new BufferedImage
            (width, height, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2d = bi.createGraphics();
        
        // Wait till the image is fully loaded.
        observer.waitTilImageDone();
        if (observer.imageError)
            return null;
        dr.setProperties(new HashMap());

        g2d.drawImage(img, 0, 0, null);
        g2d.dispose();

        return bi;
    }


    public static class MyImgObs implements ImageObserver {
        boolean widthDone = false;
        boolean heightDone = false;
        boolean imageDone = false;
        int width = -1;
        int height = -1;
        boolean imageError = false;

        int IMG_BITS = ALLBITS|ERROR|ABORT;

        public void clear() {
            width=-1;
            height=-1;
            widthDone = false;
            heightDone = false;
            imageDone       = false;
        }

        public boolean imageUpdate(Image img, int infoflags, 
                                   int x, int y, int width, int height) {
            synchronized (this) {
                boolean notify = false;

                if ((infoflags & WIDTH)   != 0) this.width  = width;
                if ((infoflags & HEIGHT)  != 0) this.height = height;

                if ((infoflags & ALLBITS) != 0) {
                    this.width  = width;
                    this.height = height;
                }

                if ((infoflags & IMG_BITS) != 0) {
                    if ((!widthDone) || (!heightDone) || (!imageDone)) {
                        widthDone  = true;
                        heightDone = true;
                        imageDone  = true;
                        notify     = true;
                    }
                    if ((infoflags & ERROR) != 0) {
                        imageError = true;
                    }
                }


                if ((!widthDone) && (this.width != -1)) {
                    notify = true;
                    widthDone = true;
                }
                if ((!heightDone) && (this.height != -1)) {
                    notify = true;
                    heightDone = true;
                }

                if (notify)
                    notifyAll();
            }
            return true;
        }

        public synchronized void waitTilWidthHeightDone() {
            while ((!widthDone) || (!heightDone)) {
                try {
                    // Wait for someone to set xxxDone
                    wait();
                }
                catch(InterruptedException ie) { 
                    // Loop around again see if src is set now...
                }
            }
        }
        public synchronized void waitTilWidthDone() {
            while (!widthDone) {
                try {
                    // Wait for someone to set xxxDone
                    wait();
                }
                catch(InterruptedException ie) { 
                    // Loop around again see if src is set now...
                }
            }
        }
        public synchronized void waitTilHeightDone() {
            while (!heightDone) {
                try {
                    // Wait for someone to set xxxDone
                    wait();
                }
                catch(InterruptedException ie) { 
                    // Loop around again see if src is set now...
                }
            }
        }

        public synchronized void waitTilImageDone() {
            while (!imageDone) {
                try {
                    // Wait for someone to set xxxDone
                    wait();
                }
                catch(InterruptedException ie) { 
                    // Loop around again see if src is set now...
                }
            }
        }
    }

}
