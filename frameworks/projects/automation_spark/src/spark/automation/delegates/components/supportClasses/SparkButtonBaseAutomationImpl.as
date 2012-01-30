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

package spark.automation.delegates.components.supportClasses
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.automation.Automation;
import mx.automation.IAutomationObjectHelper;
import mx.core.EventPriority;
import mx.core.mx_internal;

import spark.components.supportClasses.ButtonBase;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines methods and properties required to perform instrumentation for the 
 *  ButtonBase control.
 * 
 *  @see spark.components.supportClasses.ButtonBase
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 *
 */
public class SparkButtonBaseAutomationImpl extends SparkSkinnableComponentAutomationImpl 
{
    include "../../../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Registers the delegate class for a component class with automation manager.
     *  
     *  @param root The SystemManger of the application.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function init(root:DisplayObject):void
    {
        Automation.registerDelegateClass(spark.components.supportClasses.ButtonBase, SparkButtonBaseAutomationImpl);
    }   

    /**
     *  Constructor.
     * @param obj ButtonBase object to be automated.     
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SparkButtonBaseAutomationImpl(obj:spark.components.supportClasses.ButtonBase)
    {
        super(obj);

        obj.addEventListener(KeyboardEvent.KEY_UP, btnKeyUpHandler, false, EventPriority.DEFAULT+1, true);          
        obj.addEventListener(MouseEvent.CLICK, clickHandler, false, EventPriority.DEFAULT+1, true);
    }

    /**
     *  @private
     *  storage for the owner component
     */
    protected function get btnBase():spark.components.supportClasses.ButtonBase
    {
        return uiComponent as spark.components.supportClasses.ButtonBase;
    }

    /**
     *  @private
     */
    private var ignoreReplayableClick:Boolean;

    //----------------------------------
    //  automationName
    //----------------------------------

    /**
     *  @private
     */
    override public function get automationName():String
    {
        return btnBase.label || btnBase.toolTip || super.automationName;
    }

    //----------------------------------
    //  automationValue
    //----------------------------------

    /**
     *  @private
     */
    override public function get automationValue():Array
    {
        return [ btnBase.label || btnBase.toolTip ];
    }

    /**
     *  @private
     */
    protected function clickHandler(event:MouseEvent):void 
    {
        if (!ignoreReplayableClick)
            recordAutomatableEvent(event);
        ignoreReplayableClick = false;
    }
    
    /**
     *  @private
     */
    private function btnKeyUpHandler(event:KeyboardEvent):void 
    {
        if (!btnBase.enabled)
            return;

        if (event.keyCode == Keyboard.SPACE)
        {
            // we need to ignore recording a click being dispatched here
            ignoreReplayableClick = true;
            recordAutomatableEvent(event);
        }
    }


    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Replays click interactions on the button.
     *  If the interaction was from the mouse,
     *  dispatches MOUSE_DOWN, MOUSE_UP, and CLICK.
     *  If interaction was from the keyboard,
     *  dispatches KEY_DOWN, KEY_UP.
     *  Button's KEY_UP handler then dispatches CLICK.
     *
     *  @param event ReplayableClickEvent to replay.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function replayAutomatableEvent(event:Event):Boolean
    {
        var help:IAutomationObjectHelper = Automation.automationObjectHelper;
        
        if (event is MouseEvent && event.type == MouseEvent.CLICK)
            return help.replayClick(uiComponent, MouseEvent(event));
        else if (event is KeyboardEvent)
            return help.replayKeyboardEvent(uiComponent, KeyboardEvent(event));
        else
            return super.replayAutomatableEvent(event);
    }
    
}

}