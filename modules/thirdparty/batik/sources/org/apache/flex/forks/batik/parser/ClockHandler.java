/*

   Copyright 2000  The Apache Software Foundation 

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

/**
 * This interface must be implemented and then registred as the
 * handler of a <code>ClockParser</code> instance in order to be
 * notified of parsing events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ClockHandler.java,v 1.3 2004/08/18 07:14:46 vhardy Exp $
 */
public interface ClockHandler {
    /**
     * Invoked when the clock attribute parsing starts.
     * @exception ParseException if an error occured while processing the clock
     */
    void startClock() throws ParseException;

    /**
     * Invoked when an int value has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void intValue(int v) throws ParseException;

    /**
     * Invoked when ':' has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void colon() throws ParseException;

    /**
     * Invoked when '.' has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void dot() throws ParseException;

    /**
     * Invoked when 'h' has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void h() throws ParseException;

    /**
     * Invoked when 'min' has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void min() throws ParseException;

    /**
     * Invoked when 's' has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void s() throws ParseException;

    /**
     * Invoked when 'ms' has been parsed.
     * @exception ParseException if an error occured while processing the clock
     */
    void ms() throws ParseException;

    /**
     * Invoked when the clock attribute parsing ends.
     * @exception ParseException if an error occured while processing the clock
     */
    void endClock() throws ParseException;
}
