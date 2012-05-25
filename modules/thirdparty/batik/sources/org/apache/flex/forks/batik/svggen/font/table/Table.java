/*

   Copyright 2001  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.svggen.font.table;

/**
 * @version $Id: Table.java,v 1.3 2004/08/18 07:15:22 vhardy Exp $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public interface Table {

    // Table constants
    public static final int BASE = 0x42415345; // Baseline data [OpenType]
    public static final int CFF  = 0x43464620; // PostScript font program (compact font format) [PostScript]
    public static final int DSIG = 0x44534947; // Digital signature
    public static final int EBDT = 0x45424454; // Embedded bitmap data
    public static final int EBLC = 0x45424c43; // Embedded bitmap location data
    public static final int EBSC = 0x45425343; // Embedded bitmap scaling data
    public static final int GDEF = 0x47444546; // Glyph definition data [OpenType]
    public static final int GPOS = 0x47504f53; // Glyph positioning data [OpenType]
    public static final int GSUB = 0x47535542; // Glyph substitution data [OpenType]
    public static final int JSTF = 0x4a535446; // Justification data [OpenType]
    public static final int LTSH = 0x4c545348; // Linear threshold table
    public static final int MMFX = 0x4d4d4658; // Multiple master font metrics [PostScript]
    public static final int MMSD = 0x4d4d5344; // Multiple master supplementary data [PostScript]
    public static final int OS_2 = 0x4f532f32; // OS/2 and Windows specific metrics [r]
    public static final int PCLT = 0x50434c54; // PCL5
    public static final int VDMX = 0x56444d58; // Vertical Device Metrics table
    public static final int cmap = 0x636d6170; // character to glyph mapping [r]
    public static final int cvt  = 0x63767420; // Control Value Table
    public static final int fpgm = 0x6670676d; // font program
    public static final int fvar = 0x66766172; // Apple's font variations table [PostScript]
    public static final int gasp = 0x67617370; // grid-fitting and scan conversion procedure (grayscale)
    public static final int glyf = 0x676c7966; // glyph data [r]
    public static final int hdmx = 0x68646d78; // horizontal device metrics
    public static final int head = 0x68656164; // font header [r]
    public static final int hhea = 0x68686561; // horizontal header [r]
    public static final int hmtx = 0x686d7478; // horizontal metrics [r]
    public static final int kern = 0x6b65726e; // kerning
    public static final int loca = 0x6c6f6361; // index to location [r]
    public static final int maxp = 0x6d617870; // maximum profile [r]
    public static final int name = 0x6e616d65; // naming table [r]
    public static final int prep = 0x70726570; // CVT Program
    public static final int post = 0x706f7374; // PostScript information [r]
    public static final int vhea = 0x76686561; // Vertical Metrics header
    public static final int vmtx = 0x766d7478; // Vertical Metrics

    // Platform IDs
    public static final short platformAppleUnicode = 0;
    public static final short platformMacintosh = 1;
    public static final short platformISO = 2;
    public static final short platformMicrosoft = 3;

    // Microsoft Encoding IDs
    public static final short encodingUndefined = 0;
    public static final short encodingUGL = 1;

    // Macintosh Encoding IDs
    public static final short encodingRoman = 0;
    public static final short encodingJapanese = 1;
    public static final short encodingChinese = 2;
    public static final short encodingKorean = 3;
    public static final short encodingArabic = 4;
    public static final short encodingHebrew = 5;
    public static final short encodingGreek = 6;
    public static final short encodingRussian = 7;
    public static final short encodingRSymbol = 8;
    public static final short encodingDevanagari = 9;
    public static final short encodingGurmukhi = 10;
    public static final short encodingGujarati = 11;
    public static final short encodingOriya = 12;
    public static final short encodingBengali = 13;
    public static final short encodingTamil = 14;
    public static final short encodingTelugu = 15;
    public static final short encodingKannada = 16;
    public static final short encodingMalayalam = 17;
    public static final short encodingSinhalese = 18;
    public static final short encodingBurmese = 19;
    public static final short encodingKhmer = 20;
    public static final short encodingThai = 21;
    public static final short encodingLaotian = 22;
    public static final short encodingGeorgian = 23;
    public static final short encodingArmenian = 24;
    public static final short encodingMaldivian = 25;
    public static final short encodingTibetan = 26;
    public static final short encodingMongolian = 27;
    public static final short encodingGeez = 28;
    public static final short encodingSlavic = 29;
    public static final short encodingVietnamese = 30;
    public static final short encodingSindhi = 31;
    public static final short encodingUninterp = 32;

    // ISO Encoding IDs
    public static final short encodingASCII = 0;
    public static final short encodingISO10646 = 1;
    public static final short encodingISO8859_1 = 2;

    // Microsoft Language IDs
    public static final short languageSQI = 0x041c;
    public static final short languageEUQ = 0x042d;
    public static final short languageBEL = 0x0423;
    public static final short languageBGR = 0x0402;
    public static final short languageCAT = 0x0403;
    public static final short languageSHL = 0x041a;
    public static final short languageCSY = 0x0405;
    public static final short languageDAN = 0x0406;
    public static final short languageNLD = 0x0413;
    public static final short languageNLB = 0x0813;
    public static final short languageENU = 0x0409;
    public static final short languageENG = 0x0809;
    public static final short languageENA = 0x0c09;
    public static final short languageENC = 0x1009;
    public static final short languageENZ = 0x1409;
    public static final short languageENI = 0x1809;
    public static final short languageETI = 0x0425;
    public static final short languageFIN = 0x040b;
    public static final short languageFRA = 0x040c;
    public static final short languageFRB = 0x080c;
    public static final short languageFRC = 0x0c0c;
    public static final short languageFRS = 0x100c;
    public static final short languageFRL = 0x140c;
    public static final short languageDEU = 0x0407;
    public static final short languageDES = 0x0807;
    public static final short languageDEA = 0x0c07;
    public static final short languageDEL = 0x1007;
    public static final short languageDEC = 0x1407;
    public static final short languageELL = 0x0408;
    public static final short languageHUN = 0x040e;
    public static final short languageISL = 0x040f;
    public static final short languageITA = 0x0410;
    public static final short languageITS = 0x0810;
    public static final short languageLVI = 0x0426;
    public static final short languageLTH = 0x0427;
    public static final short languageNOR = 0x0414;
    public static final short languageNON = 0x0814;
    public static final short languagePLK = 0x0415;
    public static final short languagePTB = 0x0416;
    public static final short languagePTG = 0x0816;
    public static final short languageROM = 0x0418;
    public static final short languageRUS = 0x0419;
    public static final short languageSKY = 0x041b;
    public static final short languageSLV = 0x0424;
    public static final short languageESP = 0x040a;
    public static final short languageESM = 0x080a;
    public static final short languageESN = 0x0c0a;
    public static final short languageSVE = 0x041d;
    public static final short languageTRK = 0x041f;
    public static final short languageUKR = 0x0422;

    // Macintosh Language IDs
    public static final short languageEnglish = 0;
    public static final short languageFrench = 1;
    public static final short languageGerman = 2;
    public static final short languageItalian = 3;
    public static final short languageDutch = 4;
    public static final short languageSwedish = 5;
    public static final short languageSpanish = 6;
    public static final short languageDanish = 7;
    public static final short languagePortuguese = 8;
    public static final short languageNorwegian = 9;
    public static final short languageHebrew = 10;
    public static final short languageJapanese = 11;
    public static final short languageArabic = 12;
    public static final short languageFinnish = 13;
    public static final short languageGreek = 14;
    public static final short languageIcelandic = 15;
    public static final short languageMaltese = 16;
    public static final short languageTurkish = 17;
    public static final short languageYugoslavian = 18;
    public static final short languageChinese = 19;
    public static final short languageUrdu = 20;
    public static final short languageHindi = 21;
    public static final short languageThai = 22;

    // Name IDs
    public static final short nameCopyrightNotice = 0;
    public static final short nameFontFamilyName = 1;
    public static final short nameFontSubfamilyName = 2;
    public static final short nameUniqueFontIdentifier = 3;
    public static final short nameFullFontName = 4;
    public static final short nameVersionString = 5;
    public static final short namePostscriptName = 6;
    public static final short nameTrademark = 7;

    /**
     * Get the table type, as a table directory value.
     * @return The table type
     */
    public int getType();
}
