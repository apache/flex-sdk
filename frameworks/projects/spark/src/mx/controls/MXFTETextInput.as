////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls
{

import mx.controls.listClasses.BaseListData;
import mx.core.IFlexModuleFactory;
import mx.core.ITextInput;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.TextInput;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the <code>data</code> property changes.
 *
 *  <p>When you use a component as an item renderer,
 *  the <code>data</code> property contains the data to display.
 *  You can listen for this event and update the component
 *  when the <code>data</code> property changes.</p>
 *
 *  @eventType mx.events.DATA_CHANGE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]


/**
 *  MXFTETextInput is a UIComponent which is used to support TLF text
 *  in Halo controls and data grid renderers.  It can be used in place
 *  of a Halo TextInput control.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public class MXFTETextInput extends TextInput implements ITextInput
{
    include "../../spark/core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function MXFTETextInput()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Used by showBorder to record the value of contentBackgroundAlpha
     *  before it is set to 0 so that it can be restored.
     */
    private var oldContentBackgroundAlpha:Number;
    

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  data
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the data property.
     */
    private var _data:Object;
    
    [Bindable("dataChange")]
    [Inspectable(environment="none")]
    
    /**
     *  Lets you pass a value to the component
     *  when you use it in an item renderer or item editor.
     *  You typically use data binding to bind a field of the <code>data</code>
     *  property to a property of this component.
     *
     *  <p>When you use the control as a drop-in item renderer or drop-in
     *  item editor, Flex automatically writes the current value of the item
     *  to the <code>text</code> property of this control.</p>
     *
     *  <p>You do not set this property in MXML.</p>
     *
     *  @default null
     *  @see mx.core.IDataRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get data():Object
    {
        return _data;
    }
    
    /**
     *  @private
     */
    public function set data(value:Object):void
    {
        var newText:*;
        
        _data = value;
        
        if (_listData)
        {
            newText = _listData.label;
        }
        else if (_data != null)
        {
            if (_data is String)
                newText = String(_data);
            else
                newText = _data.toString();
        }
        
        if (newText !== undefined)
            text = newText;
        
        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    

    //----------------------------------
    //  fontContext
    //----------------------------------

    /**
     *  Documentation is not currently available.
     */
    public function get fontContext():IFlexModuleFactory
    {
        return null;
    }

    /**
     *  @private
     */
    public function set fontContext(value:IFlexModuleFactory):void
    {
        // not used for DefineFont4
    }

    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
    
    /**
     *  Documentation is not currently available.
     */
    public function get horizontalScrollPosition():Number
    {
        return textDisplay ? textDisplay.horizontalScrollPosition : 0;
    }

    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void
    {
        if (textDisplay)
            textDisplay.horizontalScrollPosition = value;
    }

    //----------------------------------
    //  listData
    //----------------------------------
    
    private var _listData:BaseListData;
    
    [Bindable("dataChange")]
    [Inspectable(environment="none")]
    
    /**
     *  When a component is used as a drop-in item renderer or drop-in
     *  item editor, Flex initializes the <code>listData</code> property
     *  of the component with the appropriate data from the list control.
     *  The component can then use the <code>listData</code> property
     *  to initialize the <code>data</code> property of the drop-in
     *  item renderer or drop-in item editor.
     *
     *  <p>You do not set this property in MXML or ActionScript;
     *  Flex sets it when the component is used as a drop-in item renderer
     *  or drop-in item editor.</p>
     *
     *  @default null
     *  @see mx.controls.listClasses.IDropInListItemRenderer
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get listData():BaseListData
    {
        return _listData;
    }
    
    /**
     *  @private
     */
    public function set listData(value:BaseListData):void
    {
        _listData = value;
    }
    
    //----------------------------------
    //  parentDrawsFocus
    //----------------------------------

    private var _parentDrawsFocus:Boolean = false;

    /**
     *  Documentation is not currently available.
     */
    public function get parentDrawsFocus():Boolean
    {
        return _parentDrawsFocus;
    }
    
    /**
     *  @private
     */
    public function set parentDrawsFocus(value:Boolean):void
    {
        _parentDrawsFocus = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  border
    //----------------------------------
    
    /**
     *  Used to determine if the control's border and background are 
     *  visible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function showBorderAndBackground(visible:Boolean):void
    {
        // Hide everything in TextInputSkin except the textDisplay and
        // the contentFill by setting borderVisible to false.
        setStyle("borderVisible", visible);

        var contentBackgroundAlpha:Number = getStyle("contentBackgroundAlpha");
        
        // Hide background/contentFill of TextInput by setting 
        // contentBackgroundAlpha to 0.
        if (!visible)
        {
            if (isNaN(contentBackgroundAlpha)||contentBackgroundAlpha != 0)
            {
                // Save old value so it can be restored when visible again.
                oldContentBackgroundAlpha = getStyle("contentBackgroundAlpha");
                setStyle("contentBackgroundAlpha", 0);
            }
        }
        else if (!isNaN(oldContentBackgroundAlpha))
        {
            setStyle("contentBackgroundAlpha", oldContentBackgroundAlpha);
            oldContentBackgroundAlpha = NaN;
        }
    }    

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Forward the drawFocus to the parent, if requested
     */
    override public function drawFocus(isFocused:Boolean):void
    {
        if (_parentDrawsFocus)
        {
            IFocusManagerComponent(parent).drawFocus(isFocused);
            return;
        }

        super.drawFocus(isFocused);
    }
    
}

}
