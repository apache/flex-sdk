/*
 * Copyright 1999-2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.gvt;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.w3c.dom.Element;
import org.w3c.flex.forks.dom.svg.SVGTextContentElement;

import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.JSVGCanvasHandler;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;
import org.apache.flex.forks.batik.test.svg.JSVGRenderingAccuracyTest;


/**
 * This test validates that the text selection API's work properly.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: TextSelectionTest.java,v 1.6 2005/04/01 02:28:16 deweese Exp $
 */
public class TextSelectionTest extends JSVGRenderingAccuracyTest {

    /**
     * Directory for reference files
     */
    public static final String REFERENCE_DIR
        = "test-references/org/apache/batik/gvt/";

    public static final String VARIATION_DIR
        = "variation/";

    public static final String CANDIDATE_DIR
        = "candidate/";


    /**
     * Error when unable to load requested SVG file
     * {0} = file
     * {1} = exception
     */
    public static final String ERROR_READING_SVG
        = "TextSelectionTest.error.reading.svg";

    /**
     * Error id doesn't reference an element
     * {0} = id
     */
    public static final String ERROR_BAD_ID
        = "TextSelectionTest.error.bad.id";

    /**
     * Error id doesn't reference a text element
     * {0} = id
     * {1} = element referenced
     */
    public static final String ERROR_ID_NOT_TEXT
        = "TextSelectionTest.error.id.not.text";

    /**
     * Error couldn't get selection highlight specified.
     * {0} = id
     * {1} = start index
     * {2} = end index
     * {3} = exception
     */
    public static final String ERROR_GETTING_SELECTION
        = "TextSelectionTest.error.getting.selection";

    /**
     * Error when unable to read/open ref URL
     * {0} = URL
     * {1} = exception stack trace.
     */
    public static final String ERROR_CANNOT_READ_REF_URL
        = "TextSelectionTest.error.cannot.read.ref.url";

    /**
     * Result didn't match reference result.
     * {0} = first byte of mismatch
     */
    public static final String ERROR_WRONG_RESULT
        = "TextSelectionTest.error.wrong.result";

    /**
     * No Reference or Variation file to compaire with.
     * {0} = reference url
     */
    public static final String ERROR_NO_REFERENCE
        = "TextSelectionTest.error.no.reference";


    public static final String ENTRY_KEY_ERROR_DESCRIPTION
        = "TextSelectionTest.entry.key.error.description";

    protected String textID    = null;
    protected int    start;
    protected int    end;

    public void setId(String id) { this.id = id; }

    /**
     * Constructor. ref is ignored if action == ROUND.
     * @param svg    The svg file to load
     * @param id     The element to select text from (must be a <text> element)
     * @param start  The first character to select
     * @param end    The last character to select
     * @param ref    The reference file.
     */
    public TextSelectionTest(String file,   String textID, 
                             Integer start, Integer end) {
        this.textID    = textID;
        this.start = start.intValue();
        this.end   = end.intValue();
        super.setFile(file);
    }

    protected String buildRefImgURL(String svgDir, String svgFile){
        return getRefImagePrefix() + svgDir + getRefImageSuffix() + 
            svgFile + "-" +textID+ "-" + start + "-" + end +PNG_EXTENSION;
    }

    public String buildVariationURL(String svgDir, String svgFile){
        return getVariationPrefix() + svgDir + getVariationSuffix() + 
            svgFile + "-" +textID+ "-" + start + "-" + end +PNG_EXTENSION;

    }

    public String  buildSaveVariationFile(String svgDir, String svgFile){
        return getSaveVariationPrefix() + svgDir + getSaveVariationSuffix() + 
            svgFile + "-" +textID+ "-" + start + "-" + end +PNG_EXTENSION;
    }

    public String  buildCandidateReferenceFile(String svgDir, String svgFile){
        return getCandidateReferencePrefix() + svgDir + getCandidateReferenceSuffix() + 
            svgFile + "-" +textID+ "-" + start + "-" + end +PNG_EXTENSION;
    }
    /**
     * Returns this Test's name
     */
    public String getName() {
        return super.getName() + "#" +textID+ "(" + start + "," + end + ")";
    }
    
    public JSVGCanvasHandler createCanvasHandler() {
        return new JSVGCanvasHandler(this, this) {
                public JSVGCanvas createCanvas() { 
                    JSVGCanvas ret = new JSVGCanvas(); 
                    ret.setDocumentState(JSVGCanvas.ALWAYS_DYNAMIC);
                    return ret;
                }
            };
    }

    public void canvasRendered(JSVGCanvas canvas) {
        DefaultTestReport report = new DefaultTestReport(this);
        try {
            Element e = canvas.getSVGDocument().getElementById(textID);
            if (e == null) {
                report.setErrorCode(ERROR_BAD_ID);
                report.setDescription(new TestReport.Entry[] {
                    new TestReport.Entry
                        (Messages.formatMessage
                         (ENTRY_KEY_ERROR_DESCRIPTION, null),
                         Messages.formatMessage
                         (ERROR_BAD_ID, new String[]{textID}))
                        });
                report.setPassed(false);
                failReport = report;
                return;
            }
            if (!(e instanceof SVGTextContentElement)) {
                report.setErrorCode(ERROR_ID_NOT_TEXT);
                report.setDescription(new TestReport.Entry[] {
                    new TestReport.Entry
                        (Messages.formatMessage
                         (ENTRY_KEY_ERROR_DESCRIPTION, null),
                         Messages.formatMessage
                         (ERROR_ID_NOT_TEXT, new String[]{id, e.toString()}))
                        });
                report.setPassed(false);
                failReport = report;
                return;
            }
            SVGTextContentElement tce = (SVGTextContentElement)e;
            tce.selectSubString(start, end);
        } catch(Exception e) {
            StringWriter trace = new StringWriter();
            e.printStackTrace(new PrintWriter(trace));
            report.setErrorCode(ERROR_GETTING_SELECTION);
            report.setDescription(new TestReport.Entry[] {
                new TestReport.Entry
                    (Messages.formatMessage(ENTRY_KEY_ERROR_DESCRIPTION, null),
                     Messages.formatMessage
                     (ERROR_GETTING_SELECTION,
                      new String[]{id, ""+start, ""+end, trace.toString()}))
                    });
            report.setPassed(false);
            failReport = report;
        }
        finally {
            scriptDone();
        }
    }
}

