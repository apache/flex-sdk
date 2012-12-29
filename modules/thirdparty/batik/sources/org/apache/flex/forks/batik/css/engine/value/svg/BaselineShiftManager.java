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
package org.apache.flex.forks.batik.css.engine.value.svg;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.FloatValue;
import org.apache.flex.forks.batik.css.engine.value.LengthManager;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class provides a manager for the 'baseline-shift' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: BaselineShiftManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class BaselineShiftManager extends LengthManager {

    /**
     * The identifier values.
     */
    protected static final StringMap values = new StringMap();
    static {
        values.put(CSSConstants.CSS_BASELINE_VALUE,
                   SVGValueConstants.BASELINE_VALUE);
        values.put(CSSConstants.CSS_SUB_VALUE,
                   SVGValueConstants.SUB_VALUE);
        values.put(CSSConstants.CSS_SUPER_VALUE,
                   SVGValueConstants.SUPER_VALUE);
    }

    /**
     * Implements {@link ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return false;
    }

    /**
     * Implements {@link ValueManager#isAnimatableProperty()}.
     */
    public boolean isAnimatableProperty() {
        return true;
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
        return SVGTypes.TYPE_BASELINE_SHIFT_VALUE;
    }

    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return CSSConstants.CSS_BASELINE_SHIFT_PROPERTY;
    }

    /**
     * Implements {@link ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.BASELINE_VALUE;
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT:
            return SVGValueConstants.INHERIT_VALUE;

        case LexicalUnit.SAC_IDENT:
            Object v = values.get(lu.getStringValue().toLowerCase().intern());
            if (v == null) {
                throw createInvalidIdentifierDOMException(lu.getStringValue());
            }
            return (Value)v;
        }
        return super.createValue(lu, engine);
    }

    /**
     * Implements {@link ValueManager#createStringValue(short,String,CSSEngine)}.
     */
    public Value createStringValue(short type, String value, CSSEngine engine)
        throws DOMException {
        if (type != CSSPrimitiveValue.CSS_IDENT) {
            throw createInvalidIdentifierDOMException(value);
        }
        Object v = values.get(value.toLowerCase().intern());
        if (v == null) {
            throw createInvalidIdentifierDOMException(value);
        }
        return (Value)v;
    }

    /**
     * Implements {@link
     * ValueManager#computeValue(CSSStylableElement,String,CSSEngine,int,StyleMap,Value)}.
     */
    public Value computeValue(CSSStylableElement elt,
                              String pseudo,
                              CSSEngine engine,
                              int idx,
                              StyleMap sm,
                              Value value) {
        if (value.getPrimitiveType() == CSSPrimitiveValue.CSS_PERCENTAGE) {
            sm.putLineHeightRelative(idx, true);

            int fsi = engine.getLineHeightIndex();
            CSSStylableElement parent;
            parent = (CSSStylableElement)elt.getParentNode();
            if (parent == null) {
                // Hmmm somthing pretty odd - can't happen accordint to spec,
                // should always have text parent.
                // http://www.w3.org/TR/SVG11/text.html#BaselineShiftProperty
                parent = elt;
            }
            Value fs = engine.getComputedStyle(parent, pseudo, fsi);
            float fsv = fs.getFloatValue();
            float v = value.getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  (fsv * v) / 100f);
        }
        return super.computeValue(elt, pseudo, engine, idx, sm, value);
    }


    /**
     * Indicates the orientation of the property associated with
     * this manager.
     */
    protected int getOrientation() {
        return BOTH_ORIENTATION; // Not used
    }

}
