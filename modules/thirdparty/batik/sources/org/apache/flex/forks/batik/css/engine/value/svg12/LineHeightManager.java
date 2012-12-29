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

package org.apache.flex.forks.batik.css.engine.value.svg12;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.LengthManager;
import org.apache.flex.forks.batik.css.engine.value.FloatValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.SVG12CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.DOMException;

/**
 * This class provides a factory for the 'margin-*' properties values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LineHeightManager.java 502538 2007-02-02 08:52:56Z dvholten $
 */
public class LineHeightManager extends LengthManager {

    public LineHeightManager() { }

    /**
     * Implements {@link ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return true;
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
        return SVGTypes.TYPE_LINE_HEIGHT_VALUE;
    }

    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return SVG12CSSConstants.CSS_LINE_HEIGHT_PROPERTY;
    }

    /**
     * Implements {@link ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVG12ValueConstants.NORMAL_VALUE;
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {

        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT:
            return SVG12ValueConstants.INHERIT_VALUE;
        case LexicalUnit.SAC_IDENT: {
            String s = lu.getStringValue().toLowerCase();
            if (SVG12CSSConstants.CSS_NORMAL_VALUE.equals(s))
                return SVG12ValueConstants.NORMAL_VALUE;
            throw createInvalidIdentifierDOMException(lu.getStringValue());
        }
        default:
            return super.createValue(lu, engine);
        }
    }


    /**
     * Indicates the orientation of the property associated with
     * this manager.
     */
    protected int getOrientation() {
        // Not really used.
        return VERTICAL_ORIENTATION;
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
        if (value.getCssValueType() != CSSValue.CSS_PRIMITIVE_VALUE)
            return value;

        switch (value.getPrimitiveType()) {
        case CSSPrimitiveValue.CSS_NUMBER:
            return new LineHeightValue(CSSPrimitiveValue.CSS_NUMBER,
                                       value.getFloatValue(), true);

        case CSSPrimitiveValue.CSS_PERCENTAGE: {
            float v     = value.getFloatValue();
            int   fsidx = engine.getFontSizeIndex();
            float fs    = engine.getComputedStyle
                (elt, pseudo, fsidx).getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER, v * fs * 0.01f);
        }

        default:
            return super.computeValue(elt, pseudo, engine, idx, sm, value);
        }
    }
}

























