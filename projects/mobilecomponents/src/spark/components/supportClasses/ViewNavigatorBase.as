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
import flash.display.StageOrientation;
import flash.events.StageOrientationEvent;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.managers.SystemManager;

import spark.components.SkinnableContainer;
import spark.components.View;
import spark.core.ContainerDestructionPolicy;
import spark.events.DisplayLayerObjectExistenceEvent;

use namespace mx_internal;

/**
 *  The ViewNavigatorBase class defines the base class logic and
 *  interface used by view navigators.  This class contains
 *  methods and properties related to view management, as well
 *  as integration points with ViewNavigatorApplicationBase application
 *  classes.
 * 
 *  @see spark.components.ViewNavigator
 *  @see spark.components.ViewNavigatorApplication
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
     *  
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get isActive():Boolean
    {
        return _active;
    }
    
    /**
     * @private
     * Setting the active state is hidden and should be managed my
     * the components that manage navigators.
     */
    mx_internal function setActive(value:Boolean, clearNavigationStack:Boolean = false):void
    {
        if (_active != value)
        {
            _active = value;
            
            if (clearNavigationStack)
                _navigationStack.popToFirstView();
            
            if (activeView)
                activeView.setActive(value);
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
    //  exitApplicationOnBackKey
    //----------------------------------
    /**
     *  @private
     *  This method determines if a device's default back key handler can
     *  be canceled.  For example, by default, when the back key is pressed
     *  on android devices, the application exits.  By returning true, that
     *  action will be canceled and the navigator's default back key behavior
     *  will run.
     * 
     *  <p>This method is only called if the navigator is the main navigator
     *  of a ViewNavigatorApplication class</p>.
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get exitApplicationOnBackKey():Boolean
    {
        return true;
    }
    
    //----------------------------------
    //  destructionPolicy
    //----------------------------------
    
    private var _destructionPolicy:String = ContainerDestructionPolicy.AUTO;
    
    [Inspectable(category="General", enumeration="auto,never", defaultValue="auto")]
    /**
     *  Sets the destructionPolicy for the navigator.  This property determines
     *  if the contents of the navigator should be destroyed when the navigator
     *  is deactivated by another component, such as TabbedViewNavigator.
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
    //  lastAction
    //----------------------------------
    
    private var _lastAction:String = ViewNavigatorAction.NONE;
    
    /**
     *  @private
     *  The last action performed by the navigator.
     *
     *  @see spark.components.supportClasses.ViewNavigatorAction
     */
    mx_internal function get lastAction():String
    {
        return _lastAction;
    }
    
    /**
     *  @private
     */ 
    mx_internal function set lastAction(value:String):void
    {
        _lastAction = value;    
    }
    
    //----------------------------------
    //  navigationStack
    //----------------------------------
    
    protected var _navigationStack:NavigationStack;
    
    /**
     *  @private
     *  The navigation stack that is being managed by the navigator.
     *  An empty navigation stack is automatically created when
     *  a navigator is created.
     * 
     *  @default null
     */ 
    mx_internal function get navigationStack():NavigationStack
    {
        return _navigationStack;
    }
    
    /**
     *  @private
     */ 
    mx_internal function set navigationStack(value:NavigationStack):void
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
    private var _parentNavigator:ViewNavigatorBase;
    
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
    public function get parentNavigator():ViewNavigatorBase
    {
        return _parentNavigator;
    }
    
    /**
     *  @private
     */ 
    mx_internal function setParentNavigator(value:ViewNavigatorBase):void
    {
        _parentNavigator = value;        
    }
    
    //----------------------------------
    //  transitionsEnabled
    //----------------------------------
    
    private var _transitionsEnabled:Boolean = true;
    
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
    public function get transitionsEnabled():Boolean
    {
        return _transitionsEnabled;
    }
    
    /**
     *  @private
     */
    public function set transitionsEnabled(value:Boolean):void
    {
        _transitionsEnabled = value;
    }
    
    //--------------------------------------------------------------------------
    //
    // Public Methods
    // 
    //--------------------------------------------------------------------------
    
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
        var finalState:String = FlexGlobals.topLevelApplication.aspectRatio;
    
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
    public function loadViewData(value:Object):void
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
    public function updateControlsForView(view:View):void
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  If the navigator is the main navigator of the ViewNavigatorApplication or
     *  class, this method is called when the back device key is pressed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function backKeyUpHandler():void
    {
    }
    
    /**
     *  @private
     *  This method checks if the current view can be removed
     *  from the display list. This is mx_internal because the
     *  TabbedViewNavigator needs to call it on its children.
     * 
     *  @return Returns true if the screen can be removed
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function canRemoveCurrentView():Boolean
    {
        // This is a method instead of a property because the default
        // implementation in ViewNavigator has a side effect
        return true;
    }
    
    /**
     *  @private
     *  Creates the top view of the navigator and adds it to the
     *  display list.  This method is used when the navigator exists
     *  inside a TabbedViewNavigator.
     */ 
    mx_internal function createTopView():void
    {
        // Override in sub class
    }

    /**
     *  @private
     */
    mx_internal function stage_orientationChangeHandler(event:StageOrientationEvent):void
    {
        invalidateSkinState();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    override public function initialize():void
    {
        super.initialize();
        
        // Add weak listener so stage doesn't hold a reference to the navigator
        systemManager.stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, 
            stage_orientationChangeHandler, false, 0, true);
    }
}
}