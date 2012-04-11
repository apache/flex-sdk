/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
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
