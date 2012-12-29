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
package org.apache.flex.forks.batik.svggen.font.table;

/**
 * @version $Id: Table.java 478176 2006-11-22 14:50:50Z dvholten $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public interface Table {

    // Table constants
    int BASE = 0x42415345; // Baseline data [OpenType]
    int CFF  = 0x43464620; // PostScript font program (compact font format) [PostScript]
    int DSIG = 0x44534947; // Digital signature
    int EBDT = 0x45424454; // Embedded bitmap data
    int EBLC = 0x45424c43; // Embedded bitmap location data
    int EBSC = 0x45425343; // Embedded bitmap scaling data
    int GDEF = 0x47444546; // Glyph definition data [OpenType]
    int GPOS = 0x47504f53; // Glyph positioning data [OpenType]
    int GSUB = 0x47535542; // Glyph substitution data [OpenType]
    int JSTF = 0x4a535446; // Justification data [OpenType]
    int LTSH = 0x4c545348; // Linear threshold table
    int MMFX = 0x4d4d4658; // Multiple master font metrics [PostScript]
    int MMSD = 0x4d4d5344; // Multiple master supplementary data [PostScript]
    int OS_2 = 0x4f532f32; // OS/2 and Windows specific metrics [r]
    int PCLT = 0x50434c54; // PCL5
    int VDMX = 0x56444d58; // Vertical Device Metrics table
    int cmap = 0x636d6170; // character to glyph mapping [r]
    int cvt  = 0x63767420; // Control Value Table
    int fpgm = 0x6670676d; // font program
    int fvar = 0x66766172; // Apple's font variations table [PostScript]
    int gasp = 0x67617370; // grid-fitting and scan conversion procedure (grayscale)
    int glyf = 0x676c7966; // glyph data [r]
    int hdmx = 0x68646d78; // horizontal device metrics
    int head = 0x68656164; // font header [r]
    int hhea = 0x68686561; // horizontal header [r]
    int hmtx = 0x686d7478; // horizontal metrics [r]
    int kern = 0x6b65726e; // kerning
    int loca = 0x6c6f6361; // index to location [r]
    int maxp = 0x6d617870; // maximum profile [r]
    int name = 0x6e616d65; // naming table [r]
    int prep = 0x70726570; // CVT Program
    int post = 0x706f7374; // PostScript information [r]
    int vhea = 0x76686561; // Vertical Metrics header
    int vmtx = 0x766d7478; // Vertical Metrics

    // Platform IDs
    short platformAppleUnicode = 0;
    short platformMacintosh = 1;
    short platformISO = 2;
    short platformMicrosoft = 3;

    // Microsoft Encoding IDs
    short encodingUndefined = 0;
    short encodingUGL = 1;

    // Macintosh Encoding IDs
    short encodingRoman = 0;
    short encodingJapanese = 1;
    short encodingChinese = 2;
    short encodingKorean = 3;
    short encodingArabic = 4;
    short encodingHebrew = 5;
    short encodingGreek = 6;
    short encodingRussian = 7;
    short encodingRSymbol = 8;
    short encodingDevanagari = 9;
    short encodingGurmukhi = 10;
    short encodingGujarati = 11;
    short encodingOriya = 12;
    short encodingBengali = 13;
    short encodingTamil = 14;
    short encodingTelugu = 15;
    short encodingKannada = 16;
    short encodingMalayalam = 17;
    short encodingSinhalese = 18;
    short encodingBurmese = 19;
    short encodingKhmer = 20;
    short encodingThai = 21;
    short encodingLaotian = 22;
    short encodingGeorgian = 23;
    short encodingArmenian = 24;
    short encodingMaldivian = 25;
    short encodingTibetan = 26;
    short encodingMongolian = 27;
    short encodingGeez = 28;
    short encodingSlavic = 29;
    short encodingVietnamese = 30;
    short encodingSindhi = 31;
    short encodingUninterp = 32;

    // ISO Encoding IDs
    short encodingASCII = 0;
    short encodingISO10646 = 1;
    short encodingISO8859_1 = 2;

    // Microsoft Language IDs
    short languageSQI = 0x041c;
    short languageEUQ = 0x042d;
    short languageBEL = 0x0423;
    short languageBGR = 0x0402;
    short languageCAT = 0x0403;
    short languageSHL = 0x041a;
    short languageCSY = 0x0405;
    short languageDAN = 0x0406;
    short languageNLD = 0x0413;
    short languageNLB = 0x0813;
    short languageENU = 0x0409;
    short languageENG = 0x0809;
    short languageENA = 0x0c09;
    short languageENC = 0x1009;
    short languageENZ = 0x1409;
    short languageENI = 0x1809;
    short languageETI = 0x0425;
    short languageFIN = 0x040b;
    short languageFRA = 0x040c;
    short languageFRB = 0x080c;
    short languageFRC = 0x0c0c;
    short languageFRS = 0x100c;
    short languageFRL = 0x140c;
    short languageDEU = 0x0407;
    short languageDES = 0x0807;
    short languageDEA = 0x0c07;
    short languageDEL = 0x1007;
    short languageDEC = 0x1407;
    short languageELL = 0x0408;
    short languageHUN = 0x040e;
    short languageISL = 0x040f;
    short languageITA = 0x0410;
    short languageITS = 0x0810;
    short languageLVI = 0x0426;
    short languageLTH = 0x0427;
    short languageNOR = 0x0414;
    short languageNON = 0x0814;
    short languagePLK = 0x0415;
    short languagePTB = 0x0416;
    short languagePTG = 0x0816;
    short languageROM = 0x0418;
    short languageRUS = 0x0419;
    short languageSKY = 0x041b;
    short languageSLV = 0x0424;
    short languageESP = 0x040a;
    short languageESM = 0x080a;
    short languageESN = 0x0c0a;
    short languageSVE = 0x041d;
    short languageTRK = 0x041f;
    short languageUKR = 0x0422;

    // Macintosh Language IDs
    short languageEnglish = 0;
    short languageFrench = 1;
    short languageGerman = 2;
    short languageItalian = 3;
    short languageDutch = 4;
    short languageSwedish = 5;
    short languageSpanish = 6;
    short languageDanish = 7;
    short languagePortuguese = 8;
    short languageNorwegian = 9;
    short languageHebrew = 10;
    short languageJapanese = 11;
    short languageArabic = 12;
    short languageFinnish = 13;
    short languageGreek = 14;
    short languageIcelandic = 15;
    short languageMaltese = 16;
    short languageTurkish = 17;
    short languageYugoslavian = 18;
    short languageChinese = 19;
    short languageUrdu = 20;
    short languageHindi = 21;
    short languageThai = 22;

    // Name IDs
    short nameCopyrightNotice = 0;
    short nameFontFamilyName = 1;
    short nameFontSubfamilyName = 2;
    short nameUniqueFontIdentifier = 3;
    short nameFullFontName = 4;
    short nameVersionString = 5;
    short namePostscriptName = 6;
    short nameTrademark = 7;

    /**
     * Get the table type, as a table directory value.
     * @return The table type
     */
    int getType();
}
