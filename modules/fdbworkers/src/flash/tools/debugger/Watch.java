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
 * The Watch object represents a single watchpoint within a Session
 * A watchpoint is a mechanism by which execution of the Player
 * can be halted when a particular variable is accessed.  The 
 * access type can be one of read, write or read/write.
 * @since Version 2
 */
public interface Watch
{
	/**
	 * Value id of the value whose member is being watched.
	 * For example if the watch is placed on 'a.b.c' then the id
	 * will be that of the value 'a.b'.  Session.getVariable()
	 * can be used to obtain the variable.  This combined with
	 * the memberName() forms the unique identifier for the Watch.
	 */
	public long getValueId();

	/**
	 * Name of variable member that is being watched.  
	 */
	public String getMemberName();

	/**
	 * The kind of watch placed on the variable being watched.
	 */
    public int getKind();
    
    /**
     * The isolate to which this watchpoint belongs.
     */
    public int getIsolateId();
}
