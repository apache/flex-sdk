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
 * This class implements an event-based parser for the SVG preserveAspectRatio
 * attribute values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: PreserveAspectRatioParser.java 502167 2007-02-01 09:26:51Z dvholten $
 */
public class PreserveAspectRatioParser extends AbstractParser {

    /**
     * The PreserveAspectRatio handler used to report parse events.
     */
    protected PreserveAspectRatioHandler preserveAspectRatioHandler;

    /**
     * Creates a new PreserveAspectRatioParser.
     */
    public PreserveAspectRatioParser() {
        preserveAspectRatioHandler =
            DefaultPreserveAspectRatioHandler.INSTANCE;
    }

    /**
     * Allows an application to register a PreserveAspectRatioParser handler.
     *
     * <p>If the application does not register a handler, all
     * events reported by the parser will be silently ignored.
     *
     * <p>Applications may register a new or different handler in the
     * middle of a parse, and the parser must begin using the new
     * handler immediately.</p>
     * @param handler The transform list handler.
     */
    public void
        setPreserveAspectRatioHandler(PreserveAspectRatioHandler handler) {
        preserveAspectRatioHandler = handler;
    }

    /**
     * Returns the length handler in use.
     */
    public PreserveAspectRatioHandler getPreserveAspectRatioHandler() {
        return preserveAspectRatioHandler;
    }

    /**
     * Parses the current stream.
     */
    protected void doParse() throws ParseException, IOException {
        current = reader.read();
        skipSpaces();

        parsePreserveAspectRatio();
    }

    /**
     * Parses a PreserveAspectRatio attribute.
     */
    protected void parsePreserveAspectRatio()
        throws ParseException, IOException {
        preserveAspectRatioHandler.startPreserveAspectRatio();

        align: switch (current) {
        case 'n':
            current = reader.read();
            if (current != 'o') {
                reportCharacterExpectedError( 'o',current );
                skipIdentifier();
                break align;
            }
            current = reader.read();
            if (current != 'n') {
                reportCharacterExpectedError( 'o',current );
                skipIdentifier();
                break align;
            }
            current = reader.read();
            if (current != 'e') {
                reportCharacterExpectedError( 'e',current );
                skipIdentifier();
                break align;
            }
            current = reader.read();
            skipSpaces();
            preserveAspectRatioHandler.none();
            break;

        case 'x':
            current = reader.read();
            if (current != 'M') {
                reportCharacterExpectedError( 'M',current );
                skipIdentifier();
                break;
            }
            current = reader.read();
            switch (current) {
            case 'a':
                current = reader.read();
                if (current != 'x') {
                    reportCharacterExpectedError( 'x',current );
                    skipIdentifier();
                    break align;
                }
                current = reader.read();
                if (current != 'Y') {
                    reportCharacterExpectedError( 'Y',current );
                    skipIdentifier();
                    break align;
                }
                current = reader.read();
                if (current != 'M') {
                    reportCharacterExpectedError( 'M',current );
                    skipIdentifier();
                    break align;
                }
                current = reader.read();
                switch (current) {
                case 'a':
                    current = reader.read();
                    if (current != 'x') {
                        reportCharacterExpectedError( 'x',current );
                        skipIdentifier();
                        break align;
                    }
                    preserveAspectRatioHandler.xMaxYMax();
                    current = reader.read();
                    break;
                case 'i':
                    current = reader.read();
                    switch (current) {
                    case 'd':
                        preserveAspectRatioHandler.xMaxYMid();
                        current = reader.read();
                        break;
                    case 'n':
                        preserveAspectRatioHandler.xMaxYMin();
                        current = reader.read();
                        break;
                    default:
                        reportUnexpectedCharacterError( current );
                        skipIdentifier();
                        break align;
                    }
                }
                break;
            case 'i':
                current = reader.read();
                switch (current) {
                case 'd':
                    current = reader.read();
                    if (current != 'Y') {
                        reportCharacterExpectedError( 'Y',current );
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    if (current != 'M') {
                        reportCharacterExpectedError( 'M',current );
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    switch (current) {
                    case 'a':
                        current = reader.read();
                        if (current != 'x') {
                            reportCharacterExpectedError( 'x',current );
                            skipIdentifier();
                            break align;
                        }
                        preserveAspectRatioHandler.xMidYMax();
                        current = reader.read();
                        break;
                    case 'i':
                        current = reader.read();
                        switch (current) {
                        case 'd':
                            preserveAspectRatioHandler.xMidYMid();
                            current = reader.read();
                            break;
                        case 'n':
                            preserveAspectRatioHandler.xMidYMin();
                            current = reader.read();
                            break;
                        default:
                            reportUnexpectedCharacterError( current );
                            skipIdentifier();
                            break align;
                        }
                    }
                    break;
                case 'n':
                    current = reader.read();
                    if (current != 'Y') {
                        reportCharacterExpectedError( 'Y',current );
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    if (current != 'M') {
                        reportCharacterExpectedError( 'M',current );
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    switch (current) {
                    case 'a':
                        current = reader.read();
                        if (current != 'x') {
                            reportCharacterExpectedError( 'x',current );
                            skipIdentifier();
                            break align;
                        }
                        preserveAspectRatioHandler.xMinYMax();
                        current = reader.read();
                        break;
                    case 'i':
                        current = reader.read();
                        switch (current) {
                        case 'd':
                            preserveAspectRatioHandler.xMinYMid();
                            current = reader.read();
                            break;
                        case 'n':
                            preserveAspectRatioHandler.xMinYMin();
                            current = reader.read();
                            break;
                        default:
                            reportUnexpectedCharacterError( current );
                            skipIdentifier();
                            break align;
                        }
                    }
                    break;
                default:
                    reportUnexpectedCharacterError( current );
                    skipIdentifier();
                    break align;
                }
                break;
            default:
                reportUnexpectedCharacterError( current );
                skipIdentifier();
            }
            break;
        default:
            if (current != -1) {
                reportUnexpectedCharacterError( current );
                skipIdentifier();
            }
        }

        skipCommaSpaces();

        switch (current) {
        case 'm':
            current = reader.read();
            if (current != 'e') {
                reportCharacterExpectedError( 'e',current );
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'e') {
                reportCharacterExpectedError( 'e',current );
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 't') {
                reportCharacterExpectedError( 't',current );
                skipIdentifier();
                break;
            }
            preserveAspectRatioHandler.meet();
            current = reader.read();
            break;
        case 's':
            current = reader.read();
            if (current != 'l') {
                reportCharacterExpectedError( 'l',current );
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'i') {
                reportCharacterExpectedError( 'i',current );
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'c') {
                reportCharacterExpectedError( 'c',current );
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'e') {
                reportCharacterExpectedError( 'e',current );
                skipIdentifier();
                break;
            }
            preserveAspectRatioHandler.slice();
            current = reader.read();
            break;
        default:
            if (current != -1) {
                reportUnexpectedCharacterError( current );
                skipIdentifier();
            }
        }

        skipSpaces();
        if (current != -1) {
            reportError("end.of.stream.expected",
                        new Object[] { new Integer(current) });
        }

        preserveAspectRatioHandler.endPreserveAspectRatio();
    }

    /**
     * Skips characters in the given reader until a white space is encountered.
     */
    protected void skipIdentifier() throws IOException {
        loop: for (;;) {
            current = reader.read();
            switch(current) {
            case 0xD: case 0xA: case 0x20: case 0x9:
                current = reader.read();
                break loop;
            default:
                if (current == -1) {
                    break loop;
                }
            }
        }
    }
}
