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
package
{

import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;

/**
 *  Classes used by the networking protocols go here
 */
import mx.messaging.config.ConfigMap; ConfigMap;
import mx.messaging.messages.AcknowledgeMessage; AcknowledgeMessage;
import mx.messaging.messages.AcknowledgeMessageExt; AcknowledgeMessageExt;
import mx.messaging.messages.AsyncMessage; AsyncMessage;
import mx.messaging.messages.AsyncMessageExt; AsyncMessageExt;
import mx.messaging.messages.CommandMessage; CommandMessage;
import mx.messaging.messages.CommandMessageExt; CommandMessageExt;
import mx.messaging.messages.ErrorMessage; ErrorMessage;
import mx.messaging.messages.HTTPRequestMessage; HTTPRequestMessage;
import mx.messaging.messages.MessagePerformanceInfo; MessagePerformanceInfo;
import mx.messaging.messages.RemotingMessage; RemotingMessage;
import mx.messaging.messages.SOAPMessage; SOAPMessage;
import mx.core.mx_internal;

[SWF(width="750", height="700")]
public class Bootstrap_CursorManager extends Sprite
{
    /**
     *  The URL of the application SWF to be loaded
     *  by this bootstrap loader.
     */
    private static const applicationURL:String = "assets/Bootstrap_CursorManager_Child.swf";

	public var portNumber : Number=80;
    /**
     *  Constructor.
     */
    public function Bootstrap_CursorManager()
    {
        super();

        if (ApplicationDomain.currentDomain.hasDefinition("mx.core::UIComponent"))
            throw new Error("UIComponent should not be in Bootstrap.");

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        if (!stage)
            isStageRoot = false;

        root.loaderInfo.addEventListener(Event.INIT, initHandler);
        
        if(root.loaderInfo != null && root.loaderInfo.parameters != null)
		{
			for (var ix:String in root.loaderInfo.parameters) 
			{
				if(ix == "port") 
				{
					portNumber = Number(root.loaderInfo.parameters[ix]);	
				}
			}
		}        
    }

    /**
     *  The Loader used to load the application SWF.
     */
    private var loader:Loader;

    /**
     *  @private
     *  Whether we are the stage root or not.
     *  We are only the stage root if we were the root
     *  of the first SWF that got loaded by the player.
     *  Otherwise we could be top level but not stage root
     *  if we are loaded by some other non-Flex shell
     *  or are sandboxed.
     */
    private var isStageRoot:Boolean = true;

	/**
	 *  @private
	 *  Whether the content is loaded
	 */
	private var contentLoaded:Boolean;

    /**
     *  Called when BootstrapLoader.swf has been loaded.
     *  Starts loading the application SWF
     *  specified by applicationURL.
     */
    private function initHandler(event:Event):void
    {
        loader = new Loader();
        addChild(loader);
        loader.contentLoaderInfo.addEventListener(
            Event.COMPLETE, completeHandler);
        loader.load(new URLRequest(applicationURL+"?port=" + portNumber));
        loader.addEventListener("mx.managers.SystemManager.isBootstrapRoot", bootstrapRootHandler);
        loader.addEventListener("mx.managers.SystemManager.isStageRoot", stageRootHandler);

        stage.addEventListener(Event.RESIZE, resizeHandler);
    }

    private function completeHandler(event:Event):void
    {
        contentLoaded = true;
    }

    private function bootstrapRootHandler(event:Event):void
    {
        // cancel event to indicate that the message was heard
        event.preventDefault();
    }

    private function stageRootHandler(event:Event):void
    {
        // cancel event to indicate that the message was heard
        if (!isStageRoot)
            event.preventDefault();
    }

    private function resizeHandler(event:Event):void
    {
    
		if (!contentLoaded)
			return;    
    
        loader.width = stage.width;
        loader.height = stage.height;
        Object(loader.content).setActualSize(stage.width, stage.height);
    }
}

}
