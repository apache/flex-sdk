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

package macromedia.asc.util;

/**
 * @author Clement Wong
 */
public final class IntegerPool
{
	private static final Integer[] constants;
	private static final int max = 10000;
	private static final int min = 0;

	static
	{
		constants = new Integer[max-min];
		for (int i = 0; i < max-min; i++)
		{
			constants[i] = new Integer(i+min);
		}
	}

	public static Integer getNumber(int num)
	{
		return (num >= min && num < max) ? constants[num-min] : new Integer(num);
	}
}
