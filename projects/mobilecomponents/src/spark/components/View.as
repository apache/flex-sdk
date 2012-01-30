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

package spark.components
{
import mx.core.IDataRenderer;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;

import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the <code>data</code> property changes.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 * 
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the current view has been activated.
 * 
 *  @eventType mx.events.FlexEvent.VIEW_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="viewActivate", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the current view has been deactivated.
 * 
 *  @eventType mx.events.FlexEvent.VIEW_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="viewDeactivate", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the screen is about to be removed in response
 *  to a screen change.  Calling <code>preventDefault()</code> 
 *  while handling this event will cancel the screen change.
 * 
 *  @eventType mx.events.FlexEvent.REMOVING
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="removing", type="mx.events.FlexEvent")]


/**
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class View extends Group implements IDataRenderer
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function View()
    {
        super();
        
        // By default, a view should extend the entire bounds of its parent
        percentWidth = 100;
        percentHeight = 100;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  active
    //----------------------------------
    
    private var _active:Boolean = false;
    
    /**
     *  Flag indicating whether the current screen is active.  The
     *  view's navigator will automatically set this flag to true
     *  or false as its state changes.  This getter will dispatch
     *  <code>FlexEvent.VIEW_ACTIVATE<code> and <code>FlexEvent.VIEW_DEACTIVATE<code>
     *  as the value changes.
     *  
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get active() : Boolean
    {
        return _active;
    }
    
    /**
     * @private
     */
    public function set active(value:Boolean) : void
    {
        if (_active != value)
        {
            _active = value;
            
            var eventName:String = _active ? FlexEvent.VIEW_ACTIVATE : FlexEvent.VIEW_DEACTIVATE;
            if (hasEventListener(eventName))
                dispatchEvent(new FlexEvent(eventName));
        }
    }

    //----------------------------------
    //  canRemove
    //----------------------------------
    
    /**
     *  @private
     * 
     *  Determines if the current view can be removed by
     *  a navigator.  The default implementation dispatches
     *  a <code>FlexEvent.REMOVING</code> event.  If
     *  preventDefault() is called on the event, this property
     *  will be set to false.
     * 
     *  @return Returns true if the screen can be removed
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    mx_internal function get canRemove():Boolean
    {
        if (hasEventListener(FlexEvent.REMOVING))
        {
            var event:FlexEvent = new FlexEvent(FlexEvent.REMOVING, false, true);
            return dispatchEvent(event);
        }
        
        return true;
    }
    
    //----------------------------------
    //  overlayControls
    //----------------------------------
    
    private var _overlayControls:Boolean = false;
    
    /**
     *  Determines the way the view's navigator's ui controls
     *  should lay out in relation to the view content.  If
     *  set to true, the ui controls will hover on top of the
     *  view.
     *  
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get overlayControls():Boolean
    {
        return _overlayControls;
    }
    
    /**
     *  @private
     */
    public function set overlayControls(value:Boolean):void
    {
        if (_overlayControls != value)
        {
            _overlayControls = value;
            
            if (navigator)
                navigator.overlayControls = _overlayControls;
        }
    }
    
    //----------------------------------
    //  desctructionPolicy
    //----------------------------------
    
    private var _destructionPolicy:String = "auto";
    
    /**
     *  Defines the destruction policy the view's navigator should use
     *  when this view is removed. If set to "auto", the navigator will
     *  destroy the view when it isn't active.  If set to "none", the
     *  view will be cached in memory.
     * 
     *  @default auto
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get destructionPolicy():String
    {
        return _destructionPolicy;
    }
    
    /**
     *  @private
     */
    public function set destructionPolicy(value:String):void
    {
        _destructionPolicy = value;	
    }
    
    //----------------------------------
    //  navigator
    //----------------------------------
    
    private var _navigator:ViewNavigator;
    
    [Bindable]
    /**
     * The view's navigator.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigator():ViewNavigator
    {
        return _navigator;
    }
    
    public function set navigator(value:ViewNavigator):void
    {
        if (_navigator != value)
            _navigator = value;
    }
    
    //----------------------------------
    //  returnedObject
    //----------------------------------
    
    private var _returnedObject:Object;
    
    /**
     *  An object that was returned by the previous view when
     *  the navigator is popping back to this view. 
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    [Bindable]
    public function get returnedObject():Object
    {
        return _returnedObject;
    }
    
    /**
     *  @private
     */ 
    public function set returnedObject(value:Object):void
    {
        _returnedObject = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  UI Template Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionContent
    //----------------------------------
    
    private var _actionContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  actionContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionContent():Array
    {
        return _actionContent;
    }
    /**
     *  @private
     */
    public function set actionContent(value:Array):void
    {
        var changeEvent:PropertyChangeEvent = 
            PropertyChangeEvent.createUpdateEvent(this, "actionContent", _actionContent, value);
        
        _actionContent = value;
        dispatchEvent(changeEvent);
    }
    
    //----------------------------------
    //  actionGroupLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar's action content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _actionGroupLayout:LayoutBase;
    
    public function get actionGroupLayout():LayoutBase
    {
        return _actionGroupLayout;
    }
    /**
     *  @private
     */
    public function set actionGroupLayout(value:LayoutBase):void
    {
        var changeEvent:PropertyChangeEvent = 
            PropertyChangeEvent.createUpdateEvent(this, "actionGroupLayout", _actionGroupLayout, value);
        
        _actionGroupLayout = value;
        dispatchEvent(changeEvent);
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    private var _navigationContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  navigationContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationContent():Array
    {
        return _navigationContent;
    }
    /**
     *  @private
     */
    public function set navigationContent(value:Array):void
    {
        var changeEvent:PropertyChangeEvent = 
            PropertyChangeEvent.createUpdateEvent(this, "navigationContent", _navigationContent, value);
        
        _navigationContent = value;
        dispatchEvent(changeEvent);
    }
    
    //----------------------------------
    //  navigationGroupLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar navigation content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _navigationGroupLayout:LayoutBase;
    
    public function get navigationGroupLayout():LayoutBase
    {
        return _navigationGroupLayout;
    }
    /**
     *  @private
     */
    public function set navigationGroupLayout(value:LayoutBase):void
    {
        var changeEvent:PropertyChangeEvent = 
            PropertyChangeEvent.createUpdateEvent(this, "navigationGroupLayout", _navigationGroupLayout, value);
        
        _navigationGroupLayout = value;
        dispatchEvent(changeEvent);
    }
	
	//----------------------------------
	//  showActionBar
	//----------------------------------
	private var _showActionBar:Boolean = true;
	
	/**
	 *  Flag indicating whether a view should show the action bar or not.
	 *  This doesn't necessarily correlate to the visible property of the
	 *  navigator's ActionBar.  In the end, ViewNavigator and the developer
	 *  have the last say as to what's visible.
	 *
	 *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
	 */
	public function get showActionBar():Boolean
	{
		return _showActionBar;
	}
    
    /**
     *  @private
     */ 
	public function set showActionBar(value:Boolean):void
	{
		_showActionBar = value;
		
		// Immediately request actionBar's visibility be toggled
		if (active && navigator)
		{
			if (_showActionBar)
				navigator.showActionBar();
			else
				navigator.hideActionBar();
		}
	}
	//----------------------------------
	//  showTabBar
	//----------------------------------
	private var _showTabBar:Boolean = true;
	
	/**
	 *  Flag indicating whether a view should show the action bar or not.
	 *  This doesn't necessarily correlate to the visible property of the
	 *  navigator's ActionBar.  In the end, ViewNavigator and the developer
	 *  have the last say as to what's visible.
	 *
	 *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
	 */
	public function get showTabBar():Boolean
	{
		return _showTabBar;
	}
    
    /**
     *  @private
     */
	public function set showTabBar(value:Boolean):void
	{
		_showTabBar = value;
		
		// Immediately request actionBar's visibility be toggled
		if (active && navigator)
		{
			if (_showTabBar)
				navigator.showTabBar();
			else
				navigator.hideTabBar();
		}
	}
	
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String;
    
    [Bindable]
    /**
     *  The title for the view.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get title():String
    {
        return _title;
    }
    
    /**
     *  @private
     */ 
    public function set title(value:String):void
    {
        if (_title != value)
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "title", _title, value);
            
            _title = value;
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  titleContent
    //----------------------------------
    
    private var _titleContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  titleContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleContent():Array
    {
        return _titleContent;
    }
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        var changeEvent:PropertyChangeEvent = 
            PropertyChangeEvent.createUpdateEvent(this, "titleContent", _titleContent, value);
        
        _titleContent = value;
        dispatchEvent(changeEvent);
    }
    
    //----------------------------------
    //  titleGroupLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar's titleContent group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    private var _titleGroupLayout:LayoutBase;
    
    public function get titleGroupLayout():LayoutBase
    {
        return _titleGroupLayout;
    }
    /**
     *  @private
     */
    public function set titleGroupLayout(value:LayoutBase):void
    {
        var changeEvent:PropertyChangeEvent = 
            PropertyChangeEvent.createUpdateEvent(this, "titleGroupLayout", _titleGroupLayout, value);
        
        _titleGroupLayout = value;
        dispatchEvent(changeEvent);
    }
    
    //--------------------------------------------------------------------------
    //
    //  IDataRenderer Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object;
    
    [Bindable("dataChange")]
    
    /**
     *  The data associated with the current view.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
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
        _data = value;
        
        if (hasEventListener(FlexEvent.DATA_CHANGE))
            dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Methods creates an object that should be returned to the
     *  previous screen when this view is popped off a navigator's
     *  stack.
     * 
     *  @return null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function createReturnObject():Object
    {
        return null;
    }
    
    /**
     *  Returns the state the view should be in based on the orientation
     *  of the device.
     * 
     *  @return A String specifying the name of the state to apply to the screen. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getCurrentViewState(landscape:Boolean):String
    {
        if (!landscape && hasState("portrait"))
            return "portrait";
        
        if (landscape && hasState("landscape"))
            return "landscape";
        
        // If none of the above states are defined in the view will
        // return the empty string. 
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Persistence Methods
    //
    //--------------------------------------------------------------------------

    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getPersistenceData():Object
    {
        return data;    
    }
    
    /**
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function deserializePersistenceData(value:Object):Object
    {
        return value;
    }
}
}