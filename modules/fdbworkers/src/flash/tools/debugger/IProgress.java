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

/**
 * A simple interface to report progress on some operation.
 * 
 * @author mmorearty
 */
public interface IProgress
{
	/**
	 * Reports how much work has been done.
	 * 
	 * @param current
	 *            how much progress has been made toward the total
	 * @param total
	 *            the total amount of work
	 */
	public void setProgress(int current, int total);
}
