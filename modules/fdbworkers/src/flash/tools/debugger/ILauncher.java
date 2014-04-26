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

/**
 * A ILauncher which handles the launching of the URI or the command.
 * 
 * ILauncher is to provide more flexibility to handle the Player launch in different platforms.
 * 
 * @author ugs
 *
 */
public interface ILauncher {

	/**
	 * Launches the debug target. 
	 * 
	 * @param cmd - Launch URL and other arguments
	 * @return A handle to the process.
	 * 
	 * @throws IOException
	 */
	public Process launch(String[] cmd) throws IOException;

	/**
	 * Terminate the process started by launch method.
	 * @param process - process started by launch.
	 * @throws IOException
	 */
	public void terminate(Process process) throws IOException;
	
	
}
