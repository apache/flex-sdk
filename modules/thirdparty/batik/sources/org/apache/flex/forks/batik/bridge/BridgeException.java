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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;
import org.w3c.flex.forks.dom.svg.SVGDocument;

/**
 * Thrown when the bridge has detected an error.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: BridgeException.java,v 1.8 2004/08/18 07:12:30 vhardy Exp $
 */
public class BridgeException extends RuntimeException {

    /** The element on which the error occured. */
    protected Element e;

    /** The error code. */
    protected String code;

    /** The paramters to use for the error message. */
    protected Object [] params;

    /** The line number on which the error occured. */
    protected int line;

    /** The graphics node that represents the current state of the GVT tree. */
    protected GraphicsNode node;

    /**
     * Constructs a new <tt>BridgeException</tt> with the specified parameters.
     *
     * @param e the element on which the error occured
     * @param code the error code
     * @param params the parameters to use for the error message
     */
    public BridgeException(Element e, String code, Object [] params) {
        this.e = e;
        this.code = code;
        this.params = params;
    }

    /**
     * Returns the element on which the error occurred.
     */
    public Element getElement() {
        return e;
    }

    /**
     * Returns the line number on which the error occurred.
     */
    public void setLineNumber(int line) {
        this.line = line;
    }

    /**
     * Sets the graphics node that represents the current GVT tree built.
     *
     * @param node the graphics node
     */
    public void setGraphicsNode(GraphicsNode node) {
        this.node = node;
    }

    /**
     * Returns the graphics node that represents the current GVT tree built.
     */
    public GraphicsNode getGraphicsNode() {
        return node;
    }

    /**
     * Returns the error message according to the error code and parameters.
     */
    public String getMessage() {
        String uri;
        String lname = "<Unknown Element>";
        SVGDocument doc = null;
        if (e != null) {
            doc = (SVGDocument)e.getOwnerDocument();
            lname = e.getLocalName();
        }
        if (doc == null)  uri = "<Unknown Document>";
        else              uri = doc.getURL();
        Object [] fullparams = new Object[params.length+3];
        fullparams[0] = uri;
        fullparams[1] = new Integer(line);
        fullparams[2] = lname;
        for (int i=0; i < params.length; ++i) {
            fullparams[i+3] = params[i];
        }
        return Messages.formatMessage(code, fullparams);
    }

    /**
     * Returns the exception's error code
     */
    public String getCode() {
        return code;
    }
}
