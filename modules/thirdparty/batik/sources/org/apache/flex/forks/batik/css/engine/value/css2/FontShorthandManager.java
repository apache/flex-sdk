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

import java.util.HashSet;
import java.util.Set;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.engine.value.IdentifierManager;
import org.apache.flex.forks.batik.css.engine.value.AbstractValueFactory;
import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.parser.CSSLexicalUnit;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.w3c.css.sac.LexicalUnit;

/**
 * This class provides support for the CSS2 'font' shorthand property.
 *
 * The form of this property is:
 *     [ [ <font-style> || <font-variant> || <font-weight> ]?
 *         <font-size> [ / <line-height> ]? <font-family> ] |
 *       caption | icon | menu | message-box | small-caption |
 *       status-bar | inherit
 *
 *  It is worth noting that there is a potential ambiguity
 * between font-size and font-weight since in SVG they can both
 * be unitless.  This is solved by considering the 'last' number
 * before an 'ident' or '/' to be font-size and any preceeding
 * number to be font-weight.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: FontShorthandManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class FontShorthandManager
    extends AbstractValueFactory
    implements ShorthandManager {

    public FontShorthandManager() { }

    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return CSSConstants.CSS_FONT_PROPERTY;
    }

    /**
     * Implements {@link ShorthandManager#isAnimatableProperty()}.
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

    static LexicalUnit NORMAL_LU = CSSLexicalUnit.createString
        (LexicalUnit.SAC_IDENT, CSSConstants.CSS_NORMAL_VALUE, null);
    static LexicalUnit BOLD_LU = CSSLexicalUnit.createString
        (LexicalUnit.SAC_IDENT, CSSConstants.CSS_BOLD_VALUE, null);

    static LexicalUnit MEDIUM_LU = CSSLexicalUnit.createString
        (LexicalUnit.SAC_IDENT, CSSConstants.CSS_MEDIUM_VALUE, null);

    static LexicalUnit SZ_10PT_LU = CSSLexicalUnit.createFloat
        (LexicalUnit.SAC_POINT, 10, null);
    static LexicalUnit SZ_8PT_LU = CSSLexicalUnit.createFloat
        (LexicalUnit.SAC_POINT, 8, null);


    static LexicalUnit FONT_FAMILY_LU;
    static {
        LexicalUnit lu;
        FONT_FAMILY_LU = CSSLexicalUnit.createString
            (LexicalUnit.SAC_IDENT, "Dialog", null);
        lu = CSSLexicalUnit.createString
            (LexicalUnit.SAC_IDENT, "Helvetica", FONT_FAMILY_LU);
        CSSLexicalUnit.createString
            (LexicalUnit.SAC_IDENT,
             CSSConstants.CSS_SANS_SERIF_VALUE, lu);
    }

    protected static final Set values = new HashSet();
    static {
        values.add(CSSConstants.CSS_CAPTION_VALUE);
        values.add(CSSConstants.CSS_ICON_VALUE);
        values.add(CSSConstants.CSS_MENU_VALUE);
        values.add(CSSConstants.CSS_MESSAGE_BOX_VALUE);
        values.add(CSSConstants.CSS_SMALL_CAPTION_VALUE);
        values.add(CSSConstants.CSS_STATUS_BAR_VALUE);
    }

    public void handleSystemFont(CSSEngine eng,
                                 ShorthandManager.PropertyHandler ph,
                                 String s,
                                 boolean imp) {

        LexicalUnit fontStyle   = NORMAL_LU;
        LexicalUnit fontVariant = NORMAL_LU;
        LexicalUnit fontWeight  = NORMAL_LU;
        LexicalUnit lineHeight  = NORMAL_LU;
        LexicalUnit fontFamily  = FONT_FAMILY_LU;

        LexicalUnit fontSize;
        if (s.equals(CSSConstants.CSS_SMALL_CAPTION_VALUE)) {
            fontSize = SZ_8PT_LU;
        } else {
            fontSize = SZ_10PT_LU;
        }
        ph.property(CSSConstants.CSS_FONT_FAMILY_PROPERTY,  fontFamily,  imp);
        ph.property(CSSConstants.CSS_FONT_STYLE_PROPERTY,   fontStyle,   imp);
        ph.property(CSSConstants.CSS_FONT_VARIANT_PROPERTY, fontVariant, imp);
        ph.property(CSSConstants.CSS_FONT_WEIGHT_PROPERTY,  fontWeight,  imp);
        ph.property(CSSConstants.CSS_FONT_SIZE_PROPERTY,    fontSize,    imp);
        ph.property(CSSConstants.CSS_LINE_HEIGHT_PROPERTY,  lineHeight,  imp);
    }

    /**
     * Implements {@link ShorthandManager#setValues(CSSEngine,ShorthandManager.PropertyHandler,LexicalUnit,boolean)}.
     */
    public void setValues(CSSEngine eng,
                          ShorthandManager.PropertyHandler ph,
                          LexicalUnit lu,
                          boolean imp) {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT: return;
        case LexicalUnit.SAC_IDENT: {
            String s = lu.getStringValue().toLowerCase();
            if (values.contains(s)) {
                handleSystemFont(eng, ph, s, imp);
                return;
            }
        }
        }

        LexicalUnit fontStyle   = null;
        LexicalUnit fontVariant = null;
        LexicalUnit fontWeight  = null;
        LexicalUnit fontSize    = null;
        LexicalUnit lineHeight  = null;
        LexicalUnit fontFamily  = null;

        ValueManager[]vMgrs = eng.getValueManagers();
        int fst, fv, fw, fsz, lh;
        fst = eng.getPropertyIndex(CSSConstants.CSS_FONT_STYLE_PROPERTY);
        fv  = eng.getPropertyIndex(CSSConstants.CSS_FONT_VARIANT_PROPERTY);
        fw  = eng.getPropertyIndex(CSSConstants.CSS_FONT_WEIGHT_PROPERTY);
        fsz = eng.getPropertyIndex(CSSConstants.CSS_FONT_SIZE_PROPERTY);
        lh  = eng.getPropertyIndex(CSSConstants.CSS_LINE_HEIGHT_PROPERTY);

        IdentifierManager fstVM = (IdentifierManager)vMgrs[fst];
        IdentifierManager fvVM  = (IdentifierManager)vMgrs[fv];
        IdentifierManager fwVM  = (IdentifierManager)vMgrs[fw];
        FontSizeManager   fszVM = (FontSizeManager)vMgrs[fsz];

        StringMap fstSM = fstVM.getIdentifiers();
        StringMap fvSM  = fvVM.getIdentifiers();
        StringMap fwSM  = fwVM.getIdentifiers();
        StringMap fszSM = fszVM.getIdentifiers();


        // Check for font-style, font-variant, & font-weight
        // These are all optional.

        boolean svwDone= false;
        LexicalUnit intLU = null;
        while (!svwDone && (lu != null)) {
            switch (lu.getLexicalUnitType()) {
            case LexicalUnit.SAC_IDENT: {
                String s = lu.getStringValue().toLowerCase().intern();
                if (fontStyle == null && fstSM.get(s) != null) {
                    fontStyle = lu;
                    if (intLU != null) {
                        if (fontWeight == null) {
                            fontWeight = intLU;
                            intLU = null;
                        } else {
                            throw createInvalidLexicalUnitDOMException
                                (intLU.getLexicalUnitType());
                        }
                    }
                    break;
                }

                if (fontVariant == null && fvSM.get(s) != null) {
                    fontVariant = lu;
                    if (intLU != null) {
                        if (fontWeight == null) {
                            fontWeight = intLU;
                            intLU = null;
                        } else {
                            throw createInvalidLexicalUnitDOMException
                                (intLU.getLexicalUnitType());
                        }
                    }
                    break;
                }

                if (intLU == null && fontWeight == null
                        && fwSM.get(s) != null) {
                    fontWeight = lu;
                    break;
                }

                svwDone = true;
                break;
            }
            case LexicalUnit.SAC_INTEGER:
                if (intLU == null && fontWeight == null) {
                    intLU = lu;
                    break;
                }
                svwDone = true;
                break;

            default: // All other must be size,'/line-height', family
                svwDone = true;
                break;
            }
            if (!svwDone) lu = lu.getNextLexicalUnit();
        }

        // Must have font-size.
        if (lu == null)
            throw createMalformedLexicalUnitDOMException();

        // Now we need to get font-size
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_IDENT: {
            String s= lu.getStringValue().toLowerCase().intern();
            if (fszSM.get(s) != null) {
                fontSize = lu; // This is a font-size ident.
                lu = lu.getNextLexicalUnit();
            }
        }
            break;

        case LexicalUnit.SAC_EM:
        case LexicalUnit.SAC_EX:
        case LexicalUnit.SAC_PIXEL:
        case LexicalUnit.SAC_CENTIMETER:
        case LexicalUnit.SAC_MILLIMETER:
        case LexicalUnit.SAC_INCH:
        case LexicalUnit.SAC_POINT:
        case LexicalUnit.SAC_PICA:
        case LexicalUnit.SAC_INTEGER:
        case LexicalUnit.SAC_REAL:
        case LexicalUnit.SAC_PERCENTAGE:
            fontSize = lu;
            lu = lu.getNextLexicalUnit();
            break;
        }


        if (fontSize == null) {
            // We must have a font-size so see if we can use intLU...
            if (intLU != null) {
                fontSize = intLU;  // Yup!
                intLU = null;
            } else {
                throw createInvalidLexicalUnitDOMException
                    (lu.getLexicalUnitType());
            }
        }

        if (intLU != null) {
            // We have a intLU left see if we can use it as font-weight
            if (fontWeight == null) {
                fontWeight = intLU; // use intLU as font-weight.
            } else {
                // we have an 'extra' integer in property.
                throw createInvalidLexicalUnitDOMException
                    (intLU.getLexicalUnitType());
            }
        }

        // Must have Font-Family, so if it's null now we are done!
        if (lu == null)
            throw createMalformedLexicalUnitDOMException();

        // Now at this point we want to look for
        // line-height.
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_OPERATOR_SLASH: // we have line-height
            lu = lu.getNextLexicalUnit();
            if (lu == null) // OOPS!
                throw createMalformedLexicalUnitDOMException();
            lineHeight = lu;
            lu = lu.getNextLexicalUnit();
            break;
        }

        // Must have Font-Family, so if it's null now we are done!
        if (lu == null)
            throw createMalformedLexicalUnitDOMException();
        fontFamily = lu;

        if (fontStyle   == null) fontStyle   = NORMAL_LU;
        if (fontVariant == null) fontVariant = NORMAL_LU;
        if (fontWeight  == null) fontWeight  = NORMAL_LU;
        if (lineHeight  == null) lineHeight  = NORMAL_LU;

        ph.property(CSSConstants.CSS_FONT_FAMILY_PROPERTY,  fontFamily,  imp);
        ph.property(CSSConstants.CSS_FONT_STYLE_PROPERTY,   fontStyle,   imp);
        ph.property(CSSConstants.CSS_FONT_VARIANT_PROPERTY, fontVariant, imp);
        ph.property(CSSConstants.CSS_FONT_WEIGHT_PROPERTY,  fontWeight,  imp);
        ph.property(CSSConstants.CSS_FONT_SIZE_PROPERTY,    fontSize,    imp);
        if (lh != -1) {
            ph.property(CSSConstants.CSS_LINE_HEIGHT_PROPERTY,
                        lineHeight,  imp);
        }
    }
}
