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
package utils;
import java.io.*;
import java.util.*;

/**
 * Creates compile commands given a list of files, 
 * basically: searches .mxml files for a testSWF="val" and
 * returns the set of includes for that testSWF
 * the assumption is that we're in the current directory to do the compile.
 * descrube:
 */
public class MustellaDirs { 

	public static final String testProp =  "testSWF=";

	/**
	 * find the testSWF and return what it references.
	 */
	public static String getTestSwf(String name) { 

		String ret = null;

		try { 

			String line = null;
			BufferedReader br = new BufferedReader (new FileReader (name));
			/// we will not go far into a file to get this
			int count = 0 ;

			int loc = -1;

			while ( (line=br.readLine()) != null) { 

				if ((loc = line.indexOf(testProp)) != -1) {

					ret = line.substring (loc+testProp.length()+1, line.indexOf ("\"", loc + testProp.length()+2));
					break;

				}
			}

		} catch (Exception e) { 
			e.printStackTrace();
		}



		String dir = null;


		if (ret != null)
			dir=getSwfDir (name);

		if (dir != null)
			return dir + File.separator + ret;
		else { 

				
			return ret;

		}


	}


	public static String getSwfDir (String file) {


		// bust off the back.

		String dir = null;

		dir = file.substring (0, file.lastIndexOf(File.separator));	
		// System.out.println ("dir1: " + dir);
		dir = dir.substring (0, dir.lastIndexOf(File.separator));	
		// System.out.println ("dir1: " + dir);

		
		String copy1 = dir + File.separator + "SWFs";

		// System.out.println ("TRYING: " + copy1);

		if ( new File(copy1).exists()) {
			// System.out.println ("FOUND IT!");
			return copy1;
		}


		String copy2 = dir + File.separator + "swfs";
		// System.out.println ("TRYING: " + copy2);

		if ( new File(copy2).exists()) { 
			// System.out.println ("FOUND IT!");
			return copy2;
		}
		

		return null;

	}



	public static void printAsCommands(HashMap hm) { 

		// getCommands (hm);
		
		String test = null;
		Iterator it = hm.entrySet().iterator();
		Map.Entry me = null;
		ArrayList tmp = null;
		String tmps = null;
		while (it.hasNext()) { 

			me = (Map.Entry) it.next();
			test= (String)me.getKey();
			tmp = (ArrayList) me.getValue();

			System.out.print (test);
			System.out.print (" "); 

			for (int i=0;i<tmp.size();i++) { 
				System.out.print (tmp.get(i));
				System.out.print (" "); 
			}
	
			System.out.println (""); 
		}		



	}


	public static void getCommands (HashMap hm) { 


		Iterator it = hm.entrySet().iterator();
		ArrayList ret = new ArrayList();
		ArrayList tmp = null;


		StringBuffer sb = null;
		String test = null;
		String tmps = null;

		Map.Entry me = null;
		while (it.hasNext()) { 

			me = (Map.Entry) it.next();
			test= (String)me.getKey();
			tmp = (ArrayList) me.getValue();

			ArrayList tmpr = new ArrayList();

			if (tmp == null)
				continue;

			sb  = new StringBuffer();

			for (int i=0;i<tmp.size();i++) { 
				
				sb.append (" -includes=");	
				sb.append ( (String)tmp.get(i) );		
				tmpr.add (sb.toString());
				
			}


			hm.put (test, tmpr);

		}
		

		// return ret;

	}


	public static boolean contains (String target, String toSplit) { 

		String [] args = toSplit.split (";");


		for (int i=0;i<args.length;i++) { 
			if (args[i].equals (target)) { 
				return true;
			}
		}

		return false;

		



	}

	/**
	 the bug is that swfs maps testSwfs to fq path to testSwf

	 but it could be a dupe in the test swf name, 

	 which would fail. 
	
	**/

	public static void genHashMap (String file, HashMap includes, HashMap swfs, String survivor) { 

		if (!file.endsWith (".mxml"))
			System.out.println ("not an mxml file, returning");


		HashMap map = new HashMap ();

		String testSwf = null;
		testSwf = getTestSwf (file);


		// System.out.println ("have this file and test swf: " + file + " " + testSwf);


		ArrayList al = null;

		Iterator it = null;

		String tmp = null;

		String path = null;

		int count = 0;


		/// It references a testSwf, ergo, it goes on the -include line
		if (testSwf != null) { 
			al = (ArrayList)includes.get (testSwf);
			// first test seen for this swf
			if (al == null) { 
				/// create a list for the line
				al = new ArrayList();
				includes.put (testSwf, al);
			}


				
			if (swfs.get (testSwf) == null) 
				swfs.put (testSwf, null);

			/// I think we'll have to clean this up
			try { 
				path = new File(file).getParent();
				file = new File(file).getName();
				/// if survivor is non null, we're only adding the file it points to
				if (survivor != null)  { 
					// if (file.equals (survivor))  { 
					if (contains(file, survivor))  { 
						// System.out.println ("genHash - survivor file: adding path, file: " + path + " " + file + " for key: " + testSwf);	
						al.add (" -includes=" + cleanFile(file));
						if (path != null && path.length() > 0) 
							al.add (" -source-path+=" + path);
					} 
				} else { 
					// System.out.println ("genHash - file: adding path, file: " + path + " " + file + " for key: " + testSwf);	
					al.add (" -includes=" + cleanFile(file));
				// this could get too long. We should really only add this once
				// ie, get rid of duplicates
					if (path != null && path.length() > 0) { 
               			         al.add (" -source-path=" + path);
					 // System.out.println ("genHash - Adding path: " + path);
					} 
					/* 
					if (swfs.get (testSwf) == null) { 
					 	System.out.println ("genHash - Still null for " + testSwf + " Making a guess" );
						addGuessSwfPath (swfs, testSwf, path);
					}	
					*/
				}
			} catch (Exception e) { 
				System.out.println ("Exception dealing with the path/Name there");
				e.printStackTrace();
			}
		} else { 
			/// in this half, we have an mxml file that does not reference 
			/// a testswf itself, potentially.
			/// let's yank the end of it off and figure out the key it goes with
			/// swfs creates an association of simple names, like main.mxml, 
			/// to their path + file name
			tmp = new File ( file ).getPath() ;
			// tmp = new File ( file ).getName() ;
			// System.out.println ("genHash - file: non referent: "+ tmp + " " + file);
			if ( swfs.get(tmp) == null) { 
				// System.out.println ("genHash - file: non referent: "+ tmp + " " + file);
				swfs.put (file, tmp);
			} 
		}

		// System.out.println (swfs);

	}


	/**
	 * make a guess about the right path + test swf
	 */
	public static void addGuessSwfPath (HashMap swfs, String testSwf, String path) { 


		/// return the guess about where this stuff lives if it's not already there
		try { 
			testSwf = new File (testSwf).getName();
			// System.out.println ("addGuess with tweaked testSwf: " + testSwf);
			if (new File (transform1(testSwf, path)).exists()) { 
				// System.out.println ("genHash - putting on a new swf for " + testSwf);
			
				swfs.put (testSwf, transform1(testSwf,path));
			} 
		} catch (NullPointerException npe) { 
				System.out.println ("genHash - putting a null on for " + testSwf);
				swfs.put (testSwf, null);

		}


	}


	/**
	 * walk the path to guess about the right path + test swf
	 */
	public static String transform1 (String file, String path) { 

		// System.out.println ("genHash - transform with : " + file + " " + path);

		if (path.indexOf (File.separator) != -1) { 
			path = path.substring (0, path.lastIndexOf (File.separator));
			// System.out.println ("path now: " + path);
			if (new File(path + File.separator + "SWFs").exists()) { 
				path=path + File.separator + "SWFs";
			} else if (new File(path + File.separator + "swfs").exists()) {
				path=path + File.separator + "swfs";
			}
			if (new File(path + File.separator + file).exists())
				path=path + File.separator + file;
			else { 
				path = null;
			}
				
		} else if (path.indexOf ("/") != -1) { 
			path = path.substring (0, path.lastIndexOf ("/"));
			// System.out.println ("path now: " + path);
			if (new File(path + "/"+ "SWFs").exists()) { 
				path=path + "/"+ "SWFs";
			} else if (new File(path + "/"+ "swfs").exists()) { 
				path=path + "/"+ "swfs";
			}

			if (new File(path + "/" + file).exists())
				path=path + "/"+ file;
			else { 
				path = null;
			}

		}


		return path ;

	}

	public static void printFiles (String dir) { 

		try { 
			System.out.println ("Begin list");

			String [] s = new File (dir).list();

			for (int i=0;i<s.length;i++) 
				System.out.println (s[i]);

			

		} catch (Exception e) { 
		}

		System.out.println ("END list");
	}


	public static String cleanFile (String f) { 

		if (f.indexOf (".mxml") != -1)
			return f.substring (0, f.indexOf (".mxml"));

		return f;


	}
	public static void main (String [] args) throws Exception { 


	}

}
