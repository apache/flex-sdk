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
package org.apache.flex.forks.batik.css.engine.value.css2;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.value.IdentifierManager;
import org.apache.flex.forks.batik.css.engine.value.ListValue;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.engine.value.StringValue;
import org.apache.flex.forks.batik.css.engine.value.URIValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueConstants;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.DOMException;
import org.w3c.css.sac.LexicalUnit;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: SrcManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class SrcManager extends IdentifierManager {

    /**
     * The identifier values.
     */
    protected static final StringMap values = new StringMap();
    static {
        values.put(CSSConstants.CSS_NONE_VALUE,
                   ValueConstants.NONE_VALUE);
    }

    public SrcManager() {
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return false;
    }

    /**
     * Implements {@link ValueManager#isAnimatableProperty()}.
     */
    public boolean isAnimatableProperty() {
        return false;
    }

    /**
     * Implements {@link ValueManager#isAdditiveProperty()}.
     */
    public boolean isAdditiveProperty() {
        return false;
    }

    /**
     * Implements {@link ValueManager#getPropertyType()}.
     */
    public int getPropertyType() {
        return SVGTypes.TYPE_FONT_DESCRIPTOR_SRC_VALUE;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return CSSConstants.CSS_SRC_PROPERTY;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return ValueConstants.NONE_VALUE;
    }


    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {

        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT:
            return ValueConstants.INHERIT_VALUE;

        default:
            throw createInvalidLexicalUnitDOMException
                (lu.getLexicalUnitType());

        case LexicalUnit.SAC_IDENT:
        case LexicalUnit.SAC_STRING_VALUE:
        case LexicalUnit.SAC_URI:
        }

        ListValue result = new ListValue();
        for (;;) {
            switch (lu.getLexicalUnitType()) {
            case LexicalUnit.SAC_STRING_VALUE:
                result.append(new StringValue(CSSPrimitiveValue.CSS_STRING,
                                              lu.getStringValue()));
                lu = lu.getNextLexicalUnit();
                break;

            case LexicalUnit.SAC_URI:
                String uri = resolveURI(engine.getCSSBaseURI(),
                                        lu.getStringValue());

                result.append(new URIValue(lu.getStringValue(), uri));
                lu = lu.getNextLexicalUnit();
                if ((lu != null) &&
                    (lu.getLexicalUnitType() == LexicalUnit.SAC_FUNCTION)) {
                    if (!lu.getFunctionName().equalsIgnoreCase("format")) {
                        break;
                    }
                    // Format really does us no good so just ignore it.

                    // TODO: Should probably turn this into a ListValue
                    // and append the format function CSS Value.
                    lu = lu.getNextLexicalUnit();
                }
                break;

            case LexicalUnit.SAC_IDENT:
                StringBuffer sb = new StringBuffer(lu.getStringValue());
                lu = lu.getNextLexicalUnit();
                if (lu != null &&
                    lu.getLexicalUnitType() == LexicalUnit.SAC_IDENT) {
                    do {
                        sb.append(' ');
                        sb.append(lu.getStringValue());
                        lu = lu.getNextLexicalUnit();
                    } while (lu != null &&
                             lu.getLexicalUnitType() == LexicalUnit.SAC_IDENT);
                    result.append(new StringValue(CSSPrimitiveValue.CSS_STRING,
                                                  sb.toString()));
                } else {
                    String id = sb.toString();
                    String s = id.toLowerCase().intern();
                    Value v = (Value)values.get(s);
                    result.append((v != null)
                                  ? v
                                  : new StringValue
                                        (CSSPrimitiveValue.CSS_STRING, id));
                }
                break;
            }
            if (lu == null) {
                return result;
            }
            if (lu.getLexicalUnitType() != LexicalUnit.SAC_OPERATOR_COMMA) {
                throw createInvalidLexicalUnitDOMException
                    (lu.getLexicalUnitType());
            }
            lu = lu.getNextLexicalUnit();
            if (lu == null) {
                throw createMalformedLexicalUnitDOMException();
            }
        }
    }

    /**
     * Implements {@link IdentifierManager#getIdentifiers()}.
     */
    public StringMap getIdentifiers() {
        return values;
    }
}
