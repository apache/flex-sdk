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

import java.io.File;

/**
 * @author mmorearty
 */
public class AIRLaunchInfo
{
	/**
	 * Full path to the AIR Debug Launcher, <code>adl.exe</code> (Windows) or
	 * <code>adl</code> (Mac/Linux).  This is mandatory.
	 */
	public File airDebugLauncher;

	/**
	 * The directory that has runtime.dll, or <code>null</code> to
	 * use the default.
	 */
	public File airRuntimeDir;

	/**
	 * The filename of the security policy to use, or <code>null</code> to
	 * use the default.
	 */
	public File airSecurityPolicy;

	/**
	 * The directory to specify as the application's content root, or
	 * <code>null</code> to not tell ADL where the content root is, in which
	 * case ADL will use the directory of the application.xml file as the
	 * content root.
	 */
	public File applicationContentRootDir;

	/**
	 * Array of command-line arguments for the user's program. These are
	 * specific to the user's program; they are not processed by AIR itself,
	 * just passed on to the user's app.
	 * <p>
	 * Note, this class has both <code>applicationArgumentsArray</code> and
	 * {@link #applicationArguments}. <code>applicationArgumentsArray</code>
	 * accepts an array of arguments, and passes them down as-is to the
	 * operating system. <code>applicationArguments</code> takes a single
	 * string, splits it into arguments, and passes the result to the operating
	 * system. You can use whichever one is more convenient for you; typically,
	 * one of these would be <code>null</code>. If both are non-
	 * <code>null</code>, then <code>applicationArgumentsArray</code> takes
	 * precedence, and <code>applicationArguments</code> is ignored.
	 */
	public String[] applicationArgumentsArray;

	/**
	 * Command-line arguments for the user's program. These are specific to the
	 * user's program; they are not processed by AIR itself, just passed on to
	 * the user's app.
	 * <p>
	 * Note, see the comment above on {@link #applicationArgumentsArray}.
	 */
	public String applicationArguments;

	/**
	 * The publisher ID to use; passed to adl's "-pubid" option.  If
	 * null, no pubid is passed to adl.
	 */
	public String airPublisherID;

	/**
	 * The profile to pass to AIR 2.0's "-profile" argument, or null to omit 
	 * the "-profile" argument.
	 */
	public String profile;
	
	/**
	 * The screensize argument to pass to AIR 2.0's "-screensize" option.
	 * A colon separated string indicating width and height of the screen
	 * in normal and fullscreen modes. Only relevant in the mobileDevice 
	 * profile.
	 */
	public String screenSize;
	
	/**
	 * The dpi argument to pass to AIR 2.5's "-xscreenDPI" option.
	 * TODO: this is apparently only going to be used in 2.5
	 */
	public int dpi;
	
	/**
	 * The version platform argument to pass to AIR's "-XversionPlatform"
	 * option. This overrides the three characters in Capabilities.os only
	 * for the runtime in the AIR SDK.
	 */
	public String versionPlatform;
	
	/**
	 * Directory to load native extensions from. Corresponds to the
	 * -extdir argument of ADL.
	 */
	public String extDir;

	/**
	 * Directory to load native extensions from for devices. Corresponds to the
	 * -XdeviceExtDir argument of ADL.
	 */
	public String deviceExtDir;
}
