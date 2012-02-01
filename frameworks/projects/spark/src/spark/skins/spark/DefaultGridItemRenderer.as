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
 *   A simple and efficient IGridItemRenderer that displays a single text label.  This
 *   class is the default value for the s:DataGrid itemRenderer property.   It's based
 *   on FTE, the FlashTextEngine, It is based on FTE, the “FlashTextEngine”, which supports 
 *   high-quality international typography and font embedding in the same way as other 
 *   Spark controls.
 * 
 *   <p>DefaultGridItemRenderer will inherit its <code>layoutDirection</code> 
 *   from its parent.  It should not be set directly on 
 *   DefaultGridItemRenderer.</p>
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
 *   @see spark.components.gridClasses.GridItemRenderer
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
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Hold the property to style conversions that getStyle() should use.
     *  Since setStyle() in UIFTETextField is a no-op, getStyle() will look here
     *  for a "pseudo style" before looking for the real styles.  See notes 
     *  on direction and locale properties.
     */
    private var pseudoStyles:Object;

    //----------------------------------
    //  direction
    //----------------------------------
    
    /**
     * @private 
     * This is a property in FTETextField so if set in mxml the property
     * rather than the style is set.  UIFTETextField will overwrite the
     * property with the value of the "direction" style so convert the property
     * to a style.
     */
    override public function set direction(value:String):void
    {
        if (!pseudoStyles)
            pseudoStyles = {};
        pseudoStyles["direction"] = value;
    }
    
    //----------------------------------
    //  locale
    //----------------------------------
    
    /**
     * @private 
     * This is a property in FTETextField so if set in mxml the property
     * rather than the style is set.  UIFTETextField will overwrite the
     * property with the value of the "locale" style so convert the property
     * to a style.
     */
    override public function set locale(value:String):void
    {
        if (!pseudoStyles)
            pseudoStyles = {};
        pseudoStyles["locale"] = value;
    }

    /**
     * @private
     */ 
    override public function getStyle(styleProp:String):*
    {
        if (pseudoStyles && pseudoStyles[styleProp] !== undefined)
            return pseudoStyles[styleProp];
        
        return super.getStyle(styleProp);
    }
    
    
include "TextFieldGridItemRendererInclude.as"

}
}