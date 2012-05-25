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
 * This class implements an event-based parser for the SVG angle
 * values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AngleParser.java,v 1.8 2004/08/18 07:14:46 vhardy Exp $
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
			reportError("character.expected",
				    new Object[] { new Character('e'),
						   new Integer(current) });
			break;
		    }
		    current = reader.read();
		    if (current != 'g') {
			reportError("character.expected",
				    new Object[] { new Character('g'),
						   new Integer(current) });
			break;
		    }
		    angleHandler.deg();
		    current = reader.read();
		    break;
		case 'g':
		    current = reader.read();
		    if (current != 'r') {
			reportError("character.expected",
				    new Object[] { new Character('r'),
						   new Integer(current) });
			break;
		    }
		    current = reader.read();
		    if (current != 'a') {
			reportError("character.expected",
				    new Object[] { new Character('a'),
						   new Integer(current) });
			break;
		    }
		    current = reader.read();
		    if (current != 'd') {
			reportError("character.expected",
				    new Object[] { new Character('d'),
						   new Integer(current) });
			break;
		    }
		    angleHandler.grad();
		    current = reader.read();
		    break;
		case 'r':
		    current = reader.read();
		    if (current != 'a') {
			reportError("character.expected",
				    new Object[] { new Character('a'),
						   new Integer(current) });
			break;
		    }
		    current = reader.read();
		    if (current != 'd') {
			reportError("character.expected",
				    new Object[] { new Character('d'),
						   new Integer(current) });
			break;
		    }
		    angleHandler.rad();
		    current = reader.read();
		    break;
		default:
		    reportError("character.unexpected",
				new Object[] { new Integer(current) });
		}
	    }

	    skipSpaces();
	    if (current != -1) {
		reportError("end.of.stream.expected",
			    new Object[] { new Integer(current) });
	    }
	} catch (NumberFormatException e) {
            reportError("character.unexpected",
                        new Object[] { new Integer(current) });
	}
	angleHandler.endAngle();
    }
}
