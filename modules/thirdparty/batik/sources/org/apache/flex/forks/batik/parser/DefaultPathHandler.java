/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.parser;

/**
 * The class provides an adapter for PathHandler.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultPathHandler.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public class DefaultPathHandler implements PathHandler {

    /**
     * The only instance of this class.
     */
    public static final PathHandler INSTANCE
        = new DefaultPathHandler();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultPathHandler() {
    }

    /**
     * Implements {@link PathHandler#startPath()}.
     */
    public void startPath() throws ParseException {
    }

    /**
     * Implements {@link PathHandler#endPath()}.
     */
    public void endPath() throws ParseException {
    }

    /**
     * Implements {@link PathHandler#movetoRel(float,float)}.
     */
    public void movetoRel(float x, float y) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#movetoAbs(float,float)}.
     */
    public void movetoAbs(float x, float y) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#closePath()}.
     */
    public void closePath() throws ParseException {
    }

    /**
     * Implements {@link PathHandler#linetoRel(float,float)}.
     */
    public void linetoRel(float x, float y) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#linetoAbs(float,float)}.
     */
    public void linetoAbs(float x, float y) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#linetoHorizontalRel(float)}.
     */
    public void linetoHorizontalRel(float x) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#linetoHorizontalAbs(float)}.
     */
    public void linetoHorizontalAbs(float x) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#linetoVerticalRel(float)}.
     */
    public void linetoVerticalRel(float y) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#linetoVerticalAbs(float)}.
     */
    public void linetoVerticalAbs(float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicRel(float,float,float,float,float,float)}.
     */
    public void curvetoCubicRel(float x1, float y1,
                                float x2, float y2,
                                float x, float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicAbs(float,float,float,float,float,float)}.
     */
    public void curvetoCubicAbs(float x1, float y1,
                                float x2, float y2,
                                float x, float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicSmoothRel(float,float,float,float)}.
     */
    public void curvetoCubicSmoothRel(float x2, float y2,
                                      float x, float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#curvetoCubicSmoothAbs(float,float,float,float)}.
     */
    public void curvetoCubicSmoothAbs(float x2, float y2,
                                      float x, float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#curvetoQuadraticRel(float,float,float,float)}.
     */
    public void curvetoQuadraticRel(float x1, float y1,
                                    float x, float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#curvetoQuadraticAbs(float,float,float,float)}.
     */
    public void curvetoQuadraticAbs(float x1, float y1,
                                    float x, float y) throws ParseException {
    }

    /**
     * Implements {@link PathHandler#curvetoQuadraticSmoothRel(float,float)}.
     */
    public void curvetoQuadraticSmoothRel(float x, float y)
        throws ParseException {
    }

    /**
     * Implements {@link PathHandler#curvetoQuadraticSmoothAbs(float,float)}.
     */
    public void curvetoQuadraticSmoothAbs(float x, float y)
        throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#arcRel(float,float,float,boolean,boolean,float,float)}.
     */
    public void arcRel(float rx, float ry,
                       float xAxisRotation,
                       boolean largeArcFlag, boolean sweepFlag,
                       float x, float y) throws ParseException {
    }

    /**
     * Implements {@link
     * PathHandler#arcAbs(float,float,float,boolean,boolean,float,float)}.
     */
    public void arcAbs(float rx, float ry,
                       float xAxisRotation,
                       boolean largeArcFlag, boolean sweepFlag,
                       float x, float y) throws ParseException {
    }
}
