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
    //  IStyleClient Methods and Properties
    //  (source code from mx.controls.dataGridClassses.DataGridItemRenderer.as)
    //
    //-------------------------------------------------------------------------- 
    
    //----------------------------------
    //  styleDeclaration
    //----------------------------------
    
    private var _styleDeclaration:CSSStyleDeclaration;
    
    /**
     *  @private
     */
    public function get styleDeclaration():CSSStyleDeclaration
    {
        return _styleDeclaration;
    }
    
    /**
     *  @private
     */
    public function set styleDeclaration(value:CSSStyleDeclaration):void
    {
        // The "direction" and "locale" are treated as properites instead of
        // styles by the compiler when the DefaultGridItemRenderer is used. 
        // This means styleDeclaration will not include these inline styles. 
        // This code adds "direction" and "locale" back into styleDeclaration
        // so the style system sees the styles.
        var uiFTETextField:UIFTETextField = UIFTETextField(this);
        var styleManager:IStyleManager2 = StyleManager.getStyleManager(moduleFactory);
        var style:CSSStyleDeclaration = new CSSStyleDeclaration(value.selector, styleManager);
        
        style.defaultFactory = function():void
        {
            this.direction = uiFTETextField.direction;
            this.locale = uiFTETextField.locale;
        }
        
        _styleDeclaration = new CSSMergedStyleDeclaration(style, value, value.selector, 
            styleManager);
    }
    
include "TextFieldGridItemRendererInclude.as"

}
}