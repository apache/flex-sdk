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
import flash.events.StageOrientationEvent;
import flash.net.registerClassAlias;

import mx.utils.BitFlagUtil;

import spark.components.supportClasses.MobileApplicationBase;
import spark.components.supportClasses.NavigationStack;
import spark.components.supportClasses.ViewHistoryData;
import spark.components.supportClasses.ViewNavigatorBase;

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
    
    // TODO (Chiedozi): Just in a var
    /**
     *  @private
     */
    private static const NAVIGATORS_PROPERTY_FLAG:uint = 1 << 0;

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
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  navigators
    //----------------------------------
    /**
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
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods: MobileApplicationBase
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     */ 
    override protected function backKeyHandler():void
    {
        if (navigator)
            navigator.backKeyHandler();
    }
    
    /**
     *  @inheritDoc
     */ 
    // TODO (chiedozi): make a getter (PARB)
    override public function canCancelDefaultBackKeyBehavior():Boolean
    {
        return  navigator && navigator.canCancelDefaultBackKeyBehavior();
    }
    
    /**
     *  @inheritDoc
     */
    override protected function orientationChangeHandler(event:StageOrientationEvent):void
    {
        if (navigator)
            navigator.landscapeOrientation = landscapeOrientation;
    }
    
    /**
     *  @inheritDoc
     */
    // TODO (chiedozi): PARB
    override protected function persistApplicationState():void
    {
        super.persistApplicationState();
    }
    
    /**
     *  @inheritDoc
     */
    override protected function registerPeristenceClassAliases():void
    {
        super.registerPeristenceClassAliases();
        
        // Register aliases for custom classes that will be written to
        // persistence store by navigator
        registerClassAlias("ViewHistoryData", ViewHistoryData);
        registerClassAlias("NavigationStack", NavigationStack);
    }
    
    /**
     *  @inheritDoc
     */
    override protected function restoreApplicationState():void
    {
        super.restoreApplicationState();
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
            
            if (navigatorProperties.navigators !== undefined)
            {
                navigator.navigators = navigatorProperties.navigators;
                newNavigatorProperties = BitFlagUtil.update(newNavigatorProperties, 
                    NAVIGATORS_PROPERTY_FLAG, true);
            }
            
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
            // Always want to save the navigation stack
            navigatorProperties = {navigators:navigator.navigators};
        }
    }
}
}