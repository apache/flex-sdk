////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

// Warning: the implementation of this class is identical to UITextFieldGridItemRenderer.
// Although most of the common code has been factored into the "IUITextFieldGridItemRenderer.as"
// include file, the imports metadata and other code below have been copied.  All changes 
// to this file should be mirrored by TextFieldGridItemRendererInclude.as.

package spark.skins.spark
{
import flash.text.TextFieldAutoSize;

import mx.core.UIFTETextField;
import mx.core.mx_internal;
import mx.styles.CSSMergedStyleDeclaration;
import mx.styles.IStyleClient;
import mx.styles.IStyleManager2;
import mx.styles.StyleManager;

import spark.components.gridClasses.GridItemRenderer;
import spark.components.gridClasses.IGridItemRenderer;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicNonInheritingTextStyles.as"
include "../../styles/metadata/BasicInheritingTextStyles.as"

// From AdvancedInheritingTextStyles.as
/**
 *  @copy flashx.textLayout.formats.ITextLayoutFormat#textIndent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="textIndent", type="Number", format="Length", inherit="yes", minValue="0.0")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the bindable <code>data</code> property changes.
 *
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

// From BasicInheritingTextStyles.as
// If ignorePadding is false (default=true), paddingLeft/paddingRight are used to set 
// the FTE leftMargin/rightMargin.  FTE paddingLeft/paddingRight are hard-coded.
[Exclude(name="paddingBottom", kind="style")]   // hard-coded in FTETextField
[Exclude(name="paddingTop", kind="style")]      // hard-coded in FTETextField
[Exclude(name="verticalAlign", kind="style")]   // not supported by renderer

// From BasicNonInheritingTextStyles.as
[Exclude(name="alignmentBaseline", kind="style")]
[Exclude(name="baselineShift", kind="style")]
[Exclude(name="cffHinting", kind="style")]
[Exclude(name="digitCase", kind="style")]
[Exclude(name="digitWidth", kind="style")]
[Exclude(name="dominantBaseline", kind="style")]
[Exclude(name="fontLookup", kind="style")]
[Exclude(name="justificationRule", kind="style")]
[Exclude(name="justificationStyle", kind="style")]
[Exclude(name="leading", kind="style")]         // hard-coded in FTETextField
[Exclude(name="ligatureLevel", kind="style")]
[Exclude(name="lineHeight", kind="style")]
[Exclude(name="lineThrough", kind="style")]
[Exclude(name="renderingMode", kind="style")]
[Exclude(name="textAlignLast", kind="style")]
[Exclude(name="textAlpha", kind="style")]
[Exclude(name="textJustify", kind="style")]
[Exclude(name="trackingLeft", kind="style")]
[Exclude(name="trackingRight", kind="style")]   // trackingRight in FTETextField set to letterSpacing
[Exclude(name="typographicCase", kind="style")]

// These must be inherited to work correctly.
[Exclude(name="layoutDirection", kind="property")]
[Exclude(name="layoutDirection", kind="style")]

// Make these properties act like styles.
[Exclude(name="direction", kind="property")]
[Exclude(name="locale", kind="property")]

/**
 *  The DefaultGridItemRenderer class defines simple and efficient 
 *  item renderer that displays a single text label.  
 *  This class is the default value for the DataGrid <code>itemRenderer</code> property. 
 *  This class extends UIFTETextField and displays the cell data in a text label using the text 
 *  field.
 *  The UIFTETextField control is based on FTE, the FlashTextEngine,  which supports 
 *  high-quality international typography and font embedding in the same way as other 
 *  Spark controls.
 *  Since the UIFTETextField control implements the TextField API, a subset of the
 *  Spark text styles are supported.
 *  Please see the documentation for this class for the list of supported styles.
 * 
 *  <p>You can control the label text wrapping by using the <code>lineBreak</code> style.  
 *  For example, setting  <code>lineBreak="explicit"</code> and <code>variableRowHeight="false"</code> 
 *  creates fixed height cells whose labels do not wrap.
 *  If you do not explicitly set the <code>wordWrap</code> property, <code>wordWrap</code> 
 *  will be set to the value of the grid's <code>variableRowHeight</code> property.</p>
 * 
 *  <p>The multiline property is used by the DataGrid's item editor to interpret
 *  input newline characters.  If <code>mutliline=false</code>, then entering a newline ends the 
 *  editing session (as does tab or escape).  If <code>multiline=true</code> then a newline character 
 *  is inserted into the text.  If the multiline property is not set explicitly, then it's automatically
 *  set to true if <code>lineBreak="explicit"</code> and <code>text</code> includes a newline
 *  character.</p>
 * 
 *  <p>DefaultGridItemRenderer inherits its <code>layoutDirection</code> property
 *  from its parent.  
 *  It should not be set directly.</p>
 *  
 *  <p>The DefaultGridItemRenderer class is not intended to be subclassed or copied.
 *  Create custom item renderers based on the GridItemRenderer class.</p>
 *
 *  <p>For the highest performance on Microsoft Windows based applications, 
 *  use the UITextFieldGridItemRenderer. 
 *  This renderer is written in ActionScript and optimized for Windows.</p>
 * 
 *  @see spark.components.DataGrid
 *  @see spark.components.gridClasses.GridItemRenderer
 *  @see spark.skins.spark.UITextFieldGridItemRenderer
 *  
 *  @includeExample examples/DefaultGridItemRendererExample.mxml
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class DefaultGridItemRenderer extends UIFTETextField implements IGridItemRenderer, IStyleClient
{
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public function DefaultGridItemRenderer()
    {
        super();
        
        autoSize = TextFieldAutoSize.NONE;
        inheritingStyles = StyleProtoChain.STYLE_UNINITIALIZED;
        nonInheritingStyles = StyleProtoChain.STYLE_UNINITIALIZED;
        
        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, GridItemRenderer.toolTipShowHandler);
    }
        
    /**
     * @private 
     * Convert this property to a style.  UIFTETextField will retrieve the
     * style and set the underlying property in FTETextField.
     */
    override public function set direction(value:String):void
    {
        setStyle("direction", value);
    }
    
    /**
     * @private 
     * Convert this property to a style.  UIFTETextField will retrieve the
     * style and set the underlying property in FTETextField.
     */
    override public function set locale(value:String):void
    {
        setStyle("locale", value);
    }

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        // Make this behave like a Spark Label which does not have a disabledColor style.
        // ToDo(cframpto):  Should be moved to setStyle or getStyle so in the very remote
        // chance the style is changed while the component is disabled the change will
        // take effect.
        if (!value && super.enabled)
            setStyle("disabledColor", getStyle("color"));        
        super.enabled = value;
    }
    
include "TextFieldGridItemRendererInclude.as"

}
}