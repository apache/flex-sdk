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

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.ActionFactory;
import flash.swf.ActionConstants;

/**
 * Represents an AS2 "push" byte code.
 *
 * @author Clement Wong
 */
public class Push extends Action
{
    public Push()
	{
		super(ActionConstants.sactionPush);
	}

	public Push(Object value)
	{
		this();
		this.value = value;
	}

    public void visit(ActionHandler h)
	{
		h.push(this);
	}

    /** the value to push */
    public Object value;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof Push))
        {
            Push push = (Push) object;

            if ( equals(push.value, this.value))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

	public static int getTypeCode(Object value)
	{
	    if (value == null) return kPushNullType;
	    if (value == ActionFactory.UNDEFINED) return kPushUndefinedType;
		if (value instanceof String)  return kPushStringType;
		if (value instanceof Float)  return kPushFloatType;
		if (value instanceof Byte)  return kPushRegisterType;
		if (value instanceof Boolean)  return kPushBooleanType;
		if (value instanceof Double)  return kPushDoubleType;
		if (value instanceof Integer)  return kPushIntegerType;
		if (value instanceof Short)
			return ((((Short)value).intValue() & 0xFFFF) < 256) ? kPushConstant8Type : kPushConstant16Type;
		assert (false);
	    return kPushStringType;
	}
}
