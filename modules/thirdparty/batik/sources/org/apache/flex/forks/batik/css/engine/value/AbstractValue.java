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
package org.apache.flex.forks.batik.css.engine.value;

import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSValue;

/**
 * This class provides an abstract implementation of the Value interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AbstractValue implements Value {
    
    /**
     * Implements {@link Value#getCssValueType()}.
     */
    public short getCssValueType() {
        return CSSValue.CSS_PRIMITIVE_VALUE;
    }

    /**
     * Implements {@link Value#getPrimitiveType()}.
     */
    public short getPrimitiveType() {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getFloatValue()}.
     */
    public float getFloatValue() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getStringValue()}.
     */
    public String getStringValue() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getRed()}.
     */
    public Value getRed() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getGreen()}.
     */
    public Value getGreen() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getBlue()}.
     */
    public Value getBlue() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getLength()}.
     */
    public int getLength() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#item(int)}.
     */
    public Value item(int index) throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getTop()}.
     */
    public Value getTop() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getRight()}.
     */
    public Value getRight() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getBottom()}.
     */
    public Value getBottom() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getLeft()}.
     */
    public Value getLeft() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getIdentifier()}.
     */
    public String getIdentifier() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getListStyle()}.
     */
    public String getListStyle() throws DOMException {
        throw createDOMException();
    }

    /**
     * Implements {@link Value#getSeparator()}.
     */
    public String getSeparator() throws DOMException {
        throw createDOMException();
    }

    /**
     * Creates an INVALID_ACCESS_ERR exception.
     */
    protected DOMException createDOMException() {
        Object[] p = new Object[] { new Integer(getCssValueType()) };
        String s = Messages.formatMessage("invalid.value.access", p);
        return new DOMException(DOMException.INVALID_ACCESS_ERR, s);
    }
}
