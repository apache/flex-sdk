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
package org.apache.flex.forks.batik.ext.awt.image.codec.tiff;

import java.awt.Rectangle;
import java.awt.Transparency;
import java.awt.color.ColorSpace;
import java.awt.image.ColorModel;
import java.awt.image.ComponentColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.DataBufferInt;
import java.awt.image.DataBufferShort;
import java.awt.image.DataBufferUShort;
import java.awt.image.IndexColorModel;
import java.awt.image.MultiPixelPackedSampleModel;
import java.awt.image.PixelInterleavedSampleModel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.DataFormatException;
import java.util.zip.Inflater;

import org.apache.flex.forks.batik.ext.awt.image.codec.SeekableStream;
import org.apache.flex.forks.batik.ext.awt.image.rendered.AbstractRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;

import com.sun.image.codec.jpeg.JPEGCodec;
import com.sun.image.codec.jpeg.JPEGDecodeParam;
import com.sun.image.codec.jpeg.JPEGImageDecoder;

public class TIFFImage extends AbstractRed {

    // Compression types
    public static final int COMP_NONE      = 1;
    public static final int COMP_FAX_G3_1D = 2;
    public static final int COMP_FAX_G3_2D = 3;
    public static final int COMP_FAX_G4_2D = 4;
    public static final int COMP_LZW       = 5;
    public static final int COMP_JPEG_OLD  = 6;
    public static final int COMP_JPEG_TTN2 = 7;
    public static final int COMP_PACKBITS  = 32773;
    public static final int COMP_DEFLATE   = 32946;

    // Image types
    private static final int TYPE_UNSUPPORTED = -1;
    private static final int TYPE_BILEVEL      = 0;
    private static final int TYPE_GRAY_4BIT    = 1;
    private static final int TYPE_GRAY         = 2;
    private static final int TYPE_GRAY_ALPHA   = 3;
    private static final int TYPE_PALETTE      = 4;
    private static final int TYPE_RGB          = 5;
    private static final int TYPE_RGB_ALPHA    = 6;
    private static final int TYPE_YCBCR_SUB    = 7;
    private static final int TYPE_GENERIC      = 8;

    // Incidental tags
    private static final int TIFF_JPEG_TABLES       = 347;
    private static final int TIFF_YCBCR_SUBSAMPLING = 530;

    SeekableStream stream;
    int tileSize;
    int tilesX, tilesY;
    long[] tileOffsets;
    long[] tileByteCounts;
    char[] colormap;
    int sampleSize;
    int compression;
    byte[] palette;
    int numBands;

    int chromaSubH;
    int chromaSubV;

    // Fax compression related variables
    long tiffT4Options;
    long tiffT6Options;
    int fillOrder;

    // LZW compression related variable
    int predictor;

    // TTN2 JPEG related variables
    JPEGDecodeParam decodeParam = null;
    boolean colorConvertJPEG = false;

    // DEFLATE variables
    Inflater inflater = null;

    // Endian-ness indicator
    boolean isBigEndian;
    
    int imageType;
    boolean isWhiteZero = false;
    int dataType;

    boolean decodePaletteAsShorts;
    boolean tiled;

    // Decoders
    private TIFFFaxDecoder decoder = null;
    private TIFFLZWDecoder lzwDecoder = null;

    /**
     * Decode a buffer of data into a Raster with the specified location.
     *
     * @param data buffer contain an interchange or abbreviated datastream.
     * @param decodeParam decoding parameters; may be null unless the
     *        data buffer contains an abbreviated datastream in which case
     *        it may not be null or an error will occur.
     * @param colorConvert whether to perform color conversion; in this
     *        case that would be limited to YCbCr-to-RGB.
     * @param minX the X position of the returned Raster.
     * @param minY the Y position of the returned Raster.
     */
    private static final Raster decodeJPEG(byte[] data,
                                           JPEGDecodeParam decodeParam,
                                           boolean colorConvert,
                                           int minX,
                                           int minY) {
        // Create an InputStream from the compressed data array.
        ByteArrayInputStream jpegStream = new ByteArrayInputStream(data);

        // Create a decoder.
        JPEGImageDecoder decoder = decodeParam == null ?
            JPEGCodec.createJPEGDecoder(jpegStream) :
            JPEGCodec.createJPEGDecoder(jpegStream,
                                        decodeParam);

        // Decode the compressed data into a Raster.
        Raster jpegRaster;
        try {
            jpegRaster = colorConvert ?
                decoder.decodeAsBufferedImage().getWritableTile(0, 0) :
                decoder.decodeAsRaster();
        } catch (IOException ioe) {
            throw new RuntimeException("TIFFImage13");
        }

        // Translate the decoded Raster to the specified location and return.
        return jpegRaster.createTranslatedChild(minX, minY);
    }

    /**
     * Inflates <code>deflated</code> into <code>inflated</code> using the
     * <code>Inflater</code> constructed during class instantiation.
     */
    private final void inflate(byte[] deflated, byte[] inflated) {
        inflater.setInput(deflated);
        try {
            inflater.inflate(inflated);
        } catch(DataFormatException dfe) {
            throw new RuntimeException("TIFFImage17"+": "+
                                       dfe.getMessage());
        }
        inflater.reset();
    }

    private static SampleModel createPixelInterleavedSampleModel
        (int dataType, int tileWidth, int tileHeight, int bands) {
        int [] bandOffsets = new int[bands];
        for (int i=0; i<bands; i++) 
            bandOffsets[i] = i;
        return new PixelInterleavedSampleModel
            (dataType, tileWidth, tileHeight, bands,
             tileWidth*bands, bandOffsets);
    }

    /**
     * Return as a long[] the value of a TIFF_LONG or TIFF_SHORT field.
     */
    private final long[] getFieldAsLongs(TIFFField field) {
        long[] value = null;

        if(field.getType() == TIFFField.TIFF_SHORT) {
            char[] charValue = field.getAsChars();
            value = new long[charValue.length];
            for(int i = 0; i < charValue.length; i++) {
                value[i] = charValue[i]  & 0xffff;
            }
        } else if(field.getType() == TIFFField.TIFF_LONG) {
            value = field.getAsLongs();
        } else {
            throw new RuntimeException();
        }

        return value;
    }

    /**
     * Constructs a TIFFImage that acquires its data from a given
     * SeekableStream and reads from a particular IFD of the stream.
     * The index of the first IFD is 0.
     *
     * @param stream the SeekableStream to read from.
     * @param param an instance of TIFFDecodeParam, or null.
     * @param directory the index of the IFD to read from.
     */
    public TIFFImage(SeekableStream stream,
                     TIFFDecodeParam param,
                     int directory)
        throws IOException {

        this.stream = stream;
        if (param == null) {
            param = new TIFFDecodeParam();
        } 

        decodePaletteAsShorts = param.getDecodePaletteAsShorts();

        // Read the specified directory.
        TIFFDirectory dir = param.getIFDOffset() == null ?
            new TIFFDirectory(stream, directory) :
            new TIFFDirectory(stream, param.getIFDOffset().longValue(),
                              directory);

        // Get the number of samples per pixel
        TIFFField sfield = dir.getField(TIFFImageDecoder.TIFF_SAMPLES_PER_PIXEL);
        int samplesPerPixel = sfield == null ? 1 : (int)sfield.getAsLong(0);

        // Read the TIFF_PLANAR_CONFIGURATION field
        TIFFField planarConfigurationField = 
            dir.getField(TIFFImageDecoder.TIFF_PLANAR_CONFIGURATION);
        char[] planarConfiguration = planarConfigurationField == null ?
            new char[] {1} :
            planarConfigurationField.getAsChars();

            // Support planar format (band sequential) only for 1 sample/pixel.
            if (planarConfiguration[0] != 1 && samplesPerPixel != 1) {
                throw new RuntimeException("TIFFImage0");
            }

            // Read the TIFF_BITS_PER_SAMPLE field
            TIFFField bitsField = 
                dir.getField(TIFFImageDecoder.TIFF_BITS_PER_SAMPLE);
            char[] bitsPerSample = null;
            if(bitsField != null) {
                bitsPerSample = bitsField.getAsChars();
            } else {
                bitsPerSample = new char[] {1};

                // Ensure that all samples have the same bit depth.
                for (int i = 1; i < bitsPerSample.length; i++) {
                    if (bitsPerSample[i] != bitsPerSample[0]) {
                        throw new RuntimeException("TIFFImage1");
                    }
                }
            }
            sampleSize = bitsPerSample[0];

            // Read the TIFF_SAMPLE_FORMAT tag to see whether the data might be
            // signed or floating point
            TIFFField sampleFormatField = 
                dir.getField(TIFFImageDecoder.TIFF_SAMPLE_FORMAT);

            char[] sampleFormat = null;
            if (sampleFormatField != null) {
                sampleFormat = sampleFormatField.getAsChars();

                // Check that all the samples have the same format
                for (int l=1; l<sampleFormat.length; l++) {
                    if (sampleFormat[l] != sampleFormat[0]) {
                        throw new RuntimeException("TIFFImage2");
                    }
                }

            } else {
                sampleFormat = new char[] {1};
            }

            // Set the data type based on the sample size and format.
            boolean isValidDataFormat = false;
            switch(sampleSize) {
            case 1:
            case 4:
            case 8:
                if(sampleFormat[0] != 3) {
                    // Ignore whether signed or unsigned: treat all as unsigned.
                    dataType = DataBuffer.TYPE_BYTE;
                    isValidDataFormat = true;
                }
                break;
            case 16:
                if(sampleFormat[0] != 3) {
                    dataType = sampleFormat[0] == 2 ?
                        DataBuffer.TYPE_SHORT : DataBuffer.TYPE_USHORT;
                    isValidDataFormat = true;
                }
                break;
            case 32:
              if (sampleFormat[0] == 3)
                isValidDataFormat = false;
              else {
                dataType = DataBuffer.TYPE_INT;
                isValidDataFormat = true;
              }
              break;
            }

            if(!isValidDataFormat) {
                throw new RuntimeException("TIFFImage3");
            }

            // Figure out what compression if any, is being used.
            TIFFField compField = dir.getField(TIFFImageDecoder.TIFF_COMPRESSION);
            compression = compField == null ? COMP_NONE : compField.getAsInt(0);

            // Get the photometric interpretation.
            int photometricType = (int)dir.getFieldAsLong(
                                                          TIFFImageDecoder.TIFF_PHOTOMETRIC_INTERPRETATION);

            // Determine which kind of image we are dealing with.
            imageType = TYPE_UNSUPPORTED;
            switch(photometricType) {
            case 0: // WhiteIsZero
                isWhiteZero = true;
            case 1: // BlackIsZero
                if(sampleSize == 1 && samplesPerPixel == 1) {
                    imageType = TYPE_BILEVEL;
                } else if(sampleSize == 4 && samplesPerPixel == 1) {
                    imageType = TYPE_GRAY_4BIT;
                } else if(sampleSize % 8 == 0) {
                    if(samplesPerPixel == 1) {
                        imageType = TYPE_GRAY;
                    } else if(samplesPerPixel == 2) {
                        imageType = TYPE_GRAY_ALPHA;
                    } else {
                        imageType = TYPE_GENERIC;
                    }
                }
                break;
            case 2: // RGB
                if(sampleSize % 8 == 0) {
                    if(samplesPerPixel == 3) {
                        imageType = TYPE_RGB;
                    } else if(samplesPerPixel == 4) {
                        imageType = TYPE_RGB_ALPHA;
                    } else {
                        imageType = TYPE_GENERIC;
                    }
                }
                break;
            case 3: // RGB Palette
                if(samplesPerPixel == 1 &&
                   (sampleSize == 4 || sampleSize == 8 || sampleSize == 16)) {
                    imageType = TYPE_PALETTE;
                }
                break;
            case 4: // Transparency mask
                if(sampleSize == 1 && samplesPerPixel == 1) {
                    imageType = TYPE_BILEVEL;
                }
                break;
            case 6: // YCbCr
                if(compression == COMP_JPEG_TTN2 &&
                   sampleSize == 8 && samplesPerPixel == 3) {
                    // Set color conversion flag.
                    colorConvertJPEG = param.getJPEGDecompressYCbCrToRGB();

                    // Set type to RGB if color converting.
                    imageType = colorConvertJPEG ? TYPE_RGB : TYPE_GENERIC;
                } else {
                    TIFFField chromaField = dir.getField(TIFF_YCBCR_SUBSAMPLING);
                    if(chromaField != null) {
                        chromaSubH = chromaField.getAsInt(0);
                        chromaSubV = chromaField.getAsInt(1);
                    } else {
                        chromaSubH = chromaSubV = 2;
                    }

                    if(chromaSubH*chromaSubV == 1) {
                        imageType = TYPE_GENERIC;
                    } else if(sampleSize == 8 && samplesPerPixel == 3) {
                        imageType = TYPE_YCBCR_SUB;
                    }
                }
                break;
            default: // Other including CMYK, CIE L*a*b*, unknown.
                if(sampleSize % 8 == 0) {
                    imageType = TYPE_GENERIC;
                }
            }

            // Bail out if not one of the supported types.
            if(imageType == TYPE_UNSUPPORTED) {
                throw new RuntimeException("TIFFImage4");
            }

            // Set basic image layout
            Rectangle bounds = new Rectangle
                (0, 0,
                 (int)dir.getFieldAsLong(TIFFImageDecoder.TIFF_IMAGE_WIDTH),
                 (int)dir.getFieldAsLong(TIFFImageDecoder.TIFF_IMAGE_LENGTH));

            // Set a preliminary band count. This may be changed later as needed.
            numBands = samplesPerPixel;

            // Figure out if any extra samples are present.
            TIFFField efield = dir.getField(TIFFImageDecoder.TIFF_EXTRA_SAMPLES);
            int extraSamples = efield == null ? 0 : (int)efield.getAsLong(0);

            int tileWidth, tileHeight;
            if (dir.getField(TIFFImageDecoder.TIFF_TILE_OFFSETS) != null) {
                tiled = true;
                // Image is in tiled format
                tileWidth = 
                    (int)dir.getFieldAsLong(TIFFImageDecoder.TIFF_TILE_WIDTH);
                tileHeight = 
                    (int)dir.getFieldAsLong(TIFFImageDecoder.TIFF_TILE_LENGTH);
                tileOffsets = 
                    (dir.getField(TIFFImageDecoder.TIFF_TILE_OFFSETS)).getAsLongs();
                tileByteCounts = 
                    getFieldAsLongs(dir.getField(TIFFImageDecoder.TIFF_TILE_BYTE_COUNTS));

            } else {
                tiled = false;

                // Image is in stripped format, looks like tiles to us
                // Note: Some legacy files may have tile width and height
                // written but use the strip offsets and byte counts fields
                // instead of the tile offsets and byte counts. Therefore
                // we default here to the tile dimensions if they are written.
                tileWidth =
                    dir.getField(TIFFImageDecoder.TIFF_TILE_WIDTH) != null ?
                    (int)dir.getFieldAsLong(TIFFImageDecoder.TIFF_TILE_WIDTH) :
                    bounds.width;
                TIFFField field =
                    dir.getField(TIFFImageDecoder.TIFF_ROWS_PER_STRIP);
                if (field == null) {
                    // Default is infinity (2^32 -1), basically the entire image
		
                    tileHeight =
                        dir.getField(TIFFImageDecoder.TIFF_TILE_LENGTH) != null ?
                        (int)dir.getFieldAsLong(TIFFImageDecoder.TIFF_TILE_LENGTH):
                        bounds.height;
                } else {
                    long l = field.getAsLong(0);
                    long infinity = 1;
                    infinity = (infinity << 32) - 1;
                    if (l == infinity) {   
                        // 2^32 - 1 (effectively infinity, entire image is 1 strip)
                        tileHeight = bounds.height;
                    } else {
                        tileHeight = (int)l;
                    }
                }

                TIFFField tileOffsetsField = 
                    dir.getField(TIFFImageDecoder.TIFF_STRIP_OFFSETS);
                if (tileOffsetsField == null) {
                    throw new RuntimeException("TIFFImage5");
                } else {
                    tileOffsets = getFieldAsLongs(tileOffsetsField);
                }

                TIFFField tileByteCountsField = 
                    dir.getField(TIFFImageDecoder.TIFF_STRIP_BYTE_COUNTS);
                if (tileByteCountsField == null) {
                    throw new RuntimeException("TIFFImage6");
                } else {
                    tileByteCounts = getFieldAsLongs(tileByteCountsField);
                }
            }

            // Calculate number of tiles and the tileSize in bytes
            tilesX = (bounds.width + tileWidth - 1)/tileWidth;
            tilesY = (bounds.height + tileHeight - 1)/tileHeight;
            tileSize = tileWidth * tileHeight * numBands;

            // Check whether big endian or little endian format is used.
            isBigEndian = dir.isBigEndian();

            TIFFField fillOrderField = 
                dir.getField(TIFFImageDecoder.TIFF_FILL_ORDER);
            if (fillOrderField != null) {
                fillOrder = fillOrderField.getAsInt(0);
            } else {
                // Default Fill Order
                fillOrder = 1;
            }

            switch(compression) {
            case COMP_NONE:
            case COMP_PACKBITS:
                // Do nothing.
                break;
            case COMP_DEFLATE:
                inflater = new Inflater();
                break;
            case COMP_FAX_G3_1D:
            case COMP_FAX_G3_2D:
            case COMP_FAX_G4_2D:
                if(sampleSize != 1) {
                    throw new RuntimeException("TIFFImage7"); 
                }

                // Fax T.4 compression options
                if (compression == 3) {
                    TIFFField t4OptionsField = 
                        dir.getField(TIFFImageDecoder.TIFF_T4_OPTIONS);
                    if (t4OptionsField != null) {
                        tiffT4Options = t4OptionsField.getAsLong(0);
                    } else {
                        // Use default value
                        tiffT4Options = 0;
                    }
                }

                // Fax T.6 compression options
                if (compression == 4) {
                    TIFFField t6OptionsField =
                        dir.getField(TIFFImageDecoder.TIFF_T6_OPTIONS);
                    if (t6OptionsField != null) {
                        tiffT6Options = t6OptionsField.getAsLong(0);
                    } else {
                        // Use default value
                        tiffT6Options = 0;
                    }
                }

                // Fax encoding, need to create the Fax decoder.
                decoder = new TIFFFaxDecoder(fillOrder,
                                             tileWidth, tileHeight);
                break;

            case COMP_LZW:
                // LZW compression used, need to create the LZW decoder.
                TIFFField predictorField = 
                    dir.getField(TIFFImageDecoder.TIFF_PREDICTOR);

                if (predictorField == null) {
                    predictor = 1;
                } else {
                    predictor = predictorField.getAsInt(0);
		    
                    if (predictor != 1 && predictor != 2) {
                        throw new RuntimeException("TIFFImage8"); 
                    }
		    
                    if (predictor == 2 && sampleSize != 8) {
                        throw new RuntimeException(sampleSize + 
                                                   "TIFFImage9");
                    }
                }
		
                lzwDecoder = new TIFFLZWDecoder(tileWidth, predictor, 
                                                samplesPerPixel); 
                break;

            case COMP_JPEG_OLD:
                throw new RuntimeException("TIFFImage15");

            case COMP_JPEG_TTN2:
                if(!(sampleSize == 8 &&
                     ((imageType == TYPE_GRAY && samplesPerPixel == 1) ||
                      (imageType == TYPE_PALETTE && samplesPerPixel == 1) ||
                      (imageType == TYPE_RGB && samplesPerPixel == 3)))) {
                    throw new RuntimeException("TIFFImage16");
                }

                // Create decodeParam from JPEGTables field if present.
                if(dir.isTagPresent(TIFF_JPEG_TABLES)) {
                    TIFFField jpegTableField = dir.getField(TIFF_JPEG_TABLES);
                    byte[] jpegTable = jpegTableField.getAsBytes();
                    ByteArrayInputStream tableStream =
                        new ByteArrayInputStream(jpegTable);
                    JPEGImageDecoder decoder =
                        JPEGCodec.createJPEGDecoder(tableStream);
                    decoder.decodeAsRaster();
                    decodeParam = decoder.getJPEGDecodeParam();
                }

                break;
            default:
                throw new RuntimeException("TIFFImage10");
            }

            ColorModel  colorModel  = null;
            SampleModel sampleModel = null;
            switch(imageType) {
            case TYPE_BILEVEL:
            case TYPE_GRAY_4BIT:
                sampleModel = 
                    new MultiPixelPackedSampleModel(dataType,
                                                    tileWidth, 
                                                    tileHeight,
                                                    sampleSize);
                if(imageType == TYPE_BILEVEL) {
                    byte[] map = new byte[] {(byte)(isWhiteZero ? 255 : 0),
                                             (byte)(isWhiteZero ? 0 : 255)};
                    colorModel = new IndexColorModel(1, 2, map, map, map);
                } else {
                    byte [] map = new byte[16];
                    if (isWhiteZero) {
                        for (int i=0; i<map.length; i++)
                            map[i] = (byte)(255-(16*i));
                    } else {
                        for (int i=0; i<map.length; i++)
                            map[i] = (byte)(16*i);
                    }
                    colorModel = new IndexColorModel(4, 16, map, map, map);
                }
                break;

            case TYPE_GRAY:
            case TYPE_GRAY_ALPHA:
            case TYPE_RGB:
            case TYPE_RGB_ALPHA:
                // Create a pixel interleaved SampleModel with decreasing
                // band offsets.
                int[] reverseOffsets = new int[numBands];
                for (int i=0; i<numBands; i++) {
                    reverseOffsets[i] = numBands - 1 - i;
                }
                sampleModel = new PixelInterleavedSampleModel
                    (dataType, tileWidth, tileHeight,
                     numBands, numBands*tileWidth, reverseOffsets);

                if(imageType == TYPE_GRAY) {
                  colorModel = new ComponentColorModel
                    (ColorSpace.getInstance(ColorSpace.CS_GRAY),
                     new int[] { sampleSize }, false, false, 
                     Transparency.OPAQUE, dataType);
                } else if (imageType == TYPE_RGB) {
                  colorModel = new ComponentColorModel
                    (ColorSpace.getInstance(ColorSpace.CS_sRGB),
                     new int[] { sampleSize, sampleSize, sampleSize }, 
                     false, false, Transparency.OPAQUE, dataType);
                } else { // hasAlpha
                    // Transparency.OPAQUE signifies image data that is 
                    // completely opaque, meaning that all pixels have an alpha
                    // value of 1.0. So the extra band gets ignored, which is
                    // what we want.
                    int transparency = Transparency.OPAQUE;
                    if(extraSamples == 1) { // associated (premultiplied) alpha
                        transparency = Transparency.TRANSLUCENT;
                    } else if(extraSamples == 2) { // unassociated alpha
                        transparency = Transparency.BITMASK;
                    }

                    colorModel =
                        createAlphaComponentColorModel(dataType,
                                                       numBands,
                                                       extraSamples == 1,
                                                       transparency);
                }
                break;

            case TYPE_GENERIC:
            case TYPE_YCBCR_SUB:
                // For this case we can't display the image, so we create a
                // SampleModel with increasing bandOffsets, and keep the
                // ColorModel as null, as there is no appropriate ColorModel.

                int[] bandOffsets = new int[numBands];
                for (int i=0; i<numBands; i++) {
                    bandOffsets[i] = i;
                }
		
                sampleModel = new PixelInterleavedSampleModel
                    (dataType, tileWidth, tileHeight,
                     numBands, numBands * tileWidth, bandOffsets);
                colorModel = null;
                break;

            case TYPE_PALETTE:
                // Get the colormap
                TIFFField cfield = dir.getField(TIFFImageDecoder.TIFF_COLORMAP);
                if (cfield == null) {
                    throw new RuntimeException("TIFFImage11");
                } else {
                    colormap = cfield.getAsChars();
                }

                // Could be either 1 or 3 bands depending on whether we use
                // IndexColorModel or not.
                if (decodePaletteAsShorts) {
                    numBands = 3;

                    // If no SampleFormat tag was specified and if the 
                    // sampleSize is less than or equal to 8, then the 
                    // dataType was initially set to byte, but now we want to 
                    // expand the palette as shorts, so the dataType should 
                    // be ushort.
                    if (dataType == DataBuffer.TYPE_BYTE) {
                        dataType = DataBuffer.TYPE_USHORT;
                    }

                    // Data will have to be unpacked into a 3 band short image
                    // as we do not have a IndexColorModel that can deal with
                    // a colormodel whose entries are of short data type.
                    sampleModel = createPixelInterleavedSampleModel
                        (dataType, tileWidth, tileHeight, numBands);

                  colorModel = new ComponentColorModel
                    (ColorSpace.getInstance(ColorSpace.CS_sRGB),
                     new int[] { 16, 16, 16 }, false, false, 
                     Transparency.OPAQUE, dataType);

                } else {

                    numBands = 1;
		
                    if (sampleSize == 4) {
                        // Pixel data will not be unpacked, will use
                        // MPPSM to store packed data and
                        // IndexColorModel to do the unpacking.
                        sampleModel = new MultiPixelPackedSampleModel
                            (DataBuffer.TYPE_BYTE, tileWidth, tileHeight, 
                             sampleSize);
                    } else if (sampleSize == 8) {
                        
                        sampleModel = createPixelInterleavedSampleModel
                            (DataBuffer.TYPE_BYTE, tileWidth, tileHeight,
                             numBands);
                    } else if (sampleSize == 16) {

                        // Here datatype has to be unsigned since we
                        // are storing indices into the
                        // IndexColorModel palette. Ofcourse the
                        // actual palette entries are allowed to be
                        // negative.
                        dataType = DataBuffer.TYPE_USHORT;
                        sampleModel = createPixelInterleavedSampleModel
                            (DataBuffer.TYPE_USHORT, tileWidth, tileHeight,
                             numBands);
                    }
		
                    int bandLength = colormap.length/3;
                    byte r[] = new byte[bandLength];
                    byte g[] = new byte[bandLength];
                    byte b[] = new byte[bandLength];
		
                    int gIndex = bandLength;
                    int bIndex = bandLength * 2;

                    if (dataType == DataBuffer.TYPE_SHORT) {

                        for (int i=0; i<bandLength; i++) {
                            r[i] = param.decodeSigned16BitsTo8Bits
                                ((short)colormap[i]);
                            g[i] = param.decodeSigned16BitsTo8Bits
                                ((short)colormap[gIndex+i]);
                            b[i] = param.decodeSigned16BitsTo8Bits
                                ((short)colormap[bIndex+i]);
                        }

                    } else {

                        for (int i=0; i<bandLength; i++) {
                            r[i] = param.decode16BitsTo8Bits
                                (colormap[i] & 0xffff);
                            g[i] = param.decode16BitsTo8Bits
                                (colormap[gIndex+i] & 0xffff);
                            b[i] = param.decode16BitsTo8Bits
                                (colormap[bIndex+i] & 0xffff);
                        }
		    
                    }

                    colorModel = new IndexColorModel(sampleSize, 
                                                     bandLength, r, g, b);
                }
                break;

            default:
                throw new RuntimeException("TIFFImage4");
            }

        Map properties = new HashMap();
        // Set a property "tiff_directory".
        properties.put("tiff_directory", dir);

        // System.out.println("Constructed TIFF");

        init((CachableRed)null, bounds, colorModel, sampleModel, 
             0, 0, properties);
    }

    /**
     * Reads a private IFD from a given offset in the stream.  This
     * method may be used to obtain IFDs that are referenced
     * only by private tag values.
     */
    public TIFFDirectory getPrivateIFD(long offset) throws IOException {
        return new TIFFDirectory(stream, offset, 0);
    }


    public WritableRaster copyData(WritableRaster wr) {
        copyToRaster(wr);
        return wr;
    }


    /**
     * Returns tile (tileX, tileY) as a Raster.
     */
    public synchronized Raster getTile(int tileX, int tileY) {
        if ((tileX < 0) || (tileX >= tilesX) ||
            (tileY < 0) || (tileY >= tilesY)) {
            throw new IllegalArgumentException("TIFFImage12");
        }

        // System.out.println("Called TIFF getTile:" + tileX + "," + tileY);


        // Get the data array out of the DataBuffer
        byte bdata[] = null;
        short sdata[] = null;
        int idata[] = null;

        SampleModel sampleModel = getSampleModel();
        WritableRaster tile = makeTile(tileX,tileY);

        DataBuffer buffer = tile.getDataBuffer();

        int dataType = sampleModel.getDataType();
        if (dataType == DataBuffer.TYPE_BYTE) {
            bdata = ((DataBufferByte)buffer).getData();
        } else if (dataType == DataBuffer.TYPE_USHORT) {
            sdata = ((DataBufferUShort)buffer).getData();
        } else if (dataType == DataBuffer.TYPE_SHORT) {
            sdata = ((DataBufferShort)buffer).getData();
        } else if (dataType == DataBuffer.TYPE_INT) {
            idata = ((DataBufferInt)buffer).getData();
        }

        // Variables used for swapping when converting from RGB to BGR
        byte bswap;
        short sswap;
        int iswap;

        // Save original file pointer position and seek to tile data location.
        long save_offset = 0;
        try {
            save_offset = stream.getFilePointer();
            stream.seek(tileOffsets[tileY*tilesX + tileX]);
        } catch (IOException ioe) {
            throw new RuntimeException("TIFFImage13");
        }

        // Number of bytes in this tile (strip) after compression.
        int byteCount = (int)tileByteCounts[tileY*tilesX + tileX];

        // Find out the number of bytes in the current tile
        Rectangle newRect;
        if (!tiled)
            newRect = tile.getBounds();
        else
            newRect = new Rectangle(tile.getMinX(), tile.getMinY(),
                                    tileWidth, tileHeight);
            
        int unitsInThisTile = newRect.width * newRect.height * numBands;

        // Allocate read buffer if needed.
        byte data[] = compression != COMP_NONE || imageType == TYPE_PALETTE ?
            new byte[byteCount] : null;

        // Read the data, uncompressing as needed. There are four cases:
        // bilevel, palette-RGB, 4-bit grayscale, and everything else.
        if(imageType == TYPE_BILEVEL) { // bilevel
            try {
                if (compression == COMP_PACKBITS) {
                    stream.readFully(data, 0, byteCount);

                    // Since the decompressed data will still be packed 
                    // 8 pixels into 1 byte, calculate bytesInThisTile
                    int bytesInThisTile;
                    if ((newRect.width % 8) == 0) {
                        bytesInThisTile = (newRect.width/8) * newRect.height;
                    } else {
                        bytesInThisTile =
                            (newRect.width/8 + 1) * newRect.height;
                    }
                    decodePackbits(data, bytesInThisTile, bdata);
                } else if (compression == COMP_LZW) {
                    stream.readFully(data, 0, byteCount);
                    lzwDecoder.decode(data, bdata, newRect.height);
                } else if (compression == COMP_FAX_G3_1D) {
                    stream.readFully(data, 0, byteCount);
                    decoder.decode1D(bdata, data, 0, newRect.height);
                } else if (compression == COMP_FAX_G3_2D) {
                    stream.readFully(data, 0, byteCount);
                    decoder.decode2D(bdata, data, 0, newRect.height,
                                     tiffT4Options);
                } else if (compression == COMP_FAX_G4_2D) {
                    stream.readFully(data, 0, byteCount);
                    decoder.decodeT6(bdata, data, 0, newRect.height,
                                     tiffT6Options);
                } else if (compression == COMP_DEFLATE) {
                    stream.readFully(data, 0, byteCount);
                    inflate(data, bdata);
                } else if (compression == COMP_NONE) {
                    stream.readFully(bdata, 0, byteCount);
                }

                stream.seek(save_offset);
            } catch (IOException ioe) {
                throw new RuntimeException("TIFFImage13");
            }
        } else if(imageType == TYPE_PALETTE) { // palette-RGB
            if (sampleSize == 16) {

                if (decodePaletteAsShorts) {
		    
                    short tempData[]= null;
		    		    
                    // At this point the data is 1 banded and will
                    // become 3 banded only after we've done the palette
                    // lookup, since unitsInThisTile was calculated with
                    // 3 bands, we need to divide this by 3.
                    int unitsBeforeLookup = unitsInThisTile / 3;
		    
                    // Since unitsBeforeLookup is the number of shorts, 
                    // but we do our decompression in terms of bytes, we 
                    // need to multiply it by 2 in order to figure out
                    // how many bytes we'll get after decompression.
                    int entries = unitsBeforeLookup * 2;
		    
                    // Read the data, if compressed, decode it, reset the pointer
                    try {
			
                        if (compression == COMP_PACKBITS) {

                            stream.readFully(data, 0, byteCount);
			    
                            byte byteArray[] = new byte[entries];
                            decodePackbits(data, entries, byteArray);
                            tempData = new short[unitsBeforeLookup];
                            interpretBytesAsShorts(byteArray, tempData,
                                                   unitsBeforeLookup);
			    
                        }  else if (compression == COMP_LZW) {

                            // Read in all the compressed data for this tile
                            stream.readFully(data, 0, byteCount);

                            byte byteArray[] = new byte[entries];
                            lzwDecoder.decode(data, byteArray, newRect.height);
                            tempData = new short[unitsBeforeLookup];
                            interpretBytesAsShorts(byteArray, tempData,
                                                   unitsBeforeLookup);

                        }  else if (compression == COMP_DEFLATE) {

                            stream.readFully(data, 0, byteCount);
                            byte byteArray[] = new byte[entries];
                            inflate(data, byteArray);
                            tempData = new short[unitsBeforeLookup];
                            interpretBytesAsShorts(byteArray, tempData,
                                                   unitsBeforeLookup);

                        } else if (compression == COMP_NONE) {

                            // byteCount tells us how many bytes are there
                            // in this tile, but we need to read in shorts, 
                            // which will take half the space, so while
                            // allocating we divide byteCount by 2.
                            tempData = new short[byteCount/2];
                            readShorts(byteCount/2, tempData);
                        }			

                        stream.seek(save_offset);

                    } catch (IOException ioe) {
                        throw new RuntimeException("TIFFImage13");
                    }

                    if (dataType == DataBuffer.TYPE_USHORT) {
			
                        // Expand the palette image into an rgb image with ushort
                        // data type.
                        int cmapValue; 
                        int count = 0, lookup, len = colormap.length/3;
                        int len2 = len * 2;
                        for (int i=0; i<unitsBeforeLookup; i++) {
                            // Get the index into the colormap
                            lookup = tempData[i] & 0xffff;
                            // Get the blue value 
                            cmapValue = colormap[lookup+len2];
                            sdata[count++] = (short)(cmapValue & 0xffff);
                            // Get the green value
                            cmapValue = colormap[lookup+len];
                            sdata[count++] = (short)(cmapValue & 0xffff);
                            // Get the red value
                            cmapValue = colormap[lookup];
                            sdata[count++] = (short)(cmapValue & 0xffff);
                        }

                    } else if (dataType == DataBuffer.TYPE_SHORT) {

                        // Expand the palette image into an rgb image with 
                        // short data type.
                        int cmapValue; 
                        int count = 0, lookup, len = colormap.length/3;
                        int len2 = len * 2;
                        for (int i=0; i<unitsBeforeLookup; i++) {
                            // Get the index into the colormap
                            lookup = tempData[i] & 0xffff;
                            // Get the blue value 
                            cmapValue = colormap[lookup+len2];
                            sdata[count++] = (short)cmapValue;
                            // Get the green value
                            cmapValue = colormap[lookup+len];
                            sdata[count++] = (short)cmapValue;
                            // Get the red value
                            cmapValue = colormap[lookup];
                            sdata[count++] = (short)cmapValue;
                        }
                    }

                } else {
		    
                    // No lookup being done here, when RGB values are needed,
                    // the associated IndexColorModel can be used to get them.
		    
                    try {

                        if (compression == COMP_PACKBITS) {

                            stream.readFully(data, 0, byteCount);

                            // Since unitsInThisTile is the number of shorts, 
                            // but we do our decompression in terms of bytes, we 
                            // need to multiply unitsInThisTile by 2 in order to 
                            // figure out how many bytes we'll get after 
                            // decompression.
                            int bytesInThisTile = unitsInThisTile * 2;

                            byte byteArray[] = new byte[bytesInThisTile];
                            decodePackbits(data, bytesInThisTile, byteArray);
                            interpretBytesAsShorts(byteArray, sdata,
                                                   unitsInThisTile);
			    
                        } else if (compression == COMP_LZW) {
			    
                            stream.readFully(data, 0, byteCount);

                            // Since unitsInThisTile is the number of shorts, 
                            // but we do our decompression in terms of bytes, we 
                            // need to multiply unitsInThisTile by 2 in order to 
                            // figure out how many bytes we'll get after 
                            // decompression.
                            byte byteArray[] = new byte[unitsInThisTile * 2];
                            lzwDecoder.decode(data, byteArray, newRect.height);
                            interpretBytesAsShorts(byteArray, sdata, 
                                                   unitsInThisTile);

                        }  else if (compression == COMP_DEFLATE) {

                            stream.readFully(data, 0, byteCount);
                            byte byteArray[] = new byte[unitsInThisTile * 2];
                            inflate(data, byteArray);
                            interpretBytesAsShorts(byteArray, sdata, 
                                                   unitsInThisTile);

                        } else if (compression == COMP_NONE) {

                            readShorts(byteCount/2, sdata);
                        }
			
                        stream.seek(save_offset);

                    } catch (IOException ioe) {
                        throw new RuntimeException("TIFFImage13");
                    }		    
                }
		
            } else if (sampleSize == 8) {

                if (decodePaletteAsShorts) {
		    
                    byte tempData[]= null;

                    // At this point the data is 1 banded and will
                    // become 3 banded only after we've done the palette
                    // lookup, since unitsInThisTile was calculated with
                    // 3 bands, we need to divide this by 3.
                    int unitsBeforeLookup = unitsInThisTile / 3;
		    
                    // Read the data, if compressed, decode it, reset the pointer
                    try {
			
                        if (compression == COMP_PACKBITS) {
			    
                            stream.readFully(data, 0, byteCount);
                            tempData = new byte[unitsBeforeLookup];
                            decodePackbits(data, unitsBeforeLookup, tempData);
			    
                        }  else if (compression == COMP_LZW) {
			    
                            stream.readFully(data, 0, byteCount);
                            tempData = new byte[unitsBeforeLookup];
                            lzwDecoder.decode(data, tempData, newRect.height);
			    
                        } else if (compression == COMP_JPEG_TTN2) {

                            stream.readFully(data, 0, byteCount);
                            Raster tempTile = decodeJPEG(data,
                                                         decodeParam,
                                                         colorConvertJPEG,
                                                         tile.getMinX(),
                                                         tile.getMinY());
                            int[] tempPixels = new int[unitsBeforeLookup];
                            tempTile.getPixels(tile.getMinX(),
                                               tile.getMinY(),
                                               tile.getWidth(),
                                               tile.getHeight(),
                                               tempPixels);
                            tempData = new byte[unitsBeforeLookup];
                            for(int i = 0; i < unitsBeforeLookup; i++) {
                                tempData[i] = (byte)tempPixels[i];
                            }

                        }  else if (compression == COMP_DEFLATE) {

                            stream.readFully(data, 0, byteCount);
                            tempData = new byte[unitsBeforeLookup];
                            inflate(data, tempData);

                        } else if (compression == COMP_NONE) {

                            tempData = new byte[byteCount];
                            stream.readFully(tempData, 0, byteCount);
                        }			

                        stream.seek(save_offset);

                    } catch (IOException ioe) {
                        throw new RuntimeException("TIFFImage13");
                    }

                    // Expand the palette image into an rgb image with ushort
                    // data type.
                    int cmapValue; 
                    int count = 0, lookup, len = colormap.length/3;
                    int len2 = len * 2;
                    for (int i=0; i<unitsBeforeLookup; i++) {
                        // Get the index into the colormap
                        lookup = tempData[i] & 0xff;
                        // Get the blue value 
                        cmapValue = colormap[lookup+len2];
                        sdata[count++] = (short)(cmapValue & 0xffff);
                        // Get the green value
                        cmapValue = colormap[lookup+len];
                        sdata[count++] = (short)(cmapValue & 0xffff);
                        // Get the red value
                        cmapValue = colormap[lookup];
                        sdata[count++] = (short)(cmapValue & 0xffff);
                    }
                } else {
		    
                    // No lookup being done here, when RGB values are needed,
                    // the associated IndexColorModel can be used to get them.
		    
                    try {

                        if (compression == COMP_PACKBITS) {
			    
                            stream.readFully(data, 0, byteCount);
                            decodePackbits(data, unitsInThisTile, bdata);
			    
                        } else if (compression == COMP_LZW) {
			    
                            stream.readFully(data, 0, byteCount);
                            lzwDecoder.decode(data, bdata, newRect.height);
			    
                        } else if (compression == COMP_JPEG_TTN2) {

                            stream.readFully(data, 0, byteCount);
                            tile.setRect(decodeJPEG(data,
                                                    decodeParam,
                                                    colorConvertJPEG,
                                                    tile.getMinX(),
                                                    tile.getMinY()));

                        }  else if (compression == COMP_DEFLATE) {
                            
                            stream.readFully(data, 0, byteCount);
                            inflate(data, bdata);

                        } else if (compression == COMP_NONE) {

                            stream.readFully(bdata, 0, byteCount);
                        }
			
                        stream.seek(save_offset);

                    } catch (IOException ioe) {
                        throw new RuntimeException("TIFFImage13");
                    }		    
                }
		
            } else if (sampleSize == 4) {
		
                int padding = (newRect.width % 2 == 0) ? 0 : 1;
                int bytesPostDecoding = ((newRect.width/2 + padding) *
                                         newRect.height);
		
                // Output short images
                if (decodePaletteAsShorts) {		
		    
                    byte tempData[] = null;

                    try {
                        stream.readFully(data, 0, byteCount);
                        stream.seek(save_offset);
                    } catch (IOException ioe) {
                        throw new RuntimeException("TIFFImage13");
                    }
		    
                    // If compressed, decode the data.
                    if (compression == COMP_PACKBITS) {
			
                        tempData = new byte[bytesPostDecoding];
                        decodePackbits(data, bytesPostDecoding, tempData);
			
                    }  else if (compression == COMP_LZW) {
			
                        tempData = new byte[bytesPostDecoding];
                        lzwDecoder.decode(data, tempData, newRect.height);
			
                    }  else if (compression == COMP_DEFLATE) {

                        tempData = new byte[bytesPostDecoding];
                        inflate(data, tempData);
			
                    } else if (compression == COMP_NONE) {
			
                        tempData = data;
                    } 
		    
                    int bytes = unitsInThisTile / 3;
		    
                    // Unpack the 2 pixels packed into each byte.	   
                    data = new byte[bytes];
		    
                    int srcCount = 0, dstCount = 0;
                    for (int j=0; j<newRect.height; j++) {
                        for (int i=0; i<newRect.width/2; i++) {
                            data[dstCount++] = 
                                (byte)((tempData[srcCount] & 0xf0) >> 4);
                            data[dstCount++] = 
                                (byte)(tempData[srcCount++] & 0x0f);
                        }
		       
                        if (padding == 1) {
                            data[dstCount++] = 
                                (byte)((tempData[srcCount++] & 0xf0) >> 4);
                        }
                    }
		    
                    int len = colormap.length/3;
                    int len2 = len*2;
                    int cmapValue, lookup;
                    int count = 0;
                    for (int i=0; i<bytes; i++) {
                        lookup = data[i] & 0xff;
                        cmapValue = colormap[lookup+len2];
                        sdata[count++] = (short)(cmapValue & 0xffff);
                        cmapValue = colormap[lookup+len];
                        sdata[count++] = (short)(cmapValue & 0xffff);
                        cmapValue = colormap[lookup];
                        sdata[count++] = (short)(cmapValue & 0xffff);
                    }
                } else {
		    
                    // Output byte values, use IndexColorModel for unpacking
                    try {
			
                        // If compressed, decode the data.
                        if (compression == COMP_PACKBITS) {
			    
                            stream.readFully(data, 0, byteCount);
                            decodePackbits(data, bytesPostDecoding, bdata);
			    
                        }  else if (compression == COMP_LZW) {
			    
                            stream.readFully(data, 0, byteCount);
                            lzwDecoder.decode(data, bdata, newRect.height);
			    
                        }  else if (compression == COMP_DEFLATE) {

                            stream.readFully(data, 0, byteCount);
                            inflate(data, bdata);

                        } else if (compression == COMP_NONE) {
			    
                            stream.readFully(bdata, 0, byteCount);
                        } 
			
                        stream.seek(save_offset);

                    } catch (IOException ioe) {
                        throw new RuntimeException("TIFFImage13");
                    }
                }
            }
        } else if(imageType == TYPE_GRAY_4BIT) { // 4-bit gray
            try {
                if (compression == COMP_PACKBITS) {
			
                    stream.readFully(data, 0, byteCount);
			
                    // Since the decompressed data will still be packed 
                    // 2 pixels into 1 byte, calculate bytesInThisTile
                    int bytesInThisTile;
                    if ((newRect.width % 8) == 0) {
                        bytesInThisTile = (newRect.width/2) * newRect.height;
                    } else {
                        bytesInThisTile = (newRect.width/2 + 1) * 
                            newRect.height;
                    }
			
                    decodePackbits(data, bytesInThisTile, bdata);
			
                } else if (compression == COMP_LZW) {
			
                    stream.readFully(data, 0, byteCount);
                    lzwDecoder.decode(data, bdata, newRect.height);
			
                }  else if (compression == COMP_DEFLATE) {
			
                    stream.readFully(data, 0, byteCount);
                    inflate(data, bdata);
			
                } else {

                    stream.readFully(bdata, 0, byteCount);
                }
		
                stream.seek(save_offset);
            } catch (IOException ioe) {
                throw new RuntimeException("TIFFImage13");
            }
        } else { // everything else
            try {
		
                if (sampleSize == 8) {
		    
                    if (compression == COMP_NONE) {
                        stream.readFully(bdata, 0, byteCount);
			
                    } else if (compression == COMP_LZW) {
			
                        stream.readFully(data, 0, byteCount);
                        lzwDecoder.decode(data, bdata, newRect.height);
			
                    } else if (compression == COMP_PACKBITS) {
			
                        stream.readFully(data, 0, byteCount);
                        decodePackbits(data, unitsInThisTile, bdata);
			
                    } else if (compression == COMP_JPEG_TTN2) {

                        stream.readFully(data, 0, byteCount);
                        tile.setRect(decodeJPEG(data,
                                                decodeParam,
                                                colorConvertJPEG,
                                                tile.getMinX(),
                                                tile.getMinY()));
                    } else if (compression == COMP_DEFLATE) {

                        stream.readFully(data, 0, byteCount);
                        inflate(data, bdata);
                    }
		    
                } else if (sampleSize == 16) {
		    
                    if (compression == COMP_NONE) {
			
                        readShorts(byteCount/2, sdata);
			
                    } else if (compression == COMP_LZW) {
			
                        stream.readFully(data, 0, byteCount);

                        // Since unitsInThisTile is the number of shorts, 
                        // but we do our decompression in terms of bytes, we 
                        // need to multiply unitsInThisTile by 2 in order to 
                        // figure out how many bytes we'll get after 
                        // decompression.
                        byte byteArray[] = new byte[unitsInThisTile * 2];
                        lzwDecoder.decode(data, byteArray, newRect.height);
                        interpretBytesAsShorts(byteArray, sdata, 
                                               unitsInThisTile);
			
                    } else if (compression == COMP_PACKBITS) {
			
                        stream.readFully(data, 0, byteCount);

                        // Since unitsInThisTile is the number of shorts, 
                        // but we do our decompression in terms of bytes, we 
                        // need to multiply unitsInThisTile by 2 in order to 
                        // figure out how many bytes we'll get after 
                        // decompression.
                        int bytesInThisTile = unitsInThisTile * 2;

                        byte byteArray[] = new byte[bytesInThisTile];
                        decodePackbits(data, bytesInThisTile, byteArray);
                        interpretBytesAsShorts(byteArray, sdata, 
                                               unitsInThisTile);
                    } else if (compression == COMP_DEFLATE) {

                        stream.readFully(data, 0, byteCount);
                        byte byteArray[] = new byte[unitsInThisTile * 2];
                        inflate(data, byteArray);
                        interpretBytesAsShorts(byteArray, sdata, 
                                               unitsInThisTile);

                    }
                } else if (sampleSize == 32 &&
                           dataType == DataBuffer.TYPE_INT) { // redundant
                    if (compression == COMP_NONE) {
			
                        readInts(byteCount/4, idata);

                    } else if (compression == COMP_LZW) {
			
                        stream.readFully(data, 0, byteCount);

                        // Since unitsInThisTile is the number of ints, 
                        // but we do our decompression in terms of bytes, we 
                        // need to multiply unitsInThisTile by 4 in order to 
                        // figure out how many bytes we'll get after 
                        // decompression.
                        byte byteArray[] = new byte[unitsInThisTile * 4];
                        lzwDecoder.decode(data, byteArray, newRect.height);
                        interpretBytesAsInts(byteArray, idata, 
                                             unitsInThisTile);
			
                    } else if (compression == COMP_PACKBITS) {
			
                        stream.readFully(data, 0, byteCount);

                        // Since unitsInThisTile is the number of ints, 
                        // but we do our decompression in terms of bytes, we 
                        // need to multiply unitsInThisTile by 4 in order to 
                        // figure out how many bytes we'll get after 
                        // decompression.
                        int bytesInThisTile = unitsInThisTile * 4;

                        byte byteArray[] = new byte[bytesInThisTile];
                        decodePackbits(data, bytesInThisTile, byteArray);
                        interpretBytesAsInts(byteArray, idata, 
                                             unitsInThisTile);
                    } else if (compression == COMP_DEFLATE) {

                        stream.readFully(data, 0, byteCount);
                        byte byteArray[] = new byte[unitsInThisTile * 4];
                        inflate(data, byteArray);
                        interpretBytesAsInts(byteArray, idata, 
                                             unitsInThisTile);

                    }
                }

                stream.seek(save_offset);

            } catch (IOException ioe) {
                throw new RuntimeException("TIFFImage13");
            }

            // Modify the data for certain special cases.
            switch(imageType) {
            case TYPE_GRAY:
            case TYPE_GRAY_ALPHA:
                if(isWhiteZero) {
                    // Since we are using a ComponentColorModel with this
                    // image, we need to change the WhiteIsZero data to
                    // BlackIsZero data so it will display properly.
                    if (dataType == DataBuffer.TYPE_BYTE &&
                        !(getColorModel() instanceof IndexColorModel)) {

                        for (int l = 0; l < bdata.length; l += numBands) {
                            bdata[l] = (byte)(255 - bdata[l]);
                        }
                    } else if (dataType == DataBuffer.TYPE_USHORT) {

                        int ushortMax = Short.MAX_VALUE - Short.MIN_VALUE;
                        for (int l = 0; l < sdata.length; l += numBands) {
                            sdata[l] = (short)(ushortMax - sdata[l]);
                        }

                    } else if (dataType == DataBuffer.TYPE_SHORT) {

                        for (int l = 0; l < sdata.length; l += numBands) {
                            sdata[l] = (short)(~sdata[l]);
                        }
                    } else if (dataType == DataBuffer.TYPE_INT) {

                        long uintMax = ((long)Integer.MAX_VALUE - 
                                        (long)Integer.MIN_VALUE);
                        for (int l = 0; l < idata.length; l += numBands) {
                            idata[l] = (int)(uintMax - idata[l]);
                        }
                    }
                }
                break;
            case TYPE_RGB:
                // Change RGB to BGR order, as Java2D displays that faster.
                // Unnecessary for JPEG-in-TIFF as the decoder handles it.
                if (sampleSize == 8 && compression != COMP_JPEG_TTN2) {
                    for (int i=0; i<unitsInThisTile; i+=3) {
                        bswap = bdata[i];
                        bdata[i] = bdata[i+2];
                        bdata[i+2] = bswap;
                    }
                } else if (sampleSize == 16) {
                    for (int i=0; i<unitsInThisTile; i+=3) {
                        sswap = sdata[i];
                        sdata[i] = sdata[i+2];
                        sdata[i+2] = sswap;
                    }
                } else if (sampleSize == 32) {
                    if(dataType == DataBuffer.TYPE_INT) {
                        for (int i=0; i<unitsInThisTile; i+=3) {
                            iswap = idata[i];
                            idata[i] = idata[i+2];
                            idata[i+2] = iswap;
                        }
                    }
                }
                break;
            case TYPE_RGB_ALPHA:
                // Convert from RGBA to ABGR for Java2D
                if (sampleSize == 8) {
                    for (int i=0; i<unitsInThisTile; i+=4) {
                        // Swap R and A
                        bswap = bdata[i];
                        bdata[i] = bdata[i+3];
                        bdata[i+3] = bswap;
			
                        // Swap G and B
                        bswap = bdata[i+1];
                        bdata[i+1] = bdata[i+2];
                        bdata[i+2] = bswap;
                    }
                } else if (sampleSize == 16) {
                    for (int i=0; i<unitsInThisTile; i+=4) {
                        // Swap R and A
                        sswap = sdata[i];
                        sdata[i] = sdata[i+3];
                        sdata[i+3] = sswap;

                        // Swap G and B
                        sswap = sdata[i+1];
                        sdata[i+1] = sdata[i+2];
                        sdata[i+2] = sswap;
                    }
                } else if (sampleSize == 32) {
                    if(dataType == DataBuffer.TYPE_INT) {
                        for (int i=0; i<unitsInThisTile; i+=4) {
                            // Swap R and A
                            iswap = idata[i];
                            idata[i] = idata[i+3];
                            idata[i+3] = iswap;

                            // Swap G and B
                            iswap = idata[i+1];
                            idata[i+1] = idata[i+2];
                            idata[i+2] = iswap;
                        }
                    }
                }
                break;
            case TYPE_YCBCR_SUB:
                // Post-processing for YCbCr with subsampled chrominance:
                // simply replicate the chroma channels for displayability.
                int pixelsPerDataUnit = chromaSubH*chromaSubV;

                int numH = newRect.width/chromaSubH;
                int numV = newRect.height/chromaSubV;

                byte[] tempData = new byte[numH*numV*(pixelsPerDataUnit + 2)];
                System.arraycopy(bdata, 0, tempData, 0, tempData.length);

                int samplesPerDataUnit = pixelsPerDataUnit*3;
                int[] pixels = new int[samplesPerDataUnit];

                int bOffset = 0;
                int offsetCb = pixelsPerDataUnit;
                int offsetCr = offsetCb + 1;

                int y = newRect.y;
                for(int j = 0; j < numV; j++) {
                    int x = newRect.x;
                    for(int i = 0; i < numH; i++) {
                        int Cb = tempData[bOffset + offsetCb];
                        int Cr = tempData[bOffset + offsetCr];
                        int k = 0;
                        while(k < samplesPerDataUnit) {
                            pixels[k++] = tempData[bOffset++];
                            pixels[k++] = Cb;
                            pixels[k++] = Cr;
                        }
                        bOffset += 2;
                        tile.setPixels(x, y, chromaSubH, chromaSubV, pixels);
                        x += chromaSubH;
                    }
                    y += chromaSubV;
                }

                break;
            }
        }
        
        return tile;
    }

    private void readShorts(int shortCount, short shortArray[]) {
	
        // Since each short consists of 2 bytes, we need a 
        // byte array of double size
        int byteCount = 2 * shortCount;
        byte byteArray[] = new byte[byteCount];

        try {	    
            stream.readFully(byteArray, 0, byteCount);
        } catch (IOException ioe) {
            throw new RuntimeException("TIFFImage13");
        }

        interpretBytesAsShorts(byteArray, shortArray, shortCount);
    }

    private void readInts(int intCount, int intArray[]) {
	
        // Since each int consists of 4 bytes, we need a 
        // byte array of quadruple size
        int byteCount = 4 * intCount;
        byte byteArray[] = new byte[byteCount];

        try {	    
            stream.readFully(byteArray, 0, byteCount);
        } catch (IOException ioe) {
            throw new RuntimeException("TIFFImage13");
        }

        interpretBytesAsInts(byteArray, intArray, intCount);
    }

    // Method to interpret a byte array to a short array, depending on 
    // whether the bytes are stored in a big endian or little endian format.
    private void interpretBytesAsShorts(byte byteArray[], 
                                        short shortArray[], 
                                        int shortCount) {

        int j = 0;
        int firstByte, secondByte;

        if (isBigEndian) {

            for (int i=0; i<shortCount; i++) {
                firstByte = byteArray[j++] & 0xff;
                secondByte = byteArray[j++] & 0xff;
                shortArray[i] = (short)((firstByte << 8) + secondByte);
            }
	    
        } else {
	    
            for (int i=0; i<shortCount; i++) {
                firstByte = byteArray[j++] & 0xff;
                secondByte = byteArray[j++] & 0xff;
                shortArray[i] = (short)((secondByte << 8) + firstByte);
            }
        }
    }

    // Method to interpret a byte array to a int array, depending on 
    // whether the bytes are stored in a big endian or little endian format.
    private void interpretBytesAsInts(byte byteArray[],
                                      int intArray[], 
                                      int intCount) {

        int j = 0;

        if (isBigEndian) {
	    
            for (int i=0; i<intCount; i++) {
                intArray[i] = (((byteArray[j++] & 0xff) << 24) |
                               ((byteArray[j++] & 0xff) << 16) |
                               ((byteArray[j++] & 0xff) << 8) |
                               ( byteArray[j++] & 0xff));
            }
	    
        } else {
	    
            for (int i=0; i<intCount; i++) {
                intArray[i] = ((byteArray[j++] & 0xff) |
                              ((byteArray[j++] & 0xff) << 8) |
                              ((byteArray[j++] & 0xff) << 16) |
                              ((byteArray[j++] & 0xff) << 24));
            }
        }
    }

    // Uncompress packbits compressed image data.
    private byte[] decodePackbits(byte data[], int arraySize, byte[] dst) {

        if (dst == null) {
            dst = new byte[arraySize];
        }

        int srcCount = 0, dstCount = 0;
        byte repeat, b;

        try {
	    
            while (dstCount < arraySize) {
		
                b = data[srcCount++];
		
                if (b >= 0 && b <= 127) {
		    
                    // literal run packet
                    for (int i=0; i<(b + 1); i++) {
                        dst[dstCount++] = data[srcCount++];
                    }
		    		    
                } else if (b <= -1 && b >= -127) {
		    
                    // 2 byte encoded run packet
                    repeat = data[srcCount++];
                    for (int i=0; i<(-b + 1); i++) {
                        dst[dstCount++] = repeat;
                    }
		    
                } else {
                    // no-op packet. Do nothing
                    srcCount++;
                }
            }
        } catch (java.lang.ArrayIndexOutOfBoundsException ae) {
            throw new RuntimeException("TIFFImage14");
        }

        return dst;
    }

    // Need a createColorModel().
    // Create ComponentColorModel for TYPE_RGB images
    private ComponentColorModel createAlphaComponentColorModel
    (int dataType, int numBands, 
     boolean isAlphaPremultiplied, int transparency) {
	
        ComponentColorModel ccm = null;
        int RGBBits[] = null;
        ColorSpace cs = null;
        switch(numBands) {
            case 2: // gray+alpha
                cs = ColorSpace.getInstance(ColorSpace.CS_GRAY);
                break;
            case 4: // RGB+alpha
                cs = ColorSpace.getInstance(ColorSpace.CS_sRGB);
                break;
            default:
                throw new IllegalArgumentException();
        }
        
        int componentSize = 0;
        switch(dataType) {
            case DataBuffer.TYPE_BYTE:
                componentSize = 8;
                break;
            case DataBuffer.TYPE_USHORT:
            case DataBuffer.TYPE_SHORT:
                componentSize = 16;
                break;
            case DataBuffer.TYPE_INT:
                componentSize = 32;
                break;
            default:
                throw new IllegalArgumentException();
        }

        RGBBits = new int[numBands];
        for(int i = 0; i < numBands; i++) {
            RGBBits[i] = componentSize;
        }

        ccm = new ComponentColorModel(cs,
                                      RGBBits,
                                      true,
                                      isAlphaPremultiplied,
                                      transparency,
                                      dataType);


        return ccm;		
    }
        
}
