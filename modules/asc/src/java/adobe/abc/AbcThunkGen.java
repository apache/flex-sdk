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

package adobe.abc;

import java.io.*;
import java.util.*;

import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;
import adobe.abc.GlobalOptimizer.*;
import static adobe.abc.OptimizerConstants.*;
import static java.lang.Boolean.TRUE;
import static java.lang.Boolean.FALSE;
 
/**
 * @author Steven Johnson
 */
public class AbcThunkGen
{
	static class IndentingPrintWriter extends PrintWriter
	{
		int indent;
		IndentingPrintWriter(Writer w)
		{
			super(w);
		}
		public void println()
		{
			for (int i=0; i < indent; i++)
				print("    ");
			super.println();
		}
		public void println(String s)
		{
			for (int i=0; i < indent; i++)
				print("    ");
			super.println(s);
		}
	}

	public static void main(String[] args) throws IOException
	{
		if (args.length == 0)
		{
			System.out.println("usage: AbcThunkGen [-import foo.abc] bar.abc");
			return;
		}

 		byte[] abcdata = null;
 		InputAbc ia = null;
		String filename = null;
		GlobalOptimizer go = new GlobalOptimizer(); 
		go.ALLOW_NATIVE_CTORS = true;
		for (int i = 0; i < args.length; ++i)
		{
 			if(args[i].equals("-import")) 
			{
				i++;
				InputAbc imported = go.new InputAbc();
				imported.readAbc(load(args[i]));
 				continue;
 			}
			if (ia != null)
			{
				throw new RuntimeException("only one abc file may be specified");
			}
			filename = args[i];
			abcdata = load(filename);
			ia = go.new InputAbc();
			ia.readAbc(abcdata);
		}

		if (ia == null)
		{
			throw new RuntimeException("an abc file must be specified");
		}
		
		String scriptname = filename.substring(0,filename.lastIndexOf('.'));
		emitNatives(ia, abcdata, scriptname, TypeCache.instance().namespaceNames);
	}

	static byte[] load(String filename) throws IOException
	{
		InputStream in = new FileInputStream(filename);
		try
		{
			byte[] before = new byte[in.available()];
			in.read(before);
			return before;
		}
		finally
		{
			in.close();
		}
	}
	
	private InputAbc abc;
	private byte[] abcdata;
	private String name;
	private Map<Namespace,Name> namespaceNames;
	private PrintWriter out_h;
	private IndentingPrintWriter out_c;
	private Map<Integer,String> native_methods;
	private HashMap<Type,Integer> class_id_map;
	private HashMap<String, HashMap<String, Method>> unique_thunks;

	AbcThunkGen(InputAbc abc, byte[] abcdata, String name, Map<Namespace,Name> namespaceNames,
					PrintWriter out_h, IndentingPrintWriter out_c)
	{
		this.abc = abc;
		this.abcdata = abcdata;
		this.name = name;
		this.namespaceNames = namespaceNames;
		this.out_h = out_h;
		this.out_c = out_c;
		this.native_methods = new TreeMap<Integer,String>();
		this.unique_thunks = new HashMap<String, HashMap<String, Method>>();
		this.class_id_map = new HashMap<Type,Integer>();
		for (int i = 0; i < abc.classes.length; ++i)
			this.class_id_map.put(abc.classes[i], i);
	}

	static void emitNatives(InputAbc abc, byte[] abcdata, String name, 
		Map<Namespace,Name> namespaceNames) throws IOException
	{
		PrintWriter out_h = new PrintWriter(new FileWriter(name+".h2"));
		IndentingPrintWriter out_c = new IndentingPrintWriter(new FileWriter(name+".cpp2"));
		try
		{
			AbcThunkGen ngen = new AbcThunkGen(abc, abcdata, name, namespaceNames, out_h, out_c); 
			ngen.emit();
		}
		finally
		{
			out_c.close();
			out_h.close();
		}
	}
	
	private void emit()
	{
		// header file - definitions & native method decls
		out_h.println("/* machine generated file -- do not edit */");
		out_c.println("/* machine generated file -- do not edit */");

		out_h.println("#define AVMTHUNK_VERSION 1");
		
		out_h.printf("const uint32_t %s_abc_class_count = %d;\n",name,abc.classes.length);
		out_h.printf("const uint32_t %s_abc_script_count = %d;\n",name,abc.scripts.length);
		out_h.printf("const uint32_t %s_abc_method_count = %d;\n",name,abc.methods.length);
		out_h.printf("const uint32_t %s_abc_length = %d;\n",name,abcdata.length);
		out_h.printf("extern const uint8_t %s_abc_data[%d];\n",name,abcdata.length);

		for (int i = 0; i < abc.scripts.length; ++i)
		{
			Type s = abc.scripts[i];
			// not enough info in the ABC to recover the original name (eg abcpackage_Foo_as) 
			// so output identifiers based on the native script functions found
			for (Binding bb : s.defs.values())
			{
				if (bb.method != null && bb.method.isNative())
					out_h.println("const uint32_t abcscript_"+ bb.getName() + " = " + i + ";");
			}
			emitSourceTraits("", s);
		}
		
		out_c.println("// "+unique_thunks.size()+" unique thunks");
		for (String sig: unique_thunks.keySet())
		{
			out_c.println();
			HashMap<String, Method> users = unique_thunks.get(sig);
			assert(users.size() > 0);
			Method m = null;
			for (String native_name: users.keySet())
			{
				out_c.println("// "+native_name);
				m = users.get(native_name);
			}
			String thunkname = name+"_"+sig;
			// emit both with and without-cookie versions, since we can't tell at this point which
			// might be used for a particular method. rely on linker to strip the unused ones.
			emitThunk(thunkname, m, false);
			emitThunk(thunkname, m, true);
			for (String native_name: users.keySet())
			{
				m = users.get(native_name);
				out_h.printf("  const uint32_t %s = %d;\n", native_name, m.id);
				// use #define here (rather than constants) to avoid the linker including them and thus preventing dead-stripping
				// (sad but true, happens in some environments)
				out_h.printf("  #define %s_thunk  %s_thunk\n", native_name, thunkname);
				out_h.printf("  #define %s_thunkc %s_thunkc\n", native_name, thunkname);
			}
		}

		// cpp file - abc data, thunks
		out_c.println("const uint8_t "+name+"_abc_data["+abcdata.length+"] = {");
		for (int i=0, n=abcdata.length; i < n; i++)
		{
			int x = abcdata[i] & 255;
			if (x < 10) out_c.print("  ");
			else if (x < 100) out_c.print(' ');
			out_c.print(x);
			if (i+1 < n) out_c.print(", ");
			if (i%16 == 15) out_c.println();
		}
		out_c.println("};");
	}

	void emitSourceTraits(String prefix, Type s)
	{
		if (s.init != null && s.init.isNative())
		{
			String native_name = prefix + s.getName();
			gatherThunk(native_name, s.init);
		}
		for (Binding b: s.defs.values())
		{
			Namespace ns = b.getName().nsset(0);
			String id = prefix + propLabel(b, ns);
			String ctype = null;

			if (b.method != null) 
			{
				if(b.method.isNative())
					emitSourceMethod(prefix, b, ns);
			} 
			else if (GlobalOptimizer.isClass(b))
			{
				emitSourceClass(b, ns);
			}
		}
	}
	
	static String to_cname(String nm)
	{
		// munge symbols that will make C unhappy
		nm = nm.replace("+", "_");
		nm = nm.replace("-", "_");
		nm = nm.replace("?", "_");
		nm = nm.replace("!", "_");
		nm = nm.replace("<", "_");
		nm = nm.replace(">", "_");
		nm = nm.replace("=", "_");
		nm = nm.replace("(", "_");
		nm = nm.replace(")", "_");
		nm = nm.replace("\"", "_");
		nm = nm.replace("'", "_");
		nm = nm.replace("*", "_");
		nm = nm.replace(" ", "_");
		nm = nm.replace(".", "_");
		nm = nm.replace("$", "_");
		nm = nm.replace(":", "_");
		nm = nm.replace("/", "_");
		return nm;
	}

	void emitSourceClass(Binding b, Namespace ns)
	{
		String label = ns_prefix(ns, true) + to_cname(b.getName().name);

		Type c = b.type.t;
		
		out_h.println();
		out_h.println("const uint32_t abcclass_"+ label + " = " + class_id_map.get(c) + ";");

		emitSourceTraits(label+"_", c);
		emitSourceTraits(label+"_", c.itype);
	}
	
	String ctype_i(int ctype, boolean allowObject)
	{
		switch (ctype)
		{
			case CTYPE_OBJECT:	
				if (allowObject)
					return "AvmObject";
				// else fall thru
			case CTYPE_ATOM:		
				return "AvmBox";
			case CTYPE_VOID:		
				return "void";
			case CTYPE_BOOLEAN:		
				return "AvmBoolArg";
			case CTYPE_INT:			
				return "int32_t";
			case CTYPE_UINT:		
				return "uint32_t";
			case CTYPE_DOUBLE:		
				return "double";
			case CTYPE_STRING:		
				return "AvmString";
			case CTYPE_NAMESPACE:	
				return "AvmNamespace";
			default:
				assert(false);
				return "";
		}
	}

	void emitSourceMethod(String prefix, Binding b, Namespace ns)
	{
		Method m = b.method;

		String native_name = prefix + propLabel(b, ns);

		if (GlobalOptimizer.isGetter(b))
			native_name += "_get";
		else if (GlobalOptimizer.isSetter(b))
			native_name += "_set";
		
		gatherThunk(native_name, m);
	}

	String ns_prefix(Namespace ns, boolean iscls)
	{
		if (!ns.isPublic() && !ns.isInternal()) 
		{
			if (ns.isPrivate() && !iscls) return "private_";
			if (ns.isProtected()) return "protected_";
			if (namespaceNames.containsKey(ns)) return namespaceNames.get(ns) + "_";
		}
		String p = to_cname(ns.uri);
		if (p.length() > 0) p += "_";
		return p;
	}
	
	String propLabel(Binding b, Namespace ns)
	{
		return ns_prefix(ns, false) + b.getName().name;
	}

	int defValCType(Object value)
	{
		if (value instanceof Integer)
			return CTYPE_INT;
		if (value instanceof Long)
			return CTYPE_UINT;
		if (value instanceof Double)
		{
			double d = (Double)value;
			if (d == (int)(d))
				return CTYPE_INT;
			if (d == (long)(d))
				return CTYPE_UINT;
			return CTYPE_DOUBLE;
		}
		if (value instanceof String)
			return CTYPE_STRING;
// sorry, not supported in natives
//		if (value instanceof Namespace)
//			return CTYPE_NAMESPACE;
		if (value == TRUE)
			return CTYPE_BOOLEAN;
		if (value == FALSE)
			return CTYPE_BOOLEAN;
		if (value.toString() == "undefined")
			return CTYPE_ATOM;
		if (value.toString() == "null")
			return CTYPE_ATOM;
		throw new RuntimeException("unsupported default-value type "+value.toString());
	}

	String defValStr(Object value)
	{
		// for numeric values, just emit inline rather than looking up in const pool
		if (value instanceof Integer)
			return value.toString();
		if (value instanceof Long)
			return value.toString();
		if (value instanceof Double)
		{
			double d = (Double)value;
			if (d == (int)(d))
				return Integer.toString((int)d, 10);
			if (d == (long)(d))
				return Long.toString((long)d, 10) + "U";
			if (Double.isInfinite(d))
				return (d < 0.0) ? "kAvmThunkNegInfinity" : "kAvmThunkInfinity";
			if (Double.isNaN(d))
				return "kAvmThunkNaN";
			return value.toString();
		}
		if (value instanceof String)
		{
			for (int i = 0; i < abc.strings.length; ++i)
				if (abc.strings[i].equals(value))
					return "AvmThunkConstant_AvmString("+Integer.toString(i, 10)+")/* \""+abc.strings[i]+"\" */";
		}
// sorry, not supported in natives
//		if (value instanceof Namespace)
//			return value.toString();
		if (value == TRUE)
			return "true";
		if (value == FALSE)
			return "false";
		if (value.toString() == "undefined")
			return "kAvmThunkUndefined";
		if (value.toString() == "null")
			return "kAvmThunkNull";
		throw new RuntimeException("unsupported default-value type "+value.toString());
	}

	int get_optional_count(Method m)
	{
		int optional_count = 0;
		if (m.values != null)
			for (Object v : m.values) 
				if (v != null)
					optional_count++;
		return optional_count;
	}
	
	String sigChar(int ctype, boolean allowObject)
	{
		switch (ctype)
		{
			case CTYPE_OBJECT:		
				if (allowObject)
					return "o";
				// else fall thru
			case CTYPE_ATOM:		
				return "a";
			case CTYPE_VOID:		
				return "v";
			case CTYPE_BOOLEAN:		
				return "b";
			case CTYPE_INT:			
				return "i";
			case CTYPE_UINT:		
				return "u";
			case CTYPE_DOUBLE:		
				return "d";
			case CTYPE_STRING:		
				return "s";
			case CTYPE_NAMESPACE:	
				return "n";
			default:
				assert(false);
				return "";
		}
	}

	String thunkSig(Method m)
	{
		String sig = sigChar(m.returns.t.ctype, false)+"2";
		if (m.returns.t.ctype == CTYPE_DOUBLE)
			sig += sigChar(CTYPE_DOUBLE, false);
		else
			sig += sigChar(CTYPE_ATOM, false);
		sig += "_";
		for (int i = 0; i < m.getParams().length; ++i)
		{
			sig += sigChar(m.getParams()[i].t.ctype, true);
		}
		if (m.hasOptional())
		{
			int param_count = m.getParams().length - 1;
			int optional_count = get_optional_count(m);
			for (int i = param_count - optional_count + 1; i <= param_count; i++)
			{
				String dts = sigChar(defValCType(m.values[i]), true);
				String defval = to_cname(defValStr(m.values[i]));
				sig += "_opt" + dts + defval;
			}
		}
		else
		{
			assert(get_optional_count(m) == 0);
		}
		if (m.needsRest())
			sig += "_rest";
		return sig;
	}

	void gatherThunk(String native_name, Method m)
	{
		native_methods.put(m.id, native_name);
		
		String sig = thunkSig(m);
		if (!unique_thunks.containsKey(sig))
			unique_thunks.put(sig, new HashMap<String, Method>());
		unique_thunks.get(sig).put(native_name, m);
	}

	void emitThunk(String name, Method m, boolean cookie)
	{
		String ret = ctype_i(m.returns.t.ctype, false);
		
		out_h.printf("extern AvmThunkRetType_%s AVMTHUNK_CALLTYPE %s_thunk%s(AvmMethodEnv env, uint32_t argc, const AvmBox* argv);\n", ret, name, cookie?"c":"");

		out_c.printf("AvmThunkRetType_%s AVMTHUNK_CALLTYPE %s_thunk%s(AvmMethodEnv env, uint32_t argc, const AvmBox* argv)\n", ret, name, cookie?"c":"");
		out_c.println("{");
		out_c.indent++;

		int param_count = m.getParams().length-1;
		assert(param_count >= 0);
		int optional_count = get_optional_count(m);
		assert(optional_count <= param_count);

		String argszprev = "0";
		for (int i = 0; i < m.getParams().length; ++i)
		{
			String cts = ctype_i(m.getParams()[i].t.ctype, true);
			if (i == 0)
				out_c.println("const uint32_t argoff0 = 0;");
			else
				out_c.println("const uint32_t argoff"+i+" = argoff"+(i-1)+" + "+argszprev+";");
			argszprev = "AvmThunkArgSize_"+cts;
		}
		if (m.needsRest())
		{
			out_c.println("const uint32_t argoffV = argoff"+(m.getParams().length-1)+" + "+argszprev+";");
		}
		
		int argct = m.getParams().length + (cookie?1:0) + (m.needsRest()?2:0);
		String[] argvals = new String[argct];
		String[] argtypes = new String[argct];
		int argsidx = 0;
		for (int i = 0; i < m.getParams().length; ++i)
		{
			String cts = ctype_i(m.getParams()[i].t.ctype, true);
			String val = "AvmThunkUnbox_"+cts+"(argv[argoff" + i + "])";
			if (i > param_count - optional_count)
			{
				String dts = ctype_i(defValCType(m.values[i]), true);
				String defval = defValStr(m.values[i]);
				if (!dts.equals(cts))
					defval = "AvmThunkCoerce_"+dts+"_"+cts+"("+defval+")";
				val = "(argc < "+i+" ? "+defval+" : "+val+")";
			}
			argvals[argsidx] = val;
			argtypes[argsidx] = cts;
			argsidx++;
			if (i == 0 && cookie)
			{
				argvals[argsidx] = "AVMTHUNK_GET_COOKIE(env)";
				argtypes[argsidx] = "int32_t";
				argsidx++;
			}
		}
	
		if (m.needsRest())
		{
			
			argvals[argsidx] = "(argc <= "+param_count+" ? NULL : argv + argoffV)";
			argtypes[argsidx] = "const AvmBox*";
			argsidx++;

			argvals[argsidx] = "(argc <= "+param_count+" ? 0 : argc - "+param_count+")";
			argtypes[argsidx] = "uint32_t";
			argsidx++;
		}

		if (!m.hasOptional() && !m.needsRest())
			out_c.println("(void)argc;");

		out_c.println("AVMTHUNK_DEBUG_ENTER(env)");
		
		String call = "";
		if (m.returns.t.ctype != CTYPE_VOID)
			call += "const "+ret+" ret = ";		
		call += "AVMTHUNK_CALL_FUNCTION_"+(argvals.length-1)+"(AVMTHUNK_GET_HANDLER(env), "+ret;
		out_c.println(call);
		out_c.indent++;
		for (int i = 0; i < argvals.length; ++i)
		{
			out_c.println(", " + argtypes[i] + ", " + argvals[i]);
		}
		out_c.indent--;
		out_c.println(");");

		out_c.println("AVMTHUNK_DEBUG_EXIT(env)");

		out_c.println("return AvmToRetType_"+ret+"(ret);");
		out_c.indent--;
		out_c.println("}");
	}
}
