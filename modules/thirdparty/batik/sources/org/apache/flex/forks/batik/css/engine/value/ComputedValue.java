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

/**
 * This class represents a computed property value.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ComputedValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public class ComputedValue implements Value {

    /**
     * The cascaded value.
     */
    protected Value cascadedValue;

    /**
     * The computed value.
     */
    protected Value computedValue;
    
    /**
     * Creates a new ComputedValue object.
     * @param cv The cascaded value.
     */
    public ComputedValue(Value cv) {
        cascadedValue = cv;
    }

    /**
     * Returns the computed value.
     */
    public Value getComputedValue() {
        return computedValue;
    }

    /**
     * Returns the cascaded value.
     */
    public Value getCascadedValue() {
        return cascadedValue;
    }

    /**
     * Sets the computed value.
     */
    public void setComputedValue(Value v) {
        computedValue = v;
    }

    /**
     * Implements {@link Value#getCssText()}.
     */
    public String getCssText() {
        return computedValue.getCssText();
    }

    /**
     * Implements {@link Value#getCssValueType()}.
     */
    public short getCssValueType() {
        return computedValue.getCssValueType();
    }

    /**
     * Implements {@link Value#getPrimitiveType()}.
     */
    public short getPrimitiveType() {
        return computedValue.getPrimitiveType();
    }

    /**
     * Implements {@link Value#getFloatValue()}.
     */
    public float getFloatValue() throws DOMException {
        return computedValue.getFloatValue();
    }

    /**
     * Implements {@link Value#getStringValue()}.
     */
    public String getStringValue() throws DOMException {
        return computedValue.getStringValue();
    }

    /**
     * Implements {@link Value#getRed()}.
     */
    public Value getRed() throws DOMException {
        return computedValue.getRed();
    }

    /**
     * Implements {@link Value#getGreen()}.
     */
    public Value getGreen() throws DOMException {
        return computedValue.getGreen();
    }

    /**
     * Implements {@link Value#getBlue()}.
     */
    public Value getBlue() throws DOMException {
        return computedValue.getBlue();
    }

    /**
     * Implements {@link Value#getLength()}.
     */
    public int getLength() throws DOMException {
        return computedValue.getLength();
    }

    /**
     * Implements {@link Value#item(int)}.
     */
    public Value item(int index) throws DOMException {
        return computedValue.item(index);
    }

    /**
     * Implements {@link Value#getTop()}.
     */
    public Value getTop() throws DOMException {
        return computedValue.getTop();
    }

    /**
     * Implements {@link Value#getRight()}.
     */
    public Value getRight() throws DOMException {
        return computedValue.getRight();
    }

    /**
     * Implements {@link Value#getBottom()}.
     */
    public Value getBottom() throws DOMException {
        return computedValue.getBottom();
    }

    /**
     * Implements {@link Value#getLeft()}.
     */
    public Value getLeft() throws DOMException {
        return computedValue.getLeft();
    }

    /**
     * Implements {@link Value#getIdentifier()}.
     */
    public String getIdentifier() throws DOMException {
        return computedValue.getIdentifier();
    }

    /**
     * Implements {@link Value#getListStyle()}.
     */
    public String getListStyle() throws DOMException {
        return computedValue.getListStyle();
    }

    /**
     * Implements {@link Value#getSeparator()}.
     */
    public String getSeparator() throws DOMException {
        return computedValue.getSeparator();
    }
}
