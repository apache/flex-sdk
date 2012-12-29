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
import java.lang.reflect.Array;
import java.net.*;
import java.util.*;
import java.text.SimpleDateFormat;

import utils.FileUtils;


/// framework pieces in the result: the testcase has to know the name of the script that's
/// running
/// we might want to use the directory as part of the result we insert.

//// could use File.length() on the log to guess if things are still live
//// so these would launch every, say timeout period and check the log size, compare to the last size
//// the re-launch sets it back to zero

public class Runner {

	public ArrayList localResultStore  = new ArrayList();

	/**
	 * we're running in distributed mode or not
	 */
	public static boolean distributed = false;
	public static boolean pmd = false;
    	public static String run_dir = null;
    	public static int directory_result = 0;
    	public static int hostId = 0;

	/**
	 * the name of the mac player (to kill it later).
	 */
	public static String macAppName = "";

	/**
	 * the port we'll listen on for messages from the framework
	 */
	public static int port = 9999;
	public static int web_port = 80;

	/**
	 * flashlog location/name
	 */
	public static String  flashlog ;

	/**
	 * player location/reference
	 */
	public static String player = "c:/main/latest/bin/SAFlashPlayer.exe";

	/**
	 * default timeout
	 */
	public static long timeout = 30000L;

	/**
	 * default step timeout
	 */
	public static long step_timeout = 0L;

	/**
	 * player property name
	 */
	public static final String playerNameProperty = "player";

	/**
	 * test location string
	 */
	public static String testsLocation = "testsuites" + File.separator + "mustella" + File.separator + "tests";

	public static String testsLocation2 = "testsuites/mustella/tests";

	/**
	 * Browser pre-pendage
	 */
	public static String browser_prefix = "http://localhost";

	/**
	 * port property name
	 */
	public static final String portProperty = "port";

	/**
	 * log property name
	 */
	public static final String flashlogProperty = "flashlog";

	public static final String testLength = "testCaseLength";

	/**
	 * timeout property name
	 */
	public static final String timeoutProperty = "timeout";

	/**
	 * property of top level sdk testsuites dir name
	 */
	public static String mustella_dir = null;

	/**
	 * property of top level sdk testsuites dir name
	 */
	public String playerVersion = null;

	/**
	 * Adl user args
	 */
	public static String adl_extras = null;

	/**
	 * check log for ending if we time out
	 */
	public boolean doubleChecking = true;

	/**
	 * did the current swf under test show an end in the log?
	 */
	public boolean seenEnd = false;


	/**
	 * default, get results from the log. Alternative: get results sent over the wire
	 */
	static public boolean getResultsFromLog = true;


	/**
	 * the id of the run (useful for database inserts). 0 would suggest no insert.
	 */
	public static int run_id = -1;

	public static boolean useBrowser = false;
	public static String browser = "";
    	private static boolean use_apollo = false;
    	private static boolean printPasses = false;

    	private static String apollo_location = "";
    	private static String apollo_exe = "adl.exe";
    	private static String apollo_runtime_arg1 = "";
    	private static String apollo_runtime_arg2 = "";

    	static String realSwfToRun = null;
    	private static String shell_swf = null;
    	private static String shell_swf_prefix = null;
    	private static String url_suffix = null;

    	private static boolean apollo_keep = false;

	public static int baselinePort = 9998;

	public static String platform = null;
	public static boolean isSafari = false;

	public static long coverage_timeout = -1;

	/**
	 * Able to prevent the baseline server from launching.
	 */
	public static boolean prevent_baseline_server = false;


	static {


		/// reset the defaults to stuff from properties
		/// maybe we could default to something more default
		/// since the defaults tend to be convenient for me


		if ( (player = System.getProperty (playerNameProperty)) == null)
			player = "c:/main/latest/bin/SAFlashPlayer.exe";

		browser = System.getProperty ("browser");

		try {
			useBrowser = new Boolean (System.getProperty ("use_browser")).booleanValue();
		} catch (Exception e) {
			useBrowser = false;
		}

		// Parameters added to the AIR invocation in local.properties
		// e.g. adl_extras=-screensize 480x762:480x800 -profile mobileDevice -XscreenDPI 252
		try {

			adl_extras = System.getProperty ("adl_extras");

			if( adl_extras.compareToIgnoreCase("${adl_extras}") == 0 ){
				adl_extras = null;
			}
		} catch (Exception e) {
			adl_extras = null;
		}

		if (browser != null && browser.toLowerCase().indexOf ("safari") != -1)
			isSafari = true;


		/// browser_prefix stuff will be ignored for safari, where only file://
		/// goes unmangled
		try {

			browser_prefix = System.getProperty ("browser_prefix");

			// System.out.println ("Browser prepend got: " + browser_prefix);

			/// set a default
			if (browser_prefix == null || browser_prefix.length()==0)
				browser_prefix = "http://localhost";


		} catch (Exception e) {
			browser_prefix = "http://localhost";
		}


		try {
			apollo_keep = new Boolean (System.getProperty ("keep_air")).booleanValue();
		} catch (Exception e) {
			apollo_keep=false;
		}


		try {
			String tmp0 = System.getProperty ("get_results_from_log");
			if (tmp0 != null && tmp0.length() > 0)
				getResultsFromLog = new Boolean (tmp0).booleanValue();
		} catch (Exception e) {
			getResultsFromLog = false;
		}

		// System.out.println ("get results from log: "+ getResultsFromLog);

		try {
			printPasses = new Boolean (System.getProperty ("print_passes")).booleanValue();
		} catch (Exception e) {
			printPasses=true;
		}

		// Don't move this code below the prevent_baseline_server fetching.
		try {
			distributed = new Boolean (System.getProperty ("distributed")).booleanValue();
		} catch (Exception e) {
			distributed=false;
		}

		// Don't move this code below the prevent_baseline_server fetching.
		try {
			pmd = new Boolean (System.getProperty ("pmd")).booleanValue();
		} catch (Exception e) {
			pmd=false;
		}

		// Don't move this code above the distributed and pmd fetching.
		if( distributed || pmd ){
			prevent_baseline_server = true;
		}else{
			try {
				prevent_baseline_server = new Boolean( System.getProperty ("prevent_baseline_server") ).booleanValue();
			} catch (Exception e) {
				prevent_baseline_server = false;
			}
		}

		// distributed:
		try {
			run_dir = System.getProperty ("run_dir");
		} catch (Exception e) {
		}

		try {
			coverage_timeout = Long.parseLong (System.getProperty ("coverage_timeout"));
		} catch (Exception e) {
			coverage_timeout = -1;
		}

		try {
			hostId = Integer.parseInt (System.getProperty ("hostId"));
		} catch (Exception e) {
			hostId=1;
		}

		// url suffix
		try {
			url_suffix = System.getProperty ("url_suffix");

			if (url_suffix.startsWith ("${")) {
				url_suffix = null;
			} else if (!url_suffix.startsWith ("?")) {
				url_suffix = "?" + url_suffix;
			}
		} catch (Exception e) {
		}


		try {
			port = Integer.parseInt (System.getProperty (portProperty));
			// System.out.println ("Serving will be at port: " + port);
		} catch (Exception e) {
			port = 9999;
		}



		try {
			baselinePort = Integer.parseInt (System.getProperty ("baseline_port"));
			// System.out.println ("Baseline serving will be at port: " + baselinePort);
		} catch (Exception e) {
			baselinePort = 9998;
		}

		try {
			timeout = Long.parseLong (System.getProperty (timeoutProperty));
			if (timeout < 1000)
				timeout = timeout*1000;
		} catch (Exception e) {
			timeout = 30000L;
		}

		try {
			step_timeout = Long.parseLong (System.getProperty ("step_timeout"));
			if (step_timeout < 1000)
				step_timeout = step_timeout*1000;
		} catch (Exception e) {
			step_timeout = 0L;
		}

		if ( (flashlog = System.getProperty (flashlogProperty)) == null)

		if ( (flashlog = System.getProperty (flashlogProperty)) == null)
			flashlog = "c:/flashlogZADM.txt";

		try {
			use_apollo = new Boolean (System.getProperty ("use_apollo")).booleanValue();
			// System.out.println ("use_apollo: " + use_apollo);
		} catch (Exception e) {
		}


		try {
			apollo_location = System.getProperty ("apollo_location");
			// System.out.println ("apollo: " + apollo_location);

		} catch (Exception e) {
		}

		try {
			shell_swf = System.getProperty ("shell_swf");

			if (shell_swf != null && shell_swf.length() == 0)
				shell_swf = null;

		} catch (Exception e) {

		}

		try {
			shell_swf_prefix = System.getProperty ("shell_swf_prefix");
			if (shell_swf_prefix == null || shell_swf_prefix.length() == 0)
				shell_swf_prefix = "file:///";

		} catch (Exception e) {
			shell_swf_prefix = "file:///";
		}


		try {
			mustella_dir = System.getProperty ("mustella.dir");

		} catch (Exception e) {
		}

		try {

			if (System.getProperty ("apollo_exe") != null)
				apollo_exe = System.getProperty ("apollo_exe");


		} catch (Exception e) {
		}




		if (useBrowser)
			player = browser;

		String os = System.getProperty ("os.name");
		platform = "";
		if (os.indexOf ("Windows") != -1) {
			platform = "win";
		} else if (os.indexOf ("Mac") != -1) {
			platform = "mac";
		}


		/// apollo setting up
		if (use_apollo && apollo_location != null && !apollo_location.equals("")) {
			player = apollo_location + File.separator + "bin" + File.separator + apollo_exe;
			player = normalizeDirOS (player, false);

			apollo_runtime_arg1 = "-runtime";
			apollo_runtime_arg2 = apollo_location + File.separator + "runtimes/air/" + platform;
			apollo_runtime_arg2 = FileUtils.normalizeDirOS (apollo_runtime_arg2);


			System.out.println ("the apollo situation: " + apollo_location + "/" + apollo_exe + " "  + apollo_runtime_arg1 + " " + apollo_runtime_arg2);
		}

		/// something to kill the mac beast
		// System.out.println ("Player, browser in static: " + player + " " + browser);
		if (player.indexOf (File.separator)!=-1)
			macAppName = player.substring (player.lastIndexOf(File.separator)+1);
		else
			macAppName = player;

	}


	/// hmmmmm
	public static boolean exitOnLoopEnd = false;

	public static boolean okayToExit = false;


	public static int exitWith = 0;


	/**
	 *
	 * consts for communicating with the test framework
	 *
	 */

	/**
	 * Standard response to anything the framework sends.
	 */
	public static final String stockResponse = "HTTP/1.1 200 OK\r\n\r\n";

	/**
	 * a heartbeat.
	 */
	public static final String heartBeat  = "testCaseStillRunning";

	/**
	 * Script Complete indication. This means it's time to go on to the next test swf
	 */
	public static final String scriptDone  = "ScriptComplete";

	/**
	 * Test begin. useful to know a testcase has begun (esp. if it times out).
	 */
	public static final String testStart  = "testCaseStart";

	/**
	 * Test result. These will be inserted to a database if a flag says so
	 */
	public static final String testResult  = "testCaseResult";

	/**
	 * get ammended timeout
	 */
	public static final String stepTimeout  = "step_timeout";

	/**
	/**
	 * Test swf request. in the shell case, we need to know what file to load
	 */
	public static final String nextTestSwf = "nextSwf";

	/**
	 * the value of the insert results flag to look for
	 */
	public static final String insertResultsProperty = "insert_results";

	/**
	 * Insert the results into the database, or not.
	 */
	public static boolean doTheInsert = true;


	public Hashtable timersOff = new Hashtable();
	public Hashtable logTimersOff = new Hashtable();
	public Hashtable metatimersOff = new Hashtable();

	public long lastHello = System.currentTimeMillis();

	public SimpleDateFormat sdf = new SimpleDateFormat ("HH:mm:ss.SSS");



	private String currentArg = null;
	public int current_iterator = 0;


	static int localwirePort = 5566;

	private static final String theGet = "GET\r\n";


	public static String getSwfOverWire() {

		System.out.println ("In the getSwfOverWire call");

		String line = null;

		try {

			Socket s = new Socket ("localhost", localwirePort);

			BufferedOutputStream bos = new BufferedOutputStream (s.getOutputStream());

			bos.write (theGet.getBytes(), 0, theGet.length());
			bos.flush();


			BufferedReader bis = null;

			bis = new BufferedReader (new InputStreamReader(s.getInputStream()));

			while ( (line=bis.readLine()) != null) {
				System.out.println ("return: "+ line);
				break;
			}

			bos.close();
			bis.close();



		} catch (Exception e) {

			e.printStackTrace();

		}

		return line;

	}


	/**
	 * Constructor
	 *
	 * drives the test.
	 */
	public Runner (String [] args) throws Exception {

		if (!getResultsFromLog || shell_swf != null || useBrowser || step_timeout > 0)
			startLocalServer();


		if(prevent_baseline_server){
			System.out.println("not starting baseline server");
		}else{
			System.out.println("starting baseline server");
			startBaselineServer();
		}

		// NYI if (!pmd)
		// 	startWebServer();

		// figure out where the flashlog is.
		flashlog = getLogSource();

		/// clobber any old logs, just to be tidy
		new File(flashlog).delete();




		/// if we needed to pre-process the list, now's the time.


		System.out.println ("test script count: " + args.length);


		/*
		InsertMilestone im1 = null;
		DistributedMilestone dins1 = null;
		if (!distributed && !pmd) {
			im1 = new InsertMilestone (run_id, "run_start", System.currentTimeMillis());
		} else if (!pmd) {
			dins1 = new DistributedMilestone (1, run_id, run_dir, -1, System.currentTimeMillis(), hostId);
		}

		if (run_id != -1 && doTheInsert)
			TestCaseCache.populateTestCases();
		*/
		
		if (pmd)
			args = new String[1];

		/// kick off a thread to run,
		for (int i=0;i<args.length;i++) {
			////

			// System.out.println ("in the RUNNER loop");
			if (pmd) {
				i=0;
				args[0]=getSwfOverWire();
				if (args[0] == null || args[0].length()==0 || args[0].equals("DONE"))
					break;
			}

			// System.out.println ("RUNNER HAS THIS TO DO: " + args[0]);


			seenEnd = false;
			current_iterator = i;


			currentArg = args[i];

			if (useBrowser && !isSafari)
				baselineServer.setDir (extractDir (currentArg));

			// Thread.sleep (100);



			// let's not bother with this one anymore

			if (currentArg.endsWith (".swf")) {
				if (server.inputHandler != null && server.inputHandler.inWaitLoop)
				{
					server.inputHandler.abortWaitLoop = true;
					while (server.inputHandler.inWaitLoop)
					{
						Thread.sleep (10);
					}					
				}
				startedCases.clear();
				doexec (currentArg);
			}
			else {
				System.out.println ("Skipping: " + currentArg);
				continue;
			}

			/// wait for it to finish
			while (!currentExec.isDone()) {

				System.out.println ("main loop, in the wait");
				Thread.sleep (30);
			}
			// System.out.println ("execer: apparently done with " + currentArg + " at: " + new Date());

			killAllTimers();
			killMetaTimer();
			killLogTimer();

			/// the mess here is that the log copy will always be the same for shell_
			if (getResultsFromLog)
				grabLog (currentArg, true);
			else
				grabLog (currentArg, false);

                        if (new File(mustella_dir + File.separator + "testing.halt").exists()) {
                		System.out.println("SAW SHUTDOWN NOTIFICATION, halting run at " + new Date());
                		break;
            		}

			// Thread.sleep (500);
			if (pmd)
				i--;

		}


		System.out.println ("at the end of main");

		/*
		InsertMilestone im2 = null;
		DistributedMilestone dins2 = null;
		if (!distributed && !pmd) {
			im2 = new InsertMilestone (run_id, "run_end", System.currentTimeMillis());
		} else if (!pmd) {
			dins2 = new DistributedMilestone (1, run_id, run_dir, directory_result, System.currentTimeMillis(), hostId);
		}
		*/
		
		/// waiting for any stragglers to report.
		int finalCount = 0;

		if (!threads.isEmpty()) {

		 Thread t = null;

			for (int i=0;i<threads.size();i++) {
		 		try {
					t = (Thread) threads.get(i);
					t.join(60000);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

		}

		/*
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
		
		stopLocalServer();

		if (!distributed)
			stopBaselineServer();

		stopWebServer();

		System.out.println ("done waiting for results...bye");

		if (!doTheInsert) {
			printResultsLocally();
		}


		if (exitOnLoopEnd)
			System.exit(0);

	}


	public static String extractDir (String swf) {


		/// get rid of trailing file & directory

		String tmp1 = swf.substring(0, swf.lastIndexOf (File.separator));

		if (tmp1.indexOf ("swfs") != -1 || tmp1.indexOf ("SWFs") != -1) {
			return tmp1.substring (0, tmp1.length ()-5);
		}


		return tmp1;


	}


	String currentSwf = null;

	/**
	 * copy log from flashlog to swfname.log
	 */
	public final void grabLog (String sourceName) {
		grabLog (sourceName, true);
	}

	public final void grabLog (String sourceName, boolean doParse) {


		if (flashlog == null) {
			System.out.println ("no log specified, no grab of log");
			return;
		}

		System.out.println ("Grab log, do parse = " + doParse);

		currentSwf = sourceName.substring (sourceName.lastIndexOf (File.separator)+1);

		// BufferedInputStream br = null;
		BufferedReader br = null;
		BufferedWriter bw = null;
		// BufferedOutputStream bw = null;


		// String copyFrom= getLogSource();
		String outName = transformName(sourceName);

		/*
		try {

		if (new File(outName).exists()) {
			outName = outName +".1";
		}
		} catch (Exception e) {
			outName = outName +".1";
		}
		*/


		System.out.println ("Grabbing the log from: "  + flashlog + " to: " + outName);


		int avail = 0;

		String line = null;

		byte [] b = null;

		String userName = System.getProperties().getProperty ("user.name");

		try {


			br = new BufferedReader (new FileReader(flashlog));
			bw = new BufferedWriter (new FileWriter (outName));

			while ( (line = br.readLine()) != null) {

				// System.out.println ("log line: " + line);
				if (line.length() <= 1) {
					continue;
				}

				if (getResultsFromLog && doParse)  {
					parseResult (line);
				} else {
					if (line.startsWith("ScriptComplete:"))
						seenEnd = true;
				}
				bw.write (line, 0, line.length());
				bw.newLine();

			}


			// throw the name in the log.
			bw.write (userName, 0, userName.length());

			bw.flush();
			br.close();
			bw.close();


			try {


				String [] fixit= new String[]{"chmod", "777", outName};
				Runtime.getRuntime().exec (fixit);


			} catch (Exception e) {
				e.printStackTrace();
			}

			if (!seenEnd) {
				System.out.println ("Grablog: never saw the ScriptDone for " + currentArg);

				// was:
				if (doParse)
				 	unpackResult (currentArg, "Timed out");



				/** broken
				TestResult tr = null;
				if (lastTestFile != null && lastTestCase != null && !lastTestCase.equals(lastTestCaseResult)) {
					tr = new TestResult (lastTestFile, lastTestCase, "Timed out on or after this case", (System.currentTimeMillis()-timeout), 1);
					System.out.println ("FABRICATED RESULT FOR: " + lastTestFile + " " + lastTestCase);
					tr.run_id = run_id;

					System.out.println ("LOGIC CHECK:" );
					System.out.println ("run_id != -1: " + (run_id != -1));
					System.out.println ("doTheInsert: " + doTheInsert);
					System.out.println ("tr.test_db_id != -1: " + (tr.test_db_id != -1)) ;

					if (run_id != -1 && doTheInsert && tr.test_db_id != -1) {
						batchedResults.add (tr.getBatchInsertString());
					} else {
						if (run_id != -1 && doTheInsert) {
							/// it must have been an orphan
							InsertResults insertResults = new InsertResults (run_id, tr);
							threads.add (insertResults);
						} else if (!doTheInsert) {
							// not an insert
							storeResultLocally (tr);
						}
					}
				} else
				 	unpackResult (currentArg, "Timed out, no cases ran");
				*/


			}


		} catch (Exception e) {

			System.out.println ("TROUBLE on the log copy.");

			if (e.getLocalizedMessage() != null)
				System.out.println(e.getLocalizedMessage());
			
			/// if we're depending on the log, note that we're bailing here
			if (getResultsFromLog)
				unpackResult (sourceName, "Missing Results");


			try {
				br.close();
			} catch (Exception e2) {
				System.out.println ("trouble on the cleanup (1) for the log copy.");
			}

			try {
				bw.close();
			} catch (Exception e2) {
				System.out.println ("trouble on the cleanup (2) for the log copy.");
			}


		}

		/*
		/// okay, by now, we're done parsing the log. Finish the insert if it's batched
		if (run_id != -1 && doTheInsert && batchedResults.size() > 0) {
			InsertBatchedResults ibr = new InsertBatchedResults(batchedResults);
			threads.add (ibr);
		}
		*/




	}

	public static ArrayList threads = new ArrayList();


	private int numResults = 0;



	String lastTestFile = null;
	String lastTestCase = null;

	String lastTestFileResult = null;
	String lastTestCaseResult = null;


	ArrayList batchedResults= new ArrayList();

	public void parseResult (String s) {

		       if (s.startsWith("RESULT: ")) {

                               	numResults++;
                               	String result = s.substring("RESULT: ".length());
				TestResult tr = new TestResult (result, run_id);

				lastTestFileResult = tr.scriptName;
				lastTestCaseResult = tr.testID;

				/// if we have an orphan, be wary
				/// WHAT ABOUT THE COMMAS?
				if (run_id != -1 && doTheInsert && tr.test_db_id != -1) {
					batchedResults.add (tr.getBatchInsertString());
				} else {
					if (run_id != -1 && doTheInsert) {
						/// it must have been an orphan
						// AJH InsertResults insertResults = new InsertResults (run_id, tr);
						// threads.add (insertResults);
					} else if (!doTheInsert) {
						// not an insert
						storeResultLocally (tr);
					}
				}


                       }
                       else if (s.startsWith("TestCase Start:"))
                       {
				lastTestFile = s.substring (s.indexOf ("Start:")+7, s.indexOf ("$"));
				lastTestCase = s.substring (s.indexOf ("$")+1);
                       }
                       else if (s.startsWith("requesting url:"))
                       {
                       }
                       else if (s.startsWith("testComplete"))
                       {
                       }
                       else if (s.startsWith("ScriptComplete:"))
                       {
				seenEnd = true;
				if (!getResultsFromLog) {
					if (numResults != resultCount  ) {
					System.out.println ("NOTE: inconsistent result count: log: " + numResults + " vs. runner: " + resultCount + " for " + currentSwf);
					} else {
						System.out.println ("consistent result count: log: " + numResults + " vs. runner: " + resultCount + " for " + currentSwf);
					}
				}
				numResults = 0;
				resultCount = 0;
                       }
                       else if (s.startsWith("Paused for"))
                       {
                       }
                       else if (s.startsWith("Warning:"))
                       {
                       }
                       else if (s.startsWith("LengthOfTestcases:"))
                       {
                       }
                       else
                       {
                               // passed = false;
                       }


	}


	private static final String winDir = "Application Data";
	private static final String win7Dir = "AppData/Roaming";
	private static final String macEnd = "Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt";
	private static final String linuxEnd = ".macromedia/Flash_Player/Logs/flashlog.txt";
	private static final String winEnd = "Macromedia/Flash Player/Logs/flashlog.txt";



	private static String getLogSource() {

		String start= System.getProperties ().getProperty ("user.home");
		String ret = null;

		String tmp = null;
		String os = System.getProperties ().getProperty ("os.name");

		/// need testing of the mac & Linux parts of this.
		// Just guessing that "Windows Vista" is the correct string for Vista.

		// On Windows 7 the value of user.home is the registry key
		// "[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Desktop]"
		// with the last directory stripped.

		if (os.indexOf ("Windows 7") != -1 || os.indexOf ("Windows Vista") != -1) {
			ret = start + File.separator + win7Dir + File.separator + winEnd;
		} else if (os.indexOf ("Windows") !=  -1) {
			ret = start + File.separator + winDir + File.separator + winEnd;
		} else if (os.indexOf ("Linux") !=  -1) {
			ret = start + File.separator + linuxEnd;
		} else if (os.indexOf ("Mac") !=  -1) {
			ret = start + File.separator + macEnd;
		}


		return ret;



	}


	public static String transformName (String source) {



		if (source.indexOf (".swf") != -1)
			source = source.substring (0, source.indexOf (".swf"));


		if (run_id != -1)
			return source + "." + run_id + ".log";
		else
			return source  + ".log";




	}


    	public static String normalizeDirOS(String dir, boolean apollo_adjust) {
       		if (dir==null) dir=".";
       	 	try {
            		dir=new File(dir).getCanonicalPath();
        	} catch (IOException e) {
        	}
        	dir=dir.replace('\\',File.separatorChar);
        	dir=dir.replace('/',File.separatorChar);
        	if (dir.endsWith("/" ) || dir.endsWith("\\")) {
            		dir=dir.substring(0,dir.length()-1);
        	}

		/// adjust for apollo
		if (apollo_adjust && dir.endsWith (".swf")) {
			dir = ApolloAdjuster.xmlWriter (dir, !apollo_keep);
			System.out.println ("post ApolloAdjuster: " + dir);
			// dir = dir.substring (0, dir.indexOf (".swf")) + ".xml";
		}
        	return dir;
    	}


	/**
	 * the currently running Execer object, which drives the player
	 */
	Execer currentExec = null;


	/**
	 * launch the Execer
	 */
	public void doexec (String filename) throws Exception {


		String test_file = normalizeDirOS( new File(filename).getPath(), use_apollo );

		if (url_suffix != null && !test_file.endsWith(".xml") ) {
			test_file = test_file + url_suffix;
		}



		/// okay, if it's a shell_swf, we need to run that, but note the test_file
		if (shell_swf != null) {
			SwfLoaderTestAdapter slw = new SwfLoaderTestAdapter (test_file, shell_swf);
			realSwfToRun = test_file;
			test_file = shell_swf;
		} else {
			realSwfToRun = null;
		}


		System.out.println ("new test file: " + test_file);

		if (useBrowser) {
			HtmlTestAdapter slw = new HtmlTestAdapter (test_file, shell_swf);
			if (isSafari)
				test_file = fixForSafari(test_file);
			else
				test_file = fixForBrowser(test_file);
		}

		testcaseCount = 0;
		finishedCount = 0;

		/// build the run array.

		ArrayList al = new ArrayList();

		al.add (player);
		al.add (test_file);

		// get extra parameters

		ArrayList moreParameters = new ArrayList();

		StringTokenizer tokbit = null;
		if (use_apollo && adl_extras != null) {
			tokbit = new StringTokenizer (adl_extras, " ");

			while (tokbit.hasMoreTokens()) {
				moreParameters.add (tokbit.nextToken());
			}

		}

		String [] runArgs = new String[al.size()];
		runArgs = (String[]) al.toArray((String[])runArgs);


		currentExec = new Execer(runArgs, realSwfToRun, moreParameters);


		while (!currentExec.isDone()) {
			Thread.sleep (50);
		}


		try {
		if (ApolloAdjuster.didWrite() && !apollo_keep) {
			ApolloAdjuster.delete ();
		}
		} catch (Exception e) {

			e.printStackTrace();

		}


	}

	public String fixForSafari(String f) {

		int loc = -1;

		/// part 1: make it html.
		if  ( (loc = f.indexOf (".swf")) != -1)
			f = f.substring (0, loc) + ".html";

		if (1==1)
			return f;

		/// clobber other stuff:
		if (f.indexOf ("sdk/testsuites/mustella") != -1) {
			System.out.println ("adjusted: " + f.substring(f.indexOf ("sdk/testsuites/mustella")+23));
			return f.substring(f.indexOf ("sdk/testsuites/mustella")+23);

		}

		return f;
	}

	public String fixForBrowser(String f) {


		int loc = -1;

		/// part 1: make it html.
		if  ( (loc = f.indexOf (".swf")) != -1)
			f = f.substring (0, loc) + ".html";

		// part2: snip off the location part and prepend http and the server

		String pattern = "\\";

		// Slashes may be one way or
		if ( (loc = f.indexOf (testsLocation)) != -1) {
			f = f.substring (loc+testsLocation.length());
			f = browser_prefix + f;
			f = f.replace ('\\', '/');
		// another, so, make sure we clip it.
		} else if ( (loc = f.indexOf (testsLocation2)) != -1) {
			f = f.substring (loc+testsLocation2.length());
			f = browser_prefix + f;
			f = f.replace ('\\', '/');
		} else {
			// System.out.println ("no fix for browser applied");
		}


		System.out.println ("Final for browser: " + f);



		return f;


	}


	public class Ender extends Thread {

		Execer execer = null;
		// long timeout =

		long started = 0;

		public Ender (Execer e) {
			this.execer = e;

			started = System.currentTimeMillis();

		}


		public void run() {

			while ( (finishedCount < testcaseCount) && (System.currentTimeMillis() - started) < timeout) {
				try { Thread.sleep(50); } catch (Exception e) { ; }

				System.out.println ("finished, count: "+ finishedCount + " " + testcaseCount + " " + new Date());

			}


			System.out.println ("Out of the Ender loop, calling setDone");
			/// we made it out, so, set testcaseCount to -1?
			System.out.println ("Ender actual finished count, testcase count: " + finishedCount + " " + testcaseCount);
			// we either timed out or finished.


			/// a guess
			// execer.setDone(false);
			execer.clobberProcess(false);


		}

	}

	public long STARTED = 0;

	public String[] lastLastCmd = null;


	public boolean beWatchingOutput = false;

	/**
	 * Added for the apollo case, which wasn't cleaning up well.
	 * if it exits immediately, notice that and retry. The retry
	 * succeeds, usually.
	 * only retry once.
	 * it's a little confusing
	*/
	public class WatchProcess extends Thread {

		// TrollProcess tp= null;

		public WatchProcess () {


			beWatchingOutput = true;
			new TrollProcess ().start();


		}

		public void run () {
			while (true) {
				try {
					/// this throws when the process is active
					currentExec.p.waitFor();
					// so if we got this far, the process is exited
					// if it did so really quickly, it was probably a
					// bogus crash, and we can retry
					if ( (System.currentTimeMillis() - STARTED) < 450) {
						/// re do it if not redone already
						if (lastCmd != lastLastCmd) {
							System.out.println ("Exited!!!! elapsed was fast, wil retry: " + (System.currentTimeMillis() - STARTED));
							lastLastCmd = lastCmd;
							currentExec = new Execer(lastCmd, (String)null, null);
							beWatchingOutput=false;
							return;
						} else {

							System.out.println ("Already retried this stuff. exiting");
							currentExec.setDone (true);
							return;
						}
					} else  {
						// bust out, it was a later exit
						break;
					}

				} catch (Exception e) {
					try { Thread.sleep (250); } catch (Exception e0) { }
				}
			}

			/// this is the ordinary exit case.
			/// it this already got called, it's okay
			if (!currentExec.isDone()) {
				beWatchingOutput=false;
				currentExec.setDone (false);
			}

		}


	}

	/**
	 * another helper: read stdout/stderr that AIR spews. Was filling some buffer
	 * making Java unhappy.
	 */
	public class TrollProcess extends Thread {

		public TrollProcess() {
		}


		public void run() {


			BufferedInputStream bos = new BufferedInputStream (currentExec.p.getInputStream());
			BufferedInputStream bos2 = new BufferedInputStream (currentExec.p.getErrorStream());

			int tmpi = 0;
			byte [] b = null;


			ByteArrayOutputStream baso = null;

		       	while (beWatchingOutput) {

				try {

                                	while ( (tmpi=bos.available()) > 0){
                                       	 b = new byte[tmpi];
                                       	 bos.read (b, 0, tmpi);
                                	}

                                	while ( (tmpi=bos2.available()) > 0){
                                       	 b = new byte[tmpi];
                                       	 bos2.read (b, 0, tmpi);
                                	}


                                	Thread.sleep (125);
				} catch (Exception ee) {

				}

                        }

			try {
				bos.close();
				bos2.close();

			} catch (Exception e)  {

                	}
		}

	}


	String [] lastCmd = null;

	/**
 	 * Execer class. Given some command array, it Execs that
	 */
	public class Execer extends Thread {



		String [] cmd = null;


		public Process p  = null;


		String swfFile = null;


		String dir = null;


		public Execer(String [] cmdArr, String filename, ArrayList moreParameters) throws Exception {

			int i = 0;

			if (cmdArr.length == 3) {
				swfFile = cmdArr[2];
			} else if (cmdArr.length > 3) {
				swfFile = cmdArr[3];
			} else {
				swfFile = cmdArr[1];
			}


			// debugging
			/**
			**/
			System.out.println("******** cmdArr before: ");
			for( i = 0; i < Array.getLength( cmdArr ); ++i ){
				System.out.println( "\t" + cmdArr[ i ] );
			}
			System.out.println("******** moreParameters before: ");
			for( i = 0; i < moreParameters.size(); ++i ){
				System.out.println( "\t" + moreParameters.get( i ) );
			}

			if( moreParameters != null ){

				ArrayList allCommands = new ArrayList();

				for( i = 0; i < Array.getLength( cmdArr ); ++i ){
					allCommands.add( cmdArr[ i ] );
				}

				allCommands.addAll( moreParameters );

				cmdArr = new String[ allCommands.size() ];

				for( i = 0; i < allCommands.size(); ++i ){
					cmdArr[ i ] = (String) allCommands.get( i );
				}
			}

			// debugging
			/**
			**/
			System.out.println("******** cmdArr after: ");
			for( i = 0; i < Array.getLength( cmdArr ); ++i ){
				System.out.println( "\t" + cmdArr[ i ] );
			}

			this.cmd = cmdArr;
			lastCmd = cmdArr;

			/// launch shell swf vs. not
			if (filename == null) {
				System.out.println ("getting directory from the swf file");
				dir = new File(swfFile).getPath();
				dir = dir.substring (0, dir.lastIndexOf (File.separator));
				System.out.println ("derived directory: " + dir);

			} else {
				/// another try:
				/// copy the file from the
				System.out.println ("getting directory from passed file");
				dir = new File(filename).getPath();
				dir = dir.substring (0, dir.lastIndexOf (File.separator));
				System.out.println ("derived directory: " + dir);
				System.out.println ("swf to run: " + swfFile);

			}


			if (getResultsFromLog)
				processed = false;

			this.start();

		}


		public void addTimedoutResult() {
			System.out.println ("NYI add timed out result");
		}


		public boolean processed = true;

		public boolean isProcessed () {
			return processed;
		}


		public Process getProcess () {
			return p;
		}


		public boolean isDone () {
			return !running;
		}

		public void setDone () {
			setDone(false);
		}

		boolean beenHere = false;
		boolean beenHereTimeout = false;

		public synchronized void setDone (boolean timedOut) {

			if (beenHere) {
				System.out.println ("hello from setDone, but we've been here, bye");
				return;
			}

			if (!running) {
				System.out.println ("hello from setDone, I think things are DONE");
			}


			beenHere = true;


			int tries = 0;


			// System.out.println ("hello from setDone, timeout? " + timedOut);

			/// reset our status to not running
			/// running=false;

			clobberProcess (timedOut);


		}


		public void clobberProcess (boolean timedOut) {

			System.out.println ("clobberProcess " + timedOut);
			if (!timedOut)
			{
				int wait = 0;
				while (wait < 5000 && p != null)
				{
					try { Thread.sleep (100);
					}catch (Exception e)  {}
					wait += 100;
				}
				System.out.println ("waited " + wait);
			}
			if (p != null) {

				if (coverage_timeout > 0) {

					try { Thread.sleep (coverage_timeout);
					} catch (Exception e)  {}

				}

				try {
					System.out.println ("ClobberProcess, destroying process");
					p.destroy();
				} catch (Exception e)
					{ System.out.println("attempt to destroy process failed, but could be natural ending"); e.printStackTrace();
				}
			} else
				 System.out.println ("ClobberProcess, it was already null");
			// running = false;

			if (getResultsFromLog)
				return;

			if (timedOut) {
				// killTimer();
				killMetaTimer();
				killAllTimers();
				/// double check here
				unpackResult (swfFile, "Timed out");
			} else {
				/// not sure
				killAllTimers();
				killMetaTimer();
				// killTimer();

			}
			running = false;
		}



		boolean running = true;

		public void run () {

			/// may want to add
			lastUpdate = System.currentTimeMillis();

			try {


				System.out.println ("Launching: " );
				for (int i=0;i<cmd.length;i++) {
				System.out.print (" "  + cmd[i]);
				}
				System.out.println (" Launching: " + cmd[0] + " " + cmd[1]);
				System.out.println ("USING directory: " + this.dir);
				System.out.println ("time: " + sdf.format(new Date()));
				//// can we re-set that?
				/// do the actual exec.

				///flags:
				String [] whatever = {""};
				lastTestCaseStart = "";
				seenEnd = false;

				if(!getResultsFromLog)
					manageMetaTimer("process start");
				else
					manageLogBasedTimer (currentArg);
				// Probably okay to leave this in for a stray timer, though unlikely
				// for there to be one.
				killAllTimers();
				if (useBrowser)
					p = Runtime.getRuntime().exec (cmd, (String[])null, (File)null);
				else {
					p = Runtime.getRuntime().exec (cmd, (String[])null, new File(this.dir));
					if (use_apollo) {
						STARTED = System.currentTimeMillis();
						// new WatchProcess ().start();
					}
				}

			} catch (Exception e) {
				e.printStackTrace ();
			}

			/// this will lock us up
			try {
				// System.out.println ("waitfor at " + sdf.format(new Date()));
				p.waitFor();
				// System.out.println ("After the waitFor: " + sdf.format(new Date()));
			} catch (Exception e) {
				e.printStackTrace();
			}

			p = null;
			
			/// if we got here, it's done
			running = false;
			System.out.println ("Total Results so far: " + localResultStore.size());
			
		}

	}





	/**
	 * Server object
	 */
	public LocalListener server = null;


	public void cleanup() throws Exception {
		server.end();
	}

	public void stopBaselineServer () throws Exception {
		if (baselineServer!=null) {
			System.out.println ("shutting down the baseline server");
			baselineServer.end();
			baselineServer.destroy();
		}

	}

	public void stopWebServer () {

		if (webserver != null)
			webserver.stop();
	}


	public void stopLocalServer () throws Exception {
		if (server!=null) {
			System.out.println ("Shutting down the results server");

			server.end();
			server.destroy();
		}
	}


	private BaselineServer baselineServer = null;


	private NanoHTTPD webserver = null;



	public void startBaselineServer () throws Exception {

		// System.out.println ("starting baseline server");
		baselineServer = new BaselineServer(baselinePort);
		baselineServer.start();

	}

	public void startWebServer() throws Exception {

		/// okay for this to fail if the machine has another server doing the
		// right thing. Fail quietly, gracefully
		webserver.setRoot (mustella_dir);
		webserver = new NanoHTTPD (web_port);

	}


	public void startLocalServer () throws Exception {

		System.out.println ("starting results server");
		server = new LocalListener ();
		server.start();

	}


	public static ArrayList startedCases = new ArrayList();
	public static ArrayList finishedCases = new ArrayList();

	/**
	 * takes a result line and breaks into pieces.
	 */
	public void unpackStart(String line) {
		/// read/insert

		String detail = URLDecoder.decode (line);

		detail= detail.substring (detail.indexOf ("?"));
		String tcStart = null;
		if (detail.indexOf (" HTTP") != -1)
			tcStart = detail.substring(1, detail.indexOf(" HTTP"));
		else
			tcStart = detail.substring(1);

		manageTimer (detail.substring(1));
		startedCases.add (tcStart);
		lastTestCaseStartTime = System.currentTimeMillis();
		lastTestCaseStart = tcStart;

		// System.out.println ("start test: " + lastTestCaseStart.substring (0, lastTestCaseStart.indexOf (" ")));


	}


	/**
	 * count cases started and cases finished, remove the starts with matching finishes
	 */
	public static int balanceAccounts (int excluded) {

		int missCount = 0;

		Object o = null;

		for (int i=0;i<finishedCases.size();i++) {


			try {
			o = startedCases.remove (startedCases.indexOf((String)finishedCases.get(i)));
			if (o==null)
				missCount++;
			} catch (Exception e) {
				missCount++;
			}

		}

		// System.out.println ("BA: started, excluded: " + startedCases.size() + " "+ excluded);
		for (int i=0;i<startedCases.size();i++) {
			try {
				System.out.println((String)startedCases.get(i) + " not finished yet");
			} catch (Exception e) {
			}
		}
		


		return (startedCases.size() - excluded);


	}


	// InsertResults insertResults = null;


	public int resultCount = 0;


	/**
	 * takes a result line and breaks into pieces.
	 */
	public final synchronized void unpackResult(String line) {
		/// read/insert

		String detail = null;
		try {
			detail = URLDecoder.decode (line);
		} catch (Exception e) {
			System.out.println ("Exception decoding result URL. You may see messy results");
			detail = line;
		}

		detail= detail.substring (detail.indexOf ("?"));

		TestResult tr = new TestResult (detail);

		resultCount++;


		killTimer (tr.scriptName + "$" + tr.testID);

		/// should have a manageMetaTimer here, no?
		manageMetaTimer  (tr.scriptName + "$" + tr.testID);

		finishedCases.add (tr.scriptName + "$" + tr.testID);

		if (run_id != -1 && doTheInsert) {
			// AJH InsertResults insertResults = new InsertResults (run_id, tr);
			// threads.add (insertResults);
		} else if (!doTheInsert) {
			storeResultLocally (tr);
		}


		if (tr.result == 1)
			System.out.println ("FAIL: " + tr.scriptName + " " + tr.testID);

		if (tr.result == 1 && distributed)
			directory_result = 1;
	}



	public void storeResultLocally (TestResult tr) {
		// System.out.println ("hello from store result locally with : " + tr);
		localResultStore.add (tr);
	}


	public void printResultsLocally () {


		// System.out.println ("printLocal, length: "+ localResultStore.size());

		TestResult tr = null;

		StringBuffer sb = new StringBuffer();

		StringBuffer sb_write = new StringBuffer();

		int passes = 0;
		int fails = 0;
		int other = 0;

		String summary = "=====================================================";


		sb.append (summary);
		sb.append ("\n");

		if (printPasses) {

			sb.append (summary);
			sb.append ("\n");
			sb.append ("\tPassed: \n");
			sb.append (summary);
			sb.append ("\n");

		}
		for (int i=0;i<localResultStore.size();i++) {

			tr = (TestResult) localResultStore.get (i);
			if (tr.result == 0 )  {
				passes++;
				if (printPasses) {
					sb.append (tr.toStringLocal());
					sb.append ("\n");
				}
			}
		}


		sb.append (summary);
		sb.append ("\n");
		sb.append ("\tFailed: \n");
		sb.append (summary);
		sb.append ("\n");
		for (int i=0;i<localResultStore.size();i++) {
			tr = (TestResult) localResultStore.get (i);
			if (tr.result == 1) {
				fails++;
				sb.append (tr.toStringLocal());
				sb.append ("\n");
				sb_write.append (tr.scriptName +" " +tr.testID);
				sb_write.append ("\n");
			}

		}

		String summary1 = "    Passes: " + passes;
		String summary2 = "    Fails: " +  fails;

		StringBuffer sb2 = new StringBuffer();
		sb2.append (summary);
		sb2.append ("\n");
		sb2.append (summary1);
		sb2.append ("\n");
		sb2.append (summary2);
		sb2.append ("\n");
		sb2.append (summary);
		sb2.append ("\n");
		sb2.append ("\n");


		sb.insert (0, sb2.toString());
		sb.append ("\n\n");
		sb.append (sb2.toString());

		System.out.println ( sb.toString());


		try {
			BufferedWriter  bw = new BufferedWriter (new FileWriter ("results.txt"));
			bw.write (sb.toString(), 0, sb.length());
			bw.flush();
			bw.close();
			System.out.println ( "Wrote summary to results.txt");

		} catch (Exception e) {
			e.printStackTrace();
		}

		try {
			BufferedWriter  bw = new BufferedWriter (new FileWriter ("failures.txt"));
			bw.write (sb_write.toString(), 0, sb_write.length());
			bw.flush();
			bw.close();
			System.out.println ( "Wrote failures to failures.txt");

		} catch (Exception e) {
			e.printStackTrace();
		}

		if (fails > 0)
			exitWith = 1;


	}



	private String lastTestCaseStart = null;
	private long lastTestCaseStartTime = 0;

	/**
	 * So, in this case, the Runner timed us out. Its like a result, but
	 * it's sort of stock.
	 * ISSUE: we don't know the testname at the timeout time
	 * so maybe tests should tell us they're starting
	 */
	public final void unpackResult(String file, String reason) {
		/// read/insert
		// System.out.println ("unpackResult (stuff): " + file + " " + reason);

		if (reason.equals("Timed out") || reason.equals ("Missing Results")) {
			if (file.indexOf (testsLocation) != -1) {
				file = file.substring (file.indexOf (testsLocation)+testsLocation.length()+1);
				file = file.replace ('\\', '/');
			/// maybe the slashes go the other way, or most of them do
			} else if (file.indexOf (testsLocation2) != -1) {
				file = file.substring (file.indexOf (testsLocation2)+testsLocation2.length()+1);
				file = file.replace ('\\', '/');
			}
		} else if (file.indexOf (File.separator) != -1) {
			file = file.substring (file.lastIndexOf (File.separator)+1);

		}


		if (lastTestCaseStart != null && lastTestCaseStart.indexOf("$") != -1) {

			file = lastTestCaseStart.substring(0, lastTestCaseStart.indexOf("$"));

			lastTestCaseStart=lastTestCaseStart.substring(lastTestCaseStart.indexOf("$")+1);

		}

		TestResult tr = new TestResult (file, lastTestCaseStart, reason, (System.currentTimeMillis()-timeout), TestResult.FAIL);

		/// soon we should insert this
		System.out.println ("unpacked result: " + tr);
		// if (run_id != -1)
		//	new InsertResults (run_id, tr);
		if (run_id != -1 && doTheInsert) {
			// AJH InsertResults insertResults = new InsertResults (run_id, tr);
			// threads.add (insertResults);
		} else if (!doTheInsert) {
			storeResultLocally (tr);
		}

	}



	/// very importantly, keeper of the time.
	public long lastUpdate = 0;


	public int finishedCount = 0;
	public int testcaseCount = 0;


	/**
	 * server thread. Listen. dispatch
	 */
	public class LocalListener extends Thread {



		public LocalListener() {


		}


		public InputHandler inputHandler;
		
		ServerSocket ss = null; /// 4/19 added moved to inst, was local to run

		public void run () {

			// System.out.println ("starting the server: " + new Date());

			/// launch server, dispatch sockets on new inlines

			try  {

				ss = new ServerSocket (port);

				while (running) {

					try {

						Socket s = ss.accept ();
						inputHandler = new InputHandler (s);
						inputHandler.start();

					} catch (Exception e) {
						// System.out.println ("broke out of the socket loop");
					}

				}

			} catch (Exception e) {

				e.printStackTrace ();

			}

		}


		boolean running = true;

		public void end() {
			running = false;
			/// 4/19 added:
			//

		}

		public void destroy() {
			try {
				ss.close();
			} catch (Exception e) {
				/// we don't really need to share this.
			}
		}
	}

	/*
	 * handle input from serverserver thread. Listen. dispatch
	 */
	public class InputHandler extends Thread {



		Socket s = null;


		public InputHandler (Socket s) {
			this.s = s;
			// this.start();  /// I think we want to kick immediately

		}

		public void run () {

			BufferedReader bis = null;
			String line = null;


			try {
				bis = new BufferedReader (new InputStreamReader(s.getInputStream()));

				while ( (line=bis.readLine()) != null) {
					handleLine(line);
				}

				try { bis.close(); } catch (Exception e) {  }
				try { s.close(); } catch (Exception e) { }

			} catch (Exception e) {
				// no more for this input handler
				// e.printStackTrace();
			}

		}



		public void handleResult (String line) {
			/// possibly we want the result unpacking to happen in this same thread?
			unpackResult(line);
			// killTimer();
			basicResponse((String)null);
			// System.out.println ("saw a result at " +  sdf.format(new Date()));
			finishedCount++;
		}

		public void handleStart (String line) {
			unpackStart(line);
			basicResponse((String)null);
			// System.out.println ("saw a start at :" +  sdf.format(new Date()));
		}

		public void handleStepTimeout (String line) {
			basicResponse(String.valueOf(step_timeout) + "\r\n\r\n");
		}


		public boolean inWaitLoop = false;
		public boolean abortWaitLoop = false;

		public void handleDone (String line) {
			currentExec.setDone();
			basicResponse((String)null);
		}

		public String countResponseHttp = "HTTP/1.1 200 OK\r\n";

		public void countResponse (String line) {


			/// Fix the look of the path:
			String l_realSwfToRun = FileUtils.normalizeDir (realSwfToRun);

			///
			if (shell_swf_prefix != null && shell_swf_prefix.startsWith ("http")) {

				// we should SHORTEN the real swf to run  if it's http
				l_realSwfToRun = l_realSwfToRun.substring (l_realSwfToRun.indexOf ("mustella/tests")+14);
				l_realSwfToRun = shell_swf_prefix + l_realSwfToRun;

			}  else  {
				// adjustments for proper file: url look:
				l_realSwfToRun = l_realSwfToRun.replace (':', '|');
				l_realSwfToRun = shell_swf_prefix + l_realSwfToRun;
			}

			System.out.println ("nextSwf: " + l_realSwfToRun);

			BufferedOutputStream bos =null;

			String ret = countResponseHttp + "\r\n" + l_realSwfToRun;

			try {
				bos = new BufferedOutputStream (s.getOutputStream ());

				bos.write (ret.getBytes(), 0, ret.length());

				bos.flush();

				bos.close();

				s.close();

			} catch (Exception e) {
				// ordinarily, this would cause an exception,
				// but not one we necessarily care about
				// e.printStackTrace();
			}

		}

		public void basicResponse (String line) {

			BufferedOutputStream bos =null;

			try {
				bos = new BufferedOutputStream (s.getOutputStream ());

				bos.write (stockResponse.getBytes(), 0, stockResponse.length());

				if (line!=null) {
					// System.out.println ("returning this for step_timeout: " + line);
					bos.write (line.getBytes(), 0, line.length());
				}

				bos.flush();


				bos.close();

				s.close();

			} catch (Exception e) {
				// ordinarily, this would cause an exception,
				// but not one we necessarily care about
				// e.printStackTrace();
			}

		}


		public void handleLine (String line) {



			// if (line.length()>0)
			//	System.out.println ("Handling this line: " + line);


			if (line.indexOf (testResult) != -1) {
				// killTimer ();  //// was here, moved to handleResult
				// System.out.println ("Handling TESTRESULT");
				lastUpdate = System.currentTimeMillis();
				handleResult (line);
			} else if (line.indexOf (heartBeat) != -1) {
				manageTimer ("heartBeat");
				lastUpdate = System.currentTimeMillis();
				basicResponse (line);
			} else if (line.indexOf (nextTestSwf) != -1) {
				// manageTimer ("heartBeat");
				countResponse (line);
			} else if (line.indexOf (testLength) != -1) {
				basicResponse (line);

				String tmp = line.substring (line.indexOf ("?") +1);
				tmp = tmp.substring (0, tmp.indexOf (" "));
				try {
					testcaseCount += Integer.parseInt (tmp);
				} catch (Exception e) {
					e.printStackTrace();
				}

			} else if (line.indexOf (testStart) != -1) {
				// System.out.println ("Handling TESTSTART");
				lastUpdate = System.currentTimeMillis();
				handleStart(line);
			} else if (line.indexOf (stepTimeout) != -1) {
				lastUpdate = System.currentTimeMillis();
				handleStepTimeout(line);
			} else if (line.indexOf (scriptDone) != -1) {
				String timeStamp = sdf.format(new Date());
				System.out.println ("SCRIPTDONE! " + timeStamp);
				System.out.println (line);
				lastUpdate = System.currentTimeMillis();
				killAllTimers ();
				killMetaTimer();

				String s_tc_done=null;
				int allowed=0;
				try { Thread.sleep (300); } catch (Exception e) { }

				if (!getResultsFromLog) {
					try {
					s_tc_done=line.substring(line.indexOf ("?")+1);
					s_tc_done=s_tc_done.substring(0, s_tc_done.indexOf (" HTTP")).trim();
					} catch (Exception e) {
						e.printStackTrace();
					}
					
					// hack, just in case a result is still processing
					// wait a little to check for other socket action:
					int waiting = balanceAccounts(Integer.parseInt(s_tc_done));

					System.out.println ("Before Wait loop " + timeStamp + " waiting = " + waiting);
					
					while (waiting > 0) {
						inWaitLoop = true;
						if (abortWaitLoop) {
							abortWaitLoop = false;
							break;
						}
						try { Thread.sleep (100); } catch (Exception e) { }
						allowed++;
						// System.out.println ("Current wait is: " + (allowed*100) + " vs timeout: " + timeout);
						if ( (allowed*100) > timeout) {
							if (waiting > 0)
								System.out.println ("Bailing, waited too long for results " + timeStamp);
							break;
						}

						waiting = balanceAccounts(Integer.parseInt(s_tc_done));

						if (allowed%10==0)
							System.out.println ("In wait loop " + timeStamp + ": Waiting for results...");
					}
					allowed = 0;
					inWaitLoop = false;
					System.out.println ("After Wait loop " + timeStamp + " waiting = " + waiting);


					lastUpdate = System.currentTimeMillis();
					handleDone(line);
					/// this can't be relevant anymore, as we're switching files:
					lastTestCaseStart="";

					/// correct?
					testcaseCount=0;
				}



			} else if (line.indexOf ("playerVersion") != -1) {

				line = URLDecoder.decode (line.substring ( line.indexOf (" "), line.lastIndexOf (" ")));
				playerVersion = line.substring (line.indexOf ("?")+1);
				System.out.println ("VERSION: " + playerVersion);

				// should end on that.
				killAllTimers ();
				killMetaTimer();
				handleDone("whatever");
				lastTestCaseStart="";
			}


		}





	}



	public void killMetaTimer() {

		Iterator it = metatimersOff.entrySet().iterator();
		Map.Entry me = null;

		while (it.hasNext()) {

			me = (Map.Entry) it.next();
			// System.out.println ("cancelling meta timer " + me.getKey() + " at " + sdf.format(new Date()));

			((Timer)me.getValue()).cancel();
		}


		metatimersOff.clear();
	}


	public void manageLogBasedTimer(String arg) {

		lastLogSize = 0L;
		killLogTimer();
		Timer currentTimer = new Timer();
		currentTimer.scheduleAtFixedRate (new LogTimeoutTask(timeout, arg), timeout, timeout);
		logTimersOff.put (arg, currentTimer);

	}

	public void manageMetaTimer(String arg) {
		// System.out.println ("call to manage meta timer with: " + arg);

		killMetaTimer();

		Timer currentTimer = new Timer();
		// System.out.println ("creating new meta timer at " + sdf.format(new Date()) + " with timeout: " + timeout + " for: " + arg);
		currentTimer.scheduleAtFixedRate (new MetaTimeoutTask(timeout, arg), timeout, timeout);

		metatimersOff.put (arg, currentTimer);

	}


	public synchronized void killLogTimer () {

		Iterator it = logTimersOff.entrySet().iterator();
		Map.Entry me = null;

		while (it.hasNext()) {
			me = (Map.Entry) it.next();
			((Timer)me.getValue()).cancel();
			/// and clobber it
			logTimersOff.remove (me.getKey());
		}


		logTimersOff.clear();



	}


	public synchronized void killAllTimers () {

		// System.out.println ("call to kill all timers");
		// if (timersOff.size() == 0)
		//	System.out.println ("....but there are no timers!");

		Iterator it = timersOff.entrySet().iterator();
		Map.Entry me = null;

		while (it.hasNext()) {
			me = (Map.Entry) it.next();
			// System.out.println ("cancelling timer " + me.getKey() + " at " + sdf.format(new Date()));
			((Timer)me.getValue()).cancel();
			/// and clobber it
			timersOff.remove (me.getKey());
		}


		timersOff.clear();


	}




	/// let's just clobber all timers then
	public void killTimer (String name) {
		// System.out.println ("call to cancel timer " + name);

		// if (timersOff.size() == 0)
		//	System.out.println ("....but there are no timers!");


		Timer t = (Timer)timersOff.get (name);

		if (t == null) {

			// System.out.println ("timer not found! " + name);
			resultList.add (name);

		} else {
			// System.out.println ("cancelling " + name);
			t.cancel();
			timersOff.remove (name);
		}


	}

	public ArrayList resultList = new ArrayList();

	public boolean haveResult (String arg) {

		/// not sure about contains
		if (resultList.contains (arg)) {
			return true;
		}

		return false;
	}

	public synchronized void manageTimer (String arg) {

		// System.out.println ("call to manage timer with: " + arg);

		///this seems strong

		killAllTimers();
		if (haveResult (arg)) {
			System.out.println ("already saw a result for " + arg  +" no timer create");
			return;
		}


		Timer currentTimer = new Timer();
		/// System.out.println ("creating new timer at " + sdf.format(new Date()) + " with timeout: " + timeout + " for: " + arg);
		currentTimer.schedule (new TimeoutTask(timeout, arg), timeout);

		timersOff.put (arg, currentTimer);

	}

	public long lastLogSize=0L;
	public long lastModTime = 0L;

	class LogTimeoutTask extends TimerTask {

		long timeout = 0;
		String myName = null;

		public LogTimeoutTask(long timeout, String myName) {
			this.timeout = timeout;
			this.myName = myName;
			// System.out.println ("LogTimeout init at: " + new Date());

		}

		/// clobber the current process and insert a timed out result, against the
		/// script
		public void run() {
			// check log size, if it hasn't changed, timeout
			String outName = flashlog;
			long currentSize = new File(outName).length();
			long currentModTime = new File(outName).lastModified();

			if (currentSize == lastLogSize && currentModTime == lastModTime)  {
				// System.out.println ("Timout values: size, time: " + currentSize + " " +  lastLogSize + " " +  currentModTime + " " + lastModTime) ;
				System.out.println ("Firing timeout for " + myName + " at: " + new Date());
                                currentExec.setDone(true);
			} else {
				// System.out.println ("timeout checke for " + myName + " at: " + new Date());
				// System.out.println ("Timout check : size, time: " + currentSize + " " +  lastLogSize + " " +  currentModTime + " " + lastModTime) ;
				lastModTime = currentModTime;
				lastLogSize = currentSize;
			}



		}
	}


	class MetaTimeoutTask extends TimerTask {

		long timeout = 0;
		String myName = null;

		public MetaTimeoutTask(long timeout, String myName) {
			this.timeout = timeout;
			this.myName = myName;
		}

		/// clobber the current process and insert a timed out result, against the
		/// script
		public void run() {
		        if ((System.currentTimeMillis() - lastUpdate) > timeout) {
                                System.out.println ("Firing Meta Timeout for " + myName + " after " +
timeout + " millis at: " +sdf.format(new Date()) );
                                currentExec.setDone(true);
                        }

		}
	}

	class TimeoutTask extends TimerTask {

		long timeout = 0;

		String myName = null;

		public TimeoutTask(long timeout, String myName) {
			this.timeout = timeout;
			this.myName = myName;
		}

		/// clobber the current process and insert a timed out result, against the
		/// script
		public void run() {
			if (haveResult (myName)) {
				System.out.println ("already saw a result for " + myName  +" will abort the timeout");
				return;
			} else {
				System.out.println ("Firing Timeout for " + myName + " after " + timeout + " millis at: " + sdf.format(new Date()) );
			}

			currentExec.setDone(true);

		}
	}


	public static void main(String args[]) throws Exception {



	        if (args.length == 0) {
	            System.out.println("[ERROR] Runner no swfs.");
	            System.exit(1);
	        }
	        if (args.length > 1) {
	            System.out.println("[ERROR] Runner expected one arg of ; separated paths");
	        }



		String tmp0 = System.getProperties().getProperty(insertResultsProperty);
		if  ( tmp0 != null && !tmp0.equals ("")) {

			try {

				/// set the insert
				doTheInsert = new Boolean (System.getProperties().getProperty(insertResultsProperty)).booleanValue();

			} catch (Exception e) {

				e.printStackTrace();

				/// back to default:
				doTheInsert = true;

			}

		} else {

			doTheInsert = true;

		}




		if  ( System.getProperty ("okay_to_exit") != null) {

			try {
				okayToExit = new Boolean (System.getProperty("okay_to_exit")).booleanValue();
			} catch (Exception e) {
				e.printStackTrace();
			}

		}

		if  ( System.getProperties().getProperty("run_id") != null)  {

			try {
				run_id = Integer.parseInt (System.getProperty("run_id"));

			} catch (Exception e) {
				e.printStackTrace();
			}

		}

		if  ( System.getProperty ("okay_to_exit") != null) {

			try {
				okayToExit = new Boolean (System.getProperty("okay_to_exit")).booleanValue();
			} catch (Exception e) {
				e.printStackTrace();
			}

		}
	        // System.out.println("Runner: yall set okayToExit to: " + okayToExit);



	        // System.out.println("Runner: y'all gimme a run_id: " + System.getProperties().getProperty("run_id"));
	        // System.out.println("args to run: " + args[0]);

	        //split up the path
	        args = args[0].split(System.getProperty("path.separator"));
		// System.out.println ("arg count to work: " + args.length);
	        // System.out.println("Compiling " + args.length + " files.");
	        String basedir = System.getProperty("basedir", ".");


		Runner r = new Runner(args);


		if (okayToExit)
			System.exit (exitWith);
	}


}

