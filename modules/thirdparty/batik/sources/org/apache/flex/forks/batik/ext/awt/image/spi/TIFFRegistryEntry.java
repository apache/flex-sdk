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

import java.io.IOException;
import java.io.InputStream;

import org.apache.flex.forks.batik.ext.awt.image.codec.SeekableStream;
import org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFDecodeParam;
import org.apache.flex.forks.batik.ext.awt.image.codec.tiff.TIFFImage;
import org.apache.flex.forks.batik.ext.awt.image.renderable.DeferRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.RedRable;
import org.apache.flex.forks.batik.ext.awt.image.rendered.Any2sRGBRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.util.ParsedURL;

public class TIFFRegistryEntry 
    extends MagicNumberRegistryEntry {

    static final byte [] sig1 = {(byte)0x49, (byte)0x49, 42,  0};
    static final byte [] sig2 = {(byte)0x4D, (byte)0x4D,  0, 42};

    static MagicNumberRegistryEntry.MagicNumber [] magicNumbers = {
        new MagicNumberRegistryEntry.MagicNumber(0, sig1),
        new MagicNumberRegistryEntry.MagicNumber(0, sig2) };

    static final String [] exts      = {"tiff", "tif" };
    static final String [] mimeTypes = {"image/tiff", "image/tif" };

    public TIFFRegistryEntry() {
        super("TIFF", exts, mimeTypes, magicNumbers);
    }

    /**
     * Decode the Stream into a RenderableImage
     *
     * @param inIS The input stream that contains the image.
     * @param origURL The original URL, if any, for documentation
     *                purposes only.  This may be null.
     * @param needRawData If true the image returned should not have
     *                    any default color correction the file may 
     *                    specify applied.  */
    public Filter handleStream(InputStream inIS, 
                               ParsedURL   origURL,
                               boolean needRawData) {

        final DeferRable  dr  = new DeferRable();
        final InputStream is  = inIS;
        final String      errCode;
        final Object []   errParam;
        if (origURL != null) {
            errCode  = ERR_URL_FORMAT_UNREADABLE;
            errParam = new Object[] {"TIFF", origURL};
        } else {
            errCode  = ERR_STREAM_FORMAT_UNREADABLE;
            errParam = new Object[] {"TIFF"};
        }

        Thread t = new Thread() {
                public void run() {
                    Filter filt;
                    try {
                        TIFFDecodeParam param = new TIFFDecodeParam();
                        SeekableStream ss = 
                            SeekableStream.wrapInputStream(is, true);
                        CachableRed cr = new TIFFImage(ss, param, 0);
                        cr = new Any2sRGBRed(cr);
                        filt = new RedRable(cr);
                    } catch (IOException ioe) {
                        filt = ImageTagRegistry.getBrokenLinkImage
                            (this, errCode, errParam);
                    } catch (ThreadDeath td) {
                        throw td;
                    } catch (Throwable t) {
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
