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
 * This class implements an event-based parser for the SVG transform
 * attribute values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: TransformListParser.java,v 1.10 2004/08/18 07:14:47 vhardy Exp $
 */
public class TransformListParser extends NumberParser {

    /**
     * The transform list handler used to report parse events.
     */
    protected TransformListHandler transformListHandler;

    /**
     * Creates a new TransformListParser.
     */
    public TransformListParser() {
	transformListHandler = DefaultTransformListHandler.INSTANCE;
    }

    /**
     * Allows an application to register a transform list handler.
     *
     * <p>If the application does not register a handler, all
     * events reported by the parser will be silently ignored.
     *
     * <p>Applications may register a new or different handler in the
     * middle of a parse, and the parser must begin using the new
     * handler immediately.</p>
     * @param handler The transform handler.
     */
    public void setTransformListHandler(TransformListHandler handler) {
	transformListHandler = handler;
    }

    /**
     * Returns the transform list handler in use.
     */
    public TransformListHandler getTransformListHandler() {
	return transformListHandler;
    }

    /**
     * Parses the current reader.
     */
    protected void doParse() throws ParseException, IOException {
	transformListHandler.startTransformList();

	loop: for (;;) {
            try {
                current = reader.read();
                switch (current) {
                case 0xD:
                case 0xA:
                case 0x20:
                case 0x9:
                case ',':
                    break;
                case 'm':
                    parseMatrix();
                    break;
                case 'r':
                    parseRotate();
                    break;
                case 't':
                    parseTranslate();
                    break;
                case 's':
                    current = reader.read();
                    switch (current) {
                    case 'c':
                        parseScale();
                        break;
                    case 'k':
                        parseSkew();
                        break;
                    default:
                        reportError("character.unexpected",
                                    new Object[] { new Integer(current) });
                        skipTransform();
                    }
                    break;
                case -1:
                    break loop;
                default:
                    reportError("character.unexpected",
                                new Object[] { new Integer(current) });
                    skipTransform();
                }
            } catch (ParseException e) {
                errorHandler.error(e);
                skipTransform();
            }
        }
	skipSpaces();
	if (current != -1) {
	    reportError("end.of.stream.expected",
			new Object[] { new Integer(current) });
	}

	transformListHandler.endTransformList();
    }

    /**
     * Parses a matrix transform. 'm' is assumed to be the current character.
     */
    protected void parseMatrix() throws ParseException, IOException {
	current = reader.read();

	// Parse 'atrix wsp? ( wsp?'
	if (current != 'a') {
	    reportError("character.expected",
			new Object[] { new Character('a'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 't') {
	    reportError("character.expected",
			new Object[] { new Character('t'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'r') {
	    reportError("character.expected",
			new Object[] { new Character('r'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'i') {
	    reportError("character.expected",
			new Object[] { new Character('i'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'x') {
	    reportError("character.expected",
			new Object[] { new Character('x'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();
	if (current != '(') {
	    reportError("character.expected",
			new Object[] { new Character('('),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();

        float a = parseFloat();
        skipCommaSpaces();
        float b = parseFloat();
        skipCommaSpaces();
        float c = parseFloat();
        skipCommaSpaces();
        float d = parseFloat();
        skipCommaSpaces();
        float e = parseFloat();
        skipCommaSpaces();
        float f = parseFloat();
	
        skipSpaces();
        if (current != ')') {
            reportError("character.expected",
                        new Object[] { new Character(')'),
                                       new Integer(current) });
            skipTransform();
            return;
        }

        transformListHandler.matrix(a, b, c, d, e, f);
    }

    /**
     * Parses a rotate transform. 'r' is assumed to be the current character.
     * @return the current character.
     */
    protected void parseRotate() throws ParseException, IOException {
	current = reader.read();

	// Parse 'otate wsp? ( wsp?'
	if (current != 'o') {
	    reportError("character.expected",
			new Object[] { new Character('o'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 't') {
	    reportError("character.expected",
			new Object[] { new Character('t'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'a') {
	    reportError("character.expected",
			new Object[] { new Character('a'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 't') {
	    reportError("character.expected",
			new Object[] { new Character('t'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'e') {
	    reportError("character.expected",
			new Object[] { new Character('e'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();

	if (current != '(') {
	    reportError("character.expected",
			new Object[] { new Character('('),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();

        float theta = parseFloat();
        skipSpaces();
        
        switch (current) {
        case ')':
            transformListHandler.rotate(theta);
            return;
        case ',':
            current = reader.read();
            skipSpaces();
        }
        
        float cx = parseFloat();
        skipCommaSpaces();
        float cy = parseFloat();
        
        skipSpaces();
        if (current != ')') {
            reportError("character.expected",
                        new Object[] { new Character(')'),
                                       new Integer(current) });
            skipTransform();
            return;
        }

        transformListHandler.rotate(theta, cx, cy);
    }

    /**
     * Parses a translate transform. 't' is assumed to be
     * the current character.
     * @return the current character.
     */
    protected void parseTranslate() throws ParseException, IOException {
	current = reader.read();

	// Parse 'ranslate wsp? ( wsp?'
	if (current != 'r') {
	    reportError("character.expected",
			new Object[] { new Character('r'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'a') {
	    reportError("character.expected",
			new Object[] { new Character('a'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'n') {
	    reportError("character.expected",
			new Object[] { new Character('n'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 's') {
	    reportError("character.expected",
			new Object[] { new Character('s'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'l') {
	    reportError("character.expected",
			new Object[] { new Character('l'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'a') {
	    reportError("character.expected",
			new Object[] { new Character('a'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 't') {
	    reportError("character.expected",
			new Object[] { new Character('t'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'e') {
	    reportError("character.expected",
			new Object[] { new Character('e'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();
	if (current != '(') {
	    reportError("character.expected",
			new Object[] { new Character('('),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();

        float tx = parseFloat();
        skipSpaces();

        switch (current) {
        case ')':
            transformListHandler.translate(tx);
            return;
        case ',':
            current = reader.read();
            skipSpaces();
        }

        float ty = parseFloat();

        skipSpaces();
        if (current != ')') {
            reportError("character.expected",
                        new Object[] { new Character(')'),
                                       new Integer(current) });
            skipTransform();
            return;
        }

        transformListHandler.translate(tx, ty);
    }

    /**
     * Parses a scale transform. 'c' is assumed to be the current character.
     * @return the current character.
     */
    protected void parseScale() throws ParseException, IOException {
	current = reader.read();

	// Parse 'ale wsp? ( wsp?'
	if (current != 'a') {
	    reportError("character.expected",
			new Object[] { new Character('a'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'l') {
	    reportError("character.expected",
			new Object[] { new Character('l'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'e') {
	    reportError("character.expected",
			new Object[] { new Character('e'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();
	if (current != '(') {
	    reportError("character.expected",
			new Object[] { new Character('('),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();

        float sx = parseFloat();
        skipSpaces();

        switch (current) {
        case ')':
            transformListHandler.scale(sx);
            return;
        case ',':
            current = reader.read();
            skipSpaces();
        }

        float sy = parseFloat();

        skipSpaces();
        if (current != ')') {
            reportError("character.expected",
                        new Object[] { new Character(')'),
                                       new Integer(current) });
            skipTransform();
            return;
        }
        
        transformListHandler.scale(sx, sy);
    }

    /**
     * Parses a skew transform. 'e' is assumed to be the current character.
     * @return the current character.
     */
    protected void parseSkew() throws ParseException, IOException {
	current = reader.read();

	// Parse 'ew[XY] wsp? ( wsp?'
	if (current != 'e') {
	    reportError("character.expected",
			new Object[] { new Character('e'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	if (current != 'w') {
	    reportError("character.expected",
			new Object[] { new Character('w'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();

	boolean skewX = false;
	switch (current) {
	case 'X':
	    skewX = true;
	case 'Y':
	    break;
	default:
	    reportError("character.expected",
			new Object[] { new Character('X'),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();
	if (current != '(') {
	    reportError("character.expected",
			new Object[] { new Character('('),
				       new Integer(current) });
	    skipTransform();
	    return;
	}
	current = reader.read();
	skipSpaces();

        float sk = parseFloat();

        skipSpaces();
        if (current != ')') {
            reportError("character.expected",
                        new Object[] { new Character(')'),
                                       new Integer(current) });
            skipTransform();
            return;
        }
        
        if (skewX) {
            transformListHandler.skewX(sk);
        } else {
            transformListHandler.skewY(sk);
        }
    }

    /**
     * Skips characters in the given reader until a ')' is encountered.
     * @return the first character after the ')'.
     */
    protected void skipTransform() throws IOException {
	loop: for (;;) {
	    current = reader.read();
	    switch (current) {
	    case ')':
		break loop;
	    default:
		if (current == -1) {
		    break loop;
		}
	    }
	}
    }
}
