/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.swing;

import java.awt.EventQueue;
import java.io.PrintWriter;
import java.io.StringWriter;

import org.w3c.flex.forks.dom.svg.SVGDocument;

import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;

/**
 * Test setDocument on JSVGComponent with non-Batik SVGOMDocument.
 *
 * This test constructs a generic Document with SVG content then it
 * ensures that when this is passed to JSVGComponet.setDocument it is
 * properly imported to an SVGOMDocument and rendered from there.
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: NullSetSVGDocumentTest.java,v 1.8 2005/03/27 08:58:37 cam Exp $
 */
public class NullSetSVGDocumentTest extends JSVGMemoryLeakTest {
    public NullSetSVGDocumentTest() {
    }

    public static final String TEST_NON_NULL_URI
        = "file:samples/anne.svg";

    /**
     * Entry describing the error
     */
    public static final String ENTRY_KEY_ERROR_DESCRIPTION 
        = "JSVGCanvasHandler.entry.key.error.description";

    /**
     * Entry describing the error
     */
    public static final String ERROR_IMAGE_NOT_CLEARED 
        = "NullSetSVGDocumentTest.message.error.image.not.cleared";

    public static final String ERROR_ON_SET 
        = "NullSetSVGDocumentTest.message.error.on.set";

    public String getName() { return getId(); }

    public JSVGCanvasHandler createHandler() {
        return new JSVGCanvasHandler(this, this) {
                public JSVGCanvas createCanvas() { 
                    return new JSVGCanvas() {
                            protected void installSVGDocument(SVGDocument doc){
                                super.installSVGDocument(doc);
                                if (doc != null) return;
                                handler.scriptDone();
                            }
                        };
                }
            };
    }

    public Runnable getRunnable(final JSVGCanvas canvas) {
        return new Runnable () {
                public void run() {
                    canvas.setSVGDocument(null);
                }};
            }

    /* JSVGCanvasHandler.Delegate Interface */
    public boolean canvasInit(JSVGCanvas canvas) {
        theCanvas = canvas;
        theFrame  = handler.getFrame();

        canvas.setDocumentState(JSVGCanvas.ALWAYS_DYNAMIC);
        canvas.setURI(TEST_NON_NULL_URI);

        registerObjectDesc(canvas, "JSVGCanvas");
        registerObjectDesc(handler.getFrame(), "JFrame");
        return true; // We did trigger a load event.
    }

    public void canvasRendered(JSVGCanvas canvas) {
        super.canvasRendered(canvas);
        try {
            EventQueue.invokeAndWait(getRunnable(canvas));
        } catch (Throwable t) {
            t.printStackTrace();
            StringWriter trace = new StringWriter();
            t.printStackTrace(new PrintWriter(trace));
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode(ERROR_ON_SET);
            report.setDescription(new TestReport.Entry[] { 
                new TestReport.Entry
                (fmt(ENTRY_KEY_ERROR_DESCRIPTION, null),
                 fmt(ERROR_ON_SET, new Object[]{ trace.toString()}))
            });
            report.setPassed(false);
            failReport = report;
        }
    }

    public boolean canvasUpdated(JSVGCanvas canvas) {
        return true;
    }


    public void canvasDone(JSVGCanvas canvas) {
        synchronized (this) {
            // Check that the original SVG
            // Document and GVT tree are cleared.
            checkObjects(new String[] { "SVGDoc", "GVT", "updateManager" });

            if (canvas.getOffScreen() == null)
                return;
            System.err.println(">>>>>>> Canvas not cleared");
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode(ERROR_IMAGE_NOT_CLEARED);
            // It would be great to provide the image here
            // but it's a lot of work and this isn't _really_
            // what we are testing.  More testing that
            // everything works (no exceptions thrown).
            report.setDescription(new TestReport.Entry[] { 
                new TestReport.Entry
                (fmt(ENTRY_KEY_ERROR_DESCRIPTION, null),
                 fmt(ERROR_IMAGE_NOT_CLEARED, null))});
            report.setPassed(false);
            failReport = report;
            return;
        }
    }
}
