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
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class represents string values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StringValue.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class StringValue extends AbstractValue {

    /**
     * Returns the CSS text associated with the given type/value pair.
     */
    public static String getCssText(short type, String value) {
        switch (type) {
        case CSSPrimitiveValue.CSS_URI:
            return "url(" + value + ')';

        case CSSPrimitiveValue.CSS_STRING:
            char q = (value.indexOf('"') != -1) ? '\'' : '"';
            return q + value + q;
        }
        return value;
    }

    /**
     * The value of the string
     */
    protected String value;

    /**
     * The unit type
     */
    protected short unitType;

    /**
     * Creates a new StringValue.
     */
    public StringValue(short type, String s) {
        unitType = type;
        value = s;
    }

    /**
     * The type of the value.
     */
    public short getPrimitiveType() {
        return unitType;
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     * @param obj the reference object with which to compare.
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof StringValue)) {
            return false;
        }
        StringValue v = (StringValue)obj;
        if (unitType != v.unitType) {
            return false;
        }
        return value.equals(v.value);
    }

    /**
     * A string representation of the current value.
     */
    public String getCssText() {
        return getCssText(unitType, value);
    }

    /**
     *  This method is used to get the string value.
     * @exception DOMException
     *    INVALID_ACCESS_ERR: Raised if the value doesn't contain a string
     *    value.
     */
    public String getStringValue() throws DOMException {
        return value;
    }

    /**
     * Returns a printable representation of this value.
     */
    public String toString() {
        return getCssText();
    }
}
