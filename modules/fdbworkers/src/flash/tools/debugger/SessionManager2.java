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
package flash.tools.debugger;

import java.io.IOException;

public interface SessionManager2 extends SessionManager {
	
	/**
	 * This is, functionally, a clone of the SessionManager.launch() method. There are however some differences.
	 * 	-This is to be called only for run launches. only for debug launches, the launch() method creates a Session and
	 * binds it to the launch and since the launch() method returns the Session, which will be null in a Run Launch case,
	 * we have no way of accessing the Process that was created for the launch.
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
	/**
	 * This is, functionally, a clone of the SessionManager.launch() method. There are however some differences.
	 * 	-This is to be called only for run launches. only for debug launches, the launch() method creates a Session and
	 * binds it to the launch and since the launch() method returns the Session, which will be null in a Run Launch case,
	 * we have no way of accessing the Process that was created for the launch.
	 * 	-To enable auto termination of run launches, we need to know the system Process for us to terminate it when
	 * necessary.
	 *  -This method creates the process and binds a process listener to it and then returns the process.
	 *
	 *  - This method used the ILauncher instance passed to launch the application.
	 *  
	 * @param uri
	 *  		  which will launch a Flash player under running OS. For
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
	 * @param launcher
	 * 			  a launcher instance which will be used to launch.
	 * @return a Process to use for the run launch.
	 *         The return value is not used to indicate an error -- exceptions
	 *         are used for that. If this function returns without throwing an
	 *         exception, then the return value will always be non-null.
	 * @throws IOException
	 */
	public Process launchForRun(String uri, AIRLaunchInfo airLaunchInfo,
			 IProgress waitReporter, ILaunchNotification launchNotification, ILauncher launcher) throws IOException;
	
	
	/**
	 * Launches the given string as a URI using the ILauncher Instance.
	 * 
	 * This API is to provide more flexibility to handle the Player launch in different platforms.
	 * 
	 * This call will block until a session with the newly launched player is
	 * created.
	 * <p>
	 * It is the caller's responsibility to ensure that no other thread is
	 * blocking in <code>accept()</code>, since that thread will gain control
	 * of this session.
	 * <p>
	 * Before calling <code>launch()</code>, you should first call
	 * <code>supportsLaunch()</code>. If <code>supportsLaunch()</code>
	 * returns false, then you will have to tell the user to manually launch the
	 * Flash player.
	 * <p>
	 * Also, before calling <code>launch()</code>, you must call
	 * <code>startListening()</code>.
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
	 * @param forDebugging
	 *            if <code>true</code>, then the launch is for the purposes
	 *            of debugging. If <code>false</code>, then the launch is
	 *            simply because the user wants to run the movie but not debug
	 *            it; in that case, the return value of this function will be
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
	 *            Will only be called if forDebugging is false.  (If forDebugging
	 *            is true, error conditions are handled by throwing an exception.)
	 *			  The callback will be called on a different thread.
	 * @return a Session to use for debugging, or null if forDebugging==false.
	 *         The return value is not used to indicate an error -- exceptions
	 *         are used for that. If this function returns without throwing an
	 *         exception, then the return value will always be non-null if
	 *         forDebugging==true, or null if forDebugging==false.
	 * @throws BindException
	 *             if <code>isListening()</code> == false
	 * @throws FileNotFoundException
	 *             if file cannot be located
	 * @throws CommandLineException
	 *             if the program that was launched exited unexpectedly. This
	 *             will be returned, for example, when launching an AIR
	 *             application, if adl exits with an error code.
	 *             CommandLineException includes functions to return any error
	 *             text that may have been sent to stdout/stderr, and the exit
	 *             code of the program.
	 * @throws IOException 
	 * 				Exception during launch.
	 */
	public Session launch(String uri, AIRLaunchInfo airLaunchInfo,
			boolean forDebugging, IProgress waitReporter, ILaunchNotification launchNotification, ILauncher launcher) throws IOException;

}
