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

package flash.swf.debug;

import flash.swf.DebugHandler;
import flash.swf.types.FlashUUID;
import flash.util.IntMap;

/**
 * Info gleaned from a debuggable flash movie (SWF+SWD)
 *
 * @author Edwin Smith
 */
public class DebugTable
        implements DebugHandler
{
    public FlashUUID uuid;
    public int version;
    public IntMap lines;
	public IntMap registers;

    public DebugTable()
    {
        lines = new IntMap();
        registers = new IntMap();
    }

    public void breakpoint(int offset)
    {
    }

    public void header(int version)
    {
        this.version = version;
    }

    public void module(DebugModule dm)
    {
    }

    public void offset(int offset, LineRecord lr)
    {
        lines.put(offset, lr);
    }

    public void registers(int offset, RegisterRecord r)
    {
        registers.put(offset, r);
    }

    public void uuid(FlashUUID id)
    {
        this.uuid = id;
    }

    public LineRecord getLine(int offset)
    {
        return (LineRecord) lines.get(offset);
    }

    public RegisterRecord getRegisters(int offset)
    {
        return (RegisterRecord) registers.get(offset);
    }

	public void error(String msg)
	{
	}
}
