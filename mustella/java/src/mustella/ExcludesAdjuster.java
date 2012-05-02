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
import java.io.*;
import java.util.ArrayList;



/**
 * Read in a local file to add to the list of excludes for a test run
 * meant as a workaround for insurmountable configuration differences.
 * details:
 * 
 * The file should reside in the qa/sdk/testsuites/mustella/tests directory.
 * It's name should be "MachineSpecificExcludes.txt".  It should not be checked in.
 * Its format should be one of two styles: 
 * it can be in failures output format (from mini run), like this: 
 *
 *   gumbo/components/List/events/VItemRendRET_event_tester VRendRET_List_scrollPosition6
 *
 * or already in exclude format: 
 * 
 *   gumbo/components/List/events/VItemRendRET_event_tester$VRendRET_List_scrollPosition6

 *
 */
public class ExcludesAdjuster {


	/**
	 * name of the file we'll read
	 */
	public static String excludesAdjustfile= "MachineSpecificExcludes.txt";

	/**
	 * Directory we'll read this from. This is ${sdk.mustella.dir}, 
	 * so we get it pushed from the excludes task (which has the project)
	 */
	public static String testsDir = null;


	public static void setDir (String dir) {
		testsDir = dir;
	}

	public static String getDir (String dir) {
		return testsDir;
	}


	public static ArrayList theExcludes = new ArrayList();


	public static void readFile () {

		if (testsDir == null) {
			System.out.println ("Must feed a directory to the ExcludesAdjuster class!");
			return;
		}

		BufferedReader br = null;

		String tmp = null;


		String lastTmp = null;
		

		try {

			br = new  BufferedReader (new FileReader ( testsDir + File.separator + excludesAdjustfile ));

			while ( (tmp=br.readLine()) != null) {

				if (tmp.length() <= 1)
					continue;

				if (tmp.indexOf (" ") != -1)
					tmp = tmp.replace (' ', '$');

				/// our guys get inserted at the top of the excludes
				/// so it's okay if they end with "," I guess
				tmp = tmp + ",";

				theExcludes.add (tmp);
					
			}	


		} catch (Exception e) {
			System.out.println ("No machine-based excludes");
				
			// e.printStackTrace();
		}
	}


	public static ArrayList getExcludes () {

		readFile();
		
		return theExcludes;


	}


	public static void main (String [] args) throws Exception {


		ArrayList al = getExcludes();

		for (int i=0;i<al.size();i++) { 

			System.out.println ("ex+ " + al.get(i));

		}	

	}

}
