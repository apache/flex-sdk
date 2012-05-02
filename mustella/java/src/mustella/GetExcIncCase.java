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

import java.sql.*;
import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;

public class GetExcIncCase { 


	/**

		Write excludes.

		type can be "class" or "text". If class, it wraps the list in a 
		package & class structure.

		text, just write the values

	**/


	public static String testcaseTableName = "test_cases";

	public static String branch = null;
	public static String browser = null;
	public static String os = null;
	public static String runtime = null;
	public static String outfile = null;
	public static String untilTime = null;
	public static String type = "class";
	public static String bugByPass = null;


	public static String exclude_config_id_str;


	public static void setPassedExcludeId (String s) { 

		if (!s.equals("")) { 
			exclude_config_id_str = s;
		}
	}

	public static void setBranch (String b) { 
		branch = b;
	}

	/// the cutoff for excludes in this run. a time stamp
	public static void setUntilTime (String b) { 
		untilTime = b;
		System.out.println ("until time is: " + b);
	}


	public static void setBugByPass (String b) { 
		bugByPass = b;
	}

	public static void setOs (String b) { 
		os = b;
	}

	public static void setType (String b) { 
		type = b;
	}

	public static void setRuntime (String b) { 
		runtime = b;
	}

	public static void setExcludeConfigId (String s) { 
		exclude_config_id_str = s;
	}

	public static void setBrowser (String b) { 
		browser = b;
		if (browser.indexOf ("/") != -1) { 
			browser = browser.substring (browser.lastIndexOf ("/")+1);
		} else if (browser.indexOf (File.separator) != -1) { 
			browser = browser.substring (browser.lastIndexOf (File.separator)+1);
		}

		browser = browser.toLowerCase();
	}

	public static void createAndWrite (String filename, String branchl, String browserl, String runtimel, String osl) throws Exception {   

		outfile = filename;
		branch = branchl;
		browser = browserl;
		runtime = runtimel;
		os = osl;


		if (browser.indexOf ("/") != -1) { 
			browser = browser.substring (browser.lastIndexOf ("/")+1);
		} else if (browser.indexOf (File.separator) != -1) { 
			browser = browser.substring (browser.lastIndexOf (File.separator)+1);
		}

		browser = browser.toLowerCase();

	
		// System.out.println ("resulting browser: " + browser);	

	
		/// set	
		if (exclude_config_id_str == null) { 
			// System.out.println ("---->>>>> Calling getExcludeConfigs");
			exclude_config_id_str = getExcludeConfigs();
		} 


		ArrayList al = getExcludes();	
		ArrayList al2 = ExcludesAdjuster.getExcludes();	
		if (!al2.isEmpty())
			al.addAll (0, al2);


		System.out.println ("excludes count: " + (al.size()));

		writeToFile (al, filename);

		
	}

	public static void createAndWrite (String filename, String exclude_config) { 

		exclude_config_id_str	= exclude_config;

		try { 

		ArrayList al = getExcludes();	
		ArrayList al2 = ExcludesAdjuster.getExcludes();	

		if (!al2.isEmpty())
			al.addAll (0, al2);

		writeToFile (al, filename);

		} catch (Exception e) { 

			e.printStackTrace();
			
		}


	}



	private static final String sep = "$";
	private static final String comma = ",";
	private static final String colon1 = ": 1";
	private static final String tabs = "		";
	private static final String newline = System.getProperties().getProperty ("line.separator");

	public static ArrayList getExcludes() throws Exception { 
		
		System.err.println ("This should no longer be called");
		
		/* AJH
		Connection con = null;

		try { 
			con = GetConnection.get();
		} catch (Exception e) { 
			System.err.println ("Could not make database connection, no fetch of excludes");
			return new ArrayList();
		}

		Statement stmt = con.createStatement();
		*/
		
		/* 
			need to make this a transaction !!

		*/

		
		ArrayList al = new ArrayList();
		
		/* AJH
		ResultSet rs =stmt.executeQuery ( getExcludeStmt () );

		String tmpdir = null;
		String tmps = null;
		String tmpt = null;

		StringBuffer sb = new StringBuffer();

		while (rs.next()) { 
			tmpdir = rs.getString(1);	
			tmps = rs.getString(2);	
			tmpt = rs.getString(3);	
			sb.append (tmpdir);
			sb.append (tmps);
			sb.append (sep);
			sb.append (tmpt);
			if (type.equals("class"))
				sb.append (colon1);
	
			if (!rs.isLast())
				sb.append (comma);

			al.add (sb.toString());
			sb.delete (0, sb.length());
		}
		*/

		return al;

	}

	public static final String qt = "'";

	public static String getExcludeCountStmt() { 


		String s = "select count(test_file) from test_cases, excludes where test_cases.id = excludes.testcase_id and (excludes.date_end = '0000-00-00 00:00:00' or excludes.date_end > '" + untilTime +"' ) and excludes.exclude_config_id in " + exclude_config_id_str;
		/// add untilTime
	
		return s;

	}


	/// neeed to check if the date_end  is > than some value we pass in; 
	//  that would be a not-yet vetted exclude

	public static String getExcludeStmt() { 

		String s = null;

		if (bugByPass != null && bugByPass.length() > 0) { 
			// System.out.println ("Here's bug by pass: " + bugByPass + " length: " + bugByPass.length());
			s = "select test_files.dir_name, test_file, test_id from test_cases, excludes, test_files where test_cases.id = excludes.testcase_id and test_files.id = test_cases.test_dir and (excludes.date_end = '0000-00-00 00:00:00' or excludes.date_end > '" + untilTime +"' ) and excludes.exclude_config_id in " + exclude_config_id_str  + " and (excludes.bug_id != '" + bugByPass + "' or excludes.bug_id is null)";
		} else {
			s = "select test_files.dir_name, test_file, test_id from test_cases, excludes, test_files where test_cases.id = excludes.testcase_id and test_files.id = test_cases.test_dir and (excludes.date_end = '0000-00-00 00:00:00' or excludes.date_end > '" + untilTime +"' ) and excludes.exclude_config_id in " + exclude_config_id_str;

		}

		// System.out.println (s);

		return s;

	}

	public static String getExcludeConfigStmt() { 
		String s = null;
		if (!browser.equals ("")) { 

			s = "select id from exclude_config where (os= '" +
			os+"' or os= 'any' ) and (branch= '" +
			branch+"' or branch= 'any' )and (runtime= '" +
			runtime+"' or runtime= 'any' ) and (browser= '" +
			browser+"' or browser= 'any') " ;
		
		} else { 

			s = "select id from exclude_config where (os= '" +
			os+"' or os= 'any' ) and (branch= '" +
			branch+"' or branch= 'any' )and (runtime= '" +
			runtime+"' or runtime= 'any' )";


		}

		// System.out.println (s);

		return s;

	}


	public static String getExcludeConfigs() throws Exception { 
		
		System.err.println ("This should not be called");
		
		/* AJH
		Connection con = null;

		try { 
			con = GetConnection.get();
		} catch (Exception e) { 
			System.err.println ("Could not make database connection, no fetch of excludes");
			return null;
		}

		Statement stmt = con.createStatement();
		*/

		StringBuffer sb = new StringBuffer();

		/* AJH
		sb.append ("(");
		
		
		ResultSet rs =stmt.executeQuery ( getExcludeConfigStmt () );

		String tmps = null;
		String tmpt = null;


		while (rs.next()) { 
			tmps = rs.getString(1);	

			sb.append (tmps);

			if (!rs.isLast())
				sb.append (comma);

		}

		sb.append (")");

		*/
		
		return sb.toString();


	}

	public static void close () { 

		/* AJH
		try { 
			GetConnection.get().close();
		} catch (Exception e) { 
		}
		*/
	}


	static String topFileExc1="package {\n\nimport flash.display.DisplayObject;\n\n[Mixin]\n\n/**\n\n*  A hash table of tests not to run. as of ";
	static String topFileExc2= "\n*/\n\npublic class CurrentExcludeList\n\n {\n\n public static function init(root:DisplayObject):void\n\n {\n\n		UnitTester.excludeList = {\n\n";

	static String topFileInc="package {\n\nimport flash.display.DisplayObject;\n\n[Mixin]\n\n/**\n\n*  A hash table of tests to run.\n*/\n\npublic class CurrentIncludeList\n\n {\n\n public static function init(root:DisplayObject):void\n\n {\n\n		UnitTester.includeList = {\n\n";

	static String bottomFile = "                };\n\n}\n }\n}\n";


	/** 
	 * writes to an as file, to be compiled as a swc
	 * writes the top, 
	 * then the arraylist contents, then the bottom
	 */
	public static void writeToFile (ArrayList al, String filename) { 
		writeToFile (al, filename, true);
	}	


	public static ResultSet doQuery (String s) {
		/* AJH
		Connection con = null;

		try { 
			con = GetConnection.get();
		} catch (Exception e) { 
			System.err.println ("Could not make database connection, no fetch of excludes");
			return null;
		}
		*/
		
		ResultSet rs = null;
		
		/* AJH
		try { 
			Statement stmt = con.createStatement();

			rs = stmt.executeQuery(s);

		} catch (Exception e) { 
			e.printStackTrace();
			return null;
		}
		*/
		
		return rs;

	}



	public static void writeToFileTransform (ArrayList al, String filename, HashMap tellFiles) throws Exception {


		FileOutputStream fos = null;

		String tmp = null;
		String last_tmp = null;

		String file_portion = null;

		try { 

			fos = new FileOutputStream (filename);


			if (type.equals ("class")) { 

				fos.write (topFileInc.getBytes(), 0, topFileInc.length());
			}



			for (int i=0;i<al.size();i++) { 

				tmp = (String) al.get (i);

				file_portion = tmp.substring (0, tmp.indexOf ("$"));

				file_portion = file_portion + qt;
					
		

				if (!file_portion.equals (last_tmp)) { 

			
					fos.write (tabs.getBytes(), 0, tabs.length());
					fos.write (file_portion.getBytes(), 0, file_portion.length());
					fos.write (":1".getBytes(), 0, ":1".length());
					fos.write (comma.getBytes(), 0, comma.length());
					fos.write (newline.getBytes(), 0, newline.length());
					last_tmp = file_portion;
					tellFiles.put (file_portion, "1");
				}

				if (type.equals("class"))
					fos.write (tabs.getBytes(), 0, tabs.length());
				fos.write (tmp.getBytes(), 0, tmp.length());

				if (i<al.size()-1)
					fos.write (comma.getBytes(), 0, comma.length());

				fos.write (newline.getBytes(), 0, newline.length());
				fos.flush();
			}

			if (type.equals ("class")) 
				fos.write (bottomFile.getBytes(), 0, bottomFile.length());
				

			fos.flush();
			fos.close();

		} catch (Exception e) { 

			e.printStackTrace ();

			try { 
				fos.close();
			} catch (Exception e2) { }

			throw e;
			
		}
	}

	public static void writeToFile (ArrayList al, String filename, boolean exclude) { 


		// System.out.println ("this is the file I'll write: " + filename);

		/// (the unusual) case of nothing to write
		/// skip out of here
		/*
		if (al.size()==0) { 
			/// not sure the wisdom
			System.out.println ("EMPTY SET FOR EXCLUDES. No write");
			return;
		}
		*/

		FileOutputStream fos = null;

		String tmp = null;

		try { 

			fos = new FileOutputStream (filename);


			if (type.equals ("class")) { 

				if (exclude) { 
					fos.write (topFileExc1.getBytes(), 0, topFileExc1.length());
					fos.write (untilTime.getBytes(), 0, untilTime.length());
					fos.write (topFileExc2.getBytes(), 0, topFileExc2.length());
				} else
					fos.write (topFileInc.getBytes(), 0, topFileInc.length());
			}



			for (int i=0;i<al.size();i++) { 

				tmp = (String) al.get (i);
				if (type.equals("class"))
					fos.write (tabs.getBytes(), 0, tabs.length());
				fos.write (tmp.getBytes(), 0, tmp.length());
				fos.write (newline.getBytes(), 0, newline.length());
				fos.flush();
			}

			if (type.equals ("class")) 
				fos.write (bottomFile.getBytes(), 0, bottomFile.length());
				

			fos.flush();
			fos.close();

		} catch (Exception e) { 

			e.printStackTrace ();

			try { 
				fos.close();
			} catch (Exception e2) { }

		}


	}




	public static void main (String [] args) throws Exception { 

		// System.out.println (System.getProperties());

		// String outfile = "tmp.run";

		/* testing
		ArrayList al = new ArrayList();

		al.add ("CBTester$myButtonTest1: 1,");
		al.add ("CBTester$myHeadTest1: 1");

		writeToFile (al, "tmp1.test");
		*/


		if (args.length == 0) { 
			System.err.println ("Required: NEED FILENAME TO WRITE EXCLUDES");
		}


		for (int i=0;i<args.length;i++)
			System.out.println (i + " " +args[i]);


		///kind of silly but it's all positional
		/// 
		String outfile = args[0];
		String branch  = args[1];
		String use_apollo = args[2];
		String use_browser = args[3];
		String browser = args[4];
		String os      = args[5];
		try { 
			untilTime = args[6];
		} catch (Exception e ) {
			/// transform to now
			untilTime = null;
		}

		String runtime = "";

		if (use_apollo.equals("true"))
			runtime = "apollo";
		else if (use_browser.equals ("true"))
			runtime = "browser";
		else
			runtime = "Standalone";

		if (runtime.equals ("apollo"))
			browser = "";


		createAndWrite (outfile, branch, browser, runtime, os);


		// System.out.println ("new run id: " + get ("999999"));



	}



}
