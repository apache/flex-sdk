/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.ext.awt.image.codec.tiff;

import  org.apache.flex.forks.batik.ext.awt.image.codec.ImageDecodeParam;

/**
 * An instance of <code>ImageDecodeParam</code> for decoding images in
 * the TIFF format.
 *
 * <p> To determine the number of images present in a TIFF file, use
 * the <code>getNumPages()</code> method on the
 * <code>ImageDecoder</code> object that will be used to perform the
 * decoding.  The desired page number may be passed as an argument to
 * the <code>ImageDecoder.decodeAsRaster)()</code> or
 * <code>decodeAsRenderedImage()</code> methods.
 *
 * <p> For TIFF Palette color images, the colorMap always has entries
 * of short data type, the color Black being represented by 0,0,0 and 
 * White by 65536,65536,65536. In order to display these images, the 
 * default behavior is to dither the short values down to 8 bits. 
 * The dithering is done by calling the <code>decode16BitsTo8Bits</code> 
 * method for each short value that needs to be dithered. The method has
 * the following implementation:
 * <code>
 *       byte b;
 *       short s;
 *       s = s & 0xffff;
 *       b = (byte)((s >> 8) & 0xff);
 * </code>
 * If a different algorithm is to be used for the dithering, this class
 * should be subclassed and an appropriate implementation should be
 * provided for the <code>decode16BitsTo8Bits</code> method in the subclass.
 *
 * <p>If the palette contains image data that is signed short, as specified
 * by the SampleFormat tag, the dithering is done by calling 
 * <code>decodeSigned16BitsTo8Bits</code> instead. The method has the 
 * following implementation:
 * <code>
 *       byte b;
 *       short s;
 *       b = (byte)((s + Short.MIN_VALUE) >> 8);
 * </code>
 * In order to use a different algorithm for the dithering, this class 
 * should be subclassed and the method overridden.
 *
 * <p> If it is desired that the Palette be decoded such that the output
 * image is of short data type and no dithering is performed, the 
 * <code>setDecodePaletteAsShorts</code> method should be used. 
 *
 * <p><b> This class is not a committed part of the JAI API.  It may
 * be removed or changed in future releases of JAI.</b>
 *
 * @see TIFFDirectory
 */
public class TIFFDecodeParam implements ImageDecodeParam {

    private boolean decodePaletteAsShorts = false;
    private Long ifdOffset = null;
    private boolean convertJPEGYCbCrToRGB = true;
    
    /** Constructs a default instance of <code>TIFFDecodeParam</code>. */
    public TIFFDecodeParam() {
    }

    /** 
     * If set, the entries in the palette will be decoded as shorts
     * and no short to byte lookup will be applied to them.
     */
    public void setDecodePaletteAsShorts(boolean decodePaletteAsShorts) {
	this.decodePaletteAsShorts = decodePaletteAsShorts;
    }
    
    /**
     * Returns <code>true</code> if palette entries will be decoded as
     * shorts, resulting in an output image with short datatype.
     */ 
    public boolean getDecodePaletteAsShorts() {
	return decodePaletteAsShorts;
    }

    /** 
     * Returns an unsigned 8 bit value computed by dithering the unsigned 
     * 16 bit value. Note that the TIFF specified short datatype is an
     * unsigned value, while Java's <code>short</code> datatype is a 
     * signed value. Therefore the Java <code>short</code> datatype cannot
     * be used to store the TIFF specified short value. A Java 
     * <code>int</code> is used as input instead to this method. The method
     * deals correctly only with 16 bit unsigned values.
     */
    public byte decode16BitsTo8Bits(int s) {
	return (byte)((s >> 8) & 0xffff);
    }

    /** 
     * Returns an unsigned 8 bit value computed by dithering the signed 
     * 16 bit value. This method deals correctly only with values in the 
     * 16 bit signed range.
     */
    public byte decodeSigned16BitsTo8Bits(short s) {
	return (byte)((s + Short.MIN_VALUE) >> 8);
    }

    /**
     * Sets the offset in the stream from which to read the image.  There
     * must be an Image File Directory (IFD) at that position or an error
     * will occur.  If <code>setIFDOffset()</code> is never invoked then
     * the decoder will assume that the TIFF stream is at the beginning of
     * the 8-byte image header.  If the directory offset is set and a page
     * number is supplied to the TIFF <code>ImageDecoder</code> then the
     * page will be the zero-relative index of the IFD in linked list of
     * IFDs beginning at the specified offset with a page of zero indicating
     * the directory at that offset.
     */
    public void setIFDOffset(long offset) {
        ifdOffset = new Long(offset);
    }

    /**
     * Returns the value set by <code>setIFDOffset()</code> or
     * <code>null</code> if no value has been set.
     */
    public Long getIFDOffset() {
        return ifdOffset;
    }

    /**
     * Sets a flag indicating whether to convert JPEG-compressed YCbCr data
     * to RGB.  The default value is <code>true</code>.  This flag is
     * ignored if the image data are not JPEG-compressed.
     */
    public void setJPEGDecompressYCbCrToRGB(boolean convertJPEGYCbCrToRGB) {
        this.convertJPEGYCbCrToRGB = convertJPEGYCbCrToRGB;
    }

    /**
     * Whether JPEG-compressed YCbCr data will be converted to RGB.
     */
    public boolean getJPEGDecompressYCbCrToRGB() {
        return convertJPEGYCbCrToRGB;
    }
}
