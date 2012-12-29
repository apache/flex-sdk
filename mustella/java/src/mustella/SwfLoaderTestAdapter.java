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

import java.io.File;
import java.util.regex.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.util.*;

/**
 * User: bolaghlin
 * invoked by Runner when doing a swfloader run
 * Rewrites the shell_swf headers with height and width from the target test_swf
 * Recompiles the shell_swf with any arguments found in target test_swf.compile files
 */
public class SwfLoaderTestAdapter { 


	// These are the default dimensions. 
	public static final String standard_height= "375";
	public static final String standard_width= "500";

	String real_mxml_file = null;

	String loader_mxml_file = null;

	ParseMxmlHeader pml = null;

	String extra_args = "";

	ByteArrayOutputStream baos = null;


	public SwfLoaderTestAdapter (String swfFile, String loaderSwf) throws Exception {

	
		real_mxml_file = transformName(swfFile, ".mxml");
		loader_mxml_file = transformName(loaderSwf, ".mxml");


		System.out.println ("Here is the real mxml file: " + real_mxml_file);


		pml = new ParseMxmlHeader();
		pml.setWidthAndHeight (real_mxml_file);

		
		GetUserArgs gu = new GetUserArgs();
		extra_args = gu.checkAndAddUserArgs (real_mxml_file, extra_args);


		/// read/edit/(and write) the genericLoad.
		readAndEditGenericLoadScript();

		compileGenericLoadScript();

	}


	public void compileGenericLoadScript() throws Exception {

		CompileMxmlUtils compm = new CompileMxmlUtils();


		String dir = FileUtils.normalizeDir (real_mxml_file);
		dir = dir.substring(0, dir.lastIndexOf("/"));
		System.out.println ("Setting dir on compile to " + dir);
		compm.setDir (dir);

		System.out.println ("Calling compile with these args: " + loader_mxml_file + " " + extra_args);

		String [] args  = StringUtils.StringToArray (extra_args);


		compm.compile(loader_mxml_file, new ArrayList(Arrays.asList(args)));

		System.out.println ("Done with generic loader compile");
	}


	public void readAndEditGenericLoadScript() throws Exception {
		/// read the file.

		String line = null;
                BufferedReader br = new BufferedReader (new FileReader (loader_mxml_file));
                BufferedWriter bw = new BufferedWriter (new FileWriter (loader_mxml_file+".tmp"));
                /// we will not go far into a file to get this
                int count = 0 ;

                int loc = -1;
                int loc_end = -1;

		boolean begun =  false;

		boolean set1 = false;
		boolean set2 = false;

		boolean done = false;

                while ( (line=br.readLine()) != null) {
                	if ( (loc = line.indexOf("Application")) != -1) 
				begun= true;

						
		
			if (begun && !done) { 
				if (line.indexOf ("height=")!=-1) {
					System.out.println ("Seeing height: " + line);
					// line = line.replaceAll ("height=\"[0-9][0-9]*\p{punct}*", "height=\"" + pml.height +"\"");
					line = line.replaceAll ("height=\"[0-9][0-9]*%?\"", "height=\"" + pml.height +"\"");
					System.out.println ("replaced height: " + line);
					set1 = true;
				}
				
				if (line.indexOf ("width=")!=-1) {
					System.out.println ("Seeing width: " + line);
					line = line.replaceAll ("width=\"[0-9][0-9]*%?\"", "width=\"" + pml.width +"\"");
					System.out.println ("replaced width: " + line);
					set2 = true;
				}
                        }

			if (set1 && set2) { 
				done = true;	
			}

                	if ( begun && (loc_end = line.indexOf(">")) != -1)  { 
				done = true;
			}

			bw.write (line, 0, line.length());
			bw.newLine();
		}

		bw.flush();
		try { 
			bw.close();
		} catch (Exception e) { 
			e.printStackTrace();
		}
		try { 
			br.close();
		} catch (Exception e) { 
			e.printStackTrace();
		}

		/// copy the .tmp to the orig
		//// NYI
		FileUtils.copyFile (loader_mxml_file+".tmp", loader_mxml_file);

		
    }



    private static final String compile_arg_ending = ".compile";

    public String checkAndAddUserArgs (String mxml, String args) { 

	String comp_mxml = transformName(mxml, compile_arg_ending);

	Map.Entry me = null;

	if (new File(comp_mxml).exists()) { 
		System.out.println ("Saw the .compile file");

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

	return args;


    }


    public static String transformName (String file, String addition) { 

	if (file.indexOf (".") != -1) {
		return file.substring (0, file.lastIndexOf (".")) + addition;

	}

	return file;

	
    }

    public String doSubstitute (String line) { 

	    	String sdk_dir=System.getProperty("sdk.dir");

	    	String fwk_dir=System.getProperty("framework.dir");

    		String mustella_dir = System.getProperty ("mustella.dir");

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
  

    public static void main (String[] args) throws Exception { 


		SwfLoaderTestAdapter slr = new SwfLoaderTestAdapter (args[0], args[1]);

	}



}
