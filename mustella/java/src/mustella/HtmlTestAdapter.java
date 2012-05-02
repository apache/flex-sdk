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
 * invoked by Runner when doing a browser run
 * Writes the html file that will get invoked 
 */
public class HtmlTestAdapter { 


	// These are the default dimensions. 
	public static final String standard_height= "375";
	public static final String standard_width= "500";

   	private static final String property_arg_ending = ".htmlvars";

	String real_mxml_file = null;

	String html_file = null;

	ParseMxmlHeader pml = null;

	String extra_args = "";

	ByteArrayOutputStream baos = null;

	public static String sdk_dir=null;
    	public static String htmlDir=null;
    	// public static String htmlDirEnd = "/templates/client-side-detection-with-history/"; 
    	public static String htmlDirEnd = "/templates/swfobject/";

	static { 
	try { 
		if (System.getProperty ("sdk.dir")!=null && !System.getProperty ("sdk.dir").equals("")) 
			sdk_dir = System.getProperty ("sdk.dir");
	} catch (Exception e) { 
	}

	try { 
		if (System.getProperty ("htmlDir")!=null && !System.getProperty ("htmlDir").equals("")) { 
			htmlDir = System.getProperty ("htmlDir");
			System.out.println ("incoming htmlDir: " + htmlDir);
		} else {
			htmlDir = sdk_dir + htmlDirEnd;
			System.out.println ("non incoming htmlDir: " + htmlDir);
		}

		if (!htmlDir.endsWith("/"))
			htmlDir = htmlDir + "/";	

		System.out.println ("result htmlDir: " + htmlDir);
	} catch (Exception e) { 
	}
	}


	public HtmlTestAdapter (String swfFile, String loaderSwf) throws Exception {

	
		real_mxml_file = transformName(swfFile, ".mxml");
		html_file = transformName(swfFile, ".html");


		System.out.println ("Here is the real mxml file: " + real_mxml_file);


		pml = new ParseMxmlHeader();
		pml.setWidthAndHeight (real_mxml_file);

		System.out.println ("here's the size: " + pml);

		
		GetUserArgs gu = new GetUserArgs();
		extra_args = gu.checkAndAddUserArgs (real_mxml_file, extra_args);



		createHtmlShell (html_file);

	}


	/// given the htmlvars file, 
	public static String populateKeyValuePairs (String mxmlFile) { 


		String fileName = transformName (mxmlFile, property_arg_ending);

		String tmp = null;

		Properties p = new Properties();

		if (new File(fileName).exists()) { 

			try { 

				BufferedReader br = new BufferedReader (new FileReader(fileName));

				while ( (tmp=br.readLine()) != null) { 

					if (tmp.startsWith("flashvars="))
						tmp = tmp.substring (10);

					split (tmp, p);

				}
			
				br.close();	
			} catch (Exception e) { 
	
				e.printStackTrace();
			}
		}

		// roll through these and make them flashvars.key=val; strings
		Iterator it = p.entrySet().iterator();

		Map.Entry me = null;

		StringBuffer bs = new StringBuffer();

		while (it.hasNext()) {

			me = (Map.Entry) it.next();

			bs.append ("flashvars.");
			bs.append ((String)me.getKey());
			bs.append ("=");
			bs.append ("\"");
			bs.append ((String)me.getValue());
			bs.append ("\"");
			bs.append (";");
		}

		return bs.toString();
    	}


	public static void split (String line, Properties  p) {

		String key = null;
		String entry = null;

		String tmp = null;

		// two way split, 
		StringTokenizer st = new StringTokenizer(line, "&");

		while (st.hasMoreTokens()) {

			tmp = st.nextToken();

			key = tmp.substring (0, tmp.indexOf ("="));
			entry = tmp.substring (tmp.indexOf ("=")+1);
			p.put (key, entry);
		}


	}	


	public static Properties populatePropertiesFile (String mxmlFile) { 

		Properties p = new Properties();

		String fileName = transformName (mxmlFile, property_arg_ending);

		if (new File(fileName).exists()) { 

			try { 
				p.load (new FileInputStream (fileName));

			} catch (Exception e) { 
	
				e.printStackTrace();
			}
		}

		return p;
    	}

    	public static String height = "375";
    	public static String width = "500";


	/*
    	public void setWidthAndHeight(String mxml) {

    	try {

		String line = null;
                BufferedReader br = new BufferedReader (new FileReader (mxml));
                /// we will not go far into a file to get this
                int count = 0 ;

                int loc = -1;
                int loc_end = -1;

		boolean begun =  false;

		boolean set1 = false;
		boolean set2 = false;

                while ( (line=br.readLine()) != null) {
                	if ( (loc = line.indexOf("Application")) != -1) 
				begun= true;

						
		
			if (begun) { 
				if (line.indexOf ("height=")!=-1) {
					height = line.substring (line.indexOf ("height=")+8);
					System.out.println ("inter h: " + height);
					height = height.substring (0, height.indexOf ("\""));
					set1 = true;
		
				}
				
				if (line.indexOf ("width=")!=-1) {
					width = line.substring (line.indexOf ("width=")+7);
					System.out.println ("inter w: " + width);
					if (width.indexOf ("\"") != -1)
						width = width.substring (0, width.indexOf ("\""));
					set2 = true;
				}
                        }

			if (set1 && set2) { 
				br.close();
				break;
			}

                	if ( begun && (loc_end = line.indexOf(">")) != -1)  { 
				br.close();
				break;
			}
		}

                } catch (Exception e) {
                        e.printStackTrace();
                }


    	}

	*/

    public void createHtmlShell(String mxml) {

	
	System.out.println ("Creating the HTML files!!!! with " + mxml);


        mxml=FileUtils.normalizeDir(mxml);

	Properties p = populatePropertiesFile (mxml);
	String pVals = populateKeyValuePairs (mxml);
	System.out.println ("Properties file contained: " + pVals);

	// ParseMxmlHeader pml = new ParseMxmlHeader();
	// pml.setWidthAndHeight (mxml);

        String dir=mxml.substring(0,mxml.lastIndexOf("/"));
        String file=mxml.substring(mxml.lastIndexOf("/")+1);
        String name=file.substring(0,file.lastIndexOf("."));
        String swf=name+".swf";


        try {
            
	    System.out.println ("Copying from: " + htmlDir + "history to: " + dir + "/history");
	    FileUtils.copyDir(htmlDir + "history", dir + "/history");
	    /// addded
	    // was: AC_OETags.js
	    System.out.println ("Copying from: " + htmlDir + "swfobject.js");
	    FileUtils.copyFile( htmlDir + "swfobject.js", dir+"/swfobject.js" );

        } catch (Exception e) {
            e.printStackTrace();
        }

	try { 
		// new load, edit, write.
		BufferedInputStream bis = new BufferedInputStream (new FileInputStream ( htmlDir + "index.template.html"));

		ByteArrayOutputStream bos = new ByteArrayOutputStream();

		int av = 0;
		byte [] b = null;
		
		String contents = null;

		while ((av = bis.available()) > 0) { 
			b = new byte[av];
			bis.read (b, 0, av);
			bos.write (b, 0, av);

		}

		contents = bos.toString();

		// replace our targets. 
		contents = contents.replaceAll ("\\$\\{useBrowserHistory\\}", "--");
		contents = contents.replaceAll ("\\$\\{application\\}", name);
		contents = contents.replaceAll ("\\$\\{title\\}", name);

		// contents = contents.replaceAll ("\\$\\{height\\}", height);
		// contents = contents.replaceAll ("\\$\\{width\\}", width);
		System.out.println ("HTML SHELL, width and height: " + pml.width + " " + pml.height);
		contents = contents.replaceAll ("\\$\\{height\\}", pml.height);
		contents = contents.replaceAll ("\\$\\{width\\}", pml.width);
		contents = contents.replaceAll ("\\$\\{bgcolor\\}", "0x000000");
		contents = contents.replaceAll ("\\$\\{version_major\\}", "9");
		contents = contents.replaceAll ("\\$\\{version_minor\\}", "0");
		contents = contents.replaceAll ("\\$\\{version_revision\\}", "0");
		contents = contents.replaceAll ("\\$\\{swf\\}", name );

		/// push FlashVars if we've got any 
		if (p.getProperty("flashvars") != null && (p.getProperty("flashvars").length() > 0)) { 
			/// teh second one has an equals sign
			contents = contents.replaceAll ("height=", "FlashVars=\"" + p.getProperty ("flashvars") + "\" " + "height=");
			// the first one doesn't
			contents = contents.replaceAll ("\"height\"", "\"FlashVars\", \"" + p.getProperty ("flashvars") + "\", " + "\"height\"");
			contents = contents.replaceAll ("var flashvars = \\{\\};", "var flashvars = \\{\\}; " + pVals);

		}

		/// write it to our target html file.
		String fileTo = dir + "/" + name + ".html";
		System.out.println ("WRITING " +  fileTo);
		BufferedOutputStream bus = new BufferedOutputStream (new FileOutputStream(fileTo));
	
		bus.write (contents.getBytes(), 0, contents.length());
		bus.flush();
		bus.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

	

		
			


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



    }



}
