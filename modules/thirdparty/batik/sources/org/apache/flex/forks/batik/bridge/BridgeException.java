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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.dom.svg.LiveAttributeException;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

import org.w3c.dom.Element;
import org.w3c.dom.svg.SVGDocument;

/**
 * Thrown when the bridge has detected an error.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: BridgeException.java 501922 2007-01-31 17:47:47Z dvholten $
 */
public class BridgeException extends RuntimeException {

    /** The element on which the error occured. */
    protected Element e;

    /** The error code. */
    protected String code;

    /**
     * The message.
     */
    protected String message;

    /** The paramters to use for the error message. */
    protected Object [] params;

    /** The line number on which the error occured. */
    protected int line;

    /** The graphics node that represents the current state of the GVT tree. */
    protected GraphicsNode node;

    /**
     * Constructs a new <tt>BridgeException</tt> based on the specified
     * <tt>LiveAttributeException</tt>.
     *
     * @param ctx the bridge context to use for determining the element's
     *            source position
     * @param ex the {@link LiveAttributeException}
     */
    public BridgeException(BridgeContext ctx, LiveAttributeException ex) {
        switch (ex.getCode()) {
            case LiveAttributeException.ERR_ATTRIBUTE_MISSING:
                this.code = ErrorConstants.ERR_ATTRIBUTE_MISSING;
                break;
            case LiveAttributeException.ERR_ATTRIBUTE_MALFORMED:
                this.code = ErrorConstants.ERR_ATTRIBUTE_VALUE_MALFORMED;
                break;
            case LiveAttributeException.ERR_ATTRIBUTE_NEGATIVE:
                this.code = ErrorConstants.ERR_LENGTH_NEGATIVE;
                break;
            default:
                throw new IllegalStateException
                    ("Unknown LiveAttributeException error code "
                     + ex.getCode());
        }
        this.e = ex.getElement();
        this.params = new Object[] { ex.getAttributeName(), ex.getValue() };
        if (e != null && ctx != null) {
            this.line = ctx.getDocumentLoader().getLineNumber(e);
        }
    }

     /**
     * Constructs a new <tt>BridgeException</tt> with the specified parameters.
     *
     * @param ctx the bridge context to use for determining the element's
     *            source position
     * @param e the element on which the error occurred
     * @param code the error code
     * @param params the parameters to use for the error message
     */
    public BridgeException(BridgeContext ctx, Element e, String code,
                           Object[] params) {

        this.e = e;
        this.code = code;
        this.params = params;
        if (e != null && ctx != null) {
            this.line = ctx.getDocumentLoader().getLineNumber(e);
        }
    }

    /**
     * Constructs a new <tt>BridgeException</tt> with the specified parameters.
     *
     * @param ctx the bridge context to use for determining the element's
     *            source position
     * @param e the element on which the error occurred
     * @param ex the exception which was the root-cause for this exception
     * @param code the error code
     * @param params the parameters to use for the error message
     */
    public BridgeException(BridgeContext ctx, Element e, Exception ex, String code,
                           Object[] params) {

        // todo ex can be chained in jdk >= 1.4
        this.e = e;

        message = ex.getMessage();
        this.code = code;
        this.params = params;
        if (e != null && ctx != null) {
            this.line = ctx.getDocumentLoader().getLineNumber(e);
        }
    }

    /**
     * Constructs a new <tt>BridgeException</tt> with the specified parameters.
     *
     * @param ctx the bridge context to use for determining the element's
     *            source position
     * @param e the element on which the error occurred
     * @param message the error message
     */
    public BridgeException(BridgeContext ctx, Element e, String message) {
        this.e = e;
        this.message = message;
        if (e != null && ctx != null) {
            this.line = ctx.getDocumentLoader().getLineNumber(e);
        }
    }

    /**
     * Returns the element on which the error occurred.
     */
    public Element getElement() {
        return e;
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
        if (message != null) {
            return message;
        }

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
        System.arraycopy( params, 0, fullparams, 3, params.length );
        return Messages.formatMessage(code, fullparams);
    }

    /**
     * Returns the exception's error code
     */
    public String getCode() {
        return code;
    }
}
