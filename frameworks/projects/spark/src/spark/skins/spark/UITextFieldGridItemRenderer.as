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

// Warning: the implementation of this class is identical to DefaultGridItemRenderer.
// Although most of the common code has been factored into the "TextFieldGridItemRendererInclude.as"
// include file, the imports metadata and other code below have been copied.  All changes 
// to this file should be mirrored by DefaultGridItemRenderer.as.

package spark.skins.spark
{
import flash.text.TextFieldAutoSize;

import mx.core.UITextField;
import mx.styles.IStyleClient;

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
 *  @productversion Flex 4
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

// These must be inherited to work correctly.

[Exclude(name="layoutDirection", kind="property")]
[Exclude(name="layoutDirection", kind="style")]

/**
 *   A simple and efficient IGridItemRenderer that displays a single text label.  For 
 *   applications displaying Grids with large numbers of visible cells, this renderer
 *   provides optimum performance on Windows.   It is based on TextField, not FTE, 
 *   so it lacks support for some Spark text features.
 * 
 *   <p>UITextFieldGridItemRenderer will inherit its 
 *   <code>layoutDirection</code> from its parent.  
 *   It should not be set directly on UITextFieldGridItemRenderer.</p>
 *
 *   <p>Label text wrapping can be controlled with the lineBreak style.  For example
 *   a DataGrid configured like this:
 *   <code>lineBreak="explicit" variableRowHeight="false"</code> yields fixed height
 *   DataGrid cells whose labels do not wrap.</p>
 * 
 *   <p>This class is not intended to be subclassed or copied, it is
 *   effectively final.  Custom item renderers can be created in MXML with the 
 *   GridItemRenderer component.</p>
 * 
 *   @see spark.components.gridClasses.GridItemRenderer
 */
public class UITextFieldGridItemRenderer extends UITextField implements IGridItemRenderer, IStyleClient
{
    
    public function UITextFieldGridItemRenderer()
    {
        super();
        
        autoSize = TextFieldAutoSize.NONE;
        
        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, toolTipShowHandler);        
    }
    
include "TextFieldGridItemRendererInclude.as"

}
}