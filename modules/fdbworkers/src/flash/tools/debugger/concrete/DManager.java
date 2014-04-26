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

package flash.tools.debugger.concrete;

import java.io.InputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import flash.tools.debugger.Isolate;
import flash.tools.debugger.SourceLocator;
import flash.tools.debugger.SuspendReason;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.Value;
import flash.tools.debugger.VariableAttribute;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.events.BreakEvent;
import flash.tools.debugger.events.ConsoleErrorFault;
import flash.tools.debugger.events.DebugEvent;
import flash.tools.debugger.events.DivideByZeroFault;
import flash.tools.debugger.events.ExceptionFault;
import flash.tools.debugger.events.FaultEvent;
import flash.tools.debugger.events.FileListModifiedEvent;
import flash.tools.debugger.events.InvalidWithFault;
import flash.tools.debugger.events.IsolateCreateEvent;
import flash.tools.debugger.events.IsolateExitEvent;
import flash.tools.debugger.events.ProtoLimitFault;
import flash.tools.debugger.events.RecursionLimitFault;
import flash.tools.debugger.events.ScriptTimeoutFault;
import flash.tools.debugger.events.StackUnderFlowFault;
import flash.tools.debugger.events.SwfLoadedEvent;
import flash.tools.debugger.events.SwfUnloadedEvent;
import flash.tools.debugger.events.TraceEvent;
import flash.util.Trace;

/**
 * Implements the receiving and updating of debug state from the socket
 * connection of the Flash Player.
 */
public class DManager implements DProtocolNotifierIF, SourceLocator {
	private final HashMap<String, String> m_parms;

	private final HashMap<Integer, DIsolate> m_isolates; /*
														 * WARNING: accessed
														 * from multiple threads
														 */

	/**
	 * The currently active isolate or worker
	 */
	private Isolate m_activeIsolate = DEFAULT_ISOLATE;

	private LinkedList<DebugEvent> m_event; /*
											 * our event queue; WARNING:
											 * accessed from multiple threads
											 */
	private SourceLocator m_sourceLocator;


	private boolean m_squelchEnabled; /*
									 * true if we are talking to a squelch
									 * enabled debug player
									 */
	private int m_playerVersion; /*
								 * player version number obtained from InVersion
								 * message; e.g. 9 for Flash Player 9.0
								 */

	private boolean m_sourceListModified; /*
										 * deprecated; indicates m_source has
										 * changed since last call to
										 * getSource(). WARNING: lock with
										 * synchronized (m_source) { ... }
										 */
	private byte[] m_actions; /* deprecated */
	private String[] m_lastConstantPool; /* deprecated */

	// SWF/SWD fetching and parsing
	private String m_uri;
	private byte[] m_swf; // latest swf obtained from get swf
	private byte[] m_swd; // latest swd obtained from get swd

	private Map<String, String> m_options = new HashMap<String, String>(); // Player
																			// options
																			// that
																			// have
																			// been
																			// queried
																			// by
																			// OutGetOption,
																			// and
																			// come
																			// back
																			// via
																			// InOption

	public static final String ARGUMENTS_MARKER = "$arguments"; //$NON-NLS-1$
	public static final String SCOPE_CHAIN_MARKER = "$scopechain"; //$NON-NLS-1$
	
	private static final DIsolate DEFAULT_ISOLATE = DIsolate.DEFAULT_ISOLATE;
	private Isolate m_inIsolate = DEFAULT_ISOLATE;
	private final Object m_inIsolateLock;
	private final Object m_activeIsolateLock;
	private boolean m_wideLines;
	private DManagerIsolateState m_mainState;
	private HashMap<Integer, DManagerIsolateState> m_isolateState;


	class DManagerIsolateState {
		public DSuspendInfo m_suspendInfo;
		public DSwfInfo m_lastSwfInfo; /*
										 * hack for syncing swfinfo records with
										 * incoming InScript messages
										 */
		public DVariable m_lastInGetVariable;/*
											 * hack for getVariable call to work
											 * with getters
											 */
		public boolean m_attachChildren; /*
										 * hack for getVariable call to work
										 * with getters
										 */
		public DVariable m_lastInCallFunction; /* hack for callFunction to work */
		public DVariable m_lastInBinaryOp;
		private boolean m_executingPlayerCode;
		private FaultEvent m_faultEventDuringPlayerCodeExecution;

		public final ArrayList<DLocation> m_breakpoints; /*
														 * WARNING: accessed
														 * from multiple threads
														 */
		public final Map<Integer, DModule> m_source; /*
													 * WARNING: accessed from
													 * multiple threads
													 */
		private final ArrayList<DSwfInfo> m_swfInfo; /*
													 * WARNING: accessed from
													 * multiple threads
													 */
		private final ArrayList<DWatch> m_watchpoints; /*
														 * WARNING: accessed
														 * from multiple threads
														 */

		/**
		 * The currently active stack frames.
		 */
		public ArrayList<DStackContext> m_frames;

		/**
		 * The stack frames that were active the last time the player was
		 * suspended.
		 */
		public ArrayList<DStackContext> m_previousFrames;

		/**
		 * A list of all known variables in the player. Stored as a mapping from
		 * an object's id to its DValue.
		 */
		public Map<Long, DValue> m_values;

		/**
		 * A list of all known variables in the player from the previous time
		 * the player was suspended. Stored as a mapping from an object's id to
		 * its DValue.
		 */
		public Map<Long, DValue> m_previousValues;

		public DManagerIsolateState() {
			m_source = new HashMap<Integer, DModule>();
			m_values = new HashMap<Long, DValue>();
			m_previousValues = new HashMap<Long, DValue>();
			m_frames = new ArrayList<DStackContext>();
			m_previousFrames = new ArrayList<DStackContext>();
			m_suspendInfo = null;
			m_lastInCallFunction = null;
			m_breakpoints = new ArrayList<DLocation>();
			m_swfInfo = new ArrayList<DSwfInfo>();
			m_watchpoints = new ArrayList<DWatch>();
			m_suspendInfo = null;
			m_lastInGetVariable = null;
			m_attachChildren = true;
			m_lastInCallFunction = null;

		}
	}

	private DManagerIsolateState getIsolateState(int isolateId) {
		if (isolateId == Isolate.DEFAULT_ID)
			return m_mainState;
		
		DManagerIsolateState isolateState = null;
		if (!m_isolateState.containsKey(isolateId)) {
			isolateState = new DManagerIsolateState();
			m_isolateState.put(isolateId, isolateState);
		} else
			isolateState = m_isolateState.get(isolateId);
		return isolateState;
	}

	public DManager() {
		m_parms = new HashMap<String, String>();
		
		m_isolates = new HashMap<Integer, DIsolate>();
		m_isolates.put(Isolate.DEFAULT_ID, DEFAULT_ISOLATE);
		m_event = new LinkedList<DebugEvent>();
		m_sourceLocator = null;
		m_squelchEnabled = false;
		m_lastConstantPool = null;
		m_playerVersion = -1; // -1 => unknown
		m_isolateState = new HashMap<Integer, DManagerIsolateState>();
		m_mainState = new DManagerIsolateState();
		m_isolateState.put(Isolate.DEFAULT_ID, m_mainState);
		m_inIsolateLock = new Object();
		m_activeIsolateLock = new Object();
		m_wideLines = false;
	}

	public void setWideLines(boolean value) {
		m_wideLines = value;
	}
	
	public String getURI() {
		return m_uri;
	}

	public byte[] getSWF() {
		return m_swf;
	}

	public byte[] getSWD() {
		return m_swd;
	}

	public byte[] getActions() {
		return m_actions;
	}

	/** Returns the Flash Player version number; e.g. 9 for Flash Player 9.0 */
	public int getVersion() {
		return m_playerVersion;
	}

	public SourceLocator getSourceLocator() {
		return m_sourceLocator;
	}

	public void setSourceLocator(SourceLocator sl) {
		m_sourceLocator = sl;
	}

	/**
	 * If this feature is enabled then we do not attempt to attach child
	 * variables to parents.
	 */
	public void enableChildAttach(boolean enable, int isolateId) {
		getIsolateState(isolateId).m_attachChildren = enable;
	}

	// return/clear the last variable seen from an InGetVariable message
	public DVariable lastVariable(int isolateId) {
		return getIsolateState(isolateId).m_lastInGetVariable;
	}

	public void clearLastVariable(int isolateId) {
		getIsolateState(isolateId).m_lastInGetVariable = null;
	}

	// return/clear the last variable seen from an InCallFunction message
	public DVariable lastFunctionCall(int isolateId) {
		return getIsolateState(isolateId).m_lastInCallFunction;
	}

	public void clearLastFunctionCall(int isolateId) {
		getIsolateState(isolateId).m_lastInCallFunction = null;
	}

	// return/clear the last binary op result seen from an InBinaryOp message
	public DVariable lastBinaryOp(int isolateId) {
		return getIsolateState(isolateId).m_lastInBinaryOp;
	}

	public void clearLastBinaryOp(int isolateId) {
		getIsolateState(isolateId).m_lastInBinaryOp = null;
	}

	/*
	 * Frees up any information we have kept about
	 */
	void freeCaches(int isolateId) {
		clearFrames(isolateId);
		freeValueCache(isolateId);
	}

	void freeValueCache(int isolateId) {
		DManagerIsolateState state = getIsolateState(isolateId);
		state.m_previousValues = state.m_values;
		state.m_values = new HashMap<Long, DValue>();

		int size = getFrameCount(isolateId);
		for (int i = 0; i < size; i++)
			getFrame(i, isolateId).markStale();
	}

	// continuing our execution
	void continuing(int isolateId) {
		freeCaches(isolateId);
		getIsolateState(isolateId).m_suspendInfo = null;
	}

	/**
	 * Variables
	 */
	DValue getOrCreateValue(long id, int isolateId) {
		DValue v = getValue(id, isolateId);
		if (v == null) {
			v = new DValue(id, isolateId);
			putValue(id, v, isolateId);
		}
		return v;
	}

	public DSwfInfo[] getSwfInfos(int isolateId) {
		ArrayList<DSwfInfo> swfInfos = getIsolateState(isolateId).m_swfInfo;
		synchronized (swfInfos) {
			return swfInfos.toArray(new DSwfInfo[swfInfos.size()]);
		}
	}

	public DSwfInfo getSwfInfo(int at, int isolateId) {
		ArrayList<DSwfInfo> swfInfos = getIsolateState(isolateId).m_swfInfo;
		synchronized (swfInfos) {
			return swfInfos.get(at);
		}
	}

	public int getSwfInfoCount(int isolateId) {
		ArrayList<DSwfInfo> swfInfos = getIsolateState(isolateId).m_swfInfo;
		synchronized (swfInfos) {
			return swfInfos.size();
		}
	}

	/**
	 * Obtains a SwfInfo object at the given index or if one doesn't yet exist
	 * at that location, creates a new empty one there and returns it.
	 */
	DSwfInfo getOrCreateSwfInfo(int at, int isolateId) {
		ArrayList<DSwfInfo> swfInfos = getIsolateState(isolateId).m_swfInfo;
		synchronized (swfInfos) {
			DSwfInfo i = (at > -1 && at < getSwfInfoCount(isolateId)) ? getSwfInfo(
					at, isolateId) : null;
			if (i == null) {
				// are we above water
				at = (at < 0) ? 0 : at;

				// fill all the gaps with null; really shouldn't be any...
				while (at >= swfInfos.size())
					swfInfos.add(null);

				i = new DSwfInfo(at, isolateId);
				swfInfos.set(at, i);
			}
			return i;
		}
	}

	/**
	 * Get the most recently active swfInfo object. We define active as the most
	 * recently seen swfInfo
	 */
	DSwfInfo getActiveSwfInfo(int isolateId) {
		int count = getSwfInfoCount(isolateId);

		// pick up the last one seen
		DSwfInfo swf = getIsolateState(isolateId).m_lastSwfInfo;

		// still don't have one then get or create the most recent one
		// works if count = 0
		if (swf == null)
			swf = getOrCreateSwfInfo(count - 1, isolateId);

		if (swf.hasAllSource()) {
			// already full so create a new one on the end
			swf = getOrCreateSwfInfo(count, isolateId);
		}
		return swf;
	}

	/**
	 * Walk the list of scripts and add them to our swfInfo object This method
	 * may be called when min/max are zero and the swd has not yet fully loaded
	 * in the player or it could be called before we have all the scripts.
	 */
	void tieScriptsToSwf(DSwfInfo info, int isolateId) {
		if (!info.hasAllSource()) {
			int min = info.getFirstSourceId();
			int max = info.getLastSourceId();
			// System.out.println("attaching scripts "+min+"-"+max+" to "+info.getUrl());
			for (int i = min; i <= max; i++) {
				DModule m = getSource(i, isolateId);
				if (m == null) {
					// this is ok, it means the scripts are coming...
				} else {
					info.addSource(i, m);
				}
			}
		}
	}

	/**
	 * Record a new source file.
	 * 
	 * @param name
	 *            filename in "basepath;package;filename" format
	 * @param swfIndex
	 *            the index of the SWF with which this source is associated, or
	 *            -1 is we don't know
	 * @return true if our list of source files was modified, or false if we
	 *         already knew about that particular source file.
	 */
	private boolean putSource(int swfIndex, int moduleId, int bitmap,
			String name, String text, int isolateId) {
		// if isolateIndex is not -1, augment swfIndex and moduleId with isolate
		// info.
		Map<Integer, DModule> source = getIsolateState(isolateId).m_source;
		synchronized (source) {
			// if we haven't already recorded this script then do so.
			if (!source.containsKey(moduleId)) {
				DModule s = new DModule(this, moduleId, bitmap, name, text, isolateId);

				// put source in our large pool
				source.put(moduleId, s);

				// put the source in the currently active swf
				DSwfInfo swf;
				if (swfIndex == -1) // caller didn't tell us what swf thi is for
					swf = getActiveSwfInfo(isolateId); // ... so guess
				else
					swf = getOrCreateSwfInfo(swfIndex, isolateId);

				swf.addSource(moduleId, s);

				return true;
			}

			return false;
		}
	}

	/**
	 * Remove our record of a particular source file.
	 * 
	 * @param id
	 *            the id of the file to forget about.
	 * @return true if source file was removed; false if we didn't know about it
	 *         to begin with.
	 */
	private boolean removeSource(int id, int isolateId) {
		Map<Integer, DModule> source = getIsolateState(isolateId).m_source;
		synchronized (source) {
			try {
				source.remove(id);
			} catch (Exception e) {
				return false;
			}
			return true;
		}
	}

	public DModule getSource(int id, int isolateId) {
		Map<Integer, DModule> source = getIsolateState(isolateId).m_source;
		synchronized (source) {
			return source.get(id);
		}
	}

	// @deprecated
	public DModule[] getSources() {
		Map<Integer, DModule> source = getIsolateState(Isolate.DEFAULT_ID).m_source;
		synchronized (source) {
			m_sourceListModified = false;

			/* find out the size of the array */
			int count = source.size();
			DModule[] ar = new DModule[count];

			count = 0;
			for (DModule sf : source.values())
				ar[count++] = sf;
			return ar;
		}
	}

	// @deprecated
	boolean sourceListModified() {
		Map<Integer, DModule> source = getIsolateState(Isolate.DEFAULT_ID).m_source;
		synchronized (source) {
			return m_sourceListModified;
		}
	}

	public DValue getValue(long id, int isolateId) {
		return getIsolateState(isolateId).m_values.get(id);
	}

	/**
	 * Returns the previous value object for the given id -- that is, the value
	 * that that object had the last time the player was suspended. Never
	 * requests it from the player (because it can't, of course). Returns
	 * <code>null</code> if we don't have a value for that id.
	 */
	public DValue getPreviousValue(long id, int isolateId) {
		return getIsolateState(isolateId).m_previousValues.get(id);
	}

	void putValue(long id, DValue v, int isolateId) {
		if (id != Value.UNKNOWN_ID) {
			getIsolateState(isolateId).m_values.put(id, v);
		}
	}

	DValue removeValue(long id, int isolateId) {
		return getIsolateState(isolateId).m_values.remove((int)id);
	}

	void addVariableMember(long parentId, DVariable child, int isolateId) {
		DValue parent = getValue(parentId, isolateId);
		addVariableMember(parent, child, isolateId);
	}

	void addVariableMember(DValue parent, DVariable child, int isolateId) {
		if (getIsolateState(isolateId).m_attachChildren) {
			// There are certain situations when the Flash player will send us
			// more
			// than one variable or getter with the same name. Basically, when a
			// subclass implements (or overrides) something that was also
			// declared in a
			// superclass, then we'll see that variable or getter in both the
			// superclass and the subclass.
			//
			// Here are a few situations where that affects the debugger in
			// different
			// ways:
			//
			// 1. When a class implements an interface, the class instance
			// actually has
			// *two* members for each implemented function: One which is public
			// and
			// represents the implementation function, and another which is
			// internal
			// to the interface, and represents the declaration of the function.
			// Both of these come in to us. In the UI, the one we want to show
			// is
			// the public one. They come in in random order (they are stored in
			// a
			// hash table in the VM), so we don't know which one will come
			// first.
			//
			// 2. When a superclass has a private member "m", and a subclass has
			// its own
			// private member with the same name "m", we will receive both of
			// them.
			// (They are scoped by different packages.) In this case, the first
			// one
			// the player sent us is the one from the subclass, and that is the
			// one
			// we want to display in the debugger.
			//
			// The following logic correctly deals with all variations of those
			// cases.
			if (parent != null) {
				DVariable existingChildWithSameName = parent.findMember(child
						.getName());
				if (existingChildWithSameName != null) {
					int existingScope = existingChildWithSameName.getScope();
					int newScope = child.getScope();

					if (existingScope == VariableAttribute.NAMESPACE_SCOPE
							&& newScope == VariableAttribute.PUBLIC_SCOPE) {
						// This is the case described above where a class
						// implements an interface,
						// so that class's definition includes both a
						// namespace-scoped declaration
						// and a public declaration, in random order; in this
						// case, the
						// namespace-scoped declaration came first. We want to
						// use the public
						// declaration.
						parent.addMember(child);
					} else if (existingScope == VariableAttribute.PUBLIC_SCOPE
							&& newScope == VariableAttribute.NAMESPACE_SCOPE) {
						// One of two things happened here:
						//
						// 1. This is the case described above where a class
						// implements an interface,
						// so that class's definition includes both a
						// namespace-scoped declaration
						// and a public declaration, in random order; in this
						// case, the
						// public declaration came first. It is tempting to use
						// the public
						// member in this case, but there is a catch...
						// 2. It might be more complicated than that: Perhaps
						// there is interface I,
						// and class C1 implements I, but class C2 extends C1,
						// and overrides
						// one of the members of I that was already implemented
						// by C1. In this
						// case, the public declaration from C2 came first, but
						// now we are seeing
						// a namespace-scoped declaration in C1. We need to
						// record that the
						// member is public, but we also need to record that it
						// is a member
						// of the base class, not just a member of the
						// superclass.
						//
						// The easiest way to deal with both cases is to use the
						// child that came from
						// the superclass, but to change its scope to public.
						child.makePublic();
						parent.addMember(child);
					} else if (existingScope != VariableAttribute.PRIVATE_SCOPE
							&& existingScope == newScope) {
						// This is a public, protected, internal, or
						// namespace-scoped member which
						// was defined in a base class and overridden in a
						// subclass. We want to
						// use the member from the base class, to that the
						// debugger knows where the
						// variable was actually defined.
						parent.addMember(child);
					} else if (existingScope == VariableAttribute.PRIVATE_SCOPE
							&& existingScope == newScope) {
						parent.addInheritedPrivateMember(child);
					}
				} else {
					parent.addMember(child);
				}
			}
			// put child in the registry if it has an id and not already there
			DValue childValue = (DValue) child.getValue();
			long childId = childValue.getId();
			if (childId != Value.UNKNOWN_ID) {
				DValue existingValue = getValue(childId, isolateId);
				if (existingValue != null) {
					assert existingValue == childValue; // TODO is this right?
														// what about getters?
				} else {
					putValue(childId, childValue, isolateId);
				}
			}
		}
	}

	// TODO is this right?
	void addVariableMember(long parentId, DVariable child, long doubleAsId,
			int isolateId) {
		addVariableMember(parentId, child, isolateId);

		// double book the child under another id
		if (getIsolateState(isolateId).m_attachChildren)
			putValue(doubleAsId, (DValue) child.getValue(), isolateId);
	}

	// @deprecated last pool that was read
	public String[] getConstantPool() {
		return m_lastConstantPool;
	}

	/**
	 * Breakpoints
	 */
	public DLocation getBreakpoint(int id, int isolateId) {
		ArrayList<DLocation> breakpoints = getIsolateState(isolateId).m_breakpoints;
		synchronized (breakpoints) {
			DLocation loc = null;
			int which = findBreakpoint(id, isolateId);
			if (which > -1)
				loc = breakpoints.get(which);
			return loc;
		}
	}

	int findBreakpoint(int id, int isolateId) {
		ArrayList<DLocation> breakpoints = getIsolateState(isolateId).m_breakpoints;
		synchronized (breakpoints) {
			int which = -1;
			int size = breakpoints.size();
			for (int i = 0; which < 0 && i < size; i++) {
				DLocation l = breakpoints.get(i);
				if (l.getId() == id)
					which = i;
			}
			return which;
		}
	}

	DLocation removeBreakpoint(int id, int isolateId) {
		ArrayList<DLocation> breakpoints = getIsolateState(isolateId).m_breakpoints;
		synchronized (breakpoints) {
			DLocation loc = null;
			int which = findBreakpoint(id, isolateId);
			if (which > -1) {
				loc = breakpoints.get(which);
				breakpoints.remove(which);
			}

			return loc;
		}
	}

	void addBreakpoint(int id, DLocation l, int isolateId) {
		ArrayList<DLocation> breakpoints = getIsolateState(isolateId).m_breakpoints;
		synchronized (breakpoints) {
			breakpoints.add(l);
		}
	}

	public DLocation[] getBreakpoints(int isolateId) {
		ArrayList<DLocation> breakpoints = getIsolateState(isolateId).m_breakpoints;
		synchronized (breakpoints) {
			return breakpoints.toArray(new DLocation[breakpoints.size()]);
		}
	}

	/**
	 * Watchpoints
	 */
	public DWatch getWatchpoint(int at, int isolateId) {
		DManagerIsolateState state = getIsolateState(isolateId);
		synchronized (state.m_watchpoints) {
			return state.m_watchpoints.get(at);
		}
	}

	public int getWatchpointCount(int isolateId) {
		DManagerIsolateState state = getIsolateState(isolateId);
		synchronized (state.m_watchpoints) {
			return state.m_watchpoints.size();
		}
	}

	public DWatch[] getWatchpoints(int isolateId) {
		DManagerIsolateState state = getIsolateState(isolateId);
		synchronized (state.m_watchpoints) {
			return state.m_watchpoints.toArray(new DWatch[state.m_watchpoints.size()]);
		}
	}

	boolean addWatchpoint(DWatch w, int isolateId) {
		ArrayList<DWatch> lockObject = getIsolateState(isolateId).m_watchpoints;
		synchronized (lockObject) {
			return lockObject.add(w);
		}
	}

	DWatch removeWatchpoint(int tag, int isolateId) {
		ArrayList<DWatch> lockObject = getIsolateState(isolateId).m_watchpoints;
		synchronized (lockObject) {
			DWatch w = null;
			int at = findWatchpoint(tag, isolateId);
			if (at > -1)
				w = lockObject.remove(at);
			return w;
		}
	}

	int findWatchpoint(int tag, int isolateId) {
		ArrayList<DWatch> lockObject = getIsolateState(isolateId).m_watchpoints;
		synchronized (lockObject) {
			int at = -1;
			int size = getWatchpointCount(isolateId);
			for (int i = 0; i < size && at < 0; i++) {
				DWatch w = getWatchpoint(i, isolateId);
				if (w.getTag() == tag)
					at = i;
			}
			return at;
		}
	}

	/**
	 * Isolates
	 */
	public DIsolate getIsolate(int at) {

		if (at == Isolate.DEFAULT_ID)
			return (DIsolate) DEFAULT_ISOLATE;

		synchronized (m_isolates) {
			return m_isolates.get(at);
		}
	}

	public DIsolate getOrCreateIsolate(int at) {
		synchronized (m_isolates) {
			if (m_isolates.containsKey(at)) {
				return m_isolates.get(at);
			} else {
				DIsolate isolate = new DIsolate(at);
				m_isolates.put(at, isolate);
				return isolate;
			}
		}
	}

	public int getIsolateCount() {
		synchronized (m_isolates) {
			return m_isolates.size();
		}
	}

	public DIsolate[] getIsolates() {
		synchronized (m_isolates) {
			return m_isolates.values().toArray(new DIsolate[m_isolates.size()]);
		}
	}

	boolean addIsolate(DIsolate t) {
		synchronized (m_isolates) {
			m_isolates.put(t.getId(), t);
			return true;
		}
	}

	void clearIsolates() {
		synchronized (m_isolates) {
			m_isolates.clear();
		}
	}

	DIsolate removeIsolate(int id) {
		synchronized (m_isolates) {
			DIsolate t = null;
			int at = findIsolate(id);
			if (at > -1)
				t = m_isolates.remove(at);
			return t;
		}
	}

	int findIsolate(int id) {
		synchronized (m_isolates) {
			if (m_isolates.containsKey(id))
				return id;
			else
				return -1;
		}
	}

	void setActiveIsolate(Isolate t) {
		synchronized (m_activeIsolateLock) {
			if (t == null) {
				m_activeIsolate = DEFAULT_ISOLATE;
			} else
				m_activeIsolate = t;
		}
	}
	
	Isolate getActiveIsolate() {
		synchronized (m_activeIsolateLock) {
			return m_activeIsolate;
		}
	}


	void setInIsolate(Isolate t) {
		synchronized (m_inIsolateLock) {
			if (t == null) {
				m_inIsolate = DEFAULT_ISOLATE;
			} else
				m_inIsolate = t;
		}
	}

	Isolate getInIsolate() {
		synchronized (m_inIsolateLock) {
			return m_inIsolate;
		}
	}

	Isolate getDefaultIsolate() {
		return DEFAULT_ISOLATE;
	}


	/**
	 * Frame stack management related stuff
	 * 
	 * @return true if we added this frame; false if we ignored it
	 */
	boolean addFrame(DStackContext ds, int isolateId) {
		getIsolateState(isolateId).m_frames.add(ds);
		return true;
	}

	void clearFrames(int isolateId) {
		if (getIsolateState(isolateId).m_frames.size() > 0)
			getIsolateState(isolateId).m_previousFrames = getIsolateState(isolateId).m_frames;
		getIsolateState(isolateId).m_frames = new ArrayList<DStackContext>();
	}

	public DStackContext getFrame(int at, int isolateId) {
		return getIsolateState(isolateId).m_frames.get(at);
	}

	public int getFrameCount(int isolateId) {
		return getIsolateState(isolateId).m_frames.size();
	}

	public DStackContext[] getFrames(int isolateId) {
		ArrayList<DStackContext> frames = getIsolateState(isolateId).m_frames;
		return frames.toArray(new DStackContext[frames.size()]);
	}

	private boolean stringsEqual(String s1, String s2) {
		if (s1 == null)
			return s2 == null;
		else
			return s1.equals(s2);
	}

	/**
	 * Correlates the old list of stack frames, from the last time the player
	 * was suspended, with the new list of stack frames, attempting to guess
	 * which frames correspond to each other. This is done so that
	 * Variable.hasValueChanged() can work correctly for local variables.
	 */
	private void mapOldFramesToNew(int isolateId) {
		ArrayList<DStackContext> previousFrames = null;
		ArrayList<DStackContext> frames = null;
		Map<Long, DValue> previousValues = null;

		previousFrames = getIsolateState(isolateId).m_previousFrames;
		frames = getIsolateState(isolateId).m_frames;
		previousValues = getIsolateState(isolateId).m_previousValues;

		int oldSize = previousFrames.size();
		int newSize = frames.size();

		// discard all old frames (we will restore some of them below)
		DValue[] oldFrames = new DValue[oldSize];
		for (int depth = 0; depth < oldSize; depth++) {
			oldFrames[depth] = (DValue) previousValues.remove(Value.BASE_ID
					- depth);
		}

		// Start at the end of the stack (the stack frame farthest from the
		// current one), and try to match up stack frames
		int oldDepth = oldSize - 1;
		int newDepth = newSize - 1;
		while (oldDepth >= 0 && newDepth >= 0) {
			DStackContext oldFrame = previousFrames.get(oldDepth);
			DStackContext newFrame = frames.get(newDepth);
			if (oldFrame != null && newFrame != null) {
				if (stringsEqual(oldFrame.getCallSignature(),
						newFrame.getCallSignature())) {
					DValue frame = oldFrames[oldDepth];
					if (frame != null)
						previousValues.put(Value.BASE_ID - newDepth, frame);
				}
			}
			oldDepth--;
			newDepth--;
		}
	}

	/**
	 * Get function is only supported in players that recognize the squelch
	 * message.
	 */
	public boolean isGetSupported() {
		return m_squelchEnabled;
	}


	/**
	 * Returns a suspend information on why the Player has suspended execution.
	 * 
	 * @return see SuspendReason
	 */
	public DSuspendInfo getSuspendInfo(int isolateId) {
		if (m_isolateState.containsKey(isolateId)) {
			return m_isolateState.get(isolateId).m_suspendInfo;
		}
		return null;
	}

	public ArrayList<SwfInfo> getIsolateSwfList() {
		ArrayList<SwfInfo> result = new ArrayList<SwfInfo>();

		for (DManagerIsolateState state : m_isolateState.values()) {
			if (state.m_swfInfo != null) {
				result.addAll(state.m_swfInfo);
			}
		}

		return result;
	}

	/**
	 * Event management related stuff
	 */
	public int getEventCount() {
		synchronized (m_event) {
			return m_event.size();
		}
	}

	/**
	 * Get an object on which callers can call wait(), in order to wait until
	 * something happens.
	 * 
	 * Note: The object will be signalled when EITHER of the following happens:
	 * (1) An event is added to the event queue; (2) The network connection is
	 * broken (and thus there will be no more events).
	 * 
	 * @return an object on which the caller can call wait()
	 */
	public Object getEventNotifier() {
		return m_event;
	}

	public DebugEvent nextEvent() {
		DebugEvent s = null;
		synchronized (m_event) {
			if (m_event.size() > 0)
				s = m_event.removeFirst();
		}
		return s;
	}

	public synchronized void addEvent(DebugEvent e) {
		synchronized (m_event) {
			m_event.add(e);
			m_event.notifyAll(); // wake up listeners (see getEventNotifier())
		}
	}

	/**
	 * Issued when the socket connection to the player is cut
	 */
	public void disconnected() {
		synchronized (m_event) {
			m_event.notifyAll(); // see getEventNotifier()
		}
	}

	/**
	 * This is the core routine for decoding incoming messages and deciding what
	 * should be done with them. We have registered ourself with DProtocol to be
	 * notified when any incoming messages have been received.
	 * 
	 * It is important to note that we should not rely on the contents of the
	 * message since it may be reused after we exit this method.
	 */
	public void messageArrived(DMessage msg, DProtocol which) {
		/*
		 * at this point we just open up a big switch statement and walk through
		 * all possible cases
		 */
		int type = msg.getType();
		// System.out.println("manager msg = "+DMessage.inTypeName(type));
		int inIsolateId = getInIsolate() != null ? getInIsolate().getId()
				: Isolate.DEFAULT_ID;
		if (inIsolateId != Isolate.DEFAULT_ID) {
			msg.setTargetIsolate(inIsolateId);
		}
		switch (type) {
		case DMessage.InVersion: {
			long ver = msg.getDWord();
			m_playerVersion = (int) ver;

			// Newer players will send another byte, which is the pointer size
			// that is used by the player (in bytes).
			int pointerSize;
			if (msg.getRemaining() >= 1)
				pointerSize = msg.getByte();
			else
				pointerSize = 4;
			DMessage.setSizeofPtr(pointerSize);
			break;
		}

		case DMessage.InErrorExecLimit: {
			handleFaultEvent(new RecursionLimitFault(msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorWith: {
			handleFaultEvent(new InvalidWithFault(msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorProtoLimit: {
			handleFaultEvent(new ProtoLimitFault(msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorURLOpen: {
//			String url = msg.getString();
//			handleFaultEvent(new InvalidURLFault(url, msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorTarget: {
//			String name = msg.getString();
//			handleFaultEvent(new InvalidTargetFault(name, msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorException: {
			long offset = msg.getDWord();
			// As of FP9, the player will also send the "toString()" message
			// of the exception. But for backward compatibility with older
			// players, we won't assume that that is there.
			String exceptionMessage;
			boolean willExceptionBeCaught = false;
			Value thrown = null;
			if (msg.getRemaining() > 0) {
				exceptionMessage = msg.getString();
				if (msg.getRemaining() > 0) {
					if (msg.getByte() != 0) {
						willExceptionBeCaught = (msg.getByte() != 0 ? true
								: false);
						msg.getPtr();
						DVariable thrownVar = extractVariable(msg);
						thrown = thrownVar.getValue();
					}
				}
			} else {
				exceptionMessage = ""; //$NON-NLS-1$
			}
			ExceptionFault exceptionFault = new ExceptionFault(
					exceptionMessage, willExceptionBeCaught, thrown, msg.getTargetIsolate());
			exceptionFault.isolateId = msg.getTargetIsolate();
			handleFaultEvent(exceptionFault);
			break;
		}

		case DMessage.InErrorStackUnderflow: {
//			long offset = msg.getDWord();
			handleFaultEvent(new StackUnderFlowFault(msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorZeroDivide: {
//			long offset = msg.getDWord();
			handleFaultEvent(new DivideByZeroFault(msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorScriptStuck: {
			handleFaultEvent(new ScriptTimeoutFault(msg.getTargetIsolate()));
			break;
		}

		case DMessage.InErrorConsole: {
			String s = msg.getString();
			handleFaultEvent(new ConsoleErrorFault(s, msg.getTargetIsolate()));
			break;
		}

		case DMessage.InTrace: {
			String text = msg.getString();
			addEvent(new TraceEvent(text));
			break;
		}

		case DMessage.InSquelch: {
			long state = msg.getDWord();
			m_squelchEnabled = (state != 0) ? true : false;
			break;
		}

		case DMessage.InParam: {
			String name = msg.getString();
			String value = msg.getString();

			// here's where we get movie = URL and password which I'm not sure
			// what to do with?
			// System.out.println(name+"="+value);
			m_parms.put(name, value);

			// if string is a "movie", then this is a URL
			if (name.startsWith("movie")) //$NON-NLS-1$
				m_uri = convertToURI(value);
			break;
		}

		case DMessage.InPlaceObject: {
			long objId = msg.getPtr();
			String path = msg.getString();
			// m_bag.placeObject((int)objId, path);
			break;
		}

		case DMessage.InSetProperty: {
			long objId = msg.getPtr();
			int item = msg.getWord();
			String value = msg.getString();
			break;
		}

		case DMessage.InNewObject: {
			long objId = msg.getPtr();
			break;
		}

		case DMessage.InRemoveObject: {
			long objId = msg.getPtr();
			// m_bag.removeObject((int)objId);
			break;
		}

		case DMessage.InSetVariable: {
			long objId = msg.getPtr();
			String name = msg.getString();
			int dType = msg.getWord();
			int flags = (int) msg.getDWord();
			String value = msg.getString();

			// m_bag.createVariable((int)objId, name, dType, flags, value);
			break;
		}

		case DMessage.InDeleteVariable: {
			long objId = msg.getPtr();
			String name = msg.getString();
			// m_bag.deleteVariable((int)objId, name);
			break;
		}

		case DMessage.InScript: {
			int module = (int) msg.getDWord();
			int bitmap = (int) msg.getDWord();
			String name = msg.getString(); // in "basepath;package;filename"
											// format
			String text = msg.getString();
			int swfIndex = -1;
			int isolateIndex = -1;

			/* new in flash player 9: player tells us what swf this is for */
			if (msg.getRemaining() >= 4)
				swfIndex = (int) msg.getDWord();

			isolateIndex = msg.getTargetIsolate();
			getOrCreateIsolate(isolateIndex);
			if (putSource(swfIndex, module, bitmap, name, text,
					isolateIndex)) {
				// have we changed the list since last query
				if (!m_sourceListModified)
					addEvent(new FileListModifiedEvent());

				m_sourceListModified = true; 
			}
			break;
		}

		case DMessage.InRemoveScript: {
			long module = msg.getDWord();
			int isolateId = msg.getTargetIsolate();
			Map<Integer, DModule> source = getIsolateState(isolateId).m_source;
			synchronized (source) {
				if (removeSource((int) module, isolateId)) {
					// have we changed the list since last query
					if (!m_sourceListModified)
						addEvent(new FileListModifiedEvent());

					m_sourceListModified = true; /* current source list is stale */
				}
			}
			break;
		}

		case DMessage.InAskBreakpoints: {
			// the player has just loaded a swf and we know the player
			// has halted, waiting for us to continue. The only caveat
			// is that it looks like it still does a number of things in
			// the background which take a few seconds to complete.
			int targetIsolate = msg.getTargetIsolate();
			DSuspendInfo iSusInfo = getIsolateState(targetIsolate).m_suspendInfo;
			if (iSusInfo == null) {
				iSusInfo = new DSuspendInfo(SuspendReason.ScriptLoaded, 0,
						0, 0, 0);
			}
			break;
		}

		case DMessage.InBreakAt: {
			long bp = 0, wideLine = 0, wideModule = 0;
			if (!m_wideLines) {
				bp = msg.getDWord();
			}
			else {
				wideModule = msg.getDWord();
				wideLine = msg.getDWord();
			}
			long id = msg.getPtr();
			String stack = msg.getString();
			int targetIsolate = msg.getTargetIsolate();

			int module = DLocation.decodeFile(bp);
			int line = DLocation.decodeLine(bp);
			if (m_wideLines) {
				module = (int)wideModule;
				line = (int)wideLine;
			}
			addEvent(new BreakEvent(module, line, targetIsolate));
			break;
		}

		case DMessage.InContinue: {
			/* we are running again so trash all our variable contents */
			continuing(msg.getTargetIsolate());
			break;
		}

		case DMessage.InSetLocalVariables: {
//			long objId = msg.getPtr();
			// m_bag.markObjectLocal((int)objId, true);
			break;
		}

		case DMessage.InSetBreakpoint: {
			long count = msg.getDWord();
			int targetIsolate = msg.getTargetIsolate();
			while (count-- > 0) {
				long bp = 0, moduleNumber = 0, lineNumber = 0;
				if (!m_wideLines) {
					bp = msg.getDWord();
				}
				else {
					moduleNumber = msg.getDWord();
					lineNumber = msg.getDWord();
				}

				int fileId = DLocation.decodeFile(bp);
				int line = DLocation.decodeLine(bp);
				if (m_wideLines) {
					fileId = (int)moduleNumber;
					line = (int)lineNumber;
				}

				DModule file = null;
				file = getSource(fileId, targetIsolate);

				DLocation l = new DLocation(file, line, targetIsolate);

				if (file != null) {
					addBreakpoint((int) bp, l, targetIsolate);
				}
			}
			break;
		}

		case DMessage.InNumScript: {
			/* lets us know how many scripts there are */
			int num = (int) msg.getDWord();
			int targetIsolate = msg.getTargetIsolate();
			DSwfInfo swf;

			/*
			 * New as of flash player 9: another dword indicating which swf this
			 * is for. That means we don't have to guess whether this is for an
			 * old SWF which has just had some more modules loaded, or for a new
			 * SWF!
			 */
			if (msg.getRemaining() >= 4) {
				int swfIndex = (int) msg.getDWord();
				swf = getOrCreateSwfInfo(swfIndex, targetIsolate);
				getIsolateState(targetIsolate).m_lastSwfInfo = swf;
			} else {
				/*
				 * This is not flash player 9 (or it is an early build of fp9).
				 * 
				 * We use this message as a trigger that a new swf has been
				 * loaded, so make sure we are ready to accept the scripts.
				 */
				swf = getActiveSwfInfo(targetIsolate);
			}

			// It is NOT an error for the player to have sent us a new,
			// different sourceExpectedCount from whatever we had before!
			// In fact, this happens all the time, whenever a SWF has more
			// than one ABC.
			swf.setSourceExpectedCount(num);
			break;
		}

		case DMessage.InRemoveBreakpoint: {
			long count = msg.getDWord();
			int isolateId = msg.getTargetIsolate();
			while (count-- > 0) {
				long bp = msg.getDWord();
				removeBreakpoint((int) bp, isolateId);
			}
			break;

		}

		case DMessage.InBreakAtExt: {
			long bp = 0, wideLine = 0, wideModule = 0;
			if (!m_wideLines) {
				bp = msg.getDWord();
			}
			else {
				wideModule = msg.getDWord();
				wideLine = msg.getDWord();
			}
			long num = msg.getDWord();

			int targetIsolate = msg.getTargetIsolate();
			// System.out.println(msg.getInTypeName()+",bp="+(bp&0xffff)+":"+(bp>>16));
			/* we have stack info to store away */
			clearFrames(targetIsolate); // just in case
			int depth = 0;

			while (num-- > 0) {
				long bpi = 0, wideLinei= 0, wideModulei = 0;
				if (!m_wideLines) {
					bpi = msg.getDWord();
				}
				else {
					wideModulei = msg.getDWord();
					wideLinei = msg.getDWord();
				}
				long id = msg.getPtr();
				String stack = msg.getString();
				int module = DLocation.decodeFile(bpi);
				int line = DLocation.decodeLine(bpi);
				if (m_wideLines) {
					module = (int)wideModulei;
					line = (int)wideLinei;
				}
				DModule m = null;
				m = getSource(module, targetIsolate);
				DStackContext c = new DStackContext(module, line, m, id, stack,
						depth, targetIsolate);
				// If addFrame() returns false, that means it chose to ignore
				// this
				// frame, so we do NOT want to increment our depth for the next
				// time through the loop. If it returns true, then we do want
				// to.
				if (addFrame(c, targetIsolate))
					++depth;
				// System.out.println("   this="+id+",@"+(bpi&0xffff)+":"+(bpi>>16)+",stack="+stack);
			}
			mapOldFramesToNew(targetIsolate);
			if (targetIsolate != Isolate.DEFAULT_ID) {
				// ask for isolate id if it is present
				appendIsolateInfoToFrame(targetIsolate);

			}
			break;

		}

		case DMessage.InFrame: {
			// For InFrame the first element is really our frame id
			DValue frame = null;
			DVariable child = null;
			ArrayList<DVariable> v = new ArrayList<DVariable>();
			ArrayList<DVariable> registers = new ArrayList<DVariable>();
			int targetIsolate = msg.getTargetIsolate();
			int depth = (int) msg.getDWord(); // depth of frame

			// make sure we have a valid depth
			if (depth > -1) {
				// first thing is number of registers
				int num = (int) msg.getDWord();
				for (int i = 0; i < num; i++)
					registers.add(extractRegister(msg, i + 1));
			}

			int currentArg = -1;
			boolean gettingScopeChain = false;

			// then our frame itself
			while (msg.getRemaining() > 0) {
				long frameId = msg.getPtr();

				if (frame == null) {
					frame = getOrCreateValue(frameId, targetIsolate);
					extractVariable(msg); // put the rest of the info in the
											// trash
				} else {
					child = extractVariable(msg);
					if (currentArg == -1
							&& child.getName().equals(ARGUMENTS_MARKER)) {
						currentArg = 0;
						gettingScopeChain = false;
					} else if (child.getName().equals(SCOPE_CHAIN_MARKER)) {
						currentArg = -1;
						gettingScopeChain = true;
					} else if (currentArg >= 0) {
						// work around a compiler bug: If the variable's name is
						// "undefined",
						// then change its name to "_argN", where "N" is the
						// argument index,
						// e.g. _arg1, _arg2, etc.
						++currentArg;
						if (child.getName().equals("undefined")) //$NON-NLS-1$
							child.setName("_arg" + currentArg); //$NON-NLS-1$
					}

					// All args and locals get added as "children" of
					// the frame; but scope chain entries do not.
					if (!gettingScopeChain)
						addVariableMember(frameId, child, targetIsolate);

					// Everything gets added to the ordered list of
					// variables that came in.
					v.add(child);
				}
			}

			// let's transfer our newly gained knowledge into the stack context
			if (depth == 0)
				populateRootNode(frame, v, targetIsolate);
			else
				populateFrame(depth, v, targetIsolate);

			break;
		}

		case DMessage.InOption: {
			String s = msg.getString();
			String v = msg.getString();
			m_options.put(s, v);
			break;
		}

		case DMessage.InGetVariable: {
			// For InGetVariable the first element is the original entity we
			// requested
			DValue parent = null;
			DVariable child = null;
			String definingClass = null;
			int level = 0;
			int targetIsolate = msg.getTargetIsolate();
			int highestLevelWithMembers = -1;
			List<String> classes = new ArrayList<String>();

			while (msg.getRemaining() > 0) {
				long parentId = msg.getPtr();

				// build or get parent node
				if (parent == null) {
					String name = msg.getString();

					// pull the contents of the node which normally are disposed
					// of except if we did a 0,name call
					getIsolateState(targetIsolate).m_lastInGetVariable = extractVariable(msg, name); 

					parent = getOrCreateValue(parentId, targetIsolate);
				} else {
					// extract the child and add it to the parent.
					child = extractVariable(msg);
					if (showMember(child)) {
						if (child.isAttributeSet(VariableAttribute.IS_DYNAMIC)) {
							// Dynamic attributes always come in marked as a
							// member of
							// class "Object"; but to the user, it makes more
							// sense to
							// consider them as members of the topmost class.
							if (classes.size() > 0) {
								child.setDefiningClass(0, classes.get(0));
								highestLevelWithMembers = Math.max(
										highestLevelWithMembers, 0);
							}
						} else {
							child.setDefiningClass(level, definingClass);
							if (definingClass != null) {
								highestLevelWithMembers = Math.max(
										highestLevelWithMembers, level);
							}
						}
						addVariableMember(parent.getId(), child, targetIsolate);
					} else {
						if (isTraits(child)) {
							definingClass = child.getQualifiedName();
							level = classes.size();

							// If the traits name end with "$", then it
							// represents a class object --
							// in other words, the variables inside it are
							// static variables of that
							// class. In that case, we need to juggle the
							// information. For example,
							// if we are told that a variable is a member of
							// "MyClass$", we actually
							// store it into the information for "MyClass".
							if (definingClass.endsWith("$")) { //$NON-NLS-1$
								String classWithoutDollar = definingClass
										.substring(0,
												definingClass.length() - 1);
								int indexOfClass = classes
										.indexOf(classWithoutDollar);
								if (indexOfClass != -1) {
									level = indexOfClass;
									definingClass = classWithoutDollar;
								}
							}

							// It wasn't static -- so, add this class to the end
							// of the list of classes
							if (level == classes.size()) {
								classes.add(definingClass);
							}
						}
					}
				}
			}

			if (parent != null && parent.getClassHierarchy(true) == null) {
				parent.setClassHierarchy(
						classes.toArray(new String[classes.size()]),
						highestLevelWithMembers + 1);
			}

			break;
		}

		case DMessage.InWatch: // for AS2; sends 16-bit ID field
		case DMessage.InWatch2: // for AS3; sends 32-bit ID field
		{
			// This message is sent whenever a watchpoint is added
			// modified or removed.
			//
			// For an addition, flags will be non-zero and
			// success will be true.
			//
			// For a modification flags will be non-zero.
			// and oldFlags will be non-zero and success
			// will be true. Additionally oldFlags will not
			// be equal to flags.
			//
			// For a removal flags will be zero. oldFlags
			// will be non-zero.
			//
			// flags identifies the type of watchpoint added,
			// see WatchKind.
			//
			// success indicates whether the operation was successful
			//
			// request. It will be associated with the watchpoint.
			int success = msg.getWord();
			int oldFlags = msg.getWord();
			int oldTag = msg.getWord();
			int flags = msg.getWord();
			int tag = msg.getWord();
			// for AS2, the ID came in above as a Word. For AS3, the above value
			// is
			// bogus, and it has been sent again as a DWord.
			long id = ((type == DMessage.InWatch2) ? msg.getPtr() : msg
					.getWord());
			String name = msg.getString();
			int targetIsolate = msg.getTargetIsolate();

			if (success != 0) {
				if (flags == 0) {
					removeWatchpoint(oldTag, targetIsolate);
				} else {
					// modification or addition is the same to us
					// a new watch is created and added into the table
					// while any old entry if it exists is removed.
					removeWatchpoint(oldTag, targetIsolate);
					DWatch w = new DWatch(id, name, flags, tag, targetIsolate);
					addWatchpoint(w, targetIsolate);
				}
			}
			break;
		}

		case DMessage.InGetSwf: {
			// we only house the swf temporarily, PlayerSession then
			// pieces it back into swfinfo record. Also, we don't
			// send any extra data in the message so that we need not
			// copy the bytes.
			m_swf = msg.getData();
			break;
		}

		case DMessage.InGetSwd: {
			// we only house the swd temporarily, PlayerSession then
			// pieces it back into swfinfo record.
			m_swd = msg.getData();
			break;
		}

		case DMessage.InBreakReason: {
			// the id map 1-1 with out SuspendReason interface constants
			int suspendReason = msg.getWord();
			int suspendPlayer = msg.getWord(); // item index of player
			int breakOffset = (int) msg.getDWord(); // current script offset
			int prevBreakOffset = (int) msg.getDWord(); // prev script offset
			int nextBreakOffset = (int) msg.getDWord(); // next script offset
			int targetIsolate = msg.getTargetIsolate();

			getIsolateState(targetIsolate).m_suspendInfo = new DSuspendInfo(
					suspendReason, suspendPlayer, breakOffset,
					prevBreakOffset, nextBreakOffset);

			// augment the current frame with this information. It
			// should work ok since we only get this message after a
			// InBreakAtExt message
			try {
				DStackContext c = getFrame(0, targetIsolate);
				c.setOffset(breakOffset);
				c.setSwfIndex(suspendPlayer);
			} catch (Exception e) {
				if (Trace.error) {
					Trace.trace("Oh my god, gag me with a spoon...getFrame(0) call failed"); //$NON-NLS-1$
					e.printStackTrace();
				}
			}
			break;
		}

			// obtain raw action script byte codes
		case DMessage.InGetActions: {
			int item = msg.getWord();
			int rsvd = msg.getWord();
			int at = (int) msg.getDWord();
			int len = (int) msg.getDWord();
			int i = 0;

			m_actions = (len <= 0) ? null : new byte[len];
			while (len-- > 0)
				m_actions[i++] = (byte) msg.getByte();

			break;
		}

			// obtain data about a SWF
		case DMessage.InSwfInfo: {
			int count = msg.getWord();
			int targetIsolate = msg.getTargetIsolate();
			for (int i = 0; i < count; i++) {
				long index = msg.getDWord();
				long id = msg.getPtr();

				// get it
				DSwfInfo info = null;

				info = getOrCreateSwfInfo((int) index, targetIsolate);
				getIsolateState(targetIsolate).m_lastSwfInfo = info;

				// remember which was last seen

				if (id != 0) {
					boolean debugComing = (msg.getByte() == 0) ? false : true;
					byte vmVersion = (byte) msg.getByte(); // AS vm version
															// number (1 = avm+,
															// 0 == avm-)
					int rsvd1 = msg.getWord();

					long swfSize = msg.getDWord();
					long swdSize = msg.getDWord();
					long scriptCount = msg.getDWord();
					long offsetCount = msg.getDWord();
					long breakpointCount = msg.getDWord();

					long port = msg.getDWord();
					String path = msg.getString();
					String url = msg.getString();
					String host = msg.getString();
					Map<Long, Integer> local2global = new HashMap<Long, Integer>();
					int minId = Integer.MAX_VALUE;
					int maxId = Integer.MIN_VALUE;
					// now we read in the swd debugging map (which provides
					// local to global mappings of the script ids
					/* anirudhs: Parsing this is only necessary if we are in
					   AVM1. (See PlayerSession::run(), there is a vmVersion 
					   check before calling parseSwfSwd(). */ 
					if (swdSize > 0) {
						long num = msg.getDWord();
						for (int j = 0; j < num; j++) {
							if (msg.getRemaining() < DMessage.getSizeofPtr()) {
								/* The SWD debugging map sent out by 
								 * AVM2 often runs short usually in 64-bit
								 * debug player. We can stop with what we know
								 * and move on.
								 */
								break;
							}
							long local = msg.getPtr();
							int global = (int) msg.getDWord();
							local2global.put(local, global);
							minId = (global < minId) ? global : minId;
							maxId = (global > maxId) ? global : maxId;
						}
					}
					// If its a new record then the swf size would have been
					// unknown at creation time
					boolean justCreated = (info.getSwfSize() == 0);

					// if we are a avm+ engine then we don't wait for the swd to
					// load
					if (vmVersion > 0) {
						debugComing = false;
						info.setVmVersion(vmVersion);
						info.setPopulated(); // added by mmorearty on 9/5/05 for
												// RSL debugging
					}

					// update this swfinfo with the lastest data
					info.freshen(id, path, url, host, port, debugComing,
							swfSize, swdSize, breakpointCount, offsetCount,
							scriptCount, local2global, minId, maxId);
					// now tie any scripts that have been loaded into this
					// swfinfo object
					tieScriptsToSwf(info, targetIsolate);

					// notify if its newly created
					if (justCreated)
						addEvent(new SwfLoadedEvent(id, (int) index, path, url,
								host, port, swfSize));
				} else {
					// note our state before marking it
					boolean alreadyUnloaded = info.isUnloaded();

					// clear it out
					info.setUnloaded();

					// notify if this information is new.
					if (!alreadyUnloaded)
						addEvent(new SwfUnloadedEvent(info.getId(),
								info.getPath(), (int) index));
				}
				// System.out.println("[SWFLOAD] Loaded "+path+", size="+swfSize+", scripts="+scriptCount);
			}
			break;
		}

			// obtain the constant pool of some player
		case DMessage.InConstantPool: {
			int item = msg.getWord();
			int count = (int) msg.getDWord();

			String[] pool = new String[count];
			for (int i = 0; i < count; i++) {
				long id = msg.getPtr();
				DVariable var = extractVariable(msg);

				// we only need the contents of the variable
				pool[i] = var.getValue().getValueAsString();
			}
			m_lastConstantPool = pool;
			break;
		}

			// obtain one or more function name line number mappings.
		case DMessage.InGetFncNames: {
			long id = msg.getDWord(); // module id
			long count = msg.getDWord(); // number of entries

			// get the DModule
			DModule m = getSource((int) id, msg.getTargetIsolate());
			if (m != null) {
				for (int i = 0; i < count; i++) {
					int offset = (int) msg.getDWord();
					int firstLine = (int) msg.getDWord();
					int lastLine = (int) msg.getDWord();
					String name = msg.getString();

					// now add the entries
					m.addLineFunctionInfo(offset, firstLine, lastLine, name);
				}
			}
			break;
		}

		case DMessage.InCallFunction:
		case DMessage.InBinaryOp: {
			// For InCallFunction the first element is the original function we
			// requested
			DValue parent = null;
			int targetIsolate = msg.getTargetIsolate();
			DVariable child = null;
			String definingClass = null;
			int level = 0;
			int highestLevelWithMembers = -1;
			List<String> classes = new ArrayList<String>();

			if (type == DMessage.InBinaryOp)
				msg.getDWord(); // id

			while (msg.getRemaining() > 0) {
				long parentId = msg.getPtr();

				// build or get parent node
				if (parent == null) {
					String name = msg.getString();

					// pull the contents of the node which normally are disposed
					// of except if we did a 0,name call
					DVariable var = extractVariable(msg, name);
					if (type == DMessage.InCallFunction) {
						getIsolateState(targetIsolate).m_lastInCallFunction = var;
					}
					else {
						getIsolateState(targetIsolate).m_lastInBinaryOp = var;
					}

					parent = getOrCreateValue(parentId, targetIsolate);
				} else {
					// extract the child and add it to the parent.
					child = extractVariable(msg);
					if (showMember(child)) {
						if (child.isAttributeSet(VariableAttribute.IS_DYNAMIC)) {
							// Dynamic attributes always come in marked as a
							// member of
							// class "Object"; but to the user, it makes more
							// sense to
							// consider them as members of the topmost class.
							if (classes.size() > 0) {
								child.setDefiningClass(0, classes.get(0));
								highestLevelWithMembers = Math.max(
										highestLevelWithMembers, 0);
							}
						} else {
							child.setDefiningClass(level, definingClass);
							if (definingClass != null) {
								highestLevelWithMembers = Math.max(
										highestLevelWithMembers, level);
							}
						}
						addVariableMember(parent.getId(), child, targetIsolate);
					} else {
						if (isTraits(child)) {
							definingClass = child.getQualifiedName();
							level = classes.size();

							// If the traits name end with "$", then it
							// represents a class object --
							// in other words, the variables inside it are
							// static variables of that
							// class. In that case, we need to juggle the
							// information. For example,
							// if we are told that a variable is a member of
							// "MyClass$", we actually
							// store it into the information for "MyClass".
							if (definingClass.endsWith("$")) { //$NON-NLS-1$
								String classWithoutDollar = definingClass
										.substring(0,
												definingClass.length() - 1);
								int indexOfClass = classes
										.indexOf(classWithoutDollar);
								if (indexOfClass != -1) {
									level = indexOfClass;
									definingClass = classWithoutDollar;
								}
							}

							// It wasn't static -- so, add this class to the end
							// of the list of classes
							if (level == classes.size()) {
								classes.add(definingClass);
							}
						}
					}
				}
			}

			if (parent != null && parent.getClassHierarchy(true) == null) {
				parent.setClassHierarchy(
						classes.toArray(new String[classes.size()]),
						highestLevelWithMembers + 1);
			}

			break;
		}

		case DMessage.InIsolateCreate: {
			long id = msg.getDWord();
			isolateCreate((int) id);

			break;
		}

		case DMessage.InIsolateExit: {
			long id = msg.getDWord();
			// Implementation dependency on runtime in case id mechanism is
			// changed:
			// Typecast id into an int.
			DIsolate isolate = removeIsolate((int) id);
			addEvent(new IsolateExitEvent(isolate));

			break;
		}

		case DMessage.InIsolateEnumerate: {
			// clearIsolates();
			//
			// long lenIsolate = msg.getDWord();
			//
			// for ( int i = 0; i < lenIsolate; i++) {
			// long id = msg.getDWord();
			// addIsolate(new DIsolate(id));
			// }

			break;
		}

		case DMessage.InSetActiveIsolate: {
			long id = msg.getDWord();

			boolean success = msg.getByte() != 0 ? true : false;

			/** Ignore inset since we don't wait
			 * for response anymore.
			 */
//			synchronized (m_activeIsolateLock) {
//				if (success) {
//					int at = findIsolate((int) id);
//					if (at > -1)
//						setActiveIsolate(getIsolate(at));
//				} else {
//					setActiveIsolate(null);
//				}
//			}

			break;
		}

		case DMessage.InIsolate: {
			long id = msg.getDWord();
			synchronized (m_inIsolateLock) {
				int at = findIsolate((int) id);
				if (at != -1)
					setInIsolate(getIsolate(at));
				else {
					if (id != Isolate.DEFAULT_ID) {
						setInIsolate(isolateCreate((int) id));
					} else
						setInIsolate(null);
				}
			}
			break;
		}
		
		case DMessage.InSetExceptionBreakpoint: {

			int result = msg.getWord();
			String exceptionBP = msg.getString();
			int remaining = msg.getRemaining();
			break;
		}

		case DMessage.InRemoveExceptionBreakpoint: {
			int result = msg.getWord();
			String exceptionBP = msg.getString();
			int remaining = msg.getRemaining();
			break;
		}

		default: {
			break;
		}
		}
	}

	private DIsolate isolateCreate(int id) {
		int idx = findIsolate(id);
		if (idx == -1) {
			DIsolate isolate = new DIsolate(id);
			addIsolate(isolate);
			setInIsolate(isolate);
			addEvent(new IsolateCreateEvent(isolate));
			return isolate;
		}
		return getIsolate(idx);

	}

	private void appendIsolateInfoToFrame(int isolateid) {
		// augment the current frame with this information. It
		// should work ok since we only get this message after a
		// InBreakAtExt message
		try {
			DStackContext c = getFrame(0, isolateid);
			c.setIsolateId(isolateid);
		} catch (Exception e) {
			if (Trace.error) {
				Trace.trace("Oh my god, gag me with a spoon...getFrame(0) call failed"); //$NON-NLS-1$
				e.printStackTrace();
			}
		}
	}

	/**
	 * Returns whether a given child member should be shown, or should be
	 * filtered out.
	 */
	private boolean showMember(DVariable child) {
		if (isTraits(child))
			return false;
		return true;
	}

	/**
	 * Returns whether this is not a variable at all, but is instead a
	 * representation of a "traits" object. A "traits" object is the Flash
	 * player's way of describing one class.
	 */
	private boolean isTraits(DVariable variable) {
		Value value = variable.getValue();
		if (value.getType() == VariableType.UNKNOWN
				&& Value.TRAITS_TYPE_NAME.equals(value.getTypeName())) {
			return true;
		}
		return false;
	}

	/**
	 * Here's where some ugly stuff happens. Since our context contains more
	 * info than what's contained within the stackcontext, we augment it with
	 * the variables. Also, we build up a list of variables that appears under
	 * root, that can be accessed without further qualification; this includes
	 * args, locals and _global.
	 */
	void populateRootNode(DValue frame, ArrayList<DVariable> orderedChildList,
			int isolateId) {
		// first populate the stack node with children
		populateFrame(0, orderedChildList, isolateId);

		/**
		 * We mark it as members obtained so that we don't go to the player and
		 * request it, which would be bad, since its our artifical creation.
		 */
		DValue base = getOrCreateValue(Value.BASE_ID, isolateId);
		base.setMembersObtained(true);

		/**
		 * Technically, we don't need to create the following nodes, but we like
		 * to give them nice type names
		 */

		// now let's create a _global node and attach it to base
	}

	/**
	 * We are done, so let's look for a number of special variables, since our
	 * frame comes in 3 pieces. First off is a "this" pointer, followed by a
	 * "$arguments" dummy node, followed by a "super" which marks the end of the
	 * arguments.
	 * 
	 * All of this stuff gets pulled apart after we build the frame node.
	 */
	void populateFrame(int depth, ArrayList<DVariable> frameVars, int isolateId) {
		// get our stack context
		DStackContext context = null;
		boolean inArgs = false;
		int nArgs = -1;
		boolean inScopeChain = false;

		// create a root node for each stack frame; first is at BASE_ID
		DValue root = getOrCreateValue(Value.BASE_ID - depth, isolateId);

		if (depth < getFrameCount(isolateId))
			context = getFrame(depth, isolateId);

		// trim all current args from this context
		if (context != null)
			context.removeAllVariables();

		// use the ordered child list
		Iterator<DVariable> e = frameVars.iterator();
		while (e.hasNext()) {
			DVariable v = e.next();
			String name = v.getName();

			// let's clear a couple of attributes that may get in our way
			v.clearAttribute(VariableAttribute.IS_LOCAL);
			v.clearAttribute(VariableAttribute.IS_ARGUMENT);
			if (name.equals("this")) //$NON-NLS-1$
			{
				if (context != null)
					context.setThis(v);

				// from our current frame, put a pseudo this entry into the
				// cache and hang it off base, mark it as an implied arg
				v.setAttribute(VariableAttribute.IS_ARGUMENT);
				addVariableMember(root, v, isolateId);

				// also add this variable under THIS_ID
				if (depth == 0)
					putValue(Value.THIS_ID, (DValue) v.getValue(), isolateId);
			} else if (name.equals("super")) //$NON-NLS-1$
			{
				// we are at the end of the arg list and let's make super part
				// of global
				inArgs = false;
			} else if (name.equals(ARGUMENTS_MARKER)) {
				inArgs = true;

				// see if we can extract an arg count from this variable
				try {
					nArgs = ((Number) (v.getValue().getValueAsObject()))
							.intValue();
				} catch (NumberFormatException nfe) {
				}
			} else if (name.equals(SCOPE_CHAIN_MARKER)) {
				inArgs = false;
				inScopeChain = true;
			} else {
				// add it to our root, marking it as an arg if we know,
				// otherwise local
				if (inArgs) {
					v.setAttribute(VariableAttribute.IS_ARGUMENT);

					if (context != null)
						context.addArgument(v);

					// decrement arg count if we have it
					if (nArgs > -1) {
						if (--nArgs <= 0)
							inArgs = false;
					}
				} else if (inScopeChain) {
					if (context != null)
						context.addScopeChainEntry(v);
				} else {
					v.setAttribute(VariableAttribute.IS_LOCAL);
					if (context != null)
						context.addLocal(v);
				}

				// add locals and arguments to root
				if (!inScopeChain)
					addVariableMember(root, v, isolateId);
			}
		}
	}

	/**
	 * Map DMessage / Player attributes to VariableAttributes
	 */
	int toAttributes(int pAttr) {
		int attr = pAttr; /* 1-1 mapping */
		return attr;
	}

	DVariable extractVariable(DMessage msg) {
		DVariable v = extractVariable(msg, msg.getString());
		return v;
	}

	/**
	 * Build a variable based on the information we can extract from the
	 * messsage
	 */
	DVariable extractVariable(DMessage msg, String name) {
		int oType = msg.getWord();
		int flags = (int) msg.getDWord();
		return extractAtom(msg, name, oType, flags);
	}

	/**
	 * Extracts an builds a register variable
	 */
	DVariable extractRegister(DMessage msg, int number) {
		int oType = msg.getWord();
		return extractAtom(msg, "$" + number, oType, 0); //$NON-NLS-1$
	}

	/**
	 * Does the job of pulling together a variable based on the type of object
	 * encountered.
	 */
	DVariable extractAtom(DMessage msg, String name, int oType, int flags) {
		int vType = VariableType.UNKNOWN;
		Object value = null;
		String typeName = ""; //$NON-NLS-1$
		String className = ""; //$NON-NLS-1$
		boolean isPrimitive = false;

		/* now we vary depending upon type */
		switch (oType) {
		case DMessage.kNumberType: {
			String s = msg.getString();
			double dval = Double.NaN;
			try {
				dval = Double.parseDouble(s);
			} catch (NumberFormatException nfe) {
			}

			value = new Double(dval);
			isPrimitive = true;
			break;
		}

		case DMessage.kBooleanType: {
			int bval = msg.getByte();
			value = new Boolean((bval == 0) ? false : true);
			isPrimitive = true;
			break;
		}

		case DMessage.kStringType: {
			String s = msg.getString();

			value = s;
			isPrimitive = true;
			break;
		}

		case DMessage.kObjectType:
		case DMessage.kNamespaceType: {
			long oid = msg.getPtr();
			long cType = (oid == -1) ? 0 : msg.getDWord();
			int isFnc = (oid == -1) ? 0 : msg.getWord();
			int rsvd = (oid == -1) ? 0 : msg.getWord();
			typeName = (oid == -1) ? "" : msg.getString(); //$NON-NLS-1$
			/* anirudhs: Date fix for expression evaluation */
			/* Player 10.2 onwards, the typename for Date comes
			 * as <dateformat>@oid where example of date format is:
			 * <Tue Feb 7 15:41:16 GMT+0530 2012>
			 * We have to fix the typename to how it originally
			 * appeared prior to this bug which is Date@oid.
			 * Note that even player 9 did not send oType as 11,
			 * instead oType was Object where as typeName was Date.
			 * What the customer sees is expression evaluation will
			 * always try to interpret date as a number. (ECMA.defaultValue
			 * has a check for preferredType of Date to be String) 
			 */
			if (typeName.startsWith("<")) { //$NON-NLS-1$
				int atIndex = typeName.indexOf('@');
				String dateVal = typeName;
				if (atIndex > -1) {
					dateVal = typeName.substring(0, atIndex);
				}
				SimpleDateFormat dFormat = new SimpleDateFormat("<EEE MMM d HH:mm:ss 'GMT'z yyyy>"); //$NON-NLS-1$
				try {
					Date dateObj = dFormat.parse(dateVal);
					if (dateObj != null && dateObj.getTime() != 0) {
						oType = DMessage.kDateType;
						typeName = "Date" + typeName.substring(atIndex); //$NON-NLS-1$
					}
				}
				catch (ParseException e) {
					//ignore
				}
			}
			
			className = DVariable.classNameFor(cType, false);
			value = new Long(oid);
			vType = (isFnc == 0) ? VariableType.OBJECT : VariableType.FUNCTION;
			break;
		}

		case DMessage.kMovieClipType: {
			long oid = msg.getPtr();
			long cType = (oid == -1) ? 0 : msg.getDWord();
			long rsvd = (oid == -1) ? 0 : msg.getDWord();
			typeName = (oid == -1) ? "" : msg.getString(); //$NON-NLS-1$
			className = DVariable.classNameFor(cType, true);

			value = new Long(oid);
			vType = VariableType.MOVIECLIP;
			break;
		}

		case DMessage.kNullType: {
			value = null;
			isPrimitive = true;
			break;
		}

		case DMessage.kUndefinedType: {
			value = Value.UNDEFINED;
			isPrimitive = true;
			break;
		}

		case DMessage.kTraitsType: {
			// This one is special: When passed to the debugger, it indicates
			// that the "variable" is not a variable at all, but rather is a
			// class name. For example, if class Y extends class X, then
			// we will send a kDTypeTraits for class Y; then we'll send all the
			// members of class Y; then we'll send a kDTypeTraits for class X;
			// and then we'll send all the members of class X. This is only
			// used by the AVM+ debugger.
			vType = VariableType.UNKNOWN;
			typeName = Value.TRAITS_TYPE_NAME;
			break;
		}

		case DMessage.kReferenceType:
		case DMessage.kArrayType:
		case DMessage.kObjectEndType:
		case DMessage.kStrictArrayType:
		case DMessage.kDateType:
		case DMessage.kLongStringType:
		case DMessage.kUnsupportedType:
		case DMessage.kRecordSetType:
		case DMessage.kXMLType:
		case DMessage.kTypedObjectType:
		case DMessage.kAvmPlusObjectType:
		default: {
			// System.out.println("<unknown>");
			break;
		}
		}
		int isolateId = msg.getTargetIsolate();
		// create the variable based on the content we received.
		DValue valueObject = null;

		// If value is a Long, then it is the ID of a non-primitive object;
		// look up to see if we already have that object in our cache. If
		// it is already in our cache, then we just want to modify the
		// existing object with the new values.
		if (value instanceof Long) {
			valueObject = getValue(((Long) value).longValue(), isolateId);
		}

		if (valueObject == null) {
			// we didn't find it in the cache, so make a new Value

			if (isPrimitive) {
				valueObject = DValue.forPrimitive(value, isolateId);
				valueObject.setAttributes(toAttributes(flags));
			} else {
				valueObject = new DValue(vType, typeName, className,
						toAttributes(flags), value, isolateId);
			}

			if (value instanceof Long
					&& (toAttributes(flags) & VariableAttribute.HAS_GETTER) == 0)
				putValue(((Long) value).longValue(), valueObject, isolateId);
		} else {
			// we found it in the cache, so just modify the properties
			// of the old Value

			if (isPrimitive) {
				// figure out some of the properties
				DValue temp = DValue.forPrimitive(value, isolateId);
				vType = temp.getType();
				typeName = temp.getTypeName();
				className = temp.getClassName();
			}

			valueObject.setType(vType);
			valueObject.setTypeName(typeName);
			valueObject.setClassName(className);
			valueObject.setAttributes(toAttributes(flags));
			valueObject.setValue(value);
		}
		if (valueObject != null) {
			valueObject.setIsolateId(isolateId);
		}
		DVariable var = new DVariable(name, valueObject, isolateId);
		return var;
	}

	/**
	 * The player sends us a URI using '|' instead of ':'
	 */
	public static String convertToURI(String playerURL) {
		int index = playerURL.indexOf('|');
		StringBuilder sb = new StringBuilder(playerURL);
		while (index > 0) {
			sb.setCharAt(index, ':');
			index = playerURL.indexOf('|', index + 1);
		}
		return sb.toString();
	}

	/**
	 * Tell us that we are about to start executing user code in the player,
	 * such as a getter, a setter, or a function call. If a FaultEvent comes in
	 * while the code is executing, it is not added to the event queue in the
	 * normal way -- instead, it is saved, and is returned when
	 * endPlayerCodeExecution() is called.
	 */
	public void beginPlayerCodeExecution(int isolateId) {
		DManagerIsolateState state = getIsolateState(isolateId);
		state.m_executingPlayerCode = true;
		state.m_faultEventDuringPlayerCodeExecution = null;
	}

	/**
	 * Informs us that user code is no longer executing, and returns the fault,
	 * if any, which occurred while the code was executing.
	 */
	public FaultEvent endPlayerCodeExecution(int isolateId) {
		DManagerIsolateState state = getIsolateState(isolateId);
		state.m_executingPlayerCode = false;
		FaultEvent e = state.m_faultEventDuringPlayerCodeExecution;
		state.m_faultEventDuringPlayerCodeExecution = null;
		return e;
	}

	/**
	 * When we've just received any FaultEvent from the player, this function
	 * gets called. If a getter/setter is currently executing, we'll save the
	 * fault for someone to get later by calling endGetterSetter(). Otherwise,
	 * normal code execution is taking place, so we'll add the event to the
	 * event queue.
	 */
	private void handleFaultEvent(FaultEvent faultEvent) {
		DManagerIsolateState isolateState = getIsolateState(faultEvent.isolateId);
		boolean executingPlayerCode = isolateState.m_executingPlayerCode;
		if (executingPlayerCode) {
			FaultEvent faultEventDuringPlayerCodeExecution = isolateState.m_faultEventDuringPlayerCodeExecution;
			
			if (faultEventDuringPlayerCodeExecution == null) // only save the
																// first fault
			{
				// save the event away so that when someone later calls
				// endGetterSetter(), we can return the fault that
				// occurred
				isolateState.m_faultEventDuringPlayerCodeExecution = faultEvent;
			}
		} else {
			// regular code is running; so post the event to the
			// event queue which the client debugger will see
			addEvent(faultEvent);
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see flash.tools.debugger.SourceLocator#locateSource(java.lang.String,
	 * java.lang.String, java.lang.String)
	 */
	public InputStream locateSource(String path, String pkg, String name) {
		if (m_sourceLocator != null)
			return m_sourceLocator.locateSource(path, pkg, name);

		return null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see flash.tools.debugger.SourceLocator#getChangeCount()
	 */
	public int getChangeCount() {
		if (m_sourceLocator != null)
			return m_sourceLocator.getChangeCount();

		return 0;
	}

	/**
	 * Returns the value of a Flash Player option that was requested by
	 * OutGetOption and returned by InOption.
	 * 
	 * @param optionName
	 *            the name of the option
	 * @return its value, or null
	 */
	public String getOption(String optionName) {
		return m_options.get(optionName);
	}
}
