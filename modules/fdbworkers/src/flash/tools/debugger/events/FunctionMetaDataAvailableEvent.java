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
 * Notification that function information for
 * all SoruceFiles is now available for access.
 * 
 * Prior to this notification the following 
 * calls to SourceFile will return null or 0 values:
 * 
 *	public String getFunctionNameForLine(int lineNum);
 *	public int getLineForFunctionName(String name);
 *	public String[] getFunctionNames();
 *
 * This is due to the fact the function data is processed
 * by a background thread and may take many hundreds of 
 * milliseconds to complete.
 * @deprecated As of Version 2.  No replacement
 */
public class FunctionMetaDataAvailableEvent extends DebugEvent
{
}
