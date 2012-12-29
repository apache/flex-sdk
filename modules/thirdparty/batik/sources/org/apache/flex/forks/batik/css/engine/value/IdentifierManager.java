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

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class provides a manager for the property with support for
 * identifier values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: IdentifierManager.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class IdentifierManager extends AbstractValueManager {

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT:
            return ValueConstants.INHERIT_VALUE;

        case LexicalUnit.SAC_IDENT:
            String s = lu.getStringValue().toLowerCase().intern();
            Object v = getIdentifiers().get(s);
            if (v == null) {
                throw createInvalidIdentifierDOMException(lu.getStringValue());
            }
            return (Value)v;

        default:
            throw createInvalidLexicalUnitDOMException
                (lu.getLexicalUnitType());
        }
    }

    /**
     * Implements {@link
     * ValueManager#createStringValue(short,String,CSSEngine)}.
     */
    public Value createStringValue(short type, String value, CSSEngine engine)
        throws DOMException {
        if (type != CSSPrimitiveValue.CSS_IDENT) {
            throw createInvalidStringTypeDOMException(type);
        }
        Object v = getIdentifiers().get(value.toLowerCase().intern());
        if (v == null) {
            throw createInvalidIdentifierDOMException(value);
        }
        return (Value)v;
    }

    /**
     * Returns the map that contains the name/value mappings for each
     * possible identifiers.
     */
    public abstract StringMap getIdentifiers();
}
