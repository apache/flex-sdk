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

import java.util.StringTokenizer;
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.gvt.font.Kern;
import org.apache.flex.forks.batik.gvt.font.UnicodeRange;
import org.w3c.dom.Element;

/**
 * A base Bridge class for the kerning elements.
 *
 * @author <a href="mailto:dean.jackson@cmis.csiro.au">Dean Jackson</a>
 * @version $Id: SVGKernElementBridge.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public abstract class SVGKernElementBridge extends AbstractSVGBridge {

    /**
     * Creates a Kern object that repesents the specified kerning element.
     *
     * @param ctx The bridge context.
     * @param kernElement The kerning element. Should be either a &lt;hkern>
     * or &lt;vkern> element.
     * @param font The font the kerning is related to.
     *
     * @return kern The new Kern object
     */
    public Kern createKern(BridgeContext ctx,
                           Element kernElement,
                           SVGGVTFont font) {

        // read all of the kern attributes
        String u1 = kernElement.getAttributeNS(null, SVG_U1_ATTRIBUTE);
        String u2 = kernElement.getAttributeNS(null, SVG_U2_ATTRIBUTE);
        String g1 = kernElement.getAttributeNS(null, SVG_G1_ATTRIBUTE);
        String g2 = kernElement.getAttributeNS(null, SVG_G2_ATTRIBUTE);
        String k = kernElement.getAttributeNS(null, SVG_K_ATTRIBUTE);
        if (k.length() == 0) {
            k = SVG_KERN_K_DEFAULT_VALUE;
        }

        // get the kern float value
        float kernValue = Float.parseFloat(k);

        // set up the first and second glyph sets and unicode ranges
        int firstGlyphLen = 0, secondGlyphLen = 0;
        int [] firstGlyphSet = null;
        int [] secondGlyphSet = null;
        List firstUnicodeRanges = new ArrayList();
        List secondUnicodeRanges = new ArrayList();

        // process the u1 attribute
        StringTokenizer st = new StringTokenizer(u1, ",");
        while (st.hasMoreTokens()) {
            String token = st.nextToken();
            if (token.startsWith("U+")) { // its a unicode range
                firstUnicodeRanges.add(new UnicodeRange(token));
            } else {
                int[] glyphCodes = font.getGlyphCodesForUnicode(token);
                if (firstGlyphSet == null) {
                    firstGlyphSet = glyphCodes;
                    firstGlyphLen = glyphCodes.length;
                }else {
                    if ((firstGlyphLen + glyphCodes.length) >
                        firstGlyphSet.length) {
                        int sz = firstGlyphSet.length*2;
                        if (sz <firstGlyphLen + glyphCodes.length)
                            sz = firstGlyphLen + glyphCodes.length;
                        int [] tmp = new int[sz];
                        System.arraycopy( firstGlyphSet, 0, tmp, 0, firstGlyphLen );
                        firstGlyphSet = tmp;
                    }
                    for (int i = 0; i < glyphCodes.length; i++)
                        firstGlyphSet[firstGlyphLen++] = glyphCodes[i];
                }
            }
        }

        // process the u2 attrbute
        st = new StringTokenizer(u2, ",");
        while (st.hasMoreTokens()) {
            String token = st.nextToken();
            if (token.startsWith("U+")) { // its a unicode range
                secondUnicodeRanges.add(new UnicodeRange(token));
            } else {
                int[] glyphCodes = font.getGlyphCodesForUnicode(token);
                if (secondGlyphSet == null) {
                    secondGlyphSet = glyphCodes;
                    secondGlyphLen = glyphCodes.length;
                } else {
                    if ((secondGlyphLen + glyphCodes.length) >
                        secondGlyphSet.length) {
                        int sz = secondGlyphSet.length*2;
                        if (sz <secondGlyphLen + glyphCodes.length)
                            sz = secondGlyphLen + glyphCodes.length;
                        int [] tmp = new int[sz];
                        System.arraycopy( secondGlyphSet, 0, tmp, 0, secondGlyphLen );
                        secondGlyphSet = tmp;
                    }
                    for (int i = 0; i < glyphCodes.length; i++)
                        secondGlyphSet[secondGlyphLen++] = glyphCodes[i];
                }
            }
        }

        // process the g1 attribute
        st = new StringTokenizer(g1, ",");
        while (st.hasMoreTokens()) {
            String token = st.nextToken();
            int[] glyphCodes = font.getGlyphCodesForName(token);
            if (firstGlyphSet == null) {
                firstGlyphSet = glyphCodes;
                firstGlyphLen = glyphCodes.length;
            }else {
                if ((firstGlyphLen + glyphCodes.length) >
                    firstGlyphSet.length) {
                    int sz = firstGlyphSet.length*2;
                    if (sz <firstGlyphLen + glyphCodes.length)
                        sz = firstGlyphLen + glyphCodes.length;
                    int [] tmp = new int[sz];
                    System.arraycopy( firstGlyphSet, 0, tmp, 0, firstGlyphLen );
                    firstGlyphSet = tmp;
                }
                for (int i = 0; i < glyphCodes.length; i++)
                    firstGlyphSet[firstGlyphLen++] = glyphCodes[i];
            }
        }

        // process the g2 attribute
        st = new StringTokenizer(g2, ",");
        while (st.hasMoreTokens()) {
            String token = st.nextToken();
            int[] glyphCodes = font.getGlyphCodesForName(token);
            if (secondGlyphSet == null) {
                secondGlyphSet = glyphCodes;
                secondGlyphLen = glyphCodes.length;
            } else {
                if ((secondGlyphLen + glyphCodes.length) >
                    secondGlyphSet.length) {
                    int sz = secondGlyphSet.length*2;
                    if (sz <secondGlyphLen + glyphCodes.length)
                        sz = secondGlyphLen + glyphCodes.length;
                    int [] tmp = new int[sz];
                    System.arraycopy( secondGlyphSet, 0, tmp, 0, secondGlyphLen );
                    secondGlyphSet = tmp;
                }
                for (int i = 0; i < glyphCodes.length; i++)
                    secondGlyphSet[secondGlyphLen++] = glyphCodes[i];
            }
        }

        // construct the arrays
        int[] firstGlyphs;
        if ((firstGlyphLen == 0) ||
            (firstGlyphLen == firstGlyphSet.length)) {
            firstGlyphs = firstGlyphSet;
        } else {
            firstGlyphs = new int[firstGlyphLen];
            System.arraycopy(firstGlyphSet, 0, firstGlyphs, 0, firstGlyphLen);
        }
        int[] secondGlyphs;
        if ((secondGlyphLen == 0) ||
            (secondGlyphLen == secondGlyphSet.length)) {
            secondGlyphs = secondGlyphSet;
        } else {
            secondGlyphs = new int[secondGlyphLen];
            System.arraycopy(secondGlyphSet, 0, secondGlyphs, 0,
                             secondGlyphLen);
        }

        UnicodeRange[] firstRanges;
        firstRanges = new UnicodeRange[firstUnicodeRanges.size()];
        firstUnicodeRanges.toArray(firstRanges);

        UnicodeRange[] secondRanges;
        secondRanges = new UnicodeRange[secondUnicodeRanges.size()];
        secondUnicodeRanges.toArray(secondRanges);

        // return the new Kern object
        return new Kern(firstGlyphs, secondGlyphs,
                        firstRanges, secondRanges, kernValue);
    }
}
