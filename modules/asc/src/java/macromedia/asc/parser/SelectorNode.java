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

package macromedia.asc.parser;

import macromedia.asc.semantics.*;
import static macromedia.asc.parser.Tokens.DOT_TOKEN; 

/**
 * Node
 *
 * @author Jeff Dyer
 */
public abstract class SelectorNode extends Node
{
	public ObjectValue base;
	private int flags;
    public ReferenceValue ref;    
    public Node expr;
    public boolean is_package;

    private static final int RVALUE_Flag      = 1;
    private static final int ATTR_Flag        = 2;
    private static final int SUPER_Flag       = 4;
    private static final int VOID_RESULT_Flag = 8;
    private static final int THIS_Flag        = 16;
    private static final int MODE_Shift       = 16;
    private static final int MODE_Mask        = 0xFFFF0000;

	public SelectorNode()
	{
		// don't set java defaults
		//base = null;
		//is_rvalue = false;
		//is_attr = false;
		//is_super = false;
		setMode(DOT_TOKEN);
	}

	public void setBase(ObjectValue base)
	{
		this.base = base;
	}
    public boolean isQualified() { return false; }
    public boolean isAttributeIdentifier() { return false; }
    public boolean isAny() { return false; }

	public void setRValue(boolean is_rvalue)
	{
		flags = is_rvalue ? (flags|RVALUE_Flag) : (flags&~RVALUE_Flag);
	}

	public boolean isRValue()
	{
		return (flags&RVALUE_Flag) != 0;
	}

	public void setAttr(boolean is_attr)
	{
		flags = is_attr ? (flags|ATTR_Flag) : (flags&~ATTR_Flag);
	}

	public boolean isAttr()
	{
		return (flags&ATTR_Flag) != 0;
	}

	public void setMode(int mode)
	{
		flags &= ~MODE_Mask;
		flags |= mode<<MODE_Shift;
	}

	public int getMode()
	{
		return flags>>MODE_Shift;
	}

    public void setSuper(boolean is_super)
    {
        flags = is_super ? (flags|SUPER_Flag) : (flags&~SUPER_Flag);
    }

    public boolean isSuper()
        {
            return (flags&SUPER_Flag) != 0;
        }

    public void setThis(boolean is_this)
    {
        flags = is_this ? (flags|THIS_Flag) : (flags&~THIS_Flag);
    }

    public boolean isThis()
        {
            return (flags&THIS_Flag) != 0;
        }

	public void voidResult()
	{
		flags |= VOID_RESULT_Flag;
	}

	public boolean isVoidResult()
	{
		return (flags & VOID_RESULT_Flag) != 0;
	}

	public IdentifierNode getIdentifier()
	{
		return (expr instanceof IdentifierNode) ? (IdentifierNode)expr : null;
	}
	private boolean skip = false;
	public void skipNode(boolean b)
	{
		skip = b;
	}

	public boolean skip()
	{
		return skip;
	}
}
