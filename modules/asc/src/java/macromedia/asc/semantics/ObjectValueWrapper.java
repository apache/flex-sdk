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

import macromedia.asc.util.*;

/**
 */
public class ObjectValueWrapper extends ObjectValue
{
    private ObjectValue wrapped;
    public ObjectValueWrapper(ObjectValue wrapped)
    {
        super();
        this.wrapped = wrapped;
    }

    public boolean removeName(Context cx, int kind, String name, ObjectValue qualifier)
    {
        return wrapped.removeName(cx,kind,name,qualifier);
    }

    public boolean hasName(Context cx, int kind, String name, ObjectValue qualifier)
    {
        return wrapped.hasName(cx,kind,name,qualifier);
    }

    public boolean hasNameUnqualified(Context cx,  String name, int kind)
    {
        return wrapped.hasNameUnqualified(cx, name, kind);
    }
    public Namespaces hasNames(Context cx, int kind, String name, Namespaces namespaces)
    {
        return wrapped.hasNames(cx, kind, name, namespaces);
    }

    public Slot get(Context cx, String name, ObjectValue qualifier)
    {
        return wrapped.get(cx, name, qualifier);
    }
/* Unused
    public void setVar(Context cx, int var_index, Value val)
    {
        wrapped.setVar(cx, var_index, val);
    }

    public Value getVar(Context cx, int var_index)
    {
        return wrapped.getVar(cx, var_index);
    }
*/
    public int defineName(Context cx, int kind, String name, ObjectValue qualifier, int slot_index)
    {
        return wrapped.defineName(cx,kind,name,qualifier,slot_index);
    }

	public Names getNamesAndCreate()
	{
        return wrapped.getNamesAndCreate();
	}

    public boolean defineNames(Context cx, int kind, String name, Namespaces namespaces, int slot_index)
    {
        return wrapped.defineNames(cx, kind, name, namespaces, slot_index);
    }
/*
    final public int addVariableSlot(Context cx, TypeValue type, int var_index)
    {
        if (slots == null) {
            slots = new Slots();
            // reserve first slot
            //slots.put(nullSlot.id,nullSlot);
        }
        Slot newSlot = new VariableSlot(type, cx.statics.getNextSlotID(), var_index);
        newSlot.declaredBy = this;
        slots.put(newSlot);
        return newSlot.id;
    }

    final public int addMethodSlot(Context cx, TypeValue type)
    {
        if (slots == null) {
            slots = new Slots();
            // reserve first slot
            //slots.put(nullSlot.id,nullSlot);
        }
        Slot newSlot = new MethodSlot(type, cx.statics.getNextSlotID());
        newSlot.declaredBy = this;
        slots.put(newSlot);
        return newSlot.id;
    }

    final public void addSlot(Slot slot)
    {
        if (slots == null)
        {
            slots = new Slots();
        }
        slots.put(slot);
    }

    final public int addSlotImplicit(Context cx, int slot_index, int kind, TypeValue type)
    {
        final int index = addMethodSlot(cx, type);
        getSlot(cx, slot_index).implicit(kind, index);
        // Set the expected type of the operands.
        return index;
    }

    final public int addSlotOverload(Context cx, int slot_index, TypeValue type, TypeValue t1)
    {
        int index = addMethodSlot(cx, type);
        getSlot(cx, slot_index).overload(t1, index);
        // Set the expected type of the operands.
        Slot slot = getSlot(cx, index);
        slot.addType(t1.getDefaultTypeInfo());
        return index;
    }

    final public int addSlotOverload(Context cx, int slot_index, TypeValue type, TypeValue t1, TypeValue t2)
    {
        int index = addMethodSlot(cx, type);
        getSlot(cx, slot_index).overload(t1, t2, index);
        // Set the expected types of the operands.
        Slot slot = getSlot(cx, index);
        slot.addType(t1.getDefaultTypeInfo());
        slot.addType(t2.getDefaultTypeInfo());
        return index;
    }
*/

    public Slot getSlot(Context cx, int index)
    {
        return wrapped.getSlot(cx, index);
    }

    public int getSlotIndex(Context cx, int kind, String name, ObjectValue qualifier)
    {
        return wrapped.getSlotIndex(cx, kind, name, qualifier);
    }

    public int getImplicitIndex(Context cx, int slot_index, int kind)
    {
        return wrapped.getImplicitIndex(cx, slot_index, kind);
    }

    public int getOverloadIndex(Context cx, int slot_index, TypeValue t1)
    {
        return wrapped.getOverloadIndex(cx, slot_index, t1);
    }

    public int getOverloadIndex(Context cx, int slot_index, TypeValue t1, TypeValue t2)
    {
        return wrapped.getOverloadIndex(cx, slot_index, t1, t2);
    }
/*
    public int addVar(Context cx)
    {
        return var_count++;
    }
    public int addMethod(Context cx)
    {
        return method_count++;
    }

    public int getFirstSlotIndex()
    {
        return 0;
    }

*/
    public ObjectValue proto()
    {
        return wrapped.proto();
    }

    public TypeInfo getType(Context cx)
    {
        return this.type;
    }

    public boolean isDynamic() { return (builder != null ? builder.is_dynamic : false); }
    public boolean isFinal() { return (builder != null ? builder.is_final : false); }
/*
    private HashMap<TypeValue,ClassDefinitionNode> deferredClassMap;

    public HashMap<TypeValue,ClassDefinitionNode> getDeferredClassMap()
    {
        if (deferredClassMap == null)
        {
            deferredClassMap = new HashMap<TypeValue,ClassDefinitionNode>();
        }
        return deferredClassMap;
    }

    public String toString() {
       if(Node.useDebugToStrings)
          return ("ObjVal: <" + type + "> " + (name != null ? name.toString() : "")
              + ((names != null && names.size()>0) ? "\nmethods: " + names.toString() : ""));
       else
          return getValue();
    }
*/
    public boolean isInterface()
    {
        return wrapped.isInterface();
    }

    public boolean canEarlyBind()
    {
        return wrapped.canEarlyBind();
    }

    public Names getNames()
    {
        return wrapped.getNames();
    }

    public String getValue()
    {
        return wrapped.getValue();
    }

    public void setValue(String value)
    {
        wrapped.setValue(value);
    }

    public boolean hasValue()
    {
        return wrapped.hasValue();
    }

    public boolean booleanValue()
    {
        return wrapped.booleanValue();
    }

    public void setPackage(boolean package_flag)
    {
        wrapped.setPackage(package_flag);
    }

    public boolean isPackage()
    {
        return wrapped.isPackage();
    }
/*
    // Namespace specific methods, these are only implemented in NamespaceValue.
    public boolean isInternal()
    {
        return wrapped.isInternal();
    }

    public boolean isProtected()
    {
        return false;
    }

    public boolean isPrivate()
    {
        return false;
    }

    public byte getNamespaceKind()
    {
        return Context.NS_PUBLIC;
    }
 */

}
