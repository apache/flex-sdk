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

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.parser.Tokens.*;

import java.util.Iterator;

/**
 * A class object is a factory for instances of that class.
 *
 * A class object has two special internal properties: prototype, and
 * instance traits. The class object uses these two properties to
 * initialize the instances it creates.
 *
 * Like other objects, a class object has its own traits object.
 * That traits object contains the names of the class's static
 * defintions. Those names have bindings to global slots and global
 * methods. Class objects have no instance slots.
 *
 * There a various kinds of bindings that can be added to an object:
 * + local slot
 * + local method
 * + local accessor pair
 * + global slot
 * + global method
 * + global accessor pair

 * The class object builder adds the global versions of these
 * bindings to the class object symbol table. Specifically,

 * class A {
 * static var x                 // adds a global slot binding
 * static function f() {}       // adds a global method binding
 * static function get y() {}   // adds a global get accessor
 * static function set y(v) {}  // adds a global set accessor
 * }
 *
 * @author Jeff Dyer
 */
public class ClassBuilder extends Builder
{
	public ClassBuilder basebui;
	public boolean is_interface;
    public ObjectValue protected_namespace; // alias to namespace created by CDN
    public ObjectValue static_protected_namespace; // alias to namespace created by CDN

	public ClassBuilder(QName classname, ObjectValue protected_namespace, ObjectValue static_protected_namespace)
	{
		basebui = null;
		is_interface = false;
		this.classname = classname;
        this.protected_namespace = protected_namespace;
        this.static_protected_namespace = static_protected_namespace;        
	}

	public void build(Context cx, ObjectValue ob)
	{
		objectValue = ob;
		contextId = cx.getId();
        if( "Class".equals(classname.toString()) )
        {
            return;
        }
        
        var_offset = 0;
        reg_offset = 1; // this, in cinit

		// private : Attribute
		Namespaces nss = new Namespaces(1);
		nss.push_back(cx.publicNamespace());

        // use up the first two disp_id's because Class has two instance methods (get/set prototype)
        // ISSUE is there a way to do this from the actual definition of Class instead of hardcoding?
		// FIXME: move these to a shared base class?
        int meth_id = Method(cx, ob, "prototype$get", nss, false);
        ExplicitGet(cx, ob, "prototype", nss, null, true, false, -1, meth_id, -1);
        Method(cx, ob, "prototype$set", nss, false);
    }

    public int Variable( Context cx, ObjectValue ob )
    {

        // If building an intrinsic instance, then do nothing here.

        if( is_intrinsic /*|| basebui!=0 && basebui->is_intrinsic*/ )
        {
            return -1;
        }

        // front-end

        int var_id = super.Variable(cx,ob);

        // back-end

        return var_id;
    }



	public int Method(Context cx, ObjectValue ob, final String name, Namespaces namespaces, boolean is_intrinsic )
	{
		if( this.is_intrinsic || is_intrinsic )
        {
            return -1;
        }
		return GetMethodId(cx,name,namespaces);
	}

	public void ImplicitCall( Context cx, ObjectValue ob, int slot_id, TypeValue type, int call_seq, int method_id, int expected_id )
	{
		// Do the frontend binding

		super.ImplicitCall(cx,ob,slot_id,type,call_seq,method_id,expected_id);
	}

	public int ExplicitGet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override )
	{
		return ExplicitGet(cx, ob, name, namespaces, type, is_final, is_override, -1, -1, -1);
	}

	public int ExplicitGet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id , int method_id , int var_id  )
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
			for (ObjectValue it : namespaces)
			{
				Name(cx,GET_TOKEN,name,it);
			}
		}

		return slot_id;
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id)
	{
		return ExplicitSet(cx, ob, name, ns, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id )
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

//		if( method_id >= 0 )
		{
			Name(cx,SET_TOKEN,name,ns);
		}

		return slot_id;
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id)
	{
		return ExplicitSet(cx, ob, name, namespaces, type, is_final, is_override, expected_id, -1, -1);
	}

	public int ExplicitSet( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id  )
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

//		if( method_id >= 0 )
		{
			for (Iterator<ObjectValue> it = namespaces.iterator(); it.hasNext();)
			{
				Name(cx,SET_TOKEN,name,it.next());
			}
		}

		return slot_id;
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id)
	{
		return ExplicitVar(cx, ob, name, ns, type, expected_id, -1, -1);
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, ObjectValue ns, TypeValue type, int expected_id, int method_id , int var_id  )
	{
		int slot_id = ob.addVariableSlot(cx,type,var_id);
        ob.getSlot(cx,slot_id).addType(type.getDefaultTypeInfo());
        CHECK_SLOT_INDEX(expected_id,slot_id);
		ob.defineName(cx,GET_TOKEN,name,ns,slot_id);
		Slot slot = ob.getSlot(cx,slot_id);
		slot.attrs(CALL_ThisMethod,method_id);

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setVarIndex(-1);   // erase the var_index
		}

//		if( var_id >= 0 )
		{
			Name(cx,VAR_TOKEN,name,ns);
		}
		return slot_id;
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, int expected_id)
	{
		return ExplicitVar(cx, ob, name, namespaces, type, expected_id, -1, -1);
	}

	public int ExplicitVar( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, int expected_id, int method_id , int var_id  )
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
		{
			for (Iterator<ObjectValue> it = namespaces.iterator();it.hasNext();)
			{
				Name(cx,VAR_TOKEN,name,it.next());
			}
		}

		return slot_id;
	}

	public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id , int var_id )
    {

        // Do the frontend binding

        int slot_id = super.ExplicitGet(cx,ob,name,namespaces,cx.functionType(),true,false,expected_id,method_id,var_id);
        ob.getSlot(cx, slot_id).setGetter(false);
        int implied_id = ob.addSlotImplicit(cx,slot_id,EMPTY_TOKEN,type);  // ISSUE: clean up

		Slot slot = ob.getSlot(cx,implied_id);
        ob.getSlot(cx,implied_id).attrs(CALL_ThisMethod,method_id);
		slot.setFinal(is_final);
		slot.setOverride(is_override);
		slot.setMethodName(classname+"$"+name);
		slot.setGetter(false);
							// this isn't right

		if( is_intrinsic || basebui!=null && basebui.is_intrinsic )
		{
			slot.setMethodID(-1);   // erase the method_id
		}

        // Do the backend binding

//        if( method_id >= 0 )
        {
			for (Iterator<ObjectValue> it = namespaces.iterator();it.hasNext();)
			{
				Name(cx,EMPTY_TOKEN,name,it.next());
			}
         }

         return slot_id;
     }

}
