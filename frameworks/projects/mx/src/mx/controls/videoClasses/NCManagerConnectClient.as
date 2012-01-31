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

import flash.net.NetConnection;

[ExcludeClass]

/**
 *  @private
 *  <p>Holds client-side functions for remote procedure calls (rpc) from
 *  the FCS during initial connection.  One of these objects is created and
 *  passed to the <code>NetConnection.client</code> property.
 */
public class NCManagerConnectClient
{
	include "../../core/Version.as";

    public var owner:NCManager;
    public var netConnection:NetConnection;
    public var connIndex:uint;
    public var pending:Boolean;
	
    public function NCManagerConnectClient(nc:NetConnection, owner:NCManager = null, connIndex:uint = 0)
    {
		super();

        this.owner = owner;
        this.netConnection = nc;
        this.connIndex = connIndex;
        this.pending = false;
    }

    public function onBWDone(... rest):void
    {
        var p_bw:Number;
        if (rest.length > 0) p_bw = rest[0];

        owner.onConnected(netConnection, p_bw);
    }

    public function onBWCheck(... rest):uint
    {
        return ++owner.payload;
    }

    public function onMetaData(... rest):void
    {
    }
	
    public function onPlayStatus(... rest):void
    {
    }
	
    public function close():void
    {     
    }
}

}