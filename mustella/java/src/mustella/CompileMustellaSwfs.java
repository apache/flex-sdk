/*
 *
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
 *
 */
package mustella; 
import utils.*;
import utils.FileUtils;
import utils.ArgumentParser;

import java.io.File;
import java.util.regex.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.util.*;

/**
 * User: bolaghlin, derived from a dschaffer piece
 * Date: Sep 21 2006 / Threaded 5/22/07
 */
public class CompileMustellaSwfs extends Thread {

    /* 
     * distributed related vars here
     */
    public static boolean distributed = false;

    /* 
     * pmd vars 
     */
    public static boolean pmd = false;

    public static String compile_dir = null;

    public static int compile_id= -1;

    public static int directory_result = 0;

    public static int hostId = 0;

    private ArrayList defaultArgs;

	private static String mobileConfigArg = null;
	
	private static String exclude_filename = null;
    
	private static String run_this_script = null;

    private static String include_list = null;

    private static boolean use_include_file = false;

    private static boolean debugDump = false;

    private static boolean skip_exclude = false;

    private static boolean fork_compile = true;

    private static boolean use_browser = false;

    private static boolean save_failures = false;

    private static boolean exit_on_compile_error = false;

    private static String socket_mixin = "";

    private static String mustella_dir = null;

    private static HashMap swfs = new HashMap();
    private static HashMap extraArgs = new HashMap();

    public static int run_id = -1;

    public static int exit_with = 0;

    private static ArrayList survivors = new ArrayList();

    private static boolean use_apollo = false;

    private static boolean apollo_transform = false;

    private static String apollo_transform_template = "air_transform/template.mxml";

    private static String apollo_transform_prefix = "zzaird_";

    private static String apollo_transform_prefix2 = "wwaird_";
	
	private static boolean use_mustella_framework_dir = false;

    private static String mustella_framework_dir = null;

    private static String apollo_location = ""; 

    private static String file_of_tests = "";

    private static String user_args = "";

    public static double flex_version = 0.0;

    public static int build_version = 0;


    public static String height = "375";
    public static String width = "500";



    /// some mixins we may be using:
    public static final String resultCollectorMixinName = "SendResultsToRunner";
    public static String excludeListMixinName = "ExcludeFileLocation";
    public static final String includeListMixinName = "CurrentIncludeList";


    public static String htmlDir = "/templates/client-side-detection-with-history/"; 
    private static String resultInclude =" -includes=SendFormattedResultsToLog";
    private static String exitInclude = " -includes=ExitWhenDone"; 
    public static int allowedCount = 1; 
	
	private static boolean run_mobile_tests = false;
	private static String device_name = "";
	private static String target_os_name = "";
	private static String os_version = "";
	
    static { 
		
		//===================================================
		// Mobile settings
		//===================================================
		try { 
			exclude_filename = System.getProperty ("exclude_filename");
		} catch (Exception e) { 
			System.out.println("Didn't get an exclude_filename.");
		} finally{
			System.out.println ("exclude_filename: " + exclude_filename);
		}

		try { 
			os_version = System.getProperty ("os_version");
		} catch (Exception e) { 
			System.out.println("Didn't get an os_version.");
		} finally{
			System.out.println ("os_version: " + os_version);
		}
		
		try { 
			target_os_name = System.getProperty ("target_os_name");
		} catch (Exception e) { 
			System.out.println("Didn't get a target_os_name.");
		} finally{
			System.out.println ("target_os_name: " + target_os_name);
		}

		try { 
			device_name = System.getProperty ("device_name");
		} catch (Exception e) { 
			System.out.println("Didn't get a device_name.");
		} finally{
			System.out.println ("device_name: " + device_name);
		}
		
		try { 
			run_mobile_tests = new Boolean (System.getProperty ("run_mobile_tests")).booleanValue();
		} catch (Exception e) { 
			System.out.println("Didn't get run_mobile_tests.");
			run_mobile_tests = false;
		}
		//===================================================
		
		try { 
			use_apollo = new Boolean (System.getProperty ("use_apollo")).booleanValue();
			// System.out.println ("use_apollo: " + use_apollo);
		} catch (Exception e) { 
		}

		try { 
			apollo_transform = new Boolean (System.getProperty ("apollo_transform")).booleanValue();
			// System.out.println ("apollo_transform: " + apollo_transform);
		} catch (Exception e) { 
		}

		// pmd distributed:
		try { 
			pmd = new Boolean (System.getProperty ("pmd")).booleanValue();
		} catch (Exception e) { 
			pmd=false;
		}

		// distributed:
		try { 
			distributed = new Boolean (System.getProperty ("distributed")).booleanValue();
		} catch (Exception e) { 
			distributed=false;
		}


		// distributed:
		try { 
			compile_dir = System.getProperty ("compile_dir");
		} catch (Exception e) { 
		}

		// distributed:
		try { 
			compile_id = Integer.parseInt (System.getProperty ("compile_id"));
		} catch (Exception e) { 
		}

		try { 
			hostId = Integer.parseInt (System.getProperty ("hostId"));
		} catch (Exception e) { 
			hostId=1;
		}


		try { 
			apollo_transform_template = System.getProperty ("apollo_transform_template");
			// System.out.println ("apollo_transform_template: " + apollo_transform_template);
		} catch (Exception e) { 
		}

		try { 
			apollo_transform_prefix = System.getProperty ("apollo_transform_prefix");
			// System.out.println ("apollo_transform_prefix: " + apollo_transform_prefix);
		} catch (Exception e) { 
		}

		try { 
			apollo_transform_prefix2 = System.getProperty ("apollo_transform_prefix2");
			/// System.out.println ("apollo_transform_prefix2: " + apollo_transform_prefix2);
		} catch (Exception e) { 
		}

		try { 
			use_browser = new Boolean (System.getProperty ("use_browser")).booleanValue();
			// System.out.println ("use_browser raw: " + System.getProperty("use_browser"));
			// System.out.println ("use_browser: " + use_browser);


		} catch (Exception e) { 
		}

		try { 
			fork_compile = new Boolean (System.getProperty ("fork_compile")).booleanValue();
			// System.out.println ("fork_compile: " + fork_compile);
		} catch (Exception e) { 
		}


		try { 
			apollo_location = System.getProperty ("apollo_location");
			// System.out.println ("apollo: " + apollo_location);
		} catch (Exception e) { 
		}

		// result_include is set in build.xml, then it gets overridden depending on if it's a local
		// or server run.
		try {
			if (System.getProperty ("result_include") != null && !System.getProperty ("result_include").startsWith ("${")) { 
				resultInclude = System.getProperty ("result_include");
			} else {
				resultInclude =" -includes=SendFormattedResultsToLog";
			}
		} catch (Exception e) {
			e.printStackTrace();
			resultInclude =" -includes=SendFormattedResultsToLog";          
		}
		System.out.println ("result_include: " + resultInclude);

		try { 
			exitInclude = System.getProperty ("exit_include");
			if (exitInclude != null && exitInclude.equals (""))
				exitInclude = " -includes=ExitWhenDone"; 
		} catch (Exception e) { 
			exitInclude = " -includes=ExitWhenDone";
		}

		try { 
			if (System.getProperty ("htmlDir")!=null && !System.getProperty ("htmlDir").equals("")) 
				htmlDir = System.getProperty ("htmlDir");
			// System.out.println ("htmlDir: " + htmlDir);
		} catch (Exception e) { 
		}

		try { 
			save_failures = new Boolean (System.getProperty ("save_failures")).booleanValue();
			// System.out.println ("save_failures: " + save_failures);
		} catch (Exception e) { 
		}


		try { 
			skip_exclude = new Boolean (System.getProperty ("skip_exclude")).booleanValue();
		} catch (Exception e) { 
		}

		try { 
			excludeListMixinName = System.getProperty ("exclude_mixin");
		} catch (Exception e) { 
		}

		try { 
			mustella_dir = System.getProperty ("mustella.dir");
		} catch (Exception e) { 
		}

		try { 
			flex_version = Double.parseDouble(System.getProperty ("flex_version"));
		} catch (Exception e) { 
		}

		try { 
			build_version = Integer.parseInt (System.getProperty ("build_version"));
		} catch (Exception e) { 
		}

		try { 
				
			if (System.getProperty ("user_args")!=null) { 
				user_args += System.getProperty ("user_args");
				// System.out.println ("saw a user arg: " + user_args);
			}
		} catch (Exception e) { 
		}

		try { 

			allowedCount = Runtime.getRuntime().availableProcessors();
			
		} catch (Exception e) { 
		}


		if (System.getProperty ("exit_on_compile_error")!=null) { 
			try { 
			exit_on_compile_error = new Boolean (System.getProperty ("exit_on_compile_error")).booleanValue();
			// System.out.println ("exit_on_compile_error: " + exit_on_compile_error);
			} catch (Exception e) { 
				
				exit_on_compile_error = false;
			}
		}

		if (System.getProperty ("use_mustella_framework_dir")!=null && !System.getProperty ("use_mustella_framework_dir").equals ("") ) { 

			try { 
				use_mustella_framework_dir = new Boolean (System.getProperty ("use_mustella_framework_dir")).booleanValue();

			} catch (Exception e) {
			}

		}

		if (System.getProperty ("include_list")!=null && !System.getProperty ("include_list").equals ("") ) { 

			try { 
				include_list = System.getProperty ("include_list");

			} catch (Exception e) {
			}

		}

		if (System.getProperty ("use_include_file")!=null && !System.getProperty ("use_include_file").equals ("") ) { 
			try { 
				use_include_file = new Boolean (System.getProperty ("use_include_file")).booleanValue();

			} catch (Exception e) {
			}

		}


		if (System.getProperty ("mustella_framework_dir")!=null && !System.getProperty ("mustella_framework_dir").equals ("") ) { 

			try { 
				mustella_framework_dir = System.getProperty ("mustella_framework_dir");

			} catch (Exception e) {
			}

		}


		if (System.getProperty ("socket_mixin")!=null) { 
			socket_mixin = System.getProperty ("socket_mixin");
			if (socket_mixin != null && !socket_mixin.equals (""))
				socket_mixin = " -includes=" + socket_mixin;
		}

		if (System.getProperty ("run_id")!=null) { 
			try { 
				run_id = Integer.parseInt (System.getProperty ("run_id"));
				// System.out.println ("compile mustella swfs, have this run id: " + run_id);
			} catch (Exception e) { 
				run_id = -1;
			}
		}


		if (System.getProperty ("run_this_script")!=null) { 
			try { 
			run_this_script = System.getProperty ("run_this_script");
			// System.out.println ("run script: " + run_this_script);
			if (run_this_script.equals (""))
				run_this_script = null;
			} catch (Exception e) { 
				run_this_script = null;
			}
		}


    }// end static init block

    public static String[] readIntoArray() {

	BufferedReader br = null;

	ArrayList al = new ArrayList();

	String tmp = null;

	String [] ret = null;

	try { 

		br = new BufferedReader (new FileReader(file_of_tests));

		while ( (tmp = br.readLine()) != null) {
			al.add (tmp);
		}

		br.close();
		ret = new String[al.size()];

		ret = (String[]) al.toArray((String[])ret);

		return ret;

	} catch (Exception e) {
		e.printStackTrace();
		
	}

	return (String[])null;
    }

    public static ArrayList threads = new ArrayList();


    public static synchronized void removeFromList (Object o) { 
	// System.out.println ("call to remove " + o );
	threads.remove (o);
	// System.out.println ("post thread look: " + threads);
    }



    static long compile_start=0;
    static long compile_end=0;
    

    public static void main(String args[]) {

		///  This isn't necessarily an error anymore. allow it
		if (args.length == 0) {
			System.out.println("CompileTestSwfs no mxml files to compile.");
			System.exit(0);
		}

		file_of_tests = args[0];

		/// just debugging:
		// System.out.println("args to compile: " + args[0]);

		String basedir = System.getProperty("basedir", ".");
		/* AJH
		InsertMilestone im1 = null;
		DistributedMilestone dins1 = null;
		
		if (!distributed)
			im1 = new InsertMilestone (run_id, "compile_start", System.currentTimeMillis());
		else
			dins1 = new DistributedMilestone (0, compile_id, compile_dir, -1, System.currentTimeMillis(),hostId);
		*/
		
		compile_start = System.currentTimeMillis();

		args = readIntoArray();

		for (int i = 0; i < args.length; i++) {
			if (new File(mustella_dir + "/" + "testing.halt").exists()) {
				System.out.println("SAW HALT NOTIFICATION, halting compile at " + new Date());
				break;
			}

			/// generate mustella args  ADD survivor check into the extraArg creation check
			if (args[i].endsWith (".mxml")) { 
				MustellaDirs.genHashMap (args[i], extraArgs, swfs, run_this_script);
			}
		}

		// Write a mobile config class to mustella/tests/mobile.
		// Note: this seems to be assuming use_mustella_framework_dir is true.
		if( run_mobile_tests ){			
			mobileConfigArg = " -includes=" + MobileConfigWriter.write( device_name, target_os_name, os_version, mustella_framework_dir, run_id, exclude_filename );
		}
		
		// System.out.println ("the hash: " + swfs);

		/// mustella args iteration
		Iterator it = extraArgs.entrySet().iterator();

		String swfName = null;
		String swfFile = null;
		ArrayList al = null;

		Map.Entry mes = null;

		long begin0=0,end0=0;

		// InsertErrorResult ier = null;

		while (true) { 
			if (new File(mustella_dir + "/" + "testing.halt").exists()) {
				System.out.println("SAW HALT NOTIFICATION, halting compile at " + new Date());
               	break;
	       	}
			
			if (threads.size() < allowedCount) {
				//  System.out.println ("size vs. allowed: " + threads.size() + " " + allowedCount + " spawning another compile thread");
				if (it.hasNext()) { 
					mes = (Map.Entry) it.next();

					swfName = (String) mes.getKey();
					// swfFile = (String) swfs.get (swfName);
					swfFile = swfName;
					al = (ArrayList)((ArrayList) extraArgs.get (swfName)).clone();

					if (swfFile != null)  { 
						// retryCount=0;
					
						CompileMustellaSwfs tc = new CompileMustellaSwfs(swfFile, al);	
						threads.add (tc);
						tc.start();
					}  else { 
		
						System.out.println ("COMPILE: busted for " + swfFile + " " + swfName + " references: " + al);

						handleCompileError (swfName, al.toString(),   "a testSWF Reference points to a swf that could not be found." );
					}
				} else  { 
					System.out.println ("nothing left to do");
					break;
				}
			} else { 
				try { 
					Thread.sleep (200);
				} catch (Exception e0) { 
					e0.printStackTrace();
				}			
			}
		}

		/* 

		while (threads.size() > 0) { 
			try { 
			Thread.sleep (1000);
			// System.out.println ("Waiting for threads to finish: active "  + threads.size());
			} catch (Exception e0) { 
				e0.printStackTrace();
			}
		}
		*/

		/// experiment, rather than waiting forever
		if (threads.size() > 0) {

			Thread t = null;

			 for (int i=0;i<threads.size();i++) { 
				try { 
					t = (Thread) threads.get(i);
					t.join (360000); // six minutes to finish a compile before we give up

				} catch (Exception ee) {
					ee.printStackTrace();
				}
			}
		}

		System.out.println ("All done with the compile");

		if (debugDump) { 
			try { Thread.sleep (4500); } catch (Exception e) { }
		}


		/* AJH
		DistributedMilestone dins2 = null;
		InsertMilestone im2 = null;
		if (!distributed)
			im2 = new InsertMilestone (run_id, "compile_end", System.currentTimeMillis());
		else
			dins2 = new DistributedMilestone (0, compile_id, compile_dir, directory_result, System.currentTimeMillis(), hostId);
		*/
		
		compile_end = System.currentTimeMillis();

		/* AJH
		try { 
			if (dins2 != null) { 
				dins2.join (4000);	
			} else if (im2 != null) {
				im2.join (4000);
			}

		} catch (Exception ee) {
			ee.printStackTrace();
		}
		*/

		System.out.println ("leaving the compile, elapsed: " + ((compile_end-compile_start)/1000));
		if (fork_compile) { 
			System.out.println ("...via exit");
			System.exit (exit_with);
		}
    }


    String swf_name = null;
    ArrayList arg_list = null;

    public CompileMustellaSwfs (String swf, ArrayList args)  {

		// System.out.println ("Compile constructor for " + swf);
		this.swf_name = swf;
		this.arg_list = args;
    }

    public void run () { 

		// System.out.println ("Calling run on Compile for " + this + " at: " + new Date() + " for: " + swf_name);

		//// what if we cleaned the args HERE
		//// 
		ArrayList al = new ArrayList();
		String tmp = null;
		String tmp_fixed = null;

		for (int i=0;i<arg_list.size();i++) { 
			tmp = (String) arg_list.get (i);

			if ( tmp.trim().startsWith ("-includes=") ) { 
				tmp_fixed = finalFixUp(tmp);
				// System.out.println ("Would replace " + tmp + " with + " + tmp_fixed);

				al.add (tmp_fixed);
			} else { 
				// System.out.println ("Leaving as is: " + tmp);
				al.add (tmp);
			}
		}

		compileMxml(swf_name, al);
    }


    public String finalFixUp (String s) {

	
	// 
	s = s.substring ("-includes=".length()+1);

	s = new File (s).getName();

	if (s.indexOf (".mxml") != -1)
		s = s.substring (0, s.indexOf (".mxml"));

	/// System.out.println ("This is the filename I've fixed: " + s);


	return "-includes=" +s;

    }


    public static void handleCompileError (String swfName, String args, String desc) { 

    	/* AJH
		if (run_id != -1)  { 
			System.out.println ("(handleCompileError: inserting a compile error)"); 
			InsertErrorResult ier = new InsertErrorResult (run_id, swfName, args, desc);
			threads.add (ier);
			System.out.println ("(started the insert error)");
			try { Thread.sleep (1250); } catch (Exception e)  {} 

		} else if (distributed && compile_id != -1) {
			System.out.println ("(handleCompileError: inserting a compile error)"); 
			InsertErrorResult ier = new InsertErrorResult (compile_id, swfName, args, desc);
			threads.add (ier);
			System.out.println ("(started the insert error)");
			try { Thread.sleep (1250); } catch (Exception e)  {} 

		} */
		if (exit_on_compile_error)  { 
       			System.out.println("Compile Error detected. Flag set to exit. bye");
			System.exit (1);
		} else { 
			exit_with = 1;
		}

    }

    public void compileMxml(String mxml, ArrayList ermineArgs) {

	/**
	 * assemble compile flags
	 */
        String dir = FileUtils.normalizeDir(mxml);
        dir = dir.substring(0, dir.lastIndexOf("/"));
        boolean coachMode = false;
        if (System.getProperty("coach") != null && System.getProperty("coach").equals("true")) {
            coachMode = true;
        }

	/// incremental
        boolean incremental="true".equals(System.getProperty("incremental"));

	/// additional as path
        String asclasspath=System.getProperty("asclasspath");

	/// additional frameworks
        String frameworks=System.getProperty("frameworks",".");

	///?
        if (frameworks.endsWith("/")==false) frameworks+="/";

        String basedir=System.getProperty("basedir");

	// var to apply them
        String args="";

	/// we need to get in this guy's brain
        // Obsolete String librarypath=System.getProperty("librarypath",frameworks+"/libs/framework.swc");
        String librarypath="";

	///  add excludes to the lib path if present:
        if (System.getProperty("excludelibrarypath") != null && !System.getProperty("excludelibrarypath").equals("")) { 
        	System.out.println ("Sent to me as excludelibrarypath: " + System.getProperty("excludelibrarypath"));
        	librarypath+= System.getProperty("excludelibrarypath");

		/// if we're excluding, add the ExcludeList mixin
	} else if  (System.getProperty("exclude_source_path") != null && !System.getProperty("exclude_source_path").equals("")) { 
		/// if not present, and not skip exclude, add that path
		args+= " -source-path=" + System.getProperty("exclude_source_path");


	}

	// NOTE: Put this before the excludeListMixinName!
	if ( CompileMustellaSwfs.run_mobile_tests )
	{
		args += mobileConfigArg;
	}		
		
	if ( device_name.equalsIgnoreCase( "mac" ) ) {
		args += " -includes=DesktopMacSettings";
	}

	if ( device_name.equalsIgnoreCase( "win" ) ) {
		args += " -includes=DesktopWinSettings";
	}
		
	// NOTE: Put this after anything which sets something related to excludes,
	// such as AndroidSettings!
	if (!skip_exclude) { 
		args += " -includes=" + excludeListMixinName;

	}

	if (use_apollo) { 
		args += " -includes=ApolloFilePath";
	}

	if (use_include_file) { 
		args += " -includes=IncludeFileLocation";
	}

	if (user_args != null)
		args += " " +user_args;

        // if (run_this_script != null && include_list != null) { 

	String extract = null;

	/* 
        if (include_list_file != null && !include_list_file.equals("")) { 

		/// read the file by line, each line is a test_file test_case identifier
		try { 

		BufferedReader br = new BufferedReader(new FileReader(include_list_file));

        	// System.out.println ("noticed an include designation, adding it softly for " + mxml);

		String front = null;

		/// if we're excluding, add the ExcludeList mixin
		ArrayList alinc = new ArrayList();
		String tmp = null;
		for (int i=0;i<ermineArgs.size();i++) {
			tmp = (String)ermineArgs.get(i);
			if (tmp.indexOf ("-includes=")!= -1) { 
				extract = tmp.substring ("-includes=".length());
			} else if (tmp.indexOf ("-source-path=")!= -1) { 
				front = tmp.substring ("-source-path=".length());
			}
		}

		front = front.substring (front.indexOf("mustella" + File.separator + "tests")+15);
		front = front.replaceAll ("\\\\", "/") + "/";


		alinc.add ("\"" + transformName( front + extract, "") + "\": 1,");
		alinc.add ("\"" + transformName( front + extract, "") + "$" + include_list + "\": 1");
		String whereToWrite= System.getProperty("mustella.dir") + File.separator + "classes";
		// we thought it best to write these to a temp location
		GetExcIncCase.writeToFile (alinc, whereToWrite + File.separator + includeListMixinName + ".as", false);
		args += " -includes=" + includeListMixinName;
		args += " -source-path="+whereToWrite;
	}
	*/

	if (include_list != null && !include_list.equals("")) { 
		// System.out.println ("noticed an include designation, adding it softly for " + mxml);

		String front = null;

		/// if we're excluding, add the ExcludeList mixin
		ArrayList alinc = new ArrayList();
		String tmp = null;
		for (int i=0;i<ermineArgs.size();i++) {
			tmp = (String)ermineArgs.get(i);
			if (tmp.indexOf ("-includes=")!= -1) { 
				extract = tmp.substring ("-includes=".length());
			} else if (tmp.indexOf ("-source-path=")!= -1) { 
				front = tmp.substring ("-source-path=".length());
			}
		}

		front = front.substring (front.indexOf("mustella" + File.separator + "tests")+15);
		front = front.replaceAll ("\\\\", "/") + "/";

		alinc.add ("\"" + transformName( front + extract, "") + "\": 1,");
		alinc.add ("\"" + transformName( front + extract, "") + "$" + include_list + "\": 1");
		String whereToWrite= System.getProperty("mustella.dir") + File.separator + "classes";
		// we thought it best to write these to a temp location
		GetExcIncCase.writeToFile (alinc, whereToWrite + File.separator + includeListMixinName + ".as", false);
		args += " -includes=" + includeListMixinName;
		args += " -source-path="+whereToWrite;
	}


	/// if there's a mustella swc, use that.
	/// probably want to be able to TOGGLE THIS on the ant side  FIX 
	String mustellaswc = "";
	if (System.getProperty("mustellaswc") != null && !use_mustella_framework_dir) { 
		mustellaswc=System.getProperty("mustellaswc");
	
		if (mustellaswc.length() > 0)
			args+= " -library-path+="+mustellaswc;
	}

	if (use_apollo) {
		if (run_mobile_tests)
			args+=" +configname=airmobile";
		else
			args+=" +configname=air";		
	}

	if (save_failures) {
	   if (!distributed && !pmd) { 
		System.out.println ("Choosing local runner bitmap save");
		args+=" -includes=SaveBitmapFailures";
	   } else if (distributed || pmd) { 
		System.out.println ("Choosing the Dist server bitmap save");
		args+=" -includes=SaveBitmapFailuresDistServer";
	   }
	}

	/// adding
	if (librarypath != null && librarypath.length() > 0) { 

		args+=" -library-path+="+ librarypath;

	}

	String externallibrarypath=System.getProperty("external.librarypath",frameworks+"/libs/playerglobal.swc");

	if (librarypath.indexOf(".swc")==-1) {
		asclasspath+=","+frameworks;
	}
		
	boolean strict=System.getProperty("strict")!=null && System.getProperty("strict").equals("true");

	if (socket_mixin != null && !socket_mixin.equals("")) { 
		args+=socket_mixin;
	}

	/// add mustella args to the arg string
	// if somehow there are no ermine args, then there is no test to mixin; so no point in 
	// compiling it
	if (ermineArgs.size() == 0) { 
		System.out.println ("Skipping compile on " + mxml + " no mustella includes survived");
		removeFromList(this);
		return;
	}
		
	for (int i=0;i<ermineArgs.size();i++) { 
		args+=" "+ (String)ermineArgs.get(i);
	}

	args+=" --allow-source-path-overlap=true ";
	if (incremental)
		args+="--incremental=true ";
	if (coachMode==false)
		args+="--show-coach-warnings="+coachMode+" ";
	if (strict==false)
		args+="--strict="+strict+" ";

	/// if we're interactive, hang around; and send results correctly.
	if (args.indexOf ("SendResultsToSnifferClient") == -1) { 
		// System.out.println ("keeping resultInclude and exitInclude");
		args += " " + resultInclude;
		args += " " + exitInclude;
	} 

	String [] pieces = asclasspath.split (",");
	for (int i=0;i<pieces.length;i++) { 
		if (pieces[i] != null && pieces[i].length() > 0)
			args+=" -source-path="+pieces[i];
	}

	if (use_mustella_framework_dir) { 
		
		// System.out.println ("Adding qa fwk dir: " + mustella_framework_dir);
		
		// Now add the rest.
		args+= " -source-path="+mustella_framework_dir;	
		
		// If we're using android or iOS, use the CompareBitmap which handles file I/O. MXMLC will
		// keep whichever CompareBitmap it encounters first.
		if( target_os_name.equalsIgnoreCase( MobileUtil.ANDROID_OS ) ||
			target_os_name.equalsIgnoreCase( MobileUtil.IOS ) || 
			target_os_name.equalsIgnoreCase( MobileUtil.QNX ) )
		{
			//System.out.println("AIR files will override.");
			args+= " -source-path="+mustella_framework_dir+File.separator+"AIR";
		}	
	}

	/// this is the include for the fwk to send stuff to the Runner

	String services = System.getProperty("services");
	if (services!= null && !services.equals("")) {
		args+=" --services="+services;
	}
	String antArgs=System.getProperty("mxmlc.args");
	if (antArgs!=null && !antArgs.equals("")) {
		args=antArgs+" "+args;
	}

	args = checkAndAddUserArgs (mxml, args);

//	System.out.println ("ARGS: " + args);


	/**
	 * if this run is designated as an air_transform, do the dirty work here
	 * we save this for the end, because we need to shift the args.
	 */
	if (apollo_transform) {
		mxml = FileUtils.normalizeDirOS(mxml);
		args = ApolloAppToWindow.doAll (args, apollo_transform_prefix, apollo_transform_prefix2, mxml, apollo_transform_template, dir);
		mxml = ApolloAppToWindow.getNewMxmlName (dir, mxml, apollo_transform_prefix);
	}
	
	// ------- ArgumentParser -------------
	ArgumentParser parser = new ArgumentParser(args);
	defaultArgs = parser.parseArguments();
	if( debugDump ) {
		for(int i=0; i < defaultArgs.size(); i++) {
			System.out.println("ARG "+i+": "+defaultArgs.get(i));
		}
	}

	try {
		// writeTag(mxml, "status=started");
		// if compc is used to produce a swc, add it to the classpath

		String compc = System.getProperty("compc");

		if (compc != null && !compc.equals("")) {
			defaultArgs = compc(mxml, defaultArgs);
		}
		
		 // do a similar thing for rsl only do not put the rsl swc on the classpath
		String rsl = System.getProperty("rsl");
		if (rsl != null && !rsl.equals("")) {
			rsl(mxml);
			defaultArgs.add("+frameworks-dir");
			defaultArgs.add(frameworks);
		}

		System.out.println ("okey doke, going to compile " + mxml);

		CompileMxmlUtils compiler = new CompileMxmlUtils();
		compiler.setPrintOut(true);

		compiler.setDir(dir);

		/**
		System.out.println ("************");
		System.out.println ("************");
		
		String defaultArgsDebugString = new String();
		
		for(int i = 0; i < defaultArgs.length; ++i){
			defaultArgsDebugString += defaultArgs[i];
		}
		
		System.out.println ("mxml: " + mxml);
		System.out.println ("defaultArgs: " + defaultArgsDebugString);
		**/
		
		compiler.compile(mxml, defaultArgs);
		RuntimeExecHelper rh = compiler.getRuntimeExecHelper();

		/// FIX collect these results / insert

		// writeTag(mxml, "mxmlc=" + StringUtils.arrayToString(compiler.getExecArgs()) + "\ncompile time=" + StringUtils.formatTime(compiler.getLastRunTime()) + "\nexitvalue=" + rh.getExitValue() + "\nstdout=" + rh.getOutputText() + "\nstderr=" + rh.getErrorText());
		// System.out.println("rh output: " + rh.getOutputText());
		// System.out.println("rh error out: " + rh.getErrorText());
		// System.out.println("exit value=" + rh.getExitValue());

		String failedFile=null;

		// InsertErrorResult ier = null;
	
		if (rh.getExitValue() != 0) { 
			directory_result = 1;
			failedFile = rh.getErrorText();
			System.out.println("here's the failedFile; " + failedFile);

			handleCompileError (mxml, args, failedFile);

			/// insert failure into the database here. 
			//ier = new InsertErrorResult (run_id, failedFile, rh.getErrorText());

			removeFromList(this);

			/// don't bother retrying anymore. No more Mr. Nice Guy
			/* 
			if (removeFromArgs (mxml, failedFile, ermineArgs) && retryCount < 4) { 
				System.out.println ("Compile: Calling again");
				compileMxml (mxml, ermineArgs);		
			} else { 
						System.out.println("!!compile failed, but could not fix cmd line, sorry");
				if (!exit_on_compile_error)   { 
							System.out.println("Not set to exit on compile error, continue");
					removeFromList(this);
				}  else { 
					/// reachable?
							System.out.println("getting out");
					System.exit(1);

				}		

			}
			*/

		} else { 
			// System.out.println ("that was just ducky");

			/// if (System.getProperty("html")==null || System.getProperty("html").equals("false")==false) {

			removeFromList(this);
		}
	} catch (Exception e) {
		e.printStackTrace();
		handleCompileError (mxml, args, e.toString());
		removeFromList(this);
	}
    }

    private static final String compile_arg_ending = ".compile";
    private static final String property_arg_ending = ".htmlvars";


    // private Hashtable htmlVars = new Hashtable();

    public String checkAndAddUserArgs (String mxml, String args) { 

		String comp_mxml = transformName(mxml, compile_arg_ending);

		Map.Entry me = null;

		if (new File(comp_mxml).exists()) { 
			// System.out.println ("Saw the .compile file");

			Properties p = new Properties();
			try { 
				// Since we may get duplicate compile key directives, we
				// have to combine them.
				// can't really use load

				String line = null;
				String key = null;
				String val = null;
				String tmp = null;
				BufferedReader be = new BufferedReader (new FileReader (comp_mxml));

				/// Simplified version: just throw the arg on there, as is
				while ( (line=be.readLine()) != null) { 
					if (!line.startsWith ("#"))
						args += " "+ doSubstitute(line);
				}

				be.close();


			} catch (Exception e) { 
				System.err.println ("Exception on trying to load user .compile file, maybe ok");
				// e.printStackTrace();


			}
		}

		if (args.indexOf ("-debug") == -1){
			args += " -debug";
		}

		return args;
    }

    public String doSubstitute (String line) { 

	    	String sdk_dir=System.getProperty("sdk.dir");

	    	String fwk_dir=System.getProperty("framework.dir");

		if (sdk_dir != null && !sdk_dir.equals("")) { 

			if ( line.indexOf ("${sdk.dir}") != -1)  { 
				line = line.replaceAll ("\\$\\{sdk.dir\\}", FileUtils.normalizeDir(sdk_dir));
			}
		}

		
		if (mustella_dir != null && !mustella_dir.equals("")) { 
			if ( line.indexOf ("${mustella.dir}") != -1)  { 
				line = line.replaceAll ("\\$\\{mustella.dir\\}", FileUtils.normalizeDir(mustella_dir));
			}

		}

		if (fwk_dir != null && !fwk_dir.equals("")) { 
			if ( line.indexOf ("${framework.dir}") != -1)  { 
				line = line.replaceAll ("\\$\\{framework.dir\\}", FileUtils.normalizeDir(fwk_dir));
			}

		}


		return line;

    }
    


    public static String transformName (String mxml, String addition) { 

	if (mxml.endsWith (".mxml")) { 
		mxml = mxml.substring (0, mxml.length()-5) + addition;

	}

	return mxml;

	
    }
  
    // counter to see if there's progress. 
    private int retryCount = 0;
    private int lastCount = 0;
    private int currentCount = 0;
    private String lastRemove = null;
    
    public boolean removeFromArgs (String mxml, String removeArg, ArrayList ermineArgs) { 

	retryCount++;
	HashMap theBroken = splitAndFix(removeArg);

	currentCount = ermineArgs.size();
	
	if (currentCount < lastCount) {
		lastCount = currentCount;
	} else if (currentCount == lastCount) {
		// we're making no headway, 	
		return false;
	}

	System.out.println ("broken files: " + theBroken);

	int countOfIncludes= countIncludes (ermineArgs);

	// note futility right away.
	if (countOfIncludes == 1) { 
		System.out.println ("include count is 1. There's no hope, returning false");
		return false;
	}

	System.out.println ("include count: " + countOfIncludes);
	String fixed = null;


	/// how do we know if there's a test left?
	boolean others= false;
	int count = 0;
	String tmp = null;
	boolean tookAction = false;
	for (int i=0;i<ermineArgs.size();i++) { 

		tmp = (String) ermineArgs.get (i);
		if (tmp.indexOf ("-includes=") != -1) 
			tmp = tmp.substring (11);
		else { 
			System.out.println ("skipping arg: "+ tmp);
			continue;
		
		}
			

		// if it's a busted one, remove
		if (theBroken.put (tmp, new Integer (1)) != null)  { 
			tookAction = true;
			ermineArgs.remove (i);		
			if (lastRemove == null)
				lastRemove= tmp;
			else { 
				if (lastRemove.equals (tmp)) { 
					System.out.println ("Looks like we're trying again to remove: " + tmp);
				} else { 
					System.out.println ("removed from the pile: " + tmp + " of: " + count);	
					lastRemove=tmp;
				}
			}
			count++;
			System.out.println ("removed from the pile: " + tmp + " of: " + count);
		} else { 

			System.out.println ("skipped removal of : " + tmp);
		}

		if (count == countOfIncludes) { 
			System.out.println ("count now == includeCount, futile, return false");
			return false;
		}
		
	}

	if (count < countOfIncludes && tookAction)
		return true;

	return false;
    }

    public int countIncludes (ArrayList al) { 

	String tmp = null;

	int count= 0;
	
	for (int i=0;i<al.size();i++) { 

		tmp = (String) al.get (i);
		if ( tmp.indexOf ("-includes=") != -1) { 

			if (tmp.length() <= "-includes=".length())
				continue;

			/// unless includes are default ones, count
			if (tmp.indexOf (resultCollectorMixinName) == -1 && tmp.indexOf (excludeListMixinName) ==-1) { 
				System.out.println ("counting this: " + tmp);
				count++;
			}


		}


	}	

	return count;

    }

    public static HashMap splitAndFix(String s){ 

	String [] arr = s.split ("\n");

	System.out.println ("This was the count: " + arr.length);


	HashMap altmp = new HashMap();


	for (int i=0;i<arr.length;i++) { 

		if (arr[i].indexOf ("Error:") != -1)
			altmp.put ( fix (arr[i]), new Integer(1));	
	}


	return altmp;



    }


    public static String fix(String s) { 

	s = MustellaDirs.cleanFile (s);

	System.out.println ("This is a path sep: " + File.pathSeparator);

	if (s.indexOf (File.separator) != -1) 
		s = s.substring (s.lastIndexOf (File.separator)+1);
	else 
		System.out.println ("There ain't none in " + s);

	return s;

    }


    /// derive compile output file.
    public static String getTagName(String mxml) {
        String tag;
        if (mxml.indexOf(".") > -1) {
            tag = mxml.substring(0, mxml.lastIndexOf(".")) + ".output";
        } else {
            tag = mxml + ".output";
        }
        return tag;
    }

    
    public static void writeTag(String mxml, String msg) {
        String build = System.getProperty("build", "workspace");
        String out = "hostname=" + StringUtils.getHostName() + "\n";
        out += "date=" + StringUtils.getDate() + "\n";
        out += "build=" + build + "\n";
        out += msg;
        String name = getTagName(mxml);
        try {
            FileUtils.writeFile(name, out);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static ArrayList compc(String mxml, ArrayList mxmlArgs) throws Exception {
        System.out.println(">>>>> compc if necessary >>>>>>> " + mxml);
        CompcUtils compc = new CompcUtils();
        //compc.setPrintOut(true);
        File argFile = null;
        try {
            argFile = compc.getCompcArgFile(mxml);
            if (argFile.exists()) {
                compc.compile(argFile);
                RuntimeExecHelper rh = compc.getRuntimeExecHelper();
                mxmlArgs = compc.addSwcToClassPath(mxmlArgs);
        //        writeTag(mxml, "COMPC compile time=" + StringUtils.formatTime(compc.getLastRunTime()) + "\nexitvalue=" + rh.getExitValue() + "\nstdout=" + rh.getOutputText() + "\nstderr=" + rh.getErrorText());
                System.out.println("compc exit value=" + rh.getExitValue());
            }
        } catch (Exception e) {
            System.out.println("compc argfile doesn't exist...carry on.");
            e.printStackTrace();
        }

        return mxmlArgs;

    }

    public static void rsl(String mxml) throws Exception {
        System.out.println(">>>>> building rsl(s)");
        CompcUtils compc = new CompcUtils();
        //compc.setPrintOut(true);
        File argFile = null;
        try {
            argFile = compc.getRSLArgFile(mxml);
            if (argFile.exists()) {
                compc.compile(argFile);
                RuntimeExecHelper rh = compc.getRuntimeExecHelper();
                System.out.println("compc exit value=" + rh.getExitValue());
            }
        } catch (Exception e) {
            System.out.println("rsl argfile doesn't exist...carry on.");
            e.printStackTrace();
        }

    }
}
