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
package org.apache.flex.forks.batik.bridge;
import java.util.List;
import java.util.LinkedList;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.FontFaceRule;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueConstants;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.gvt.font.GVTFontFamily;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class represents a &lt;font-face> element or @font-face rule
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: CSSFontFace.java 475477 2006-11-15 22:44:28Z cam $
 */
public class CSSFontFace extends FontFace implements SVGConstants {

    GVTFontFamily fontFamily = null;

    /**
     * Constructes an CSSFontFace with the specfied font-face attributes.
     */
    public CSSFontFace
        (List srcs,
         String familyName, float unitsPerEm, String fontWeight,
         String fontStyle, String fontVariant, String fontStretch,
         float slope, String panose1, float ascent, float descent,
         float strikethroughPosition, float strikethroughThickness,
         float underlinePosition, float underlineThickness,
         float overlinePosition, float overlineThickness) {
        super(srcs,
              familyName, unitsPerEm, fontWeight, fontStyle,
              fontVariant, fontStretch, slope, panose1, ascent, descent,
              strikethroughPosition, strikethroughThickness,
              underlinePosition, underlineThickness,
              overlinePosition, overlineThickness);
    }

    protected CSSFontFace(String familyName) {
        super(familyName);
    }

    public static CSSFontFace createCSSFontFace(CSSEngine eng,
                                                FontFaceRule ffr) {
        StyleMap sm = ffr.getStyleMap();
        String familyName = getStringProp
            (sm, eng, SVGCSSEngine.FONT_FAMILY_INDEX);

        CSSFontFace ret = new CSSFontFace(familyName);

        Value v;
        v = sm.getValue(SVGCSSEngine.FONT_WEIGHT_INDEX);
        if (v != null) 
            ret.fontWeight = v.getCssText();
        v = sm.getValue(SVGCSSEngine.FONT_STYLE_INDEX);
        if (v != null) 
            ret.fontStyle = v.getCssText();
        v = sm.getValue(SVGCSSEngine.FONT_VARIANT_INDEX);
        if (v != null) 
            ret.fontVariant = v.getCssText();
        v = sm.getValue(SVGCSSEngine.FONT_STRETCH_INDEX);
        if (v != null) 
            ret.fontStretch = v.getCssText();
        v = sm.getValue(SVGCSSEngine.SRC_INDEX);
        
        ParsedURL base = ffr.getURL();
        if ((v != null) && (v != ValueConstants.NONE_VALUE)) {
            if (v.getCssValueType() == CSSValue.CSS_PRIMITIVE_VALUE) {
                ret.srcs = new LinkedList();
                ret.srcs.add(getSrcValue(v, base));
            } else if (v.getCssValueType() == CSSValue.CSS_VALUE_LIST) {
                ret.srcs = new LinkedList();
                for (int i=0; i<v.getLength(); i++) {
                    ret.srcs.add(getSrcValue(v.item(i), base));
                }
            }
        }
        /*
        float unitsPerEm = getFloatProp
            (sm, eng, SVGCSSEngine.UNITS_PER_EM_INDEX);
        String slope = getFloatProp
            (sm, eng, SVGCSSEngine.SLOPE_INDEX);
        String panose1 = getStringProp
            (sm, eng, SVGCSSEngine.PANOSE1_INDEX);
        String ascent = getFloatProp
            (sm, eng, SVGCSSEngine.ASCENT_INDEX);
        String descent = getFloatProp
            (sm, eng, SVGCSSEngine.DESCENT_INDEX);
        String strikethroughPosition = getFloatProp
            (sm, eng, SVGCSSEngine.STRIKETHROUGH_POSITION_INDEX);
        String strikethroughThickness = getFloatProp
            (sm, eng, SVGCSSEngine.STRIKETHROUGH_THICKNESS_INDEX);
        String underlinePosition = getFloatProp
            (sm, eng, SVGCSSEngine.UNDERLINE_POSITION_INDEX);
        String underlineThickness = getFloatProp
            (sm, eng, SVGCSSEngine.UNDERLINE_THICKNESS_INDEX);
        String overlinePosition = getFloatProp
            (sm, eng, SVGCSSEngine.OVERLINE_POSITION_INDEX);
        String overlineThickness = getFloatProp
            (sm, eng, SVGCSSEngine.OVERLINE_THICKNESS_INDEX);
        */
        return ret;
    }

    public static Object getSrcValue(Value v, ParsedURL base) {
        if (v.getCssValueType() != CSSValue.CSS_PRIMITIVE_VALUE) 
            return null;
        if (v.getPrimitiveType() == CSSPrimitiveValue.CSS_URI) {
            if (base != null)
                return new ParsedURL(base, v.getStringValue());
            return new ParsedURL(v.getStringValue());
        } 
        if (v.getPrimitiveType() == CSSPrimitiveValue.CSS_STRING)
            return v.getStringValue();
        return null;
    }
    public static String getStringProp(StyleMap sm, CSSEngine eng, int pidx) {
        Value v = sm.getValue(pidx);
        ValueManager [] vms = eng.getValueManagers();
        if (v == null) {
            ValueManager vm = vms[pidx];
            v = vm.getDefaultValue();
        }
        while (v.getCssValueType() == CSSValue.CSS_VALUE_LIST) {
            v = v.item(0);
        }
        return v.getStringValue();
    }

    public static float getFloatProp(StyleMap sm, CSSEngine eng, int pidx) {
        Value v = sm.getValue(pidx);
        ValueManager [] vms = eng.getValueManagers();
        if (v == null) {
            ValueManager vm = vms[pidx];
            v = vm.getDefaultValue();
        }
        while (v.getCssValueType() == CSSValue.CSS_VALUE_LIST) {
            v = v.item(0);
        }
        return v.getFloatValue();
    }

    /**
     * Returns the font associated with this rule or element.
     */
    public GVTFontFamily getFontFamily(BridgeContext ctx) {
        if (fontFamily != null)
            return fontFamily ;

        fontFamily = super.getFontFamily(ctx);
        return fontFamily;
    }
}
