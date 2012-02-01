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
import mx.core.UIFTETextField;
import mx.styles.IStyleClient;

import spark.components.IGridItemRenderer;

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
 *  @productversion Flex 4
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *   A simple and efficent IGridItemRenderer that displays a single text label.  This
 *   class is the default value for the s:DataGrid itemRenderer property.   It's based
 *   on FTE, the FlashTextEngine, It is based on FTE, the “FlashTextEngine”, which supports 
 *   high-quality international typography and font embedding in the same way as other 
 *   Spark controls.
 * 
 *   <p>Label text wrapping can be controlled with the lineBreak style.  For example
 *   a DataGrid configured like this:
 *   <code>lineBreak="explicit" variableRowHeight="false"</code> yields fixed height
 *   DataGrid cells whose labels do not wrap.</p>
 * 
 *   <p>DefaultGridItemRenderer is not intended to be subclassed or copied, it is
 *   effectively final.  Custom item renderers can be created in MXML with the 
 *   GridItemRenderer component.</p>
 * 
 *   @see spark.components.supportClasses.GridItemRenderer
 */
public class DefaultGridItemRenderer extends UIFTETextField implements IGridItemRenderer, IStyleClient
{
    
    public function DefaultGridItemRenderer()
    {
        super();
        
        autoSize = TextFieldAutoSize.NONE;
        inheritingStyles = StyleProtoChain.STYLE_UNINITIALIZED;
        nonInheritingStyles = StyleProtoChain.STYLE_UNINITIALIZED;
        
        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);
    }
    
include "TextFieldGridItemRendererInclude.as"

}
}