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

public interface SessionManager2 extends SessionManager {
	
	/**
	 * This is, functionally, a clone of the SessionManager.launch() method. There are however some differences.
	 * 	-This is to be called only for run launches. The launch() method creates a Session and
	 * binds it to the launch. Since the launch() method returns the Session, which will be null in a Run Launch case,
	 * we have no way of accessing the Process that was created for the launch (in the case of a run launch).
	 * 	-To enable auto termination of run launches, we need to know the system Process for us to terminate it when
	 * necessary.
	 *  -This method creates the process and binds a process listener to it and then returns the process.
	 *
	 * 
	 * @param uri
	 *            which will launch a Flash player under running OS. For
	 *            Flash/Flex apps, this can point to either a SWF or an HTML
	 *            file. For AIR apps, this must point to the application.xml
	 *            file for the application.
	 * @param airLaunchInfo
	 *            If trying to launch an AIR application, this argument must be
	 *            specified; it gives more information about how to do the
	 *            launch. If trying to launch a regular web-based Flash or Flex
	 *            application, such as one that will be in a browser or in the
	 *            standalone Flash Player, this argument should be
	 *            <code>null</code>.
	 * @param waitReporter
	 *            a progress monitor to allow accept() to notify its parent how
	 *            long it has been waiting for the Flash player to connect to
	 *            it. May be <code>null</code> if the caller doesn't need to
	 *            know how long it's been waiting.
	 * @param launchNotification
	 *            a notifier to notify the caller about ADL Exit Code.
	 *            Main usage is for ADL Exit Code 1 (Successful invocation of an 
	 *            already running AIR application. ADL exits immediately).
	 *            May be <code>null</code> if no need to listen ADL. 
	 *			  The callback will be called on a different thread.
	 * @return a Process to use for the run launch.
	 *         The return value is not used to indicate an error -- exceptions
	 *         are used for that. If this function returns without throwing an
	 *         exception, then the return value will always be non-null.
	 * @throws IOException
	 *             see Runtime.exec()
	 */
	public Process launchForRun(String uri, AIRLaunchInfo airLaunchInfo,
			 IProgress waitReporter, ILaunchNotification launchNotification) throws IOException;

}
