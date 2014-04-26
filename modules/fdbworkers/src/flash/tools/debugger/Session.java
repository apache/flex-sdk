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

import flash.tools.debugger.events.DebugEvent;
import flash.tools.debugger.expression.PlayerFaultException;

/**
 * The Session object manages all aspects of debugging session with
 * the Flash Player.  A program can be suspended, resumed, single
 * stepping can be performed and state information can be obtained
 * through this object.
 */
public interface Session
{
	/**
	 * Returns the URL that identifies this Session.
	 * Note: this may not be unique across Sessions if
	 * the same launching mechanism and SWF are used.
	 * @return URI received from the connected Player.
	 * It identifies the debugging session
	 */
	public String getURI();

	/**
	 * Returns the Process object, if any, that triggered this Session.
	 * @return the Process object that was used to create this Session.
	 * If SessionManager.launch() was not used, then null is returned.
	 */
	public Process getLaunchProcess();

	/**
	 * Adjust the preferences for this session; see SessionManager
	 * for a list of valid preference strings.
	 *
	 * If an invalid preference is passed, it will be silently ignored.
	 * @param pref preference name, one of the strings listed above
	 * @param value value to set for preference
	 */
	public void setPreference(String pref, int value);

	/**
	 * Return the value of a particular preference item
	 *
	 * @param pref preference name, one of the strings listed in <code>SessionManager</code>
	 * @throws NullPointerException if pref does not exist
	 * @see SessionManager
	 */
	public int getPreference(String pref) throws NullPointerException;

	/**
	 * Is the Player currently connected for this session.  This function
	 * must be thread-safe.
	 *
	 * @return true if connection is alive
	 */
	public boolean isConnected();

	/**
	 * Allow the session to start communicating with the player.  This
	 * call must be made PRIOR to any other Session method call.
	 * @return true if bind was successful.
	 * @throws VersionException connected to Player which does not support all API completely
	 */
	public boolean bind() throws VersionException;

	/**
	 * Permanently stops the debugging session and breaks the
	 * connection.  If this Session is used for any subsequent
	 * calls exceptions will be thrown.
	 * <p>
	 * Note: this method allows the caller to disconnect
	 * from the debugging session (and Player) without
	 * terminating the Player.  A subsequent call to terminate()
	 * will destroy the Player process.
	 * <p>
	 * Under normal circumstances this method need not be
	 * called since a call to terminate() performs both
	 * actions of disconnecting from the Player and destroying
	 * the Player process.
	 */
	public void unbind();

	/**
	 * Permanently stops the debugging session and breaks the connection. If
	 * this session ID is used for any subsequent calls exceptions will be
	 * thrown.
	 * <p>
	 * Note that due to platform and browser differences, it should not be
	 * assumed that this function will necessarily kill the process being
	 * debugged. For example:
	 *
	 * <ul>
	 * <li> On all platforms, Firefox cannot be terminated. This is because when
	 * we launch a new instance of Firefox, Firefox actually checks to see if
	 * there is another already-running instance. If there is, then the new
	 * instance just passes control to that old instance. So, the debugger
	 * doesn't know the process ID of the browser. It would be bad to attempt to
	 * figure out the PID and then kill that process, because the user might
	 * have other browser windows open that they don't want to lose. </li>
	 * <li> On Mac, similar problems apply to the Safari and Camino browsers:
	 * all browsers are launched with /usr/bin/open, so we never know the
	 * process ID, and we can't kill it. However, for Safari and Camino, what we
	 * do attempt to do is communicate with the browser via AppleScript, and
	 * tell it to close the window of the program that is being debugged. </li>
	 * </ul>
	 *
	 * <p>
	 * If SessionManager.launch() was used to initiate the Session then calling
	 * this function also causes getLaunchProcess().destroy() to be called.
	 * <p>
	 * Note: this method first calls unbind() if needed.
	 */
	public void terminate();

	/**
	 * Continue a halted session.  Execution of the ActionScript
	 * will commence until a reason for halting exists. That
	 * is, a breakpoint is reached or the <code>suspend()</code> method is called.
	 * <p>
	 * This method will NOT block.  It will return immediately
	 * after the Player resumes execution.  Use the isSuspended
	 * method to determine when the Player has halted.
	 *
	 * @throws NoResponseException if times out
	 * @throws NotSuspendedException if Player is already running
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public void resume() throws NotSuspendedException, NotConnectedException, NoResponseException;

	/**
	 * Halt a running session.  Execution of the ActionScript
	 * will stop at the next possible breakpoint.
	 * <p>
	 * This method WILL BLOCK until the Player halts for some
	 * reason or an error occurs. During this period, one or
	 * more callbacks may be initiated.
	 *
	 * @throws NoResponseException if times out
	 * @throws SuspendedException if Player is already suspended
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public void suspend() throws SuspendedException, NotConnectedException, NoResponseException;
	
	/**
	 * Is the Player currently halted awaiting requests, such as continue,
	 * stepOut, stepIn, stepOver. This function is guaranteed to be thread-safe.
	 *
	 * @return true if player halted
	 * @throws NotConnectedException
	 *             if Player is disconnected from Session
	 */
	public boolean isSuspended() throws NotConnectedException;

	/**
	 * Returns a SuspendReason integer which indicates
	 * why the Player has suspended execution.
	 * @return see SuspendReason
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public int suspendReason() throws NotConnectedException;
	
	/**
	 * Returns an array of frames that identify the location and contain
	 * arguments, locals and 'this' information for each frame on the
	 * function call stack.   The 0th frame contains the current location
	 * and context for the actionscript program.  Likewise
	 * getFrames[getFrames().length] is the topmost (or outermost) frame
	 * of the call stack.
	 * @return array of call frames with 0th element representing the current frame.
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public Frame[] getFrames() throws NotConnectedException;
	
	/**
	 * Step to the next executable source line within the
	 * program, will enter into functions.
	 * <p>
	 * This method will NOT block.  It will return immediately
	 * after the Player resumes execution.  Use the isSuspended
	 * method to determine when the Player has halted.
	 *
	 * @throws NoResponseException if times out
	 * @throws NotSuspendedException if Player is running
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public void stepInto() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Step out of the current method/function onto the
	 * next executable soruce line.
	 * <p>
	 * This method will NOT block.  It will return immediately
	 * after the Player resumes execution.  Use the isSuspended
	 * method to determine when the Player has halted.
	 *
	 * @throws NoResponseException if times out
	 * @throws NotSuspendedException if Player is running
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public void stepOut()  throws NotSuspendedException, NoResponseException, NotConnectedException;

	/**
	 * Step to the next executable source line within
	 * the program, will NOT enter into functions.
	 * <p>
	 * This method will NOT block.  It will return immediately
	 * after the Player resumes execution.  Use the isSuspended
	 * method to determine when the Player has halted.
	 *
	 * @throws NoResponseException if times out
	 * @throws NotSuspendedException if Player is running
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public void stepOver() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Continue the process of stepping.
	 * This call should only be issued if a previous
	 * stepXXX() call was made and the Player suspended
	 * execution due to a breakpoint being hit.
	 * That is getSuspendReason() == SuspendReason.Break
	 * This operation can be used for assisting with
	 * the processing of conditional breakpoints.
	 * @throws NoResponseException if times out
	 * @throws NotSuspendedException if Player is running
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public void stepContinue() throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Obtain information about the various SWF(s) that have been
	 * loaded into the Player, for this session.
	 *
	 * Note: As SWFs are loaded by the Player a SwfLoadedEvent is
	 * fired.  At this point, a call to getSwfInfo() will provide
	 * updated information.
	 *
	 * @return array of records describing the SWFs
	 * @throws NoResponseException if times out
	 */
	public SwfInfo[] getSwfs() throws NoResponseException;
	
	/**
	 * Get a list of the current breakpoints.  No specific ordering
	 * of the breakpoints is implied by the array.
	 * @return breakpoints currently set.
	 * @throws NoResponseException if times out
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public Location[] getBreakpointList() throws NoResponseException, NotConnectedException;

	/**
	 * Set a breakpoint on a line within the given file.
	 * <p>
	 * <em>Warning:</em> <code>setBreakpoint()</code> and
	 * <code>clearBreakpoint()</code> do not keep track of how many times they
	 * have been called for a given Location. For example, if you make two calls
	 * to <code>setBreakpoint()</code> for file X.as line 10, and then one
	 * call to <code>clearBreakpoint()</code> for that same file and line,
	 * then the breakpoint is gone. So, the caller is responsible for keeping
	 * track of whether the user has set two breakpoints at the same location.
	 *
	 * @return null if breakpoint not set, otherwise
	 * Location of breakpoint.
	 * @throws NoResponseException if times out
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public Location setBreakpoint(int fileId, int lineNum) throws NoResponseException, NotConnectedException;
	
	/**
	 * Remove a breakpoint at given location. The Location obtain can be a
	 * clone/copy of a Location object returned from a previous call to
	 * getBreakpointList().
	 * <p>
	 * <em>Warning:</em> <code>setBreakpoint()</code> and
	 * <code>clearBreakpoint()</code> do not keep track of how many times they
	 * have been called for a given Location. For example, if you make two calls
	 * to <code>setBreakpoint()</code> for file X.as line 10, and then one
	 * call to <code>clearBreakpoint()</code> for that same file and line,
	 * then the breakpoint is gone. So, the caller is responsible for keeping
	 * track of whether the user has set two breakpoints at the same location.
	 *
	 * @return null if breakpoint was not removed.
	 * @throws NoResponseException
	 *             if times out
	 * @throws NotConnectedException
	 *             if Player is disconnected from Session
	 */
	public Location clearBreakpoint(Location location) throws NoResponseException, NotConnectedException;

	/**
	 * Get a list of the current watchpoint.  No specific ordering
	 * of the watchpoints is implied by the array.  Also, the
	 * list may contain watchpoints that are no longer relevant due
	 * to the variable going out of scope.
	 * @return watchpoints currently set.
	 * @throws NoResponseException if times out
	 * @throws NotConnectedException if Player is disconnected from Session
	 * @since Version 2
	 */
	public Watch[] getWatchList() throws NoResponseException, NotConnectedException;
	
	/**
	 * Set a watchpoint on a given variable.  A watchpoint is used
	 * to suspend Player execution upon access of a particular variable.
	 * If the variable upon which the watchpoint is set goes out of scope,
	 * the watchpoint will NOT be automatically removed.
	 * <p>
	 * Specification of the variable item to be watched requires two
	 * pieces of information (similar to setScalarMember())
	 * The Variable and the name of the particular member to be watched
	 * within the variable.
	 * For example if the watchpoint is to be applied to 'a.b.c'.  First the
	 * Value for object 'a.b' must be obtained and then the call
	 * setWatch(v, "c", ...) can be issued.
	 * The watchpoint can be triggered (i.e. the Player suspended) when either a read
	 * or write (or either) occurs on the variable.  If the Player is suspended
	 * due to a watchpoint being fired, then the suspendReason() call will
	 * return SuspendReason.WATCH.
	 * <p>
	 * Setting a watchpoint multiple times on the same variable will result
	 * in the old watchpoint being removed from the list and a new watchpoint
	 * being added to the end of the list.
	 * <p>
	 * Likewise, if a previously existing watchpoint is modified by
	 * specifiying a different kind variable then the old watchpoint
	 * will be removed from the list and a new watchpoint will be added
	 * to the end of the list.
	 *
	 * @param v the variable, upon whose member, the watch is to be placed.
	 * @param varName is the mmeber name upon which the watch
	 * should be placed.  This variable name may NOT contain the dot ('.')
	 * character and MUST be a member of v.
	 * @param kind access type that will trigger the watchpoint to fire --
	 * read, write, or read/write.  See <code>WatchKind</code>.
	 * @return null if watchpoint was not created.
	 * @throws NoResponseException if times out
	 * @throws NotConnectedException if Player is disconnected from Session
	 * @throws NotSupportedException if the Player does not support watchpoints,
	 * or does not support watchpoints on this particular member (e.g. because
	 * it is a getter or a dynamic variable).
	 * @since Version 2
	 * @see WatchKind
	 */
	public Watch setWatch(Value v, String memberName, int kind) throws NoResponseException, NotConnectedException, NotSupportedException;
	
	/**
	 * Enables or disables a watchpoint.
	 *
	 * @param watch
	 *            the watch to enable or disable
	 * @param enabled
	 *            whether to enable it or disable it
	 * @throws NotSupportedException
	 * @throws NotConnectedException
	 * @throws NoResponseException
	 */
	public Watch setWatch(Watch watch) throws NoResponseException, NotConnectedException, NotSupportedException;

	/**
	 * Remove a previously created watchpoint.  The watchpoint
	 * that was removed will be returned upon a sucessful call.
	 * @return null if watchpoint was not removed.
	 * @throws NoResponseException if times out
	 * @throws NotConnectedException if Player is disconnected from Session
	 * @since Version 2
	 */
	public Watch clearWatch(Watch watch) throws NoResponseException, NotConnectedException;
	
	/**
	 * Obtains a list of variables that are local to the current
	 * halted state.
	 * @deprecated As of version 2.
	 * @see Frame#getLocals
	 */
	public Variable[] getVariableList() throws NotSuspendedException, NoResponseException, NotConnectedException, VersionException;
	
	/**
	 * From a given value identifier return a Value.  This call
	 * allows tools to access a specific value whenever the Player has
	 * suspended.  A Value's id is maintained for the life of the
	 * Value and is guaranteed not to change.  Values that
	 * go out of scope are no longer accessible and will result
	 * in a null being returned.   Also note, that scalar
	 * variables do not contain an id that can be referenced in
	 * this manner.  Therefore the caller must also maintain the
	 * 'context' in which the variable was obtained.  For example
	 * if a Number b exists on a, then the reference 'a.b' must be
	 * managed, as the id of 'a' will be needed to obtain the
	 * value of 'b'.
	 * @param valueId identifier from Value class or
	 * from a call to Value.getId()
	 * @return null, if value cannot be found or
	 * value with the specific id.
	 * @throws NoResponseException if times out
	 * @throws NotSuspendedException if Player is running
	 * @throws NotConnectedException if Player is disconnected from Session
	 */
	public Value getValue(long valueId) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Looks up a global name, like "MyClass", "String", etc.
	 *
	 * @return its value, or <code>null</code> if the global does not exist.
	 */
	public Value getGlobal(String name) throws NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Events provide a mechanism whereby status information is provided from
	 * the Player in a timely fashion.
	 * <p>
	 * The caller has the option of either polling the event queue via
	 * <code>nextEvent()</code> or calling <code>waitForEvent()</code> which
	 * blocks the calling thread until one or more events exist in the queue.
	 *
	 * @throws NotConnectedException
	 *             if Session is disconnected from Player
	 * @throws InterruptedException
	 */
	public void waitForEvent() throws NotConnectedException, InterruptedException;

	/**
	 * Returns the number of events currently in the queue.  This function
	 * is guaranteed to be thread-safe.
	 */
	public int getEventCount();

	/**
	 * Removes and returns the next event from queue
	 */
	public DebugEvent nextEvent();

	/**
	 * Gets the SourceLocator for this session.  If none has been
	 * specified, returns null.
	 */
    public SourceLocator getSourceLocator();

	/**
	 * Sets the SourceLocator for this session.  This can be used in order
	 * to override the default rules used for finding source files.
	 */
	public void setSourceLocator(SourceLocator sourceLocator);

	/**
	 * Invokes a constructor in the player. Returns the newly created object.
	 * Not supported in Player 9 or AIR 1.0. If you call this function and the
	 * player to which you are connected doesn't support this feature, this will
	 * throw a PlayerDebugException.
	 */
	public Value callConstructor(String classname, Value[] args) throws PlayerDebugException;

	/**
	 * Invokes a function. For example, calling
	 * <code>callFunction(myobj, "toString", new Value[0])</code> will call
	 * <code>myobj.toString()</code>. Not supported in Player 9 or AIR 1.0.
	 * If you call this function and the player to which you are connected
	 * doesn't support this feature, this will throw a PlayerDebugException.
	 */
	public Value callFunction(Value thisObject, String functionName, Value[] args) throws PlayerDebugException;
	
	/**
	 * The player always halts on exceptions that are not going to be caught;
	 * this call allows the debugger to control its behavior when an exception
	 * that *will* be caught is thrown.
	 *
	 * @throws NotSupportedException
	 *             thrown by older players that don't support this feature.
	 * @throws NoResponseException
	 */
	public void breakOnCaughtExceptions(boolean b) throws NotSupportedException, NoResponseException;

	/**
	 * Evaluate the ActionScript expression "value is type"
	 *
	 * @throws PlayerDebugException
	 * @throws PlayerFaultException
	 */
	public boolean evalIs(Value value, Value type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * Evaluate the ActionScript expression "value is type"
	 *
	 * @throws PlayerDebugException
	 * @throws PlayerFaultException
	 */
	public boolean evalIs(Value value, String type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * Evaluate the ActionScript expression "value instanceof type"
	 *
	 * @throws PlayerFaultException
	 * @throws PlayerDebugException
	 */
	public boolean evalInstanceof(Value value, Value type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * Evaluate the ActionScript expression "value instanceof type"
	 *
	 * @throws PlayerFaultException
	 * @throws PlayerDebugException
	 */
	public boolean evalInstanceof(Value value, String type) throws PlayerDebugException, PlayerFaultException;

	/**
	 * Evaluate the ActionScript expression "property in object"
	 *
	 * @throws PlayerFaultException
	 * @throws PlayerDebugException
	 */
	public boolean evalIn(Value property, Value object) throws PlayerDebugException, PlayerFaultException;

	/**
	 * Evaluate the ActionScript expression "value as type"
	 *
	 * @throws PlayerDebugException
	 * @throws PlayerFaultException
	 */
	public Value evalAs(Value value, Value type) throws PlayerDebugException, PlayerFaultException;
	
	/**
	 * Returns whether the target player supports watchpoints.
	 * @see #setWatch(Value, String, int)
	 */
	public boolean supportsWatchpoints();
	
	/**
	 * Returns the root SocketException that caused the rxMessage()
	 * thread to shut down. This works in conjunction with 
	 * PREF_SOCKET_TIMEOUT and helps in detecting broken connections.
	 */
	public Exception getDisconnectCause();

	/**
	 * Set an exception breakpoint. Returns true if succeeded.
	 * @param exceptionClass
	 * @return
	 * @throws NoResponseException
	 * @throws NotConnectedException
	 */
	public boolean setExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException;

	/**
	 * Clears an exception breakpoint. Returns true if succeeded.
	 * @param exceptionClass
	 * @return
	 * @throws NoResponseException
	 * @throws NotConnectedException
	 */
	public boolean clearExceptionBreakpoint(String exceptionClass) throws NoResponseException, NotConnectedException;
	
	// Concurrency begin
	
	/**
	 * Returns whether the target player supports concurrency.
	 * @see #setActiveIsolate(Value)
	 */
	public boolean supportsConcurrency();
	
	/**
	 * Get an array of all workers that the debugger knows of.
	 */
	public Isolate[] getWorkers();
	
	/**
	 * Ask the player again for a list of all workers. Use this
	 * method with caution as it will also reset all state about
	 * workers that the debugger is aware of.
	 */
	public Isolate[] refreshWorkers() throws  NotSupportedException, NotSuspendedException, NoResponseException, NotConnectedException;
	
	/**
	 * Return the worker specific session object that can be used
	 * to communicate with that worker.
	 */
	public IsolateSession getWorkerSession(int isolateId);
	
	/**
	 * 
	 * Sets the ILauncher instance which is associated with this session. 
	 * ILauncher instance is used to terminate the process at the end of the debugging session.
	 *
	 * @param launcher 
	 * 				ILauncher instance used to launch & terminate the process.
	 */
	public void setLauncher(ILauncher launcher);

}
