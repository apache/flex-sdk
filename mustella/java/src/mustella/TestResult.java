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

import java.util.Date;

import java.io.File;
// import java.io.BufferedWriter;
// import java.io.CharArrayWriter;


public class TestResult { 

	public static final int PASS = 0;
	public static final int FAIL = 1;
	public static final int ERROR = 2;

	public static final int SETUP=0;
	public static final int BODY=1;
	public static final int CLEANUP=2;


	/**
	 * 
	 */
	public long elapsed;

	/**
	 * time test began
	 */
	public long startTime;

	/**
	 * pass fail status  0 = fail 1= passed
	 */
	public int result;

	/**
	 * test name
	 */
	public String testID;

	/**
	 * test's DB id (optionally populated)
	 */
	public int test_db_id;

	/**
	 * the run_id
	 */
	public int run_id = -1;


	/**
	 * scriptName
	 */
	public String scriptName;

	/**
	 * swfName
	 */
	public String swfName;

	/**
	 * message (usually on failure)
	 */
	public String message;

	/**
	 * extra data. Originally used to point to the failed bitmap
	 */
	public String fdata;

	/**
	 *   last phase hit in test
	 */
	public int phase;


	/**
	 * if you pass a string, it's assumed to be an ordered list from 
	 * a url. TestResult unpacks /populates vars
	 *  id=TNTester.m_visible_01&result=pass&msg=&elapsed=0&phase=body 
	 */
	public TestResult () { 
	}

	public TestResult (String line) { 
		unpack (line, -1);	
	}

	public TestResult (String line, int run_id) { 
		unpack (line, run_id);	
	}

	public TestResult (String script, String id, String msg, long started, int result) { 
		this.scriptName = script;
		this.testID = cleanup(id);
		this.message = msg;
		this.startTime = started;
		this.result = result;
	}


	public final String cleanup (String line) { 

		if (line==null)
			return line;

		if (line.indexOf ("'") != -1) {
			line = line.replace ('\'', ' ');
		}


		if (line.indexOf ("HTTP/1.1") != -1) { 
			line = line.substring (0, line.indexOf ("HTTP/1.1"));
		}

		if (line.startsWith ("?")) { 
			line = line.substring (1);
		}
		line = line.trim();

		return line;
	}


	private final String postProcessMsg (String s) {

		// if there's "'" in there, split on it.	
		if (s.indexOf ("^")==-1) 
			return s;

		String ret = "";

		StringBuffer sb = new StringBuffer();

		String nl0 = System.getProperty("line.separator"); 

		int loc=0,lastloc=0;

		while (true) {
			loc = s.indexOf ("^", lastloc);

			if (loc != -1) {
				ret = s.substring (lastloc, loc);
				sb.append (ret);
				sb.append (nl0);
				lastloc = loc+1;
			} else { 
				break;
			}
		}

		return sb.toString();

	}


	public final void unpack (String line, int run_id) { 


		this.run_id = run_id;

		if (line.indexOf ("'") != -1) {
			line = line.replace ('\'', ' ');
		}



		if (line.indexOf ("HTTP/1.1") != -1) { 
			line = line.substring (0, line.indexOf ("HTTP/1.1"));
		}

		String [] stuff = line.split ("&");


		String tmp = null;

		for (int i=0;i<stuff.length;i++) { 


			if (stuff[i].indexOf ("id=") != -1) { 
				this.testID = stuff[i].substring ("id=".length());
			} else if (stuff[i].indexOf ("scriptName=") != -1) { 
				if (stuff[i].startsWith ("?"))
					stuff[i] = stuff[i].substring (1);
				this.scriptName = stuff[i].substring ("scriptName=".length()).trim();
			} else if (stuff[i].indexOf ("swfName=") != -1) { 
				if (stuff[i].startsWith ("?"))
					stuff[i] = stuff[i].substring (1);
				this.swfName = stuff[i].substring ("swfName=".length()).trim();
			} else if (stuff[i].indexOf ("result=") != -1) { 
			
				tmp = stuff[i].substring ("result=".length());

				if(tmp.equals ("pass")) { 
					result = PASS;
				} else if (tmp.equals ("fail")) { 
					result = FAIL;
				} else  { 
					result = ERROR;
				}
			} else if (stuff[i].indexOf ("msg=") != -1) { 
				try { 
					this.message = postProcessMsg(stuff[i].substring ("msg=".length()));
				} catch (Exception e) { 
					this.message = "";
				}
			} else if (stuff[i].indexOf ("phase=") != -1) { 
				tmp = stuff[i].substring ("phase=".length());
				if (tmp.equals ("setup")) { 
					phase = SETUP;
				} else if (tmp.equals ("body")) { 
					phase = BODY;
				} else if (tmp.equals ("cleanup")) { 
					phase = CLEANUP;
				}
			} else if (stuff[i].indexOf ("elapsed=") != -1) { 
				tmp = stuff[i].substring ("elapsed=".length());
				if (tmp.indexOf (".")!=-1)
					elapsed = Long.parseLong (tmp.trim().substring(0, tmp.trim().indexOf (".")));
				else
					elapsed = Long.parseLong (tmp.trim());
			} else if (stuff[i].indexOf ("started=") != -1) { 
				tmp = stuff[i].substring ("started=".length());
				if (tmp.indexOf (".")!=-1)
					startTime = Long.parseLong (tmp.trim().substring(0, tmp.trim().indexOf (".")));
				else
					startTime = Long.parseLong (tmp.trim());
			} else if (stuff[i].indexOf ("extraInfo=") != -1) { 
				try { 
					fdata = stuff[i].substring ("extraInfo=".length());
				} catch (Exception e) { 
					fdata = "";
				}

			}





		}

		// AJH if (run_id != -1)
		// AJH 	test_db_id = TestCaseCache.getTestID (scriptName, testID);

	}

	public final String getResultAsString () { 

		if (result==PASS) { 
			return "Passed"; 
		} else if (result == FAIL) {
			return "Failed";
		} else if (result == ERROR) { 
			return "Error";
		}

		return null;

	}


	public static final String comma = ",";
	public static final String open_paren = "(";
	public static final String close_paren = ")";
	public static final String quote = "'";


	// test_id, time_elapsed, result, notes, test_run, time_started, fdata
	// (test_case, time_elapsed, result, notes, test_run, time_started,fdata) values (" + 
	public String getBatchInsertString() {

		return open_paren + test_db_id + comma + elapsed + comma + result + comma + quote + message + quote +  comma + run_id + comma + quote + /* AJH InsertResults.format(startTime) + */ quote + comma + quote + fdata + quote + close_paren;
	
	}


	public String toString () { 
		return scriptName + " " + testID + " " + getResultAsString() + " " + message + " " + phase + " " + new Date (startTime) + " " + (elapsed/1000D);


	}

	public String toStringLocal () { 
		return scriptName + " " + testID + " " + getResultAsString() + " " + message;

	}

	public static void main (String [] args) throws Exception { 



		/* 
		// String s  =  "?scriptName=TextArea_Styles_ScrollControlBase&id=style.backgroundImage_linked_JPG&result=fail&msg=Timeout%20waiting%20for%20complete%20from%20ta1.getChildAt%280%29&elapsed=4086&phase=setup%20started=1158603148810 HTTP/1.1";

		*/

		String s  = "scriptName=LegendEvents&id=Area_XML_Linear&result=fail&msg=Timeout&waiting for update Complete from comp&elapsed=4093&phase=body&started=1161290198430";

		TestResult tr = new TestResult (s);


		System.out.println (tr);

		String s2  =  "scriptName=gumbo/components/Wireframe/Properties/Components_tester&id=Wireframe_FxTextArea_enabled&result=fail&msg=ArgumentError: Undefined state 'normal'.";

		TestResult tr2 = new TestResult (s2);
		System.out.println (tr2);
	}
}
