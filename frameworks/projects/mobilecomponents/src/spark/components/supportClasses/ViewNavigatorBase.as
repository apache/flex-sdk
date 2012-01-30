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

package spark.components.supportClasses
{
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;

import spark.components.SkinnableContainer;
import spark.components.View;
import spark.events.DisplayLayerObjectExistenceEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the navigator has been activated.
 * 
 *  @eventType mx.events.FlexEvent.NAVIGATOR_ACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="navigatorActivate", type="mx.events.FlexEvent")]

/**
 *  Dispatched when the navigator has been deactivated.
 * 
 *  @eventType mx.events.FlexEvent.NAVIGATOR_DEACTIVATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Event(name="navigatorDeactivate", type="mx.events.FlexEvent")]

/**
 *  The ViewNavigatorBase class defines the base class logic and
 *  interface used by view navigators.  This class contains
 *  methods and properties related to view management, as well
 *  as integration points with MobileApplicationBase application
 *  classes.
 * 
 *  @see spark.components.ViewNavigator
 *  @see spark.components.MobileApplication
 */ 
public class ViewNavigatorBase extends SkinnableContainer
{
    //--------------------------------------------------------------------------
    //
    // Constructor
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  Creates an empty navigation stack.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ViewNavigatorBase()
    {
        super();
        
        _navigationStack = new NavigationStack();
    }
    
    //--------------------------------------------------------------------------
    //
    // Properties
    // 
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  active
    //----------------------------------
    
    private var _active:Boolean = true;
    
    /**
     *  Flag indicating whether the navigator is active.  The parent navigator
     *  will automatically set this flag to true or false as its state changes.  
     *  This getter will dispatch <code>FlexEvent.NAVIGATOR_ACTIVATE</code> and 
     *  <code>FlexEvent.NAVIGATOR_DEACTIVATE</code> as the value changes.
     *  
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get active():Boolean
    {
        return _active;
    }
    
    /**
     * @private
     */
    public function set active(value:Boolean):void
    {
        if (_active != value)
        {
            _active = value;
            
            if (activeView)
                activeView.active = value;
            
            var eventName:String = _active ? FlexEvent.NAVIGATOR_ACTIVATE : 
                                             FlexEvent.NAVIGATOR_DEACTIVATE;
            if (hasEventListener(eventName))
                dispatchEvent(new FlexEvent(eventName));
        }
    }

    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  The currently active view of the navigator.  Only one view can
     *  be active at a time.
     *
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get activeView():View
    {
        return null;
    }
    
    //----------------------------------
    //  canCancelBackKeyBehavior
    //----------------------------------
    /**
     *  This method determines if a device's default back key handler can
     *  be canceled.  For example, by default, when the back key is pressed
     *  on android devices, the application exits.  By returning true, that
     *  action will be canceled and the navigator's backKeyHandler() method
     *  is called.
     * 
     *  <p>This method is only called if the navigator is the main navigator
     *  of a MobileApplication class</p>.
     * 
     *  @return Flag indicating the default behavior can be canceled.  By
     *  default, this method returns false.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    // TODO (chiedozi): PARB? exitOnBack?
    public function get canCancelBackKeyBehavior():Boolean
    {
        return false;
    }
    
    //----------------------------------
    //  icon
    //----------------------------------
    
    private var _icon:Class;
    
    /**
     *  Returns the icon that should be used when this navigator is represented
     *  by a visual component.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get icon():Class
    {
        return _icon;    
    }
    
    /**
     *  @private
     */
    public function set icon(value:Class):void
    {
        if (_icon != value)
        {
            var oldValue:Class = _icon;
            _icon = value;
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                    PropertyChangeEvent.createUpdateEvent(this, "icon", oldValue, _icon);
                
                dispatchEvent(changeEvent);
            }
        }
    }
    
    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String = "";
    
    [Bindable]
    /**
     *  The label to be used when this stack is represented by a visual component.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */
    public function set label(value:String):void
    {    
        if (_label != value)
        {
            var oldValue:String = _label;
            _label = value;
            
            if (hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE))
            {
                var changeEvent:PropertyChangeEvent = 
                    PropertyChangeEvent.createUpdateEvent(this, "label", oldValue, _label);
                
                dispatchEvent(changeEvent);
            }
        }
    }
    
    //----------------------------------
    //  landscapeOrientation
    //----------------------------------
    
    private var _landscapeOrientation:Boolean = false;
    
    /**
     *  Indicates whether the navigator should be in portrait or landscape
     *  orientation.  When this property changes, the navigator attempts
     *  to change it's skin state to match.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get landscapeOrientation():Boolean
    {
        return _landscapeOrientation;
    }
    
    public function set landscapeOrientation(value:Boolean):void
    {
        if (value != _landscapeOrientation)
        {
            _landscapeOrientation = value;
            invalidateSkinState();
            
            if (skin)
                skin.invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  navigationStack
    //----------------------------------
    
    protected var _navigationStack:NavigationStack;
    
    /**
     *  The navigation stack that is being managed by the navigator.
     *  An empty navigation stack is automatically created when
     *  a navigator is created.
     * 
     *  @default null
     */ 
    public function get navigationStack():NavigationStack
    {
        return _navigationStack;
    }
    /**
     *  @private
     */ 
    public function set navigationStack(value:NavigationStack):void
    {
        if (value == null)
            _navigationStack = new NavigationStack();
        else
            _navigationStack = value;
    }
    
    //----------------------------------
    //  overlayControls
    //----------------------------------
    private var _overlayControls:Boolean = false;
    
    /**
     *  Flag indicates how the navigator's ui controls should be
     *  laid out in relation to the active view.  If true, the view
     *  will extend the entire content area of the component, and the
     *  ui controls will hover on top.
     * 
     *  <p>Changing this property will result in a skin validation.</p>
     * 
     *  @default true
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
    
    public function set overlayControls(value:Boolean):void
    {
        if (value != _overlayControls)
        {
            _overlayControls = value;
            invalidateSkinState();
            
            if (skin)
            {
                skin.invalidateSize();
                skin.invalidateDisplayList();
            }
        }
    }
    
    //----------------------------------
    //  parentNavigator
    //----------------------------------
    /**
     *  The parent navigator for this navigator.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var parentNavigator:ViewNavigatorBase;
    
    //----------------------------------
    //  transitionsEnabled
    //----------------------------------
    
    /**
     *  Flag indicating whether transitions are played by the 
     *  navigator when a view changes or when the actionBar or tab bar 
     *  visibility changes.
     * 
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public var transitionsEnabled:Boolean = true;
    
    //----------------------------------
    //  useDefaultTransitions
    //----------------------------------
    
    // TODO (chiedozi): PARB name, Getters/Setters
    /**
     *
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public var useDefaultTransitions:Boolean = true;
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  If the navigator is the main navigator of the MobileApplication or
     *  class, this method is called when the back device key is pressed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function backKeyHandler():void
    {
    }
    
    /**
     *  This method checks if the current view can be removed
     *  from the display list.
     * 
     *  @return Returns true if the screen can be removed
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function canRemoveCurrentView():Boolean
    {
    	// This is a method instead of a property because the default
    	// implementation in ViewNavigator has a side effect
        return true;
    }
    
    /**
     *  @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function getCurrentSkinState():String
    {
        var finalState:String = _landscapeOrientation ? "landscape" : "portrait";
    
        if (_overlayControls)
            finalState += "AndOverlay";
        
        return finalState;
    }
    
    /**
     *  This method is responsible for serializing all data related to
     *  the navigator's children into an object that can be saved
     *  by the persistence manager.  This object will be sent to the
     *  restoreViewData method when the navigator is reinstantiated.
     * 
     *  @return The object that represents the navigators state
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function saveViewData():Object
    {
        return {label:label, iconClassName:getQualifiedClassName(icon)};
    }
    
    /**
     *  This method is responsible for restoring the navigator's view
     *  data based on the object that is passed in.
     * 
     *  @param value The saved object that should be used to restore
     *  the navigators state
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    // TODO (chiedozi): This is not module safe
    public function restoreViewData(value:Object):void
    {
        label = value.label;
        
        var iconClassName:String = value.iconClassName;
        icon = (iconClassName == "null") ? null : getDefinitionByName(iconClassName) as Class;
    }
    
    /**
     *  This method updates various properties of the navigator when a
     *  new view is added and activated.
     * 
     *  @param view The view that was added
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function updatePropertiesForView(view:View):void
    {
    }
}
}