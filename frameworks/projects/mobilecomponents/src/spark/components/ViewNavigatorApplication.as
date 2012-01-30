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

package spark.components
{
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.StageOrientationEvent;
import flash.net.registerClassAlias;
import flash.ui.Keyboard;

import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.MobileApplicationBase;
import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewHistoryData;
import spark.layouts.supportClasses.LayoutBase;

use namespace mx_internal;

[DefaultProperty("navigationStack")]

/**
 * 
 */
public class MobileApplication extends MobileApplicationBase
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    // The following constants are used to indicate whether the developer
    // has explicitly set one of the navigator template properties.  This
    // allows us to properly store these set properties if the navigator skin
    // changes.
    
    /**
     *  @private
     */
    private static const ACTION_CONTENT_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    private static const ACTION_LAYOUT_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const NAVIGATION_CONTENT_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    private static const NAVIGATION_LAYOUT_PROPERTY_FLAG:uint = 1 << 3;
    
    /**
     *  @private
     */
    private static const TITLE_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const TITLE_CONTENT_PROPERTY_FLAG:uint = 1 << 5;
    
    /**
     *  @private
     */
    private static const TITLE_LAYOUT_PROPERTY_FLAG:uint = 1 << 6;
    
    /**
     *  @private
     */
    private static const NAVIGATION_STACK_PROPERTY_FLAG:uint = 1 << 7;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    public function MobileApplication()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    /**
     *  The main view navigator for the application.  This component is 
     *  responsible for managing the view navigation model for the application.  
     */ 
    public var navigator:ViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var navigatorProperties:Object = {};
    
    /**
     *  @private
     */
    // TODO (chiedozi): Why did we decide to make this private?
    private function get navigationStack():NavigationStack
    {
        if (navigator)
            return navigator.navigationStack;
        else
            return navigatorProperties.navigationStack;
    }
    
    /**
     *  @private
     */
    private function set navigationStack(value:NavigationStack):void
    {
        if (navigator)
        {
            navigator.navigationStack = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                NAVIGATION_STACK_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigationStack = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  canCancelBackKeyBehavior
    //----------------------------------
    /**
     *  @private
     */  
    override public function get canCancelBackKeyBehavior():Boolean
    {
        return navigator && navigator.canCancelBackKeyBehavior;
    }
    
    //----------------------------------
    //  firstViewData
    //----------------------------------
    /**
     * @private
     */
    private var _firstViewData:Object;
    
    /**
     * This is the initialization data to pass to the
     * root screen when it is created.
     */
    public function get firstViewData():Object
    {
        return _firstViewData;
    }
    
    /**
     * @private
     */
    public function set firstViewData(value:Object):void
    {
        _firstViewData = value;
    }
    
    //----------------------------------
    //  firstView
    //----------------------------------
    /**
     *  @private
     *  The backing variable for the firstView property.
     */
    private var _firstView:Class;
    
    /**
     *  This property is the object to use to initialize the first view
     *  of the stack.
     */
    public function get firstView():Class
    {
        return _firstView;
    }
    
    /**
     * @private
     */
    public function set firstView(value:Class):void
    {
        _firstView = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  UI Template Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  actionContent
    //----------------------------------
    
    [ArrayElementType("mx.core.IVisualElement")]
    /**
     *  Array of visual elements that are used as the ActionBar's
     *  actionContent when this view is active.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionContent():Array
    {
        if (navigator)
            return navigator.actionContent;
        else
            return navigatorProperties.actionContent;
    }
    
    /**
     *  @private
     */
    public function set actionContent(value:Array):void
    {
        if (navigator)
        {
            navigator.actionContent = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                                        ACTION_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.actionContent = value;
    }
    
    //----------------------------------
    //  actionLayout
    //----------------------------------
    
    /**
     *  Layout for the ActionBar's action content group.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get actionLayout():LayoutBase
    {
        if (navigator)
            return navigator.actionLayout;
        else
            return navigatorProperties.actionLayout;
    }
    
    /**
     *  @private
     */
    public function set actionLayout(value:LayoutBase):void
    {
        if (navigator)
        {
            navigator.actionLayout = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                                        ACTION_LAYOUT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.actionLayout = value;
    }
    
    //----------------------------------
    //  navigationContent
    //----------------------------------
    
    
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
        if (navigator)
            return navigator.navigationContent;
        else
            return navigatorProperties.navigationContent;
    }
    
    /**
     *  @private
     */
    public function set navigationContent(value:Array):void
    {
        if (navigator)
        {
            navigator.navigationContent = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                NAVIGATION_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigationContent = value;
    }
    
    //----------------------------------
    //  navigationLayout
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
    public function get navigationLayout():LayoutBase
    {
        if (navigator)
            return navigator.navigationLayout;
        else
            return navigatorProperties.navigationLayout;
    }
    
    /**
     *  @private
     */
    public function set navigationLayout(value:LayoutBase):void
    {
        if (navigator)
        {
            navigator.navigationLayout = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                NAVIGATION_LAYOUT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigationLayout = value;
    }
    
    //----------------------------------
    //  title
    //----------------------------------
    
    [Bindable]
    /**
     *  The default title that should be used by the ActionBar if the
     *  view doesn't provide one.
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function get title():String
    {
        if (navigator)
            return navigator.title;
        else
            return navigatorProperties.title;
    }
    
    /**
     *  @private
     */ 
    public function set title(value:String):void
    {
        if (navigator)
        {
            navigator.title = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                TITLE_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.title = value;
    }
    
    //----------------------------------
    //  titleContent
    //----------------------------------
    
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
        if (navigator)
            return navigator.titleContent;
        else
            return navigatorProperties.titleContent;
    }
    
    /**
     *  @private
     */
    public function set titleContent(value:Array):void
    {
        if (navigator)
        {
            navigator.titleContent = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                TITLE_CONTENT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.titleContent = value;
    }
    
    //----------------------------------
    //  titleLayout
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
    public function get titleLayout():LayoutBase
    {
        if (navigator)
            return navigator.titleLayout;
        else
            return navigatorProperties.titleLayout;
    }
    
    /**
     *  @private
     */
    public function set titleLayout(value:LayoutBase):void
    {
        if (navigator)
        {
            navigator.titleLayout = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint, 
                NAVIGATION_LAYOUT_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.titleLayout = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: MobileApplicationBase
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function nativeApplication_invokeHandler(event:InvokeEvent):void
    {
        super.nativeApplication_invokeHandler(event);

        // Set the stage focus to the navigator's active view
        if (systemManager.stage.focus == null && navigator)
        {
            if (navigator.activeView)
                systemManager.stage.focus = navigator.activeView;
            else
                systemManager.stage.focus = navigator;
        }
    }
    
    /**
     *  @private
     */ 
    override protected function nativeApplication_deactivateHandler(event:Event):void
    {
        if (navigator && navigator.activeView)
            navigator.activeView.setActive(false);

        // super is called after so that the active view can get the
        // viewDeactive event before the persistence process begins.
        super.nativeApplication_deactivateHandler(event);
    }
    
    /**
     *  @private
     */ 
    override protected function backKeyHandler():void
    {
        super.backKeyHandler();
        
        navigator.backKeyHandler();
    }
    
    /**
     *  @private
     */ 
    override protected function orientationChangeHandler(event:StageOrientationEvent):void
    {
        super.orientationChangeHandler(event);
        
        if (navigator)
            navigator.landscapeOrientation = landscapeOrientation;
    }
    
    /**
     *  @private
     */ 
    override protected function persistApplicationState():void
    {
        super.persistApplicationState();

        // TODO (chiedozi): Rename save to maybe get?
        if (navigator)
            persistenceManager.setProperty("navigatorState", navigator.saveViewData());
    }
    
    /**
     *  @private
     */ 
    override protected function registerPersistenceClassAliases():void
    {
        super.registerPersistenceClassAliases();
        
        // Register aliases for custom classes that will be written to
        // persistence store by navigator
        registerClassAlias("ViewHistoryData", ViewHistoryData);
        registerClassAlias("NavigationStack", NavigationStack);
    }
    
    /**
     * @private
     */
    override protected function restoreApplicationState():void
    {
        // TODO (chiedozi): Figure out how to refactor this into base class
        super.restoreApplicationState();
        
        var savedState:Object = persistenceManager.getProperty("navigatorState");
        
        if (savedState)
            navigator.restoreViewData(savedState);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == navigator)
        {
            var newNavigatorProperties:uint = 0;
                
            if (navigatorProperties.actionContent !== undefined)
            {
                navigator.actionContent = navigatorProperties.actionContent;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                                                ACTION_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.actionLayout !== undefined)
            {
                navigator.actionLayout = navigatorProperties.actionLayout;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    ACTION_LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.navigationContent !== undefined)
            {
                navigator.navigationContent = navigatorProperties.navigationContent;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    NAVIGATION_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.navigationLayout !== undefined)
            {
                navigator.navigationLayout = navigatorProperties.navigationLayout;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    NAVIGATION_LAYOUT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.title !== undefined)
            {
                navigator.title = navigatorProperties.title;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    TITLE_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.titleContent !== undefined)
            {
                navigator.titleContent = navigatorProperties.titleContent;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    TITLE_CONTENT_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.titleLayout !== undefined)
            {
                navigator.titleLayout = navigatorProperties.titleLayout;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    TITLE_LAYOUT_PROPERTY_FLAG, true);
            }
            
            navigatorProperties = newNavigatorProperties;
            navigator.firstView = firstView;
            navigator.firstViewData = firstViewData;
            navigator.navigationStack = navigationStack;
            navigator.landscapeOrientation = landscapeOrientation;
            
            // Set the stage focus to the navigator
            systemManager.stage.focus = navigator;
        }
    }
     
    /**
     *  @private
     */ 
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == navigator)
        {
            var newNavigatorProperties:Object = {};
                
            if (BitFlagUtil.isSet(navigatorProperties as uint, ACTION_CONTENT_PROPERTY_FLAG))
                newNavigatorProperties.actionContent = navigator.actionContent;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, ACTION_LAYOUT_PROPERTY_FLAG))
                newNavigatorProperties.actionLayout = navigator.actionLayout;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, NAVIGATION_CONTENT_PROPERTY_FLAG))
                newNavigatorProperties.navigationContent = navigator.navigationContent;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, NAVIGATION_LAYOUT_PROPERTY_FLAG))
                newNavigatorProperties.navigationLayout = navigator.navigationLayout;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_PROPERTY_FLAG))
                newNavigatorProperties.title = navigator.title;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_CONTENT_PROPERTY_FLAG))
                newNavigatorProperties.titleContent = navigator.titleContent;
            
            if (BitFlagUtil.isSet(navigatorProperties as uint, TITLE_LAYOUT_PROPERTY_FLAG))
                newNavigatorProperties.titleLayout = navigator.titleLayout;
               
            // Always want to save the navigation stack
            // TODO (chiedozi): I'm not doing this right...
            newNavigatorProperties.navigationStack = navigator.navigationStack;
            navigatorProperties = newNavigatorProperties;
        }
    }
}
}