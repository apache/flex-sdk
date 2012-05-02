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
import java.io.*;

public class WriteFileNames extends Task {

    	private String list=null;
    	private String file=null;


	public void setList(String list) { 
		this.list = list;
	}

	public String getList() {
		return list;
	}

	public void setFile(String file) { 
		this.file = file;
	}

	public String getFile() {
		return file;
	}

	

	public static final String delimiter = ";";	



	/**
	 * Write the file one line at a time. 
	 */ 
	public void writeFile() { 


		BufferedWriter bw = null;

		try { 

			String [] arr = list.split(";");  

			bw = new BufferedWriter (new FileWriter (file));

			for (int i=0;i<arr.length;i++) { 

				bw.write (arr[i], 0, arr[i].length());
				bw.newLine();

			}

			bw.flush();
			bw.close();


		} catch (Exception e) { 
			e.printStackTrace();

		}




	}

	
	/// we need to take build, passed to us, and 
	/// generate the id, setting that back in the project
    	public void execute() {


		if (list == null) { 
                	log("Cannot continnue, need list attribute.", Project.MSG_ERR);
			return;
		}

		if (file == null) { 
                	log("Cannot continnue, need file attribute.", Project.MSG_ERR);
			return;
		}

		writeFile();

	
	}	
}
