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
import org.apache.flex.forks.batik.css.engine.value.ListValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSValue;

/**
 * This class provides a manager for the SVGColor property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGColorManager.java 475685 2006-11-16 11:16:05Z cam $
 */
public class SVGColorManager extends ColorManager {

    /**
     * The name of the handled property.
     */
    protected String property;

    /**
     * The default value.
     */
    protected Value defaultValue;

    /**
     * Creates a new SVGColorManager.
     * The default value is black.
     */
    public SVGColorManager(String prop) {
        this(prop, SVGValueConstants.BLACK_RGB_VALUE);
    }

    /**
     * Creates a new SVGColorManager.
     */
    public SVGColorManager(String prop, Value v) {
        property = prop;
        defaultValue = v;
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
        return true;
    }

    /**
     * Implements {@link ValueManager#getPropertyType()}.
     */
    public int getPropertyType() {
        return SVGTypes.TYPE_COLOR;
    }

    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return property;
    }

    
    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return defaultValue;
    }
    
    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        if (lu.getLexicalUnitType() == LexicalUnit.SAC_IDENT) {
            if (lu.getStringValue().equalsIgnoreCase
                (CSSConstants.CSS_CURRENTCOLOR_VALUE)) {
                return SVGValueConstants.CURRENTCOLOR_VALUE;
            }
        }
        Value v = super.createValue(lu, engine);
        lu = lu.getNextLexicalUnit();
        if (lu == null) {
            return v;
        }
        if (lu.getLexicalUnitType() != LexicalUnit.SAC_FUNCTION ||
            !lu.getFunctionName().equalsIgnoreCase("icc-color")) {
            throw createInvalidLexicalUnitDOMException
                (lu.getLexicalUnitType());
        }
        lu = lu.getParameters();
        if (lu.getLexicalUnitType() != LexicalUnit.SAC_IDENT) {
            throw createInvalidLexicalUnitDOMException
                (lu.getLexicalUnitType());
        }
        ListValue result = new ListValue(' ');
        result.append(v);

        ICCColor icc = new ICCColor(lu.getStringValue());
        result.append(icc);

        lu = lu.getNextLexicalUnit();
        while (lu != null) {
            if (lu.getLexicalUnitType() != LexicalUnit.SAC_OPERATOR_COMMA) {
                throw createInvalidLexicalUnitDOMException
                    (lu.getLexicalUnitType());
            }
            lu = lu.getNextLexicalUnit();
            if (lu == null) {
                throw createInvalidLexicalUnitDOMException((short)-1);
            }
            icc.append(getColorValue(lu));
            lu = lu.getNextLexicalUnit();
        }
        return result;
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
        if (value == SVGValueConstants.CURRENTCOLOR_VALUE) {
            sm.putColorRelative(idx, true);

            int ci = engine.getColorIndex();
            return engine.getComputedStyle(elt, pseudo, ci);
        }
        if (value.getCssValueType() == CSSValue.CSS_VALUE_LIST) {
            ListValue lv = (ListValue)value;
            Value v = lv.item(0);
            Value t = super.computeValue(elt, pseudo, engine, idx, sm, v);
            if (t != v) {
                ListValue result = new ListValue(' ');
                result.append(t);
                result.append(lv.item(1));
                return result;
            }
            return value;
        }
        return super.computeValue(elt, pseudo, engine, idx, sm, value);
    }

    /**
     * Creates a float value usable as a component of an RGBColor.
     */
    protected float getColorValue(LexicalUnit lu) {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INTEGER:
            return lu.getIntegerValue();
        case LexicalUnit.SAC_REAL:
            return lu.getFloatValue();
        }
        throw createInvalidLexicalUnitDOMException(lu.getLexicalUnitType());
    }
}
