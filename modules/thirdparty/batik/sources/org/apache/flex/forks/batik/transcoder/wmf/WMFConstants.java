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

package org.apache.flex.forks.batik.transcoder.wmf;

/**
 * Contains the definitions of WMF constants.
 *
 * @author <a href="mailto:luano@asd.ie">Luan O'Carroll</a>
 * @version $Id: WMFConstants.java 501094 2007-01-29 16:35:37Z deweese $
 */
public interface WMFConstants
{
    int META_ALDUS_APM              = 0x9ac6cdd7;

    int META_DRAWTEXT               = 0x062F;
    int META_SETBKCOLOR             = 0x0201;
    int META_SETBKMODE              = 0x0102;
    int META_SETMAPMODE             = 0x0103;
    int META_SETROP2                = 0x0104;
    int META_SETRELABS              = 0x0105;
    int META_SETPOLYFILLMODE        = 0x0106;
    int META_SETSTRETCHBLTMODE      = 0x0107;
    int META_SETTEXTCHAREXTRA       = 0x0108;
    int META_SETTEXTCOLOR           = 0x0209;
    int META_SETTEXTJUSTIFICATION   = 0x020A;
    int META_SETWINDOWORG           = 0x020B;
    int META_SETWINDOWORG_EX        = 0x0000; // ???? LOOKS SUSPICIOUS
    int META_SETWINDOWEXT           = 0x020C;
    int META_SETVIEWPORTORG         = 0x020D;
    int META_SETVIEWPORTEXT         = 0x020E;
    int META_OFFSETWINDOWORG        = 0x020F;
    int META_SCALEWINDOWEXT         = 0x0410;
    int META_OFFSETVIEWPORTORG      = 0x0211;
    int META_SCALEVIEWPORTEXT       = 0x0412;
    int META_LINETO                 = 0x0213;
    int META_MOVETO                 = 0x0214;
    int META_EXCLUDECLIPRECT        = 0x0415;
    int META_INTERSECTCLIPRECT      = 0x0416;
    int META_ARC                    = 0x0817;
    int META_ELLIPSE                = 0x0418;
    int META_FLOODFILL              = 0x0419;
    int META_PIE                    = 0x081A;
    int META_RECTANGLE              = 0x041B;
    int META_ROUNDRECT              = 0x061C;
    int META_PATBLT                 = 0x061D;
    int META_SAVEDC                 = 0x001E;
    int META_SETPIXEL               = 0x041F;
    int META_OFFSETCLIPRGN          = 0x0220;
    int META_TEXTOUT                = 0x0521;
    int META_BITBLT                 = 0x0922;
    int META_STRETCHBLT             = 0x0B23;
    int META_POLYGON                = 0x0324;
    int META_POLYLINE               = 0x0325;
    int META_ESCAPE                 = 0x0626;
    int META_RESTOREDC              = 0x0127;
    int META_FILLREGION             = 0x0228;
    int META_FRAMEREGION            = 0x0429;
    int META_INVERTREGION           = 0x012A;
    int META_PAINTREGION            = 0x012B;
    int META_SELECTCLIPREGION       = 0x012C;
    int META_SELECTOBJECT           = 0x012D;
    int META_SETTEXTALIGN           = 0x012E;
    int META_CHORD                  = 0x0830;
    int META_SETMAPPERFLAGS         = 0x0231;
    int META_EXTTEXTOUT             = 0x0a32;
    int META_SETDIBTODEV            = 0x0d33;
    int META_SELECTPALETTE          = 0x0234;
    int META_REALIZEPALETTE         = 0x0035;
    int META_ANIMATEPALETTE         = 0x0436;
    int META_SETPALENTRIES          = 0x0037;
    int META_POLYPOLYGON            = 0x0538;
    int META_RESIZEPALETTE          = 0x0139;
    int META_DIBBITBLT              = 0x0940;
    int META_DIBSTRETCHBLT          = 0x0b41;
    int META_DIBCREATEPATTERNBRUSH  = 0x0142;
    int META_STRETCHDIB             = 0x0f43;
    int META_EXTFLOODFILL           = 0x0548;
    int META_SETLAYOUT              = 0x0149;
    int META_DELETEOBJECT           = 0x01f0;
    int META_CREATEPALETTE          = 0x00f7;
    int META_CREATEPATTERNBRUSH     = 0x01F9;
    int META_CREATEPENINDIRECT      = 0x02FA;
    int META_CREATEFONTINDIRECT     = 0x02FB;
    int META_CREATEBRUSHINDIRECT    = 0x02FC;
    int META_CREATEREGION           = 0x06FF;
    int META_POLYBEZIER16           = 0x1000;
    int META_CREATEBRUSH            = 0x00F8;
    int META_CREATEBITMAPINDIRECT   = 0x02FD;
    int META_CREATEBITMAP           = 0x06FE;

    int META_OBJ_WHITE_BRUSH         = 0;
    int META_OBJ_LTGRAY_BRUSH        = 1;
    int META_OBJ_GRAY_BRUSH          = 2;
    int META_OBJ_DKGRAY_BRUSH        = 3;
    int META_OBJ_BLACK_BRUSH         = 4;
    int META_OBJ_NULL_BRUSH          = 5;
    int META_OBJ_HOLLOW_BRUSH        = 5;
    int META_OBJ_WHITE_PEN           = 6;
    int META_OBJ_BLACK_PEN           = 7;
    int META_OBJ_NULL_PEN            = 8;
    int META_OBJ_OEM_FIXED_FONT      = 10;
    int META_OBJ_ANSI_FIXED_FONT     = 11;
    int META_OBJ_ANSI_VAR_FONT       = 12;
    int META_OBJ_SYSTEM_FONT         = 13;
    int META_OBJ_DEVICE_DEFAULT_FONT = 14;
    int META_OBJ_DEFAULT_PALETTE     = 15;
    int META_OBJ_SYSTEM_FIXED_FONT   = 16;

    /* New StretchBlt() Modes */
    int STRETCH_BLACKONWHITE = 1;
    int STRETCH_WHITEONBLACK = 2;
    int STRETCH_COLORONCOLOR = 3;
    int STRETCH_HALFTONE = 4;
    int STRETCH_ANDSCANS = 1;
    int STRETCH_ORSCANS = 2;
    int STRETCH_DELETESCANS = 3;

    // new values for PATBLT value

    /** new constant for PATBLT.
     */
    int META_PATCOPY                = 0x00F00021;
    /** new constant for PATBLT.
     */
    int META_PATINVERT              = 0x005A0049;
    /** new constant for PATBLT.
     */
    int META_DSTINVERT              = 0x00550009;
    /** new constant for PATBLT.
     */
    int META_BLACKNESS              = 0x00000042;
    /** new constant for PATBLT.
     */
    int META_WHITENESS              = 0x00FF0062;

    // new constants for pen styles
    int META_PS_SOLID = 0;
    int META_PS_DASH = 1;
    int META_PS_DOT = 2;
    int META_PS_DASHDOT = 3;
    int META_PS_DASHDOTDOT = 4;
    int META_PS_NULL = 5;
    int META_PS_INSIDEFRAME = 6;

    // new constants for charsets

    /** ANSI charset WMF ID.
     */
    int META_CHARSET_ANSI = 0;

    /** DEFAULT charset WMF ID.
     */
    int META_CHARSET_DEFAULT = 1;

    /** SYMBOL charset WMF ID.
     */
    int META_CHARSET_SYMBOL = 2;

    /** SHIFTJIS charset WMF ID.
     */
    int META_CHARSET_SHIFTJIS = 128;

    /** HANGUL charset WMF ID.
     */
    int META_CHARSET_HANGUL = 129;

    /** JOHAB charset WMF ID.
     */
    int META_CHARSET_JOHAB = 130;

    /** GB2312 charset WMF ID.
     */
    int META_CHARSET_GB2312 = 134;

    /** CHINESEBIG5 charset WMF ID.
     */
    int META_CHARSET_CHINESEBIG5 = 136;

    /** GREEK charset WMF ID.
     */
    int META_CHARSET_GREEK = 161;

    /** TURKISH charset WMF ID.
     */
    int META_CHARSET_TURKISH = 162;

    /** VIETNAMESE charset WMF ID.
     */
    int META_CHARSET_VIETNAMESE = 163;

    /** HEBREW charset WMF ID.
     */
    int META_CHARSET_HEBREW = 177;

    /** ARABIC charset WMF ID.
     */
    int META_CHARSET_ARABIC = 178;

    /** RUSSIAN (CYRILLIC) charset WMF ID.
     */
    int META_CHARSET_RUSSIAN = 204;

    /** THAI charset WMF ID.
     */
    int META_CHARSET_THAI = 222;

    /** EASTEUROPE charset WMF ID.
     */
    int META_CHARSET_EASTEUROPE = 238;

    /** OEM charset WMF ID.
     */
    int META_CHARSET_OEM = 255;

    // new constants for charset names, useful for decoding and encoding text.

    /** ANSI charset Java name, ie "ISO-8859-1" charset.
     */
    String CHARSET_ANSI = "ISO-8859-1";

    /** DEFAULT charset Java name, by default taken as "US-ASCII" charset.
     */
    String CHARSET_DEFAULT = "US-ASCII";

    /** SHIFTJIS charset Java name, ie "Shift_JIS" charset.
     */
    String CHARSET_SHIFTJIS = "Shift_JIS";

    /** HANGUL charset Java name, ie "cp949" charset.
     */
    String CHARSET_HANGUL = "cp949";

    /** JOHAB charset Java name, ie "x-Johab" charset.
     */
    String CHARSET_JOHAB = "x-Johab";

    /** GB2312 charset Java name, ie "GB2312" charset.
     */
    String CHARSET_GB2312 = "GB2312";

    /** CHINESEBIG5 charset Java name, ie "Big5" charset.
     */
    String CHARSET_CHINESEBIG5 = "Big5";

    /** GREEK charset Java name, ie "windows-1253" charset.
     */
    String CHARSET_GREEK = "windows-1253";

    /** TURKISH charset Java name, ie "cp1254" charset.
     */
    String CHARSET_TURKISH = "cp1254";

    /** VIETNAMESE charset Java name, ie "windows-1253" charset.
     */
    String CHARSET_VIETNAMESE = "cp1258";

    /** CYRILLIC charset Java name, ie "windows-1251" charset.
     */
    String CHARSET_CYRILLIC = "windows-1251";

    /** HEBREW charset Java name, ie "windows-1255" charset.
     */
    String CHARSET_HEBREW = "windows-1255";

    /** ARABIC charset Java name, ie "windows-1256" charset.
     */
    String CHARSET_ARABIC = "windows-1256";

    /** THAI charset Java name, ie "cp874" charset.
     */
    String CHARSET_THAI = "cp874";

    /** EASTEUROPE charset Java name, ie "cp1250" charset.
     */
    String CHARSET_EASTEUROPE = "cp1250";

    /** OEM charset Java name, ie "cp437" charset.
     */
    String CHARSET_OEM = "cp437";

    /** conversion from inches to Millimeters
     */
    float INCH_TO_MM = 25.4f;

    /** number of inches default values
     */
    int DEFAULT_INCH_VALUE = 576;

    // constants concerning map modes
    int MM_TEXT = 1;
    int MM_LOMETRIC = 2;
    int MM_HIMETRIC = 3;
    int MM_LOENGLISH = 4;
    int MM_HIENGLISH = 5;
    int MM_HITWIPS = 6;
    int MM_ISOTROPIC = 7;
    int MM_ANISOTROPIC = 8;

    // other WMF constants.
    int BS_SOLID = 0;
    int BS_HOLLOW = 1;
    int BS_NULL = 1;
    int BS_HATCHED = 2;
    int BS_PATTERN = 3;
    int BS_DIBPATTERN = 5;
    int HS_HORIZONTAL = 0;
    int HS_VERTICAL = 1;
    int HS_FDIAGONAL = 2;
    int HS_BDIAGONAL = 3;
    int HS_CROSS = 4;
    int HS_DIAGCROSS = 5;
    int DIB_RGB_COLORS = 0;
    int DIB_PAL_COLORS = 1;
    int FW_DONTCARE = 100;
    int FW_THIN = 100;
    int FW_NORMAL = 400;
    int FW_BOLD = 700;
    int FW_BLACK = 900;
    byte ANSI_CHARSET = 0;
    byte DEFAULT_CHARSET = 1;
    byte SYMBOL_CHARSET = 2;
    byte SHIFTJIS_CHARSET = -128;
    byte OEM_CHARSET = -1;
    byte OUT_DEFAULT_PRECIS = 0;
    byte OUT_STRING_PRECIS = 1;
    byte OUT_CHARACTER_PRECIS = 2;
    byte OUT_STROKE_PRECIS = 3;
    byte OUT_TT_PRECIS = 4;
    byte OUT_DEVICE_PRECIS = 5;
    byte OUT_RASTER_PRECIS = 6;
    byte CLIP_DEFAULT_PRECIS = 0;
    byte CLIP_CHARACTER_PRECIS = 1;
    byte CLIP_STROKE_PRECIS = 2;
    byte CLIP_MASK = 15;
    byte CLIP_LH_ANGLES = 16;
    byte CLIP_TT_ALWAYS = 32;
    byte DEFAULT_QUALITY = 0;
    byte DRAFT_QUALITY = 1;
    byte PROOF_QUALITY = 2;
    byte DEFAULT_PITCH = 0;
    byte FIXED_PITCH = 1;
    byte VARIABLE_PITCH = 2;
    byte FF_DONTCARE = 0;
    byte FF_ROMAN = 16;
    byte FF_SWISS = 32;
    byte FF_MODERN = 48;
    byte FF_SCRIPT = 64;
    byte FF_DECORATIVE = 80;
    int TRANSPARENT = 1;
    int OPAQUE = 2;
    int ALTERNATE = 1;
    int WINDING = 2;
    int TA_TOP = 0;
    int TA_BOTTOM = 8;
    int TA_BASELINE = 24;
    int TA_LEFT = 0;
    int TA_RIGHT = 2;
    int TA_CENTER = 6;
    int TA_NOUPDATECP = 0;
    int TA_UPDATECP = 1;
    int R2_BLACK = 1;
    int R2_NOTMERGEPEN = 2;
    int R2_MASKNOTPENNOT = 3;
    int R2_NOTCOPYPEN = 4;
    int R2_MASKPENNOT = 5;
    int R2_NOT = 6;
    int R2_XORPEN = 7;
    int R2_NOTMASKPEN = 8;
    int R2_MASKPEN = 9;
    int R2_NOTXORPEN = 10;
    int R2_NOP = 11;
    int R2_MERGENOTPEN = 12;
    int R2_COPYPEN = 13;
    int R2_MERGEPENNOT = 14;
    int R2_MERGEPEN = 15;
    int R2_WHITE = 16;
    int ETO_OPAQUE = 2;
    int ETO_CLIPPED = 4;
    int BLACKNESS = 66;
    int NOTSRCERASE = 0x1100a6;
    int NOTSRCCOPY = 0x330008;
    int SRCERASE = 0x440328;
    int DSTINVERT = 0x550009;
    int PATINVERT = 0x5a0049;
    int SRCINVERT = 0x660046;
    int SRCAND = 0x8800c6;
    int MERGEPAINT = 0xbb0226;
    int SRCCOPY = 0xcc0020;
    int SRCPAINT = 0xee0086;
    int PATCOPY = 0xf00021;
    int PATPAINT = 0xfb0a09;
    int WHITENESS = 0xff0062;
}
