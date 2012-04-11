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
 * Low-level visitor interface
 *
 * @author Clement Wong
 */
public interface Visitor
{
	void methodInfo(int returnType, int[] paramTypes, int nativeName, int flags, int[] values, int[] value_kinds, int[] param_names) throws DecoderException;

	void metadataInfo(int index, int name, int[] keys, int[] values) throws DecoderException;

	void startInstance(int name, int superName, boolean isDynamic, boolean isFinal, boolean isInterface, int[] interfaces, int iinit, int protectedNamespace) throws DecoderException;

	void endInstance();

	void startClass(int name, int cinit) throws DecoderException;

	void endClass();

	void startScript(int initID);

	void endScript();

	void startMethodBody(int methodInfo, int maxStack, int maxRegs, int scopeDepth, int maxScope, int codeStart, long codeLength) throws DecoderException;

	void endMethodBody();

	void startOpcodes(int methodInfo);

	void endOpcodes();
	
	void exception(long start, long end, long target, int type, int name);

	void startExceptions(int exceptionCount);

	void endExceptions();

	void traitCount(int traitCount);

	void slotTrait(int kind, int name, int slotId, int type, int value, int value_kind, int[] metadata) throws DecoderException;

	void methodTrait(int kind, int name, int dispId, int methodInfo, int[] metadata) throws DecoderException;

	void classTrait(int kind, int name, int slotId, int classIndex, int[] metadata) throws DecoderException;

	void functionTrait(int kind, int name, int slotId, int methodInfo, int[] metadata) throws DecoderException;
	
	void target(int pos);

	void OP_returnvoid();

	void OP_returnvalue();

	void OP_nop();

	void OP_bkpt();

	void OP_timestamp();

	void OP_debugline(int linenum);

	void OP_bkptline();

	void OP_debug(int di_local, int index, int slot, int linenum);

	void OP_debugfile(int index);

	void OP_jump(int jump, int pos);

	void OP_pushnull();

	void OP_pushundefined();

	void OP_pushstring(int index);

    void OP_pushnamespace(int index);

    void OP_pushint(int index);

    void OP_pushuint(int index);

    void OP_pushdouble(int index);

	void OP_getlocal(int index);

	void OP_pushtrue();

	void OP_pushfalse();

	void OP_pushnan();

	void OP_pop();

	void OP_dup();

	void OP_swap();
	
	void OP_pushdecimal(int index);
	
	void OP_pushdnan();

	void OP_convert_s();

	void OP_esc_xelem();

    void OP_esc_xattr();

    void OP_checkfilter();

	void OP_convert_d();

	void OP_convert_b();

	void OP_convert_o();
	
	void OP_convert_m();
	
	void OP_convert_m_p(int param);

	void OP_negate_p(int param);

	void OP_negate();

	void OP_negate_i();

	void OP_increment_p(int param);

	void OP_increment();

	void OP_increment_i();

	void OP_inclocal(int index);

	void OP_inclocal_p(int param, int index);

	void OP_kill(int index);

	void OP_inclocal_i(int index);

	void OP_decrement();

	void OP_decrement_p(int param);

	void OP_decrement_i();

	void OP_declocal(int index);

	void OP_declocal_p(int param, int index);

	void OP_declocal_i(int index);

	void OP_typeof();

	void OP_not();

	void OP_bitnot();

	void OP_setlocal(int index);

	void OP_add();

	void OP_add_i();

	void OP_subtract();

	void OP_subtract_i();

	void OP_multiply();

	void OP_multiply_i();

	void OP_divide();

	void OP_modulo();
	
	void OP_add_p(int param);

	void OP_subtract_p(int param);

	void OP_multiply_p(int param);

	void OP_divide_p(int param);

	void OP_modulo_p(int param);

	void OP_lshift();

	void OP_rshift();

	void OP_urshift();

	void OP_bitand();

	void OP_bitor();

	void OP_bitxor();

	void OP_equals();

	void OP_strictequals();

	void OP_lookupswitch(int defaultPos, int[] casePos, int thisPos, int caseTablePos);

	void OP_iftrue(int offset, int nextPos);

	void OP_iffalse(int offset, int nextPos);

	void OP_ifeq(int offset, int nextPos);

	void OP_ifne(int offset, int nextPos);

	void OP_ifstricteq(int offset, int nextPos);

	void OP_ifstrictne(int offset, int nextPos);

	void OP_iflt(int offset, int nextPos);

	void OP_ifle(int offset, int nextPos);

	void OP_ifgt(int offset, int nextPos);

	void OP_ifge(int offset, int nextPos);

	void OP_lessthan();

	void OP_lessequals();

	void OP_greaterthan();

	void OP_greaterequals();

	void OP_newobject(int size);

	void OP_newarray(int size);

	void OP_getproperty(int index);

    void OP_setproperty(int index);

    void OP_initproperty(int index);

	void OP_getdescendants(int index);

	void OP_findpropstrict(int index);

	void OP_findproperty(int index);

	void OP_finddef(int index);

	void OP_nextname();

	void OP_nextvalue();

	void OP_hasnext();

	void OP_hasnext2(int objectRegister, int indexRegister);	
	
	void OP_getlex(int index);

	void OP_deleteproperty(int index);

	void OP_setslot(int index);

	void OP_getslot(int index);

	void OP_setglobalslot(int index);

	void OP_getglobalslot(int index);

	void OP_call(int size);

	void OP_construct(int size);

    void OP_applytype(int size);

	void OP_newfunction(int id);

	void OP_newclass(int id);

	void OP_callstatic(int id, int argc);

	void OP_callmethod(int id, int argc);

	void OP_callproperty(int index, int argc);

	void OP_callproplex(int index, int argc);
	
	void OP_constructprop(int index, int argc);

	void OP_callsuper(int index, int argc);

	void OP_getsuper(int index);

	void OP_setsuper(int index);

	void OP_constructsuper(int argc);

	void OP_pushshort(int n);

	void OP_astype(int index);

	void OP_astypelate();

	void OP_coerce(int index);

	void OP_coerce_b();

	void OP_coerce_o();

	void OP_coerce_a();

	void OP_coerce_i();

	void OP_coerce_u();

	void OP_coerce_d();

	void OP_coerce_s();

	void OP_istype(int index);

	void OP_istypelate();

	void OP_pushbyte(int n);

	void OP_getscopeobject(int index);

	void OP_pushscope();

	void OP_popscope();

	void OP_convert_i();

	void OP_convert_u();

	void OP_throw();

	void OP_instanceof();

	void OP_in();

	void OP_dxns(int index);

	void OP_dxnslate();

	void OP_ifnlt(int offset, int nextPos);

	void OP_ifnle(int offset, int nextPos);

	void OP_ifngt(int offset, int nextPos);

	void OP_ifnge(int offset, int nextPos);

	void OP_pushwith();

	void OP_newactivation();

	void OP_newcatch(int index);

	void OP_deldescendants();

	void OP_getglobalscope();

	void OP_getlocal0();

	void OP_getlocal1();

	void OP_getlocal2();

	void OP_getlocal3();

	void OP_setlocal0();

	void OP_setlocal1();

	void OP_setlocal2();

	void OP_setlocal3();
	
	void OP_label();

	void OP_pushconstant(int id);

	void OP_callsupervoid(int index, int argc);

	void OP_callpropvoid(int index, int argc);

    void OP_li8();

    void OP_li16();

    void OP_li32();

    void OP_lf32();

    void OP_lf64();

    void OP_si8();

    void OP_si16();

    void OP_si32();

    void OP_sf32();

    void OP_sf64();

    void OP_sxi1();

    void OP_sxi8();

    void OP_sxi16();
}
