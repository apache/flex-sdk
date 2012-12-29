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
 * This class implements an event-based parser for the SVG angle
 * values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AngleParser.java 502181 2007-02-01 10:14:58Z dvholten $
 */
public class AngleParser extends NumberParser {

    /**
     * The angle handler used to report parse events.
     */
    protected AngleHandler angleHandler = DefaultAngleHandler.INSTANCE;

    /**
     * Allows an application to register an angle handler.
     *
     * <p>If the application does not register a handler, all
     * events reported by the parser will be silently ignored.
     *
     * <p>Applications may register a new or different handler in the
     * middle of a parse, and the parser must begin using the new
     * handler immediately.</p>
     * @param handler The transform list handler.
     */
    public void setAngleHandler(AngleHandler handler) {
        angleHandler = handler;
    }

    /**
     * Returns the angle handler in use.
     */
    public AngleHandler getAngleHandler() {
        return angleHandler;
    }

    /**
     * Parses the current reader representing an angle.
     */
    protected void doParse() throws ParseException, IOException {
        angleHandler.startAngle();

        current = reader.read();
        skipSpaces();

        try {
            float f = parseFloat();

            angleHandler.angleValue(f);

            s: if (current != -1) {
                switch (current) {
                case 0xD: case 0xA: case 0x20: case 0x9:
                    break s;
                }

                switch (current) {
                case 'd':
                    current = reader.read();
                    if (current != 'e') {
                        reportCharacterExpectedError('e', current );
                        break;
                    }
                    current = reader.read();
                    if (current != 'g') {
                        reportCharacterExpectedError('g', current );
                        break;
                    }
                    angleHandler.deg();
                    current = reader.read();
                    break;
                case 'g':
                    current = reader.read();
                    if (current != 'r') {
                        reportCharacterExpectedError('r', current );
                        break;
                    }
                    current = reader.read();
                    if (current != 'a') {
                        reportCharacterExpectedError('a', current );
                        break;
                    }
                    current = reader.read();
                    if (current != 'd') {
                        reportCharacterExpectedError('d', current );
                        break;
                    }
                    angleHandler.grad();
                    current = reader.read();
                    break;
                case 'r':
                    current = reader.read();
                    if (current != 'a') {
                        reportCharacterExpectedError('a', current );
                        break;
                    }
                    current = reader.read();
                    if (current != 'd') {
                        reportCharacterExpectedError('d', current );
                        break;
                    }
                    angleHandler.rad();
                    current = reader.read();
                    break;
                default:
                    reportUnexpectedCharacterError( current );
                }
            }

            skipSpaces();
            if (current != -1) {
                reportError("end.of.stream.expected",
                            new Object[] { new Integer(current) });
            }
        } catch (NumberFormatException e) {
            reportUnexpectedCharacterError( current );
        }
        angleHandler.endAngle();
    }
}
