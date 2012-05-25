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
package org.apache.flex.forks.batik.parser;

import java.io.*;

import org.apache.flex.forks.batik.test.*;

/**
 * To test the path parser.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: PathParserTest.java,v 1.3 2004/08/18 07:16:42 vhardy Exp $
 */
public class PathParserTest extends AbstractTest {

    protected String sourcePath;
    protected String destinationPath;

    protected StringBuffer buffer;
    protected String resultPath;

    /**
     * Creates a new PathParserTest.
     * @param spath The path to parse.
     * @param dpath The path after serialization.
     */
    public PathParserTest(String spath, String dpath) {
        sourcePath = spath;
        destinationPath = dpath;
    }

    public TestReport runImpl() throws Exception {
        PathParser pp = new PathParser();
        pp.setPathHandler(new TestHandler());

        try {
            pp.parse(new StringReader(sourcePath));
        } catch (ParseException e) {
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode("parse.error");
            report.addDescriptionEntry("exception.text", e.getMessage());
            report.setPassed(false);
            return report;
        }

        if (!destinationPath.equals(resultPath)) {
            DefaultTestReport report = new DefaultTestReport(this);
            report.setErrorCode("invalid.parsing.events");
            report.addDescriptionEntry("expected.text", destinationPath);
            report.addDescriptionEntry("generated.text", resultPath);
            report.setPassed(false);
            return report;
        }

        return reportSuccess();
    }

    class TestHandler extends DefaultPathHandler {
        public TestHandler() {}

        public void startPath() throws ParseException {
            buffer = new StringBuffer();
        }
        
        public void movetoRel(float x, float y) throws ParseException {
            buffer.append('m');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void movetoAbs(float x, float y) throws ParseException {
            buffer.append('M');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void endPath() throws ParseException {
            resultPath = buffer.toString();
        }

        public void closePath() throws ParseException {
            buffer.append('Z');
        }

        public void linetoRel(float x, float y) throws ParseException {
            buffer.append('l');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void linetoAbs(float x, float y) throws ParseException {
            buffer.append('L');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void linetoHorizontalRel(float x) throws ParseException {
            buffer.append('h');
            buffer.append(x);
        }

        public void linetoHorizontalAbs(float x) throws ParseException {
            buffer.append('H');
            buffer.append(x);
        }

        public void linetoVerticalRel(float y) throws ParseException {
            buffer.append('v');
            buffer.append(y);
        }

        public void linetoVerticalAbs(float y) throws ParseException {
            buffer.append('V');
            buffer.append(y);
        }

        public void curvetoCubicRel(float x1, float y1, 
                                    float x2, float y2, 
                                    float x, float y) throws ParseException {
            buffer.append('c');
            buffer.append(x1);
            buffer.append(' ');
            buffer.append(y1);
            buffer.append(' ');
            buffer.append(x2);
            buffer.append(' ');
            buffer.append(y2);
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoCubicAbs(float x1, float y1, 
                                    float x2, float y2, 
                                    float x, float y) throws ParseException {
            buffer.append('C');
            buffer.append(x1);
            buffer.append(' ');
            buffer.append(y1);
            buffer.append(' ');
            buffer.append(x2);
            buffer.append(' ');
            buffer.append(y2);
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoCubicSmoothRel(float x2, float y2, 
                                          float x, float y) throws ParseException {
            buffer.append('s');
            buffer.append(x2);
            buffer.append(' ');
            buffer.append(y2);
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoCubicSmoothAbs(float x2, float y2, 
                                          float x, float y) throws ParseException {
            buffer.append('S');
            buffer.append(x2);
            buffer.append(' ');
            buffer.append(y2);
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoQuadraticRel(float x1, float y1, 
                                        float x, float y) throws ParseException {
            buffer.append('q');
            buffer.append(x1);
            buffer.append(' ');
            buffer.append(y1);
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoQuadraticAbs(float x1, float y1, 
                                        float x, float y) throws ParseException {
            buffer.append('Q');
            buffer.append(x1);
            buffer.append(' ');
            buffer.append(y1);
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoQuadraticSmoothRel(float x, float y)
            throws ParseException {
            buffer.append('t');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void curvetoQuadraticSmoothAbs(float x, float y)
            throws ParseException {
            buffer.append('T');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void arcRel(float rx, float ry, 
                           float xAxisRotation, 
                           boolean largeArcFlag, boolean sweepFlag, 
                           float x, float y) throws ParseException {
            buffer.append('a');
            buffer.append(rx);
            buffer.append(' ');
            buffer.append(ry);
            buffer.append(' ');
            buffer.append(xAxisRotation);
            buffer.append(' ');
            buffer.append(largeArcFlag ? '1' : '0');
            buffer.append(' ');
            buffer.append(sweepFlag ? '1' : '0');
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }

        public void arcAbs(float rx, float ry, 
                           float xAxisRotation, 
                           boolean largeArcFlag, boolean sweepFlag, 
                           float x, float y) throws ParseException {
            buffer.append('A');
            buffer.append(rx);
            buffer.append(' ');
            buffer.append(ry);
            buffer.append(' ');
            buffer.append(xAxisRotation);
            buffer.append(' ');
            buffer.append(largeArcFlag ? '1' : '0');
            buffer.append(' ');
            buffer.append(sweepFlag ? '1' : '0');
            buffer.append(' ');
            buffer.append(x);
            buffer.append(' ');
            buffer.append(y);
        }
    }
}
