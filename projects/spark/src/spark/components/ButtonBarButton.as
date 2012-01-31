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
import flash.events.Event;

import spark.components.IItemRenderer;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Dispatched when the <code>data</code> property changes.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 * 
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  The ButtonBarButton class defines the custom item renderer
 *  used by the ButtonBar control. 
 *  This item renderer is used in the ButtonBarSkin class, 
 *  the default skin for the ButtonBar.
 *
 *  @see spark.components.ButtonBar
 *  @see spark.skins.spark.ButtonBarSkin
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
     *  If <code>true</code>, the user click on a currently selected button to deselect it.
     *  If <code>false</code>, the user must select a different button 
     *  to deselect the currently selected button.
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
    //  showsCaret
    //----------------------------------

    /**
     *  @private
     *  Storage for the showsCaret property 
     */
    private var _showsCaret:Boolean = false;

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
    public function get showsCaret():Boolean
    {
        return _showsCaret;
    }
    
    /**
     *  @private
     */    
    public function set showsCaret(value:Boolean):void
    {
        if (value == _showsCaret)
            return;

        _showsCaret = value;
        drawFocusAnyway = true;
        drawFocus(value);
    }

    //----------------------------------
    //  dragging
    //----------------------------------

    /**
     *  @private  
     */
    public function get dragging():Boolean
    {
        return false;
    }

    /**
     *  @private  
     */
    public function set dragging(value:Boolean):void
    {
    }

    //----------------------------------
    //  data
    //----------------------------------

    [Bindable("dataChange")]
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
         dispatchEvent(new Event("dataChange"));
    }
    
    //----------------------------------
    //  itemIndex
    //----------------------------------
    
    /**
     *  @private
     *  storage for the itemIndex property 
     */    
    private var _itemIndex:int;
    
    /**
     *  @inheritDoc 
     *
     *  @default false
     */    
    public function get itemIndex():int
    {
        return _itemIndex;
    }
    
    /**
     *  @private
     */    
    public function set itemIndex(value:int):void
    {
        _itemIndex = value;
    }
    
    //----------------------------------
    //  label
    //----------------------------------
    
    /**
     *  @private 
     */
    private var _label:String = "";
    
    /**
     *  @inheritDoc  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private 
     */
    override public function set label(value:String):void
    {
        if (value != _label)
        {
            _label = value;

            if (labelDisplay)
                labelDisplay.text = _label;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden functions: ButtonBase
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */ 
    override protected function buttonReleased():void
    {
        if (selected && !allowDeselection)
            return;
        
        super.buttonReleased();
    }
}

}