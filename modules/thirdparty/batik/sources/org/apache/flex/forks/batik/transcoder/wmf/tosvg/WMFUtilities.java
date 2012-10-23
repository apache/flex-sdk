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

package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

import java.io.UnsupportedEncodingException;
import org.apache.flex.forks.batik.transcoder.wmf.WMFConstants;

/** This class holds various utilies for importing WMF files that can be used either for
 *  {@link org.apache.flex.forks.batik.transcoder.wmf.tosvg.AbstractWMFReader}s and
 *  {@link org.apache.flex.forks.batik.transcoder.wmf.tosvg.AbstractWMFPainter}s
 *
 * @version $Id: WMFUtilities.java 582434 2007-10-06 02:11:51Z cam $
 */
public class WMFUtilities {

    /**
     * Decode a byte array in a string, using the charset of the given font.
     *
     * @param wmfFont the font to use the charset of.
     * @param bstr the encoded bytes of the string.
     */
    public static String decodeString(WMFFont wmfFont, byte[] bstr) {
        // manage the charset encoding
        try {
            switch (wmfFont.charset) {
            case WMFConstants.META_CHARSET_ANSI:
                return new String(bstr, WMFConstants.CHARSET_ANSI);
            case WMFConstants.META_CHARSET_DEFAULT:
                return new String(bstr, WMFConstants.CHARSET_DEFAULT);
            case WMFConstants.META_CHARSET_SHIFTJIS:
                return new String(bstr, WMFConstants.CHARSET_SHIFTJIS);
            case WMFConstants.META_CHARSET_HANGUL:
                return new String(bstr, WMFConstants.CHARSET_HANGUL);
            case WMFConstants.META_CHARSET_JOHAB:
                return new String(bstr, WMFConstants.CHARSET_JOHAB);
            case WMFConstants.META_CHARSET_GB2312:
                return new String(bstr, WMFConstants.CHARSET_GB2312);
            case WMFConstants.META_CHARSET_CHINESEBIG5:
                return new String(bstr, WMFConstants.CHARSET_CHINESEBIG5);
            case WMFConstants.META_CHARSET_GREEK:
                return new String(bstr, WMFConstants.CHARSET_GREEK);
            case WMFConstants.META_CHARSET_TURKISH:
                return new String(bstr, WMFConstants.CHARSET_TURKISH);
            case WMFConstants.META_CHARSET_VIETNAMESE:
                return new String(bstr, WMFConstants.CHARSET_VIETNAMESE);
            case WMFConstants.META_CHARSET_HEBREW:
                return new String(bstr, WMFConstants.CHARSET_HEBREW);
            case WMFConstants.META_CHARSET_ARABIC:
                return new String(bstr, WMFConstants.CHARSET_ARABIC);
            case WMFConstants.META_CHARSET_RUSSIAN:
                return new String(bstr, WMFConstants.CHARSET_CYRILLIC);
            case WMFConstants.META_CHARSET_THAI:
                return new String(bstr, WMFConstants.CHARSET_THAI);
            case WMFConstants.META_CHARSET_EASTEUROPE:
                return new String(bstr, WMFConstants.CHARSET_EASTEUROPE);
            case WMFConstants.META_CHARSET_OEM:
                return new String(bstr, WMFConstants.CHARSET_OEM);
            default:
                // Fall through to use default.
            }
        } catch (UnsupportedEncodingException e) {
            // Fall through to use default.
        }

        return new String(bstr);
    }

    /** Get the Horizontal Alignement for the Alignment property.
     */
    public static int getHorizontalAlignment(int align) {
        int v = align;
        v = v % WMFConstants.TA_BASELINE; // skip baseline alignment (24)
        v = v % WMFConstants.TA_BOTTOM;  // skip bottom aligment (8)
        if (v >= 6) return WMFConstants.TA_CENTER;
        else if (v >= 2) return WMFConstants.TA_RIGHT;
        else return WMFConstants.TA_LEFT;
    }

    /** Get the Vertical Alignement for the Alignment property.
     */
    public static int getVerticalAlignment(int align) {
        int v = align;
        if ((v/WMFConstants.TA_BASELINE) != 0) return WMFConstants.TA_BASELINE;
        v = v % WMFConstants.TA_BASELINE; // skip baseline alignment (24)
        if ((v/WMFConstants.TA_BOTTOM) != 0) return WMFConstants.TA_BOTTOM;
        else return WMFConstants.TA_TOP;
    }
}
