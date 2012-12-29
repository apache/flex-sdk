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
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class provides a manager for the property with support for
 * CSS color values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractColorManager.java 489226 2006-12-21 00:05:36Z cam $
 */
public abstract class AbstractColorManager extends IdentifierManager {

    /**
     * The identifier values.
     */
    protected static final StringMap values = new StringMap();
    static {
        values.put(CSSConstants.CSS_AQUA_VALUE,
                   ValueConstants.AQUA_VALUE);
        values.put(CSSConstants.CSS_BLACK_VALUE,
                   ValueConstants.BLACK_VALUE);
        values.put(CSSConstants.CSS_BLUE_VALUE,
                   ValueConstants.BLUE_VALUE);
        values.put(CSSConstants.CSS_FUCHSIA_VALUE,
                   ValueConstants.FUCHSIA_VALUE);
        values.put(CSSConstants.CSS_GRAY_VALUE,
                   ValueConstants.GRAY_VALUE);
        values.put(CSSConstants.CSS_GREEN_VALUE,
                   ValueConstants.GREEN_VALUE);
        values.put(CSSConstants.CSS_LIME_VALUE,
                   ValueConstants.LIME_VALUE);
        values.put(CSSConstants.CSS_MAROON_VALUE,
                   ValueConstants.MAROON_VALUE);
        values.put(CSSConstants.CSS_NAVY_VALUE,
                   ValueConstants.NAVY_VALUE);
        values.put(CSSConstants.CSS_OLIVE_VALUE,
                   ValueConstants.OLIVE_VALUE);
        values.put(CSSConstants.CSS_PURPLE_VALUE,
                   ValueConstants.PURPLE_VALUE);
        values.put(CSSConstants.CSS_RED_VALUE,
                   ValueConstants.RED_VALUE);
        values.put(CSSConstants.CSS_SILVER_VALUE,
                   ValueConstants.SILVER_VALUE);
        values.put(CSSConstants.CSS_TEAL_VALUE,
                   ValueConstants.TEAL_VALUE);
        values.put(CSSConstants.CSS_WHITE_VALUE,
                   ValueConstants.WHITE_VALUE);
        values.put(CSSConstants.CSS_YELLOW_VALUE,
                   ValueConstants.YELLOW_VALUE);

        values.put(CSSConstants.CSS_ACTIVEBORDER_VALUE,
                   ValueConstants.ACTIVEBORDER_VALUE);
        values.put(CSSConstants.CSS_ACTIVECAPTION_VALUE,
                   ValueConstants.ACTIVECAPTION_VALUE);
        values.put(CSSConstants.CSS_APPWORKSPACE_VALUE,
                   ValueConstants.APPWORKSPACE_VALUE);
        values.put(CSSConstants.CSS_BACKGROUND_VALUE,
                   ValueConstants.BACKGROUND_VALUE);
        values.put(CSSConstants.CSS_BUTTONFACE_VALUE,
                   ValueConstants.BUTTONFACE_VALUE);
        values.put(CSSConstants.CSS_BUTTONHIGHLIGHT_VALUE,
                   ValueConstants.BUTTONHIGHLIGHT_VALUE);
        values.put(CSSConstants.CSS_BUTTONSHADOW_VALUE,
                   ValueConstants.BUTTONSHADOW_VALUE);
        values.put(CSSConstants.CSS_BUTTONTEXT_VALUE,
                   ValueConstants.BUTTONTEXT_VALUE);
        values.put(CSSConstants.CSS_CAPTIONTEXT_VALUE,
                   ValueConstants.CAPTIONTEXT_VALUE);
        values.put(CSSConstants.CSS_GRAYTEXT_VALUE,
                   ValueConstants.GRAYTEXT_VALUE);
        values.put(CSSConstants.CSS_HIGHLIGHT_VALUE,
                   ValueConstants.HIGHLIGHT_VALUE);
        values.put(CSSConstants.CSS_HIGHLIGHTTEXT_VALUE,
                   ValueConstants.HIGHLIGHTTEXT_VALUE);
        values.put(CSSConstants.CSS_INACTIVEBORDER_VALUE,
                   ValueConstants.INACTIVEBORDER_VALUE);
        values.put(CSSConstants.CSS_INACTIVECAPTION_VALUE,
                   ValueConstants.INACTIVECAPTION_VALUE);
        values.put(CSSConstants.CSS_INACTIVECAPTIONTEXT_VALUE,
                   ValueConstants.INACTIVECAPTIONTEXT_VALUE);
        values.put(CSSConstants.CSS_INFOBACKGROUND_VALUE,
                   ValueConstants.INFOBACKGROUND_VALUE);
        values.put(CSSConstants.CSS_INFOTEXT_VALUE,
                   ValueConstants.INFOTEXT_VALUE);
        values.put(CSSConstants.CSS_MENU_VALUE,
                   ValueConstants.MENU_VALUE);
        values.put(CSSConstants.CSS_MENUTEXT_VALUE,
                   ValueConstants.MENUTEXT_VALUE);
        values.put(CSSConstants.CSS_SCROLLBAR_VALUE,
                   ValueConstants.SCROLLBAR_VALUE);
        values.put(CSSConstants.CSS_THREEDDARKSHADOW_VALUE,
                   ValueConstants.THREEDDARKSHADOW_VALUE);
        values.put(CSSConstants.CSS_THREEDFACE_VALUE,
                   ValueConstants.THREEDFACE_VALUE);
        values.put(CSSConstants.CSS_THREEDHIGHLIGHT_VALUE,
                   ValueConstants.THREEDHIGHLIGHT_VALUE);
        values.put(CSSConstants.CSS_THREEDLIGHTSHADOW_VALUE,
                   ValueConstants.THREEDLIGHTSHADOW_VALUE);
        values.put(CSSConstants.CSS_THREEDSHADOW_VALUE,
                   ValueConstants.THREEDSHADOW_VALUE);
        values.put(CSSConstants.CSS_WINDOW_VALUE,
                   ValueConstants.WINDOW_VALUE);
        values.put(CSSConstants.CSS_WINDOWFRAME_VALUE,
                   ValueConstants.WINDOWFRAME_VALUE);
        values.put(CSSConstants.CSS_WINDOWTEXT_VALUE,
                   ValueConstants.WINDOWTEXT_VALUE);
    }

    /**
     * The computed identifier values.
     */
    protected static final StringMap computedValues = new StringMap();
    static {
        computedValues.put(CSSConstants.CSS_BLACK_VALUE,
                           ValueConstants.BLACK_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_SILVER_VALUE,
                           ValueConstants.SILVER_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GRAY_VALUE,
                           ValueConstants.GRAY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_WHITE_VALUE,
                           ValueConstants.WHITE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_MAROON_VALUE,
                           ValueConstants.MAROON_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_RED_VALUE,
                           ValueConstants.RED_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_PURPLE_VALUE,
                           ValueConstants.PURPLE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_FUCHSIA_VALUE,
                           ValueConstants.FUCHSIA_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_GREEN_VALUE,
                           ValueConstants.GREEN_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_LIME_VALUE,
                           ValueConstants.LIME_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_OLIVE_VALUE,
                           ValueConstants.OLIVE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_YELLOW_VALUE,
                           ValueConstants.YELLOW_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_NAVY_VALUE,
                           ValueConstants.NAVY_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_BLUE_VALUE,
                           ValueConstants.BLUE_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_TEAL_VALUE,
                           ValueConstants.TEAL_RGB_VALUE);
        computedValues.put(CSSConstants.CSS_AQUA_VALUE,
                           ValueConstants.AQUA_RGB_VALUE);
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        if (lu.getLexicalUnitType() == LexicalUnit.SAC_RGBCOLOR) {
            lu = lu.getParameters();
            Value red = createColorComponent(lu);
            lu = lu.getNextLexicalUnit().getNextLexicalUnit();
            Value green = createColorComponent(lu);
            lu = lu.getNextLexicalUnit().getNextLexicalUnit();
            Value blue = createColorComponent(lu);
            return createRGBColor(red, green, blue);
        }
        return super.createValue(lu, engine);
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
        if (value.getPrimitiveType() == CSSPrimitiveValue.CSS_IDENT) {
            String ident = value.getStringValue();
            // Search for a direct computed value.
            Value v = (Value)computedValues.get(ident);
            if (v != null) {
                return v;
            }
            // Must be a system color...
            if (values.get(ident) == null) {
                throw new IllegalStateException("Not a system-color:" + ident );
            }
            return engine.getCSSContext().getSystemColor(ident);
        }
        return super.computeValue(elt, pseudo, engine, idx, sm, value);
    }

    /**
     * Creates an RGB color.
     */
    protected Value createRGBColor(Value r, Value g, Value b) {
        return new RGBColorValue(r, g, b);
    }

    /**
     * Creates a color component from a lexical unit.
     */
    protected Value createColorComponent(LexicalUnit lu) throws DOMException {
        switch (lu.getLexicalUnitType()) {
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
        throw createInvalidRGBComponentUnitDOMException
            (lu.getLexicalUnitType());
    }

    /**
     * Implements {@link IdentifierManager#getIdentifiers()}.
     */
    public StringMap getIdentifiers() {
        return values;
    }

    private DOMException createInvalidRGBComponentUnitDOMException
        (short type) {
        Object[] p = new Object[] { getPropertyName(),
                                    new Integer(type) };
        String s = Messages.formatMessage("invalid.rgb.component.unit", p);
        return new DOMException(DOMException.NOT_SUPPORTED_ERR, s);
    }

}
