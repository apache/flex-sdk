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
import flash.display.Stage;
import flash.events.StageOrientationEvent;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.utils.DensityUtil;

import spark.components.SkinnableContainer;
import spark.components.View;
import spark.utils.MultiDPIBitmapSource;

use namespace mx_internal;

/**
 *  The ViewNavigatorBase class defines the base class logic and
 *  interface used by view navigators.  
 *  This class contains methods and properties related to view management, 
 *  as well as integration points with ViewNavigatorApplicationBase application
 *  classes.
 *
 *  @mxml <p>The <code>&lt;s:ViewNavigatorBase&gt;</code> tag inherits 
 *  all of the tag attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewNavigatorBase
 *    <strong>Properties</strong>
 *    icon="null"
 *    label="null"
 *    transitionsEnabled="true"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.components.ViewNavigator
 *  @see spark.components.ViewNavigatorApplication
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
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
     *  @langversion 3.0
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
    // Variables
    // 
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This private variable is used to indicate that the navigator shouldn't play
     *  the pending visibility animation for the chrome components that it controls
     *  (e.g, ActionBar and TabBar).  This flag is set to true when the stage changes
     *  orientation.  This allows the framework to prevent the hide/show animation 
     *  from playing when the controls are hidden in either landscape or portrait.
     * 
     *  See SDK-28541 for more information.
     */
    mx_internal var disableNextControlAnimation:Boolean = false;
    
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
     *  Set to <code>true</code> when this navigator is active.  
     *  The parent navigator automatically sets this flag its state changes.
     *  
     *  @default true
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
     * Setting the active state is hidden and should be managed my
     * the components that manage navigators.
     */
    mx_internal function setActive(value:Boolean, clearNavigationStack:Boolean = false):void
    {
        if (_active != value)
            _active = value;
    }

    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  The currently active view of the navigator.  
     *  Only one view can be active at a time.
     *
     *  @default null
     * 
     *  @langversion 3.0
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get exitApplicationOnBackKey():Boolean
    {
        return true;
    }
    
    //----------------------------------
    //  icon
    //----------------------------------
    
    private var _icon:Object;
    
    /**
     *  The icon used when this navigator is represented
     *  by a visual component.
     * 
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get icon():Object
    {
        return _icon;    
    }
    
    /**
     *  @private
     */
    public function set icon(value:Object):void
    {
        if (_icon != value)
        {
            var oldValue:Object = _icon;
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
     *  The label used when this navigator is represented by a visual component.
     * 
     *  @default null
     * 
     *  @langversion 3.0
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
    
    /**
     *  @private
     */ 
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
     *  @private
     *  This property controls the overlay state of the navigator.  The
     *  navigator will properly update this property in the
     *  updateControlsForView() method with the View.overlayControls
     *  property.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    mx_internal function get overlayControls():Boolean
    {
        return _overlayControls;
    }
    
    mx_internal function set overlayControls(value:Boolean):void
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
     *  Set to <code>true</code> to enable view transitions 
     *  when a view changes, or when the ActionBar control or 
     *  TabBar control visibility changes.
     * 
     *  @default true
     * 
     *  @langversion 3.0
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
     *  This method executes the default back key behavior for a ViewNavigator.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3.1
     *  @productversion Flex 4.6
     */
    public function backKeyUpHandler():void
    {
    }
    
    /**
     *  Serializes all data related to
     *  the navigator's children into an object that can be saved
     *  by the persistence manager.  
     *  This returned object is passed to the <code>restoreViewData()</code> 
     *  method when the navigator is reinstantiated.
     * 
     *  @return The object that represents the navigators state
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function saveViewData():Object
    {
        var iconData:Object = icon;
        
        if (iconData is MultiDPIBitmapSource)
        {
            var app:Object = FlexGlobals.topLevelApplication;
            var dpi:Number;
            if ("runtimeDPI" in app)
                dpi = app["runtimeDPI"];
            else
                dpi = DensityUtil.getRuntimeDPI();

            iconData = MultiDPIBitmapSource(iconData).getSource(dpi);
        }
        
        if (iconData is Class)
            return {label:label, iconClassName:getQualifiedClassName(iconData)};
        if (iconData is String)
            return {label:label, iconStringName: iconData};
        
        return {label:label};
    }
    
    /**
     *  Restores the state of a navigator's view 
     *  from the <code>value</code> argument.
     *  The object passed as the <code>value</code> argument is 
     *  created by a call to the <code>saveViewData()</code> method.
     * 
     *  @param value The object used to restore the navigators state.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function loadViewData(value:Object):void
    {
        label = value.label;
        
        var iconClassName:String = value.iconClassName;

        if (iconClassName == null)
            icon = value.iconStringName;
        else if (iconClassName != null)
            icon = getDefinitionByName(iconClassName);
        
        // TODO (chiedozi): This is not module safe because of its use of 
        // getDefinitionByName.  Should use systemManager to do this. (SDK-27424)
    }
    
    /**
     *  Updates various properties of the navigator when a
     *  new view is added and activated.
     * 
     *  @param view The view that was added.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function updateControlsForView(view:View):void
    {
        if (parentNavigator)
            parentNavigator.updateControlsForView(view);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  
     *  @langversion 3.0
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
     *  @private
     *  This method checks if the current view can be removed
     *  from the display list. This is mx_internal because the
     *  TabbedViewNavigator needs to call it on its children.
     * 
     *  @return Returns true if the screen can be removed
     *  
     *  @langversion 3.0
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
     *  Captures the important animation values of component to use
     *  when animating the actionBar's visiblity.
     *  
     *  @param component The component to capture the values from
     * 
     *  @return Returns an object that contains the properties 
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    mx_internal function captureAnimationValues(component:UIComponent):Object
    {
        var values:Object = {   x:component.x,
                                y:component.y,
                                width:component.width,
                                height:component.height,
                                explicitWidth:component.explicitWidth,
                                explicitHeight:component.explicitHeight,
                                percentWidth:component.percentWidth,
                                percentHeight:component.percentHeight,
                                visible: component.visible,
                                includeInLayout: component.includeInLayout,
                                cacheAsBitmap: component.cacheAsBitmap };
        
        return values;
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
    private function creationCompleteHandler(event:FlexEvent):void
    {
        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        
		// Create a weak listener so stage doesn't hold a reference to the view
		FlexGlobals.topLevelApplication.addEventListener(ResizeEvent.RESIZE, 
            stage_resizeHandler, false, 0, true);
    }
    
	/**
	 *  @private
	 */
	mx_internal function updateFocus():void
	{
		var stage:Stage = systemManager.stage;
		if (!stage.focus || !stage.focus.stage || stage.focus == this)
		{
			if (activeView)
				stage.focus = activeView;
			else
				stage.focus = this;
		}
    }
    
    /**
     *  @private
     */ 
    mx_internal function stage_resizeHandler(event:ResizeEvent):void
    {
        disableNextControlAnimation = true;
        invalidateSkinState();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function attachSkin():void
    {
        super.attachSkin();
        
        // Since a new skin was added, update the state of the controls
        // added as part of the new skin
        updateControlsForView(activeView);
    }
    
    /**
     *  @private
     */ 
    override public function initialize():void
    {
        super.initialize();
        
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
    }
}
}