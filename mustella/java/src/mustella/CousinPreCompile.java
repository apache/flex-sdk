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

import org.apache.tools.ant.Task;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.BuildException;
import java.io.File;
import java.util.*;

public class CousinPreCompile extends Task {


	/** 

	Custom filtering mechanism. 

	looks for a file ("pre_compile.sh") in SWF directories, given a list of files/directories

	by decree, the only shell script that should get executed in the SWFs directory
	is the pre_compile.sh script. If something else turns up, we remove it.


	**/



	// this is a variable, though it seems needless at this point:
    	private String shellFile = "pre_compile.sh";


    	private final String swfDir1 = "../SWFs/";
    	private final String swfDir2 = "../swfs/";

	public void setShellFile(String s) { 
		this.shellFile = s;
	}

	public String getShellFile() { 
		return shellFile;
	}

	private String property = null;

	public String getProperty() { 
		return property;
	}

	public void setProperty (String prop) { 
		this.property = prop;
	}


	/// the contents of a fileset: 
	private String files = null;

	public void setFiles(String target) { 
		this.files = target;
	}

	public String getFiles() { 
		return files;
	}


	private String root = "";

	public void setRoot(String target) { 
		this.root = target;
	}

	public String getRoot() { 
		return root;
	}


	private HashMap rez = new HashMap();


	/// we need to take build, passed to us, and 
	/// generate the id, setting that back in the project
    	public void execute() {


		/// split into pieces: 
		String [] args = files.split(File.pathSeparator);
		// System.out.println ("args length: " + args.length);
		// System.out.println ("arg1: " + args[1]);

		


		ArrayList actuals = new ArrayList();

		StringBuffer result = new StringBuffer();
		result.append("");

		Object obj = null;


		File tmp = null;

		String use = null;


		for (int i=0;i<args.length;i++) {


			use = args[i].trim();
			// System.out.println ("result0: " + use);

			if ( use.startsWith(","))
				use=use.substring(1).trim();

			// System.out.println ("result1: " + use);

			tmp = new File (use);

			if (use == null || use.equals (""))
				 continue;


			if (!tmp.isDirectory()) {
				// if this is a file, see if we have to filter it
				// if it lives in the SWFs directory, it can only be one name
				if (tmp.getParent().toLowerCase().endsWith ("swfs")) {
					// System.out.println ("NAME: " + tmp.getName());
					if (!tmp.getName().equals ("pre_compile.sh")) {
						// System.out.println ("SKIPPING " + tmp.getName());
						continue;
					} else { 
				
						try { 
							obj = rez.put (tmp.getCanonicalPath(), "");
							if (obj==null)
								actuals.add(0, tmp.getCanonicalPath());
						} catch (Exception e) {
							e.printStackTrace();
						}
						continue;

					}
				} else { 
					/// in this case, it's a file, 
					/// so, we strip the file and will search it later
					// System.out.println ("Adding: " + tmp);
					try { 
						obj = rez.put (tmp.getCanonicalPath(), "");
						if (obj==null)
							actuals.add(tmp.getCanonicalPath());
					} catch (Exception e) {
						e.printStackTrace();
					}
					// System.out.println ("working NOW with: " + tmp.getParent());
					args[i] = tmp.getParent();
				}
			}

			if (!tmp.exists()) {
				args[i] = root + "/" + args[i];
				// System.out.println ("morphed to: " + args[i]);
			}


			if (new File ( args[i] + "/" + swfDir1 + shellFile ).exists() ) {
			
				try { 	
				obj = (Object) rez.put (new File ( args[i] + "/" + swfDir1 + shellFile).getCanonicalPath(), "");
				if (obj==null)
					actuals.add(0, new File ( args[i] + "/" + swfDir1 + shellFile).getCanonicalPath());
				// System.out.println ("got one off: " + new File ( args[i] + "/" + swfDir1 + shellFile).getCanonicalPath());
				}catch (Exception e) {}
				continue;
			} else if (new File ( args[i] + "/" + swfDir2 + shellFile ).exists() ) {
				try { 	
				obj = (Object)rez.put (new File ( args[i] + "/" + swfDir2 + shellFile).getCanonicalPath(), "");
				if (obj==null)
					actuals.add(0, new File ( args[i] + "/" + swfDir2 + shellFile).getCanonicalPath());
				// System.out.println ("got one off: " + new File ( args[i] + "/" + swfDir2 + shellFile).getCanonicalPath());
				}catch (Exception e) {}
				continue;
			} else if (new File (tmp.getParent() + "/" + swfDir1 + shellFile ).exists() ) {
				try { 	
				obj = (Object) rez.put (new File (tmp.getParent() + "/" + swfDir1 + shellFile ).getCanonicalPath(), "");
				if (obj==null)
					actuals.add(0, new File (tmp.getParent() + "/" + swfDir1 + shellFile ).getCanonicalPath());
				// System.out.println ("got one off: " + new File (tmp.getParent() + "/" + swfDir1 + shellFile ).getCanonicalPath());
				}catch (Exception e) {}
				continue;
			} else if (new File (tmp.getParent() + "/" + swfDir2 + shellFile ).exists() ) {
				try { 	
				obj = (Object) rez.put (new File (tmp.getParent() + "/" + swfDir2 + shellFile ).getCanonicalPath(), "");
				if (obj==null)
					actuals.add(0, new File (tmp.getParent() + "/" + swfDir2 + shellFile ).getCanonicalPath());
				// System.out.println ("got one off: " + new File (tmp.getParent() + "/" + swfDir2 + shellFile ).getCanonicalPath());
				}catch (Exception e) {}
				continue;
			}

			// System.out.println ("bottom of loop");
		}

			

		// System.out.println ("rez: " + rez.toString());

		// Iterator it = actuals.iterator();


		String tmp1 = null;

		/// use CANONICAL!

		for (int i=0;i<actuals.size();i++) {


			tmp1 = (String)actuals.get(i);
			if (tmp1.endsWith(".sh"))
				result.append (tmp1);

			if (i<(actuals.size()-1))
				result.append (File.pathSeparator);
				
		}

		// System.out.println ("result: " +  result.toString());

		/* 
		while (it.hasNext()) {
			tmp1 = (String) it.next();
			try { 
			} catch (Exception e) {
				e.printStackTrace();}
			result.append (tmp1);
			if (it.hasNext())
				result.append (File.pathSeparator);
			// System.out.println ("result: " +  tmp1.toString());
		}
		*/

		Project project = getProject();
		project.setProperty(property, result.toString());
		   
	 

	}	



}
