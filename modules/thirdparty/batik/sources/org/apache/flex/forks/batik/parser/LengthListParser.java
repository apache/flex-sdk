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
 * This class implements an event-based parser for the SVG length
 * list values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LengthListParser.java,v 1.9 2004/08/18 07:14:47 vhardy Exp $
 */
public class LengthListParser extends LengthParser {

    /**
     * Creates a new LengthListParser.
     */
    public LengthListParser() {
	lengthHandler = DefaultLengthListHandler.INSTANCE;
    }

    /**
     * Allows an application to register a length list handler.
     *
     * <p>If the application does not register a handler, all
     * events reported by the parser will be silently ignored.
     *
     * <p>Applications may register a new or different handler in the
     * middle of a parse, and the parser must begin using the new
     * handler immediately.</p>
     * @param handler The transform list handler.
     */
    public void setLengthListHandler(LengthListHandler handler) {
	lengthHandler = handler;
    }

    /**
     * Returns the length list handler in use.
     */
    public LengthListHandler getLengthListHandler() {
	return (LengthListHandler)lengthHandler;
    }

    /**
     * Parses the given reader.
     */
    protected void doParse() throws ParseException, IOException {
	((LengthListHandler)lengthHandler).startLengthList();

	current = reader.read();
	skipSpaces();
	
	try {
	    for (;;) {
		lengthHandler.startLength();
		parseLength();
		lengthHandler.endLength();
		skipCommaSpaces();
		if (current == -1) {
		    break;
		}
	    }
	} catch (NumberFormatException e) {
        reportError("character.unexpected",
                    new Object[] { new Integer(current) });
	}
	((LengthListHandler)lengthHandler).endLengthList();
    }
}
