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
import mx.core.mx_internal;
import mx.styles.IStyleClient;

import spark.components.gridClasses.GridItemRenderer;
import spark.components.gridClasses.IGridItemRenderer;

use namespace mx_internal;

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
 *  @playerversion AIR 2.0
 *  @productversion Flex 4.5
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

// These must be inherited to work correctly.

[Exclude(name="layoutDirection", kind="property")]
[Exclude(name="layoutDirection", kind="style")]

/**
 *  The UITextFieldGridItemRenderer class defines simple and efficient 
 *  item renderer that displays a single text label.  
 *  For applications displaying grid controls with large numbers of visible cells, 
 *  this renderer provides optimum performance on Microsoft Windows.   
 *  It is based on TextField, not the Flash Text Engine (FTE), so it lacks support for 
 *  some Spark text features and it does not support the FTE specific text styles.
 *
 *  <p>You can control the label text wrapping by using the <code>wordWrap</code> property.  
 *  For example, setting <code>wordWrap="false"</code> and <code>variableRowHeight="false"</code> 
 *  creates fixed height cells whose labels do not wrap.  
 *  If you do not explicitly set the <code>wordWrap</code> property, <code>wordWrap</code> 
 *  will be set to the value of the grid's <code>variableRowHeight</code> property.</p>
 * 
 *  <p>UITextFieldGridItemRenderer inherits its the value of the 
 *  <code>layoutDirection</code> property from its parent.  
 *  It should not be set directly on UITextFieldGridItemRenderer.</p> 
 * 
 *  <p>The UITextFieldGridItemRenderer class is not intended to be subclassed or copied.
 *  Create custom item renderers based on the GridItemRenderer class.</p>
 * 
 *  @see spark.components.DataGrid
 *  @see spark.components.gridClasses.GridItemRenderer
 *  @see spark.skins.spark.DefaultGridItemRenderer
 *  @see mx.core.FTETextField
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class UITextFieldGridItemRenderer extends UITextField implements IGridItemRenderer, IStyleClient
{
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.0
     *  @productversion Flex 4.5
     */
    public function UITextFieldGridItemRenderer()
    {
        super();
        
        autoSize = TextFieldAutoSize.NONE;
        
        addEventListener(ToolTipEvent.TOOL_TIP_SHOW, GridItemRenderer.toolTipShowHandler);        
    }
        
include "TextFieldGridItemRendererInclude.as"

}
}