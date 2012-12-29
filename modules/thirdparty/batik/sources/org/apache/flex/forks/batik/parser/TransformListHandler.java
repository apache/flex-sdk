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
 * This interface must be implemented and then registred as the
 * handler of a <code>TransformParser</code> instance in order to
 * be notified of parsing events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: TransformListHandler.java 475685 2006-11-16 11:16:05Z cam $
 */
public interface TransformListHandler {
    /**
     * Invoked when the tranform starts.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void startTransformList() throws ParseException;

    /**
     * Invoked when 'matrix(a, b, c, d, e, f)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void matrix(float a, float b, float c, float d, float e, float f)
        throws ParseException;

    /**
     * Invoked when 'rotate(theta)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void rotate(float theta) throws ParseException;

    /**
     * Invoked when 'rotate(theta, cx, cy)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void rotate(float theta, float cx, float cy) throws ParseException;

    /**
     * Invoked when 'translate(tx)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void translate(float tx) throws ParseException;

    /**
     * Invoked when 'translate(tx, ty)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void translate(float tx, float ty) throws ParseException;

    /**
     * Invoked when 'scale(sx)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void scale(float sx) throws ParseException;

    /**
     * Invoked when 'scale(sx, sy)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void scale(float sx, float sy) throws ParseException;

    /**
     * Invoked when 'skewX(skx)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform 
     */
    void skewX(float skx) throws ParseException;

    /**
     * Invoked when 'skewY(sky)' has been parsed.
     *
     * @exception ParseException if an error occured while processing
     * the transform
     */
    void skewY(float sky) throws ParseException;

    /**
     * Invoked when the transform ends.
     *
     * @exception ParseException if an error occured while processing
     * the transform
     */
    void endTransformList() throws ParseException;
}
