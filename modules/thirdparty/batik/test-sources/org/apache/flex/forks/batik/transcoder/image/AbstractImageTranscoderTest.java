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
package org.apache.flex.forks.batik.transcoder.image;

import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;

import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

import java.net.MalformedURLException;
import java.net.URL;

import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.spi.ImageTagRegistry;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;

import org.apache.flex.forks.batik.ext.awt.image.codec.PNGImageEncoder;
import org.apache.flex.forks.batik.ext.awt.image.codec.PNGEncodeParam;

import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;

import org.apache.flex.forks.batik.transcoder.image.ImageTranscoder;
import org.apache.flex.forks.batik.transcoder.image.PNGTranscoder;

import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;
import org.apache.flex.forks.batik.test.svg.SVGRenderingAccuracyTest;

/**
 * The base class for the ImageTranscoder tests.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: AbstractImageTranscoderTest.java,v 1.7 2004/08/18 07:17:12 vhardy Exp $
 */
public abstract class AbstractImageTranscoderTest extends AbstractTest {

    /**
     * Error when the reference image and the generated image is different.
     */
    public static final String ERROR_IMAGE_DIFFER =
	"AbstractImageTranscoderTest.error.image.differ";

    /**
     * Tag for difference image URI.
     */
    public static final String DIFFERENCE_IMAGE =
	"AbstractImageTranscoderTest.error.difference.image";

    /**
     * Error when an exception occured while transcoding.
     */
    public static final String ERROR_TRANSCODING =
	"AbstractImageTranscoderTest.error.transcoder.exception";

    /**
     * Constructs a new <tt>AbstractImageTranscoderTest</tt>.
     */
    public AbstractImageTranscoderTest() {
    }

    /**
     * Resolves the input string as follows.
     * + First, the string is interpreted as a file description.
     *   If the file exists, then the file name is turned into
     *   a URL.
     * + Otherwise, the string is supposed to be a URL. If it
     *   is an invalid URL, an IllegalArgumentException is thrown.
     */
    protected URL resolveURL(String url){
        // Is url a file?
        File f = (new File(url)).getAbsoluteFile();
        if(f.getParentFile().exists()){
            try{
                return f.toURL();
            }catch(MalformedURLException e){
                throw new IllegalArgumentException();
            }
        }
        
        // url is not a file. It must be a regular URL...
        try{
            return new URL(url);
        }catch(MalformedURLException e){
            throw new IllegalArgumentException(url);
        }
    }

    DefaultTestReport report;
    /**
     * Runs this test. This method will only throw exceptions if some aspect of
     * the test's internal operation fails.
     */
    public TestReport runImpl() throws Exception {
	report = new DefaultTestReport(this);

	try {
	    DiffImageTranscoder transcoder = 
		new DiffImageTranscoder(getReferenceImageData());

	    Map hints = createTranscodingHints();
	    if (hints != null) {
		transcoder.setTranscodingHints(hints);
	    }

	    TranscoderInput input = createTranscoderInput();
	    transcoder.transcode(input, null);
	} catch (Exception ex) {
	    report.setErrorCode(ERROR_TRANSCODING);
	    report.addDescriptionEntry(ERROR_TRANSCODING, toString(ex));
            ex.printStackTrace();
	    report.setPassed(false);
	}
	
	return report;
    }

    /**
     * Creates the <tt>TranscoderInput</tt>.
     */
    protected abstract TranscoderInput createTranscoderInput();

    /**
     * Creates a Map that contains additional transcoding hints.
     */
    protected Map createTranscodingHints() {
	return null;
    }

    /**
     * Returns the reference image for this test.
     */
    protected abstract byte [] getReferenceImageData();

    //////////////////////////////////////////////////////////////////////////
    // Convenient methods
    //////////////////////////////////////////////////////////////////////////

    /**
     * Gives the specified exception as a string.
     */
    public static String toString(Exception ex) {
	StringWriter trace = new StringWriter();
	ex.printStackTrace(new PrintWriter(trace));
	return trace.toString();
    }

    static String filename;

    /**
     * Loads an image from a URL
     */
    public static byte [] createBufferedImageData(URL url) {
        try {
            filename = url.toString();
            //System.out.println(url.toString());
            InputStream istream = url.openStream();
            byte [] imgData = null;
            byte [] buf = new byte[1024];
            int length;
            while ((length = istream.read(buf, 0, buf.length)) == buf.length) {
                if (imgData != null) {
                    byte [] imgDataTmp = new byte[imgData.length + length];
                    System.arraycopy
                        (imgData, 0, imgDataTmp, 0, imgData.length);
                    System.arraycopy
                        (buf, 0, imgDataTmp, imgData.length, length);
                    imgData = imgDataTmp;
                } else {
                    imgData = new byte[length];
                    System.arraycopy(buf, 0, imgData, 0, length);
                }
            }
            if (imgData != null) {
                byte [] imgDataTmp = new byte[imgData.length + length];
                System.arraycopy
                    (imgData, 0, imgDataTmp, 0, imgData.length);
                System.arraycopy
                    (buf, 0, imgDataTmp, imgData.length, length);
                imgData = imgDataTmp;
            } else {
                imgData = new byte[length];
                System.arraycopy(buf, 0, imgData, 0, length);
            }
            istream.close();
            return imgData;
        } catch (IOException ex) {
            return null;
        }
    }

    /**
     * A custom ImageTranscoder for testing.
     */
    protected class DiffImageTranscoder extends ImageTranscoder {

	/** The result of the image comparaison. */
	protected boolean state;

	/** The reference image. */
	protected byte [] refImgData;

	/**
	 * Constructs a new <tt>DiffImageTranscoder</tt>.
	 *
	 * @param refImg the reference image
	 * @param report the test report into which errors have been sent
	 */
	public DiffImageTranscoder(byte [] refImgData) {
	    this.refImgData = refImgData;
	}

	/**
	 * Creates a new image with the specified dimension.
	 * @param w the image width in pixels
	 * @param h the image height in pixels
	 */
	public BufferedImage createImage(int w, int h) {
	    return new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
	}

	/**
	 * Compares the specified image with the reference image and set the
	 * state flag.
	 *
	 * @param img the image to write
	 * @param output the output (ignored)
	 * @param TranscoderException if an error occured while storing the
	 * image 
	 */
	public void writeImage(BufferedImage img, TranscoderOutput output)
	    throws TranscoderException {

	    compareImage(img);
	}

        protected void writeCandidateReference(byte [] imgData) {
            try {
                String s = new File(filename).getName();
                s = "test-references/org/apache/batik/transcoder/image/candidate-reference/"+s;
                System.out.println(s);
                FileOutputStream ostream = new FileOutputStream(s);
                ostream.write(imgData, 0, imgData.length);
                ostream.flush();
                ostream.close();
            } catch (Exception ex) { }
            return;
        }

        protected void writeCandidateVariation(byte [] imgData, byte [] refData)
        {
            writeCandidateReference(imgData);
            try {
                BufferedImage ref = getImage(new ByteArrayInputStream(refData));
                BufferedImage img = getImage(new ByteArrayInputStream(imgData));
                BufferedImage diff = 
                    SVGRenderingAccuracyTest.buildDiffImage(ref, img);
                String s = new File(filename).getName();
                s = ("test-references/org/apache/batik/transcoder/image/"+
                     "candidate-variation/"+s);
                PNGImageEncoder encoder 
                    = new PNGImageEncoder
                    (new FileOutputStream(s),
                     PNGEncodeParam.getDefaultEncodeParam(diff));
                encoder.encode(diff);
                report.addDescriptionEntry(DIFFERENCE_IMAGE,new File(s));
            } catch (Exception e) { }
        }

	/**
	 * Compares both source and result images and set the state flag.
	 */
	protected void compareImage(BufferedImage img) 
            throws TranscoderException {
	    // compare the resulting image with the reference image
	    // state = true if refImg is the same than img

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            TranscoderOutput output = new TranscoderOutput(out);
            PNGTranscoder t = new PNGTranscoder();
            t.writeImage(img, output);
            byte [] imgData = out.toByteArray();

            if (refImgData == null) {
                report.setErrorCode(ERROR_IMAGE_DIFFER);
                report.addDescriptionEntry(ERROR_IMAGE_DIFFER, "");
                report.setPassed(false);
                writeCandidateReference(imgData);
                state = false;
                return;
            }
            
            if (refImgData.length != imgData.length) {
                report.setErrorCode(ERROR_IMAGE_DIFFER);
                report.addDescriptionEntry(ERROR_IMAGE_DIFFER, "");
                report.setPassed(false);
                writeCandidateVariation(imgData, refImgData);
                return;
            }

            for (int i = 0; i < refImgData.length; ++i) {
                if (refImgData[i] != imgData[i]) {
                    report.setErrorCode(ERROR_IMAGE_DIFFER);
                    report.addDescriptionEntry(ERROR_IMAGE_DIFFER, "");
                    report.setPassed(false);
                    writeCandidateVariation(imgData, refImgData);
                    return;
                }
            }
            
	    state = true;
	}

	/**
	 * Returns true if the reference image is the same than the generated
	 * image, false otherwise.  
	 */
	public boolean isIdentical() {
	    return state;
	}
    }

    protected BufferedImage getImage(InputStream is) 
        throws IOException {
        ImageTagRegistry reg = ImageTagRegistry.getRegistry();
        Filter filt = reg.readStream(is);
        if(filt == null)
            throw new IOException("Couldn't read Stream");

        RenderedImage red = filt.createDefaultRendering();
        if(red == null)
            throw new IOException("Couldn't render Stream");
        
        BufferedImage img = new BufferedImage(red.getWidth(),
                                              red.getHeight(),
                                              BufferedImage.TYPE_INT_ARGB);
        red.copyData(img.getRaster());
        return img;
    }
}
