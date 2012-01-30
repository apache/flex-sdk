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
import flash.events.StageOrientationEvent;

import mx.core.FlexGlobals;
import mx.core.IDataRenderer;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;

import spark.core.ContainerDestructionPolicy;
import spark.events.ViewNavigatorEvent;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[Exclude(name="height", kind="property")]
[Exclude(name="minHeight", kind="property")]
[Exclude(name="maxHeight", kind="property")]
[Exclude(name="width", kind="property")]
[Exclude(name="minWidth", kind="property")]
[Exclude(name="maxWidth", kind="property")]
[Exclude(name="scaleX", kind="property")]
[Exclude(name="scaleY", kind="property")]
[Exclude(name="scaleZ", kind="property")]
[Exclude(name="z", kind="property")]

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the back key is pressed when a view exists inside
 *  a mobile application.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.BACK_KEY_PRESSED
 * 
 */
[Event(name="backKeyPressed", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the <code>data</code> property changes.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.DATA_CHANGE
 * 
 */
[Event(name="dataChange", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the menu key is pressed when a view exists inside
 *  a mobile application.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 * 
 *  @eventType mx.events.FlexEvent.MENU_KEY_PRESSED
 * 
 */
[Event(name="menuKeyPressed", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the current view has been activated.
 * 
 *  @eventType spark.events.ViewNavigatorEvent.VIEW_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="viewActivate", type="spark.events.ViewNavigatorEvent")]

/**
 *  Dispatched when the current view has been deactivated.
 * 
 *  @eventType spark.events.ViewNavigatorEvent.VIEW_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="viewDeactivate", type="spark.events.ViewNavigatorEvent")]

/**
 *  Dispatched when the screen is about to be removed in response
 *  to a screen change.  
 *  Calling <code>preventDefault()</code> 
 *  while handling this event cancels the screen change.
 * 
 *  @eventType spark.events.ViewNavigatorEvent.REMOVING
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="removing", type="spark.events.ViewNavigatorEvent")]

/**
 *  The View class is the base container class for all views used by view
 *  navigators.  
 *  The View container extends the Group container and adds
 *  additional properties used to communicate with it's parent
 *  navigator.
 *
 *  <p>In a mobile application, the content area of the application
 *  displays the individual screens, or views, that make up the application. 
 *  Users navigate the views of the application by using the touch screen, 
 *  components built into the application, and the input controls of the mobile device.</p>
 *
 *  <p>The following image shows a View container with a List control:</p>
 *
 * <p>
 *  <img src="../../images/vn_single_section_home_vn.png" alt="View container" />
 * </p>
 *
 *  <p>Each view in an application corresponds to a View container defined 
 *  in an ActionScript or MXML file. 
 *  Each View contains a <code>data</code> property that specifies the data 
 *  associated with that view. 
 *  Views can use the <code>data</code> property to pass information to each 
 *  other as the user navigates the application.</p>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:View&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:View
 *   <strong>Properties</strong>
 *    actionBarVisible="true"
 *    actionContent="null"
 *    actionLayout="null"
 *    data="null"
 *    destructionPolicy="auto"
 *    navigationContent="null"
 *    navigationLayout="null"
 *    overlayControls="false"
 *    tabBarVisible="true"
 *    title=""
 *    titleContent="null"
 *    titleLayout="null"
 *    viewMenuItems="null"
 * 
 *   <strong>Events</strong>
 *    backKeyPressed="<i>No default</i>"
 *    dataChange="<i>No default</i>"
 *    menuKeyPressed="<i>No default</i>"
 *    removing="<i>No default</i>"
 *    viewActivate="<i>No default</i>"
 *    viewDeactivate="<i>No default</i>"
 * 
 *  &gt;
 *  </pre>
 *
 *  @see ViewNavigator
 *
 *  @includeExample examples/ViewExample.mxml -noswf
 *  @includeExample examples/ViewExampleHomeView.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class View extends SkinnableContainer implements IDataRenderer
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function View()
    {
        super();
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
     *  Indicates whether the current view is active.  
     *  The view's navigator  automatically sets this flag to <code>true</code> 
     *  or <code>false</code> as its state changes.  
     *  Setting this property can dispatch the <code>viewActivate</code> or 
     *  <code>viewDeactivate</code> events. 
     *  
     *  @default false
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get isActive():Boolean
    {
        return _active;
    }
    
    /**
     * @private
     */
    mx_internal function setActive(value:Boolean):void
    {
        if (_active != value)
        {
            _active = value;
            
            // Switch orientation states if needed
            if (_active)
                updateOrientationState();
                
            var eventName:String = _active ? 
                ViewNavigatorEvent.VIEW_ACTIVATE : 
                ViewNavigatorEvent.VIEW_DEACTIVATE;
            
            if (hasEventListener(eventName))
                dispatchEvent(new ViewNavigatorEvent(eventName, false, false, navigator.lastAction));
        }
    }

    //----------------------------------
    //  canRemove
    //----------------------------------
    
    /**
     *  @private
     *  Determines if the current view can be removed by a navigator.  The default 
     *  implementation dispatches a <code>FlexEvent.REMOVING</code> event.  If
     *  preventDefault() is called on the event, this property will return false.
     * 
     *  @return Returns true if the view can be removed
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    mx_internal function canRemove():Boolean
    {
        if (hasEventListener(ViewNavigatorEvent.REMOVING))
        {
            var event:ViewNavigatorEvent = 
                new ViewNavigatorEvent(ViewNavigatorEvent.REMOVING, 
                                       false, true, navigator.lastAction);
            
            return dispatchEvent(event);
        }
        
        return true;
    }
    
    /**
     *  @private
     */ 
    mx_internal function backKeyHandledByView():Boolean
    {
        if (hasEventListener(FlexEvent.BACK_KEY_PRESSED))
        {
            var event:FlexEvent = new FlexEvent(FlexEvent.BACK_KEY_PRESSED, false, true);
            var eventCanceled:Boolean = !dispatchEvent(event);
            
            // If the event was canceled, that means the application
            // is doing its own custom logic for the back key
            return eventCanceled;
        }
        
        return false;
    }
    
    /**
     *  @private
     */ 
    mx_internal function menuKeyHandledByView():Boolean
    {
        if (hasEventListener(FlexEvent.MENU_KEY_PRESSED))
        {
            var event:FlexEvent = new FlexEvent(FlexEvent.MENU_KEY_PRESSED, false, true);
            var eventCanceled:Boolean = !dispatchEvent(event);
            
            // If the event was canceled, that means the application
            // is doing its own custom logic for the back key
            return eventCanceled;
        }
        
        return false;
    }
    
    //----------------------------------
    //  overlayControls
    //----------------------------------
    
    private var _overlayControls:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]
    /**
     *  By default, the TabBar and ActionBar controls of a 
     *  mobile application define an area that cannot be used 
     *  by the views of an application. 
     *  That means your content cannot use the full screen size 
     *  of the mobile device.
     *  If you set this property to <code>true</code>, the content area 
     *  of the application spans the entire width and height of the screen. 
     *  The ActionBar and TabBar controls hover over the content area with 
     *  an <code>alpha</code> value of 0.5 so that they are partially transparent. 
     *  
     *  @default false
     * 
     *  @langversion 3.0
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
            var oldValue:Boolean = _overlayControls;
            _overlayControls = value;
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "overlayControls", oldValue, _overlayControls);
            
                dispatchEvent(changeEvent);
            }
        }
    }
    
    //----------------------------------
    //  destructionPolicy
    //----------------------------------
    
    private var _destructionPolicy:String = ContainerDestructionPolicy.AUTO;
    
    [Inspectable(category="General", enumeration="auto,never", defaultValue="auto")]
    /**
     *  Defines the destruction policy the view's navigator should use
     *  when this view is removed. If set to "auto", the navigator will
     *  destroy the view when it isn't active.  If set to "never", the
     *  view will be cached in memory.
     * 
     *  @default auto
     * 
     *  @langversion 3.0
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
    
    private var _navigator:ViewNavigator = null;
    
    /**
     * The view navigator that this view resides in.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    
    [Bindable("navigatorChanged")]
    public function get navigator():ViewNavigator
    {
        return _navigator;
    }
    
    /**
     *  @private
     */ 
    mx_internal function setNavigator(value:ViewNavigator):void
    {
        _navigator = value;
        
        if (hasEventListener("navigatorChanged"))
            dispatchEvent(new Event("navigatorChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  UI Template Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionBarVisible
    //----------------------------------
    private var _actionBarVisible:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]
    /**
     *  Specifies whether a view should show the action bar or not.
     *  This property does not necessarily correlate to the 
     *  <code>visible</code> property of the view navigator's ActionBar control. 
     *
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionBarVisible():Boolean
    {
        return _actionBarVisible;
    }
    
    /**
     *  @private
     */ 
    public function set actionBarVisible(value:Boolean):void
    {
        _actionBarVisible = value;
        
        // Immediately request actionBar's visibility be toggled
        if (isActive && navigator)
        {
            if (_actionBarVisible)
                navigator.showActionBar();
            else
                navigator.hideActionBar();
        }
    }
    
    /**
     *  @private
     *  Method called by parent navigator to update the actionBarVisible
     *  flag as a result of the showActionBar() or hideActionBar() methods.
     */ 
    mx_internal function setActionBarVisible(value:Boolean):void
    {
        _actionBarVisible = value;
    }
    
    //----------------------------------
    //  actionContent
    //----------------------------------
    
    private var _actionContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  This property overrides the <code>actionContent</code>
     *  property in the ActionBar, ViewNavigator, and 
     *  ViewNavigatorApplication components.
     * 
     *  @copy ActionBar#actionContent
     *
     *  @default null
     *
     *  @see ActionBar#actionContent
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
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
        var oldValue:Array = _actionContent;
        _actionContent = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "actionContent", oldValue, _actionContent);
        
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  actionLayout
    //----------------------------------
    
    private var _actionLayout:LayoutBase;
    
    /**
     *  @copy ActionBar#actionLayout
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionLayout():LayoutBase
    {
        return _actionLayout;
    }
    /**
     *  @private
     */
    public function set actionLayout(value:LayoutBase):void
    {
        var oldValue:LayoutBase = value;
        _actionLayout = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "actionLayout", oldValue, _actionLayout);
        
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  viewMenuItems
    //----------------------------------
    
    private var _viewMenuItems:Vector.<ViewMenuItem>;
    
    /**
     *  The Vector of ViewMenuItem objects passed to the ViewMenu when
     *  this View is the active view. 
     *
     *  @see ViewMenu
     *  @see ViewMenuItem
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */   
    public function get viewMenuItems():Vector.<ViewMenuItem>
    {
        return _viewMenuItems;
    }
    
    public function set viewMenuItems(value:Vector.<ViewMenuItem>):void
    {
        _viewMenuItems = value;
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    private var _navigationContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  This property overrides the <code>navigationContent</code>
     *  property in the ActionBar, ViewNavigator, and 
     *  ViewNavigatorApplication components.
     * 
     *  @copy ActionBar#navigationContent
     *
     *  @default null
     * 
     *  @see ActionBar#navigationContent
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
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
        var oldValue:Array = _navigationContent;
        _navigationContent = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "navigationContent", oldValue, _navigationContent);
        
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  navigationLayout
    //----------------------------------
    
    private var _navigationLayout:LayoutBase;
    
    /**
     *  @copy ActionBar#navigationLayout
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigationLayout():LayoutBase
    {
        return _navigationLayout;
    }
    /**
     *  @private
     */
    public function set navigationLayout(value:LayoutBase):void
    {
        var oldValue:LayoutBase = _navigationLayout;
        _navigationLayout = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "navigationLayout", _navigationLayout, value);
        
            dispatchEvent(changeEvent);
        }
    }
    

    
    //----------------------------------
    //  tabBarVisible
    //----------------------------------
    private var _tabBarVisible:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]
    /**
     *  Specifies whether a view should show the tab bar or not.
     *  This property does not necessarily correlate to the 
     *  <code>visible</code> property of the navigator's TabBar control. 
     *
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get tabBarVisible():Boolean
    {
        return _tabBarVisible;
    }
    
    /**
     *  @private
     */
    public function set tabBarVisible(value:Boolean):void
    {
        var oldValue:Boolean = _tabBarVisible;
        _tabBarVisible = value;
        
        // Immediately request actionBar's visibility be toggled
        if (isActive && navigator)
        {
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                    PropertyChangeEvent.createUpdateEvent(this, "tabBarVisible", oldValue, value);
                
                dispatchEvent(changeEvent);
            }
        }
    }
    
    /**
     *  @private
     *  Method called by parent navigator to update the actionBarVisible
     *  flag as a result of the showTabBar() or hideTabBar() methods.
     */ 
    mx_internal function setTabBarVisible(value:Boolean):void
    {
        _tabBarVisible = value;
    }
    
    //----------------------------------
    //  title
    //----------------------------------
    
    private var _title:String;
    
    [Bindable]
    /**
     *  This property overrides the <code>title</code>
     *  property in the ActionBar, ViewNavigator, and 
     *  ViewNavigatorApplication components.
     * 
     *  @copy ActionBar#title
     *
     *  @default ""
     *  
     *  @langversion 3.0
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
            var oldValue:String = _title;            
            _title = value;
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                    PropertyChangeEvent.createUpdateEvent(this, "title", oldValue, _title);
            
                dispatchEvent(changeEvent);
            }
        }
    }
    
    //----------------------------------
    //  titleContent
    //----------------------------------
    
    private var _titleContent:Array;
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  This property overrides the <code>titleContent</code>
     *  property in the ActionBar, ViewNavigator, and 
     *  ViewNavigatorApplication components.
     * 
     *  @copy ActionBar#titleContent
     *
     *  @default null
     * 
     *  @see ActionBar#titleContent
     *  @see spark.skins.mobile.ActionBarSkin
     *  
     *  @langversion 3.0
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
        var oldValue:Array = _titleContent;
        _titleContent = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "titleContent", oldValue, _titleContent);
            
            dispatchEvent(changeEvent);
        }
    }
    
    //----------------------------------
    //  titleLayout
    //----------------------------------
    
    private var _titleLayout:LayoutBase;
    
    /**
     *  @copy ActionBar#titleLayout
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get titleLayout():LayoutBase
    {
        return _titleLayout;
    }
    /**
     *  @private
     */
    public function set titleLayout(value:LayoutBase):void
    {
        var oldValue:LayoutBase = _titleLayout;
        _titleLayout = value;
        
        if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
        {
            var changeEvent:PropertyChangeEvent = 
                PropertyChangeEvent.createUpdateEvent(this, "titleLayout", oldValue, _titleLayout);
            
            dispatchEvent(changeEvent);
        }
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
     *  You use this property to pass infomration to the View when 
     *  it is pushed onto the navigator's stack.
     *  You can set this property by passing a <code>data</code>
     *  argument to the <code>pushView()</code> method. 
     * 
     *  @langversion 3.0
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
     *  Creates an object returned to the view navigator
     *  when this view is popped off the navigator's stack.
     *
     *  <p>Override this method in a View to return data back the new 
     *  view when this view is popped off the stack. 
     *  The <code>createReturnObject()</code> method returns a single Object.
     *  The Object returned by this method is written to the 
     *  <code>ViewNavigator.poppedViewReturnedObject</code> property. </p>
     *
     *  <p>The <code>ViewNavigator.poppedViewReturnedObject</code> property
     *  is of type ViewReturnObject.
     *  The <code>ViewReturnObject.object</code> property contains the 
     *  value returned by this method. </p>
     *
     *  <p>If the <code>poppedViewReturnedObject</code> property is null, 
     *  no data was returned. 
     *  The <code>poppedViewReturnedObject</code> property is guaranteed to be set 
     *  in the new view before the new view receives the <code>add</code> event.</p>
     * 
     *  @return The value written to the <code>object</code> field of the 
     *  <code>ViewNavigator.poppedViewReturnedObject</code> property.  
     *
     *  @see ViewNavigator#poppedViewReturnedObject
     *  @see spark.components.supportClasses.ViewReturnObject
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function createReturnObject():Object
    {
        return null;
    }
    
    /**
     *  Checks the aspect ratio of the stage and returns the proper state
     *  that the View should change to.  
     * 
     *  @return A String specifying the name of the state to apply to the view. 
     *  The possible return values are <code>"portrait"</code>
     *  or <code>"landscape"</code>.  
     *  The state is only changed if the desired state exists
     *  on the View. 
     *  If it does not, this method returns the component's current state.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getCurrentViewState():String
    {
        var aspectRatio:String = FlexGlobals.topLevelApplication.aspectRatio;
        
        if (hasState(aspectRatio))
            return aspectRatio;
        
        // If the appropriate state for the orientation of the device
        // isn't defined, return the current state
        return currentState;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */ 
    private function application_resizeHandler(event:Event):void
    {
        if (isActive)
            updateOrientationState();
    }
    
    /**
     *  @private
     */
    mx_internal function updateOrientationState():void
    {
        setCurrentState(getCurrentViewState(), false);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override public function initialize():void
    {
        super.initialize();
        
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
    }
    
    /**
     *  @private
     */ 
    private function creationCompleteHandler(event:FlexEvent):void
    {
        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        
        // Create a weak listener so stage doesn't hold a reference to the view
        FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, 
            application_resizeHandler, false, 0, true);
        
        updateOrientationState();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Persistence Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Responsible for serializes the view's <code>data</code> property 
     *  when the view is being persisted to disk.  
     *  The returned object should be something that can
     *  be successfully written to a shared object.  
     *  By default, this method returns the <code>data</code> property
     *  of the view.
     * 
     *  @return The serialized data object.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function serializeData():Object
    {
        return data;    
    }
    
    /**
     *  Deserializes a data object that was saved to disk by the view,
     *  typically by a call to the <code>serializeData()</code> method.  
     *
     *  @param value The data object to deserialize.
     *  
     *  @return The value assigned to the 
     *  view's <code>data</code> property.
     *
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function deserializeData(value:Object):Object
    {
        return value;
    }
}
}