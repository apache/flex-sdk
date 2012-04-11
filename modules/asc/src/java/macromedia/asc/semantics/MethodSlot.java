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

public class MethodSlot extends Slot
{
	public MethodSlot(TypeInfo type, int id)
	{
		super(type, id);
	}

    public MethodSlot(TypeValue type, int id)
    {
        super(type, id);
    }

	public String getMethodName()
	{
		return method_name;
	}
	
	public void setMethodName(String method_name)
	{
		this.method_name = method_name;
	}
	
	public int getMethodID()
	{
		return method_id;
	}
	
	public void setMethodID(int method_id)
	{
		this.method_id = method_id;
	}

	public void setDeclStyles(ByteList decl_styles)
	{
		this.decl_styles = decl_styles;
	}

	public ByteList getDeclStyles()
	{
		return decl_styles;
	}

	public void addDeclStyle(int style)
	{
		if (decl_styles == null)
			decl_styles = new ByteList(2);
		decl_styles.push_back((byte)style);
	}

	public void setVarIndex(int var_index)
	{
		throw new IllegalArgumentException();
	}

	public int getVarIndex()
	{
		return -1;
	}

	public void setTypeRef(ReferenceValue typeref)
	{
		throw new IllegalArgumentException();
	}
	
	public ReferenceValue getTypeRef()
	{
		return null;
	}

	private String method_name = "";
	private int method_id = -1;
    private ByteList decl_styles; // for functions, vector of PARAM_REQUIRED, PARAM_Optional, or PARAM_Rest
}
