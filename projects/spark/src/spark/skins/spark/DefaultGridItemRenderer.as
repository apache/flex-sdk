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
import mx.styles.CSSMergedStyleDeclaration;
import mx.styles.IStyleClient;
import mx.styles.IStyleManager2;
import mx.styles.StyleManager;

import spark.components.gridClasses.IGridItemRenderer;

//--------------------------------------
//  Styles
//--------------------------------------

include "../../styles/metadata/BasicNonInheritingTextStyles.as"
include "../../styles/metadata/BasicInheritingTextStyles.as"

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
 *  This class displays the cell data in a text label using the UIFTETextField control.
 *  It is based on FTE, the FlashTextEngine,  which supports 
 *  high-quality international typography and font embedding in the same way as other 
 *  Spark controls.
 *
 *  <p>DefaultGridItemRenderer inherits its <code>layoutDirection</code> property
 *  from its parent.  
 *  It should not be set directly.</p>
 *
 *  <p>You can control the label text wrapping by using the <code>lineBreak</code> style.  
 *  For example, setting  <code>lineBreak="explicit"</code> and <code>variableRowHeight="false"</code> 
 *  creates fixed height cells whose labels do not wrap.</p>
 *  
 *  <p>The DefaultGridItemRenderer class is not intended to be subclassed or copied.
 *  Create custom item renderers based on the  GridItemRenderer class.</p>
 *
 *  <p>For the highest performance on Microsoft Windows based applications, 
 *  use the UITextFieldGridItemRenderer. 
 *  This renderer is written in ActionScript and optimized for Windows.</p>
 * 
 *  @see spark.components.DataGrid
 *  @see spark.components.gridClasses.GridItemRenderer
 *  @see UITextFieldGridItemRenderer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class DefaultGridItemRenderer extends UIFTETextField implements IGridItemRenderer, IStyleClient
{
    
    //--------------------------------------------------------------------------
    //
    //  Constructor.
    //
    //--------------------------------------------------------------------------
    
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
        
        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);
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

include "TextFieldGridItemRendererInclude.as"

}
}