/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.embedding.avmplus;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Activation interface. An activation provides slot storage.
 *
 * @author Jeff Dyer
 */
public class ActivationBuilder extends Builder
{
	// public:

	public ActivationBuilder()
	{
	}

	public void build(Context cx, ObjectValue ob)
	{
		objectValue = ob;
		contextId = cx.getId();
	    var_offset = 0;
	    reg_offset = 1; // this
	}

    public int Method(Context cx, ObjectValue ob, final String name, Namespaces namespaces, boolean is_intrinsic)
    {
        // If building an intrinsic instance, then do nothing here
		if( this.is_intrinsic || is_intrinsic )
        {
            return -1;
        }

		return GetMethodId(cx,name,namespaces);
    }

	public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id )
	{
		// Do the frontend binding

		if( method_id >= 0 || var_id < 0 ) // this is secret code for: it is a real method (not intrinsic) that doesn't have an implementation yet
		{
			// allocate a new var
			var_id  = Variable(cx,ob);
		}
		// otherwise, reuse the one passed in

		TypeValue functionType = cx.useStaticSemantics() ? cx.functionType() : type;
		int slot_id = super.ExplicitVar(cx,ob,name,namespaces,functionType,expected_id,-1,var_id);

		return slot_id;
	}
}
