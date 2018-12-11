/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.tools.debugger;

import java.io.IOException;

/**
 * Used to notify caller in case of ADL Exit Code 1: Successful invocation of an already running 
 * AIR application. ADL exits immediately.
 */
public interface ILaunchNotification
{
	/**
	 * Notifies the listener that the launch is done, and, if it failed,
	 * an exception with information about why it failed.
	 * 
	 * @param e
	 *            an exception if the launch failed, or null if the launch
	 *            succeeded.
	 */
	public void notify(IOException e);
}
