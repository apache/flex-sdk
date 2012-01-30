////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.automation.delegates.components.mediaClasses
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.automation.Automation;
import mx.automation.IAutomationObjectHelper;
import mx.automation.events.AutomationRecordEvent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

import spark.automation.delegates.components.SparkButtonAutomationImpl;
import spark.components.mediaClasses.MuteButton;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines methods and properties required to perform instrumentation for the 
 *  MuteButton control.
 * 
 *  @see spark.components.mediaClasses.MuteButton 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SparkMuteButtonAutomationImpl extends SparkButtonAutomationImpl 
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function init(root:DisplayObject):void
    {
        Automation.registerDelegateClass(spark.components.mediaClasses.MuteButton, SparkMuteButtonAutomationImpl);
    }   

    /**
     *  Constructor.
     * @param obj MuteButton object to be automated.     
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SparkMuteButtonAutomationImpl(obj:spark.components.mediaClasses.MuteButton)
    {
        super(obj);
        obj.addEventListener(FlexEvent.MUTED_CHANGE , muteChangeHandler, false, 0, true);
        obj.addEventListener(AutomationRecordEvent.RECORD, recordHandler,false,0,true);

    }
    
    
    /**
     *  @private
     */
    
    private function recordHandler(event:AutomationRecordEvent):void
    {
        // let us not record the click event.
        var re:Event = event.replayableEvent;
        if((re is MouseEvent) && (re.type == MouseEvent.CLICK))
            event.preventDefault();
    }

    
    /**
     *  @private
     */
    private function muteChangeHandler(event:mx.events.FlexEvent):void
    {
        recordAutomatableEvent(event);
    }
    
    /**
     *  @private
     */
    override public function replayAutomatableEvent(event:Event):Boolean
    {
        var help:IAutomationObjectHelper = Automation.automationObjectHelper;
        
        if (event is mx.events.FlexEvent)
        {
            // we need to replay the click on the muteButton
            if(event.type == FlexEvent.MUTED_CHANGE)
            {
                help.replayClick(sparkMuteButton);
            }
        }
        return super.replayAutomatableEvent(event);
    }
    
    /**
     *  @private
     *  storage for the owner component
     */
    protected function get sparkMuteButton():spark.components.mediaClasses.MuteButton
    {
        return uiComponent as spark.components.mediaClasses.MuteButton;
    }
    
}

}