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

package mx.controls.videoClasses 
{

[ExcludeClass]

/**
 *  @private
 *  Holds client-side functions for remote procedure calls (RPCs) from
 *  the FCS during reconnection.
 *  One of these objects is created and passed to the
 *  <code>NetConnection.client</code> property.
 */
public class NCManagerReconnectClient
{
	include "../../core/Version.as";

    public var owner:NCManager;

    public function NCManagerReconnectClient(owner:NCManager = null)
    {
		super();

        this.owner = owner;
    }

    // This is defined just to work around bug 121673
    public function onBWCheck(... rest):uint
    {
        return ++owner.payload;
    }

    public function onBWDone(... rest):void
    {
        owner.onReconnected();
    }
}

}