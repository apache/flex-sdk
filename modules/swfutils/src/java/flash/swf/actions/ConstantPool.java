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

package flash.swf.actions;

import java.util.Arrays;

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.ActionConstants;

/**
 * Represents an AS2 "contant pool" byte code.
 *
 * @author Clement Wong
 */
public class ConstantPool extends Action
{
	public ConstantPool()
	{
		super(ActionConstants.sactionConstantPool);
	}

	public ConstantPool(String[] poolData)
	{
	    this();
		pool = poolData;
	}

    public void visit(ActionHandler h)
	{
		h.constantPool(this);
	}

    public String[] pool;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof ConstantPool))
        {
            ConstantPool constantPool = (ConstantPool) object;

            if ( Arrays.equals(constantPool.pool, this.pool) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        sb.append("ConstantPool[ pool = { ");
        for (int i = 0; i < pool.length; i++)
        {
            sb.append(pool[i]);
            sb.append(", ");
        }
        sb.append("} ]");
        return sb.toString();
    }
}
