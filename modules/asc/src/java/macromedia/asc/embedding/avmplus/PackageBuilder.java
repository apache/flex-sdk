/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.embedding.avmplus;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.parser.Tokens.*;

/**
 * Package object builder.
 *
 * @author Jeff Dyer
 */
public class PackageBuilder extends Builder
{
    public PackageBuilder()
    {
    }

    public PackageBuilder(QName name)
    {
        classname = name;
    }

	public void build(Context cx, ObjectValue ob)
	{
		objectValue = ob;
		contextId = cx.getId();
		var_offset = 0;
		reg_offset = 1; // this, in init

		Builder globbui = new GlobalBuilder();
		globbui.build(cx, ob);
	}

    public int Variable( Context cx, ObjectValue ob )
    {

        // If building an intrinsic instance, then do nothing here.

        if( is_intrinsic )
        {
            return -1;
        }

        // front-end

        int var_id = super.Variable(cx,ob);

        // back-end

        return var_id;
    }

    public int Method(Context cx, ObjectValue ob, final String name, Namespaces namespaces)
    {
        return GetMethodId(cx,name,namespaces);
    }

	public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id)
	{
		return ExplicitCall(cx, ob, name, namespaces, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id )
	{
		// Do the frontend binding
		TypeValue functionType = cx.useStaticSemantics() ? cx.functionType() : type;
		int slot_id = super.ExplicitGet(cx,ob,name,namespaces,functionType,true/*is_final*/,false/*is_override*/,expected_id,-1,var_id);
        ob.getSlot(cx, slot_id).setGetter(false);
		int implied_id = ob.addSlotImplicit(cx,slot_id,EMPTY_TOKEN,type);  // ISSUE: clean up

		Slot slot = ob.getSlot(cx,implied_id);
		ob.getSlot(cx,implied_id).attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);
		slot.setMethodName(classname+"$"+name);
		slot.setGetter(false);
							// this isn't right

		// do backend binding

		if( method_id >= 0 )
		{
			for (ObjectValue n : namespaces)
			{
				Name(cx,EMPTY_TOKEN,name,n);            
			}
		}

		return slot_id;
	}
}
