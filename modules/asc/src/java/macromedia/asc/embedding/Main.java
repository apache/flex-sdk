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

package macromedia.asc.embedding;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;

import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.ObjectList;
import static macromedia.asc.util.Version.*;
import static macromedia.asc.embedding.avmplus.Features.*;

/**
 * @author Jeff Dyer
 */
public class Main
{
	static boolean show_parsetrees = false;
	static boolean show_instructions = false;
	static boolean show_linenums = false;
	static boolean show_bytes = false;
	static boolean show_machinecode = false;
	static boolean show_flow = false;
	static boolean emit_debug_info = false;
	static boolean emit_doc_info = false;
	static boolean do_test = false;
	static boolean do_help = false;
	static boolean filespecFound = false; // only default param
	static boolean make_movieclip = false;
	static boolean lint_mode = false;
	static boolean use_static_semantics = false;
	static boolean sanity_mode = false;

	static boolean emit_metadata = false;
	static boolean log = false;
	static PrintStream stderr = System.err;

	static int earliest_dialect = 7;
	static int latest_dialect = 11;
	static int default_dialect = 9;
    static int default_target = TARGET_AVM2;  // Default to FP10
    static int dialect = default_dialect;
    static int target = default_target;
	static int api_version = -1;

    static boolean optimize = false;

	static ObjectList<String> include_filespecs = new ObjectList<String>();
	static ObjectList<String> import_filespecs = new ObjectList<String>();
	static ObjectList<String> use_namespaces;
	
	static String swf_options = "";
	static String language = "EN";
	static String avmplus_exe = null;

    static ObjectList<ConfigVar> config_vars = new ObjectList<ConfigVar>();
    static ObjectList<ConfigVar> optimizer_configs = null;

	public static void main(String[] args) throws Exception
	{
		String filename = "";
		String ext = "";

		if (args.length == 0)
		{
			do_help = true;
		}
		else
		{
			for (int i = 0; i < args.length; ++i)
			{
				String flag = args[i];
				if (flag.charAt(0) == '-')
				{
                    if( flag.length() < 2 )
                    {
                        do_help = true;
                        continue;
                    }
                    switch (flag.charAt(1))
					{
					case '!':
						use_static_semantics = true;
						break;
					case 'b':
						show_bytes = true;
						break;
					case 'f':
						show_flow = true;
						break;
					case 'p':
						show_parsetrees = true;
						break;
					case 'i':
						if (flag.length() == 3 && flag.charAt(2) == 'n') // -in
																			// <filespec>
						{
							++i;
							include_filespecs.add(args[i]);
						}
						else if (flag.length() == 7 && "-import".equals(flag)) // -import
																				// <filespec>
						{
							++i;
							import_filespecs.add(args[i].trim());
						}
						else
						{
							show_instructions = true;
						}
						break;
					case 'm':
						if (flag.length() == 10 && "-movieclip".equals(flag))
						{
							make_movieclip = true;
						}
						else if (flag.length() == 3 && "-md".equals(flag))
						{
							emit_metadata = true;
						}
						else
						{
							show_instructions = true; // -m implies -i
							show_machinecode = true;
						}
						break;

					case 'a':
						if (flag.length() == 10 && "-abcfuture".equals(flag))
						{
							FUTURE_ABC = true;
						}
                        else if ( flag.length() == 10 && "-avmtarget".equals(flag))
                        {
                            ++i;
                            try
                            {
                                String vm_target = args[i].trim();
                                int v = Integer.parseInt(vm_target);
                                switch(v) {
                                case 1:
                                    target = TARGET_AVM1;
                                    break;
                                case 2:
                                    target = TARGET_AVM2;
                                    break;
                                default:
                                    do_help = true;
                                    break;
                                }
                            }
                            catch(Exception e)
                            {
                                do_help = true;
                            }
                        }
						break;

					case 'c':
						if (flag.length() == 6 && "-coach".equals(flag))
						{
							lint_mode = true;
						}
                        else if( flag.length() == 7 && "-config".equals(flag))
                        {
                            ++i;
                            String temp = args[i];
                            ConfigVar cv = parseConfigVar(temp);
                            if( cv != null)
                                config_vars.push_back(cv);
                            else
                                do_help = true;
                        }
						break;

					case 'w':
						if (flag.length() == 9 && "-warnings".equals(flag))
						{
							lint_mode = true;
						}
						break;

					case 's':
						if (flag.length() == 7)
						{
							if ("-strict".equals(flag))
							{
								use_static_semantics = true;
							}
							else if ("-sanity".equals(flag))
							{
								sanity_mode = true;
							}
						}
						else if (flag.length() == 4 && "-swf".equals(flag))
						{
							++i;
							swf_options = args[i];
							if (swf_options.indexOf("-g") > -1) // -g means make it a debuggable swf
								emit_debug_info = true;
						}
						break;

					case 'e':
						if (flag.length() == 4)
						{
							if ("-exe".equals(flag))
							{
								++i;
								avmplus_exe = args[i];
							}
						}
						break;

					case 'd':
						if (flag.length() == 4 && "-doc".equals(flag))
						{
							emit_doc_info = true;
						}
						else
						{
							emit_debug_info = true;
						}
						break;
					case 'l':
						if (flag.length() == 4 && "-log".equals(flag))
						{
							log = true;
						}
						else if (flag.length() == 9 && "-language".equals(flag))
						{
							i++;
							language = args[i];
						}
						else
						{
							show_linenums = true;
						}
						break;
					case 't':
						do_test = true;
						break;
					case 'h':
						do_help = true;
						break;
                    case 'o':
                    	if ( "-O".equalsIgnoreCase(flag))
                    	{
                    		optimize = true;
                    	}
                    	else if (flag.substring(0, 3).equalsIgnoreCase("-O2") )
                    	{
                    		if ( null == optimizer_configs)
                    		{
                    			optimizer_configs = new ObjectList<ConfigVar>();
                    		}
                    		
                    		if ( flag.length() > 4)
                    		{
                    			String option_name = flag.substring(4);
                    			String option_value = "";
                    			
                    			int eq_pos = option_name.indexOf('=');
                    			
                    			if ( eq_pos != -1 )
                    			{
                    				option_value = option_name.substring(eq_pos+1);  //  Skip the "=" char
                    				option_name  = option_name.substring(0, eq_pos);
                    			}
                    		
	                    		optimizer_configs.add(new ConfigVar("o2", option_name, option_value));
                    		}
                    	}
                        break;
                    case 'A':
                    	if (flag.length() == 4 && "-AS3".equalsIgnoreCase(flag))
                    	{
                    		dialect = 10;
                    	}
                    	break;
                    case 'E':
                    	if (flag.length() == 3 && "-ES".equalsIgnoreCase(flag))
                    	{
                    		dialect = 9;
                    	}
                    	else if (flag.length() == 4 && "-ES4".equalsIgnoreCase(flag))
                    	{
                    		dialect = 11;
                    	}
                    	break;
                    case 'u':
						if (flag.length() == 4 && "-use".equals(flag)) // -use <namespace>
						{
							++i;
                            if (use_namespaces == null)
                                use_namespaces = new ObjectList<String>();
                            use_namespaces.add(args[i].trim());
						}
						break;
						
					default:
						try
						{
							if (flag.length() > 1
									&& (dialect = -1 * Integer.parseInt(flag)) != 0)
							{
								if (dialect < earliest_dialect
										|| dialect > latest_dialect)
								{
									do_help = true;
								}
								// otherwise, we have a valid dialect number
							}
						}
						catch (NumberFormatException nfe)
						{
							do_help = true;
						}
						break;
					}
				}

				// assume it's a filename
				else
				{
					filename = new String(args[i].trim());
					if (filename.endsWith(".as"))
					{
						ext = ".as";
					}
					else if (filename.endsWith(".es"))
					{
						ext = ".es";
					}
					else if (filename.endsWith(".js"))
					{
						ext = ".js";
					}
					else
					{
						ext = "";
					}
					filespecFound = true;
					handleFile(filename, ext);
				}
			}
		}

		if (!(do_help || filespecFound))
		{
            Context cx = new Context(new ContextStatics());

			System.err.println(cx.errorString(ErrorConstants.kError_MissingFilespec));
			System.exit(1);
		}
		else if (do_help)
		{
			handleFile("","");
		}
	}

	private static void handleFile(String filename, String ext) throws IOException, FileNotFoundException, Exception
	{
		String scriptname;

		if (do_help)
		{
			System.out.println("ActionScript 3.0 for AVM+");
			System.out.println("version " + ASC_VERSION_USER + " build "+ ASC_BUILD_CODE);
			System.out.println("Copyright 2012 The Apache Software Foundation");
			System.out.println("All rights reserved\n");
			System.out.println("Usage:");
			System.out.println("  asc {-AS3|-ES|-d|-f|-h|-i|-import <filename>|-in <filename>|-m|-p}* filespec");
			System.out.println("  -AS3 = use the AS3 class based object model for greater performance and better error reporting");
			System.out.println("  -ES = use the ECMAScript edition 3 prototype based object model to allow dynamic overriding of prototype properties");
			System.out.println("  -d = emit debug info into the bytecode");
			System.out.println("  -f = print the flow graph to standard out");
			System.out.println("  -h = print this message");
			System.out.println("  -i = write intermediate code to the .il file");
			System.out.println("  -import <filename> = make the packages in the");
			System.out.println("       specified file available for import");
			System.out.println("  -in <filename> = include the specified filename");
			System.out.println("       (multiple -in arguments allowed)");
			System.out.println("  -m = write the avm+ assembly code to the .il file");
			System.out.println("  -p = write parse tree to the .p file");
			System.out.println("  -md = emit metadata information into the bytecode");
			System.out.println("  -warnings = warn on common actionscript mistakes");
			System.out.println("  -strict = treat undeclared variable and method access as errors");
			System.out.println("  -sanity = system-independent error/warning output -- appropriate for sanity testing");
			System.out.println("  -log = redirect all error output to a logfile");
			System.out.println("  -exe <avmplus path> = emit an EXE file (projector)");
			System.out.println("  -swf classname,width,height[,fps] = emit a SWF file");
			System.out.println("  -language = set the language for output strings {EN|FR|DE|IT|ES|JP|KR|CN|TW}");
            System.out.println("  -optimize = produced an optimized abc file");
            System.out.println("  -config ns::name=value = define a configuration value in the namespace ns");
            System.out.println("  -use <namespace> = automatically use a namespace when compiling this code");
            System.out.println("  -avmtarget <vm version number> = emit bytecode for a specific VM version, 1 is AVM1, 2 is AVM2, etc");
            System.out.println("");
			System.exit(1);
		}

		if (do_test)
		{

			if (false) // DEFINE_TEST_DRIVERS
			{
				// InputBuffer::main(argc,argv);
				// InputBuffer::test_getLineText();
				// InputBuffer::test_markandcopy();
				// InputBuffer.test_retract();
				// InputBuffer::test_nextchar();

				// Token::main(argc,argv);
				// Scanner::main(argc,argv);

				// NodeFactory::main(argc,argv);
				// Parser::main(argc,argv);
				// ConstantEvaluator::main(argc,argv);
				// ObjectValue::main(argc,argv);
				// CodeGenerator::main(argc,argv);
			} // DEFINE_TEST_DRIVER
		}
		else
		{
			File f = new File(filename.trim());
			if (!f.exists())
			{
                Context cx = new Context(new ContextStatics());
				StringBuilder error_msg = new StringBuilder();
				Context.replaceStringArg(error_msg, cx
						.errorString(ErrorConstants.kError_UnableToOpenFile),
						0, filename);
				System.err.println(error_msg.toString());
				return;
			}

			String pathspec;
            try
            {
            	pathspec = new File(f.getCanonicalPath()).getParent();
            }
            catch (IOException ex)
            {
            	pathspec = new File(f.getAbsolutePath()).getParent();
            }
			scriptname = f.getName().substring(0,
					f.getName().length() - ext.length());

			BufferedInputStream in = new BufferedInputStream(
					new FileInputStream(f));

			// Compiler.doCompile(in, pathspec, scriptname, filename,
			// include_filespec,
			// import_filespec, errorname, null, show_instructions,
			// show_machinecode, show_linenums,
			// show_parsetrees, show_bytes, show_flow, emit_debug_info);

			CompilerPlug plug = new CompilerPlug();

			plug.in = in;
			plug.pathspec = pathspec;
			plug.filename = f.getPath();
			; // TODO errorname
			plug.scriptname = scriptname;
			plug.emit_debug_info = emit_debug_info;
			plug.emit_doc_info = emit_doc_info;
			plug.make_movieclip = make_movieclip;
			plug.import_filespecs = import_filespecs;
			plug.use_namespaces = use_namespaces;
			plug.lint_mode = lint_mode;
			plug.use_static_semantics = use_static_semantics;
			plug.emit_metadata = emit_metadata;
			plug.swf_options = swf_options;
			plug.avmplus_exe = avmplus_exe;
            plug.language = language;
            plug.dialect = dialect;
            plug.target = target;
            plug.optimize = optimize;
            plug.optimizer_configs = optimizer_configs;
            plug.configs = config_vars;
			plug.api_version = api_version;

			if(sanity_mode)
			{
				ContextStatics.useSanityStyleErrors = true;
				plug.handler = new SanityCompilerHandler();
			}

			if (log)
			{
				String logfile = filename.substring(0, filename.length()
						- ext.length())
						+ ".log";
				System.setErr(stderr);
				System.err.println("Logging to " + logfile);
				System.setErr(new PrintStream(new FileOutputStream(new File(logfile))));
			}

			if (include_filespecs.size() > 0)
			{
				plug.includes = new ObjectList<IncludeInfo>();
				for (int n = 0; n < include_filespecs.size(); ++n)
				{
					String filespec = include_filespecs.get(n);
					f = new File(filespec);
					if (!f.exists())
					{
						System.err.println("File not found");
						return;
					}

					filespec = f.getPath();
					pathspec = new File(f.getCanonicalPath()).getParent();
					filename = f.getAbsolutePath();
					scriptname = f.getName().substring(0,
							f.getName().length() - ext.length());
					in = new BufferedInputStream(new FileInputStream(f));

					IncludeInfo iinfo = new IncludeInfo();
					iinfo.script = in;

					if (make_movieclip)
					{
						iinfo.name = "frame" + n;
					}
					else
					{
						iinfo.name = filespec;
					}

					plug.includes.push_back(iinfo);
				}
			}

			ObjectList<CompilerPlug> plugs = new ObjectList<CompilerPlug>();

			Compiler.doCompile(plug, plugs, show_instructions,
					show_machinecode, show_linenums, show_parsetrees,
					show_bytes, show_flow);

			// delete all the input file streams
		}
	}

    public static ConfigVar parseConfigVar(String s)
    {
        ConfigVar cv = null;

        if( s != null )
        {
            int ns_end = s.indexOf("::");
            if( ns_end != -1 )
            {
                String ns = s.substring(0,ns_end);
                int eq_pos = s.indexOf("=", ns_end);
                if( eq_pos != -1 )
                {
                    String name = s.substring(ns_end+2, eq_pos);
                    String value = s.substring(eq_pos+1, s.length());
                    cv = new ConfigVar(ns, name, value);
                }
            }
        }

        return cv;
    }
}
