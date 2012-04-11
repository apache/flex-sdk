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

package flash.swf.tags;

import flash.swf.Tag;
import flash.swf.TagHandler;

/**
 * Represents a DoABC SWF tag.  This is used by AS3.
 *
 * @author Clement Wong
 */
public class DoABC extends Tag
{
    public DoABC(String name, int flag)
    {
        super(stagDoABC2);
        abc = new byte[0];
        this.name = name;
        this.flag = flag;
    }
	public DoABC()
	{
		super(stagDoABC);
		abc = new byte[0];
        name = null;
        flag = 1;
	}

	public void visit(TagHandler h)
	{
		h.doABC(this);
	}

	public byte[] abc;
    public String name;
    public int flag;

	public boolean equals(Object object)
	{
		boolean isEqual = false;

		if (super.equals(object) && (object instanceof DoABC))
		{
			DoABC doABC = (DoABC) object;

			if (equals(doABC.abc, this.abc) && equals(doABC.name, this.name) && doABC.flag == this.flag)
			{
				isEqual = true;
			}
		}

		return isEqual;
	}

	public int hashCode()
	{
		return super.hashCode() + DefineTag.PRIME * abc.hashCode() & name.hashCode() + flag;
	}
}
