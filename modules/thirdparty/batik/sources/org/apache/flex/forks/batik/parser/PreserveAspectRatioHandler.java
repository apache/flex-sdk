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
 * handler of a <code>PreserveAspectRatioParser</code> instance in order to
 * be notified of parsing events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: PreserveAspectRatioHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface PreserveAspectRatioHandler {
    /**
     * Invoked when the PreserveAspectRatio parsing starts.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void startPreserveAspectRatio() throws ParseException;

    /**
     * Invoked when 'none' been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void none() throws ParseException;

    /**
     * Invoked when 'xMaxYMax' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMaxYMax() throws ParseException;

    /**
     * Invoked when 'xMaxYMid' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMaxYMid() throws ParseException;

    /**
     * Invoked when 'xMaxYMin' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMaxYMin() throws ParseException;

    /**
     * Invoked when 'xMidYMax' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMidYMax() throws ParseException;

    /**
     * Invoked when 'xMidYMid' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMidYMid() throws ParseException;

    /**
     * Invoked when 'xMidYMin' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMidYMin() throws ParseException;

    /**
     * Invoked when 'xMinYMax' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMinYMax() throws ParseException;

    /**
     * Invoked when 'xMinYMid' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMinYMid() throws ParseException;

    /**
     * Invoked when 'xMinYMin' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void xMinYMin() throws ParseException;

    /**
     * Invoked when 'meet' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void meet() throws ParseException;

    /**
     * Invoked when 'slice' has been parsed.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio 
     */
    void slice() throws ParseException;

    /**
     * Invoked when the PreserveAspectRatio parsing ends.
     * @exception ParseException if an error occured while processing
     * the PreserveAspectRatio
     */
    void endPreserveAspectRatio() throws ParseException;
}
