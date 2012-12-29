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

/**
 * This class implements an event-based parser for SMIL timing specifier
 * list values.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimingSpecifierListParser.java 502167 2007-02-01 09:26:51Z dvholten $
 */
public class TimingSpecifierListParser extends TimingSpecifierParser {

    /**
     * Creates a new TimingSpecifierListParser.
     * @param useSVG11AccessKeys allows the use of accessKey() timing
     *                           specifiers with a single character
     * @param useSVG12AccessKeys allows the use of accessKey() with a
     *                           DOM 3 key name
     */
    public TimingSpecifierListParser(boolean useSVG11AccessKeys,
                                     boolean useSVG12AccessKeys) {
        super(useSVG11AccessKeys, useSVG12AccessKeys);
        timingSpecifierHandler = DefaultTimingSpecifierListHandler.INSTANCE;
    }

    /**
     * Registers a parse event handler.
     */
    public void setTimingSpecifierListHandler
            (TimingSpecifierListHandler handler) {
        timingSpecifierHandler = handler;
    }

    /**
     * Returns the parse event handler in use.
     */
    public TimingSpecifierListHandler getTimingSpecifierListHandler() {
        return (TimingSpecifierListHandler) timingSpecifierHandler;
    }

    /**
     * Parses a timing specifier list.
     */
    protected void doParse() throws ParseException, IOException {
        current = reader.read();

        ((TimingSpecifierListHandler) timingSpecifierHandler)
            .startTimingSpecifierList();

        skipSpaces();

        if (current != -1) {
            for (;;) {
                Object[] spec = parseTimingSpecifier();
                handleTimingSpecifier(spec);
                skipSpaces();
                if (current == -1) {
                    break;
                }
                if (current == ';') {
                    current = reader.read();
                    continue;
                }
                reportUnexpectedCharacterError( current );
            }
        }

        skipSpaces();

        if (current != -1) {
            reportUnexpectedCharacterError( current );
        }

        ((TimingSpecifierListHandler) timingSpecifierHandler)
            .endTimingSpecifierList();
    }
}
