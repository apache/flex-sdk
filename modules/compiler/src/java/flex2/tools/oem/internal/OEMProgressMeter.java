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

package flex2.tools.oem.internal;

import flex2.tools.oem.ProgressMeter;

/**
 * A ProgressMeter implementation that outputs to System.out.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class OEMProgressMeter implements ProgressMeter
{
	public void end()
	{
		System.out.println("progress meter: end");
	}

	public void percentDone(int n)
	{
		System.out.println(n + "%");
	}

	public void start()
	{
		System.out.println("progress meter: start");
	}
}
