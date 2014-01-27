/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.tools.debugger.concrete;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import flash.tools.debugger.AIRLaunchInfo;
import flash.tools.debugger.Frame;
import flash.tools.debugger.IDebuggerCallbacks;
import flash.tools.debugger.InProgressException;
import flash.tools.debugger.Location;
import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSupportedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SessionManager;
import flash.tools.debugger.SourceFile;
import flash.tools.debugger.SourceLocator;
import flash.tools.debugger.SuspendedException;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.Value;
import flash.tools.debugger.ValueAttribute;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VariableAttribute;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.VersionException;
import flash.tools.debugger.Watch;
import flash.tools.debugger.concrete.DProtocol.ListenerIndex;
import flash.tools.debugger.events.DebugEvent;
import flash.tools.debugger.events.ExceptionFault;
import flash.tools.debugger.events.FaultEvent;
import flash.tools.debugger.expression.ECMA;
import flash.tools.debugger.expression.PlayerFaultException;
import flash.util.Trace;


public class PlayerSession implements Session, DProtocolNotifierIF, Runnable
{
	public static final int MAX_STACK_DEPTH = 256;
	public static final long MAX_TERMINATE_WAIT_MILLIS = 10000;

	private Socket				m_socket;
	private DProtocol			m_protocol;
	private DManager			m_manager;
	private IDebuggerCallbacks	m_debuggerCallbacks;
	private Process				m_process;
	private Map<String, Object> m_prefs; // WARNING -- accessed from multiple threads
	private static final String	s_newline = System.getProperty("line.separator"); //$NON-NLS-1$

	private volatile boolean m_isConnected; // WARNING -- accessed from multiple threads
	private volatile boolean m_isHalted; // WARNING -- accessed from multiple threads
	private volatile boolean m_incoming; // WARNING -- accessed from multiple threads
	private volatile boolean m_lastResponse;  // whether there was a reponse from the last message to the Player
	private int				m_watchTransactionTag;
	private Boolean			m_playerCanCallFunctions;
	private Boolean			m_playerSupportsWatchpoints;
	private Boolean			m_playerCanBreakOnAllExceptions;

	/**
	 * The URL that was launched, or <code>null</code> if not known.  Note:
	 * This is NOT the value returned by getURI().  getURI() returns the
	 * URL that came from the Player, and is therefore probably the URI of
	 * the SWF; but m_launchedUrl contains the URL that we tried to launch,
	 * which might be an HTML wrapper, e.g. http://localhost/myapp.html
	 */
	private String				m_launchUrl;

	private AIRLaunchInfo	m_airLaunchInfo; // null if this is not an AIR app

	static volatile boolean	m_debugMsgOn;		// debug ONLY; turned on with "set $debug_messages = 1"
	volatile int			m_debugMsgSize;		// debug ONLY; controlled with "set $debug_message_size = NNN"
	static volatile boolean	m_debugMsgFileOn;	// debug ONLY for file dump; turned on with "set $debug_message_file = 1"
	volatile int			m_debugMsgFileSize;	// debug ONLY for file dump; controlled with "set $debug_message_file_size = NNN"

	/**
	 * A simple cache of previous "is" and "instanceof" queries, in order to
	 * avoid having to send redundant messages to the player.
	 */
	private Map<String, Boolean> m_evalIsAndInstanceofCache = new HashMap<String, Boolean>();

	private static final String DEBUG_MESSAGES = "$debug_messages"; //$NON-NLS-1$
	private static final String DEBUG_MESSAGE_SIZE = "$debug_message_size"; //$NON-NLS-1$
	private static final String DEBUG_MESSAGE_FILE = "$debug_message_file"; //$NON-NLS-1$
	private static final String DEBUG_MESSAGE_FILE_SIZE = "$debug_message_file_size"; //$NON-NLS-1$

	private static final String CONSOLE_ERRORS = "$console_errors"; //$NON-NLS-1$

	private static final String FLASH_PREFIX = "$flash_"; //$NON-NLS-1$

	PlayerSession(Socket s, DProtocol proto, DManager manager, IDebuggerCallbacks debuggerCallbacks)
	{
		m_isConnected = false;
		m_isHalted = false;
		m_socket = s;
		m_protocol = proto;
		m_manager = manager;
		m_prefs = Collections.synchronizedMap(new HashMap<String, Object>());
		m_incoming = false;
		m_debugMsgOn = false;
		m_debugMsgSize = 16;
		m_debugMsgFileOn = false;
		m_debugMsgFileSize = 128;
		m_watchTransactionTag = 1;  // number that is sent for each watch transaction that occurs
		m_playerCanCallFunctions = null;
		m_debuggerCallbacks = debuggerCallbacks;
	}
	
	private static PlayerSession createFromSocketHelper(Socket s, IDebuggerCallbacks debuggerCallbacks, DProtocol proto) throws IOException
	{
		// let the manager hear incoming messages
		DManager manager = new DManager();

		PlayerSession session = new PlayerSession(s, proto, manager, debuggerCallbacks);
		return session;
	}

	/**
	 * @deprecated Use createFromSocketWithOptions
	 * @param s
	 * @param debuggerCallbacks
	 * @return
	 * @throws IOException
	 */
	public static PlayerSession createFromSocket(Socket s, IDebuggerCallbacks debuggerCallbacks) throws IOException
	{
		DProtocol proto = DProtocol.createFromSocket(s);

		return createFromSocketHelper(s, debuggerCallbacks, proto);
	}
	
	/**
	 * Creates a session from the socket. Sets session specific 
	 * socket settings and stores the callback object.
	 * @param s
	 * @param debuggerCallbacks
	 * @param sessionManager
	 * @return
	 * @throws IOException
	 */
	public static PlayerSession createFromSocketWithOptions(Socket s, IDebuggerCallbacks debuggerCallbacks, SessionManager sessionManager) throws IOException
	{
		DProtocol proto = DProtocol.createFromSocket(s, sessionManager);

		return createFromSocketHelper(s, debuggerCallbacks, proto);
	}

	/* getter */
	public DMessageCounter		getMessageCounter()		{ return m_protocol.getMessageCounter(); }
	public String				getURI()				{ return m_manager.getURI(); }
	public boolean				playerSupportsGet()		{ return m_manager.isGetSupported(); }
    public int                  playerVersion()         { return m_manager.getVersion(); }
    public SourceLocator        getSourceLocator()      { return m_manager.getSourceLocator(); }

	/*
	 * @see flash.tools.debugger.Session#setSourceLocator(flash.tools.debugger.SourceLocator)
	 */
	public void setSourceLocator(SourceLocator sourceLocator)
	{
		m_manager.setSourceLocator(sourceLocator);
	}

	/**
	 * If the manager started the process for us, then note it here. We will attempt to kill
	 * it when we go down
	 */
	void setProcess(Process proc)
	{
		m_process = proc;
	}

	/*
	 * @see flash.tools.debugger.Session#getLaunchProcess()
	 */
	public Process getLaunchProcess()
	{
		return m_process;
	}

	/**
	 * Set preference
	 * If an invalid preference is passed, it will be silently ignored.
	 */
	public void			setPreferences(Map<String, ? extends Object> map)	{ m_prefs.putAll(map); mapBack(); }
	public Set<String>	keySet()								{ return m_prefs.keySet(); }
	public Object		getPreferenceAsObject(String pref)		{ return m_prefs.get(pref); }

	/**
	 * Set a property. Special logic for debug message boolean
	 */
	public void setPreference(String pref, int value)
	{
		m_prefs.put(pref, new Integer(value));
		mapBack();

		// change in console messages?
		if (pref.equals(CONSOLE_ERRORS))
			sendConsoleErrorsAsTrace(value == 1);

		// generic message for flash player wherein "$flash_xxx" causes "xxx" to be sent
		if (pref.startsWith(FLASH_PREFIX))
			sendOptionMessage(pref.substring(FLASH_PREFIX.length()), Integer.toString(value));
	}

	// helper for mapBack()
	private int mapBackOnePreference(String preferenceName, int defaultValue)
	{
		Object prefValue = getPreferenceAsObject(preferenceName);
		if (prefValue != null)
			return ((Integer)prefValue).intValue();
		else
			return defaultValue;
	}

	// helper for mapBack()
	private boolean mapBackOnePreference(String preferenceName, boolean defaultValue)
	{
		Object prefValue = getPreferenceAsObject(preferenceName);
		if (prefValue != null)
			return ((Integer)prefValue).intValue() != 0 ? true : false;
		else
			return defaultValue;
	}

	// look for preferences, that map back to variables
	private void mapBack()
	{
		m_debugMsgOn = mapBackOnePreference(DEBUG_MESSAGES, m_debugMsgOn);
		m_debugMsgSize = mapBackOnePreference(DEBUG_MESSAGE_SIZE, m_debugMsgSize);

		m_debugMsgFileOn = mapBackOnePreference(DEBUG_MESSAGE_FILE, m_debugMsgFileOn);
		m_debugMsgFileSize = mapBackOnePreference(DEBUG_MESSAGE_FILE_SIZE, m_debugMsgFileSize);
	}

	public int getPreference(String pref)
	{
		int val = 0;
		Integer i = (Integer)m_prefs.get(pref);
		if (i == null)
			throw new NullPointerException();
		else
			val = i.intValue();
		return val;
	}


	/*
	 * @see flash.tools.debugger.Session#isConnected()
	 */
	public boolean isConnected()
	{
		return m_isConnected;
	}

	/*
	 * @see flash.tools.debugger.Session#isSuspended()
	 */
	public boolean isSuspended() throws NotConnectedException
	{
		if (!isConnected())
			throw new NotConnectedException();

		return m_isHalted;
	}

	/**
	 * Start up the session listening for incoming messages on the socket
	 */
	public boolean bind() throws VersionException
	{
		boolean bound = false;

		if (m_isConnected)
			return false;
		
		// mark that we are connected
		m_isConnected = true;

		// attach us to the pipe (we are last to ensure that DManager and msg counter
		// get updated first
		m_protocol.addListener(ListenerIndex.PlayerSession, this);

		// start up the receiving thread
		bound = m_protocol.bind();

		// transmit our first few adjustment messages
		sendStopWarning();
		sendStopOnFault();
		sendEnumerateOverride();
		sendFailureNotify();
		sendInvokeSetters();
		sendSwfloadNotify();
		sendGetterTimeout();
		sendSetterTimeout();
		boolean responded = sendSquelch(true);

		// now note in our preferences whether get is working or not.
		setPreference(SessionManager.PLAYER_SUPPORTS_GET, playerSupportsGet() ? 1 : 0);

		// Spawn a background thread which fetches the SWF and SWD
		// from the Player and uses them to build function name tables
		// for each source file
		Thread t = new Thread(this, "SWF/SWD reader"); //$NON-NLS-1$
		t.setDaemon(true);
		t.start();

		// we're probably using a bad version
		if (!responded)
			throw new VersionException();

		return bound;
	}

	/**
	 * Permanently stops the debugging session and breaks the
	 * connection to the Player
	 */
	public void unbind()
	{
		unbind(false);
	}

	/**
	 * @param requestTerminate
	 *            if true, and if the player to which we are attached is capable
	 *            of terminating itself (e.g. Adobe AIR), then the player will
	 *            be told to terminate.
	 * @return true if the player is capable of terminating itself and has been
	 *         told to do so
	 */
	private boolean unbind(boolean requestTerminate)
	{
		// If the caller asked us to terminate the player, then we first check
		// whether the player to which we are connected is capable of that.
		// (The web-based players are not; Adobe AIR is.)
		requestTerminate = requestTerminate && playerCanTerminate();
		DMessage dm = DMessageCache.alloc(1);
		dm.setType(DMessage.OutExit);
		dm.putByte((byte)(requestTerminate ? 1 : 0));
		sendMessage(dm);

		// unbind from the socket, so that we don't receive any more messages
		m_protocol.unbind();

		// kill the socket
		try { m_socket.close(); } catch(IOException io) {}

		m_isConnected = false;
		m_isHalted = false;

		return requestTerminate; // true if player was told to terminate
	}

	/**
	 * Execute the specified AppleScript by passing it to /usr/bin/osascript.
	 *
	 * @param appleScript
	 *            the AppleScript to execute, as a series of lines
	 * @param argv
	 *            any arguments; these can be accessed from within your
	 *            AppleScript via "item 1 or argv", "item 2 of argv", etc.
	 * @return any text which was sent to stdout by /usr/bin/osascript, with the
	 *         trailing \n already removed
	 */
	private String executeAppleScript(String[] appleScript, String[] argv)
	{
		StringBuilder retval = new StringBuilder();
		try
		{
			List<String> execArgs = new LinkedList<String>();
			// "osascript" is the command-line way of executing AppleScript.
			execArgs.add("/usr/bin/osascript"); //$NON-NLS-1$
			execArgs.add("-"); //$NON-NLS-1$
			if (argv != null)
			{
				for (int i=0; i<argv.length; ++i)
					execArgs.add(argv[i]);
			}
			Process osascript = Runtime.getRuntime().exec(execArgs.toArray(new String[execArgs.size()]));
			// feed our AppleScript code to osascript's stdin
			OutputStream outputStream = osascript.getOutputStream();
			PrintWriter writer = new PrintWriter(outputStream, true);
			writer.println("on run argv"); //$NON-NLS-1$ // this gives the name "argv" to the command-line args
			for (int i=0; i<appleScript.length; ++i)
				writer.println(appleScript[i]);
			writer.println("end run"); //$NON-NLS-1$
			writer.close();
			InputStreamReader reader = new InputStreamReader(osascript.getInputStream());
			int ch;
			while ( (ch=reader.read()) != -1 )
				retval.append((char)ch);
		}
		catch (IOException e)
		{
			// ignore
		}
		return retval.toString().replaceAll("\n$", ""); //$NON-NLS-1$ //$NON-NLS-2$
	}

	/**
	 * Execute the specified AppleScript by passing it to /usr/bin/osascript.
	 *
	 * @param appleScriptFilename
	 *            The name of the file containing AppleScript to execute.  This
	 *            must be relative to PlayerSession.java.
	 * @param argv
	 *            any arguments; these can be accessed from within your
	 *            AppleScript via "item 1 or argv", "item 2 of argv", etc.
	 * @return any text which was sent to stdout by /usr/bin/osascript, with the
	 *         trailing \n already removed
	 * @throws IOException
	 */
	private String executeAppleScript(String appleScriptFilename, String[] argv) throws IOException
	{
		InputStream stm = null;
		try {
			stm = PlayerSession.class.getResourceAsStream(appleScriptFilename);
			BufferedReader reader = new BufferedReader(new InputStreamReader(stm));
			String line;
			List<String> appleScriptLines = new ArrayList<String>();
			while ( (line=reader.readLine()) != null )
				appleScriptLines.add(line);
			String[] lines = appleScriptLines.toArray(new String[appleScriptLines.size()]);
			return executeAppleScript(lines, argv);
		} finally {
			if (stm != null) {
				stm.close();
			}
		}
	}

	/**
	 * Checks whether the specified Macintosh web browser is currently
	 * running.  You should only call this function if you have already
	 * checked that you are running on a Mac.
	 *
	 * @param browserName a name, e.g. "Safari", "Firefox", "Camino"
	 * @return true if currently running
	 */
	private Set<String> runningApplications()
	{
		String running = executeAppleScript(
			new String[]
        	{
				"tell application \"System Events\"", //$NON-NLS-1$
				"	name of processes", //$NON-NLS-1$
				"end tell" //$NON-NLS-1$
        	},
        	null
		);
		String[] apps = running.split(", "); //$NON-NLS-1$
		Set<String> retval = new HashSet<String>();
		for (int i=0; i<apps.length; ++i)
			retval.add(apps[i]);
		return retval;
	}

	/**
	 * Destroys all objects related to the connection
	 * including the process that was tied to this
	 * session via SessionManager.launch(), if it
	 * exists.
	 */
	public void terminate()
	{
		boolean playerWillTerminateItself = false;

		// unbind first
		try
		{
			// Tell player to end session.  Note that this is just a hint, and will often
			// do nothing.  For example, the Flash player running in a browser will
			// currently never terminate when you tell it to, but the AIR player will
			// terminate.
			playerWillTerminateItself = unbind(true);
		} catch(Exception e)
		{
		}

		if (!playerWillTerminateItself)
		{
			if (System.getProperty("os.name").toLowerCase().startsWith("mac os x")) //$NON-NLS-1$ //$NON-NLS-2$
			{
				if (m_airLaunchInfo != null)
				{
					// nothing we need to do -- Process.destroy() will kill the AIR app
				}
				else if (m_launchUrl != null && m_launchUrl.length() > 0)
				{
					boolean closedAnyWindows = false;
					Set<String> runningApps = runningApplications();

					if (!closedAnyWindows && runningApps.contains("Safari")) //$NON-NLS-1$
					{
						try {
							String url = m_launchUrl.replaceAll(" ", "%20"); //$NON-NLS-1$ //$NON-NLS-2$
							String safariClosedAnyWindows = executeAppleScript("appleScriptCloseSafariWindow.txt", new String[] { url }); //$NON-NLS-1$
							if ("true".equals(safariClosedAnyWindows)) { //$NON-NLS-1$ 								
								closedAnyWindows = true;								
							}
							else if ( "appquit".equals(safariClosedAnyWindows) ) { //$NON-NLS-1$
								closedAnyWindows = true;
								//we closed Safari, verify safari was closed
								runningApps = waitForMacAppQuit("Safari"); //$NON-NLS-1$
							}
						} catch (IOException e) {
							// ignore
						}
					}
										
					if (!closedAnyWindows && runningApps.contains("Camino")) //$NON-NLS-1$
					{
						// For local file: URLs, Camino uses "file://localhost/..." instead of "file:///..."
						String url = m_launchUrl.replaceFirst("^file:///", "file://localhost/"); //$NON-NLS-1$ //$NON-NLS-2$
						try {
							String caminoClosedAnyWindows = executeAppleScript("appleScriptCloseCaminoWindow.txt", new String[] { url }); //$NON-NLS-1$
							if ("true".equals(caminoClosedAnyWindows)) { //$NON-NLS-1$								
								closedAnyWindows = true;
							}
							else if ( "appquit".equals(caminoClosedAnyWindows) ) { //$NON-NLS-1$
								closedAnyWindows = true;
								//we closed camino, verify camino was closed
								runningApps = waitForMacAppQuit("Camino"); //$NON-NLS-1$
							}
								
						} catch (IOException e) {
							// ignore
						}
					}

					// The standalone player on the Mac has gone through several name changes,
					// so we have to look for all of these.
					String[] macStandalonePlayerNames =
					{
						"Flash Player Debugger",	// New name as of Player 10.1	//$NON-NLS-1$
						"Flash Player",				// New name as of 12/4/06		//$NON-NLS-1$
						"SAFlashPlayer",			// An older name				//$NON-NLS-1$
						"standalone"				// Another older name			//$NON-NLS-1$
					};

					for (int i=0; !closedAnyWindows && i<macStandalonePlayerNames.length; ++i)
					{
						if (runningApps.contains(macStandalonePlayerNames[i]))
						{
							executeAppleScript(new String[] { "tell application \"" + macStandalonePlayerNames[i] + "\" to quit" }, null); //$NON-NLS-1$ //$NON-NLS-2$
							waitForMacAppQuit(macStandalonePlayerNames[i]);
							closedAnyWindows = true;
						}
					}
				}
			}

			// if we have a process pop it
			if (m_process != null)
			{
				try
				{
					m_debuggerCallbacks.terminateDebugTarget(m_process);
				}
				catch (IOException e)
				{
					// ignore
				}
			}
		}
		else if (m_process != null) {
			try {
				m_process.waitFor();
			}
			catch (Exception e) {
			}
		}

		// now clear it all
		m_isConnected = false;
		m_isHalted = false;
	}

	/**
	 * Utility function to wait for a mac application to quit.
	 * This waits for a maximum of MAX_TERMINATE_WAIT_MILLIS.
	 * 
	 * Waiting is important because applescript "quit" is not
	 * synchronous and launching a URL while the browser is
	 * quitting is not good. (See FB-21879)
	 * @return Set<String> of running applications.
	 */
	private Set<String> waitForMacAppQuit(String browser) {
		Set<String> runningApps;
		boolean appClosed = true;
		final long startMillis = System.currentTimeMillis();		
		final long waitMillis = 100;
		do {
			runningApps = runningApplications();
			if ( runningApps.contains(browser) ) {
				appClosed = false;
				
				try {
					Thread.sleep(waitMillis);					
				} catch (InterruptedException e) {
					return runningApps;
				}
				
				long currentMillis = System.currentTimeMillis();
				
				if ( currentMillis - startMillis >= MAX_TERMINATE_WAIT_MILLIS )
					break;
			}
			else {
				appClosed = true;
			}
		}
		while ( !appClosed );
		return runningApps;
	}

	/*
	 * @see flash.tools.debugger.Session#resume()
	 */
	public void resume() throws NotSuspendedException, NotConnectedException, NoResponseException
	{
		// send a continue message then return
		if (!isSuspended())
			throw new NotSuspendedException();

		if (!simpleRequestResponseMessage(DMessage.OutContinue, DMessage.InContinue))
			throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));
	}

	/*
	 * @see flash.tools.debugger.Session#suspend()
	 */
	public void suspend() throws SuspendedException, NotConnectedException, NoResponseException
	{
		// send a halt message
		int wait = getPreference(SessionManager.PREF_SUSPEND_WAIT);
 		int every = 50; // wait this long for a response.  The lower the number the more aggressive we are!

		if (isSuspended())
			throw new SuspendedException();

		while (!isSuspended() && wait > 0)
		{
			simpleRequestResponseMessage(DMessage.OutStopDebug, DMessage.InBreakAtExt, every);
			wait -= every;
		}

		if (!isSuspended())
			throw new NoResponseException(wait);
	}

	/**
	 * Obtain all the suspend information
	 */
	public DSuspendInfo getSuspendInfo()
	{
		DSuspendInfo info = m_manager.getSuspendInfo();
		if (info == null)
		{
			// request break information
			if (simpleRequestResponseMessage(DMessage.OutGetBreakReason, DMessage.InBreakReason))
				info = m_manager.getSuspendInfo();

			// if we still can't get any info from the manager...
			if (info == null)
				info = new DSuspendInfo();  // empty unknown break information
		}
		return info;
	}

	/**
	 * Return the reason that the player has suspended itself.
	 */
	public int suspendReason()
	{
		DSuspendInfo info = getSuspendInfo();
		return info.getReason();
	}

	/**
	 * Return the offset in which the player has suspended itself.  The BreakReason
	 * message contains both reason and offset.
	 */
	public int getSuspendOffset()
	{
		DSuspendInfo info = getSuspendInfo();
		return info.getOffset();
	}

	/**
	 * Return the offset in which the player has suspended itself.  The BreakReason
	 * message contains both reason and offset.
	 */
	public int getSuspendActionIndex()
	{
		DSuspendInfo info = getSuspendInfo();
		return info.getActionIndex();
	}

	/**
	 * Obtain information about the various SWF(s) that have been
	 * loaded into the Player, for this session.
	 *
	 * Note: As SWFs are loaded by the Player a SwfLoadedEvent is
	 * fired.  At this point, a call to getSwfInfo() will provide
	 * updated information.
	 *
	 * @return array of records describing the SWFs
	 */
	public SwfInfo[] getSwfs() throws NoResponseException
	{
		if (m_manager.getSwfInfoCount() == 0)
		{
			// need to help out on the first one since the player
			// doesn't send it
			requestSwfInfo(0);
		}
		SwfInfo[] swfs = m_manager.getSwfInfos();
		return swfs;
	}

	/**
	 * Request information on a particular swf, used by DSwfInfo
	 * to fill itself correctly
	 */
	public void requestSwfInfo(int at) throws NoResponseException
	{
		// nope don't have it...might as well go out and ask for all of them.
		DMessage dm = DMessageCache.alloc(4);
		dm.setType( DMessage.OutSwfInfo );
		dm.putWord(at);
		dm.putWord(0);  // rserved

		int to = getPreference(SessionManager.PREF_CONTEXT_RESPONSE_TIMEOUT);

		if (!simpleRequestResponseMessage(dm, DMessage.InSwfInfo, to))
			throw new NoResponseException(to);
	}

	/**
	 * Request a set of actions from the player
	 */
	public byte[] getActions(int which, int at, int len) throws NoResponseException
	{
		byte[] actions = null;

		// send a actions message
		DMessage dm = DMessageCache.alloc(12);
		dm.setType( DMessage.OutGetActions );
		dm.putWord(which);
		dm.putWord(0); // rsrvd
		dm.putDWord(at);
		dm.putDWord(len);

		// request action bytes
		int to = getPreference(SessionManager.PREF_CONTEXT_RESPONSE_TIMEOUT);
		if (simpleRequestResponseMessage(dm, DMessage.InGetActions, to))
			actions = m_manager.getActions();
		else
			throw new NoResponseException(to);

		return actions;
	}

	/*
	 * @see flash.tools.debugger.Session#stepInto()
	 */
	public void stepInto() throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (isSuspended())
		{
			// send a step-into message and then wait for the Flash player to tell us that is has
			// resumed execution
			if (!simpleRequestResponseMessage(DMessage.OutStepInto, DMessage.InContinue))
				throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));
		}
		else
			throw new NotSuspendedException();
	}

	/*
	 * @see flash.tools.debugger.Session#stepOut()
	 */
	public void stepOut() throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (isSuspended())
		{
			// send a step-out message and then wait for the Flash player to tell us that is has
			// resumed execution
			if (!simpleRequestResponseMessage(DMessage.OutStepOut, DMessage.InContinue))
				throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));
		}
		else
			throw new NotSuspendedException();
	}

	/*
	 * @see flash.tools.debugger.Session#stepOver()
	 */
	public void stepOver() throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (isSuspended())
		{
			// send a step-over message and then wait for the Flash player to tell us that is has
			// resumed execution
			if (!simpleRequestResponseMessage(DMessage.OutStepOver, DMessage.InContinue))
				throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));
		}
		else
			throw new NotSuspendedException();
	}

	/*
	 * @see flash.tools.debugger.Session#stepContinue()
	 */
	public void stepContinue() throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (!isSuspended())
			throw new NotSuspendedException();

		// send a step-continue message and then wait for the Flash player to tell us that is has
		// resumed execution
		if (!simpleRequestResponseMessage(DMessage.OutStepContinue, DMessage.InContinue))
			throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));
	}

    /**
     * Sends a request to the player to obtain function names.
     * The resultant message end up populating the function name array
     * for the given DModule.
     *
     * @param moduleId
     * @param lineNbr
     * @return
     */
    public void requestFunctionNames(int moduleId, int lineNbr) throws VersionException, NoResponseException
    {
        // only player 9 supports this message
        if (m_manager.getVersion() >= 9)
        {
            DMessage dm = DMessageCache.alloc(8);
            dm.setType(DMessage.OutGetFncNames);
            dm.putDWord(moduleId);
            dm.putDWord(lineNbr);

            if (!simpleRequestResponseMessage(dm, DMessage.InGetFncNames))
                throw new NoResponseException(0);
        }
        else
        {
            throw new VersionException();
        }
    }

	/**
	 * From a given file identifier return a source file object
	 */
	public SourceFile getFile(int fileId)
	{
		return m_manager.getSource(fileId);
	}

	/**
	 * Get a list of breakpoints
	 */
	public Location[] getBreakpointList()
	{
		return m_manager.getBreakpoints();
	}

	/*
	 * @see flash.tools.debugger.Session#setBreakpoint(int, int)
	 */
	public Location setBreakpoint(int fileId, int lineNum) throws NoResponseException, NotConnectedException
	{
		/* send the message to the player and await a response */
		Location l = null;
		int bp = DLocation.encodeId(fileId, lineNum);

		DMessage dm = DMessageCache.alloc(8);
		dm.setType(DMessage.OutSetBreakpoints);
		dm.putDWord(1);
		dm.putDWord(bp);

		boolean gotResponse = simpleRequestResponseMessage(dm, DMessage.InSetBreakpoint);
		if(gotResponse)
		{
			/* even though we think we got an answer check that the breakpoint was added */
			l = m_manager.getBreakpoint(bp);
		}
		else
			throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));

		return l;
	}

	/*
	 * @see flash.tools.debugger.Session#clearBreakpoint(flash.tools.debugger.Location)
	 */
	public Location clearBreakpoint(Location local)
	{
		/* first find it */
		SourceFile source = local.getFile();
		int fileId = source.getId();
		int lineNum = local.getLine();
		int bp = DLocation.encodeId(fileId, lineNum);
		Location l = m_manager.getBreakpoint(bp);
		if (l != null)
		{
			/* send the message */
			DMessage dm = DMessageCache.alloc(8);
			dm.setType(DMessage.OutRemoveBreakpoints);
			dm.putDWord(1);
			dm.putDWord(bp);
			sendMessage(dm);

			/* no callback from the player so we remove it ourselves */
			m_manager.removeBreakpoint(bp);
		}
		return l;
	}

	/*
	 * @see flash.tools.debugger.Session#getWatchList()
	 */
	public Watch[] getWatchList() throws NoResponseException, NotConnectedException
	{
		return m_manager.getWatchpoints();
	}

	private Watch setWatch(long varId, String memberName, int kind) throws NoResponseException, NotConnectedException, NotSupportedException
	{
		// we really have two cases here, one where we add a completely new
		// watchpoint and the other where we modify an existing one.
		// In either case the DManager logic is such that the last watchpoint
		// in the list will contain our id if successful.
		Watch w = null;
		int tag = m_watchTransactionTag++;

		if (addWatch(varId, memberName, kind, tag))
		{
			// good that we got a response now let's check that
			// it actually worked.
			int count = m_manager.getWatchpointCount();
			if (count > 0)
			{
				DWatch lastWatch = m_manager.getWatchpoint(count-1);
				if (lastWatch.getTag() == tag)
					w = lastWatch;
			}
		}
		return w;
	}

	/*
	 * @see flash.tools.debugger.Session#setWatch(flash.tools.debugger.Variable, java.lang.String, int)
	 */
	public Watch setWatch(Value v, String memberName, int kind) throws NoResponseException, NotConnectedException, NotSupportedException
	{
		return setWatch(v.getId(), memberName, kind);
	}

	public Watch setWatch(Watch watch) throws NoResponseException, NotConnectedException, NotSupportedException
	{
		return setWatch(watch.getValueId(), watch.getMemberName(), watch.getKind());
	}

	/*
	 * @see flash.tools.debugger.Session#clearWatch(flash.tools.debugger.Watch)
	 */
	public Watch clearWatch(Watch watch) throws NoResponseException, NotConnectedException
	{
		Watch[] list = getWatchList();
		Watch w = null;
		if ( removeWatch(watch.getValueId(), watch.getMemberName()) )
		{
			// now let's first check the size of the list, it
			// should now be one less
			if (m_manager.getWatchpointCount() < list.length)
			{
				// ok we made a change. So let's compare list and see which
				// one went away
				Watch[] newList = getWatchList();
				for(int i=0; i<newList.length; i++)
				{
					// where they differ is the missing one
					if (list[i] != newList[i])
					{
						w = list[i];
						break;
					}
				}

				// might be the last one...
				if (w == null)
					w = list[list.length-1];
			}
		}
		return w;
	}

	/*
	 * @see flash.tools.debugger.Session#getVariableList()
	 */
	public Variable[] getVariableList() throws NotSuspendedException, NoResponseException, NotConnectedException, VersionException
	{
		// make sure the player has stopped and send our message awaiting a response
		if (!isSuspended())
			throw new NotSuspendedException();

		requestFrame(0);  // our 0th frame gets our local context

		// now let's request all of the special variables too
		getValue(Value.GLOBAL_ID);
		getValue(Value.THIS_ID);
		getValue(Value.ROOT_ID);

		// request as many levels as we can get
		int i = 0;
		Value v = null;
		do
		{
			v = getValue(Value.LEVEL_ID-i);
		}
		while( i++ < 128 && v != null);

		// now that we've primed the DManager we can request the base variable whose
		// children are the variables that are available
		v = m_manager.getValue(Value.BASE_ID);
		if (v == null)
			throw new VersionException();
		return v.getMembers(this);
	}

	/*
	 * @see flash.tools.debugger.Session#getFrames()
	 */
	public Frame[] getFrames() throws NotConnectedException
	{
		return m_manager.getFrames();
	}

	/**
	 * Asks the player to return information regarding our current context which includes
	 * this pointer, arguments for current frame, locals, etc.
	 */
	public void requestFrame(int depth) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (playerSupportsGet())
		{
			if (!isSuspended())
				throw new NotSuspendedException();

			int timeout = getPreference(SessionManager.PREF_CONTEXT_RESPONSE_TIMEOUT);

			DMessage dm = DMessageCache.alloc(4);
			dm.setType(DMessage.OutGetFrame);
			dm.putDWord(depth);  // depth of zero
			if (!simpleRequestResponseMessage(dm,  DMessage.InFrame, timeout)) {
				throw new NoResponseException(timeout);
			}

			pullUpActivationObjectVariables(depth);
		}
	}

	/**
	 * The compiler sometimes creates special local variables called
	 * "activation objects."  When it decides to do this (e.g. if the
	 * current function contains any anonymous functions, try/catch
	 * blocks, complicated E4X expressions, or "with" clauses), then
	 * all locals and arguments are actually stored as children of
	 * this activation object, rather than the usual way.
	 *
	 * We need to hide this implementation detail from the user.  So,
	 * if we find any activation objects among the locals of the current
	 * function, then we will "pull up" its members, and represent them
	 * as if they were actually args/locals of the function itself.
	 *
	 * @param depth the depth of the stackframe we are fixing; 0 is topmost
	 */
	private void pullUpActivationObjectVariables(int depth) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		DValue frame = m_manager.getValue(Value.BASE_ID-depth);
		DStackContext context = m_manager.getFrame(depth);		
		DVariable[] frameVars = (DVariable[]) frame.getMembers(this);
		Map<String, DVariable> varmap = new LinkedHashMap<String, DVariable>(frameVars.length); // preserves order
		List<DVariable> activationObjects = new ArrayList<DVariable>();
		Pattern activationObjectNamePattern = Pattern.compile("^.*\\$\\d+$"); //$NON-NLS-1$

		// loop through all frame variables, and separate them into two
		// groups: activation objects, and all others (locals and arguments)
		for (int i=0; i<frameVars.length; ++i)
		{
			DVariable member = frameVars[i];
			Matcher matcher = activationObjectNamePattern.matcher(member.getName());
			if (matcher.matches())
				activationObjects.add(member);
			else
				varmap.put(member.getName(), member);
		}

		// If there are no activation objects, then we don't need to do anything
		if (activationObjects.size() == 0)
			return;

		// overwrite existing args and locals with ones pulled from the activation objects
		for (int i=0; i<activationObjects.size(); ++i)
		{
			DVariable activationObject = activationObjects.get(i);
			DVariable[] activationMembers = (DVariable[]) activationObject.getValue().getMembers(this);
			for (int j=0; j<activationMembers.length; ++j)
			{
				DVariable member = activationMembers[j];
				int attributes = member.getAttributes();

				// For some odd reason, the activation object often contains a whole bunch of
				// other variables that we shouldn't be displaying.  I don't know what they
				// are, but I do know that they are all marked "static".
				if ((attributes & VariableAttribute.IS_STATIC) != 0)
					continue;

				// No matter what the activation object member's scope is, we want all locals
				// and arguments to be considered "public"
				attributes &= ~(VariableAttribute.PRIVATE_SCOPE | VariableAttribute.PROTECTED_SCOPE | VariableAttribute.NAMESPACE_SCOPE);
				attributes |= VariableAttribute.PUBLIC_SCOPE;
				member.setAttributes(attributes);

				String name = member.getName();
				DVariable oldvar = varmap.get(name);
				int vartype;
				if (oldvar != null)
					vartype = oldvar.getAttributes() & (VariableAttribute.IS_ARGUMENT | VariableAttribute.IS_LOCAL);
				else
					vartype = VariableAttribute.IS_LOCAL;
				member.setAttributes(member.getAttributes() | vartype);
				varmap.put(name, member);
			}

			context.convertLocalToActivationObject(activationObject);
		}

		for (DVariable var: varmap.values())
		{
			frame.addMember(var);
			if (var.isAttributeSet(VariableAttribute.IS_LOCAL))
			{
				context.addLocal(var);
			}
			else if (var.isAttributeSet(VariableAttribute.IS_ARGUMENT))
			{
				if (var.getName().equals("this")) //$NON-NLS-1$
					context.setThis(var);
				else
					context.addArgument(var);
			}
		}
	}

	/*
	 * @see flash.tools.debugger.Session#getValue(int)
	 */
	public Value getValue(long valueId) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		DValue val = null;

		if (!isSuspended())
			throw new NotSuspendedException();

		// get it from cache if we can
		val = m_manager.getValue(valueId);

		if (val == null)
		{
			// if a special variable, then we need to trigger a local frame call, otherwise just use id to get it
			if (valueId < Value.UNKNOWN_ID)
			{
				requestFrame(0); // force our current frame to get populated, BASE_ID will be available
			}
			else if (valueId > Value.UNKNOWN_ID)
			{
				requestVariable(valueId, null);
			}

			// after all this we should have our variable cache'd so try again if it wasn't there the first time
			val = m_manager.getValue(valueId);
		}

		return val;
	}

	/**
	 * Returns the current value object for the given id; never requests it from the player.
	 */
	public Value getRawValue(long valueId)
	{
		return m_manager.getValue(valueId);
	}

	/**
	 * Returns the previous value object for the given id -- that is, the value that that
	 * object had the last time the player was suspended.  Never requests it from the
	 * player (because it can't, of course).  Returns <code>null</code> if we don't have
	 * a value for that id.
	 */
	public Value getPreviousValue(long valueId)
	{
		return m_manager.getPreviousValue(valueId);
	}

	/**
	 * Launches a request to obtain all the members of the specified variable, and
	 * store them in the variable which would be returned by
	 * {@link DManager#getVariable(long)}.
	 *
	 * @param valueId id of variable whose members we want; underlying Variable must
	 * already be known by the PlayerSessionManager.
	 *
	 * @throws NoResponseException
	 * @throws NotConnectedException
	 * @throws NotSuspendedException
	 */
	void obtainMembers(long valueId) throws NoResponseException, NotConnectedException, NotSuspendedException
	{
		if (!isSuspended())
			throw new NotSuspendedException();

		// Get it from cache.  Normally, this should never fail; however, in
		// the case of Flex Builder, which is multithreaded, it is possible
		// that a thread has called this even after a different thread has
		// single-stepped, so that the original variable is no longer valid.
		// So, we'll check for a null return value.
		DValue v = m_manager.getValue(valueId);

		if (v != null && !v.membersObtained())
		{
			requestVariable(valueId, null, false, true);
		}
	}

	public Value getGlobal(String name) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		Value v = getValue(0, name);

		if (v==null || v.getType() == VariableType.UNDEFINED)
			return null;
		else
			return v;
	}

	/**
	 * Get the value of the variable named 'name' using varId
	 * as the context id for the Variable.
	 *
	 * This call is used to fire getters, where the id must
	 * be that of the original object and not the object id
	 * of where the getter actually lives.  For example
	 * a getter a() may live under o.__proto__.__proto__
	 * but you must use the id of o and the name of 'a'
	 * in order for the getter to fire correctly.  [Note: This
	 * paragraph was written for AS2; __proto__ doesn't exist
	 * in AS3.  TODO: revise this paragraph]
	 */
	public Value getValue(long varId, String name) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		Value v = null;
		if (isSuspended())
		{
			int fireGetter = getPreference(SessionManager.PREF_INVOKE_GETTERS);

			// disable children attaching to parent variables and clear our
			// most recently seen variable
			m_manager.clearLastVariable();
			m_manager.enableChildAttach(false);

			try
			{
				requestVariable(varId, name, (fireGetter != 0), false);

				DVariable lastVariable = m_manager.lastVariable();
				if (lastVariable != null)
					v = lastVariable.getValue();
				else
					v = DValue.forPrimitive(Value.UNDEFINED);
			}
			catch (NoResponseException e)
			{
				if (fireGetter != 0)
				{
					// We fired a getter -- most likely, what happened is that that getter
					// (which is actual code in the user's movie) just took too long to
					// calculate its value.  So rather than throwing an exception, we store
					// some error text for the value of the variable itself.
					//
					// TODO [mmorearty 4/20/06] Even though I wrote the below code, I now
					// am wondering if it is incorrect that I am calling addVariableMember(),
					// because in every other case, this function does not add members to
					// existing objects.  Need to revisit this.
					v = new DValue(VariableType.STRING, "String", "String", ValueAttribute.IS_EXCEPTION, //$NON-NLS-1$ //$NON-NLS-2$
							e.getLocalizedMessage());
					if (varId != 0) {
						DVariable var = new DVariable(name, (DValue)v);
						m_manager.enableChildAttach(true);
						m_manager.addVariableMember(varId, var);
					}
				}
				else
				{
					throw e; // re-throw
				}
			}
			finally
			{
				// reset our attach flag, so that children attach to parent variables.
				m_manager.enableChildAttach(true);
			}
		}
		else
			throw new NotSuspendedException();

		return v;
	}

	private void requestVariable(long id, String name) throws NoResponseException, NotConnectedException, NotSuspendedException
	{
		requestVariable(id, name, false, false);
	}

	/**
	 * @param thisValue the value of the "this" pointer; meaningless if isConstructor is true
	 * @param isConstructor whether we're calling a constructor as opposed to a regular function
	 * @param funcname the name of the function to call (or class whose constructor we're calling)
	 * @param args the args to the function
	 * @return the return value of the function
	 */
	private Value callFunction(Value thisValue, boolean isConstructor, String funcname, Value[] args) throws PlayerDebugException
	{
		if (!isSuspended())
			throw new NotSuspendedException();

		if (!playerCanCallFunctions())
			throw new NotSupportedException(PlayerSessionManager.getLocalizationManager().getLocalizedTextString("functionCallsNotSupported")); //$NON-NLS-1$

		// name = getRawMemberName(id, name);

		m_manager.clearLastFunctionCall();

		DMessage dm = buildCallFunctionMessage(isConstructor, thisValue, funcname, args);

		// make sure any exception during the setter gets held onto
		m_manager.beginPlayerCodeExecution();

		// TODO wrong timeout
		int timeout = getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT);
		timeout += 500; // give the player enough time to raise its timeout exception

		boolean result = simpleRequestResponseMessage(dm, DMessage.InCallFunction, timeout);

		// tell manager we're done; ignore returned FaultEvent
		m_manager.endPlayerCodeExecution();

		if (!result)
			throw new NoResponseException(timeout);

		DVariable lastFunctionCall = m_manager.lastFunctionCall();
		if (lastFunctionCall != null)
			return lastFunctionCall.getValue();
		else
			return DValue.forPrimitive(Value.UNDEFINED);
	}

	/*
	 * @see flash.tools.debugger.Session#callFunction(flash.tools.debugger.Value, java.lang.String, flash.tools.debugger.Value[])
	 */
	public Value callFunction(Value thisValue, String funcname, Value[] args) throws PlayerDebugException
	{
		Value retval = callPseudoFunction(thisValue, funcname, args);
		if (retval != null) {
			return retval;
		}

		return callFunction(thisValue, false, funcname, args);
	}

	/**
	 * Checks to see if the function being called is a debugger pseudofunction such as
	 * $obj(), and if so, handles that directly rather than calling the player.  Returns
	 * null if the function being called is not a pseudofunction.
	 */
	private Value callPseudoFunction(Value thisValue, String funcname, Value[] args) throws PlayerDebugException{
		if (thisValue.getType() == VariableType.UNDEFINED || thisValue.getType() == VariableType.NULL) {
			if ("$obj".equals(funcname)) { //$NON-NLS-1$
				return callObjPseudoFunction(args);
			}
		}

		return null;
	}

	/**
	 * Handles a call to the debugger pseudofunction $obj() -- e.g. $obj(1234) returns
	 * a pointer to the object with id 1234.
	 */
	private Value callObjPseudoFunction(Value[] args) throws PlayerDebugException {
		if (args.length != 1) {
			return DValue.forPrimitive(DValue.UNDEFINED);
		}
		double arg = ECMA.toNumber(this, args[0]);
		long id = (long) arg;
		if (id != arg) {
			return DValue.forPrimitive(DValue.UNDEFINED);
		}
		DValue value = m_manager.getValue(id);
		if (value == null) {
			return DValue.forPrimitive(DValue.UNDEFINED);
		}
		return value;
	}

	public Value callConstructor(String funcname, Value[] args) throws PlayerDebugException
	{
		return callFunction(DValue.forPrimitive(null), true, funcname, args);
	}

	private DMessage buildCallFunctionMessage(boolean isConstructor, Value thisValue, String funcname, Value[] args)
	{
		funcname = (funcname == null) ? "" : funcname; //$NON-NLS-1$

		int messageSize = 8; // DWORD representing flags + DWORD representing frame
		String thisType = DVariable.typeNameFor(thisValue.getType());
		String thisValueString = thisValue.getValueAsString();
		messageSize += DMessage.getStringLength(thisType)+1;
		messageSize += DMessage.getStringLength(thisValueString)+1;
		messageSize += DMessage.getStringLength(funcname)+1;
		messageSize += 4; // DWORD representing the number of args
		String[] argTypes = new String[args.length];
		String[] argValues = new String[args.length];
		for (int i=0; i<args.length; ++i)
		{
			argTypes[i] = DVariable.typeNameFor(args[i].getType());
			argValues[i] = args[i].getValueAsString();
			messageSize += DMessage.getStringLength(argValues[i])+1;
			messageSize += DMessage.getStringLength(argTypes[i])+1;
		}

		DMessage dm = DMessageCache.alloc(messageSize);
		dm.setType(DMessage.OutCallFunction);
		try
		{
			dm.putDWord(isConstructor ? 1 : 0);
			dm.putDWord(0); // TODO: the currently active frame number
			dm.putString(thisType);
			dm.putString(thisValueString);
			dm.putString(funcname);
			dm.putDWord(args.length);
			for (int i=0; i<args.length; ++i)
			{
				dm.putString(argTypes[i]);
				dm.putString(argValues[i]);
			}
		}
		catch(UnsupportedEncodingException uee)
		{
			// couldn't write out the string, so just terminate it and complete anyway
			dm.putByte((byte)'\0');
		}

		return dm;
	}

	private void requestVariable(long id, String name, boolean fireGetter, boolean alsoGetChildren) throws NoResponseException, NotConnectedException, NotSuspendedException
	{
		if (!isSuspended())
			throw new NotSuspendedException();

		name = getRawMemberName(id, name);

		DMessage dm = buildOutGetMessage(id, name, fireGetter, alsoGetChildren);

		// make sure any exception during the setter gets held onto
		m_manager.beginPlayerCodeExecution();

		int timeout = getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT);
		timeout += 500; // give the player enough time to raise its timeout exception

		boolean result = simpleRequestResponseMessage(dm, DMessage.InGetVariable, timeout);

		// tell manager we're done; ignore returned FaultEvent
		m_manager.endPlayerCodeExecution();

		if (!result)
			throw new NoResponseException(timeout);
	}

	private DMessage buildOutGetMessage(long id, String name, boolean fireGetter, boolean alsoGetChildren)
	{
		final int FLAGS_SIZE = 4;
		name = (name == null) ? "" : name; //$NON-NLS-1$

		DMessage dm = DMessageCache.alloc(DMessage.getSizeofPtr() + DMessage.getStringLength(name)+1 + FLAGS_SIZE);
		dm.setType( (!fireGetter) ? DMessage.OutGetVariable : DMessage.OutGetVariableWhichInvokesGetter );
		dm.putPtr(id);
		try
		{
			dm.putString(name);
		}
		catch(UnsupportedEncodingException uee)
		{
			// couldn't write out the string, so just terminate it and complete anyway
			dm.putByte((byte)'\0');
		}

		// as an optimization, newer player builds allow us to tell them not to
		// send all the children of an object along with the object, because
		// frequently we don't care about the children
		int flags = GetVariableFlag.DONT_GET_FUNCTIONS; // we never want functions
		if (fireGetter)
			flags |= GetVariableFlag.INVOKE_GETTER;
		if (alsoGetChildren)
			flags |= GetVariableFlag.ALSO_GET_CHILDREN | GetVariableFlag.GET_CLASS_HIERARCHY;
		dm.putDWord(flags);

		return dm;
	}

	public FaultEvent setScalarMember(long varId, String memberName, int type, String value) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (!isSuspended())
			throw new NotSuspendedException();

		// If the varId is that of a stack frame, then we need to check whether that
		// stack frame has an "activation object".  If it does, then all of the
		// arguments and locals are actually kept as members of that activation
		// object, and so we need to change varId to be the ID of that activation
		// object -- that way, the player will modify the member of the activation
		// object rather than modifying the "regular" argument or local.  See bug
		// 155031.
		if (varId <= Value.BASE_ID && varId > Value.LEVEL_ID)
		{
			int depth = (int) (Value.BASE_ID - varId);
			DStackContext context = m_manager.getFrame(depth);
			DVariable activationObject = context.getActivationObject();
			if (activationObject != null)
				varId = activationObject.getValue().getId();
		}

		memberName = getRawMemberName(varId, memberName);

		// see if it is our any of our special variables
		FaultEvent faultEvent = requestSetVariable( isPseudoVarId(varId) ? 0 : varId, memberName, type, value);

		// now that we sent it out, we need to clear our variable cache
		// if it is our special context then mark the frame as stale.
		if (isPseudoVarId(varId) && m_manager.getFrameCount() > 0)
		{
			m_manager.getFrame(0).markStale();
		}
		else
		{
			DValue parent = m_manager.getValue(varId);
			if (parent != null)
				parent.removeAllMembers();
		}

		return faultEvent;
	}

	/**
	 * Returns whether a variable ID is "real" or not.  For example,
	 * Value.THIS_ID is a "pseudo" varId, as are all the other special
	 * hard-coded varIds in the Value class.
	 */
	private boolean isPseudoVarId(long varId)
	{
		/*
		 * Unfortunately, this is actually just taking a guess.  The old code
		 * used "varId &lt; 0"; however, the Linux player sometimes has real
		 * variable IDs which are less than zero.
		 */
		return (varId < 0 && varId > -65535);
	}

	/**
	 * <code>memberName</code> might be just <code>"varname"</code>, or it
	 * might be <code>"namespace::varname"</code>, or it might be
	 * <code>"namespace@hexaddr::varname"</code>.  In the third case, it is
	 * fully resolved, and there is nothing we need to do.  But in the first
	 * and second cases, we may need to fully resolve it so that the Player
	 * will recognize it.
	 */
	private String getRawMemberName(long parentValueId, String memberName)
	{
		if (memberName != null)
		{
			DValue parent = m_manager.getValue(parentValueId);
			if (parent != null)
			{
				int doubleColon = memberName.indexOf("::"); //$NON-NLS-1$
				String shortName = (doubleColon==-1) ? memberName : memberName.substring(doubleColon+2);
				DVariable member = parent.findMember(shortName);
				if (member != null)
					memberName = member.getRawName();
			}
		}
		return memberName;
	}

	/**
	 * @return null for success, or fault event if a setter in the player threw an exception
	 */
	private FaultEvent requestSetVariable(long id, String name, int t, String value) throws NoResponseException
	{
		// convert type to typeName
		String type = DVariable.typeNameFor(t);
		DMessage dm = buildOutSetMessage(id, name, type, value);
		FaultEvent faultEvent = null;
//		System.out.println("setmsg id="+id+",name="+name+",t="+type+",value="+value);

		// make sure any exception during the setter gets held onto
		m_manager.beginPlayerCodeExecution();

		// turn off squelch so we can hear the response
		sendSquelch(false);

		int timeout = getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT);

		if (!simpleRequestResponseMessage(dm, (t == VariableType.STRING) ? DMessage.InSetVariable : DMessage.InSetVariable2, timeout))
			throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));

		// turn it back on
		sendSquelch(true);

		// tell manager we're done, and get exception if any
		faultEvent = m_manager.endPlayerCodeExecution();

		// hammer the variable cache and context array
		m_manager.freeValueCache();
		return faultEvent;
	}

	private DMessage buildOutSetMessage(long id, String name, String type, String v)
	{
		DMessage dm = DMessageCache.alloc(DMessage.getSizeofPtr()+
				DMessage.getStringLength(name)+
				DMessage.getStringLength(type)+
				DMessage.getStringLength(v)+
				3);
		dm.setType(DMessage.OutSetVariable);
		dm.putPtr(id);
		try { dm.putString(name); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		try { dm.putString(type); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		try { dm.putString(v); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		return dm;
	}

	/*
	 * @see flash.tools.debugger.Session#waitForEvent()
	 */
	public void waitForEvent() throws NotConnectedException, InterruptedException
	{
		Object eventNotifier = m_manager.getEventNotifier();
		synchronized (eventNotifier)
		{
			while (getEventCount() == 0 && isConnected())
			{
				eventNotifier.wait();
			}
		}

		// We should NOT call isConnected() to test for a broken connection!  That
		// is because we may have received one or more events AND lost the connection,
		// almost simultaneously.  If there are any messages available for the
		// caller to process, we should not throw an exception.
		if (getEventCount() == 0 && !isConnected())
			throw new NotConnectedException();
	}

	/*
	 * @see flash.tools.debugger.Session#getEventCount()
	 */
	public int getEventCount()
	{
		return m_manager.getEventCount();
	}

	/*
	 * @see flash.tools.debugger.Session#nextEvent()
	 */
	public DebugEvent nextEvent()
	{
		return m_manager.nextEvent();
	}

	/**
	 * Adds a watchpoint on the given expression
	 * @throws NotConnectedException
	 * @throws NoResponseException
	 * @throws NotSupportedException
	 * @throws NotSuspendedException
	 */
	public boolean addWatch(long varId, String varName, int type, int tag) throws NoResponseException, NotConnectedException, NotSupportedException
	{
		// TODO check for NoResponse, NotConnected

		if (!supportsWatchpoints())
			throw new NotSupportedException(PlayerSessionManager.getLocalizationManager().getLocalizedTextString("watchpointsNotSupported")); //$NON-NLS-1$

		varName = getRawMemberName(varId, varName);
		DMessage dm = DMessageCache.alloc(4+DMessage.getSizeofPtr()+DMessage.getStringLength(varName)+1);
		dm.setType(DMessage.OutAddWatch2);
		dm.putPtr(varId);
		try { dm.putString(varName); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		dm.putWord(type);
		dm.putWord(tag);

		int timeout = getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT);
		boolean result = simpleRequestResponseMessage(dm, DMessage.InWatch2, timeout);
		return result;
	}

	/**
	 * Removes a watchpoint on the given expression
	 * @throws NotConnectedException
	 * @throws NoResponseException
	 * @throws NotSuspendedException
	 */
	public boolean removeWatch(long varId, String memberName) throws NoResponseException, NotConnectedException
	{
		memberName = getRawMemberName(varId, memberName);
		DMessage dm = DMessageCache.alloc(DMessage.getSizeofPtr()+DMessage.getStringLength(memberName)+1);
		dm.setType(DMessage.OutRemoveWatch2);
		dm.putPtr(varId);
		try { dm.putString(memberName); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }

		int timeout = getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT);
		boolean result = simpleRequestResponseMessage(dm, DMessage.InWatch2, timeout);
		return result;
	}

	/**
	 * Send a message that contains no data
	 */
	void sendMessage(int message)
	{
		DMessage dm = DMessageCache.alloc(0);
		dm.setType(message);
		sendMessage(dm);
	}

	/**
	 * Send a fully formed message and release it when done
	 */
	synchronized void sendMessage(DMessage dm)
	{
		try
		{
			m_protocol.txMessage(dm);

			if (m_debugMsgOn || m_debugMsgFileOn)
				trace(dm, false);
		}
		catch(IOException io)
		{
			if (Trace.error)
			{
				Trace.trace("Attempt to send message "+dm.outToString()+" failed"); //$NON-NLS-1$ //$NON-NLS-2$
				io.printStackTrace();
			}
		}
		DMessageCache.free(dm);
	}


	/**
	 * Tell the player to shut-up
	 */
	boolean sendSquelch(boolean on)
	{
		boolean responded;
		DMessage dm = DMessageCache.alloc(4);
		dm.setType(DMessage.OutSetSquelch);
		dm.putDWord( on ? 1 : 0);
		responded = simpleRequestResponseMessage(dm, DMessage.InSquelch);
		return responded;
	}

	void sendStopWarning()
	{
		// Currently, "disable_script_stuck_dialog" only works for AS2, not for AS3.
		String option = "disable_script_stuck_dialog"; //$NON-NLS-1$
		String value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);

		// HACK: Completely disable the script-stuck notifications, so that we can
		// get AS3 debugging working.
		option = "disable_script_stuck"; //$NON-NLS-1$
		value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendStopOnFault()
	{
		String option = "break_on_fault"; //$NON-NLS-1$
		String value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendEnumerateOverride()
	{
		String option = "enumerate_override"; //$NON-NLS-1$
		String value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendFailureNotify()
	{
		String option = "notify_on_failure"; //$NON-NLS-1$
		String value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendInvokeSetters()
	{
		String option = "invoke_setters"; //$NON-NLS-1$
		String value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendSwfloadNotify()
	{
		String option = "swf_load_messages"; //$NON-NLS-1$
		String value = "on"; //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendConsoleErrorsAsTrace(boolean on)
	{
		String option = "console_errors"; //$NON-NLS-1$
		String value = (on) ? "on" : "off"; //$NON-NLS-1$ //$NON-NLS-2$

		sendOptionMessage(option, value);
	}

	void sendGetterTimeout()
	{
		String option = "getter_timeout"; //$NON-NLS-1$
		String value = "" + getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT); //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendSetterTimeout()
	{
		String option = "setter_timeout"; //$NON-NLS-1$
		String value = "" + getPreference(SessionManager.PREF_SETVAR_RESPONSE_TIMEOUT); //$NON-NLS-1$

		sendOptionMessage(option, value);
	}

	void sendOptionMessage(String option, String value)
	{
		int msgSize = DMessage.getStringLength(option)+DMessage.getStringLength(value)+2;  // add 2 for trailing nulls of each string

		DMessage dm = DMessageCache.alloc(msgSize);
		dm.setType(DMessage.OutSetOption);
		try { dm.putString(option); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		try { dm.putString(value); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		simpleRequestResponseMessage(dm, DMessage.InOption);
	}

	public boolean supportsWatchpoints()
	{
		if (m_playerSupportsWatchpoints == null)
			m_playerSupportsWatchpoints = new Boolean(getOption("can_set_watchpoints", false)); //$NON-NLS-1$
		return m_playerSupportsWatchpoints.booleanValue();
	}

	public boolean playerCanBreakOnAllExceptions()
	{
		if (m_playerCanBreakOnAllExceptions == null)
			m_playerCanBreakOnAllExceptions = new Boolean(getOption("can_break_on_all_exceptions", false)); //$NON-NLS-1$
		return m_playerCanBreakOnAllExceptions.booleanValue();
	}

	public boolean playerCanTerminate()
	{
		return getOption("can_terminate", false); //$NON-NLS-1$
	}

	public boolean playerCanCallFunctions()
	{
		if (m_playerCanCallFunctions == null)
			m_playerCanCallFunctions = new Boolean(getOption("can_call_functions", false)); //$NON-NLS-1$
		return m_playerCanCallFunctions.booleanValue();
	}

	/**
	 * Returns the value of a Flash Player boolean option that was requested by
	 * OutGetOption and returned by InOption.
	 *
	 * @param optionName
	 *            the name of the option
	 * @return its value, or null
	 */
	public boolean getOption(String optionName, boolean defaultValue)
	{
		boolean retval = defaultValue;
		String optionValue = getOption(optionName, null);

		if (optionValue != null)
			retval = Boolean.valueOf(optionValue).booleanValue();

		return retval;
	}

	/**
	 * Returns the value of a Flash Player string option that was requested by
	 * OutGetOption and returned by InOption.
	 *
	 * @param optionName
	 *            the name of the option
	 * @return its value, or null
	 */
	public String getOption(String optionName, String defaultValue)
	{
		String optionValue = defaultValue;

		int msgSize = DMessage.getStringLength(optionName)+1;  // add 1 for trailing null of string

		DMessage dm = DMessageCache.alloc(msgSize);
		dm.setType(DMessage.OutGetOption);
		try { dm.putString(optionName); } catch(UnsupportedEncodingException uee) { dm.putByte((byte)'\0'); }
		if (simpleRequestResponseMessage(dm, DMessage.InOption))
			optionValue = m_manager.getOption(optionName);
		return optionValue;
	}

	/**
	 * Send our message and assume that the next response that is received is
	 * ours.  Primitive but there is no use in setting up a full request / response
	 * pattern since the player doesn't follow it.
	 *
	 * @return false is no response.
	 */
	boolean simpleRequestResponseMessage(DMessage msg, int msgType, int timeout)
	{
		boolean response = false;

		// use default or user supplied timeout
		timeout = (timeout > 0) ? timeout : getPreference(SessionManager.PREF_RESPONSE_TIMEOUT);

		// note the number of messages of this type before our send
		DMessageCounter msgCounter = getMessageCounter();
		long num = msgCounter.getInCount(msgType);
		long expect = num+1;

		// send the message
		sendMessage(msg);

		long startTime = System.currentTimeMillis();
//		System.out.println("sending- "+DMessage.outTypeName(msg.getType())+",timeout="+timeout+",start="+start);

		// now wait till we see a message come in
		m_incoming = false;
		synchronized (msgCounter.getInLock())
		{
			while( (expect > msgCounter.getInCount(msgType)) &&
					System.currentTimeMillis() < startTime + timeout &&
					isConnected())
			{
				// block until the message counter tells us that some message has been received
				try
				{
					msgCounter.getInLock().wait(timeout);
				}
				catch (InterruptedException e)
				{
					// this should never happen
					e.printStackTrace();
				}

				// if we see incoming messages, then we should reset our timeout
				synchronized (this)
				{
					if (m_incoming)
					{
						startTime = System.currentTimeMillis();
						m_incoming = false;
					}
				}
			}
		}

		if (msgCounter.getInCount(msgType) >= expect)
			response = true;
		else if (timeout <= 0 && Trace.error)
			Trace.trace("Timed-out waiting for "+DMessage.inTypeName(msgType)+" response to message "+msg.outToString()); //$NON-NLS-1$ //$NON-NLS-2$

//		long endTime = System.currentTimeMillis();
//		System.out.println("    response- "+response+",timeout="+timeout+",elapsed="+(endTime-startTime));
		m_lastResponse = response;
		return response;
	}

	// use default timeout
	boolean simpleRequestResponseMessage(DMessage msg, int msgType) 	{ return simpleRequestResponseMessage(msg, msgType, -1); 	}
	boolean simpleRequestResponseMessage(int msg, int msgType)			{ return simpleRequestResponseMessage(msg, msgType, -1); 	}

	// Convenience function
	boolean simpleRequestResponseMessage(int msg, int msgType, int timeout)
	{
		DMessage dm = DMessageCache.alloc(0);
		dm.setType(msg);
		return simpleRequestResponseMessage(dm, msgType, timeout);
	}

	/**
	 * We register ourself as a listener to DMessages from the pipe for the
	 * sole purpose of monitoring the state of the debugger.  All other
	 * object management occurs with DManager
	 */
	/**
	 * Issued when the socket connection to the player is cut
	 */
	public void disconnected()
	{
		m_isHalted = false;
		m_isConnected = false;
		m_manager.disconnected();
	}

	/**
	 * This is the core routine for decoding incoming messages and deciding what should be
	 * done with them.  We have registered ourself with DProtocol to be notified when any
	 * incoming messages have been received.
	 *
	 * It is important to note that we should not rely on the contents of the message
	 * since it may be reused after we exit this method.
	 */
	public void messageArrived(DMessage msg, DProtocol which)
	{
		preMessageArrived(msg, which);
		msg.reset(); // allow the message to be re-parsed
		m_manager.messageArrived(msg, which);
		msg.reset(); // allow the message to be re-parsed
		postMessageArrived(msg, which);
	}

	/**
	 * Processes the message before it is passed to the DManager.
	 */
	private void preMessageArrived(DMessage msg, DProtocol which)
	{
		switch (msg.getType())
		{
			case DMessage.InAskBreakpoints:
			case DMessage.InBreakAt:
			case DMessage.InBreakAtExt:
			{
				// We need to set m_isHalted to true before the DManager processes
				// the message, because the DManager may add a BreakEvent to the
				// event queue, which the host debugger may immediately process;
				// if the debugger calls back to the Session, the Session must be
				// correctly marked as halted.
				m_isHalted = true;
				break;
			}
		}
	}

	/**
	 * Processes the message after it has been passed to the DManager.
	 */
	private void postMessageArrived(DMessage msg, DProtocol which)
	{
		if (m_debugMsgOn || m_debugMsgFileOn)
			trace(msg, true);

		/* at this point we just open up a big switch statement and walk through all possible cases */
		int type = msg.getType();
		switch(type)
		{
			case DMessage.InExit:
			{
				m_isConnected = false;
				break;
			}

			case DMessage.InProcessTag:
			{
				// need to send a response to this message to keep the player going
				sendMessage(DMessage.OutProcessedTag);
				break;
			}

			case DMessage.InContinue:
			{
				m_isHalted = false;
				break;
			}

			case DMessage.InOption:
			{
				String s = msg.getString();
				String v = msg.getString();

				// add it to our properties, for DEBUG purposes only
				m_prefs.put(s, v);
				break;
			}

			case DMessage.InSwfInfo:
			case DMessage.InScript:
			case DMessage.InRemoveScript:
			{
				m_evalIsAndInstanceofCache.clear();
				m_incoming = true;
				break;
			}

			default:
			{
				/**
				 * Simple indicator that we have received a message.  We
				 * put this indicator in default so that InProcessTag msgs
				 * wouldn't generate false triggers.  Mainly, we want to
				 * reset our timeout counter when we receive trace messages.
				 */
				m_incoming = true;
				break;
			}
		}

		// something came in so assume that we can now talk
		// to the player
		m_lastResponse = true;
	}

    /**
     * A background thread which wakes up periodically and fetches the SWF and SWD
     * from the Player for new movies that have loaded.  It then uses these to create
	 * an instance of MovieMetaData (a class shared with the Profiler) from which
	 * fdb can cull function names.
     * This work is done on a background thread because it can take several
     * seconds, and we want the fdb user to be able to execute other commands
     * while it is happening.
     */
    public void run()
    {
    	long last = 0;
		while(isConnected())
		{
			// try every 250ms
			try { Thread.sleep(250); } catch(InterruptedException ie) {}

			try
			{
				// let's make sure that the traffic level is low before
				// we do our requests.
				long current = m_protocol.messagesReceived();
				long delta = last - current;
				last = current;

				// if the last message that went out was not responded to
				// or we are not suspended and have high traffic
				// then wait for later.
				if (!m_lastResponse || (!isSuspended() && delta > 5))
					throw new NotSuspendedException();

				// we are either suspended or low enough traffic

				// get the list of swfs we have
				int count = m_manager.getSwfInfoCount();
				for(int i=0; i<count; i++)
				{
					DSwfInfo info = m_manager.getSwfInfo(i);

					// no need to process if it's been removed
					if (info == null || info.isUnloaded() || info.isPopulated() || (info.getVmVersion() > 0) )
						continue;

					// see if the swd has been loaded, throws exception if unable to load it.
					// Also triggers a callback into the info object to freshen its contents
					// if successful
					info.getSwdSize(this);

                    // check since our vm version info could get updated in between.
                    if (info.getVmVersion() > 0)
                    {
                        // mark it populated if we haven't already done so
                        info.setPopulated();
                        continue;
                    }

					// so by this point we know that we've got good swd data,
					// or we've made too many attempts and gave up.
					if (!info.isSwdLoading() && !info.isUnloaded())
					{
						// now load the swf, if we haven't already got it
						if (info.getSwf() == null && !info.isUnloaded())
							info.setSwf(requestSwf(i));

						// only get the swd if we haven't got it
						if (info.getSwd() == null && !info.isUnloaded())
							info.setSwd(requestSwd(i));

						try
						{
							// now go populate the functions tables...
							if (!info.isUnloaded())
								info.parseSwfSwd(m_manager);
						}
						catch(Throwable e)
						{
							// oh this is not good and means that we should probably
							// give up.
							if (Trace.error)
							{
								Trace.trace("Error while parsing swf/swd '"+info.getUrl()+"'. Giving up and marking it processed"); //$NON-NLS-1$ //$NON-NLS-2$
								e.printStackTrace();
							}

							info.setPopulated();
						}
					}
				}
			}
			catch(InProgressException ipe)
			{
				// swd is still loading so give us a bit of
				// time and then come back and try again
			}
			catch(NoResponseException nre)
			{
				// timed out on one of our requests so don't bother
				// continuing right now,  try again later
			}
			catch(NotSuspendedException nse)
			{
				// probably want to wait until we are halted before
				// doing this heavy action
			}
			catch(Exception e)
			{
				// maybe not good
				if (Trace.error)
				{
					Trace.trace("Exception in background swf/swd processing thread"); //$NON-NLS-1$
					e.printStackTrace();
				}
			}
		}
    }

	byte[] requestSwf(int index) throws NoResponseException
	{
		/* send the message */
		int to = getPreference(SessionManager.PREF_SWFSWD_LOAD_TIMEOUT);
		byte[] swf = null;

		// the query
		DMessage dm = DMessageCache.alloc(2);
		dm.setType(DMessage.OutGetSwf);
		dm.putWord(index);

		if (simpleRequestResponseMessage(dm, DMessage.InGetSwf, to))
			swf = m_manager.getSWF();
		else
			throw new NoResponseException(to);

		return swf;
	}

	byte[] requestSwd(int index) throws NoResponseException
	{
		/* send the message */
		int to = getPreference(SessionManager.PREF_SWFSWD_LOAD_TIMEOUT);
		byte[] swd = null;

		// the query
		DMessage dm = DMessageCache.alloc(2);
		dm.setType(DMessage.OutGetSwd);
		dm.putWord(index);

		if (simpleRequestResponseMessage(dm, DMessage.InGetSwd, to))
			swd = m_manager.getSWD();
		else
			throw new NoResponseException(to);

		return swd;
	}

	//
	// Debug purposes only.  Dump contents of our messages to the screen
	// and/or file.
	//
	synchronized void trace(DMessage dm, boolean in)
	{
		try
		{
			if (m_debugMsgOn)
				System.out.println( (in) ? dm.inToString(m_debugMsgSize) : dm.outToString(m_debugMsgSize) );

			if (m_debugMsgFileOn)
			{
				traceFile().write( (in) ? dm.inToString(m_debugMsgFileSize) : dm.outToString(m_debugMsgFileSize) );
				m_trace.write(s_newline);
				m_trace.flush();
			}
		}
		catch(Exception e) {}
	}

	// i/o for tracing
    java.io.Writer m_trace;

	java.io.Writer traceFile() throws IOException
	{
		if (m_trace == null)
		{
			m_trace = new java.io.FileWriter("mm_debug_api_trace.txt"); //$NON-NLS-1$
			try { m_trace.write(new java.util.Date().toString()); } catch(Exception e) { m_trace.write("Date unknown"); } //$NON-NLS-1$
			try
			{
				m_trace.write(s_newline);

				// java properties dump
				java.util.Properties props = System.getProperties();
				props.list(new java.io.PrintWriter(m_trace));

				m_trace.write(s_newline);

				// property dump
				for (String key: m_prefs.keySet())
				{
					Object value = m_prefs.get(key);
					m_trace.write(key);
					m_trace.write(" = "); //$NON-NLS-1$
					m_trace.write(value.toString());
					m_trace.write(s_newline);
				}
			}
			catch(Exception e) { if (Trace.error) e.printStackTrace(); }
			m_trace.write(s_newline);
		}
		return m_trace;
	}

	public void setLaunchUrl(String url)
	{
		if (url.startsWith("/")) { //$NON-NLS-1$
			url = "file://" + url; //$NON-NLS-1$
		}
		m_launchUrl = url;
	}

	public void setAIRLaunchInfo(AIRLaunchInfo airLaunchInfo)
	{
		m_airLaunchInfo = airLaunchInfo;
	}

	public void breakOnCaughtExceptions(boolean b) throws NotSupportedException, NoResponseException {
		if (!playerCanBreakOnAllExceptions())
			throw new NotSupportedException(PlayerSessionManager.getLocalizationManager().getLocalizedTextString("exceptionBreakpointsNotSupported")); //$NON-NLS-1$

		DMessage dm = DMessageCache.alloc(1);
		dm.setType(DMessage.OutPassAllExceptionsToDebugger);
		dm.putByte((byte)(b ? 1 : 0));
		sendMessage(dm);
		if (!simpleRequestResponseMessage(dm, DMessage.InPassAllExceptionsToDebugger))
			throw new NoResponseException(getPreference(SessionManager.PREF_RESPONSE_TIMEOUT));
	}

	public boolean evalIs(Value value, Value type) throws PlayerDebugException, PlayerFaultException
	{
		return evalIsOrInstanceof(BinaryOp.Is, value, type);
	}

	public boolean evalIs(Value value, String type) throws PlayerDebugException, PlayerFaultException
	{
		return evalIsOrInstanceof(BinaryOp.Is, value, type);
	}

	public boolean evalInstanceof(Value value, Value type) throws PlayerDebugException, PlayerFaultException
	{
		return evalIsOrInstanceof(BinaryOp.Instanceof, value, type);
	}

	public boolean evalInstanceof(Value value, String type) throws PlayerDebugException, PlayerFaultException
	{
		return evalIsOrInstanceof(BinaryOp.Instanceof, value, type);
	}

	private boolean evalIsOrInstanceof(BinaryOp op, Value value, Value type) throws PlayerDebugException, PlayerFaultException
	{
		String key = value.getTypeName() + " " + op + " " + type.getTypeName(); //$NON-NLS-1$ //$NON-NLS-2$
		Boolean retval = m_evalIsAndInstanceofCache.get(key);
		if (retval == null)
		{
			retval = new Boolean(ECMA.toBoolean(evalBinaryOp(op, value, type)));
			m_evalIsAndInstanceofCache.put(key, retval);
		}

		return retval.booleanValue();
	}

	private boolean evalIsOrInstanceof(BinaryOp op, Value value, String type) throws PlayerDebugException, PlayerFaultException
	{
		String key = value.getTypeName() + " " + op + " " + type; //$NON-NLS-1$ //$NON-NLS-2$
		Boolean retval = m_evalIsAndInstanceofCache.get(key);
		if (retval == null)
		{
			Value typeval = getGlobal(type);
			if (typeval == null)
				retval = Boolean.FALSE;
			else
				retval = new Boolean(ECMA.toBoolean(evalBinaryOp(op, value, typeval)));
			m_evalIsAndInstanceofCache.put(key, retval);
		}

		return retval.booleanValue();
	}

	public boolean evalIn(Value property, Value object) throws PlayerDebugException, PlayerFaultException
	{
		return ECMA.toBoolean(evalBinaryOp(BinaryOp.In, property, object));
	}

	public Value evalAs(Value value, Value type) throws PlayerDebugException, PlayerFaultException {
		return evalBinaryOp(BinaryOp.As, value, type);
	}

	private Value evalBinaryOp(BinaryOp op, Value lhs, Value rhs) throws PlayerDebugException, PlayerFaultException
	{
		if (!isSuspended())
			throw new NotSuspendedException();

		if (!playerCanCallFunctions())
		{
			Map<String,String> parameters = new HashMap<String,String>();
			parameters.put("operator", op.getName()); //$NON-NLS-1$
			String message = PlayerSessionManager.getLocalizationManager().getLocalizedTextString("operatorNotSupported", parameters); //$NON-NLS-1$
			throw new NotSupportedException(message);
		}

		int id = (int) (Math.random() * 65536); // good 'nuff
		DMessage dm = buildBinaryOpMessage(id, op, lhs, rhs);

		m_manager.clearLastBinaryOp();

		// make sure any exception gets held onto
		m_manager.beginPlayerCodeExecution();

		// TODO wrong timeout
		int timeout = getPreference(SessionManager.PREF_GETVAR_RESPONSE_TIMEOUT);
		timeout += 500; // give the player enough time to raise its timeout exception

		boolean result = simpleRequestResponseMessage(dm, DMessage.InBinaryOp, timeout);

		// tell manager we're done; ignore returned FaultEvent
		m_manager.endPlayerCodeExecution();

		if (!result)
			throw new NoResponseException(timeout);

		DVariable lastBinaryOp = m_manager.lastBinaryOp();
		Value v;
		if (lastBinaryOp != null)
			v = lastBinaryOp.getValue();
		else
			v = DValue.forPrimitive(Value.UNDEFINED);

		if (v.isAttributeSet(ValueAttribute.IS_EXCEPTION))
			throw new PlayerFaultException(new ExceptionFault(v.getValueAsString(), false, v));

		return v;
	}

	private DMessage buildBinaryOpMessage(int id, BinaryOp op, Value lhs, Value rhs) {
		int messageSize = 5; // DWORD representing id + byte representing op
		String lhsType = DVariable.typeNameFor(lhs.getType());
		String lhsValueString = lhs.getValueAsString();
		String rhsType = DVariable.typeNameFor(rhs.getType());
		String rhsValueString = rhs.getValueAsString();
		messageSize += DMessage.getStringLength(lhsType)+1;
		messageSize += DMessage.getStringLength(lhsValueString)+1;
		messageSize += DMessage.getStringLength(rhsType)+1;
		messageSize += DMessage.getStringLength(rhsValueString)+1;

		DMessage dm = DMessageCache.alloc(messageSize);
		dm.setType(DMessage.OutBinaryOp);
		try
		{
			dm.putDWord(id);
			dm.putByte((byte) op.getValue());
			dm.putString(lhsType);
			dm.putString(lhsValueString);
			dm.putString(rhsType);
			dm.putString(rhsValueString);
		}
		catch(UnsupportedEncodingException uee)
		{
			// couldn't write out the string, so just terminate it and complete anyway
			dm.putByte((byte)'\0');
		}

		return dm;
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.Session#getDisconnectCause()
	 */
	public Exception getDisconnectCause() {
		if (m_protocol != null)
			return m_protocol.getDisconnectCause();
		
		return null;
	}

}
