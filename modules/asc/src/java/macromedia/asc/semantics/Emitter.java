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

import macromedia.asc.util.ByteList;
import macromedia.asc.util.IntList;
import macromedia.asc.util.Context;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList; // for getTypeOfNumberLiteral
import macromedia.asc.util.NumberConstant;
import macromedia.asc.util.NumberUsage;

/**
 * Emitter
 *
 * @author Jeff Dyer
 */
public class Emitter
{
	private boolean doing_method;
	private boolean doing_class;
	private boolean doing_package;

	public Emitter()
	{
		this(null);
	}

	public Emitter(Emitter impl)
	{
		this.impl = impl;
		doing_method = false;
		doing_class = false;
		doing_package = false;
	}

	public int GetMethodInfo(final String name)
	{
		int n = -1;
		if (impl != null)
		{
			n = impl.GetMethodInfo(name);
		}
		return n;
	}

	public int GetMethodId(String name, Namespaces namespaces)
	{
		int n = -1;
		if (impl != null)
		{
			n = impl.GetMethodId(name, namespaces);
		}
		return n;
	}

	public ByteList emit(ByteList bytes)
	{
		if (impl != null)
		{
			impl.emit(bytes);
		}
		return bytes;
	}

	public NumberConstant getValueOfNumberLiteral(String str, TypeValue[] type, NumberUsage usage)
	{
		if (impl != null)
		{
			return impl.getValueOfNumberLiteral(str, type, usage);
		}
		return null;
	}

	public void setPosition(int lnNum, int colPos, int pos)
	{
		if (impl != null)
		{
			impl.setPosition(lnNum, colPos, pos);
		}
		else
		{
			this.lnNum = lnNum;  // Numbers are 1 based
			this.colPos = colPos;
			this.pos = pos;
		}
	}

    public void clearPositionInfo()
    {
        if( impl != null )
        {
            impl.clearPositionInfo();
        }
    }

	public void setOrigin(final String origin)
	{
		if (impl != null)
		{
			impl.setOrigin(origin);
		}
		else
		{
			this.origin = origin;
		}
	}

	public int getOriginAndPosition(String[] origin, int[] lnNum, int[] colPos)
	{
		if (impl != null)
		{
			return impl.getOriginAndPosition(origin, lnNum, colPos);
		}
		else
		{
			origin[0] = this.origin;
			lnNum[0] = this.lnNum;
			colPos[0] = this.colPos;
			return this.pos;
		}
	}

	protected Emitter impl;

	protected void DefineSlotVariable(Context cx, String debug_name, String function_debug_name, int pos, TypeInfo type, int slotIndex)
	{
		if (impl != null)
		{
			impl.DefineSlotVariable(cx, debug_name, function_debug_name, pos, type, slotIndex);
		}
	}

	protected void StartMethod()
	{
		StartMethod("", 0, 0, 0, false, 0);
	}

	protected void StartMethod(final String name, int param_count, int local_count)
	{
		StartMethod(name, param_count, local_count, 0, false, 0);
	}

	protected void StartMethod(final String name, int param_count, int local_count, int temp_count, boolean needs_activation, int needs_arguments)
	{
		doing_method = true;
		if (impl != null)
		{
			impl.StartMethod(name, param_count, local_count, temp_count, needs_activation, needs_arguments);
		}
	}

	protected int FinishMethod(Context cx, final String name, TypeInfo type, ObjectList<TypeInfo> types, ObjectValue activation, int needs_arguments, int scope_depth, String debug_name, boolean is_native, boolean is_interface, String[] arg_names)
	{
		doing_method = false;
		if (impl != null)
		{
			return impl.FinishMethod(cx,name,type,types,activation,needs_arguments,scope_depth,debug_name,is_native,is_interface, arg_names);
		}
		return 0;
	}

	protected void StartClass(final String name)
	{
		doing_class = true;
		if (impl != null)
		{
			impl.StartClass(name);
		}
	}

	protected void FinishClass(Context cx, final QName name, final QName basename, boolean is_dynamic, boolean is_final, boolean is_interface, boolean is_nullable)
	{
		doing_class = false;
		if (impl != null)
		{
			impl.FinishClass(cx, name, basename, is_dynamic, is_final, is_interface, is_nullable);
		}
	}

    protected void StartProgram(final String filename)
    {
        if (impl != null)
        {
            impl.StartProgram(filename);
        }
    }

    protected void FinishProgram(Context cx, final String name, int init_info)
    {
        if (impl != null)
        {
            impl.FinishProgram(cx, name, init_info);
        }
    }

    protected boolean doingMethod()
	{
		return doing_method;
	}

	protected boolean doingClass()
	{
		return doing_class;
	}

	protected boolean doingPackage()
	{
		return doing_package;
	}

	protected int allocateTemp()
	{
		if (impl != null)
		{
			return impl.allocateTemp();
		}
		return 0;
	}

	protected void freeTemp(int t)
	{
		if (impl != null)
		{
			impl.freeTemp(t);
		}
		return;
	}

	protected void Kill(int t)
	{
		if (impl != null)
		{
			impl.Kill(t);
		}
	}
	
	protected int getTempCount()
	{
		if (impl != null)
		{
			return impl.getTempCount();
		}
		return 0;
	}

	protected int getIP()
	{
		if (impl != null)
		{
			return impl.getIP();
		}
		return 0;
	}

	protected String origin;
	protected int lnNum;
	protected int colPos;
	protected int pos;

	/* Abstract Machine Language instructions
	 */

    protected void Break(int loop_index)
	{
		if (impl != null)
		{
			impl.Break(loop_index);
		}
	}

	protected void CaseLabel(boolean is_default)
	{
		if (impl != null)
		{
			impl.CaseLabel(is_default);
		}
	}

	/*
	 * LabelStatement support (for breaking out of a labeled block)
	 */
	protected void LabelStatementEnd(int loop_index)
	{
		if (impl != null)
		{
			impl.LabelStatementEnd(loop_index);
		}
	}

	protected void LabelStatementBegin()
	{
		if (impl != null)
		{
			impl.LabelStatementBegin();
		}
	}
	
	/*
     * Exception handling support
     */

	protected void Try(boolean hasFinally)
	{
		if (impl != null)
		{
			impl.Try(hasFinally);
		}
	}

    protected void CatchClausesBegin()
    {
        if (impl != null)
        {
            impl.CatchClausesBegin();
        }
    }

    protected void CatchClausesEnd()
    {
        if (impl != null)
        {
            impl.CatchClausesEnd();
        }
    }

    protected void CallFinally(int numFinallys)
    {
    	if (impl != null)
    	{
    		impl.CallFinally(numFinallys);
    	}
    }

    protected void FinallyClauseBegin()
    {
        if (impl != null)
        {
            impl.FinallyClauseBegin();
        }
    }

	protected void FinallyClauseEnd()
	{
		if (impl != null)
		{
			impl.FinallyClauseEnd();
		}
	}

    protected void Catch(TypeValue type, final QName name)
    {
        if (impl != null)
        {
            impl.Catch(type, name);
        }
    }

    protected void Throw()
    {
        if (impl != null)
        {
            impl.Throw();
        }
    }

	protected void Nop()
	{
		if (impl != null)
		{
			impl.Nop();
		}
	}

    protected void CheckType(final QName name)
    {
        if (impl != null)
        {
            impl.CheckType(name);
        }
    }

	protected void Continue(int loop_index)
	{
		if (impl != null)
		{
			impl.Continue(loop_index);
		}
	}

	protected int DefineVar(final String name, int value, int slot)
	{
		if (impl != null)
		{
			return impl.DefineVar(name, value, slot);
		}
        return -1;
	}

	protected void Dup()
	{
		if (impl != null)
		{
			impl.Dup();
		}
	}

	protected void Else()
	{
		if (impl != null)
		{
			impl.Else();
		}
	}

	protected void GetProperty(boolean is_qualified, boolean is_super, boolean is_attr, Namespaces used_def_namespaces)
	{
		if (impl != null)
		{
			impl.GetProperty(is_qualified,is_super,is_attr,used_def_namespaces);
		}
	}

    protected void GetProperty(final String name, boolean is_super, boolean is_attr)
    {
        if (impl != null)
        {
            impl.GetProperty(name,is_super,is_attr);
        }
    }

    protected void GetProperty(final String name, Namespaces namespaces,boolean is_qualified, boolean is_super, boolean is_attr)
    {
        if (impl != null)
        {
            impl.GetProperty(name, namespaces,is_qualified,is_super,is_attr);
        }
    }

    protected void DeleteProperty(boolean is_qualified, boolean is_super, boolean is_attr, Namespaces used_def_namespaces)
    {
        if (impl != null)
        {
            impl.DeleteProperty(is_qualified,is_super,is_attr, used_def_namespaces);
        }
    }

    protected void DeleteProperty(final String name, boolean is_super, boolean is_attr)
    {
        if (impl != null)
        {
            impl.DeleteProperty(name,is_super,is_attr);
        }
    }

    protected void DeleteProperty(final String name, Namespaces namespaces,boolean is_qualified, boolean is_super, boolean is_attr)
    {
        if (impl != null)
        {
            impl.DeleteProperty(name, namespaces,is_qualified,is_super,is_attr);
        }
    }

    protected void SetProperty(boolean is_qualified, boolean is_super, boolean is_attr, Namespaces used_def_namespaces, boolean is_constinit)
    {
        if (impl != null)
        {
            impl.SetProperty(is_qualified,is_super,is_attr,used_def_namespaces,is_constinit);
        }
    }

    protected void SetProperty(final String name, boolean is_super, boolean is_attr)
    {
        if (impl != null)
        {
            impl.SetProperty(name,is_super,is_attr);
        }
    }

    protected void SetProperty(final String name, Namespaces namespaces,boolean is_qualified, boolean is_super, boolean is_attr, boolean is_constinit)
    {
        if (impl != null)
        {
            impl.SetProperty(name, namespaces,is_qualified,is_super,is_attr,is_constinit);
        }
    }

    protected void GetDescendants(boolean is_qualified, boolean is_attr, Namespaces used_def_namespaces)
    {
        if( impl != null )
        {
            impl.GetDescendants(is_qualified,is_attr,used_def_namespaces);
        }
    }
    protected void GetDescendants(final String name, boolean is_super, boolean is_attr)
    {
        if( impl != null )
        {
            impl.GetDescendants(name,is_super,is_attr);
        }
    }
    protected void GetDescendants(final String name, Namespaces namespaces,boolean is_qualified, boolean is_super, boolean is_attr)
    {
        if( impl != null )
        {
            impl.GetDescendants(name,namespaces,is_qualified,is_super,is_attr);
        }
    }
    protected void DeleteDescendants(final String name, boolean is_super, boolean is_attr)
    {
        if( impl != null )
        {
            impl.DeleteDescendants(name,is_super,is_attr);
        }
    }
    protected void DeleteDescendants(final String name, Namespaces namespaces,boolean is_qualified, boolean is_super, boolean is_attr)
    {
        if( impl != null )
        {
            impl.DeleteDescendants(name,namespaces,is_qualified,is_super,is_attr);
        }
    }

	protected void GetBaseObject(int scope_index)
	{
		if (impl != null)
		{
			impl.GetBaseObject(scope_index);
		}
	}

	protected void GetGlobalScope()
	{
		if (impl != null)
		{
			impl.GetGlobalScope();
		}
	}

	protected void GetScopeChain()
	{
		if (impl != null)
		{
			impl.GetScopeChain();
		}
	}

	protected void GetScopeOnTop()
	{
		if (impl != null)
		{
			impl.GetScopeOnTop();
		}
	}

    protected void If(int kind)
    {
        if (impl != null)
        {
            impl.If(kind);
        }
    }

    protected void InvokeBinary(int operator_id, NumberUsage numberUsage)
	{
		if (impl != null)
		{
			impl.InvokeBinary(operator_id, numberUsage);
		}
	}

	protected void InvokeClosure(boolean asConstruct, int size)
	{
		if (impl != null)
		{
			impl.InvokeClosure(asConstruct, size);
		}
	}

    protected void InvokeMethod(boolean localDispatch, int method_id, int size)
    {
        if (impl != null)
        {
            impl.InvokeMethod(localDispatch, method_id, size);
        }
    }

	protected void InvokeSuper(boolean construct, int size)
	{
		if( impl != null)
		{
			impl.InvokeSuper(construct,size);
		}
	}

    protected void ApplyType(int size)
    {
        if (impl != null)
        {
            impl.ApplyType(size);
        }
    }
    
    protected void CallProperty(String name, ObjectList<ObjectValue> namespaces, int size, boolean is_qualified, boolean is_super, boolean is_attr, boolean is_lex )
    {
        if( impl != null)
        {
            impl.CallProperty(name,namespaces,size,is_qualified,is_super,is_attr,is_lex);
        }
    }

    protected void ConstructProperty(String name, ObjectList<ObjectValue> namespaces, int size, boolean is_qualified, boolean is_super, boolean is_attr )
    {
        if( impl != null)
        {
            impl.ConstructProperty(name,namespaces,size,is_qualified,is_super,is_attr);
        }
    }

	protected void InvokeUnary(int operator_id, int size, int data, Namespaces used_def_namespaces, NumberUsage usage)
	{
		if (impl != null)
		{
			impl.InvokeUnary(operator_id, size, data, used_def_namespaces, usage);
		}
	}

	protected void LoadGlobal(int index, int type_id)
	{
		if (impl != null)
		{
			impl.LoadGlobal(index, type_id);
		}
	}

	protected void LoadGlobal(String name)
	{
		if (impl != null)
		{
			impl.LoadGlobal(name);
		}
	}

	protected void LoadRegister(int reg, int type_id)
	{
		if (impl != null)
		{
			impl.LoadRegister(reg, type_id);
		}
	}

	protected void LoadThis()
	{
		if (impl != null)
		{
			impl.LoadThis();
		}
	}

	protected void LoadSuper()
	{
		if (impl != null)
		{
			impl.LoadSuper();
		}
	}

	protected void LoadVar(int index)
	{
		if (impl != null)
		{
			impl.LoadVar(index);
		}
	}

    protected void FindProperty(boolean is_strict, boolean is_attr, boolean is_qualified, Namespaces used_def_namespaces)
    {
        if (impl != null)
        {
            impl.FindProperty(is_strict, is_attr, is_qualified, used_def_namespaces);
        }
    }

    protected void FindProperty(final String name, boolean is_strict, boolean is_attr)
    {
        if (impl != null)
        {
            impl.FindProperty(name,is_strict, is_attr);
        }
    }

    protected void FindProperty(final String name, Namespaces namespaces, boolean is_strict, boolean is_qualified, boolean is_attr)
    {
        if (impl != null)
        {
            impl.FindProperty(name, namespaces, is_strict, is_qualified, is_attr);
        }
    }

    protected void LoopBegin()
	{
		if (impl != null)
		{
			impl.LoopBegin();
		}
	}

	protected void LoopEnd(int kind)
	{
		if (impl != null)
		{
			impl.LoopEnd(kind);
		}
	}

	protected void NewArray(int size)
	{
		if (impl != null)
		{
			impl.NewArray(size);
		}
	}

	protected void NewClassObject(final QName name)
	{
		if (impl != null)
		{
			impl.NewClassObject(name);
		}
	}

	protected void NewFunctionObject(final String name)
	{
		if (impl != null)
		{
			impl.NewFunctionObject(name);
		}
	}

	protected void NewObject(int size)
	{
		if (impl != null)
		{
			impl.NewObject(size);
		}
	}

	protected void PatchBreak(int loop_index)
	{
		if (impl != null)
		{
			impl.PatchBreak(loop_index);
		}
	}

	protected void PatchContinue(int loop_index)
	{
		if (impl != null)
		{
			impl.PatchContinue(loop_index);
		}
	}

	protected void PatchElse(int addr)
	{
		if (impl != null)
		{
			impl.PatchElse(addr);
		}
	}

	protected void PatchIf(int addr)
	{
		if (impl != null)
		{
			impl.PatchIf(addr);
		}
	}

	protected void PatchLoopBegin(int addr)
	{
		if (impl != null)
		{
			impl.PatchLoopBegin(addr);
		}
	}

	protected void PatchSwitchBegin(int addr)
	{
		if (impl != null)
		{
			impl.PatchSwitchBegin(addr);
		}
	}

	protected void Pop()
	{
		if (impl != null)
		{
			impl.Pop();
		}
	}

	protected void PushBoolean(boolean b)
	{
		if (impl != null)
		{
			impl.PushBoolean(b);
		}
	}

	protected void PushCaseIndex(int index)
	{
		if (impl != null)
		{
			impl.PushCaseIndex(index);
		}
	}

	protected void PushEmpty()
	{
		if (impl != null)
		{
			impl.PushEmpty();
		}
	}

	protected void PushNull()
	{
		if (impl != null)
		{
			impl.PushNull();
		}
	}

	protected void PushNumber(NumberConstant val, int type_id)
	{
		if (impl != null)
		{
			impl.PushNumber(val, type_id);
		}
	}

    protected void PushNamespace(ObjectValue ns)
    {
        if (impl != null)
        {
            impl.PushNamespace(ns);
        }
    }

	protected void NewNamespace(ObjectValue ns)
	{
		if (impl != null)
		{
			impl.NewNamespace(ns);
		}
	}

	protected void PushString(final String str)
	{
		if (impl != null)
		{
			impl.PushString(str);
		}
	}

	protected void PushUndefined()
	{
		if (impl != null)
		{
			impl.PushUndefined();
		}
	}

    protected void PushUninitialized()
    {
        if (impl != null)
        {
            impl.PushUninitialized();
        }
    }

	protected void Return(int type_id)
	{
		if (impl != null)
		{
			impl.Return(type_id);
		}
	}

	protected void PreStoreGlobal(int index, int type_id)  // swf only
	{
		if (impl != null)
		{
			impl.PreStoreGlobal(index, type_id);
		}
	}

	protected void StoreGlobal(int index, int type_id)
	{
		if (impl != null)
		{
			impl.StoreGlobal(index, type_id);
		}
	}

	protected void StoreGlobal(String name)
	{
		if (impl != null)
		{
			impl.StoreGlobal(name);
		}
	}

	protected void StoreRegister(int reg, int type_id)
	{
		StoreRegister(reg, type_id, "");
	}	

	protected void StoreRegister(int reg, int type_id, final String varName)
	{
		if (impl != null)
		{
			impl.StoreRegister(reg, type_id, varName);
		}
	}
	
	protected void HasNext(int objectRegister, int indexRegister)
	{
		if (impl != null)
		{
			impl.HasNext(objectRegister, indexRegister);
		}
	}

	protected void StoreVar(int index)
	{
		if (impl != null)
		{
			impl.StoreVar(index);
		}
	}

	protected void SwitchBegin()
	{
		if (impl != null)
		{
			impl.SwitchBegin();
		}
	}

	protected void SwitchTable()
	{
		if (impl != null)
		{
			impl.SwitchTable();
		}
	}

	protected void ToBoolean(int type_id)
	{
		if (impl != null)
		{
			impl.ToBoolean(type_id);
		}
	}

	protected void ToNativeBool()
	{
		if (impl != null)
		{
			impl.ToNativeBool();
		}
	}

    protected void ToInt()
    {
        if (impl != null)
        {
            impl.ToInt();
        }
    }

    protected void ToUint()
    {
        if (impl != null)
        {
            impl.ToUint();
        }
    }

    protected void ToDouble(int type_id)
	{
		if (impl != null)
		{
			impl.ToDouble(type_id);
		}
	}

    protected void ToDecimal(int type_id)
	{
		if (impl != null)
		{
			impl.ToDecimal(type_id);
		}
	}

	protected void ToObject()
	{
		if (impl != null)
		{
			impl.ToObject();
		}
	}

	protected void ToPrimitive()
	{
		if (impl != null)
		{
			impl.ToPrimitive();
		}
	}

	protected void ToString()
	{
		if (impl != null)
		{
			impl.ToString();
		}
	}

	protected void PushScope()
	{
		if (impl != null)
		{
			impl.PushScope();
		}
	}

	protected void PushWith()
	{
		if (impl != null)
		{
			impl.PushWith();
		}
	}

	protected void NewActivation()
	{
		if (impl != null)
		{
			impl.NewActivation();
		}
	}

	protected void NewCatch(int index)
	{
		if (impl != null)
		{
			impl.NewCatch(index);
		}
	}
	
    protected void PopScope()
    {
        if (impl != null)
        {
            impl.PopScope();
        }
    }

    protected void PopWith()
    {
        if (impl != null)
        {
            impl.PopWith();
        }
    }

    protected void DefaultXMLNamespace(String name)
    {
        if (impl != null)
        {
            impl.DefaultXMLNamespace(name);
        }
    }
    
    protected void DefaultXMLNamespace()
    {
        if (impl != null)
        {
            impl.DefaultXMLNamespace();
        }
    }
   
    protected void Swap()
    {
    	if (impl != null)
    	{
    		impl.Swap();
    	}
    }
    
    static protected int size(ObjectList list)
    {
    	return list != null ? list.size() : 0;
    }
    static protected int size(IntList list)
    {
    	return list != null ? list.size() : 0;
    }
    static protected int size(ByteList list)
    {
    	return list != null ? list.size() : 0;
    }
}
