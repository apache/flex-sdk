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
package org.apache.flex.forks.batik.dom.svg;

import org.w3c.dom.Element;

/**
 * Thrown when a live attribute cannot parse an attribute's value.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: LiveAttributeException.java 479349 2006-11-26 11:54:23Z cam $
 */
public class LiveAttributeException extends RuntimeException {

    // Constants for the error code.
    public static final short ERR_ATTRIBUTE_MISSING   = 0;
    public static final short ERR_ATTRIBUTE_MALFORMED = 1;
    public static final short ERR_ATTRIBUTE_NEGATIVE  = 2;

    /**
     * The element on which the error occured.
     */
    protected Element e;

    /**
     * The attribute name.
     */
    protected String attributeName;

    /**
     * The reason for the exception.  This must be one of the ERR_* constants
     * defined in this class.
     */
    protected short code;

    /**
     * The malformed attribute value.
     */
    protected String value;

    /**
     * Constructs a new <tt>LiveAttributeException</tt> with the specified
     * parameters.
     *
     * @param e the element on which the error occured
     * @param an the attribute name
     * @param code the error code
     * @param val the malformed attribute value
     */
    public LiveAttributeException(Element e, String an, short code,
                                  String val) {
        this.e = e;
        this.attributeName = an;
        this.code = code;
        this.value = val;
    }

    /**
     * Returns the element on which the error occurred.
     */
    public Element getElement() {
        return e;
    }

    /**
     * Returns the attribute name.
     */
    public String getAttributeName() {
        return attributeName;
    }

    /**
     * Returns the error code.
     */
    public short getCode() {
        return code;
    }

    /**
     * Returns the problematic attribute value.
     */
    public String getValue() {
        return value;
    }
}
