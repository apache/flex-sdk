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
package org.apache.flex.forks.batik.svggen;

import org.apache.flex.forks.batik.svggen.SVGGeneratorContext.GraphicContextDefaults;

import java.awt.Dimension;
import java.awt.Font;

import java.net.URL;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.io.PrintWriter;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;

import org.apache.flex.forks.batik.svggen.SVGGraphics2D;
import org.apache.flex.forks.batik.dom.GenericDOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DOMImplementation;

/**
 * This test validates that a given rendering sequence, modeled
 * by a <tt>Painter</tt> is properly converted to an SVG document
 * by comparing the generated SVG document to a know, valid
 * SVG reference.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SVGAccuracyTest.java,v 1.14 2004/08/18 07:16:45 vhardy Exp $
 */
public class SVGAccuracyTest extends AbstractTest
    implements SVGConstants{
    /**
     * Error when an error occurs while generating SVG
     * with the <tt>SVGGraphics2D</tt>
     * {0} = painter class name if painter not null. Null otherwise
     * {1} = exception class name
     * {2} = exception message
     * {3} = exception stack trace.
     */
    public static final String ERROR_CANNOT_GENERATE_SVG
        = "SVGAccuracyTest.error.cannot.generate.svg";

    /**
     * Error when the reference SVG file cannot be opened
     * {0} = URI of the reference image
     * {1} = IOException message
     */
    public static final String ERROR_CANNOT_OPEN_REFERENCE_SVG_FILE
        = "SVGAccuracyTest.error.cannot.open.reference.svg.file";

    /**
     * Error when there is an IOException while comparing the
     * reference SVG file with the newly generated SVG content
     * {0} = URI of the reference image
     * {1} = IOException message.
     */
    public static final String ERROR_ERROR_WHILE_COMPARING_FILES
        = "SVGAccuracyTest.error.while.comparing.files";

    /**
     * Error when the generated SVG is inaccurate
     */
    public static final String ERROR_GENERATED_SVG_INACCURATE
        = "SVGAccuracyTest.error.generated.svg.inaccurate";

    public static final String ENTRY_KEY_ERROR_DESCRIPTION
        = "SVGAccuracyTest.entry.key.error.description";

    public static final String ENTRY_KEY_LINE_NUMBER
        = "SVGAccuracyTest.entry.key.line.number";

    public static final String ENTRY_KEY_COLUMN_NUMBER
        = "SVGAccuracyTest.entry.key.column.number";

    public static final String ENTRY_KEY_COLUMN_EXPECTED_VALUE
        = "SVGAccuracyTest.entry.key.column.expected.value";

    public static final String ENTRY_KEY_COLUMN_FOUND_VALUE
        = "SVGAccuracyTest.entry.key.column.found.value";

    public static final String ENTRY_KEY_REFERENCE_LINE
        = "SVGAccuracyTest.entry.key.reference.line";

    public static final String ENTRY_KEY_NEW_LINE
        = "SVGAccuracyTest.entry.key.new.line";

    /**
     * Canvas size for all tests
     */
    public static final Dimension CANVAS_SIZE
        = new Dimension(300, 400);

    /**
     * Painter which performs an arbitrary rendering
     * sequence.
     */
    private Painter painter;

    /**
     * Reference SVG URL
     */
    private URL refURL;

    /**
     * File where the generated SVG might be saved
     */
    private File saveSVG;

    /**
     * Constructor
     * @param painter the <tt>Painter</tt> object which will
     *        perform an arbitrary rendering sequence.
     * @param refURL the location of a reference SVG which
     *        should be exactly identical to that generated
     *        by the painter.
     */
    public SVGAccuracyTest(Painter painter,
                           URL refURL){
        this.painter = painter;
        this.refURL  = refURL;
    }

    public File getSaveSVG(){
        return saveSVG;
    }

    public void setSaveSVG(File saveSVG){
        this.saveSVG = saveSVG;
    }

    /**
     * This method will only throw exceptions if some aspect
     * of the test's internal operation fails.
     */
    public TestReport runImpl() throws Exception {
        DefaultTestReport report
            = new DefaultTestReport(this);

        SVGGraphics2D g2d = buildSVGGraphics2D();
        g2d.setSVGCanvasSize(CANVAS_SIZE);

        //
        // Generate SVG content
        //
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        OutputStreamWriter osw = new OutputStreamWriter(bos, "UTF-8");
        try{
            painter.paint(g2d);
            configureSVGGraphics2D(g2d);
            g2d.stream(osw);
            osw.flush();
            bos.flush();
            bos.close();
        }catch(Exception e){
            StringWriter trace = new StringWriter();
            e.printStackTrace(new PrintWriter(trace));
            report.setErrorCode(ERROR_CANNOT_GENERATE_SVG);
            report.setDescription(new TestReport.Entry[]{
                new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_ERROR_DESCRIPTION, null),
                                     Messages.formatMessage(ERROR_CANNOT_GENERATE_SVG,
                                                            new String[]{painter == null? "null" : painter.getClass().getName(),
                                                                         e.getClass().getName(),
                                                                         e.getMessage(),
                                                                         trace.toString() })) });
            report.setPassed(false);
            return report;
        }

        //
        // Compare with reference SVG
        //
        InputStream refStream = null;
        try {
            refStream =
                new BufferedInputStream(refURL.openStream());
        }catch(Exception e){
            report.setErrorCode(ERROR_CANNOT_OPEN_REFERENCE_SVG_FILE);
            report.setDescription( new TestReport.Entry[]{
                new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_ERROR_DESCRIPTION, null),
                          Messages.formatMessage(ERROR_CANNOT_OPEN_REFERENCE_SVG_FILE,
                                                 new Object[]{refURL != null? refURL.toExternalForm() : "null",
                                                              e.getMessage()})) });
            report.setPassed(false);
            save(bos.toByteArray());
            return report;
        }

        InputStream newStream = new ByteArrayInputStream(bos.toByteArray());

        boolean accurate = true;
        String refLine = null;
        String newLine = null;
        int ln = 1;

        try{
            // accurate = compare(refStream, newStream);
            BufferedReader refReader = new BufferedReader(new InputStreamReader(refStream));
            BufferedReader newReader = new BufferedReader(new InputStreamReader(newStream));
            while((refLine = refReader.readLine()) != null){
                newLine = newReader.readLine();
                if(newLine == null || !refLine.equals(newLine)){
                    accurate = false;
                    break;
                }
                ln++;
            }

            if(accurate){
                // need to make sure newLine is null as well
                newLine = newReader.readLine();
                if(newLine != null){
                    accurate = false;
                }
            }

        } catch(IOException e) {
            report.setErrorCode(ERROR_ERROR_WHILE_COMPARING_FILES);
            report.setDescription(new TestReport.Entry[]{
                new TestReport.Entry(Messages.formatMessage(ENTRY_KEY_ERROR_DESCRIPTION, null),
                                     Messages.formatMessage(ERROR_ERROR_WHILE_COMPARING_FILES,
                                                            new Object[]{refURL.toExternalForm(),
                                                                         e.getMessage()}))});
            report.setPassed(false);
            save(bos.toByteArray());
            return report;
        }

        if(!accurate){
            save(bos.toByteArray());
            int cn = computeColumnNumber(refLine, newLine);
            String expectedChar = "eol";
            if(cn >= 0 && refLine != null && refLine.length() > cn){
                expectedChar = (new Character(refLine.charAt(cn))).toString();
            }
            String foundChar = "null";
            if(cn >=0 && newLine != null && newLine.length() > cn){
                foundChar = (new Character(newLine.charAt(cn))).toString();
            }

            if(expectedChar.equals(" ")){
                expectedChar = "' '";
            }
            if(foundChar.equals(" ")){
                foundChar = "' '";
            }

            report.setErrorCode(ERROR_GENERATED_SVG_INACCURATE);
            report.addDescriptionEntry(Messages.formatMessage(ENTRY_KEY_LINE_NUMBER,null), new Integer(ln));
            report.addDescriptionEntry(Messages.formatMessage(ENTRY_KEY_COLUMN_NUMBER,null), new Integer(cn));
            report.addDescriptionEntry(Messages.formatMessage(ENTRY_KEY_COLUMN_EXPECTED_VALUE,null), expectedChar);
            report.addDescriptionEntry(Messages.formatMessage(ENTRY_KEY_COLUMN_FOUND_VALUE,null), foundChar);
            report.addDescriptionEntry(Messages.formatMessage(ENTRY_KEY_REFERENCE_LINE,null), refLine);
            report.addDescriptionEntry(Messages.formatMessage(ENTRY_KEY_NEW_LINE,null), newLine);
            report.setPassed(false);
        }
        else{
            report.setPassed(true);
        }

        return report;
    }
    
    public int computeColumnNumber(String aStr, String bStr){
        if(aStr == null || bStr == null){
            return -1;
        }

        int n = aStr.length();
        int i = -1;
        for(i=0; i<n; i++){
            char a = aStr.charAt(i);
            if(i < bStr.length()){
                char b = bStr.charAt(i);
                if(a != b){
                    break;
                }
            }
            else {
                break;
            }
        }

        return i;
    }

    /**
     * Saves the byte array in the "saveSVG" file
     * if that file's parent directory exists.
     */
    protected void save(byte[] data) throws IOException{
        if(saveSVG == null){
            return;
        }

        FileOutputStream os = new FileOutputStream(saveSVG);
        os.write(data);
        os.close();
    }

    /**
     * Compare the two input streams
     */
    protected boolean byteCompare(InputStream refStream,
                                  InputStream newStream)
        throws IOException{
        int b = 0;
        int nb = 0;
        do {
            if (b == nb || nb != 13)
                b = refStream.read();
            nb = newStream.read();
        } while (b != -1 && nb != -1 && (b == nb || nb == 13));
        refStream.close();
        newStream.close();
        return (b == nb || nb == 13);
    }

    /**
     * Builds an <tt>SVGGraphics2D</tt> with a default
     * configuration.
     */
    protected SVGGraphics2D buildSVGGraphics2D() {
        // CSSDocumentHandler.setParserClassName(CSS_PARSER_CLASS_NAME);
        DOMImplementation impl = GenericDOMImplementation.getDOMImplementation();
        String namespaceURI = SVGConstants.SVG_NAMESPACE_URI;
        Document domFactory = impl.createDocument(namespaceURI, SVG_SVG_TAG, null);
        SVGGeneratorContext ctx = SVGGeneratorContext.createDefault(domFactory);
        GraphicContextDefaults defaults 
            = new GraphicContextDefaults();
        defaults.font = new Font("Arial", Font.PLAIN, 12);
        ctx.setGraphicContextDefaults(defaults);
        ctx.setPrecision(12);
        return new SVGGraphics2D(ctx, false);
    }


    /**
     * Eventually configure the <tt>SVGGraphics2D</tt> after dumping in it and just
     * before serializing the DOM Tree.
     */
    protected void configureSVGGraphics2D(SVGGraphics2D g2d) {}
}
