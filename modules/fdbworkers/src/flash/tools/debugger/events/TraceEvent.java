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
 * Trace is a special operation by the player that
 * allows text strings to be displayed during the
 * execution of some ActionScript.  
 * <p>
 * The event provides notification that a trace 
 * statement was encountered. The info string 
 * contains the contenxt of the trace message.
 */
public class TraceEvent extends DebugEvent
{
	public TraceEvent(String s) { super(s); }
}
