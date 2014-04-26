/*
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
 */

package flash.tools.debugger;

import java.io.IOException;

/**
 * A SessionManager controls connection establishment and preferences 
 * for all debugging sessions with the Flash Player.
 * 
 * To begin a new debugging session:
 * 
 * <ol>
 * <li> Get a <code>SessionManager</code> from <code>Bootstrap.sessionManager()</code> </li>
 * <li> Call <code>SessionManager.startListening()</code> </li>
 * <li> If you want to have the API launch the Flash Player for you, call
 *      <code>SessionManager.launch()</code>.  If you want to launch the Flash Player
 *      and then have the API connect to it, then launch the Flash Player and then
 *      call <code>SessionManager.accept()</code>. <em>Note:</em> <code>launch()</code> 
 *      and <code>accept()</code> are both blocking calls, so you probably don't want
 *      to call them from your main UI thread. </li>
 * <li> Finally, call <code>SessionManager.stopListening()</code>.
 * </ol>
 */
public interface SessionManager
{
	/**
	 * The preferences are set using the setPreference() method, and
	 * take effect immediately thereafter.
	 */

	/**
	 * The value used for <code>$accepttimeout</code> controls how long (in
	 * milliseconds) <code>accept()</code> waits before timing out. The
	 * default value for this preference is 120000 (2 minutes).
	 */
	public static final String PREF_ACCEPT_TIMEOUT				= "$accepttimeout"; //$NON-NLS-1$

	/**
	 * Valid values for <code>$urimodification</code> are 0 (off) and 1 (on).
	 * The default value is 1 (on), which allows this API to modify the URI
	 * passed to <code>launch()</code> as necessary for creating a debuggable
	 * version of an MXML file.
	 */
	public static final String PREF_URI_MODIFICATION			= "$urimodification"; //$NON-NLS-1$

	/**
	 *-----------------------------------------------------------------
	 * The following are Session specific preferences.  These can be
	 * modified in this class, resulting in all future sessions using
	 * the values or they can be modified at the session level via
	 * Session.setPreference().
	 *-----------------------------------------------------------------
	 */

	/**
	 * <code>$responsetimeout</code> is used to determine how long (in
	 * milliseconds) the session will wait, for a player response before giving
	 * up on the request and throwing an Exception.
	 */
	public static final String PREF_RESPONSE_TIMEOUT			= "$responsetimeout"; //$NON-NLS-1$
	
	/**
	 * <code>$sockettimeout</code> is used to determine how long (in
	 * milliseconds) the session will wait on a Socket recv call.
	 * On timeout, we do not immediately abort the session, instead we
	 * write a squelch message to player. If the write succeeds, we assume
	 * everything is normal.This helps identify broken connections that 
	 * are relevant when performing WiFi debugging. 
	 * This is -1 by default to indicate no timeout 
	 * (for backward compatibility).
	 */
	public static final String PREF_SOCKET_TIMEOUT			= "$sockettimeout"; //$NON-NLS-1$

	/**
	 * <code>$contextresponsetimeout</code> is used to determine how long (in
	 * milliseconds) the session will wait for a player response from a request
	 * to get context, before giving up on the request and throwing an
	 * Exception.
	 */
	public static final String PREF_CONTEXT_RESPONSE_TIMEOUT	= "$contextresponsetimeout"; //$NON-NLS-1$

	/**
	 * <code>$getvarresponsetimeout</code> is used to determine how long (in
	 * milliseconds) the session will wait, for a player response to a get
	 * variable request before giving up on the request and throwing an
	 * Exception.
	 */
	public static final String PREF_GETVAR_RESPONSE_TIMEOUT		= "$getvarresponsetimeout"; //$NON-NLS-1$

	/**
	 * <code>$setvarresponsetimeout</code> is the amount of time (in
	 * milliseconds) that a setter in the user's code will be given to execute,
	 * before the player interrupts it with a ScriptTimeoutError. Default value
	 * is 5000 ms.
	 */
	public static final String PREF_SETVAR_RESPONSE_TIMEOUT		= "$setvarresponsetimeout"; //$NON-NLS-1$

	/**
	 * <code>$swfswdloadtimeout<code> is used to determine how long (in milliseconds)
	 * the session will wait, for a player response to a swf/swd load 
	 * request before giving up on the request and throwing an Exception.
	 */
	public static final String PREF_SWFSWD_LOAD_TIMEOUT			= "$swfswdloadtimeout"; //$NON-NLS-1$

	/**
	 * <code>$suspendwait</code> is the amount of time (in milliseconds) that
	 * a Session will wait for the Player to suspend, after a call to
	 * <code>suspend()</code>.
	 */
	public static final String PREF_SUSPEND_WAIT				= "$suspendwait"; //$NON-NLS-1$

	/**
	 * <code>$invokegetters</code> is used to determine whether a getter
	 * property is invoked or not when requested via <code>getVariable()</code>
	 * The default value is for this to be enabled.
	 */
	public static final String PREF_INVOKE_GETTERS				= "$invokegetters"; //$NON-NLS-1$

	public static final String PLAYER_SUPPORTS_GET				= "$playersupportsget"; //$NON-NLS-1$

	/**
	 * <code>$hiervars</code> is used to determine whether the members of
	 * a variable are shown in a hierchical way.
	 */
	public static final String PREF_HIERARCHICAL_VARIABLES		= "$hiervars"; //$NON-NLS-1$

	/**
	 * The value used for <code>$connecttimeout</code> controls how long (in
	 * milliseconds) <code>connect()</code> waits before timing out. The
	 * default value for this preference is 120000 (2 minutes).
	 */
	public static final String PREF_CONNECT_TIMEOUT				= "$connecttimeout"; //$NON-NLS-1$

	 /**
     * The value used for <code>$connectwaitinterval</code> controls how long (in
     * milliseconds) we wait between subsequent <code>connect()</code> calls. The
     * default value for this preference is 250.
     */
    public static final String PREF_CONNECT_WAIT_INTERVAL = "$connectwaitinterval"; //$NON-NLS-1$

    /**
     * The value used for <code>$connectretryattempts</code> controls how many times
     * the debugger retries connecting to the application. This is time bound by 
     * <code>$connecttimeout</code>. The default value for this preference is -1 and
     * indicates that the debugger should retry till the timeout period has elapsed.
     * Setting this to zero will disable the retry mechanism.
     */
    public static final String PREF_CONNECT_RETRY_ATTEMPTS = "$connectretryattempts"; //$NON-NLS-1$
    
	/**
	 * Set preference for this manager and for subsequent Sessions 
	 * that are initiated after this call.
	 * 
	 * If an invalid preference is passed, it will be silently ignored.
	 * @param pref preference name, one of the strings listed above
	 * @param value value to set for preference
	 */
	public void setPreference(String pref, int value);

	/**
	 * Set preference for this manager and for subsequent Sessions 
	 * that are initiated after this call.
	 * 
	 * If an invalid preference is passed, it will be silently ignored.
	 * @param pref preference name, one of the strings listed above
	 * @param value value to set for preference
	 */
	public void setPreference(String pref, String value);

	/**
	 * Return the value of a particular preference item
	 * 
	 * @param pref preference name, one of the strings listed above
	 * @throws NullPointerException if pref does not exist
	 */
	public int getPreference(String pref) throws NullPointerException;

	/**
	 * Listens for Player attempts to open a debug session. This method must be
	 * called prior to <code>accept()</code> being invoked.
	 * 
	 * @throws IOException
	 *             if opening the server side socket fails
	 */
	public void startListening() throws IOException;

	/**
	 * Stops listening for new Player attempts to open a debug session. The
	 * method DOES NOT terminate currently connected sessions, but will cause
	 * threads blocked in <code>accept</code> to throw SocketExceptions.
	 */
	public void stopListening() throws IOException;

	/**
	 * Is this object currently listening for Debug Player connections 
	 * @return TRUE currently listening 
	 */
	public boolean isListening();

	/**
	 * Launches a Player using the given string as a URI, as defined by RFC2396.
	 * It is expected that the operating system will be able to launch the
	 * appropriate player application given this URI.
	 * <p>
	 * For example "http://localhost:8100/flex/my.mxml" or for a local file on
	 * Windows, "file://c:/my.swf"
	 * <p>
	 * This call will block until a session with the newly launched player is
	 * created.
	 * <p>
	 * It is the caller's responsibility to ensure that no other thread is
	 * blocking in <code>accept()</code>, since that thread will gain control
	 * of this session.
	 * <p>
	 * Before calling <code>launch()</code>, you should first call
	 * <code>supportsLaunch()</code>. If <code>supportsLaunch()</code>
	 * returns false, then you will have to tell the user to manually launch the
	 * Flash player.
	 * <p>
	 * Also, before calling <code>launch()</code>, you must call
	 * <code>startListening()</code>.
	 * 
	 * @param uri
	 *            which will launch a Flash player under running OS. For
	 *            Flash/Flex apps, this can point to either a SWF or an HTML
	 *            file. For AIR apps, this must point to the application.xml
	 *            file for the application.
	 * @param airLaunchInfo
	 *            If trying to launch an AIR application, this argument must be
	 *            specified; it gives more information about how to do the
	 *            launch. If trying to launch a regular web-based Flash or Flex
	 *            application, such as one that will be in a browser or in the
	 *            standalone Flash Player, this argument should be
	 *            <code>null</code>.
	 * @param forDebugging
	 *            if <code>true</code>, then the launch is for the purposes
	 *            of debugging. If <code>false</code>, then the launch is
	 *            simply because the user wants to run the movie but not debug
	 *            it; in that case, the return value of this function will be
	 *            <code>null</code>.
	 * @param waitReporter
	 *            a progress monitor to allow accept() to notify its parent how
	 *            long it has been waiting for the Flash player to connect to
	 *            it. May be <code>null</code> if the caller doesn't need to
	 *            know how long it's been waiting.
	 * @param launchNotification
	 *            a notifier to notify the caller about ADL Exit Code.
	 *            Main usage is for ADL Exit Code 1 (Successful invocation of an 
	 *            already running AIR application. ADL exits immediately).
	 *            May be <code>null</code> if no need to listen ADL. 
	 *            Will only be called if forDebugging is false.  (If forDebugging
	 *            is true, error conditions are handled by throwing an exception.)
	 *			  The callback will be called on a different thread.
	 * @return a Session to use for debugging, or null if forDebugging==false.
	 *         The return value is not used to indicate an error -- exceptions
	 *         are used for that. If this function returns without throwing an
	 *         exception, then the return value will always be non-null if
	 *         forDebugging==true, or null if forDebugging==false.
	 * @throws BindException
	 *             if <code>isListening()</code> == false
	 * @throws FileNotFoundException
	 *             if file cannot be located
	 * @throws CommandLineException
	 *             if the program that was launched exited unexpectedly. This
	 *             will be returned, for example, when launching an AIR
	 *             application, if adl exits with an error code.
	 *             CommandLineException includes functions to return any error
	 *             text that may have been sent to stdout/stderr, and the exit
	 *             code of the program.
	 * @throws IOException
	 *             see Runtime.exec()
	 */
	public Session launch(String uri, AIRLaunchInfo airLaunchInfo,
			boolean forDebugging, IProgress waitReporter, ILaunchNotification launchNotification) throws IOException;

	/**
	 * Returns information about the Flash player which will be used to run the
	 * given URI.
	 * 
	 * @param uri
	 *            The URI which will be passed to <code>launch()</code> -- for
	 *            example, <code>http://flexserver/mymovie.mxml</code> or
	 *            <code>c:\mymovie.swf</code>. If launching an AIR app, this
	 *            should point to the app's *-app.xml file.
	 * @param airLaunchInfo
	 *            If launching an AIR app, this should, if possible, contain
	 *            info about the version of AIR being launched, but it can be
	 *            null if you don't have that information. If launching a
	 *            web-based app, this should be null.
	 * @return a {@link Player} which can be used to determine information about
	 *         the player -- for example, whether it is a debugger-enabled
	 *         player. Returns <code>null</code> if the player cannot be
	 *         determined. <em>Important:</em> There are valid situations in
	 *         which this will return <code>null</code>
	 */
	public Player playerForUri(String uri, AIRLaunchInfo airLaunchInfo);

	/**
	 * Returns whether this platform supports the <code>launch()</code>
	 * command; that is, whether the debugger can programmatically launch the
	 * Flash player. If this function returns false, then the debugger will have
	 * to tell the user to manually launch the Flash player.
	 * 
	 * @return true if this platform supports the <code>launch()</code>
	 *         command.
	 */
	public boolean supportsLaunch();

	/**
	 * Blocks until the next available player debug session commences, or until
	 * <code>getPreference(PREF_ACCEPT_TIMEOUT)</code> milliseconds pass.
	 * <p>
	 * Before calling <code>launch()</code>, you must call
	 * <code>startListening()</code>.
	 * <p>
	 * Once a Session is obtained, Session.bind() must be called prior to any
	 * other Session method.
	 * 
	 * @param waitReporter
	 *            a progress monitor to allow accept() to notify its parent how
	 *            long it has been waiting for the Flash player to connect to it.
	 *            May be <code>null</code> if the caller doesn't need to know how
	 *            long it's been waiting.
	 * @throws BindException
	 *             if isListening() == false
	 * @throws IOException -
	 *             see java.net.ServerSocket.accept()
	 */
	public Session accept(IProgress waitReporter) throws IOException;

	/**
	 * Tells the session manager to use the specified IDebuggerCallbacks for
	 * performing certain operatios, such as finding the Flash Player and
	 * launching the debug target. If you do not call this, the session manager
	 * will use a <code>DefaultDebuggerCallbacks</code> object.
	 */
	public void setDebuggerCallbacks(IDebuggerCallbacks debugger);

	/**
	 * Initiate a debug session by connecting to the specified port. Blocks 
	 * until a connection is made, or until 
	 * <code>getPreference(PREF_CONNECT_TIMEOUT)</code> milliseconds pass.
	 * <p>
	 * This work-flow is a reverse of <code>accept()</code> and suited for 
	 * cases where the player is unable to initiate the connection. The 
	 * player must be listening on the specified port for an incoming debug 
	 * connection. In addition, this function calls bind() on the session
	 * to determine if the handshake was successful so that retry works
	 * correctly even across port-forwards.
	 * <p> 
	 * Use <code>stopConnecting()</code> to cancel connect,
	 * <code>isConnecting()</code> to check if we are currently trying to 
	 * connect.
	 * 
	 * @param port - The port to connect to. See DProtocol.DEBUG_CONNECT_PORT.
	 * @param waitReporter
	 * @return A Session object on which bind() has already been called.
	 * @throws IOException - This may have a wrapped VersionException due to bind()
	 */
	public Session connect(int port, IProgress waitReporter) throws IOException;
	
	/**
	 * Stops connecting to the Player for a debug session. The
	 * method DOES NOT terminate currently connected sessions, but will cause
	 * threads blocked in <code>connect</code> to throw SocketExceptions.
	 */
	public void stopConnecting() throws IOException;

	/**
	 * Is this object currently connecting to the Debug Player 
	 * @return TRUE currently connecting 
	 */
	public boolean isConnecting();
}
