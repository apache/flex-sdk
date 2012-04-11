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

package flash.tools.debugger;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import flash.util.Trace;

/**
 * @author mmorearty
 */
public class DefaultDebuggerCallbacks implements IDebuggerCallbacks
{
	private boolean m_computedExeLocations;
	private File m_httpExe;
	private File m_playerExe;

	private static final String UNIX_DEFAULT_BROWSER = "firefox"; //$NON-NLS-1$
	private static final String UNIX_FLASH_PLAYER = "flashplayer"; //$NON-NLS-1$

	private static final int WINDOWS = 0;
	private static final int MAC = 1;
	private static final int UNIX = 2;

	// A pattern for a value that was output by reg.exe.  Warning,
	// Windows XP and Windows Vista have different output; the following
	// pattern needs to work for both.
	private static final Pattern registryValuePattern = Pattern.compile("\\sREG_[^ \t]+\\s+(.*)$"); //$NON-NLS-1$

	/**
	 * Returns WINDOWS, MAC, or UNIX
	 */
	private static int getOS() {
		String osName = System.getProperty("os.name").toLowerCase(); //$NON-NLS-1$
		if (osName.startsWith("windows")) //$NON-NLS-1$
			return WINDOWS;
		else if (osName.startsWith("mac os x")) // as per http://developer.apple.com/technotes/tn2002/tn2110.html //$NON-NLS-1$
			return MAC;
		else
			return UNIX;
	}

	/*
	 * @see flash.tools.debugger.IDebuggerCallbacks#getHttpExe()
	 */
	public synchronized File getHttpExe()
	{
		if (!m_computedExeLocations)
			recomputeExeLocations();
		return m_httpExe;
	}

	/*
	 * @see flash.tools.debugger.IDebuggerCallbacks#getPlayerExe()
	 */
	public synchronized File getPlayerExe()
	{
		if (!m_computedExeLocations)
			recomputeExeLocations();
		return m_playerExe;
	}

	/*
	 * @see flash.tools.debugger.IDebuggerCallbacks#recomputeExeLocations()
	 */
	public synchronized void recomputeExeLocations()
	{
		int os = getOS();
		if (os == WINDOWS)
		{
			m_httpExe = getDefaultWindowsBrowser();
			m_playerExe = determineExeForType("ShockwaveFlash.ShockwaveFlash"); //$NON-NLS-1$
		}
		else if (os == MAC)
		{
			m_httpExe = null;
			m_playerExe = null;
		}
		else // probably Unix
		{
			// "firefox" is default browser for unix
			m_httpExe = findUnixProgram(UNIX_DEFAULT_BROWSER);

			// "flashplayer" is standalone flash player on unix
			m_playerExe = findUnixProgram(UNIX_FLASH_PLAYER);
		}
		m_computedExeLocations = true;
	}

	public String getHttpExeName()
	{
		if (getOS() == UNIX)
			return UNIX_DEFAULT_BROWSER;
		else
			return Bootstrap.getLocalizationManager().getLocalizedTextString("webBrowserGenericName"); //$NON-NLS-1$
	}

	public String getPlayerExeName()
	{
		if (getOS() == UNIX)
			return UNIX_FLASH_PLAYER;
		else
			return Bootstrap.getLocalizationManager().getLocalizedTextString("flashPlayerGenericName"); //$NON-NLS-1$
	}

	/**
	 * Looks for a Unix program.  Checks the PATH, and if not found there,
	 * checks the directory specified by the "application.home" Java property.
	 * ("application.home" was set by the "fdb" shell script.)
	 * 
	 * @param program program to find, e.g. "firefox"
	 * @return path, or <code>null</code> if not found.
	 */
	private File findUnixProgram(String program)
	{
		String[] cmd = { "/bin/sh", "-c", "which " + program }; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
		try
		{
			Process process = Runtime.getRuntime().exec(cmd);
			BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
			String line = reader.readLine();
			if (line != null)
			{
				File f = new File(line);
				if (f.exists())
				{
					return f;
				}
			}

			// Check in the Flex SDK's "bin" directory.  The "application.home"
			// property is set by the "fdb" shell script.
			String flexHome = System.getProperty("application.home"); //$NON-NLS-1$
			if (flexHome != null)
			{
				File f = new File(flexHome, "bin/" + program); //$NON-NLS-1$
				if (f.exists())
				{
					return f;
				}
			}
		}
		catch (IOException e)
		{
			// ignore
		}
		return null;
	}

	private File getDefaultWindowsBrowser() {
		try {
			String browser = null;

			double osVersion;
			try {
				osVersion = Double.parseDouble(System.getProperty("os.version")); //$NON-NLS-1$
			} catch (NumberFormatException e) {
				osVersion = 0;
			}

			if (osVersion >= 6) { // Vista or higher
				String progid = queryWindowsRegistry(
					"HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice", //$NON-NLS-1$
					"Progid"); //$NON-NLS-1$
				if (progid != null) {
					browser = getClassShellOpenCommand(progid);
				}
			}

			if (browser == null) {
				browser = getClassShellOpenCommand("http"); //$NON-NLS-1$
			}

			if (browser != null) {
				browser = extractExenameFromCommandString(browser);
				return new File(browser);
			} else {
				return null;
			}
		} catch (IOException e) {
			return null;
		}
	}

	private String getClassShellOpenCommand(String clazz) throws IOException {
		return queryWindowsRegistry("HKEY_CLASSES_ROOT\\" + clazz + "\\shell\\open\\command", null); //$NON-NLS-1$ //$NON-NLS-2$
	}

	/**
	 * Note, this function is Windows-specific.
	 */
	private File determineExeForType(String type)
	{
		String it = null;
		try
		{
			String[] cmd = new String[] { "cmd", "/d", "/c", "ftype", type }; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
			Process p = Runtime.getRuntime().exec(cmd);
			LineNumberReader lnr = new LineNumberReader(new InputStreamReader(p.getInputStream()));
			String line = null;
			type += "="; //$NON-NLS-1$
			while( it == null && (line = lnr.readLine()) != null)
			{
				if (line.length() < type.length() ||
					line.substring(0, type.length()).compareToIgnoreCase(type) == 0)
				{
					it = line;
					break;
				}
			}
			p.destroy();

			// if we have one extract cmd = " "
			if (it != null)
			{
				int equalSign = it.indexOf('=');
				if (equalSign != -1)
					it = it.substring(equalSign+1);

				it = extractExenameFromCommandString(it);
			}
		}
		catch (IOException e)
		{
			// means it didn't work
		}

		if (it != null)
			return new File(it);
		else
			return null;
	}

	/**
	 * Given a command string of the form
	 * 		"path_to_exe" args
	 * or
	 * 		path_to_exe args
	 * 
	 * return the path_to_exe.  Note that path_to_exe may contain spaces.
	 */
	protected String extractExenameFromCommandString(String cmd)
	{
		// now strip trailing junk if any
		if (cmd.startsWith("\"")) { //$NON-NLS-1$
			// ftype is enclosed in quotes
			int closingQuote =  cmd.indexOf('"', 1);
			if (closingQuote == -1)
				closingQuote = cmd.length();
			cmd = cmd.substring(1, closingQuote);
		} else {
			// Some ftypes don't use enclosing quotes.  This is tricky -- we have to
			// scan through the string, stopping at each space and checking whether
			// the filename up to that point refers to a valid filename.  For example,
			// if the input string is
			//
			//     C:\Program Files\Macromedia\Flash 9\Players\SAFlashPlayer.exe %1
			//
			// then we need to stop at each space and see if that is an EXE name:
			//
			//     C:\Program.exe
			//     C:\Program Files\Macromedia\Flash.exe
			//     C:\Program Files\Macromedia\Flash 9\Players\SAFlashPlayer.exe

			int endOfFilename = -1;
			for (;;) {
				int nextSpace = cmd.indexOf(' ', endOfFilename+1);
				if (nextSpace == -1) {
					endOfFilename = -1;
					break;
				}
				String filename = cmd.substring(0, nextSpace);
				if (!filename.toLowerCase().endsWith(".exe")) //$NON-NLS-1$
					filename += ".exe"; //$NON-NLS-1$
				if (new File(filename).exists()) {
					endOfFilename = nextSpace;
					break;
				}
				endOfFilename = nextSpace;
			}
			if (endOfFilename != -1 && endOfFilename < cmd.length())
				cmd = cmd.substring(0, endOfFilename);
		}
		return cmd;
	}

	/*
	 * @see flash.tools.debugger.IDebuggerCallbacks#launchDebugTarget(java.lang.String[])
	 */
	public Process launchDebugTarget(String[] cmd) throws IOException
	{
		return Runtime.getRuntime().exec(cmd);
	}

	/*
	 * @see flash.tools.debugger.IDebuggerCallbacks#terminateDebugTarget(java.lang.Process)
	 */
	public void terminateDebugTarget(Process process) throws IOException
	{
		process.destroy();
	}

	/**
	 * This implementation of queryWindowsRegistry() does not make any native
	 * calls.  I had to do it this way because it is too hard, at this point,
	 * to add native code to the Flex code tree.
	 */
	public String queryWindowsRegistry(String key, String value) throws IOException
	{
		Process p = null;
		String result = null;

		List<String> arguments = new ArrayList<String>(6);
		arguments.add("reg.exe"); //$NON-NLS-1$
		arguments.add("query"); //$NON-NLS-1$
		arguments.add(key);
		if (value == null || value.length() == 0)
		{
			arguments.add("/ve"); //$NON-NLS-1$
		}
		else
		{
			arguments.add("/v"); //$NON-NLS-1$
			arguments.add(value);
		}

		// This line must not be in try/catch -- if it throws an exception,
		// we want that to propagate out to our caller.
		p = Runtime.getRuntime().exec(arguments.toArray(new String[arguments.size()]));

		try
		{
			BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));

			String line;
			while ((line = reader.readLine()) != null)
			{
				if (line.equalsIgnoreCase(key))
				{
					line = reader.readLine();
					if (line != null)
					{
						Matcher matcher = registryValuePattern.matcher(line);
						if (matcher.find()) {
							result = matcher.group(1);
						}
					}
					break;
				}
			}
		}
		catch (IOException e)
		{
			if (Trace.error)
				e.printStackTrace();
		}
		finally
		{
			if (p != null)
			{
				p.destroy();
				p = null;
			}
		}

		return result;
	}

	/**
	 * Default implementation does not know how to get the version
	 * of an application.
	 */
	public int[] getAppVersion(File application) throws IOException {
		return null;
	}
	
	/**
	 * Default application does not have any extra arguments for the
	 * browser.
	 */
	public String[] getBrowserParameters(String uri)
	{
		return null;
	}
}
