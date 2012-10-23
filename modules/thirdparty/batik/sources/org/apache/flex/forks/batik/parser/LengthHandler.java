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
 * handler of a <code>LengthParser</code> instance in order to be
 * notified of parsing events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LengthHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface LengthHandler {
    /**
     * Invoked when the length attribute starts.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void startLength() throws ParseException;

    /**
     * Invoked when a float value has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void lengthValue(float v) throws ParseException;

    /**
     * Invoked when 'em' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void em() throws ParseException;

    /**
     * Invoked when 'ex' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void ex() throws ParseException;

    /**
     * Invoked when 'in' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void in() throws ParseException;

    /**
     * Invoked when 'cm' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void cm() throws ParseException;

    /**
     * Invoked when 'mm' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void mm() throws ParseException;

    /**
     * Invoked when 'pc' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void pc() throws ParseException;

    /**
     * Invoked when 'pt' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void pt() throws ParseException;

    /**
     * Invoked when 'px' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void px() throws ParseException;

    /**
     * Invoked when '%' has been parsed.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void percentage() throws ParseException;

    /**
     * Invoked when the length attribute ends.
     * @exception ParseException if an error occures while processing
     *                           the length
     */
    void endLength() throws ParseException;
}
