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

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import static macromedia.abc.Opcodes.*;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;

/**
 * @author Clement Wong
 */
public class Printer
{
	/**
	 * Usage: macromedia.abc.Printer -c mx.core:UIObject -m setColor -l 10-15 -b foo.abc
	 *
	 * @param args command-line arguments
	 */
	public static void main(String[] args) throws Throwable
	{
		if (args.length == 0)
		{
			System.err.println("Usage: abcdump [-b] [-c mx.core:UIObject] [-m setColor] [-l 10-15] foo.abc");
			System.err.println();
			System.err.println("  -b:                     include opcodes in the output");
			System.err.println("  -c className:           restrict output to the specified class");
			System.err.println("  -m methodName:          restrict output to the specified method");
			System.err.println("  -l startLine[-endLine]: restrict output to the specified line(s)");
			return;
		}

		for (int i = 0, argc = args.length; i < argc; i++)
		{
			if ("-c".equals(args[i]))
			{
				className = args[i + 1].intern();
				i++;
			}
			else if ("-m".equals(args[i]))
			{
				methodName = args[i + 1].intern();
				i++;
			}
			else if ("-l".equals(args[i]))
			{
				String lineRange = args[i + 1];
				int index = lineRange.indexOf("-");
				if (index != -1)
				{
					startLine = Integer.parseInt(lineRange.substring(0, index));
					endLine = Integer.parseInt(lineRange.substring(index + 1));
				}
				else
				{
					startLine = Integer.parseInt(lineRange);
					endLine = startLine + 1;
				}
				i++;
			}
			else if ("-b".equals(args[i]))
			{
				showOpcodes = true;
			}
			else if (i == argc - 1)
			{
				fileName = args[i];
			}
		}

		byte[] bytecodes = readBytes(new File(fileName));
		BytecodeBuffer in = new BytecodeBuffer(bytecodes);

		decoder = new Decoder(in);
		processScripts();
	}

	private static Decoder decoder;
	private static String fileName;

	private static boolean showOpcodes;

	private static String className;
	private static String methodName;
	private static int startLine;
	private static int endLine;

	private static String currentClass;
	private static String currentMethod;
	private static int currentLine;

	private static void processScripts() throws DecoderException
	{
		Decoder.ScriptInfo scriptInfo = decoder.scriptInfo;
		Visitor v = new ABCVisitor(decoder);

		for (int i = 0, size = scriptInfo.size(); i < size; i++)
		{
			scriptInfo.decode(i, v);
		}
	}

	static class ABCVisitor extends DefaultVisitor
	{
		ABCVisitor(Decoder decoder)
		{
			super(decoder);
		}

		public void methodInfo(QName returnType, QName[] paramTypes, String nativeName, int flags, Object[] values, String[] param_names)
		{
			print("<info name='" + nativeName + "' paramTypes='");
			for (int i = 0, length = paramTypes != null ? paramTypes.length : 0; i < length; i++)
			{
				print(paramTypes[i] + " ");
			}
			print("'");
			if (returnType != null)
			{
				print(" returnType='" + returnType + "'");
			}
            print(" paramNames='");
            for (int i = 0, length = param_names != null ? param_names.length : 0; i < length; i++)
            {
                print(param_names[i] + " ");
            }
            print("'");

			println("/>");
		}

		public void metadata(String name, String[] keys, String[] values)
		{
			println("<metadata/>");
		}

		public void beginVar(QName name, int slotID, QName type, Object value)
		{
			print("<var name='" + name + "'");
			if (type != null)
			{
				print(" type='" + type + "'");
			}
			println(">");
			if (value != null)
			{
				println("<value>" + value + "</value>");
			}
		}

		public void endVar(QName name)
		{
			println("</var>");
		}

		public void beginConst(QName name, int slotID, QName type, Object value)
		{
			print("<const name='" + name + "'");
			if (type != null)
			{
				print(" type='" + type + "'");
			}
			println(">");
			if (value != null)
			{
				println("<value>" + value + "</value>");
			}
		}

		public void endConst(QName name)
		{
			println("</const>");
		}

		public void beginGetter(int methodInfo, QName name, int dispID, int attr)
		{
			if (methodName != null)
			{
				currentMethod = name.toString().intern();
			}
			println("<getter name='" + name + "' dispID='" + dispID + "' attr='" + attr + "'>");
		}

		public void endGetter(QName name)
		{
			println("</getter>");
			if (methodName != null)
			{
				currentMethod = null;
			}
		}

		public void beginSetter(int methodInfo, QName name, int dispID, int attr)
		{
			if (methodName != null)
			{
				currentMethod = name.toString().intern();
			}
			println("<setter name='" + name + "' dispID='" + dispID + "' attr='" + attr + "'>");
		}

		public void endSetter(QName name)
		{
			println("</setter>");
			if (methodName != null)
			{
				currentMethod = null;
			}
		}

		public void beginMethod(int methodInfo, QName name, int dispID, int attr)
		{
			if (methodName != null)
			{
				currentMethod = name.toString().intern();
			}
			println("<method name='" + name + "' dispID='" + dispID + "' attr='" + attr + "'>");
		}

		public void endMethod(QName name)
		{
			println("</method>");
			if (methodName != null)
			{
				currentMethod = null;
			}
		}

		public void beginClass(QName name, int slotID)
		{
			if (className != null)
			{
				currentClass = name.toString().intern();
			}
			println("<class name='" + name + "' slot='" + slotID + "'>");
		}

		public void endClass(QName name)
		{
			println("</class>");
			if (className != null)
			{
				currentClass = null;
			}
		}

		public void beginIInit(int methodInfo)
		{
			println("<iinit>");
		}

		public void endIInit()
		{
			println("</iinit>");
		}

		public void beginCInit(int methodInfo)
		{
			println("<cinit>");
		}

		public void endCInit()
		{
			println("</cinit>");
		}

		public void beginFunction(int methodInfo, QName name, int slotID)
		{
			println("<function name='" + name + "'>");
		}

		public void endFunction(QName name)
		{
			println("</function>");
		}

		public void instanceInfo(QName name, QName superName, MultiName[] interfaces)
		{
			print("<info type='" + name + "'");
			if (superName != null)
			{
				print(" superType='" + superName + "'");
			}
			println("/>");
		}

		public void classInfo(QName name)
		{
		}

		public void beginABC()
		{
			println("<abc>");
		}

		public void endABC()
		{
			println("</abc>");
		}

		public void beginBody(int methodID, int codeStart, long codeLength)
		{
			println("<![CDATA[");
		}

		public void endBody()
		{
			println("]]>");
		}


        private Object getConstantStringValue(int index)
        {
            try
            {
                return decoder.constantPool.getString(index);
            }
            catch (DecoderException ex)
            {
                return "decoder exception...";
            }
        }

        private Object getConstantNamespaceValue(int index)
        {
            try
            {
                return decoder.constantPool.getNamespaceName(index);
            }
            catch (DecoderException ex)
            {
                return "decoder exception...";
            }
        }

        private Object getConstantIntValue(int index)
        {
            return decoder.constantPool.getInt(index);
        }

        private Object getConstantUIntValue(int index)
        {
            return decoder.constantPool.getLong(index);
        }

        /*private Object getConstantDoubleValue(int index)
        {
            try
            {
                return decoder.constantPool.getDouble(index);
            }
            catch (DecoderException ex)
            {
                return "decoder exception...";
            }
        }*/

        private Object getConstantMultinameValue(int index)
        {
            try
            {
                return decoder.constantPool.getGeneralMultiname(index);
            }
            catch (DecoderException ex)
            {
                return "decoder exception...";
            }
        }
        
        public void target(int pos)
        {
        	System.out.println("target "+pos);
        }

		public void OP_returnvoid()
		{
			printOpcode(opNames[OP_returnvoid]);
		}

		public void OP_returnvalue()
		{
			printOpcode(opNames[OP_returnvalue]);
		}

		public void OP_nop()
		{
			printOpcode(opNames[OP_nop]);
		}

		public void OP_bkpt()
		{
			printOpcode(opNames[OP_bkpt]);
		}

		public void OP_timestamp()
		{
			printOpcode(opNames[OP_timestamp]);
		}

		public void OP_debugline(int linenum)
		{
			if (startLine != 0 && endLine != 0)
			{
				currentLine = linenum;
			}
			printOpcode(System.getProperty("line.separator") + opNames[OP_debugline] + " linenum=" + linenum);
		}

		public void OP_bkptline()
		{
			printOpcode(opNames[OP_bkptline]);
		}

		public void OP_debug(int di_local, int index, int slot, int linenum)
		{
			printOpcode(opNames[OP_debug] + " di_local=" + di_local + " index=" + index + " slot=" + slot + " linenum=" + linenum);
		}

		public void OP_debugfile(int index)
		{
			printOpcode(opNames[OP_debugfile] + " cpool[" + index + "]" + " = " + getConstantStringValue(index));
		}

		public void OP_jump(int jump, int pos)
		{
			printOpcode(opNames[OP_jump] + " " + jump);
		}

		public void OP_pushnull()
		{
			printOpcode(opNames[OP_pushnull]);
		}

		public void OP_pushundefined()
		{
			printOpcode(opNames[OP_pushundefined]);
		}

        public void OP_pushstring(int index)
        {
            printOpcode(opNames[OP_pushstring] + " cpool_string[" + index + "]" + " = " + getConstantStringValue(index));
        }
        public void OP_pushnamespace(int index)
        {
            printOpcode(opNames[OP_pushnamespace] + " cpool_namespace[" + index + "]" + " = " + getConstantNamespaceValue(index));
        }
        public void OP_pushint(int index)
        {
            printOpcode(opNames[OP_pushint] + " cpool_int[" + index + "]" + " = " + getConstantIntValue(index));
        }
        public void OP_pushuint(int index)
        {
            printOpcode(opNames[OP_pushuint] + " cpool_uint[" + index + "]" + " = " + getConstantUIntValue(index));
        }
        public void OP_pushdouble(int index)
        {
            printOpcode(opNames[OP_pushdouble] + " cpool_double[" + index + "]");
        }

        public void OP_pushdecimal(int index)
        {
            printOpcode(opNames[OP_pushdouble] + " cpool_decimal[" + index + "]");
        }

		public void OP_getlocal(int index)
		{
			printOpcode(opNames[OP_getlocal] + " r" + index);
		}

		public void OP_pushtrue()
		{
			printOpcode(opNames[OP_pushtrue]);
		}

		public void OP_pushfalse()
		{
			printOpcode(opNames[OP_pushfalse]);
		}

		public void OP_pushnan()
		{
			printOpcode(opNames[OP_pushnan]);
		}

		public void OP_pushdnan()
		{
			printOpcode(opNames[OP_pushdnan]);
		}

		public void OP_pop()
		{
			printOpcode(opNames[OP_pop]);
		}

		public void OP_dup()
		{
			printOpcode(opNames[OP_dup]);
		}

		public void OP_swap()
		{
			printOpcode(opNames[OP_swap]);
		}

		public void OP_convert_s()
		{
			printOpcode(opNames[OP_convert_s]);
		}

		public void OP_esc_xelem()
		{
			printOpcode(opNames[OP_esc_xelem]);
		}

        public void OP_esc_xattr()
        {
            printOpcode(opNames[OP_esc_xattr]);
        }

        public void OP_checkfilter()
        {
            printOpcode(opNames[OP_checkfilter]);
        }

		public void OP_convert_d()
		{
			printOpcode(opNames[OP_convert_d]);
		}

		public void OP_convert_b()
		{
			printOpcode(opNames[OP_convert_b]);
		}

		public void OP_convert_o()
		{
			printOpcode(opNames[OP_convert_o]);
		}

		public void OP_convert_m()
		{
			printOpcode(opNames[OP_convert_m]);
		}

		public void OP_convert_m_p(int param)
		{
			printOpcode(opNames[OP_convert_m_p] + " p" + param);
		}

		public void OP_negate()
		{
			printOpcode(opNames[OP_negate]);
		}

		public void OP_negate_p(int param)
		{
			printOpcode(opNames[OP_negate_p] + " p" + param);
		}

		public void OP_negate_i()
		{
			printOpcode(opNames[OP_negate_i]);
		}

		public void OP_increment()
		{
			printOpcode(opNames[OP_increment]);
		}

		public void OP_increment_p(int param)
		{
			printOpcode(opNames[OP_increment_p] + " p" + param);
		}

		public void OP_increment_i()
		{
			printOpcode(opNames[OP_increment_i]);
		}

		public void OP_inclocal(int index)
		{
			printOpcode(opNames[OP_inclocal] + " r" + index);
		}

		public void OP_inclocal_p(int param, int index)
		{
			printOpcode(opNames[OP_inclocal] + " p" + param + " r" + index);
		}

		public void OP_kill(int index)
		{
			printOpcode(opNames[OP_kill] + " r" + index);
		}

		public void OP_inclocal_i(int index)
		{
			printOpcode(opNames[OP_inclocal_i] + " r" + index);
		}

		public void OP_decrement()
		{
			printOpcode(opNames[OP_decrement]);
		}

		public void OP_decrement_p(int param)
		{
			printOpcode(opNames[OP_decrement_p] + " p" + param);
		}

		public void OP_decrement_i()
		{
			printOpcode(opNames[OP_decrement_i]);
		}

		public void OP_declocal(int index)
		{
			printOpcode(opNames[OP_declocal] + " r" + index);
		}

		public void OP_declocal_p(int param, int index)
		{
			printOpcode(opNames[OP_declocal_p] + " p" + param + " r" + index);
		}

		public void OP_declocal_i(int index)
		{
			printOpcode(opNames[OP_declocal_i] + " r" + index);
		}

		public void OP_typeof()
		{
			printOpcode(opNames[OP_typeof]);
		}

		public void OP_not()
		{
			printOpcode(opNames[OP_not]);
		}

		public void OP_bitnot()
		{
			printOpcode(opNames[OP_bitnot]);
		}

		public void OP_setlocal(int index)
		{
			printOpcode(opNames[OP_setlocal] + " r" + index);
		}

		public void OP_add()
		{
			printOpcode(opNames[OP_add]);
		}

		public void OP_add_p(int param)
		{
			printOpcode(opNames[OP_add] + " p" + param);
		}

		public void OP_add_i()
		{
			printOpcode(opNames[OP_add_i]);
		}

		public void OP_subtract()
		{
			printOpcode(opNames[OP_subtract]);
		}

		public void OP_subtract_p(int param)
		{
			printOpcode(opNames[OP_subtract_p] + " p" + param);
		}

		public void OP_subtract_i()
		{
			printOpcode(opNames[OP_subtract_i]);
		}

		public void OP_multiply()
		{
			printOpcode(opNames[OP_multiply]);
		}

		public void OP_multiply_p(int param)
		{
			printOpcode(opNames[OP_multiply_p] + " p" + param);
		}

		public void OP_multiply_i()
		{
			printOpcode(opNames[OP_multiply_i]);
		}

		public void OP_divide()
		{
			printOpcode(opNames[OP_divide]);
		}

		public void OP_divide_p(int param)
		{
			printOpcode(opNames[OP_divide_p] + " p" + param);
		}

		public void OP_modulo()
		{
			printOpcode(opNames[OP_modulo]);
		}

		public void OP_modulo_p(int param)
		{
			printOpcode(opNames[OP_modulo_p] + " p" + param);
		}

		public void OP_lshift()
		{
			printOpcode(opNames[OP_lshift]);
		}

		public void OP_rshift()
		{
			printOpcode(opNames[OP_rshift]);
		}

		public void OP_urshift()
		{
			printOpcode(opNames[OP_urshift]);
		}

		public void OP_bitand()
		{
			printOpcode(opNames[OP_bitand]);
		}

		public void OP_bitor()
		{
			printOpcode(opNames[OP_bitor]);
		}

		public void OP_bitxor()
		{
			printOpcode(opNames[OP_bitxor]);
		}

		public void OP_equals()
		{
			printOpcode(opNames[OP_equals]);
		}

		public void OP_strictequals()
		{
			printOpcode(opNames[OP_strictequals]);
		}

		public void OP_lookupswitch(int defaultPos, int[] casePos, int pos, int p2)
		{
			String caseList = "";
			for (int i = 0, len = casePos.length; i < len; i++)
			{
				caseList += casePos[i] + ",";
			}
			printOpcode(opNames[OP_lookupswitch] + " defaultPos=" + defaultPos + " casePos=" + caseList);
		}

		public void OP_iftrue(int offset, int pos)
		{
			printOpcode(opNames[OP_iftrue] + " " + offset);
		}

		public void OP_iffalse(int offset, int pos)
		{
			printOpcode(opNames[OP_iffalse] + " " + offset);
		}

		public void OP_ifeq(int offset, int pos)
		{
			printOpcode(opNames[OP_ifeq] + " " + offset);
		}

		public void OP_ifne(int offset, int pos)
		{
			printOpcode(opNames[OP_ifne] + " " + offset);
		}

		public void OP_ifstricteq(int offset, int pos)
		{
			printOpcode(opNames[OP_ifstricteq] + " " + offset);
		}

		public void OP_ifstrictne(int offset, int pos)
		{
			printOpcode(opNames[OP_ifstrictne] + " " + offset);
		}

		public void OP_iflt(int offset, int pos)
		{
			printOpcode(opNames[OP_iflt] + " " + offset);
		}

		public void OP_ifle(int offset, int pos)
		{
			printOpcode(opNames[OP_ifle] + " " + offset);
		}

		public void OP_ifgt(int offset, int pos)
		{
			printOpcode(opNames[OP_ifgt] + " " + offset);
		}

		public void OP_ifge(int offset, int pos)
		{
			printOpcode(opNames[OP_ifge] + " " + offset);
		}

		public void OP_lessthan()
		{
			printOpcode(opNames[OP_lessthan]);
		}

		public void OP_lessequals()
		{
			printOpcode(opNames[OP_lessequals]);
		}

		public void OP_greaterthan()
		{
			printOpcode(opNames[OP_greaterthan]);
		}

		public void OP_greaterequals()
		{
			printOpcode(opNames[OP_greaterequals]);
		}

		public void OP_newobject(int size)
		{
			printOpcode(opNames[OP_newobject] + " size=" + size);
		}

		public void OP_newarray(int size)
		{
			printOpcode(opNames[OP_newarray] + " size=" + size);
		}

		public void OP_getproperty(int index)
		{
			printOpcode(opNames[OP_getproperty] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

        public void OP_setproperty(int index)
        {
            printOpcode(opNames[OP_setproperty] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
        }

        public void OP_initproperty(int index)
        {
            printOpcode(opNames[OP_initproperty] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
        }

		public void OP_getdescendants(int index)
		{
			printOpcode(opNames[OP_getdescendants] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_findpropstrict(int index)
		{
			printOpcode(opNames[OP_findpropstrict] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_findproperty(int index)
		{
			printOpcode(opNames[OP_findproperty] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_finddef(int index)
		{
			printOpcode(opNames[OP_finddef] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_getlex(int index)
		{
			printOpcode(opNames[OP_getlex] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_nextname()
		{
			printOpcode(opNames[OP_nextname]);
		}

		public void OP_nextvalue()
		{
			printOpcode(opNames[OP_nextvalue]);
		}

		public void OP_hasnext()
		{
			printOpcode(opNames[OP_hasnext]);
		}

		public void OP_hasnext2(int objectRegister, int indexRegister)
		{
			printOpcode(opNames[OP_hasnext2] + " " + objectRegister + " " + indexRegister);
		}
		
		public void OP_deleteproperty(int index)
		{
			printOpcode(opNames[OP_deleteproperty] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_setslot(int index)
		{
			printOpcode(opNames[OP_setslot] + " " + index);
		}

		public void OP_getslot(int index)
		{
			printOpcode(opNames[OP_getslot] + " " + index);
		}

		public void OP_setglobalslot(int index)
		{
			printOpcode(opNames[OP_setglobalslot] + " " + index);
		}

		public void OP_getglobalslot(int index)
		{
			printOpcode(opNames[OP_getglobalslot] + " " + index);
		}

		public void OP_call(int size)
		{
			printOpcode(opNames[OP_call] + " size=" + size);
		}

		public void OP_construct(int size)
		{
			printOpcode(opNames[OP_construct] + " size=" + size);
		}

        public void OP_applytype(int size)
        {
            printOpcode(opNames[OP_applytype] + " size=" + size);
        }

		public void OP_newfunction(int id)
		{
			printOpcode(opNames[OP_newfunction] + " function=" + id);
		}

		public void OP_newclass(int id)
		{
			printOpcode(opNames[OP_newclass] + " class=" + id);
		}

		public void OP_callstatic(int id, int argc)
		{
			printOpcode(opNames[OP_callstatic] + " method=" + id + " argc=" + argc);
		}

		public void OP_callmethod(int id, int argc)
		{
			printOpcode(opNames[OP_callmethod] + " dispid=" + id + " argc=" + argc);
		}

		public void OP_callproperty(int index, int argc)
		{
			printOpcode(opNames[OP_callproperty] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index) + " argc=" + argc);
		}

		public void OP_callproplex(int index, int argc)
		{
			printOpcode(opNames[OP_callproplex] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index) + " argc=" + argc);
		}

		public void OP_constructprop(int index, int argc)
		{
			printOpcode(opNames[OP_constructprop] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index) + " argc=" + argc);
		}

		public void OP_callsuper(int index, int argc)
		{
			printOpcode(opNames[OP_callsuper] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index) + " argc=" + argc);
		}

		public void OP_getsuper(int index)
		{
			printOpcode(opNames[OP_getsuper] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_setsuper(int index)
		{
			printOpcode(opNames[OP_setsuper] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_constructsuper(int argc)
		{
			printOpcode(opNames[OP_constructsuper] + " argc=" + argc);
		}

		public void OP_pushshort(int n)
		{
			printOpcode(opNames[OP_pushshort] + " " + n);
		}

		public void OP_astype(int index)
		{
			printOpcode(opNames[OP_astype] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_astypelate()
		{
			printOpcode(opNames[OP_astypelate]);
		}

		public void OP_coerce(int index)
		{
			printOpcode(opNames[OP_coerce] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_coerce_b()
		{
			printOpcode(opNames[OP_coerce_b]);
		}

		public void OP_coerce_o()
		{
			printOpcode(opNames[OP_coerce_o]);
		}

		public void OP_coerce_a()
		{
			printOpcode(opNames[OP_coerce_a]);
		}

		public void OP_coerce_i()
		{
			printOpcode(opNames[OP_coerce_i]);
		}

		public void OP_coerce_u()
		{
			printOpcode(opNames[OP_coerce_u]);
		}

		public void OP_coerce_d()
		{
			printOpcode(opNames[OP_coerce_d]);
		}

		public void OP_coerce_s()
		{
			printOpcode(opNames[OP_coerce_s]);
		}

		public void OP_istype(int index)
		{
			printOpcode(opNames[OP_istype] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_istypelate()
		{
			printOpcode(opNames[OP_istypelate]);
		}

		public void OP_pushbyte(int n)
		{
			printOpcode(opNames[OP_pushbyte] + " " + n);
		}

		public void OP_getscopeobject(int index)
		{
			printOpcode(opNames[OP_getscopeobject] + " index=" + index);
		}

		public void OP_pushscope()
		{
			printOpcode(opNames[OP_pushscope]);
		}

		public void OP_popscope()
		{
			printOpcode(opNames[OP_popscope]);
		}

		public void OP_convert_i()
		{
			printOpcode(opNames[OP_convert_i]);
		}

		public void OP_convert_u()
		{
			printOpcode(opNames[OP_convert_u]);
		}

		public void OP_throw()
		{
			printOpcode(opNames[OP_throw]);
		}

		public void OP_instanceof()
		{
			printOpcode(opNames[OP_instanceof]);
		}

		public void OP_in()
		{
			printOpcode(opNames[OP_in]);
		}

		public void OP_dxns(int index)
		{
			printOpcode(opNames[OP_dxns] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index));
		}

		public void OP_dxnslate()
		{
			printOpcode(opNames[OP_dxnslate]);
		}

		public void OP_ifnlt(int offset, int pos)
		{
			printOpcode(opNames[OP_ifnlt] + " " + offset);
		}

		public void OP_ifnle(int offset, int pos)
		{
			printOpcode(opNames[OP_ifnle] + " " + offset);
		}

		public void OP_ifngt(int offset, int pos)
		{
			printOpcode(opNames[OP_ifngt] + " " + offset);
		}

		public void OP_ifnge(int offset, int pos)
		{
			printOpcode(opNames[OP_ifnge] + " " + offset);
		}

		public void OP_pushwith()
		{
			printOpcode(opNames[OP_pushwith]);
		}

		public void OP_newactivation()
		{
			printOpcode(opNames[OP_newactivation]);
		}

		public void OP_newcatch(int index)
		{
			printOpcode(opNames[OP_newcatch] + " " + index);
		}

		public void OP_deldescendants()
		{
			printOpcode(opNames[OP_deldescendants]);
		}

		public void OP_getglobalscope()
		{
			printOpcode(opNames[OP_getglobalscope]);
		}

		public void OP_getlocal0()
		{
			printOpcode(opNames[OP_getlocal0]);
		}

		public void OP_getlocal1()
		{
			printOpcode(opNames[OP_getlocal1]);
		}

		public void OP_getlocal2()
		{
			printOpcode(opNames[OP_getlocal2]);
		}

		public void OP_getlocal3()
		{
			printOpcode(opNames[OP_getlocal3]);
		}

		public void OP_setlocal0()
		{
			printOpcode(opNames[OP_setlocal0]);
		}

		public void OP_setlocal1()
		{
			printOpcode(opNames[OP_setlocal1]);
		}

		public void OP_setlocal2()
		{
			printOpcode(opNames[OP_setlocal2]);
		}

		public void OP_setlocal3()
		{
			printOpcode(opNames[OP_setlocal3]);
		}
		
		public void OP_label()
		{
			printOpcode(opNames[OP_label]);		
		}

		public void OP_pushconstant(int id)
		{
			printOpcode(opNames[OP_pushuninitialized] + " " + id);
		}

		public void OP_callsupervoid(int index, int argc)
		{
			printOpcode(opNames[OP_callsupervoid] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index) + " argc=" + argc);
		}

		public void OP_callpropvoid(int index, int argc)
		{
			printOpcode(opNames[OP_callpropvoid] + " cpool[" + index + "]" + " = " + getConstantMultinameValue(index) + " argc=" + argc);
		}

        public void OP_li8()
        {
            printOpcode(opNames[OP_li8]);
        }

        public void OP_li16()
        {
            printOpcode(opNames[OP_li16]);
        }

        public void OP_li32()
        {
            printOpcode(opNames[OP_li32]);
        }

        public void OP_lf32()
        {
            printOpcode(opNames[OP_lf32]);
        }

        public void OP_lf64()
        {
            printOpcode(opNames[OP_lf64]);
        }
        public void OP_si8()
        {
            printOpcode(opNames[OP_si8]);
        }

        public void OP_si16()
        {
            printOpcode(opNames[OP_si16]);
        }

        public void OP_si32()
        {
            printOpcode(opNames[OP_si32]);
        }

        public void OP_sf32()
        {
            printOpcode(opNames[OP_sf32]);
        }

        public void OP_sf64()
        {
            printOpcode(opNames[OP_sf64]);
        }

        public void OP_sxi1()
        {
            printOpcode(opNames[OP_sxi1]);
        }

        public void OP_sxi8()
        {
            printOpcode(opNames[OP_sxi8]);
        }

        public void OP_sxi16()
        {
            printOpcode(opNames[OP_sxi16]);
        }
    }

	private static void print(String s)
	{
		if (currentClass == className && currentMethod == methodName)
		{
			System.out.print(s);
		}
	}

	private static void println(String s)
	{
		if (currentClass == className && currentMethod == methodName)
		{
			System.out.println(s);
		}
	}

	private static void printOpcode(String s)
	{
		if (currentClass == className && currentMethod == methodName &&
		    ((startLine == 0 && endLine == 0) || (currentLine >= startLine && currentLine < endLine)) &&
		    showOpcodes)
		{
			System.out.println(s);
		}
	}

	private static byte[] readBytes(File path) throws IOException
	{
		BufferedInputStream in = null;
		try
		{
			in = new BufferedInputStream(new FileInputStream(path));
			byte[] a = new byte[in.available()];
			in.read(a);
			return a;
		}
		finally
		{
			if (in != null)
			{
				try
				{
					in.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}
}
