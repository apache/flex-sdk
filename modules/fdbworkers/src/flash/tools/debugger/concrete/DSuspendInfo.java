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

package flash.tools.debugger.concrete;

import flash.tools.debugger.SuspendReason;

/**
 * The suspend information object returns information about the
 * current halted state of the Player.
 */
public class DSuspendInfo
{
	int m_reason;
	int m_actionIndex;  // which script caused the halt
	int m_offset;		// offset into the actions that the player has halted
	int m_previousOffset;  // previous offset, if any, which lies on the same source line (-1 means unknown)
	int m_nextOffset;  // next offset, if any, which lies on the same source line (-1 means unknown)

	public DSuspendInfo()
	{
		m_reason = SuspendReason.Unknown;
		m_actionIndex =	-1;
		m_offset = -1;	
		m_previousOffset = -1;
		m_nextOffset = -1;
	}

	public DSuspendInfo(int reason, int actionIndex, int offset, int previousOffset, int nextOffset)
	{
		m_reason = reason;
		m_actionIndex =	actionIndex;
		m_offset = offset;	
		m_previousOffset = previousOffset;
		m_nextOffset = nextOffset;
	}

    public int getReason()			{ return m_reason; }
	public int getActionIndex()		{ return m_actionIndex; }
    public int getOffset()			{ return m_offset; }
	public int getPreviousOffset()	{ return m_previousOffset; }
	public int getNextOffset()		{ return m_nextOffset; }
}
