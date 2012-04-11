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

package flex2.tools;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import macromedia.abc.BytecodeBuffer;
import macromedia.abc.Decoder;
import macromedia.abc.DecoderException;
import macromedia.abc.DefaultVisitor;
import macromedia.abc.MultiName;
import macromedia.abc.QName;
import macromedia.abc.Visitor;

import flash.swf.Frame;
import flash.swf.Movie;
import flash.swf.MovieDecoder;
import flash.swf.TagDecoder;
import flash.swf.tags.DoABC;

/**
 * Command line tool for dumping all the classes, their functions, and
 * the location of each class.
 * 
 * @author Clement Wong
 */
public class MovieMetaDataPrinter
{
	/**
	 * 
	 * @param args
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception
	{
		BufferedInputStream in = new BufferedInputStream(new FileInputStream(args[0]));

		Movie movie = new Movie();
		new TagDecoder(in).parse(new MovieDecoder(movie));

		MovieMetaDataPrinter metadata = new MovieMetaDataPrinter();
		metadata.process(movie);

		System.out.println(metadata.toString());
	}

	/**
	 * 
	 * @param movie
	 */
	public MovieMetaDataPrinter()
	{
		classes = new LinkedHashMap<String, Class>();
		functions = new LinkedHashSet<Function>();
		locations = new LinkedHashMap<String, String>();
	}

	private Map<String, Class> classes;
    private Map<String, String> locations;

	private Set<Function> functions;

	/**
	 * 
	 * @return
	 */
	public boolean process(Movie movie)
	{
		boolean result = true;

		for (int i = 0, frameSize = movie.frames.size(); i < frameSize; i++)
		{
			Frame f = movie.frames.get(i);
			for (int j = 0, codeSize = f.doABCs.size(); j < codeSize; j++)
			{
				DoABC t = f.doABCs.get(j);
				BytecodeBuffer buffer = new BytecodeBuffer(t.abc);
				try
				{
					Decoder decoder = new Decoder(buffer);
					result = processABC(decoder);
				}
				catch (DecoderException ex)
				{
					ex.printStackTrace();
					result = false;
				}
			}
		}

		return result;
	}

	/**
	 * 
	 * @param decoder
	 * @return
	 */
	private boolean processABC(Decoder decoder)
	{
		Visitor v = new ABCVisitor(decoder);
		boolean result = true;

		Decoder.ScriptInfo scriptInfo = decoder.scriptInfo;
		for (int i = 0, size = scriptInfo.size(); i < size; i++)
		{
			try
			{
				scriptInfo.decode(i, v);
			}
			catch (DecoderException ex)
			{
				result = false;
			}
		}

		Decoder.MethodBodies methodBodies = decoder.methodBodies;
		for (int i = 0, size = methodBodies.size(); i < size; i++)
		{
			try
			{
				methodBodies.decode(i, v);
			}
			catch (DecoderException ex)
			{
				result = false;
			}
		}

		return result;
	}

	/**
	 * 
	 */
	public String toString()
	{
		StringWriter w = new StringWriter();
		PrintWriter out = new PrintWriter(w, true);

		for (Iterator<String> i = classes.keySet().iterator(); i.hasNext();)
		{
			String key = i.next();
			Class c = classes.get(key);
			
			if (c.metadata.size() > 0)
			{
				out.println(c.metadata);
			}
			out.println(key);

			for (Iterator<String> j = c.functions.keySet().iterator(); j.hasNext();)
			{
				Function f = c.functions.get(j.next());
				if (f.metadata.size() > 0)
				{
					out.println("\t" + f.metadata);
				}
				out.println("\t" + f.name);
			}
		}

		for (Iterator<Function> i = functions.iterator(); i.hasNext();)
		{
			Function f = i.next();
			if (f.metadata.size() > 0)
			{
				out.println(f.metadata);
			}
			out.println(f.name);
		}

		for (Iterator<String> i = locations.keySet().iterator(); i.hasNext();)
		{
			String key = i.next();
			out.println(key + " --> " + locations.get(key));
		}

		return w.toString();
	}

	class Class
	{
		List<String> metadata = new ArrayList<String>();
		Map<String, Function> functions = new LinkedHashMap<String, Function>();
	}

	class Function
	{
		List<String> metadata = new ArrayList<String>();
		String name;

		public String toString()
		{
			return name;
		}
	}

	/**
	 * 
	 */
	class ABCVisitor extends DefaultVisitor
	{
		ABCVisitor(Decoder decoder)
		{
			super(decoder);
			methods = new HashMap<Integer, String>();
			mdStack = new Stack<List<String>>();
		}

		private String currentClass, currentFunction, currentDefinition;
		private Map<Integer, String> methods;
		private Stack<List<String>> mdStack;

		private void registerMethodInfo(int methodInfo)
		{
			if (currentClass != null)
			{
				methods.put(new Integer(methodInfo), currentClass);
			}
			else if (currentFunction != null)
			{
				methods.put(new Integer(methodInfo), currentFunction);
			}
		}

		/**
		 * 
		 * @param className
		 */
		private void registerClass(String className)
		{
			if (!classes.containsKey(className))
			{
				classes.put(className, new Class());
			}
			Class clazz = classes.get(className);
			mdStack.push(clazz.metadata);
			currentClass = className;
		}

		/**
		 * 
		 * @param functionName
		 */
		private void registerFunction(String functionName)
		{
			Function f = new Function();
			f.name = functionName;
			functions.add(f);
			currentFunction = functionName;
			mdStack.push(f.metadata);
		}

		/**
		 * 
		 * @param functionName
		 */
		private void registerMethod(String functionName)
		{
			Class c = classes.get(currentClass);
			if (c != null)
			{
				Function f = new Function();
				f.name = functionName;
				c.functions.put(functionName, f);
				mdStack.push(f.metadata);
			}
		}

		public void beginABC()
		{
		}

		public void beginBody(int methodID, int codeStart, long codeLength)
		{
			currentDefinition = methods.get(new Integer(methodID));
		}

		public void beginCInit(int methodID)
		{
			registerMethodInfo(methodID);
			mdStack.push(new ArrayList<String>(1));
		}

		public void beginClass(QName name, int slotID)
		{
			registerClass(name.toString());
		}

		public void beginConst(QName name, int slotID, QName type, Object value)
		{
			mdStack.push(new ArrayList<String>(1));
		}

		public void beginFunction(int methodID, QName name, int slotID)
		{
			registerFunction(name.toString());
			registerMethodInfo(methodID);
		}

		public void beginGetter(int methodID, QName name, int dispID, int attr)
		{
			if (currentClass != null)
			{
				registerMethod("get " + name.toString());
			}
			else
			{
				registerFunction("get " + name.toString());
			}
			registerMethodInfo(methodID);
		}

		public void beginIInit(int methodID)
		{
			registerMethodInfo(methodID);
		}

		public void beginMethod(int methodID, QName name, int dispID, int attr)
		{
			registerMethod(name.toString());
			registerMethodInfo(methodID);
		}

		public void beginSetter(int methodID, QName name, int dispID, int attr)
		{
			if (currentClass != null)
			{
				registerMethod("set " + name.toString());
			}
			else
			{
				registerFunction("set " + name.toString());
			}
			registerMethodInfo(methodID);
		}

		public void beginVar(QName name, int slotID, QName type, Object value)
		{
			mdStack.push(new ArrayList<String>(1));
		}

		public void classInfo(QName name)
		{
		}

		public void endABC()
		{
		}

		public void endBody()
		{
		}

		public void endCInit()
		{
			mdStack.pop();
		}

		public void endClass(QName name)
		{
			currentClass = null;
			mdStack.pop();
		}

		public void endConst(QName name)
		{
			mdStack.pop();
		}

		public void endFunction(QName name)
		{
			currentFunction = null;
			mdStack.pop();
		}

		public void endGetter(QName name)
		{
			if (currentClass != null)
			{
				Class c = classes.get(currentClass);
				if (c != null)
				{
					mdStack.pop();
				}
			}
			else
			{
				mdStack.pop();
			}
			currentFunction = null;
		}

		public void endIInit()
		{
		}

		public void endMethod(QName name)
		{
			Class c = classes.get(currentClass);
			if (c != null)
			{
				mdStack.pop();
			}
		}

		public void endSetter(QName name)
		{
			if (currentClass != null)
			{
				Class c = classes.get(currentClass);
				if (c != null)
				{
					mdStack.pop();
				}
			}
			else
			{
				mdStack.pop();
			}
			currentFunction = null;
		}

		public void endVar(QName name)
		{
			mdStack.pop();
		}

		public void instanceInfo(QName name, QName superName, MultiName[] interfaces)
		{
		}

		public void metadata(String name, String[] keys, String[] values)
		{
			List<String> metadata = mdStack.peek();
			if (metadata != null)
			{
				StringBuilder b = new StringBuilder();
				b.append(name);
				b.append("(");
				for (int i = 0, size = keys == null ? 0 : keys.length; i < size; i++)
				{
					if (keys[i] != null)
					{
						b.append(keys[i]);
						b.append("=");
					}
					b.append(values[i]);
					if (i < size - 1)
					{
						b.append(",");
					}
				}
				b.append(")");
				metadata.add(b.toString());
			}
		}

		public void methodInfo(QName returnType, QName[] paramTypes, String nativeName, int flags, Object[] values,
				String[] param_names)
		{
		}

		public void OP_add()
		{
		}

		public void OP_add_i()
		{
		}
		
		public void OP_add_p(int i)
		{
		}

		public void OP_astype(int index)
		{
		}

		public void OP_astypelate()
		{
		}

		public void OP_bitand()
		{
		}

		public void OP_bitnot()
		{
		}

		public void OP_bitor()
		{
		}

		public void OP_bitxor()
		{
		}

		public void OP_bkpt()
		{
		}

		public void OP_bkptline()
		{
		}

		public void OP_call(int size)
		{
		}

		public void OP_callmethod(int id, int argc)
		{
		}

		public void OP_callproperty(int index, int argc)
		{
		}

		public void OP_callproplex(int index, int argc)
		{
		}

		public void OP_callpropvoid(int index, int argc)
		{
		}

		public void OP_callstatic(int id, int argc)
		{
		}

		public void OP_callsuper(int index, int argc)
		{
		}

		public void OP_callsupervoid(int index, int argc)
		{
		}

		public void OP_checkfilter()
		{
		}

		public void OP_coerce(int index)
		{
		}

		public void OP_coerce_a()
		{
		}

		public void OP_coerce_b()
		{
		}

		public void OP_coerce_d()
		{
		}

		public void OP_coerce_i()
		{
		}

		public void OP_coerce_o()
		{
		}

		public void OP_coerce_s()
		{
		}

		public void OP_coerce_u()
		{
		}

		public void OP_construct(int size)
		{
		}

		public void OP_applytype(int size)
		{
		}

		public void OP_constructprop(int index, int argc)
		{
		}

		public void OP_constructsuper(int argc)
		{
		}

		public void OP_convert_b()
		{
		}

		public void OP_convert_d()
		{
		}

		public void OP_convert_i()
		{
		}

		public void OP_convert_o()
		{
		}

		public void OP_convert_s()
		{
		}

		public void OP_convert_u()
		{
		}

		public void OP_convert_m()
		{
		}

		public void OP_convert_m_p(int i)
		{
		}

		public void OP_debug(int di_local, int index, int slot, int linenum)
		{
		}

		public void OP_debugfile(int index)
		{
			try
			{
				String value = decoder.constantPool.getString(index);
				if (currentDefinition != null && !locations.containsKey(currentDefinition))
				{
					locations.put(currentDefinition, value);
				}
			}
			catch (DecoderException ex)
			{
			}
		}

		public void OP_debugline(int linenum)
		{
		}

		public void OP_declocal(int index)
		{
		}

		public void OP_declocal_i(int index)
		{
		}

		public void OP_declocal_p(int i1, int i2)
		{
		}

		public void OP_decrement()
		{
		}

		public void OP_decrement_i()
		{
		}

		public void OP_decrement_p(int i)
		{
		}

		public void OP_deldescendants()
		{
		}

		public void OP_deleteproperty(int index)
		{
		}

		public void OP_divide()
		{
		}

		public void OP_divide_p(int i)
		{
		}

		public void OP_dup()
		{
		}

		public void OP_dxns(int index)
		{
		}

		public void OP_dxnslate()
		{
		}

		public void OP_equals()
		{
		}

		public void OP_esc_xattr()
		{
		}

		public void OP_esc_xelem()
		{
		}

		public void OP_finddef(int index)
		{
		}

		public void OP_findproperty(int index)
		{
		}

		public void OP_findpropstrict(int index)
		{
		}

		public void OP_getdescendants(int index)
		{
		}

		public void OP_getglobalscope()
		{
		}

		public void OP_getglobalslot(int index)
		{
		}

		public void OP_getlex(int index)
		{
		}

		public void OP_getlocal(int index)
		{
		}

		public void OP_getlocal0()
		{
		}

		public void OP_getlocal1()
		{
		}

		public void OP_getlocal2()
		{
		}

		public void OP_getlocal3()
		{
		}

		public void OP_getproperty(int index)
		{
		}

		public void OP_getscopeobject(int index)
		{
		}

		public void OP_getslot(int index)
		{
		}

		public void OP_getsuper(int index)
		{
		}

		public void OP_greaterequals()
		{
		}

		public void OP_greaterthan()
		{
		}

		public void OP_hasnext()
		{
		}

		public void OP_hasnext2(int objectRegister, int indexRegister)
		{
		}

		public void OP_ifeq(int offset, int nextPos)
		{
		}

		public void OP_iffalse(int offset, int nextPos)
		{
		}

		public void OP_ifge(int offset, int nextPos)
		{
		}

		public void OP_ifgt(int offset, int nextPos)
		{
		}

		public void OP_ifle(int offset, int nextPos)
		{
		}

		public void OP_iflt(int offset, int nextPos)
		{
		}

		public void OP_ifne(int offset, int nextPos)
		{
		}

		public void OP_ifnge(int offset, int nextPos)
		{
		}

		public void OP_ifngt(int offset, int nextPos)
		{
		}

		public void OP_ifnle(int offset, int nextPos)
		{
		}

		public void OP_ifnlt(int offset, int nextPos)
		{
		}

		public void OP_ifstricteq(int offset, int nextPos)
		{
		}

		public void OP_ifstrictne(int offset, int nextPos)
		{
		}

		public void OP_iftrue(int offset, int nextPos)
		{
		}

		public void OP_in()
		{
		}

		public void OP_inclocal(int index)
		{
		}

		public void OP_inclocal_i(int index)
		{
		}

		public void OP_inclocal_p(int i1, int i2)
		{
		}

		public void OP_increment()
		{
		}

		public void OP_increment_i()
		{
		}

		public void OP_increment_p(int i)
		{
		}

		public void OP_initproperty(int index)
		{
		}

		public void OP_instanceof()
		{
		}

		public void OP_istype(int index)
		{
		}

		public void OP_istypelate()
		{
		}

		public void OP_jump(int jump, int pos)
		{
		}

		public void OP_kill(int index)
		{
		}

		public void OP_label()
		{
		}

		public void OP_lessequals()
		{
		}

		public void OP_lessthan()
		{
		}

		public void OP_lookupswitch(int defaultPos, int[] casePos, int thisPos, int caseTablePos)
		{
		}

		public void OP_lshift()
		{
		}

		public void OP_modulo()
		{
		}

		public void OP_modulo_p(int i)
		{
		}

		public void OP_multiply()
		{
		}

		public void OP_multiply_i()
		{
		}

		public void OP_multiply_p(int i)
		{
		}

		public void OP_negate()
		{
		}

		public void OP_negate_i()
		{
		}

		public void OP_negate_p(int index)
		{
		}

		public void OP_newactivation()
		{
		}

		public void OP_newarray(int size)
		{
		}

		public void OP_newcatch(int index)
		{
		}

		public void OP_newclass(int id)
		{
		}

		public void OP_newfunction(int id)
		{
		}

		public void OP_newobject(int size)
		{
		}

		public void OP_nextname()
		{
		}

		public void OP_nextvalue()
		{
		}

		public void OP_nop()
		{
		}

		public void OP_not()
		{
		}

		public void OP_pop()
		{
		}

		public void OP_popscope()
		{
		}

		public void OP_pushbyte(int n)
		{
		}

		public void OP_pushconstant(int id)
		{
		}

		public void OP_pushdouble(int index)
		{
		}

		public void OP_pushdecimal(int index)
		{
		}

		public void OP_pushfalse()
		{
		}

		public void OP_pushint(int index)
		{
		}

		public void OP_pushnamespace(int index)
		{
		}

		public void OP_pushnan()
		{
		}

		public void OP_pushdnan()
		{
		}

		public void OP_pushnull()
		{
		}

		public void OP_pushscope()
		{
		}

		public void OP_pushshort(int n)
		{
		}

		public void OP_pushstring(int index)
		{
		}

		public void OP_pushtrue()
		{
		}

		public void OP_pushuint(int index)
		{
		}

		public void OP_pushundefined()
		{
		}

		public void OP_pushwith()
		{
		}

		public void OP_returnvalue()
		{
		}

		public void OP_returnvoid()
		{
		}

		public void OP_rshift()
		{
		}

		public void OP_setglobalslot(int index)
		{
		}

		public void OP_setlocal(int index)
		{
		}

		public void OP_setlocal0()
		{
		}

		public void OP_setlocal1()
		{
		}

		public void OP_setlocal2()
		{
		}

		public void OP_setlocal3()
		{
		}

		public void OP_setproperty(int index)
		{
		}

		public void OP_setslot(int index)
		{
		}

		public void OP_setsuper(int index)
		{
		}

		public void OP_strictequals()
		{
		}

		public void OP_subtract()
		{
		}

		public void OP_subtract_i()
		{
		}

		public void OP_subtract_p(int i)
		{
		}

		public void OP_swap()
		{
		}

		public void OP_throw()
		{
		}

		public void OP_timestamp()
		{
		}

		public void OP_typeof()
		{
		}

		public void OP_urshift()
		{
		}

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

		public void target(int pos)
		{
		}
	}
}
