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

package spark.components
{
import flash.events.MouseEvent;

import spark.components.IItemRenderer;
import mx.core.mx_internal;

/**
 *  The ButtonBarButton class defines the custom item renderer
 *  used by the ButtobBar control. 
 *  This item renderer is used in the ButtonBarSkin class, 
 *  the default skin for the ButtonBar.
 *
 *  @see spark.components.ButtonBar
 *  @see spark.skins.default.ButtonBarSkin
 *  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ButtonBarButton extends ToggleButton implements IItemRenderer
{
    /**
     *  Constructor. 
     */    
    public function ButtonBarButton()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  allowDeselection
    //----------------------------------

    /**
     *  @private
     *  Storage for the allowDeselection property 
     */
    private var _allowDeselection:Boolean = true;

    /**
     *  @inheritDoc 
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function get allowDeselection():Boolean
    {
        return _allowDeselection;
    }
    
    /**
     *  @private
     */    
    public function set allowDeselection(value:Boolean):void
    {
        _allowDeselection = value;
    }

    //----------------------------------
    //  caret
    //----------------------------------

    /**
     *  @private
     *  Storage for the caret property 
     */
    private var _caret:Boolean = false;

    /**
     *  @inheritDoc 
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function get caret():Boolean
    {
        return _caret;
    }
    
    /**
     *  @private
     */    
    public function set caret(value:Boolean):void
    {
        if (value == _caret)
            return;

        _caret = value;
        mx_internal::drawFocusAnyway = true;
        drawFocus(value);
    }

    //----------------------------------
    //  data
    //----------------------------------

    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get data():Object
    {
         return content;
    }

    /**
     *  @private 
     */
    public function set data(value:Object):void
    {
         content = value;
    }
    
    //----------------------------------
    //  labelText
    //----------------------------------
    
    /**
     *  @private 
     */
    private var _labelText:String = "";
    
    /**
     *  @inheritDoc  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get labelText():String
    {
        return _labelText;
    }
    
    /**
     *  @private 
     */
    public function set labelText(value:String):void
    {
        if (value != _labelText)
        {
            _labelText = value;
            if (labelElement)
                labelElement.text = _labelText;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    override protected function clickHandler(event:MouseEvent):void
    {
        if (selected && !allowDeselection)
            return;
        super.clickHandler(event);
    }
}

}