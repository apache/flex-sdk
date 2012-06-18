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

package macromedia.asc.embedding.avmplus;

import macromedia.asc.semantics.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.parser.Tokens.*;

/**
 * Instance builder.
 *
 * @author Jeff Dyer
 */
public class InstanceBuilder extends Builder
{
	public boolean has_ctor;
	public boolean calls_super_ctor;
	public String ctor_name;
    public InstanceBuilder basebui;
    public boolean canEarlyBind = true;

    public ObjectList<ReferenceValue> interface_refs = new ObjectList<ReferenceValue>();

	public InstanceBuilder(final QName classname)
	{
		has_ctor = false;
		calls_super_ctor = false;
        basebui = null;
		local_method_count = 0;
		this.classname = classname;
	}

	public void build(Context cx, ObjectValue ob)
	{
		objectValue = ob;
		contextId = cx.getId();
        var_offset = 0;
        reg_offset = 1; // this, in iinit
    }

	public int Variable(Context cx, ObjectValue ob)
	{
		// If building an intrinsic instance or inheriting from one,
		// then do nothing here.

		if( is_intrinsic /*|| basebui!=0 && basebui->is_intrinsic*/ )
		{
			return 0;
		}

		// front-end

		int var_id = super.Variable(cx,ob);

		// back-end

		return var_id;

	}

	/*
	Allocate a method id for a method. Search the base instance methods
	to see if this method name has already been allocated an id. It is
	an error for two methods with incompatible signatures to share the
	same method id.
	*/

	public int Method(Context cx, ObjectValue ob, final String name, Namespaces namespaces, boolean is_intrinsic)
	{
		if( this.is_intrinsic || is_intrinsic )
        {
            return -1;
        }

		int method_id = GetMethodId(cx, name, namespaces);

        if( method_id > method_count )
        {
            method_count = method_id;
        }

		return method_offset+method_id;
	}

	public int ExplicitGet(Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
	{
		int slot_id = ob.addMethodSlot(cx,type);
		CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,GET_TOKEN,name,namespaces,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setMethodID(-1);   // erase the method_id
		}

		// do backend binding

//		if( method_id >= 0 )
		{
			for (ObjectValue n : namespaces)
			{
				Name(cx, GET_TOKEN, name, n);
			}
		}

		return slot_id;
	}

	public int ExplicitSet(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
	{
		int slot_id = ob.addMethodSlot(cx,type);
		CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineName(cx,SET_TOKEN,name,ns,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setMethodID(-1);   // erase the method_id
		}

//		if( method_id > 0 )
		{
			Name(cx,SET_TOKEN,name,ns);
		}

		return slot_id;

	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id)
	{
		return ExplicitSet(cx, ob, name, namespaces, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id)
	{
		int slot_id = ob.addMethodSlot(cx,type);
		CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,SET_TOKEN,name,namespaces,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setMethodID(-1);   // erase the method_id
		}

		// do backend binding

//		if( method_id > 0 )
		{
			for (ObjectValue n : namespaces)
			{
				Name(cx,SET_TOKEN,name,n);
			}
		}

		return slot_id;
	}

	public int ExplicitVar(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id)
	{
		return ExplicitVar(cx, ob, name, ns, type, expected_id, -1, -1);
	}

	public int ExplicitVar(Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id, int method_id, int var_id)
	{
		int slot_id = ob.addVariableSlot(cx,type,var_id);
        ob.getSlot(cx,slot_id).addType(type.getDefaultTypeInfo());
        CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineName(cx,GET_TOKEN,name,ns,slot_id);
		ob.defineName(cx,SET_TOKEN,name,ns,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setVarIndex(-1);   // erase the var_index
		}

//		if( var_id >= 0 )
		Name(cx,VAR_TOKEN,name,ns);
		return slot_id;
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, int expected_id)
	{
		return ExplicitVar(cx, ob, name, namespaces, type, expected_id, -1, -1);
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, int expected_id, int method_id , int var_id )
	{
		int slot_id = ob.addVariableSlot(cx,type,var_id);
        ob.getSlot(cx,slot_id).addType(type.getDefaultTypeInfo());
        CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineNames(cx,GET_TOKEN,name,namespaces,slot_id);
		ob.defineNames(cx,SET_TOKEN,name,namespaces,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setVarIndex(-1);   // erase the var_index
		}

		// do backend binding

//		if( var_id >= 0 )
			for (ObjectValue n : namespaces)
			{
				Name(cx,VAR_TOKEN,name,n);            
			}

		return slot_id;
	}

    public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
    {
        // Do the frontend binding

        int slot_id = super.ExplicitGet(cx,ob,name,namespaces,cx.functionType(),is_final,is_override,expected_id,method_id,var_id);
		ob.getSlot(cx, slot_id).setGetter(false);
        int implied_id = ob.addSlotImplicit(cx,slot_id,EMPTY_TOKEN,type);  // ISSUE: clean up

		if( is_final ) // its final
        {
            ob.getSlot(cx,implied_id).setDispatchKind(DISPATCH_final);
        }
        else
        {
            ob.getSlot(cx,implied_id).setDispatchKind(DISPATCH_virtual);
        }

		Slot slot = ob.getSlot(cx,implied_id);
		ob.getSlot(cx,implied_id).attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);
		slot.setMethodName("temp$"+classname+"$"+name);
		slot.setGetter(false);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setMethodID(-1);   // erase the method_id
		}

        // Do the backend binding

//        if( method_id >= 0 )
		for (ObjectValue n : namespaces)
		{
			Name(cx, EMPTY_TOKEN, name, n);
		}

         return slot_id;
     }

    public int ExplicitCall( Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id)
    {
        // Do the frontend binding

        int slot_id = super.ExplicitGet(cx,ob,name,ns,cx.functionType(),is_final,is_override,expected_id,method_id,var_id);
		ob.getSlot(cx, slot_id).setGetter(false);
        int implied_id = ob.addSlotImplicit(cx,slot_id,EMPTY_TOKEN,type);  // ISSUE: clean up

		if( is_final ) // its final
        {
            ob.getSlot(cx,implied_id).setDispatchKind(DISPATCH_final);
        }
        else
        {
            ob.getSlot(cx,implied_id).setDispatchKind(DISPATCH_virtual);
        }

		Slot slot = ob.getSlot(cx,implied_id);
		ob.getSlot(cx,implied_id).attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);
		slot.setMethodName("temp$"+classname+"$"+name);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setMethodID(-1);   // erase the method_id
		}

        // Do the backend binding

		Name(cx, EMPTY_TOKEN, name, ns);

        return slot_id;
     }


	public void ImplicitCall(Context cx, ObjectValue ob, int slot_id, TypeValue type, int call_seq, int method_id, int expected_id)
	{
		// Do the frontend binding

		super.ImplicitCall(cx, ob, slot_id, type, call_seq, method_id, expected_id);
	}
}
