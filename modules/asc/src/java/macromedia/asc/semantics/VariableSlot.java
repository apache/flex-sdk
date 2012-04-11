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

package macromedia.asc.semantics;

import macromedia.asc.util.ByteList;

public class VariableSlot extends Slot
{
	public VariableSlot(TypeInfo type, int id, int var_index)
	{
		super(type, id);
		this.var_index = var_index;
	}

    public VariableSlot(TypeValue type, int id, int var_index)
    {
        super(type, id);
        this.var_index = var_index;
    }

	public int getVarIndex()
	{
		return var_index;
	}
	
	public void setVarIndex(int var_index)
	{
		this.var_index = var_index;
	}
	
	public void setTypeRef(ReferenceValue typeref)
	{
		this.typeref = typeref;
	}

	public ReferenceValue getTypeRef()
	{
		return typeref;
	}

    public void setType(TypeInfo type)
    {
        // This means the typeref has now been resolved, so we can clear out
        // the RefVal ptr so it can be GC'ed
        this.typeref = null;
        super.setType(type);
    }

	public void setMethodID(int method_id)
	{
		if (method_id != -1)
		{
			throw new IllegalArgumentException();
		}
	}
	
	public int getMethodID()
	{
		return -1;
	}

	public void setMethodName(String method_name)
	{
		setAuxData(AUX_MethodName, method_name);
	}

	public String getMethodName()
	{
		String method_name = (String)getAuxData(AUX_MethodName);
		return (method_name != null) ? method_name : "";
	}

	public void setDeclStyles(ByteList decl_styles)
	{
		throw new IllegalArgumentException();
	}
	
	public ByteList getDeclStyles()
	{
		return null;
	}
	
	public void addDeclStyle(int style)
	{
		// ignore
	}

    public Value getValue()
	{
        // cn:  initializer values for instance variables are apparently stored in the slot's value, but they aren't
        //  compile time constants.  getValue()/getObjectValue() is  used in the compiler to get
        //  compile time constant values for slots, however, so don't return the value unless this is a const.
        return (this.isConst() ? super.getValue() : null);
	}

    public ObjectValue getInitializerValue()
    {
        // cn: see comment above.  This gets the initializer value regardless of const-ness.
        return (ObjectValue)(super.getValue());
    }

	private int var_index;
	private ReferenceValue typeref;
}
