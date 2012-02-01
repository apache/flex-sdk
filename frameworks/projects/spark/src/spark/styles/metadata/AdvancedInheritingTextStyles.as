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
 *  Specifies a vertical or horizontal progression of line placement.
 * 
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.blockProgression.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#blockProgression
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="blockProgression", type="String", enumeration="tb,rl", inherit="yes")]

/**
 *  Controls where lines are allowed to break when breaking wrapping text into multiple 
 *  lines. 
 * 
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.breakOpportunity.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#breakOpportunity
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="breakOpportunity", type="String", enumeration="auto,all,any,none", inherit="yes")]

/**
 *  Controls how text wraps around a float.
 * 
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.clearFloats.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#clearFloats
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="clearFloats", type="String", enumeration="start,end,left,right,both,none", inherit="yes")]

/**
 *  Specifies the baseline position of the first line in the container.
 * 
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.firstBaselineOffset.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#firstBaselineOffset
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="firstBaselineOffset", type="Object", inherit="yes")]

/**
 *  Specifies the leading model, which is a combination of leading basis and leading 
 *  direction.
 * 
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.leadingModel.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#leadingModel
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="leadingModel", type="String", enumeration="auto,romanUp,ideographicTopUp,ideographicCenterUp,ideographicTopDown,ideographicCenterDown,ascentDescentUp,box", inherit="yes")]

/**
 *  This specifies an auto indent for the start edge of lists when the padding value of 
 *  the list on that side is <code>auto</code>.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.listAutoPadding.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#listAutoPadding
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="listAutoPadding", type="Number", format="length", inherit="yes", minValue="-1000", maxValue="1000")]

/**
 *  This controls the placement of a list item marker relative to the list item.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.listStylePosition.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#listStylePosition
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="listStylePosition", type="String", enumeration="inside,outside", inherit="yes")]

/**
 *  This controls the appearance of items in a list.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.listStyleType.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#listStyleType
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Style(name="listStyleType", type="String", enumeration="upperAlpha,lowerAlpha,upperRoman,lowerRoman,none,disc,circle,square,box,check,diamond,hyphen,arabicIndic,bengali,decimal,decimalLeadingZero,devanagari,gujarati,gurmukhi,kannada,persian,thai,urdu,cjkEarthlyBranch,cjkHeavenlyStem,hangul,hangulConstant,hiragana,hiraganaIroha,katakana,katakanaIroha,lowerGreek,lowerLatin,upperGreek,upperLatin", inherit="yes")]

/**
 *  The amount to indent the paragraph's end edge.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.paragraphEndIndent.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#paragraphEndIndent
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paragraphEndIndent", type="Number", format="length", inherit="yes", minValue="0.0")]

/**
 *  The amount of space to leave after the paragraph.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.paragraphSpaceAfter.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#paragraphSpaceAfter
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paragraphSpaceAfter", type="Number", format="length", inherit="yes", minValue="0.0")]

/**
 *  The amount of space to leave before the paragraph.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.paragraphSpaceBefore.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#paragraphSpaceBefore
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paragraphSpaceBefore", type="Number", format="length", inherit="yes", minValue="0.0")]

/**
 *  The amount to indent the paragraph's start edge.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.paragraphStartIndent.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#paragraphStartIndent
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="paragraphStartIndent", type="Number", format="length", inherit="yes")]

/**
 *  Specifies the tab stops associated with the paragraph.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.tabStops.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#tabStops
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="tabStops", type="String", inherit="yes")]

/**
 *  Offset of first line of text from the left side of the container.
 * .
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.textIndent.</b></p>
 *
 *  <p><b>For the Mobile theme, if using StyleableTextField,
 *  see spark.components.supportClasses.StyleableTextField Style textIndent,
 *  and if using StyleableStageText this is not supported.</b></p>
 *
 *  @see flashx.textLayout.formats.ITextLayoutFormat#textIndent
 *  @see spark.components.supportClasses.StyleableTextField#style:textIndent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textIndent", type="Number", format="Length", inherit="yes", minValue="0.0")]

/**
 *  Determines the number of degrees to rotate this text.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.textRotation.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#textRotation
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textRotation", type="String", enumeration="auto,rotate0,rotate90,rotate180,rotate270", inherit="yes")]

/**
 *  Collapses or preserves whitespace when importing text into a TextFlow.
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.whiteSpaceCollapse.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#whiteSpaceCollapse
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="whiteSpaceCollapse", type="String", enumeration="collapse,preserve", inherit="yes")]

/**
 *  Specifies the spacing between words to use during justification. 
 *  
 *  <p><b>For the Spark theme, see
 *  flashx.textLayout.formats.ITextLayoutFormat.wordSpacing.</b></p>
 *
 *  <p><b>For the Mobile theme, this is not supported.</b></p>
 * 
 *  @see flashx.textLayout.formats.ITextLayoutFormat#wordSpacing
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.5
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Style(name="wordSpacing", type="Object", inherit="yes")]
