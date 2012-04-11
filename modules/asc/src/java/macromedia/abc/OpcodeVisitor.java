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

package macromedia.abc;

/**
 * @author Clement Wong
 */
public class OpcodeVisitor implements Visitor
{
	public final void methodInfo(int returnType, int[] paramTypes, int nativeName, int flags, int[] values, int[] value_kinds, int[] param_names) {}
	public final void metadataInfo(int index, int name, int[] keys, int[] values) {}
	public final void startInstance(int name, int superName, boolean isDynamic, boolean isFinal, boolean isInterface, int[] interfaces, int iinit, int protectedNamespace) {}
	public final void endInstance() {}
	public final void startClass(int name, int cinit) {}
	public final void endClass() {}
	public final void startScript(int initID) {}
	public final void endScript() {}
	public final void startMethodBody(int methodInfo, int maxStack, int maxRegs, int scopeDepth, int maxScope, int codeStart, long codeLength) {}
	public final void endMethodBody() {}
	public final void startOpcodes(int methodInfo) {}
	public final void endOpcodes() {}
	public final void exception(long start, long end, long target, int type, int name) {}
	public final void startExceptions(int exceptionCount) {}
	public final void endExceptions() {}
	public final void traitCount(int traitCount) {}
	public final void slotTrait(int kind, int name, int slotId, int type, int value, int value_kind, int[] metadata) {}
	public final void methodTrait(int kind, int name, int dispId, int methodInfo, int[] metadata) {}
	public final void classTrait(int kind, int name, int slotId, int classIndex, int[] metadata) {}
	public final void functionTrait(int kind, int name, int slotId, int methodInfo, int[] metadata) {}

	public void target(int pos) {}
	public void OP_returnvoid() {}
	public void OP_returnvalue() {}
	public void OP_nop() {}
	public void OP_bkpt() {}
	public void OP_timestamp() {}
	public void OP_debugline(int linenum) {}
	public void OP_bkptline() {}
	public void OP_debug(int di_local, int index, int slot, int linenum) {}
	public void OP_debugfile(int index) {}
	public void OP_jump(int jump, int pos) {}
	public void OP_pushnull() {}
	public void OP_pushundefined() {}
	public void OP_pushstring(int index) {}
    public void OP_pushnamespace(int index) {}
    public void OP_pushint(int index) {}
    public void OP_pushuint(int index) {}
    public void OP_pushdouble(int index) {}
    public void OP_pushdecimal(int index) {}
	public void OP_getlocal(int index) {}
	public void OP_pushtrue() {}
	public void OP_pushfalse() {}
	public void OP_pushnan() {}
	public void OP_pushdnan() {}
	public void OP_pop() {}
	public void OP_dup() {}
	public void OP_swap() {}
	public void OP_convert_s() {}
	public void OP_esc_xelem() {}
    public void OP_esc_xattr() {}
    public void OP_checkfilter() {}
	public void OP_convert_d() {}
	public void OP_convert_m() {}
	public void OP_convert_m_p(int params) {}
	public void OP_convert_b() {}
	public void OP_convert_o() {}
	public void OP_negate() {}
	public void OP_negate_p(int params) {}
	public void OP_negate_i() {}
	public void OP_increment() {}
	public void OP_increment_p(int params) {}
	public void OP_increment_i() {}
	public void OP_inclocal(int index) {}
	public void OP_inclocal_p(int params, int index) {}
	public void OP_kill(int index) {}
	public void OP_inclocal_i(int index) {}
	public void OP_decrement() {}
	public void OP_decrement_p(int params) {}
	public void OP_decrement_i() {}
	public void OP_declocal(int index) {}
	public void OP_declocal_p(int params, int index) {}
	public void OP_declocal_i(int index) {}
	public void OP_typeof() {}
	public void OP_not() {}
	public void OP_bitnot() {}
	public void OP_setlocal(int index) {}
	public void OP_add() {}
	public void OP_add_i() {}
	public void OP_subtract() {}
	public void OP_subtract_i() {}
	public void OP_multiply() {}
	public void OP_multiply_i() {}
	public void OP_divide() {}
	public void OP_divide_i() {}
	public void OP_modulo() {}
	public void OP_add_p(int params) {}
	public void OP_subtract_p(int params) {}
	public void OP_multiply_p(int params) {}
	public void OP_divide_p(int params) {}
	public void OP_modulo_p(int params) {}
	public void OP_lshift() {}
	public void OP_rshift() {}
	public void OP_urshift() {}
	public void OP_bitand() {}
	public void OP_bitor() {}
	public void OP_bitxor() {}
	public void OP_equals() {}
	public void OP_strictequals() {}
	public void OP_lookupswitch(int defaultPos, int[] casePos, int p1, int p2) {}
	public void OP_iftrue(int offset, int pos) {}
	public void OP_iffalse(int offset, int pos) {}
	public void OP_ifeq(int offset, int pos) {}
	public void OP_ifne(int offset, int pos) {}
	public void OP_ifstricteq(int offset, int pos) {}
	public void OP_ifstrictne(int offset, int pos) {}
	public void OP_iflt(int offset, int pos) {}
	public void OP_ifle(int offset, int pos) {}
	public void OP_ifgt(int offset, int pos) {}
	public void OP_ifge(int offset, int pos) {}
	public void OP_lessthan() {}
	public void OP_lessequals() {}
	public void OP_greaterthan() {}
	public void OP_greaterequals() {}
	public void OP_newobject(int size) {}
	public void OP_newarray(int size) {}
	public void OP_getproperty(int index) {}
    public void OP_setproperty(int index) {}
    public void OP_initproperty(int index) {}
	public void OP_getdescendants(int index) {}
	public void OP_findpropstrict(int index) {}
	public void OP_findproperty(int index) {}
	public void OP_finddef(int index) {}
	public void OP_getlex(int index) {}
	public void OP_nextname() {}
	public void OP_nextvalue() {}
	public void OP_hasnext() {}
	public void OP_hasnext2(int objectRegister, int indexRegister) {}
	public void OP_deleteproperty(int index) {}
	public void OP_setslot(int index) {}
	public void OP_getslot(int index) {}
	public void OP_setglobalslot(int index) {}
	public void OP_getglobalslot(int index) {}
	public void OP_call(int size) {}
	public void OP_construct(int size) {}
    public void OP_applytype(int size) {}
	public void OP_newfunction(int id) {}
	public void OP_newclass(int id) {}
	public void OP_callstatic(int id, int argc) {}
	public void OP_callmethod(int id, int argc) {}
	public void OP_callproperty(int index, int argc) {}
	public void OP_callproplex(int index, int argc) {}
	public void OP_constructprop(int index, int argc) {}
	public void OP_callsuper(int index, int argc) {}
	public void OP_getsuper(int index) {}
	public void OP_setsuper(int index) {}
	public void OP_constructsuper(int argc) {}
	public void OP_pushshort(int n) {}
	public void OP_astype(int index) {}
	public void OP_astypelate() {}
	public void OP_coerce(int index) {}
	public void OP_coerce_b() {}
	public void OP_coerce_o() {}
	public void OP_coerce_a() {}
	public void OP_coerce_i() {}
	public void OP_coerce_u() {}
	public void OP_coerce_d() {}
	public void OP_coerce_s() {}
	public void OP_istype(int index) {}
	public void OP_istypelate() {}
	public void OP_pushbyte(int n) {}
	public void OP_getscopeobject(int index) {}
	public void OP_pushscope() {}
	public void OP_popscope() {}
	public void OP_convert_i() {}
	public void OP_convert_u() {}
	public void OP_throw() {}
	public void OP_instanceof() {}
	public void OP_in() {}
	public void OP_dxns(int index) {}
	public void OP_dxnslate() {}
	public void OP_ifnlt(int offset, int pos) {}
	public void OP_ifnle(int offset, int pos) {}
	public void OP_ifngt(int offset, int pos) {}
	public void OP_ifnge(int offset, int pos) {}
	public void OP_pushwith() {}
	public void OP_newactivation() {}
	public void OP_newcatch(int index) {}
	public void OP_deldescendants() {}
	public void OP_getglobalscope() {}
	public void OP_getlocal0() {}
	public void OP_getlocal1() {}
	public void OP_getlocal2() {}
	public void OP_getlocal3() {}
	public void OP_setlocal0() {}
	public void OP_setlocal1() {}
	public void OP_setlocal2() {}
	public void OP_setlocal3() {}
	public void OP_label() {}
	public void OP_pushconstant(int id) {}
	public void OP_callsupervoid(int index, int argc) {}
	public void OP_callpropvoid(int index, int argc) {}
    public void OP_li8(){}
    public void OP_li16(){}
    public void OP_li32(){}
    public void OP_lf32(){}
    public void OP_lf64(){}
    public void OP_si8(){}
    public void OP_si16(){}
    public void OP_si32(){}
    public void OP_sf32(){}
    public void OP_sf64(){}
    public void OP_sxi1(){}
    public void OP_sxi8(){}
    public void OP_sxi16(){}
}
