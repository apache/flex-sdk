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

import org.apache.flex.forks.batik.css.engine.CSSContext;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;

/**
 * This class provides a manager for the property with support for
 * length values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: LengthManager.java 480490 2006-11-29 09:02:20Z dvholten $
 */
public abstract class LengthManager extends AbstractValueManager {

    /**
     * precomputed square-root of 2.0
     */
    static final double SQRT2 = Math.sqrt( 2.0 );

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_EM:
            return new FloatValue(CSSPrimitiveValue.CSS_EMS,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_EX:
            return new FloatValue(CSSPrimitiveValue.CSS_EXS,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_PIXEL:
            return new FloatValue(CSSPrimitiveValue.CSS_PX,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_CENTIMETER:
            return new FloatValue(CSSPrimitiveValue.CSS_CM,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_MILLIMETER:
            return new FloatValue(CSSPrimitiveValue.CSS_MM,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_INCH:
            return new FloatValue(CSSPrimitiveValue.CSS_IN,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_POINT:
            return new FloatValue(CSSPrimitiveValue.CSS_PT,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_PICA:
            return new FloatValue(CSSPrimitiveValue.CSS_PC,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_INTEGER:
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  lu.getIntegerValue());

        case LexicalUnit.SAC_REAL:
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  lu.getFloatValue());

        case LexicalUnit.SAC_PERCENTAGE:
            return new FloatValue(CSSPrimitiveValue.CSS_PERCENTAGE,
                                  lu.getFloatValue());
        }
        throw createInvalidLexicalUnitDOMException(lu.getLexicalUnitType());
    }

    /**
     * Implements {@link ValueManager#createFloatValue(short,float)}.
     */
    public Value createFloatValue(short type, float floatValue)
        throws DOMException {
        switch (type) {
        case CSSPrimitiveValue.CSS_PERCENTAGE:
        case CSSPrimitiveValue.CSS_EMS:
        case CSSPrimitiveValue.CSS_EXS:
        case CSSPrimitiveValue.CSS_PX:
        case CSSPrimitiveValue.CSS_CM:
        case CSSPrimitiveValue.CSS_MM:
        case CSSPrimitiveValue.CSS_IN:
        case CSSPrimitiveValue.CSS_PT:
        case CSSPrimitiveValue.CSS_PC:
        case CSSPrimitiveValue.CSS_NUMBER:
            return new FloatValue(type, floatValue);
        }
        throw createInvalidFloatTypeDOMException(type);
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
        if (value.getCssValueType() != CSSValue.CSS_PRIMITIVE_VALUE) {
            return value;
        }

        switch (value.getPrimitiveType()) {
        case CSSPrimitiveValue.CSS_NUMBER:
        case CSSPrimitiveValue.CSS_PX:
            return value;

        case CSSPrimitiveValue.CSS_MM:
            CSSContext ctx = engine.getCSSContext();
            float v = value.getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  v / ctx.getPixelUnitToMillimeter());

        case CSSPrimitiveValue.CSS_CM:
            ctx = engine.getCSSContext();
            v = value.getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  v * 10f / ctx.getPixelUnitToMillimeter());

        case CSSPrimitiveValue.CSS_IN:
            ctx = engine.getCSSContext();
            v = value.getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  v * 25.4f / ctx.getPixelUnitToMillimeter());

        case CSSPrimitiveValue.CSS_PT:
            ctx = engine.getCSSContext();
            v = value.getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  v * 25.4f /
                                  (72f * ctx.getPixelUnitToMillimeter()));

        case CSSPrimitiveValue.CSS_PC:
            ctx = engine.getCSSContext();
            v = value.getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER,
                                  (v * 25.4f /
                                   (6f * ctx.getPixelUnitToMillimeter())));

        case CSSPrimitiveValue.CSS_EMS:
            sm.putFontSizeRelative(idx, true);

            v = value.getFloatValue();
            int fsidx = engine.getFontSizeIndex();
            float fs;
            fs = engine.getComputedStyle(elt, pseudo, fsidx).getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER, v * fs);


        case CSSPrimitiveValue.CSS_EXS:
            sm.putFontSizeRelative(idx, true);

            v = value.getFloatValue();
            fsidx = engine.getFontSizeIndex();
            fs = engine.getComputedStyle(elt, pseudo, fsidx).getFloatValue();
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER, v * fs * 0.5f);

        case CSSPrimitiveValue.CSS_PERCENTAGE:
            ctx = engine.getCSSContext();
            switch (getOrientation()) {
            case HORIZONTAL_ORIENTATION:
                sm.putBlockWidthRelative(idx, true);
                fs = value.getFloatValue() * ctx.getBlockWidth(elt) / 100f;
                break;
            case VERTICAL_ORIENTATION:
                sm.putBlockHeightRelative(idx, true);
                fs = value.getFloatValue() * ctx.getBlockHeight(elt) / 100f;
                break;
            default: // Both
                sm.putBlockWidthRelative(idx, true);
                sm.putBlockHeightRelative(idx, true);
                double w = ctx.getBlockWidth(elt);
                double h = ctx.getBlockHeight(elt);
                fs = (float)(value.getFloatValue() *
                        (Math.sqrt(w * w + h * h) / SQRT2 ) / 100.0);
            }
            return new FloatValue(CSSPrimitiveValue.CSS_NUMBER, fs);
        }
        return value;
    }

    //
    // Orientation enumeration
    //
    protected static final int HORIZONTAL_ORIENTATION = 0;
    protected static final int VERTICAL_ORIENTATION = 1;
    protected static final int BOTH_ORIENTATION = 2;

    /**
     * Indicates the orientation of the property associated with
     * this manager.
     */
    protected abstract int getOrientation();
}
