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

package mx.managers.systemClasses
{

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.Event;
import flash.events.MouseEvent;
import mx.events.SandboxMouseEvent;
import mx.utils.EventUtil;
import mx.managers.IMarshalSystemManager;
import mx.managers.ISystemManager;

[ExcludeClass]

/**
 * @private
 * An object that marshals events to other sandboxes
 */
public class EventProxy extends EventDispatcher
{
    private var marshalSystemManager:IMarshalSystemManager;
    private var systemManager:ISystemManager;

    public function EventProxy(systemManager:ISystemManager)
    {
        this.systemManager = systemManager;
    }

    public function marshalListener(event:Event):void
    {
        if (event is MouseEvent)
        {
            var me:MouseEvent = event as MouseEvent;;
            var mme:SandboxMouseEvent= new SandboxMouseEvent(EventUtil.mouseEventMap[event.type],
                false, false, me.ctrlKey, me.altKey, me.shiftKey, me.buttonDown);
            // trace(">>marshalListener", systemManager, mme.type);
            if (!marshalSystemManager)
                marshalSystemManager = 
			        IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
            marshalSystemManager.dispatchEventFromSWFBridges(mme, null, true, true);
            // trace("<<marshalListener", systemManager);
        }
        else if (event.type == Event.MOUSE_LEAVE)
        {
            mme = new SandboxMouseEvent(SandboxMouseEvent.MOUSE_UP_SOMEWHERE);
            // trace(">>marshalListener", systemManager, mme.type);
            if (!marshalSystemManager)
                marshalSystemManager = 
			        IMarshalSystemManager(systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
            marshalSystemManager.dispatchEventFromSWFBridges(mme, null, true, true);
            // must send to ourselves as well
            systemManager.dispatchEvent(mme);
        }
    }

}

}
