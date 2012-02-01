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
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="alignmentBaseline", type="String", enumeration="useDominantBaseline,roman,ascent,descent,ideographicTop,ideographicCenter,ideographicBottom", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#baselineShift
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="baselineShift", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#cffHinting
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cffHinting", type="String", enumeration="horizontalStem,none", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#color
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="color", type="uint", format="Color", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#digitCase
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="digitCase", type="String", enumeration="default,lining,oldStyle", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#digitWidth
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="digitWidth", type="String", enumeration="default,proportional,tabular", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#direction
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="direction", type="String", enumeration="ltr,rtl", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#dominantBaseline
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="dominantBaseline", type="String", enumeration="auto,roman,ascent,descent,ideographicTop,ideographicCenter,ideographicBottom", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontFamily
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="fontFamily", type="String", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontLookup
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="fontLookup", type="String", enumeration="auto,device,embeddedCFF", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontSize
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="fontSize", type="Number", format="Length", inherit="yes", minValue="1.0", maxValue="720.0")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontStyle
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="fontStyle", type="String", enumeration="normal,italic", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#fontWeight
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="fontWeight", type="String", enumeration="normal,bold", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#justificationRule
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="justificationRule", type="String", enumeration="auto,space,eastAsian", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#justificationStyle
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="justificationStyle", type="String", enumeration="auto,prioritizeLeastAdjustment,pushInKinsoku,pushOutOnly", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#kerning
 *  
 *  <p>Kerning is enabled by default for Spark components, but is disabled by default for MX components.
 *  Spark components interpret <code>default</code> as <code>auto</code>, 
 *  while MX components interpret <code>default</code> as <code>false</code>.</p>
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="kerning", type="String", enumeration="auto,on,off", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#ligatureLevel
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="ligatureLevel", type="String", enumeration="common,minimum,uncommon,exotic", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#lineHeight
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="lineHeight", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#lineThrough
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="lineThrough", type="Boolean", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#locale
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="locale", type="String", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#renderingMode
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="renderingMode", type="String", enumeration="cff,normal", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlign
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textAlign", type="String", enumeration="start,end,left,right,center,justify", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlignLast
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textAlignLast", type="String", enumeration="start,end,left,right,center,justify", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textAlpha
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textAlpha", type="Number", inherit="yes", minValue="0.0", maxValue="1.0")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textDecoration
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textDecoration", type="String", enumeration="none,underline", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textJustify
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textJustify", type="String", enumeration="interWord,distribute", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#trackingLeft
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="trackingLeft", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#trackingRight
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="trackingRight", type="Object", inherit="yes")]

/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#typographicCase
 *  
 *  <p>TLF styles are not supported in the mobile theme.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="typographicCase", type="String", enumeration="default,capsToSmallCaps,uppercase,lowercase,lowercaseToSmallCaps", inherit="yes")]


/**
 *  Additional vertical space between lines of text.
 *
 *  <p>The default value is 0.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="leading", type="Number", format="Length", inherit="yes", theme="mobile")]

/**
 *  The number of additional pixels to appear between each character.
 *  A positive value increases the character spacing beyond the normal spacing,
 *  while a negative value decreases it.
 * 
 *  @default 0
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="letterSpacing", type="Number", inherit="yes", theme="mobile")]

/**
 *  Color of text shadows.
 * 
 *  @default #FFFFFF
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textShadowColor", type="uint", format="Color", inherit="yes", theme="mobile")]

/**
 *  Alpha of text shadows.
 * 
 *  @default 0.55
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textShadowAlpha", type="Number",inherit="yes", minValue="0.0", maxValue="1.0", theme="mobile")]
