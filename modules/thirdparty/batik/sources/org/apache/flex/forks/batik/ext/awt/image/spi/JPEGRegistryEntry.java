/*

   Copyright 2001-2003  The Apache Software Foundation 

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

import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.WritableRaster;
import java.io.IOException;
import java.io.InputStream;

import org.apache.flex.forks.batik.ext.awt.image.GraphicsUtil;
import org.apache.flex.forks.batik.ext.awt.image.renderable.DeferRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.RedRable;
import org.apache.flex.forks.batik.ext.awt.image.rendered.Any2sRGBRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.FormatRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.util.ParsedURL;

import com.sun.image.codec.jpeg.JPEGCodec;
import com.sun.image.codec.jpeg.JPEGImageDecoder;
import com.sun.image.codec.jpeg.TruncatedFileException;

public class JPEGRegistryEntry 
    extends MagicNumberRegistryEntry {

    static final byte [] sigJPEG   = {(byte)0xFF, (byte)0xd8, 
                                      (byte)0xFF};
    static final String [] exts      = {"jpeg", "jpg" };
    static final String [] mimeTypes = {"image/jpeg", "image/jpg" };
    static final MagicNumber [] magicNumbers = {
        new MagicNumber(0, sigJPEG)
    };

    public JPEGRegistryEntry() {
        super("JPEG", exts, mimeTypes, magicNumbers);
    }

    /**
     * Decode the Stream into a RenderableImage
     *
     * @param inIS The input stream that contains the image.
     * @param origURL The original URL, if any, for documentation
     *                purposes only.  This may be null.
     * @param needRawData If true the image returned should not have
     *                    any default color correction the file may 
     *                    specify applied.  
     */
    public Filter handleStream(InputStream inIS, 
                               ParsedURL   origURL,
                               boolean     needRawData) {
        final DeferRable  dr  = new DeferRable();
        final InputStream is  = inIS;
        final String      errCode;
        final Object []   errParam;
        if (origURL != null) {
            errCode  = ERR_URL_FORMAT_UNREADABLE;
            errParam = new Object[] {"JPEG", origURL};
        } else {
            errCode  = ERR_STREAM_FORMAT_UNREADABLE;
            errParam = new Object[] {"JPEG"};
        }

        Thread t = new Thread() {
                public void run() {
                    Filter filt;
                    try{
                        JPEGImageDecoder decoder;
                        decoder = JPEGCodec.createJPEGDecoder(is);
                        BufferedImage image;
                        try { 
                            image   = decoder.decodeAsBufferedImage();
                        } catch (TruncatedFileException tfe) {
                            image = tfe.getBufferedImage();
                            // Should probably draw some indication
                            // that this is a partial image....
                            if (image == null)
                                throw new IOException
                                    ("JPEG File was truncated");
                        }
                        dr.setBounds(new Rectangle2D.Double
                                     (0, 0, image.getWidth(), 
                                      image.getHeight()));
                        CachableRed cr;
                        cr = GraphicsUtil.wrap(image);
                        cr = new Any2sRGBRed(cr);
                        cr = new FormatRed(cr, GraphicsUtil.sRGB_Unpre);
                        WritableRaster wr = (WritableRaster)cr.getData();
                        ColorModel cm = cr.getColorModel();
                        image = new BufferedImage
                            (cm, wr, cm.isAlphaPremultiplied(), null);
                        cr = GraphicsUtil.wrap(image);
                        filt = new RedRable(cr);
                    } catch (IOException ioe) {
                        // Something bad happened here...
                        filt = ImageTagRegistry.getBrokenLinkImage
                            (this, errCode, errParam);
                    }

                    dr.setSource(filt);
                }
            };
        t.start();
        return dr;
    }
}
