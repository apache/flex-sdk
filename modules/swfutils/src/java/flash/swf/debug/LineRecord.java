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

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.types.ActionList;

/**
 * This class represents a AS2 "line record" byte code.
 */
public class LineRecord extends Action
{
	public LineRecord(int lineno, DebugModule module)
	{
		super(ActionList.sactionLineRecord);
		this.lineno = lineno;
		this.module = module;
	}

    public int lineno;
    public DebugModule module;

	public void visit(ActionHandler h)
	{
		h.lineRecord(this);
	}

    public String toString()
    {
        return module.name + ":" + lineno;
    }

    public boolean equals(Object object)
    {
        if (object instanceof LineRecord)
        {
            LineRecord other = (LineRecord) object;
            return super.equals(other) &&
                    other.lineno == this.lineno &&
                    equals(other.module, this.module);
        }
        else
        {
            return false;
        }
    }
}
