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

import java.util.Calendar;

/**
 * This interface must be implemented and then registered as the
 * handler of a {@link TimingSpecifierParser} instance in order
 * to be notified of parsing events.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimingSpecifierHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface TimingSpecifierHandler {

    /**
     * Invoked when an offset value timing specifier is parsed.
     */
    void offset(float offset);

    /**
     * Invoked when a syncbase value timing specifier is parsed.
     */
    void syncbase(float offset, String syncbaseID, String timeSymbol);

    /**
     * Invoked when an eventbase value timing specifier is parsed.
     */
    void eventbase(float offset, String eventbaseID, String eventType);

    /**
     * Invoked when a repeat value timing specifier with no iteration
     * is parsed.
     */
    void repeat(float offset, String syncbaseID);

    /**
     * Invoked when a repeat value timing specifier with an iteration
     * is parsed.
     */
    void repeat(float offset, String syncbaseID, int repeatIteration);

    /**
     * Invoked when an accesskey value timing specifier is parsed.
     */
    void accesskey(float offset, char key);

    /**
     * Invoked when an SVG 1.2 accessKey value timing specifier is parsed.
     */
    void accessKeySVG12(float offset, String keyName);

    /**
     * Invoked when a media marker value timing specifier is parsed.
     */
    void mediaMarker(String syncbaseID, String markerName);

    /**
     * Invoked when a wallclock value timing specifier is parsed.
     */
    void wallclock(Calendar time);

    /**
     * Invoked when an indefinite value timing specifier is parsed.
     */
    void indefinite();
}
