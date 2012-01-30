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
import flash.events.StageOrientationEvent;
import flash.net.registerClassAlias;

import mx.core.ContainerCreationPolicy;
import mx.core.mx_internal;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.MobileApplicationBase;
import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewDescriptor;
import spark.components.supportClasses.ViewNavigatorBase;

use namespace mx_internal;

[DefaultProperty("navigators")]

/**
 * 
 */
public class TabbedMobileApplication extends MobileApplicationBase
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
    
    // TODO (chiedozi): Just use a variable instead of a bitfield
    /**
     *  @private
     */
    private static const NAVIGATORS_PROPERTY_FLAG:uint = 1 << 0;
    private static const MAINTAIN_NAVIGATION_STACK_PROPERTY_FLAG:uint = 1 << 1;

    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    /**
     *  The main navigator for the application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var navigator:TabbedViewNavigator;
    
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
    public function TabbedMobileApplication()
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
     */
    private var navigatorProperties:Object = {};
    
    //----------------------------------
    //  activeView
    //----------------------------------
    
    /**
     *  @private
     */ 
    override mx_internal function get activeView():View
    {
        if (navigator)
            return navigator.activeView;
        
        return null;
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
    override public function get exitApplicationOnBackKey():Boolean
    {
    	if (navigator)
    		return navigator.exitApplicationOnBackKey;
    	
        return super.exitApplicationOnBackKey;
    }
    
    //----------------------------------
    //  creationPolicy
    //----------------------------------
    private var _explicitCreationPolicy:String = ContainerCreationPolicy.AUTO;

    /**
     *  @inheritDoc
     *
     *  <p>TabbedMobileApplication can not have visual elements
     *  added to it, so the creationPolicy concept use by the framework
     *  doesn't necessarily make sense.  Instead, this property repurposed to
     *  control whether the application's child navigators create their children
     *  when the application initializes.</p>
     */
    override public function get creationPolicy():String
    {
        return _explicitCreationPolicy;
    }
    
    /**
     *  @private
     */ 
    override public function set creationPolicy(value:String):void
    {
        // Don't want to change real creationPolicy property
        if (value != _explicitCreationPolicy)
        {
            _explicitCreationPolicy = value;
            
            if (navigator)
                navigator.creationPolicy = _explicitCreationPolicy;
        }
    }
    
    //----------------------------------
    //  navigators
    //----------------------------------
    /**
     *  The list of navigators that are being managed by the application.
     *  Each navigator in the list will be represented by a item on the tab
     *  bar.
     *  
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get navigators():Vector.<ViewNavigatorBase>
    {
        if (navigator)
            return navigator.navigators;
        else
            return navigatorProperties.navigators;
    }
    /**
     *  @private
     */
    public function set navigators(value:Vector.<ViewNavigatorBase>):void
    {
        if (navigator)
        {
            navigator.navigators = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                NAVIGATORS_PROPERTY_FLAG, value != null);
        }
        else
            navigatorProperties.navigators = value;
    }
    
    //----------------------------------
    //  maintainNavigationStack
    //----------------------------------
    /**
     *  This property indicates whether the navigation stack of the view
     *  should remain intact when the navigator is deactivated by its
     *  parent navigator.  If set to true, when reactivated the view history
     *  will remain the same.  If false, the navigator will display the
     *  first view in its navigation stack.
     * 
     *  @default true
     *  
     *  @see spark.components.TabbedViewNavigator
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get maintainNavigationStack():Boolean
    {
        if (navigator)
            return navigator.maintainNavigationStack;
        else
            return navigatorProperties.maintainNavigationStack;
    }
    
    /**
     *  @private
     */ 
    public function set maintainNavigationStack(value:Boolean):void
    {
        if (navigator)
        {
            navigator.maintainNavigationStack = value;
            navigatorProperties = BitFlagUtil.update(navigatorProperties as uint,
                MAINTAIN_NAVIGATION_STACK_PROPERTY_FLAG, true);
        }
        else
            navigatorProperties.maintainNavigationStack = value;
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
        if (navigator)
            navigator.backKeyHandler();
    }
    
    /**
     *  @private
     */
    override protected function orientationChangeHandler(event:StageOrientationEvent):void
    {
        if (navigator)
            navigator.landscapeOrientation = landscapeOrientation;
    }
    
    /**
     *  @private
     */
    // TODO (chiedozi): PARB
    override protected function persistApplicationState():void
    {
        super.persistApplicationState();
        
        if (navigators.length > 0)
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
        registerClassAlias("ViewDescriptor", ViewDescriptor);
        registerClassAlias("NavigationStack", NavigationStack);
    }
    
    /**
     *  @private
     */
    override protected function restoreApplicationState():void
    {
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
            
            navigator.creationPolicy = _explicitCreationPolicy;
            navigator.landscapeOrientation = landscapeOrientation;
            
            if (navigatorProperties.navigators !== undefined)
            {
                navigator.navigators = navigatorProperties.navigators;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    NAVIGATORS_PROPERTY_FLAG, true);
            }
            
            if (navigatorProperties.maintainNavigationStack !== undefined)
            {
                navigator.maintainNavigationStack = navigatorProperties.maintainNavigationStack;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    MAINTAIN_NAVIGATION_STACK_PROPERTY_FLAG, true);
            }
            
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
        	// FIXME (chiedozi): maintainNavigationStack check ISSET
            // Always want to save the navigation stack
            navigatorProperties = {navigators:navigator.navigators,
                                   maintainNavigationStack:navigator.maintainNavigationStack};
        }
    }
}
}