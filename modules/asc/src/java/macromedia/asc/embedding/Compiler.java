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

package macromedia.asc.embedding;

import macromedia.asc.embedding.avmplus.ActionBlockEmitter;
import macromedia.asc.embedding.avmplus.GlobalBuilder;
import macromedia.asc.embedding.avmplus.Features;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.*;
import macromedia.asc.util.*;
import macromedia.abc.AbcParser;
import macromedia.abc.Optimizer;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.ByteArrayInputStream;
import java.util.Iterator;

/**
 * The main interface to the compiler.
 *
 * @author Jeff Dyer
 */
public class Compiler implements ErrorConstants
{
	//TODO Probably want to comment out all "ex.printStackTrace();" calls -- or at least add a debug flag to it
	
    static int ref_count = 0;
    
    private static final String newline = System.getProperty("line.separator");

    static void init()
    {
        // Init the subsystems. This is not thread-safe. To make thread-safe
        // make init and fini critical sections.

        if (ref_count == 0)
        {
            TypeValue.init();
            ObjectValue.init();
        }

        ++ref_count;
    }

    static int col_counter = 0; // Not thread-safe, but do we care?

    static void print_byte(byte b)
    {
        if (col_counter % 16 == 0)
        {
            System.out.print("\n\t");
        }
        System.out.print(Integer.toHexString(b));
        ++col_counter;
    }

    static void compile(Context cx, ObjectValue global,
        InputStream in, String filename, String file_encoding,
        ObjectList<IncludeInfo> includes,
		String swf_options,
		String avmplus_exe,
	ObjectList<CompilerPlug> plugs,
	boolean emit_doc_info, boolean show_parsetrees, boolean show_bytes, boolean show_flow, 
    boolean lint_mode, boolean emit_metadata, boolean save_comment_nodes, boolean emit_debug_info, ObjectList<String> import_filespecs)
    {
        ProgramNode second = null;
	    
		ObjectList<ImportNode> imports = new ObjectList<ImportNode>();
        for( String filespec : import_filespecs )
        {
            Context cx2 = new Context(cx.statics);

            BufferedInputStream import_in = null;
            try
            {
                if( filespec.endsWith(".abc") )
                {
                    second = (new AbcParser(cx2, filespec)).parseAbc();
                    if( second == null  )
                    {
                        cx.error(-1, kError_InvalidAbcFile, filespec);
                    }
                }
                else
                {
                	import_in = new BufferedInputStream(new FileInputStream(filespec));
	                cx2.setPath(new File(filespec).getAbsoluteFile().getParent());
                    second = (new Parser(cx2, import_in, filespec, null, emit_doc_info, save_comment_nodes)).parseProgram();
                }
            }
            catch (IOException ex) { cx.error(-1, kError_UnableToOpenFile, filespec); }
            finally
            {
                if (import_in != null)
                {
                    try { import_in.close(); } 
                    catch (IOException ex) {}
                }
            }

            /* debug
             for (String s : cx.getNodeFactory().pkg_names.keySet())
             {
             System.out.println(s);
             }
             */
			NodeFactory nodeFactory = cx2.getNodeFactory();
			imports.push_back(nodeFactory.Import(cx2, nodeFactory.literalString(filespec,0),second));
			cx2.getNodeFactory().pkg_defs.clear();
        }

        // Parse

	    cx.setPath(new File(filename).getAbsoluteFile().getParent());
        ProgramNode node = (new Parser(cx, in, filename, file_encoding, emit_doc_info, save_comment_nodes)).parseProgram();
        node.imports = imports; // add the imports

        // test error strings:
        /*
		{
			cx.error(-1, kError_UnableToOpenFile, "someFile");

			parser.testErrorStrings();

			FlowGraphEmitter flowem = new FlowGraphEmitter(cx,filename,show_flow);
			FlowAnalyzer     flower = new FlowAnalyzer(flowem);
			flower.testErrorStrings(cx);

			ConstantEvaluator analyzer = new ConstantEvaluator(cx);
			analyzer.testErrorStrings(cx);

			LintEvaluator evaluator = new LintEvaluator(cx,filename,lint_mode,use_static_semantics);
			evaluator.testErrorStrings(cx);

			CodeGenerator generator = new CodeGenerator(cx.getEmitter());
			generator.testErrorStrings(cx);
		}
        */

        ObjectList<ProgramNode> nodes = new ObjectList<ProgramNode>();
		
            // Assemble program from its parts

        {
            ProgramNode node2;

            {
				if(includes != null) {
					Iterator<IncludeInfo> in_it = includes.iterator();
					for( ; in_it.hasNext(); )
					{
						IncludeInfo iinfo = in_it.next();
						Context cx2 = new Context(cx.statics);
						node2 = (new Parser(cx2,iinfo.script,iinfo.name, iinfo.encoding, emit_doc_info, save_comment_nodes)).parseProgram();
						nodes.add(node2);
					}
				}
			}
        }

        cx.pushScope(global); // first scope is always considered the global scope.

        if( includes != null && includes.size() > 0 )
        {
            ObjectList<Node> stmts = node.statements.items;
            for( int i = nodes.size()-1; i >= 0; --i )
            {
                Context cx2 = nodes.get(i).cx;  // get the program nodes context
                NodeFactory nodeFactory = cx2.getNodeFactory();

		        String name = includes.get(i).name;
                LiteralStringNode first  = nodeFactory.literalString(name,0);
                IncludeDirectiveNode idn = nodeFactory.includeDirective(cx2,first,nodes.get(i));
                StatementListNode istmts = nodeFactory.statementList(null,idn);
                ObjectList<Node> items   = istmts.items;
                stmts.addAll(0,items);
            }
        }

        node.pkgdefs.clear();
        node.pkgdefs.addAll(cx.getNodeFactory().pkg_defs);

        if( show_parsetrees && cx.errorCount() == 0 )
        {
            printParseTrees(cx.scriptName(), node, cx, ".p");
            return;
        }

        // Analyze

        if (cx.errorCount() == 0)
        {
        	ConfigurationEvaluator ce = new ConfigurationEvaluator();
        	node.evaluate(cx, ce);
        }
        if (cx.errorCount() == 0)
        {
            FlowGraphEmitter flowem = new FlowGraphEmitter(cx, filename, show_flow);
            FlowAnalyzer flower = new FlowAnalyzer(flowem);
	        // 1. ProgramNode.state == Inheritance
	        node.evaluate(cx, flower);
	        // 2. ProgramNode.state == else
	        node.evaluate(cx, flower);
        }

       if( cx.errorCount() == 0)
        {
            if( emit_metadata )
            {
                MetaDataEvaluator printer = new MetaDataEvaluator(emit_debug_info);
                node.evaluate(cx,printer);
            }
        }

        if (cx.errorCount() == 0)
        {
            ConstantEvaluator analyzer = new ConstantEvaluator(cx);
            node.evaluate(cx, analyzer);
        }

        if (cx.errorCount() == 0 && emit_doc_info)
		{
			MetaDataEvaluator printer = new MetaDataEvaluator();
			node.evaluate(cx,printer);

			StringBuilder out = new StringBuilder();
			out.append("<asdoc>").append(newline);

			ObjectList<DocCommentNode> comments = printer.doccomments;
			int numComments = comments.size();
            Node prev = null;
            for(int x = 0; x < numComments; x++)
			{
                DocCommentNode d = comments.get(x);
                d.emit(cx,out);
                prev = d.def;
            }
			out.append(newline).append("</asdoc>").append(newline);

			BufferedOutputStream warningOut = null;
			try
			{
				String outName =  cx.scriptName() + ".xml";
				warningOut = new BufferedOutputStream(new FileOutputStream(new File(cx.path(), outName)));
				warningOut.write(out.toString().getBytes());
				warningOut.flush();
			}
			catch (IOException ex)
			{
				ex.printStackTrace();
			}
			finally
			{
				if (warningOut != null)
				{
					try
					{
						warningOut.close();
						System.err.println("wrote .xml doc file: " + cx.path() + "/" + cx.scriptName() + ".xml" );
					}
					catch (IOException ex) {}
				}
			}
			// this is not the end of the method -- just an early return if the IF is taken
			return;
		} // endif



 		// check for common errors
		if( lint_mode && cx.errorCount() == 0 )
        {
			LintEvaluator evaluator = new LintEvaluator(cx, filename, (String)null);
			node.evaluate(cx,evaluator);
			evaluator.logWarnings(cx);
			evaluator.clear();
        }

        // Generate
        if (cx.errorCount() == 0)
        {
            Emitter emitter = cx.getEmitter();
            CodeGenerator generator = new CodeGenerator(emitter);
            node.evaluate(cx, generator);
        }

        // Clean up

        cx.popScope();

    }

    /*
     * helper function that will complete the entire compile
     * process, but allow both filestreams and regular input
     * streams to be compiled.
     */
    static boolean doCompile(InputStream in,
        String pathspec,
        String scriptname,
        String filename,
        String encoding,
		String swf_options,
		String avmplus_exe,
        ObjectList<IncludeInfo> includes,
    ObjectList<String> import_filespecs,
    ObjectList<String> use_namespaces,
	String language,
    ObjectList<ConfigVar> configs,
    ObjectList<CompilerPlug> plugs,
    CompilerHandler handler,
        boolean emit_doc_info /*false*/,
			boolean emit_debug_info /*=false*/,
                boolean show_instructions /*=false*/,
                    boolean show_machinecode /*=false*/,
                        boolean show_linenums /*=false*/,
                            boolean show_parsetrees /*=false*/,
                                boolean show_bytes /*=false*/,
                                    boolean show_flow /*=false*/,
                                        boolean lint_mode /*=false*/,
                                            boolean use_static_semantics /*=false*/,
                                                boolean emit_metadata,
                                                    boolean save_comment_nodes/*=false*/,
                                                        int dialect /*=0*/,
                                                            int target,
                                                                boolean optimize,
							 ObjectList<ConfigVar> optimizer_configs,
							 int api_version)
    {
        // Initialize the compiler before compiling anything
        init();

        // Create and initialize a compiler context
		ContextStatics statics = new ContextStatics();
		statics.handler = handler;
		statics.use_static_semantics = use_static_semantics;
        statics.dialect = dialect;
        statics.setAbcVersion(target);
        
        // set up use_namespaces anytime before parsing begins
        if (use_namespaces != null)
        {
            statics.use_namespaces.addAll(use_namespaces);
        }
        
        // don't allow decimal on 1.4
        {
        	String ver = System.getProperty("java.version", "noVersion");
        	if (ver.indexOf("1.4") >= 0)
        		statics.es4_numerics = false;
        }

        Context cx = new Context(statics);
		cx.setLanguage(language);
        cx.setPath(pathspec);
        cx.setScriptName(scriptname);
        ActionBlockEmitter emitter =
        	new ActionBlockEmitter(cx, scriptname,
        						   new StringPrintWriter(),//code_out
        						   new StringPrintWriter(),//header_out
        						   show_instructions, show_machinecode,
        						   show_linenums, emit_debug_info);
        
        // ISSUE: does authoring need the output filename to be filename rather than scriptname?
        cx.setEmitter(emitter);  // retrieve emitter using cx.getEmitter();
        cx.setHandler(handler);
        
        cx.config_vars = configs;

        //		#if TRANSLATE_COMPOUND_NAMES
        //		// This is a test
        //		std::vector<String> compound_names;
        //		compound_names.push_back("Foo.bar");
        //		cx.setCompoundNames(compound_names);
        //		#endif // USE_COMPOUND_NAMES

        // Build the global object
        Builder globalBuilder = new GlobalBuilder();
        ObjectValue global = new ObjectValue(cx, globalBuilder, null);

        // Compiler something
        compile(cx, global, in, filename, encoding, includes, swf_options, avmplus_exe, plugs, emit_doc_info, show_parsetrees, show_bytes,
                show_flow, lint_mode, emit_metadata, save_comment_nodes, emit_debug_info, import_filespecs);

        int error_count = status(cx);

        if (error_count == 1)
        {
        	System.err.println();
            System.err.println("1 error found");
        }
        else if (error_count > 1)
        {
        	System.err.println();
            System.err.println(error_count + " errors found");
        }
        else if (show_parsetrees == false && emit_doc_info == false)
		{
			if (show_instructions)
			{
				printIL(cx, scriptname, emitter);
			}

			if (error_count == 0 && !show_parsetrees)
			{
				ByteList bytes = new ByteList();
				emitter.emit(bytes);            // Emit it
				if (bytes.size() != 0)
				{
                    if( optimize )
                    {
                        bytes = Optimizer.optimize(bytes);
                    }
                    
                    if ( optimizer_configs != null )
                    {
                    	try
                    	{
                    		byte[] optimized_abc = adobe.abc.GlobalOptimizer.optimize(bytes.toByteArray(), filename, optimizer_configs, import_filespecs);
                    		bytes.clear();
                    		bytes.addAll(optimized_abc);
                    	}
                    	catch ( Exception ex )
                    	{
                    		System.err.println("Unable to optimize due to:");
                    		ex.printStackTrace();
                    	}
                    }
					BufferedOutputStream code_out = null;
					try
					{
						code_out = new BufferedOutputStream(new FileOutputStream(new File(pathspec, scriptname + ".abc")));
						code_out.write(bytes.toByteArray());
						code_out.flush();
					}
					catch (IOException ex)
					{
						ex.printStackTrace();
					}
					finally
					{
						if (code_out != null)
						{
							try
							{
								code_out.close();
							}
							catch (IOException ex)
							{
							}
						}
					}

					System.err.println();

					if (swf_options.length() == 0
							// suppress this for sanity - byte size may change
							&& !ContextStatics.useSanityStyleErrors)
					{
						System.err.println(scriptname + ".abc, " + bytes.size() + " bytes written");
					}
					
					if (avmplus_exe != null)
					{
						createProjector(avmplus_exe, pathspec, scriptname, bytes);
					}

					if (swf_options.length() != 0)
					{
                        makeSwf(cx, bytes, swf_options, pathspec, scriptname);
                    }

					if (emitter.native_method_count > 0)
					{
						printNative(cx, scriptname, emitter, bytes.toByteArray(false));
					}
					
				}
			}
        }

        // Finalize the compiler before exiting process
		statics.clear();
        fini();

        return (error_count == 0);
    }

    static void makeSwf(Context cx, ByteList bytes, String swf_options, String pathspec, String scriptname) {
        SwfMaker swfMaker = new SwfMaker();
        if( cx.abcVersion(Features.TARGET_AVM2) )
            swfMaker.swf_version = 10;
        if (!swfMaker.EncodeABC(bytes, swf_options))
        {
            System.err.println("ERROR: invalid -swf options, should be classname,width,height");
        }
        else
        {
            BufferedOutputStream swf_out = null;
            try
            {
                swf_out = new BufferedOutputStream(new FileOutputStream(new File(pathspec, scriptname + ".swf")));
                swf_out.write(swfMaker.buffer.toByteArray());
                swf_out.flush();
            }
            catch (IOException ex)
            {
                ex.printStackTrace();
            }
            finally
            {
                if (swf_out != null)
                {
                    try
                    {
                        swf_out.close();
                    }
                    catch (IOException ex)
                    {
                    }
                }
            }

            System.err.println(scriptname + ".swf, " + swfMaker.buffer.size() + " bytes written");
        }
    }

    static boolean doCompile(
        CompilerPlug mainplug,
        ObjectList<CompilerPlug> plugs,
        boolean show_instructions /*=false*/,
        boolean show_machinecode /*=false*/,
        boolean show_linenums /*=false*/,
        boolean show_parsetrees /*=false*/,
        boolean show_bytes /*=false*/,
        boolean show_flow /*=false*/)        throws Exception
    {
        // rsun 11.18.05 let's open InputStreams for all the plugs, then
        // send them to compile(.)
        if(mainplug != null) {
            File f = new File(mainplug.filename.trim());
            InputStream in;
            if(f.exists())
            {
                in = new BufferedInputStream(new FileInputStream(f));
            }
            else {
                byte[] buf = new byte[1];
                buf[0] = 0;
                in = new ByteArrayInputStream(buf);
            }

            if(in != null) {
                mainplug.in = in;
            }
        }

        Iterator<CompilerPlug> plug_it = plugs.iterator();
        for( ; plug_it.hasNext(); )
        {
            CompilerPlug plug = plug_it.next();

            File f = new File(plug.filename.trim());
            InputStream in;
            if(f.exists())
            {
                in = new BufferedInputStream(new FileInputStream(f));
            }
            else {
                byte[] buf = new byte[1];
                buf[0] = 0;
                in = new ByteArrayInputStream(buf);
            }

            if(in != null) {
                plug.in = in;
            }
        }

        CompilerHandler handler = null;

        if(handler == null) {
            handler = mainplug.handler;
        }

        return doCompile(
                mainplug.in,
                mainplug.pathspec,
                mainplug.scriptname,
                mainplug.filename,
                mainplug.file_encoding,
                mainplug.swf_options,
                mainplug.avmplus_exe,
                mainplug.includes,
                mainplug.import_filespecs,
                mainplug.use_namespaces,
                mainplug.language,
                mainplug.configs,
                plugs,
                handler,
                mainplug.emit_doc_info,
                mainplug.emit_debug_info,
                show_instructions,
                show_machinecode,
                show_linenums,
                show_parsetrees,
                show_bytes,
                show_flow,
                mainplug.lint_mode,
                mainplug.use_static_semantics,
                mainplug.emit_metadata,
                mainplug.save_comment_nodes,
                mainplug.dialect,
                mainplug.target,
                mainplug.optimize,
                mainplug.optimizer_configs,
				mainplug.api_version
                    );
    }

    static boolean doCompile(
        CompilerPlug mainplug )
    {
        return doCompile(
            mainplug.in,
            mainplug.pathspec,
            mainplug.scriptname,
            mainplug.filename,
            mainplug.file_encoding,
            mainplug.swf_options,
            mainplug.avmplus_exe,
            mainplug.includes,
            mainplug.import_filespecs,
            mainplug.use_namespaces,
		    mainplug.language,
            mainplug.configs,
            new ObjectList<CompilerPlug>(),
            mainplug.handler,
		    mainplug.emit_doc_info, /*=false*/
            mainplug.emit_debug_info, /*=false*/
            false /*=false*/,
            false /*=false*/,
            false /*=false*/,
            false /*=false*/,
            false /*=false*/,
            false /*=false*/,
            mainplug.lint_mode /*=false*/,
            mainplug.use_static_semantics /*=false*/,
            mainplug.emit_metadata,
            mainplug.save_comment_nodes,
            mainplug.dialect,
            mainplug.target,
            mainplug.optimize,
            mainplug.optimizer_configs,
			mainplug.api_version);
    }
    
    static void createProjector(String avmplus_exe, String pathspec, String scriptname, ByteList bytes)
    {
    	BufferedInputStream exe_in = null;
    	BufferedOutputStream exe_out = null;
    	int bytesWritten = 0;
    	
    	try
    	{
    		exe_in = new BufferedInputStream(new FileInputStream(new File(avmplus_exe)));
    		
    		int abc_length = bytes.size();
    		
    		int avmplus_exe_length = exe_in.available();
    		byte avmplus_exe_bytes[] = new byte[avmplus_exe_length];
    		exe_in.read(avmplus_exe_bytes);
    		    		
    		exe_out = new BufferedOutputStream(new FileOutputStream(new File(pathspec, scriptname + ".exe")));
    		
    		exe_out.write(avmplus_exe_bytes);
    		bytesWritten += avmplus_exe_bytes.length;
    		
    		exe_out.write(bytes.toByteArray());
    		bytesWritten += abc_length;

    		byte header[] = new byte[8];
    		header[0] = 0x56;
    		header[1] = 0x34;
    		header[2] = 0x12;
    		header[3] = (byte) 0xFA;
    		header[4] = (byte) (abc_length & 0xFF);
    		header[5] = (byte) ((abc_length>>8) & 0xFF);
    		header[6] = (byte) ((abc_length>>16) & 0xFF);
    		header[7] = (byte) ((abc_length>>24) & 0xFF);
    		exe_out.write(header);
    		
    		bytesWritten += 8;
    		
    		exe_out.flush();
    	}
		catch (IOException ex)
		{
			ex.printStackTrace();
		}
		finally
		{
			if (exe_in != null)
			{
				try
				{
					exe_in.close();
				}
				catch (IOException ex)
				{
				}
			}
			if (exe_out != null)
			{
				try
				{
					exe_out.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	
		System.err.println(scriptname + ".exe, " + bytesWritten + " bytes written");
	}

    static void printIL(Context cx, String scriptname, ActionBlockEmitter emitter)
    {
        if (status(cx) == 0)
        {
            FileWriter out = null;
            String str = emitter.il_str();
            try
            {
                out = new FileWriter(new File(cx.path(), scriptname + ".il"));
                out.write(str);
                out.flush();
            }
            catch (IOException ex)
            {
                ex.printStackTrace();
            }
            finally
            {
                if (out != null)
                {
                    try
                    {
                        out.close();
                    }
                    catch (IOException ex)
                    {
                    }
                }
            }
        }
    }

    static void printNative(Context cx, String scriptname, ActionBlockEmitter emitter, byte[] bytes)
    {
        if (status(cx) == 0)
        {
        	//emitter.dumpCpoolVars();
            String str = emitter.header_str();
			int count = bytes.length;
            PrintWriter out = null;
            try
            {
                out = new PrintWriter(new FileWriter(new File(cx.path(), scriptname + ".h")));
                out.write(str);
                out.println("extern const int "+scriptname+"_abc_length;");
                out.println("extern const int "+scriptname+"_abc_method_count;");
                out.println("extern const int "+scriptname+"_abc_class_count;");
                out.println("extern const int "+scriptname+"_abc_script_count;");
                out.println("extern const unsigned char "+scriptname+"_abc_data[];");
            }
            catch (IOException ex)
            {
                ex.printStackTrace();
            }
            finally
            {
                if (out != null)
                {
					out.close();
                }
            }
			
			out = null;
            try
            {
                out = new PrintWriter(new FileWriter(new File(cx.path(), scriptname + ".cpp")));
                out.println("const int "+scriptname+"_abc_length = "+count+";");
                out.println("const int "+scriptname+"_abc_method_count = " + (emitter.native_method_count) + ";");
                out.println("const int "+scriptname+"_abc_class_count = " + (emitter.native_class_count) + ";");
                out.println("const int "+scriptname+"_abc_script_count = " + (emitter.native_package_count) + ";");
                out.println("const unsigned char "+scriptname+"_abc_data["+count+"] = {");
				
                for (int i=0; i < count; i++)
                {
                    int b = 0xFF&bytes[i];
                    out.print("0x");
                    if (b < 16)
                        out.print('0');
                    out.print(Integer.toHexString(b));
                    if (i+1 < count)
                        out.print(',');
                    if ((i+1)%16 == 0)
                        out.println();
                    else
                        out.print(' ');
                }
				
                out.println("};");
            }
            catch (IOException ex)
            {
                ex.printStackTrace();
            }
            finally
            {
                if (out != null)
                {
                    out.close();
                }
            }
			
        }
    }

	static int status(Context cx)
	{
		return cx.errorCount();
	}

	static void fini()
	{
		--ref_count;
		if (ref_count == 0)
		{
			ObjectValue.clear();
			TypeValue.clear();
		}
	}

    static void printParseTrees(String scriptname, Node node, Context cx, String ext)
    {
        if (status(cx) == 0)
        {
            PrintWriter out;
            try
            {
                out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(cx.path(), scriptname + ext)), "UTF-8")), true);
            }
            catch (IOException ex)
            {
                out = new PrintWriter(System.out, true);
            }
            NodePrinter printer = new NodePrinter(out);
            node.evaluate(cx, printer);
            out.flush();
            out.close();
        }
    }
    
	static void DetectFileImports(InputStream script,
			String scriptname,
			String filename,
			String classpath,
			CompilerHandler handler)
	{
		// InheritanceEvaluator needs to be ported to Java in
		// order for this to work.
		/*
	    ContextStatics statics = new ContextStatics();
	    statics.handler = handler;
	    
	    Context context = new Context(statics);
	    context.setPath(classpath);
	    context.setScriptName(scriptname);
	    context.setHandler(handler);

	    Parser parser = new Parser(context, script, filename);

	    ProgramNode node = parser.parseProgram();

	    ObjectList<String> deps;

	    InheritanceEvaluator inheritEval = new InheritanceEvaluator(deps);
	    inheritEval.evaluate(context, node);

	    int numDeps = deps.size();
	    for(int i = 0; i < numDeps; i++) {
		handler.importFile(deps.get(i));
	    }

	    statics.clear();
	    */
	}

	/*
	 * jkamerer ported from c++ start
	 */

	/*
	static ProgramNode parseAbcBuffer(Context cx, BytecodeBuffer buf)
	{
		if (buf == null) {
				return null;
		} else {
				AbcParser p = new AbcParser(cx, buf);
				return p.parseAbc();
		}
	}
	*/

	static ProgramNode parseAbcFile(Context cx, String fixed_filespec)
		throws java.io.IOException
	{
		AbcParser p = new AbcParser(cx, fixed_filespec);
		return p.parseAbc();
	}

}
