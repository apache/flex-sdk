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
 * This class represents a list of values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ListValue.java 476924 2006-11-19 21:13:26Z dvholten $
 */
public class ListValue extends AbstractValue {

    /**
     * The length of the list.
     */
    protected int length;

    /**
     * The items.
     */
    protected Value[] items = new Value[5];

    /**
     * The list separator.
     */
    protected char separator = ',';

    /**
     * Creates a ListValue.
     */
    public ListValue() {
    }

    /**
     * Creates a ListValue with the given separator.
     */
    public ListValue(char s) {
        separator = s;
    }

    /**
     * Returns the separator used for this list.
     */
    public char getSeparatorChar() {
        return separator;
    }

    /**
     * Implements {@link Value#getCssValueType()}.
     */
    public short getCssValueType() {
        return CSSValue.CSS_VALUE_LIST;
    }

    /**
     *  A string representation of the current value.
     */
    public String getCssText() {
        StringBuffer sb = new StringBuffer( length * 8 );
        if (length > 0) {
            sb.append(items[0].getCssText());
        }
        for (int i = 1; i < length; i++) {
            sb.append(separator);
            sb.append(items[i].getCssText());
        }
        return sb.toString();
    }

    /**
     * Implements {@link Value#getLength()}.
     */
    public int getLength() throws DOMException {
        return length;
    }

    /**
     * Implements {@link Value#item(int)}.
     */
    public Value item(int index) throws DOMException {
        return items[index];
    }

    /**
     * Returns a printable representation of this value.
     */
    public String toString() {
        return getCssText();
    }

    /**
     * Appends an item to the list.
     */
    public void append(Value v) {
        if (length == items.length) {
            Value[] t = new Value[length * 2];
            System.arraycopy( items, 0, t, 0, length );
            items = t;
        }
        items[length++] = v;
    }
}
