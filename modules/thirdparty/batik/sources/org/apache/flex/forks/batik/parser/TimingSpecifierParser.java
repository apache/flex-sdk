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

import java.io.IOException;
import java.util.Calendar;

/**
 * This class implements an event-based parser for SMIL timing specifier
 * list values.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimingSpecifierParser.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TimingSpecifierParser extends TimingParser {

    /**
     * The handler used to report parse events.
     */
    protected TimingSpecifierHandler timingSpecifierHandler;

    /**
     * Creates a new TimingSpecifierParser.
     * @param useSVG11AccessKeys allows the use of accessKey() timing
     *                           specifiers with a single character
     * @param useSVG12AccessKeys allows the use of accessKey() with a
     *                           DOM 3 key name
     */
    public TimingSpecifierParser(boolean useSVG11AccessKeys,
                                 boolean useSVG12AccessKeys) {
        super(useSVG11AccessKeys, useSVG12AccessKeys);
        timingSpecifierHandler = DefaultTimingSpecifierHandler.INSTANCE;
    }

    /**
     * Registers a parse event handler.
     */
    public void setTimingSpecifierHandler(TimingSpecifierHandler handler) {
        timingSpecifierHandler = handler;
    }

    /**
     * Returns the parse event handler in use.
     */
    public TimingSpecifierHandler getTimingSpecifierHandler() {
        return timingSpecifierHandler;
    }

    /**
     * Parses a timing specifier.
     */
    protected void doParse() throws ParseException, IOException {
        current = reader.read();
        Object[] spec = parseTimingSpecifier();
        skipSpaces();
        if (current != -1) {
            reportError("end.of.stream.expected",
                        new Object[] { new Integer(current) });
        }
        handleTimingSpecifier(spec);
    }

    /**
     * Calls the appropriate parse event handler function for the given
     * parsed timing specifier.
     */
    protected void handleTimingSpecifier(Object[] spec) {
        int type = ((Integer) spec[0]).intValue();
        switch (type) {
            case TIME_OFFSET:
                timingSpecifierHandler.offset(((Float) spec[1]).floatValue());
                break;
            case TIME_SYNCBASE:
                timingSpecifierHandler.syncbase(((Float) spec[1]).floatValue(),
                                                (String) spec[2],
                                                (String) spec[3]);
                break;
            case TIME_EVENTBASE:
                timingSpecifierHandler.eventbase(((Float) spec[1]).floatValue(),
                                                 (String) spec[2],
                                                 (String) spec[3]);
                break;
            case TIME_REPEAT: {
                float offset = ((Float) spec[1]).floatValue();
                String syncbaseID = (String) spec[2];
                if (spec[3] == null) {
                    timingSpecifierHandler.repeat(offset, syncbaseID);
                } else {
                    timingSpecifierHandler.repeat
                        (offset, syncbaseID, ((Integer) spec[3]).intValue());
                }
                break;
            }
            case TIME_ACCESSKEY:
                timingSpecifierHandler.accesskey
                    (((Float) spec[1]).floatValue(),
                     ((Character) spec[2]).charValue());
                break;
            case TIME_ACCESSKEY_SVG12:
                timingSpecifierHandler.accessKeySVG12
                    (((Float) spec[1]).floatValue(),
                     (String) spec[2]);
                break;
            case TIME_MEDIA_MARKER:
                timingSpecifierHandler.mediaMarker((String) spec[1],
                                                   (String) spec[2]);
                break;
            case TIME_WALLCLOCK:
                timingSpecifierHandler.wallclock((Calendar) spec[1]);
                break;
            case TIME_INDEFINITE:
                timingSpecifierHandler.indefinite();
                break;
        }
    }
}
