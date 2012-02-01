////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#alignmentBaseline
 */
[Style(name="alignmentBaseline", type="String", enumeration="useDominantBaseline,roman,ascent,descent,ideographicTop,ideographicCenter,ideographicBottom", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#baselineShift
 */
[Style(name="baselineShift", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#breakOpportunity
 */
[Style(name="breakOpportunity", type="String", enumeration="auto,all,any,none", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#cffHinting
 */
[Style(name="cffHinting", type="String", enumeration="horizontalStem,none", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#color
 */
[Style(name="color", type="uint", format="Color", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#digitCase
 */
[Style(name="digitCase", type="String", enumeration="default,lining,oldStyle", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#digitWidth
 */
[Style(name="digitWidth", type="String", enumeration="default,proportional,tabular", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#direction
 */
[Style(name="direction", type="String", enumeration="ltr,rtl", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#dominantBaseline
 */
[Style(name="dominantBaseline", type="String", enumeration="auto,roman,ascent,descent,ideographicTop,ideographicCenter,ideographicBottom", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontFamily
 */
[Style(name="fontFamily", type="String", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontLookup
 */
[Style(name="fontLookup", type="String", enumeration="device,embeddedCFF", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontSize
 */
[Style(name="fontSize", type="Number", format="Length", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontStyle
 */
[Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontWeight
 */
[Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#justificationRule
 */
[Style(name="justificationRule", type="String", enumeration="auto,space,eastAsian", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#justificationStyle
 */
[Style(name="justificationStyle", type="String", enumeration="auto,prioritizeLeastAdjustment,pushInKinsoku,pushOutOnly", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#kerning
 */
[Style(name="kerning", type="String", enumeration="on,off,auto", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#ligatureLevel
 */
[Style(name="ligatureLevel", type="String", enumeration="common,uncommon,exotic,minimum", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#lineBreak 
 */
[Style(name="lineBreak", type="String", enumeration="toFit,explicit", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#lineHeight
 */
[Style(name="lineHeight", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#lineThrough
 */
[Style(name="lineThrough", type="Boolean", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#locale
 */
[Style(name="locale", type="String", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingBottom
 */
[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingLeft
 */
[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingRight
 */
[Style(name="paddingRight", type="Number", format="Length", inherit="no")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#paddingTop
 */
[Style(name="paddingTop", type="Number", format="Length", inherit="no")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#renderingMode
 */
[Style(name="renderingMode", type="String", enumeration="cff,normal", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlign
 */
[Style(name="textAlign", type="String", enumeration="start,end,left,right,center,justify", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlignLast
 */
[Style(name="textAlignLast", type="String", enumeration="start,end,left,right,center,justify", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlpha
 */
[Style(name="textAlpha", type="Number", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textDecoration
 */
[Style(name="textDecoration", type="String", enumeration="none,underline", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textJustify
 */
[Style(name="textJustify", type="String", enumeration="interWord,distribute", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textRotation
 */
[Style(name="textRotation", type="String", enumeration="auto,rotate0,rotate90,rotate180,rotate270", inherit="yes")]

/**
 *  Space added to the advance after each character, as a percentage of the current point size. Percentages can be negative, 
 *  to bring characters closer together. The default value is 0.
 */
[Style(name="tracking", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#trackingLeft
 */
[Style(name="trackingLeft", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#trackingRight
 */
[Style(name="trackingRight", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#typographicCase
 */
[Style(name="typographicCase", type="String", enumeration="default,title,caps,smallCaps,uppercase,lowercase,capsAndSmallCaps", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#verticalAlign
 */
[Style(name="verticalAlign", type="String", enumeration="top,middle,bottom,justify", inherit="no")]
