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

package macromedia.asc.semantics;

import macromedia.asc.util.*;

/**
 * The value class from which all other values derive. Immediate
 * children are ObjectValue, and ReferenceValue.
 *
 * @author Jeff Dyer
 */
public abstract class Value
{
    protected int flags;

    public static final int HAS_VALUE_Flag        = 1;
    public static final int HAS_METHOD_INDEX_Flag = 2;
    public static final int HAS_QUALIFIER_Flag    = 4;
    public static final int IS_PACKAGE_Flag       = 8;
    public static final int IS_ATTRID_Flag        = 16;
    public static final int TYPE_ANNOTATION_Flag      = 32;
    public static final int KIND_Mask             = 0x0000FF00;
    public static final int KIND_Shift            = 8;
    public static final int SCOPE_INDEX_Mask      = 0xFFFF0000;
    public static final int SCOPE_INDEX_Shift     = 16;    
    
	public Value()
	{
        //macromedia.asc.parser.Node.tally(this);
	}

	public Value getValue(Context context)
	{
		return this;
	}

	public TypeInfo getType(Context context)
	{
		return null;
	}

	public int getTypeId()
	{
		return 0;
	}

	public boolean isReference()
	{
		return false;
	}

	public String toString()
	{
		return "";
	}

    public boolean booleanValue()
    {
    	return false;
    }
    
    public String getPrintableName()
    {
		return super.toString();
	}

	public boolean hasValue()
	{
		return false;
	}
}
