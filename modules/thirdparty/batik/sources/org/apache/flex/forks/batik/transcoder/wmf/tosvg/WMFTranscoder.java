/*

   Copyright 1999-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

import java.awt.Dimension;
import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.svggen.SVGGraphics2D;
import org.apache.flex.forks.batik.transcoder.AbstractTranscoder;
import org.apache.flex.forks.batik.transcoder.TranscoderException;
import org.apache.flex.forks.batik.transcoder.TranscoderInput;
import org.apache.flex.forks.batik.transcoder.TranscoderOutput;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.xml.sax.XMLFilter;


/**
 * This class implements the <tt>Transcoder</tt> interface and
 * can convert a WMF input document into an SVG document.
 *
 * It can use <tt>TranscoderInput</tt> that are either a URI
 * or a <tt>InputStream</tt> or a <tt>Reader</tt>. The
 * <tt>XMLReader</tt> and <tt>Document</tt> <tt>TranscoderInput</tt>
 * types are not supported.
 *
 * This transcoder can use <tt>TranscoderOutputs</tt> that are
 * of any type except the <tt>XMLFilter</tt> type.
 *
 * @version $Id: WMFTranscoder.java,v 1.7 2004/11/18 01:47:02 deweese Exp $
 * @author <a href="mailto:luano@asd.ie">Luan O'Carroll</a>
 */
public class WMFTranscoder extends AbstractTranscoder
    implements SVGConstants{

    /**
     * Error codes for the WMFTranscoder
     */
    public static final int WMF_TRANSCODER_ERROR_BASE = 0xff00;
    public static final int ERROR_NULL_INPUT = WMF_TRANSCODER_ERROR_BASE + 0;
    public static final int ERROR_INCOMPATIBLE_INPUT_TYPE = WMF_TRANSCODER_ERROR_BASE + 1;
    public static final int ERROR_INCOMPATIBLE_OUTPUT_TYPE = WMF_TRANSCODER_ERROR_BASE + 2;

    /**
     * Default constructor
     */
    public WMFTranscoder(){
    }

    /**
     * Transcodes the specified input in the specified output.
     * @param input the input to transcode
     * @param output the ouput where to transcode
     * @exception TranscoderException if an error occured while transcoding
     */
    public void transcode(TranscoderInput input, TranscoderOutput output)
        throws TranscoderException {
        //
        // Extract the input
        //
        DataInputStream is = getCompatibleInput(input);

        //
        // Build a RecordStore from the input
        //
        WMFRecordStore currentStore = new WMFRecordStore();
        try{
            currentStore.read(is);
        }catch(IOException e){
            handler.fatalError(new TranscoderException(e));
            return;
        }

        //
        // Build a painter for the RecordStore
        //
        WMFPainter painter = new WMFPainter(currentStore);

        //
        // Use SVGGraphics2D to generate SVG content
        //
        DOMImplementation domImpl
            = SVGDOMImplementation.getDOMImplementation();

        Document doc = domImpl.createDocument(SVG_NAMESPACE_URI,
                                              SVG_SVG_TAG, null);

        SVGGraphics2D svgGenerator = new SVGGraphics2D(doc);

        painter.paint(svgGenerator);

        //
        // Set the size and viewBox on the output document
        //
        int vpX = currentStore.getVpX();
        int vpY = currentStore.getVpY();
        int vpW = currentStore.getVpW();
        int vpH = currentStore.getVpH();
        svgGenerator.setSVGCanvasSize(new Dimension(vpW, vpH));

        Element svgRoot = svgGenerator.getRoot();
        svgRoot.setAttributeNS(null, SVG_VIEW_BOX_ATTRIBUTE,
                               "" + vpX + " " + vpY + " " +
                               vpW + " " + vpH );

        //
        // Now, write the SVG content to the output
        //
        writeSVGToOutput(svgGenerator, svgRoot, output);
    }

    /**
     * Writes the SVG content held by the svgGenerator to the
     * <tt>TranscoderOutput</tt>.
     */
    private void writeSVGToOutput(SVGGraphics2D svgGenerator,
                                  Element svgRoot,
                                  TranscoderOutput output)
        throws TranscoderException {
        // XMLFilter
        XMLFilter xmlFilter = output.getXMLFilter();
        if(xmlFilter != null){
            handler.fatalError(new TranscoderException("" + ERROR_INCOMPATIBLE_OUTPUT_TYPE));
        }

        // <!> FIX ME: SHOULD HANDLE DOCUMENT INPUT
        Document doc = output.getDocument();
        if(doc != null){
            handler.fatalError(new TranscoderException("" + ERROR_INCOMPATIBLE_OUTPUT_TYPE));
        }

        try{
            // Output stream
            OutputStream os = output.getOutputStream();
            if( os != null ){
                svgGenerator.stream(svgRoot, new OutputStreamWriter(os));
                return;
            }

            // Writer
            Writer wr = output.getWriter();
            if( wr != null ){
                svgGenerator.stream(svgRoot, wr);
                return;
            }

            // URI
            String uri = output.getURI();
            if( uri != null ){
                try{
                    URL url = new URL(uri);
                    URLConnection urlCnx = url.openConnection();
                    os = urlCnx.getOutputStream();
                    svgGenerator.stream(svgRoot, new OutputStreamWriter(os));
                    return;
                }catch(MalformedURLException e){
                    handler.fatalError(new TranscoderException(e));
                }catch(IOException e){
                    handler.fatalError(new TranscoderException(e));
                }
            }
        }catch(IOException e){
            throw new TranscoderException(e);
        }

        throw new TranscoderException("" + ERROR_INCOMPATIBLE_OUTPUT_TYPE);

    }

    /**
     * Checks that the input is one of URI or an <tt>InputStream</tt>
     * returns it as a DataInputStream
     */
    private DataInputStream getCompatibleInput(TranscoderInput input)
        throws TranscoderException {
        // Cannot deal with null input
        if(input == null){
            handler.fatalError(new TranscoderException("" + ERROR_NULL_INPUT));
        }

        // Can deal with InputStream
        InputStream in = input.getInputStream();
        if(in != null){
            return new DataInputStream(new BufferedInputStream(in));
        }

        // Can deal with URI
        String uri = input.getURI();
        if(uri != null){
            try{
                URL url = new URL(uri);
                in = url.openStream();
                return new DataInputStream(new BufferedInputStream(in));
            }catch(MalformedURLException e){
                handler.fatalError(new TranscoderException(e));
            }catch(IOException e){
                handler.fatalError(new TranscoderException(e));
            }
        }

        handler.fatalError(new TranscoderException("" + ERROR_INCOMPATIBLE_INPUT_TYPE));
        return null;
    }

    public static final String USAGE = "The WMFTranscoder converts a WMF document into an SVG document. \n" +
        "This simple application generates SVG documents that have the same name, but a where the .wmf extension \n" +
        "is replaced with .svg. To run the application, type the following at the command line: \n" +
        "java org.apache.flex.forks.batik.transcoder.wmf.tosvg.WMFTranscoder fileName [fileName]+";

    public static final String WMF_EXTENSION = ".wmf";
    public static final String SVG_EXTENSION = ".svg";

    /**
     * Unit testing : Illustrates how the transcoder might be used.
     */
    public static void main(String args[]) throws TranscoderException {
        if(args.length < 1){
            System.err.println(USAGE);
            System.exit(1);
        }

        WMFTranscoder transcoder = new WMFTranscoder();
        int nFiles = args.length;

        for(int i=0; i<nFiles; i++){
            String fileName = args[i];
            if(!fileName.toLowerCase().endsWith(WMF_EXTENSION)){
                System.err.println(args[i] + " does not have the " + WMF_EXTENSION + " extension. It is ignored");
            }
            else{
                System.out.print("Processing : " + args[i] + "...");
                String outputFileName = fileName.substring(0, fileName.toLowerCase().indexOf(WMF_EXTENSION)) + SVG_EXTENSION;
                File inputFile = new File(fileName);
                File outputFile = new File(outputFileName);
                try{
                    TranscoderInput input = new TranscoderInput(inputFile.toURL().toString());
                    TranscoderOutput output = new TranscoderOutput(new FileOutputStream(outputFile));
                    transcoder.transcode(input, output);
                }catch(MalformedURLException e){
                    throw new TranscoderException(e);
                }catch(IOException e){
                    throw new TranscoderException(e);
                }
                System.out.println(".... Done");
            }
        }

        System.exit(0);
    }
}
