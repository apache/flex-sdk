/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger.events;

/**
 * This event is fired when the player has completed the loading of 
 * the specified SWF.
 */
public class SwfLoadedEvent extends DebugEvent
{
	/** unique identifier for the SWF */
	public long id;				

	/** index of swf in Session.getSwfs() array */
	public int index;

	/** full path name for  SWF */
	public String path;

	/** size of the loaded SWF in bytes */
	public long swfSize;

	/** URL of the loaded SWF */
	public String url;

	/** port number related to the URL */
	public long port;

	/** name of host in which the SWF was loaded */
	public String host;

	public SwfLoadedEvent(long sId, int sIndex, String sPath, String sUrl, String sHost, long sPort, long sSwfSize)
	{
		id = sId;
		index = sIndex;
		swfSize = sSwfSize;
		port = sPort;
		path = sPath;
		url = sUrl;
		host = sHost;
	}
}
