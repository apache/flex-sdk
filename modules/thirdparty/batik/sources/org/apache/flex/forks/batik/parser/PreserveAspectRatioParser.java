/*

   Copyright 2000-2003  The Apache Software Foundation 

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

import java.io.IOException;

/**
 * This class implements an event-based parser for the SVG preserveAspectRatio
 * attribute values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: PreserveAspectRatioParser.java,v 1.10 2004/08/18 07:14:47 vhardy Exp $
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
		reportError("character.expected",
			    new Object[] { new Character('o'),
                                           new Integer(current) });
		skipIdentifier();
		break align;
	    }
	    current = reader.read();
	    if (current != 'n') {
		reportError("character.expected",
			    new Object[] { new Character('n'),
					   new Integer(current) });
		skipIdentifier();
		break align;
	    }
	    current = reader.read();
	    if (current != 'e') {
		reportError("character.expected",
			    new Object[] { new Character('e'),
					   new Integer(current) });
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
                reportError("character.expected",
                            new Object[] { new Character('M'),
					   new Integer(current) });
                skipIdentifier();
                break;
            }
            current = reader.read();
            switch (current) {
            case 'a':
                current = reader.read();
                if (current != 'x') {
                    reportError("character.expected",
                                new Object[] { new Character('x'),
			          	       new Integer(current) });
                    skipIdentifier();
                    break align;
                }
                current = reader.read();
                if (current != 'Y') {
                    reportError("character.expected",
                                new Object[] { new Character('Y'),
					       new Integer(current) });
                    skipIdentifier();
                    break align;
                }
                current = reader.read();
                if (current != 'M') {
                    reportError("character.expected",
                                new Object[] { new Character('M'),
					       new Integer(current) });
                    skipIdentifier();
                    break align;
                }
                current = reader.read();
                switch (current) {
                case 'a':
                    current = reader.read();
                    if (current != 'x') {
                        reportError("character.expected",
                                    new Object[] { new Character('x'),
						   new Integer(current) });
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
                        reportError("character.unexpected",
                                    new Object[] { new Integer(current) });
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
                        reportError("character.expected",
                                    new Object[] { new Character('Y'),
						   new Integer(current) });
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    if (current != 'M') {
                        reportError("character.expected",
                                    new Object[] { new Character('M'),
						   new Integer(current) });
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    switch (current) {
                    case 'a':
                        current = reader.read();
                        if (current != 'x') {
                            reportError
                                ("character.expected",
                                 new Object[] { new Character('x'),
                                                    new Integer(current) });
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
			    reportError("character.unexpected",
					new Object[] { new Integer(current) });
			    skipIdentifier();
			    break align;
                        }
                    }
                    break;
                case 'n':
                    current = reader.read();
                    if (current != 'Y') {
                        reportError("character.expected",
                                    new Object[] { new Character('Y'),
					           new Integer(current) });
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    if (current != 'M') {
                        reportError("character.expected",
                                    new Object[] { new Character('M'),
						   new Integer(current) });
                        skipIdentifier();
                        break align;
                    }
                    current = reader.read();
                    switch (current) {
                    case 'a':
                        current = reader.read();
                        if (current != 'x') {
                            reportError
                                ("character.expected",
                                 new Object[] { new Character('x'),
                                                new Integer(current) });
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
                            reportError
                                ("character.unexpected",
                                 new Object[] { new Integer(current) });
                            skipIdentifier();
                            break align;
                        }
                    }
                    break;
                default:
                    reportError("character.unexpected",
                                new Object[] { new Integer(current) });
                    skipIdentifier();
                    break align;
                }
                break;
            default:
                reportError("character.unexpected",
                            new Object[] { new Integer(current) });
                skipIdentifier();
            }
            break;
        default:
            if (current != -1) {
                reportError("character.unexpected",
                            new Object[] { new Integer(current) });
                skipIdentifier();
            }
        }

        skipCommaSpaces();

        switch (current) {
        case 'm':
            current = reader.read();
            if (current != 'e') {
                reportError("character.expected",
                            new Object[] { new Character('e'),
				           new Integer(current) });
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'e') {
                reportError("character.expected",
                            new Object[] { new Character('e'),
			         	   new Integer(current) });
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 't') {
                reportError("character.expected",
                            new Object[] { new Character('t'),
	        			   new Integer(current) });
                skipIdentifier();
                break;
            }
            preserveAspectRatioHandler.meet();
            current = reader.read();
            break;
        case 's':
            current = reader.read();
            if (current != 'l') {
                reportError("character.expected",
                            new Object[] { new Character('l'),
				           new Integer(current) });
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'i') {
                reportError("character.expected",
                            new Object[] { new Character('i'),
					   new Integer(current) });
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'c') {
                reportError("character.expected",
                            new Object[] { new Character('c'),
			        	   new Integer(current) });
                skipIdentifier();
                break;
            }
            current = reader.read();
            if (current != 'e') {
                reportError("character.expected",
                            new Object[] { new Character('e'),
					   new Integer(current) });
                skipIdentifier();
                break;
            }
            preserveAspectRatioHandler.slice();
            current = reader.read();
            break;
        default:
            if (current != -1) {
                reportError("character.unexpected",
                            new Object[] { new Integer(current) });
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
     * @return the first character after the space.
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
