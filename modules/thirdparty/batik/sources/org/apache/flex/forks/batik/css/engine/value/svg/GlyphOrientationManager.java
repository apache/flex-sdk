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
import org.apache.flex.forks.batik.css.engine.value.AbstractValueManager;
import org.apache.flex.forks.batik.css.engine.value.FloatValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class provides a manager for the 'glyph-orientation' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GlyphOrientationManager.java 475685 2006-11-16 11:16:05Z cam $
 */
public abstract class GlyphOrientationManager extends AbstractValueManager {
    
    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return true;
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
        return SVGTypes.TYPE_ANGLE;
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT:
            return SVGValueConstants.INHERIT_VALUE;

        case LexicalUnit.SAC_DEGREE:
            return new FloatValue(CSSPrimitiveValue.CSS_DEG,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_GRADIAN:
            return new FloatValue(CSSPrimitiveValue.CSS_GRAD,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_RADIAN:
            return new FloatValue(CSSPrimitiveValue.CSS_RAD,
                                  lu.getFloatValue());

            // For SVG angle properties unit defaults to 'deg'.
        case LexicalUnit.SAC_INTEGER:
            { 
                int n = lu.getIntegerValue();
                return new FloatValue(CSSPrimitiveValue.CSS_DEG, n);
            }
        case LexicalUnit.SAC_REAL:
            { 
                float n = lu.getFloatValue();
                return new FloatValue(CSSPrimitiveValue.CSS_DEG, n);
            }
        }
    
        throw createInvalidLexicalUnitDOMException(lu.getLexicalUnitType());
    }

    /**
     * Implements {@link ValueManager#createFloatValue(short,float)}.
     */
    public Value createFloatValue(short type, float floatValue)
        throws DOMException {
        switch (type) {
        case CSSPrimitiveValue.CSS_DEG:
        case CSSPrimitiveValue.CSS_GRAD:
        case CSSPrimitiveValue.CSS_RAD:
            return new FloatValue(type, floatValue);
        }
        throw createInvalidFloatValueDOMException(floatValue);
    }
}
