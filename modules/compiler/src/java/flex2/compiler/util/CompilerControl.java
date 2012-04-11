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

package flex2.compiler.util;

/**
 * A utility class primarily used to short circuit compilation, like
 * when an IDE wants to abort a compilation and start over after a
 * file has changed.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class CompilerControl
{
	public static final int RUN = 1;
	public static final int PAUSE = 2;
	public static final int STOP = 4;
	
	public CompilerControl()
	{
		run();
	}
	
	private int status;
	
	public void run()
	{
		status = RUN;
	}
	
	public void pause()
	{
		status = PAUSE;
	}
	
	public void stop()
	{
		status = STOP;
	}
	
	public int getStatus()
	{
		return status;
	}
}
