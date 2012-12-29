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
 * This interface represents a property value.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: Value.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface Value {
    
    /**
     *  A string representation of the current value. 
     */
    String getCssText();

    /**
     * A code defining the type of the value. 
     */
    short getCssValueType();

    /**
     * The type of the value.
     */
    short getPrimitiveType();

    /**
     *  This method is used to get the float value.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a float
     *    value. 
     */
    float getFloatValue() throws DOMException;

    /**
     *  This method is used to get the string value.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a string
     *    value. 
     */
    String getStringValue() throws DOMException;

    /**
     * The red value of the RGB color. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a RGB
     *    color value. 
     */
    Value getRed() throws DOMException;

    /**
     * The green value of the RGB color. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a RGB
     *    color value. 
     */
    Value getGreen() throws DOMException;

    /**
     * The blue value of the RGB color. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a RGB
     *    color value. 
     */
    Value getBlue() throws DOMException;

    /**
     * The number of <code>CSSValues</code> in the list. The range of valid 
     * values of the indices is <code>0</code> to <code>length-1</code> 
     * inclusive.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a list
     *    value. 
     */
    int getLength() throws DOMException;

    /**
     * Used to retrieve a rule by ordinal index.
     * @return The style rule at the <code>index</code> position in the 
     *   list, or <code>null</code> if that is not a valid index.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a list
     *    value. 
     */
    Value item(int index) throws DOMException;

    /**
     * The top value of the rect. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Rect
     *    value. 
     */
    Value getTop() throws DOMException;

    /**
     * The right value of the rect. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Rect
     *    value. 
     */
    Value getRight() throws DOMException;

    /**
     * The bottom value of the rect. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Rect
     *    value. 
     */
    Value getBottom() throws DOMException;

    /**
     * The left value of the rect. 
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Rect
     *    value. 
     */
    Value getLeft() throws DOMException;

    /**
     * The identifier value of the counter.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Counter
     *    value. 
     */
    String getIdentifier() throws DOMException;

    /**
     * The listStyle value of the counter.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Counter
     *    value. 
     */
    String getListStyle() throws DOMException;

    /**
     * The separator value of the counter.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a Counter
     *    value. 
     */
    String getSeparator() throws DOMException;
}
