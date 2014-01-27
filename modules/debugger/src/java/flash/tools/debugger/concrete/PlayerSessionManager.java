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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.BindException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import flash.localization.LocalizationManager;
import flash.tools.debugger.AIRLaunchInfo;
import flash.tools.debugger.DebuggerLocalizer;
import flash.tools.debugger.DefaultDebuggerCallbacks;
import flash.tools.debugger.IDebuggerCallbacks;
import flash.tools.debugger.ILaunchNotification;
import flash.tools.debugger.IProgress;
import flash.tools.debugger.Player;
import flash.tools.debugger.Session;
import flash.tools.debugger.SessionManager2;
import flash.tools.debugger.VersionException;
import flash.util.URLHelper;

public class PlayerSessionManager implements SessionManager2
{
	private ServerSocket m_serverSocket;
	private HashMap<String, Object> m_prefs;
	private IDebuggerCallbacks m_debuggerCallbacks;
	private static LocalizationManager m_localizationManager;
	private Socket m_connectSocket;
	private boolean m_cancelConnect;
	
	static
	{
        // set up for localizing messages
        m_localizationManager = new LocalizationManager();
        m_localizationManager.addLocalizer( new DebuggerLocalizer("flash.tools.debugger.concrete.djapi.") ); //$NON-NLS-1$
	}

	public PlayerSessionManager()
	{
		m_debuggerCallbacks = new DefaultDebuggerCallbacks();

		m_serverSocket = null;
		m_connectSocket = null;
		m_cancelConnect = false;
		m_prefs = new HashMap<String, Object>();

		// manager
		setPreference(PREF_ACCEPT_TIMEOUT, 120000); // 2 minutes
		setPreference(PREF_URI_MODIFICATION, 1);
		setPreference(PREF_CONNECT_TIMEOUT, 120000); // 2 minutes
		setPreference(PREF_CONNECT_WAIT_INTERVAL, 250); // 0.25 seconds
		setPreference(PREF_CONNECT_RETRY_ATTEMPTS, -1); // Retry till timeout
		
		// session

		// response to requests
		setPreference(PREF_SOCKET_TIMEOUT, -1); // no timeout by default
		setPreference(PREF_RESPONSE_TIMEOUT, 750); // 0.75s
		setPreference(PREF_CONTEXT_RESPONSE_TIMEOUT, 1000); // 1s
		setPreference(PREF_GETVAR_RESPONSE_TIMEOUT, 1500); // 1.5s
		setPreference(PREF_SETVAR_RESPONSE_TIMEOUT, 5000); // 5s
		setPreference(PREF_SWFSWD_LOAD_TIMEOUT, 5000);  // 5s

		// wait for a suspend to occur after a halt
		setPreference(PREF_SUSPEND_WAIT, 7000);

		// invoke getters by default
		setPreference(PREF_INVOKE_GETTERS, 1);

		// hierarchical variables view
		setPreference(PREF_HIERARCHICAL_VARIABLES, 0);
	}

	/**
	 * Set preference 
	 * If an invalid preference is passed, it will be silently ignored.
	 */
	public void			setPreference(String pref, int value)	{ m_prefs.put(pref, new Integer(value)); }
	public void			setPreference(String pref, String value){ m_prefs.put(pref, value);	}
	public Set<String>	keySet()								{ return m_prefs.keySet(); }
	public Object		getPreferenceAsObject(String pref)		{ return m_prefs.get(pref); }

	/*
	 * @see flash.tools.debugger.SessionManager#getPreference(java.lang.String)
	 */
	public int getPreference(String pref)
	{
		int val = 0;
		Integer i = (Integer)m_prefs.get(pref);
		if (i == null)
			throw new NullPointerException();
		val = i.intValue();
		return val;
	}

	/*
	 * @see flash.tools.debugger.SessionManager#startListening()
	 */
	public void startListening() throws IOException 
	{
		if (m_serverSocket == null)
			m_serverSocket = new ServerSocket(DProtocol.DEBUG_PORT);
	}

	/*
	 * @see flash.tools.debugger.SessionManager#stopListening()
	 */
	public void stopListening() throws IOException
	{
		if (m_serverSocket != null)
		{
			m_serverSocket.close();
			m_serverSocket = null;
		}
	}

	/*
	 * @see flash.tools.debugger.SessionManager#isListening()
	 */
	public boolean isListening()
	{
		return (m_serverSocket == null) ? false : true;
	}

	private class LaunchInfo
	{
		private String m_uri;

		public LaunchInfo(String uri)
		{
			m_uri = uri;
		}

		public boolean isAbout()
		{
			return m_uri.startsWith("about:"); //$NON-NLS-1$
		}

		public boolean isHttpOrAbout()
		{
			return m_uri.startsWith("http:") || m_uri.startsWith("https:") || isAbout(); //$NON-NLS-1$ //$NON-NLS-2$
		}

		public boolean isWebPage()
		{
			return isHttpOrAbout() || m_uri.endsWith(".htm") || m_uri.endsWith(".html"); //$NON-NLS-1$ //$NON-NLS-2$
		}

		public boolean isWebBrowserNativeLaunch()
		{
			return isWebPage() && (m_debuggerCallbacks.getHttpExe() != null);
		}

		public boolean isPlayerNativeLaunch()
		{
			return m_uri.length() > 0 && !isWebPage() && (m_debuggerCallbacks.getPlayerExe() != null);
		}
		
		public boolean isAIRLaunch()
		{
			return m_uri.startsWith("file:") && (m_uri.endsWith("-app.xml") || m_uri.endsWith("application.xml")); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
		}
	}

	private enum OS {
		Mac,
		Windows,
		Unix
	}

	private OS getOS()
	{
		String osName = System.getProperty("os.name").toLowerCase(); //$NON-NLS-1$
		if (osName.startsWith("mac os x")) //$NON-NLS-1$
		{
			return OS.Mac;
		}
		else if (osName.startsWith("windows")) //$NON-NLS-1$
		{
			return OS.Windows;
		}
		else
		{
			return OS.Unix;
		}
	}

	/*
	 * @see flash.tools.debugger.SessionManager#launch(java.lang.String, flash.tools.debugger.AIRLaunchInfo, boolean, flash.tools.debugger.IProgress)
	 */
	public Session launch(String uri, AIRLaunchInfo airLaunchInfo, boolean forDebugging, IProgress waitReporter, ILaunchNotification launchNotification) throws IOException
	{
		String[] launchCommand;

		uri = uri.trim();

		if (airLaunchInfo == null)
		{
			LaunchInfo launchInfo = new LaunchInfo(uri);

			uri = tweakNativeLaunchUri(uri, forDebugging, launchInfo);

			launchCommand = getFlashLaunchArgs(uri, launchInfo);
		}
		else // else, AIR
		{
			launchCommand = getAIRLaunchArgs(uri, airLaunchInfo);
		}

		ProcessListener pl = null; 
		PlayerSession session = null;

		// create the process and attach a thread to watch it during our accept phase
		Process proc = m_debuggerCallbacks.launchDebugTarget(launchCommand);

		pl = new ProcessListener(launchCommand, proc, launchNotification, forDebugging, airLaunchInfo != null); // BUG FB-9874: launchNotifier added

		// If launching an AIR app, and forDebugging=false (meaning we are just running it,
		// not debugging it), start a background thread that will call the launchNotification
		// when the launch is complete.
		if (!forDebugging && airLaunchInfo != null && launchNotification != null)
			pl.startLaunchNotifier();

		if (forDebugging)
		{
			/* now wait for a connection */
			session = (PlayerSession)accept(pl, waitReporter);
			session.setProcess(proc);
			session.setLaunchUrl(uri);
			session.setAIRLaunchInfo(airLaunchInfo);
		}

		return session;
	}
	
	public Process launchForRun(String uri, AIRLaunchInfo airLaunchInfo, IProgress waitReporter,
			ILaunchNotification launchNotification) throws IOException {
		
		String[] launchCommand;
		uri = uri.trim();

		if (airLaunchInfo == null)
		{
			LaunchInfo launchInfo = new LaunchInfo(uri);

			//forDebugging = false;
			uri = tweakNativeLaunchUri(uri, false, launchInfo);

			launchCommand = getFlashLaunchArgs(uri, launchInfo);
		}
		else // else, AIR
		{
			launchCommand = getAIRLaunchArgs(uri, airLaunchInfo);
		}

		ProcessListener pl = null; 

		// create the process and attach a thread to watch it during our accept phase
		Process proc = m_debuggerCallbacks.launchDebugTarget(launchCommand);

		//forDebugging = false
		pl = new ProcessListener(launchCommand, proc, launchNotification, false, airLaunchInfo != null); // BUG FB-9874: launchNotifier added
		pl.setIsRunLaunch(true);

		// If launching an AIR app, and forDebugging=false (meaning we are just running it,
		// not debugging it), start a background thread that will call the launchNotification
		// when the launch is complete.
		if (airLaunchInfo != null && launchNotification != null)
			pl.startLaunchNotifier();

		return proc;
	}

	/**
	 * Tweaks the launch URI if necessary, e.g. may append "?debug=true"
	 */
	private String tweakNativeLaunchUri(String uri, boolean forDebugging,
			LaunchInfo launchInfo) throws IOException, FileNotFoundException
	{
		// first let's see if it's an HTTP URL or not
		if (launchInfo.isHttpOrAbout())
		{
			boolean modify = (getPreference(PREF_URI_MODIFICATION) != 0);

			if (modify && forDebugging && !launchInfo.isAbout())
			{
				// escape spaces if we have any
				uri = URLHelper.escapeSpace(uri);

		        // be sure that ?debug=true is included in query string
				URLHelper urlHelper = new URLHelper(uri);
				Map<String, String> params = urlHelper.getParameterMap();
				params.put("debug", "true"); //$NON-NLS-1$ //$NON-NLS-2$
				urlHelper.setParameterMap(params);

				uri = urlHelper.getURL();
		    }
		}
		else
		{
			// ok, its not an http: type request therefore we should be able to see
			// it on the file system, right?  If not then it's probably not valid
			File f = null;
			if (uri.startsWith("file:")) //$NON-NLS-1$
			{
				try
				{
					f = new File(new URI(uri));
				}
				catch (URISyntaxException e)
				{
					IOException ioe = new IOException(e.getMessage());
					ioe.initCause(e);
					throw ioe;
				}
			}
			else
			{
				f = new File(uri);
			}

			if (f != null && f.exists()) {
				// Do not use getCanonicalPath() -- see FB-24595
				uri = f.getAbsolutePath();
			} else {
				throw new FileNotFoundException(uri);
			}
		}

		return uri;
	}

	/**
	 * Gets the arguments needed for launching a swf that needs to run
	 * in a web browser or the standalone player.
	 */
	private String[] getFlashLaunchArgs(String uri, LaunchInfo launchInfo) throws FileNotFoundException
	{
		String[] launchCommand;

		OS os = getOS();

		/**
		 * Various ways to launch this stupid thing.  If we have the exe
		 * values for the player, then we can launch it directly, monitor
		 * it and kill it when we die; otherwise we launch it through
		 * a command shell (cmd.exe, open, or bash) and our Process object
		 * dies right away since it spawned another process to run the
		 * Player within.
		 */
		if (os == OS.Mac)
		{
			if (launchInfo.isWebBrowserNativeLaunch())
			{
				File httpExe = m_debuggerCallbacks.getHttpExe();
				String[] customParams = m_debuggerCallbacks.getBrowserParameters(uri);
				if (customParams == null) {
					launchCommand = new String[] { "/usr/bin/open", "-a", httpExe.toString(), uri }; //$NON-NLS-1$ //$NON-NLS-2$
				}
				else {
					final int prependLen = 4;
					launchCommand = new String[customParams.length + prependLen ];
					launchCommand[0] = "/usr/bin/open";
					launchCommand[1] = "-a";
					launchCommand[2] = httpExe.toString();
					launchCommand[3] = "--args";
					for ( int i = 0; i < customParams.length; i++) {
						launchCommand[i + prependLen] = customParams[i];
					}
				}
			}
			else if (launchInfo.isPlayerNativeLaunch())
			{
				File playerExe = m_debuggerCallbacks.getPlayerExe();
				launchCommand = new String[] { "/usr/bin/open", "-a", playerExe.toString(), uri }; //$NON-NLS-1$ //$NON-NLS-2$
			}
			else
			{
				launchCommand = new String[] { "/usr/bin/open", uri }; //$NON-NLS-1$
			}
		}
		else // Windows or *nix
		{
			if (launchInfo.isWebBrowserNativeLaunch())
			{
				File httpExe = m_debuggerCallbacks.getHttpExe();
				String[] customParams = m_debuggerCallbacks.getBrowserParameters(uri);
				if (customParams == null) {
					if (os == OS.Windows)
						launchCommand = getWindowsBrowserLaunchArgs(httpExe, uri);
					else
						launchCommand = new String[] { httpExe.toString(), uri };
				}
				else {
					final int prependLen = 1;
					launchCommand = new String[customParams.length + prependLen];
					launchCommand[0] = httpExe.toString();
					for ( int i = 0; i < customParams.length; i++) {
						launchCommand[i + prependLen] = customParams[i];
					}
				}
			}
			else if (launchInfo.isPlayerNativeLaunch())
			{
				File playerExe = m_debuggerCallbacks.getPlayerExe();
				launchCommand = new String[] { playerExe.toString(), uri };
			}
			else
			{
				if (os == OS.Windows)
				{
					// We must quote all ampersands in the URL; if we don't, then
					// cmd.exe will interpret the ampersand as a command separator.
					uri = uri.replaceAll("&", "\"&\""); //$NON-NLS-1$ //$NON-NLS-2$

					launchCommand = new String[] { "cmd", "/c", "start", uri }; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
				}
				else
				{
					String exeName;
					if (launchInfo.isWebPage())
						exeName = m_debuggerCallbacks.getHttpExeName();
					else
						exeName = m_debuggerCallbacks.getPlayerExeName();
					throw new FileNotFoundException(exeName);
				}
			}
		}
		return launchCommand;
	}

	/**
	 * Gets the arguments needed for launching a web browser on Windows.
	 */
	private String[] getWindowsBrowserLaunchArgs(File httpExe, String uri)
	{
		if (httpExe.getName().equalsIgnoreCase("chrome.exe")) //$NON-NLS-1$
		{
			// FB-16779: Adding "--disable-hang-monitor" to prevent Chrome
			// from warning us that a plug-inappears to be hung; it does
			// that when the user hits a breakpoint.
			return new String[] { httpExe.toString(), "--disable-hang-monitor", uri }; //$NON-NLS-1$
		}
		else if (httpExe.getName().equalsIgnoreCase("iexplore.exe")) //$NON-NLS-1$
		{
			boolean isIE8 = false;

			try
			{
				int[] ieVersion = m_debuggerCallbacks.getAppVersion(httpExe);
				if (ieVersion != null)
					isIE8 = (ieVersion[0] >= 8);
			} catch (IOException e) {
				// ignore
			}

			if (isIE8)
			{
				// FB-22107: Tell IE to keep using the new process we are
				// launching, rather than merging the new process into the
				// old one.  This allows us to terminate the new IE
				// debugging session.
				return new String[] { httpExe.toString(), "-noframemerging", uri }; //$NON-NLS-1$
			}
		}

		return new String[] { httpExe.toString(), uri };
	}

	/**
	 * Gets the arguments needed for launching a swf that needs to run
	 * in AIR.
	 */
	private String[] getAIRLaunchArgs(String uri, AIRLaunchInfo airLaunchInfo)
			throws IOException
	{
		List<String> cmdList = new LinkedList<String>();

		cmdList.add(airLaunchInfo.airDebugLauncher.getPath());

		if (airLaunchInfo.airRuntimeDir != null)
		{
			cmdList.add("-runtime"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.airRuntimeDir.getPath());
		}

		if (airLaunchInfo.airSecurityPolicy != null)
		{
			cmdList.add("-security-policy"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.airSecurityPolicy.getPath());
		}

		if (airLaunchInfo.airPublisherID != null && airLaunchInfo.airPublisherID.length() > 0)
		{
			cmdList.add("-pubid"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.airPublisherID);
		}

		if (airLaunchInfo.profile != null && airLaunchInfo.profile.length() > 0)
		{
			cmdList.add("-profile"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.profile);
		}
		
		if (airLaunchInfo.screenSize != null && airLaunchInfo.screenSize.length() > 0)
		{
			cmdList.add("-screensize"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.screenSize);
		}
		
		if (airLaunchInfo.dpi > 0)
		{
			//TODO: this is apparently only going to be used in AIR 2.5.
			//Figure out permanent solution when AIR 3.0 comes along.
			cmdList.add("-XscreenDPI"); //$NON-NLS-1$
			cmdList.add(String.valueOf(airLaunchInfo.dpi));
		}
		
		if (airLaunchInfo.versionPlatform != null && airLaunchInfo.versionPlatform.length() > 0)
		{
			cmdList.add("-XversionPlatform"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.versionPlatform);
		}
		
		if (airLaunchInfo.extDir != null && airLaunchInfo.extDir.length() > 0) {
			cmdList.add("-extdir"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.extDir);
		}
		
		if (airLaunchInfo.deviceExtDir != null && airLaunchInfo.deviceExtDir.length() > 0) {
			cmdList.add("-XdeviceExtDir"); //$NON-NLS-1$
			cmdList.add(airLaunchInfo.deviceExtDir);
		}
		
		// If it's a "file:" URL, then pass the actual filename; otherwise, use the URL
		// ok, its not an http: type request therefore we should be able to see
		// it on the file system, right?  If not then it's probably not valid
		File f = null;
		if (uri.startsWith("file:")) //$NON-NLS-1$
		{
			try
			{
				f = new File(new URI(uri));
				cmdList.add(f.getPath());
			}
			catch (URISyntaxException e)
			{
				IOException ioe = new IOException(e.getMessage());
				ioe.initCause(e);
				throw ioe;
			}
		}
		else
		{
			cmdList.add(uri);
		}

		if (airLaunchInfo.applicationContentRootDir != null)
		{
			cmdList.add(airLaunchInfo.applicationContentRootDir.getAbsolutePath());
		}

		List<String> args = null;
		if (airLaunchInfo.applicationArgumentsArray != null)
		{
			args = Arrays.asList(airLaunchInfo.applicationArgumentsArray);
		}
		else if (airLaunchInfo.applicationArguments != null)
		{
			args = splitArgs(airLaunchInfo.applicationArguments);
		}

		if (args != null && args.size() > 0)
		{
			cmdList.add("--"); //$NON-NLS-1$
			cmdList.addAll(args);
		}

		return cmdList.toArray(new String[cmdList.size()]);
	}

	/**
	 * This is annoying: We must duplicate the operating system's behavior
	 * with regard to splitting arguments.
	 * 
	 * @param arguments A single string of arguments that are intended to
	 * be passed to an AIR application.  The tricky part is that some
	 * of the arguments may be quoted, and if they are, then the quoting
	 * will be in a way that is specific to the current platform.  For
	 * example, on Windows, strings are quoted with the double-quote character
	 * ("); on Mac and Unix, strings can be quoted with either double-quote
	 * or single-quote.
	 * @return The equivalent
	 */
	private List<String> splitArgs(String arguments)
	{
		List<String> retval = new ArrayList<String>();

		arguments = arguments.trim();

		// Windows quotes only with double-quote; Mac and Unix also allow single-quote.
		boolean isWindows = System.getProperty("os.name").toLowerCase().startsWith("win"); //$NON-NLS-1$ //$NON-NLS-2$
		boolean isMacOrUnix = !isWindows;

		int i=0;
		while (i<arguments.length()) {
			char ch = arguments.charAt(i);
			if (ch == ' ' || ch == '\t') {
				// keep looping
				i++;
			} else if (ch == '"' || (isMacOrUnix && ch == '\'')) {
				char quote = ch;
				int nextQuote = arguments.indexOf(quote, i+1);
				if (nextQuote == -1) {
					retval.add(arguments.substring(i+1));
					return retval;
				} else {
					retval.add(arguments.substring(i+1, nextQuote));
					i = nextQuote+1;
				}
			} else {
				int startPos = i;
				while (i<arguments.length()) {
					ch = arguments.charAt(i);
					if (ch == ' ' || ch == '\t') {
						break;
					}
					i++;
				}
				retval.add(arguments.substring(startPos, i));
			}
		}

		return retval;
	}

	/*
	 * @see flash.tools.debugger.SessionManager#playerForUri(java.lang.String, flash.tools.debugger.AIRLaunchInfo)
	 */
	public Player playerForUri(String url, AIRLaunchInfo airLaunchInfo)
	{
		LaunchInfo launchInfo = new LaunchInfo(url);

		if (airLaunchInfo != null)
		{
			return new AIRPlayer(airLaunchInfo.airDebugLauncher);
		}
		else if (launchInfo.isAIRLaunch())
		{
			return new AIRPlayer(null);
		}
		else
		{
			// Find the Netscape plugin
			if (getOS() == OS.Mac)
			{
				if (!launchInfo.isWebBrowserNativeLaunch())
				{
					File playerExe = m_debuggerCallbacks.getPlayerExe();
					return new StandalonePlayer(playerExe);
				}
				File flashPlugin = new File("/Library/Internet Plug-Ins/Flash Player.plugin"); //$NON-NLS-1$
				return new NetscapePluginPlayer(m_debuggerCallbacks.getHttpExe(), flashPlugin);
			}
			else
			{
				if (launchInfo.isWebBrowserNativeLaunch())
				{
					File httpExe = m_debuggerCallbacks.getHttpExe();
					if (httpExe.getName().equalsIgnoreCase("iexplore.exe")) //$NON-NLS-1$
					{
						// IE on Windows: Find the ActiveX control
						String activeXFile = null;
						try
						{
							activeXFile = m_debuggerCallbacks.queryWindowsRegistry("HKEY_CLASSES_ROOT\\CLSID\\{D27CDB6E-AE6D-11cf-96B8-444553540000}\\InprocServer32", null); //$NON-NLS-1$
						}
						catch (IOException e)
						{
							// ignore
						}
						if (activeXFile == null)
							return null; // we couldn't find the player
						File file = new File(activeXFile);
						return new ActiveXPlayer(httpExe, file);
					}
					else
					{
						// Find the Netscape plugin
						File browserDir = httpExe.getParentFile();
	
						// Opera puts plugins under "program\plugins" rather than under "plugins"
						if (httpExe.getName().equalsIgnoreCase("opera.exe")) //$NON-NLS-1$
							browserDir = new File(browserDir, "program"); //$NON-NLS-1$
	
						File pluginsDir = new File(browserDir, "plugins"); //$NON-NLS-1$
						File flashPlugin = new File(pluginsDir, "NPSWF32.dll"); // WARNING, Windows-specific //$NON-NLS-1$

						// Bug FB-4691: The player is now installed via a registry key, not
						// in the "plugins" directory.
						//
						// Although Mozilla does not document this, the actual behavior of
						// the browser seems to be that it looks first in the "plugins" directory,
						// and then, if the file is not found there, it looks in the registry.
						// So, we mimic that behavior.
						if (!flashPlugin.exists())
						{
							File pathFromRegistry = getWindowsMozillaPlayerPathFromRegistry();

							if (pathFromRegistry != null)
								flashPlugin = pathFromRegistry;
						}
	
						return new NetscapePluginPlayer(httpExe, flashPlugin);
					}
				}
				else if (launchInfo.isPlayerNativeLaunch())
				{
					File playerExe = m_debuggerCallbacks.getPlayerExe();
					return new StandalonePlayer(playerExe);
				}
			}
		}

		return null;
	}

	/**
	 * Look in the Windows registry for the Mozilla version of the Flash player.
	 */
	private File getWindowsMozillaPlayerPathFromRegistry()
	{
		final String KEY = "\\SOFTWARE\\MozillaPlugins\\@adobe.com/FlashPlayer"; //$NON-NLS-1$
		final String PATH = "Path"; //$NON-NLS-1$

		// According to
		//
		//    http://developer.mozilla.org/en/docs/Plugins:_The_first_install_problem
		//
		// the MozillaPlugins key can be written to either HKEY_CURRENT_USER or
		// HKEY_LOCAL_MACHINE.  Unfortunately, as of this writing, Firefox
		// (version 2.0.0.2) doesn't actually work that way -- it only checks
		// HKEY_LOCAL_MACHINE, but not HKEY_CURRENT_USER.
		//
		// But in hopeful anticipation of a fix for that, we are going to check both
		// locations.  On current builds, that won't do any harm, because the
		// current Flash Player installer only writes to HKEY_LOCAL_MACHINE.  In the
		// future, if Mozilla gets fixed and then the Flash player installer gets
		// updated, then our code will already work correctly.
		//
		// Another quirk: In my opinion, it would be better for Mozilla to look first
		// in HKEY_CURRENT_USER, and then in HKEY_LOCAL_MACHINE.  However, according to
		//
		//    http://developer.mozilla.org/en/docs/Installing_plugins_to_Gecko_embedding_browsers_on_Windows
		//
		// they don't agree with that -- they want HKEY_LOCAL_MACHINE first.

		String[] roots = { "HKEY_LOCAL_MACHINE", "HKEY_CURRENT_USER" }; //$NON-NLS-1$ //$NON-NLS-2$
		for (int i=0; i<roots.length; ++i)
		{
			try
			{
				String path = m_debuggerCallbacks.queryWindowsRegistry(roots[i] + KEY, PATH);
				if (path != null)
					return  new File(path);
			}
			catch (IOException e)
			{
				// ignore
			}
		}

		return null;
	}

	/*
	 * @see flash.tools.debugger.SessionManager#supportsLaunch()
	 */
	public boolean supportsLaunch()
	{
		return true;
	}

	/*
	 * @see flash.tools.debugger.SessionManager#accept(flash.tools.debugger.IProgress)
	 */
	public Session accept(IProgress waitReporter) throws IOException
	{
		return accept(null, waitReporter);
	}

	/**
	 * A private variation on <code>accept()</code> that also has an argument
	 * indicating that the process we are waiting for has terminated.
	 * 
	 * @param pl
	 *            Optional process listener. If non-null, this is used to detect
	 *            if a process that was launched has terminated unexpectedly.
	 *            For example, if launch() launches adl, but adl exits, then we
	 *            don't want to continue to wait for a socket connection.
	 */
	private Session accept(ProcessListener pl, IProgress waitReporter) throws IOException
	{
		// get timeout 
		int timeout = getPreference(PREF_ACCEPT_TIMEOUT);
		int totalTimeout = timeout;
		int iterateOn = 100;

		PlayerSession session = null;
		try
		{
			m_serverSocket.setSoTimeout(iterateOn);

			// Wait 100ms per iteration.  We have to do that so that we can report how long
			// we have been waiting.
			Socket s = null;
			while (s == null && !airAppTerminated(pl))
			{
				try
				{
					s = m_serverSocket.accept();
				}
				catch(IOException ste)
				{
					timeout -= iterateOn;
					if (timeout < 0 || m_serverSocket == null || m_serverSocket.isClosed())
						throw ste; // we reached the timeout, or someome called stopListening()
				}

				// Tell the progress monitor we've waited a little while longer,
				// so that the Eclipse progress bar can keep chugging along
				if (waitReporter != null)
					waitReporter.setProgress(totalTimeout - timeout, totalTimeout);
			}

			if (s == null && airAppTerminated(pl))
			{
				throw pl.createLaunchFailureException();
			}

			/* create a new session around this socket */
			session = PlayerSession.createFromSocketWithOptions(s, m_debuggerCallbacks, this);

			// transfer preferences
			session.setPreferences(m_prefs);
		}
		catch(NullPointerException npe)
		{
			throw new BindException(getLocalizationManager().getLocalizedTextString("serverSocketNotListening")); //$NON-NLS-1$
		}

		return session;
	}

	/**
	 * Returns true if the passed-in process listener is for an AIR application
	 * that has terminated. This is used by accept() in order to detect that it
	 * should give up listening on the socket.
	 * 
	 * The reason we can't do this for Flash player-based apps is that unlike
	 * AIR apps, the process that we launched sometimes acts as just sort of a
	 * "launcher" process that terminates quickly, and the actual Flash player
	 * is in some other process. For example, on Mac, we often invoke the "open"
	 * program to open a web browser; and on Windows, if you launch firefox.exe
	 * but it detects that there is already a running instance of firefox.exe,
	 * the new instance will just pass a message to the old instance, and then
	 * the new instance will terminate.
	 * 
	 * @param pl
	 *            a process listener, or <code>null</code>
	 * @return true if pl refers to an AIR app that has terminated.
	 */
	private boolean airAppTerminated(ProcessListener pl)
	{
		if (pl != null)
		{
			if (pl.isAIRApp())
			{
				if (pl.isProcessDead())
				{
					return true;
				}
			}
		}

		return false;
	}

	/*
	 * @see flash.tools.debugger.SessionManager#getDebuggerCallbacks()
	 */
	public IDebuggerCallbacks getDebuggerCallbacks()
	{
		return m_debuggerCallbacks;
	}

	/*
	 * @see flash.tools.debugger.SessionManager#setDebuggerCallbacks(flash.tools.debugger.IDebuggerCallbacks)
	 */
	public void setDebuggerCallbacks(IDebuggerCallbacks debuggerCallbacks)
	{
		m_debuggerCallbacks = debuggerCallbacks;
	}
	
	/**
	 * A private variation on <code>connect()</code> that also has an argument
	 * indicating that the process we are waiting for has terminated.
	 * 
	 * @param pl
	 *            Optional process listener. If non-null, this is used to detect
	 *            if a process that was launched has terminated unexpectedly.
	 *            For example, if launch() launches adl, but adl exits, then we
	 *            don't want to continue to wait for a socket connection.
	 */
	public Session connect(int port, IProgress waitReporter) throws IOException
	{
		final int waitTime = getPreference(PREF_CONNECT_WAIT_INTERVAL);
		final int maxRetryAttempts = getPreference(PREF_CONNECT_RETRY_ATTEMPTS);
		final int totalTimeout = getPreference(PREF_CONNECT_TIMEOUT);
		final long timeForConnectStart = System.currentTimeMillis();
		
		long elapsedTime = 0;
		int retryAttempts = -1;
		PlayerSession session = null;
		Socket s = null;		
		
		m_cancelConnect = false;		
		
		// Try to see if a connect happens till totalTimeout
		// If the connection was refused in between, retry
		// again after waitTime until totalTimeout is elapsed.
		// Retry mechanism is disabled if PREF_CONNECT_RETRY_ATTEMPTS
		// is 0.
		while (s == null)
		{
			try
			{
				InetSocketAddress localAddress = new InetSocketAddress(InetAddress.getByName(null), port);
				s = new Socket();
				//save the socket for canceling connect
				m_connectSocket = s;
				//connect to loopback address at the specified port
				s.connect(localAddress, totalTimeout);
			}
			catch(IOException ste)
			{
				if (ste instanceof SocketTimeoutException) {
					//if we timed out, abort connect
					abortConnect(ste);
				}

				safeCloseSocket(s);
				
				s = null;
				retryAttempts++;
				
				//if we should not retry, checkConnectTimeout 
				//throws an exception
				elapsedTime = checkConnectTimeout(waitTime, maxRetryAttempts,
						totalTimeout, retryAttempts, timeForConnectStart, ste);
			}

			// Tell the progress monitor we've waited a little while longer,
			// so that the Eclipse progress bar can keep chugging along
			if (waitReporter != null)
				waitReporter.setProgress((int)elapsedTime, totalTimeout);
			
			if (s != null) {
				/** If we connected, make sure that we get some response 
				 * back after sending the handshake. This is required because
				 * of the way port forwarding works. A connect will be successful
				 * if port forwarding is set up, but we won't get any response 
				 * unless the application is actually listening. 				
				 */				
				/* create a new session around this socket */
				session = PlayerSession.createFromSocketWithOptions(s, m_debuggerCallbacks, this);
				// transfer preferences
				session.setPreferences(m_prefs);
				try {
					session.bind();					
				}
				catch (VersionException ex) {
					session.unbind();
					safeCloseSocket(s);
					
					s = null;					
					retryAttempts++;
					
					/** The VersionException here is considered as an IOException
					 * because we do not know if there was even a valid application
					 * listening on the port. Once the port is forwarded, connect
					 * succeeds and we get a VersionException even if player is not
					 * listening on that port.
					 */
					elapsedTime = checkConnectTimeout(waitTime, maxRetryAttempts, 
							totalTimeout, retryAttempts, timeForConnectStart, 
							new IOException(ex.getLocalizedMessage()));
				}
			}
		}
		m_connectSocket = null;
		
		return session;
	}

	/**
	 * @param waitTime
	 * @param maxRetryAttempts
	 * @param totalTimeout
	 * @param retryAttempts
	 * @param startTime
	 * @param caughtException
	 * @return
	 * @throws IOException
	 */
	private long checkConnectTimeout(final int waitTime,
			final int maxRetryAttempts, final int totalTimeout,
			int retryAttempts, final long startTime, IOException caughtException)
			throws IOException {
		long elapsedTime;
		long endTime = System.currentTimeMillis();
		elapsedTime = endTime - startTime;
		
		// check if we should retry
		boolean retryFinished = (maxRetryAttempts != -1 && retryAttempts >= maxRetryAttempts);
		
		// check if we timed out or somebody called stopConnecting()
		if (retryFinished ||
				elapsedTime > totalTimeout || 
				m_cancelConnect ) {
			abortConnect(caughtException);
		}

		//wait a bit before retrying
		try {
			Thread.sleep(waitTime);
		} catch (InterruptedException e) {
			abortConnect(caughtException);
		}

		//check cancel before resuming
		if (m_cancelConnect ) {
			abortConnect(caughtException);
		}
		return elapsedTime;
	}

	/**
	 * @param ste
	 * @throws IOException
	 */
	private void abortConnect(IOException ste) throws IOException {
		m_connectSocket = null;
		m_cancelConnect = false;
		throw ste;
	}

	/**
	 * @param s
	 */
	private void safeCloseSocket(Socket s) {
		//clean up the socket
		if (s != null && !s.isClosed()) {
			try {
				s.close();
			}
			catch (IOException closeException) {
				//ignore
			}
		}
	}

	/*
	 * @see flash.tools.debugger.SessionManager#stopConnecting()
	 */
	public void stopConnecting() throws IOException
	{
		if (!m_cancelConnect) {
			m_cancelConnect = true;
			if (m_connectSocket != null)
			{			
				m_connectSocket.close();
				m_connectSocket = null;
			}
		}		
	}

	/*
	 * @see flash.tools.debugger.SessionManager#isConnecting()
	 */
	public boolean isConnecting()
	{
		return (m_connectSocket == null) ? false : true;
	}
	
	/**
	 * Returns the localization manager.  Use this for all localized strings.
	 */
	public static LocalizationManager getLocalizationManager()
	{
		return m_localizationManager;
	}
}
