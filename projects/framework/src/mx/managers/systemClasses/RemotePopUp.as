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

import flash.display.DisplayObject;
import flash.events.IEventDispatcher;

[ExcludeClass]

/**
 * @private
 * A form that exists in a SystemManager in another sandbox or compiled with
 * a different version of Flex.
 * 
 * An instance of a RemotePopUp is put into the forms array of the top-level 
 * System Manager so the top-level System Manager can manage the form's 
 * activation/deactivation along with any other forms that are displayed.
 */
public class RemotePopUp extends Object
{
    /**
     * Create new RemotePopUp. There are two kinds of remote pop ups. One for trusted
     * popups and one for untrusted popups. Trusted pop ups pass may pass display objects
     * and the bridge handle of the form. Untrusted pop ups may only pass a string id and
     * the bridge handle of the direct child.
     * 
     * @param window String if the form is a placeholder for an untrusted pop up. A display
     * object (SystemManagerProxy) if the form is trusted.
     * 
     * @param bridge If the form is trusted, the bridge handle of the source of the form.
     * If the form is untrusted, the bridge of the direct child of this application that parents
     * the source of the form. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function RemotePopUp(window:Object, bridge:Object)
    {
        this.window = window;
        this.bridge = bridge;
    }
    
    public var window:Object;       // SystemManagerProxy or String id of remote form
    public var bridge:Object;       // bridge of remote form
}

}
