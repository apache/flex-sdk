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
 * This class implements an event-based parser for the SVG Number
 * list values.
 *
 * @author  tonny@kiyut.com
 * @version $Id: NumberListParser.java 502167 2007-02-01 09:26:51Z dvholten $
 */
public class NumberListParser extends NumberParser {
    /**
     * The number list handler used to report parse events.
     */
    protected NumberListHandler numberListHandler;


    /** Creates a new instance of NumberListParser */
    public NumberListParser() {
        numberListHandler = DefaultNumberListHandler.INSTANCE;
    }

    /**
     * Allows an application to register a number list handler.
     *
     * <p>If the application does not register a handler, all
     * events reported by the parser will be silently ignored.
     *
     * <p>Applications may register a new or different handler in the
     * middle of a parse, and the parser must begin using the new
     * handler immediately.</p>
     * @param handler The number list handler.
     */
    public void setNumberListHandler(NumberListHandler handler) {
        numberListHandler = handler;
    }

    /**
     * Returns the number list handler in use.
     */
    public NumberListHandler getNumberListHandler() {
        return numberListHandler;
    }

    /**
     * Parses the given reader.
     */
    protected void doParse() throws ParseException, IOException {
        numberListHandler.startNumberList();

        current = reader.read();
        skipSpaces();

        try {
            for (;;) {
                numberListHandler.startNumber();
                float f = parseFloat();
                numberListHandler.numberValue(f);
                numberListHandler.endNumber();
                skipCommaSpaces();
                if (current == -1) {
                    break;
                }
            }
        } catch (NumberFormatException e) {
            reportUnexpectedCharacterError( current );
        }
        numberListHandler.endNumberList();
    }
}
