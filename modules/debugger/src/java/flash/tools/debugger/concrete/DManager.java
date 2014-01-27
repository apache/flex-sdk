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

import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import flash.tools.debugger.SourceLocator;
import flash.tools.debugger.SuspendReason;
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
import flash.tools.debugger.events.InvalidTargetFault;
import flash.tools.debugger.events.InvalidURLFault;
import flash.tools.debugger.events.InvalidWithFault;
import flash.tools.debugger.events.ProtoLimitFault;
import flash.tools.debugger.events.RecursionLimitFault;
import flash.tools.debugger.events.ScriptTimeoutFault;
import flash.tools.debugger.events.StackUnderFlowFault;
import flash.tools.debugger.events.SwfLoadedEvent;
import flash.tools.debugger.events.SwfUnloadedEvent;
import flash.tools.debugger.events.TraceEvent;
import flash.util.Trace;

/**
 * Implements the receiving and updating of debug state from the socket connection
 * of the Flash Player.
 */
public class DManager implements DProtocolNotifierIF, SourceLocator
{
	private final HashMap<String, String>	m_parms;
	private final Map<Integer,DModule>		m_source;	   /* WARNING: accessed from multiple threads */
	private final ArrayList<DLocation>		m_breakpoints; /* WARNING: accessed from multiple threads */
	private final ArrayList<DSwfInfo>		m_swfInfo;     /* WARNING: accessed from multiple threads */
	private final ArrayList<DWatch>			m_watchpoints; /* WARNING: accessed from multiple threads */

	/**
	 * The currently active stack frames.
	 */
	private ArrayList<DStackContext>		m_frames;

	/**
	 * The stack frames that were active the last time the player was suspended.
	 */
	private ArrayList<DStackContext>		m_previousFrames;

	/**
	 * A list of all known variables in the player.  Stored as a mapping
	 * from an object's id to its DValue.
	 */
	private Map<Long,DValue>				m_values;

	/**
	 * A list of all known variables in the player from the previous time
	 * the player was suspended.  Stored as a mapping from an object's id
	 * to its DValue.
	 */
	private Map<Long,DValue>				m_previousValues;

	private LinkedList<DebugEvent> m_event;	/* our event queue; WARNING: accessed from multiple threads */
	private DSuspendInfo	m_suspendInfo;	/* info for when we are stopped */
	private SourceLocator	m_sourceLocator;

	private DSwfInfo	m_lastSwfInfo;		/* hack for syncing swfinfo records with incoming InScript messages */
	private DVariable	m_lastInGetVariable;/* hack for getVariable call to work with getters */
	private boolean		m_attachChildren;	/* hack for getVariable call to work with getters */
	private DVariable	m_lastInCallFunction; /* hack for callFunction to work */
	private DVariable	m_lastInBinaryOp;
	private boolean		m_squelchEnabled;	/* true if we are talking to a squelch enabled debug player */
	private int			m_playerVersion;	/* player version number obtained from InVersion message; e.g. 9 for Flash Player 9.0 */

	private boolean		m_sourceListModified;	/* deprecated; indicates m_source has changed since last
												 * call to getSource().
												 * WARNING: lock with synchronized (m_source) { ... }
												 */
	private byte[]		m_actions;				/* deprecated */
	private String[]	m_lastConstantPool;		/* deprecated */

	// SWF/SWD fetching and parsing
	private String		m_uri;
	private byte[]		m_swf;					// latest swf obtained from get swf
	private byte[]		m_swd;					// latest swd obtained from get swd

	private boolean		m_executingPlayerCode;
	private FaultEvent	m_faultEventDuringPlayerCodeExecution;

	private Map<String, String>	m_options = new HashMap<String, String>();	// Player options that have been queried by OutGetOption, and come back via InOption

	public static final String ARGUMENTS_MARKER = "$arguments"; //$NON-NLS-1$
	public static final String SCOPE_CHAIN_MARKER = "$scopechain"; //$NON-NLS-1$

	public DManager()
	{
		m_parms = new HashMap<String, String>();
		m_source = new HashMap<Integer, DModule>();
		m_breakpoints = new ArrayList<DLocation>();
		m_values = new HashMap<Long, DValue>();
		m_previousValues = new HashMap<Long, DValue>();
		m_frames = new ArrayList<DStackContext>();
		m_previousFrames = new ArrayList<DStackContext>();
		m_swfInfo = new ArrayList<DSwfInfo>();
		m_watchpoints = new ArrayList<DWatch>();
		m_event = new LinkedList<DebugEvent>();
		m_suspendInfo = null;
		m_sourceLocator = null;

		m_lastInGetVariable = null;
		m_attachChildren = true;
		m_lastInCallFunction = null;
		m_squelchEnabled = false;
		m_lastConstantPool = null;
        m_playerVersion = -1; // -1 => unknown
	}

	public String getURI()		{ return m_uri; }
    public byte[] getSWF()		{ return m_swf; }
    public byte[] getSWD()		{ return m_swd; }
    public byte[] getActions()	{ return m_actions; }
    
    /** Returns the Flash Player version number; e.g. 9 for Flash Player 9.0 */
    public int    getVersion()  { return m_playerVersion; }
    
	public SourceLocator getSourceLocator() { return m_sourceLocator; }
	public void setSourceLocator(SourceLocator sl) { m_sourceLocator = sl; }

	/**
	 * If this feature is enabled then we do not attempt to attach
	 * child variables to parents.
	 */
	public void enableChildAttach(boolean enable) { m_attachChildren = enable; }

	// return/clear the last variable seen from an InGetVariable message
	public DVariable	lastVariable()			{ return m_lastInGetVariable; }
	public void			clearLastVariable()		{ m_lastInGetVariable = null; }

	// return/clear the last variable seen from an InCallFunction message
	public DVariable	lastFunctionCall()		{ return m_lastInCallFunction; }
	public void			clearLastFunctionCall()	{ m_lastInCallFunction = null; }

	// return/clear the last binary op result seen from an InBinaryOp message
	public DVariable	lastBinaryOp()			{ return m_lastInBinaryOp; }
	public void			clearLastBinaryOp()		{ m_lastInBinaryOp = null; }

	/*
	 * Frees up any information we have kept about
	 */
	void freeCaches()
	{
		clearFrames();
		freeValueCache();
	}

	void freeValueCache()
	{
		m_previousValues = m_values;
		m_values = new HashMap<Long, DValue>();

		// mark all frames as stale
		int size = getFrameCount();
		for(int i=0; i<size; i++)
			getFrame(i).markStale();
	}

	// continuing our execution
	void continuing()
	{
		freeCaches();
		m_suspendInfo = null;
	}

	/**
	 * Variables
	 */
	DValue getOrCreateValue(long id)
	{
		DValue v = getValue(id);
		if (v == null)
		{
			v = new DValue(id);
			putValue(id, v);
		}
		return v;
	}

	// Simple DSwfInfo getters
	public DSwfInfo[] getSwfInfos()
	{
		synchronized (m_swfInfo)
		{
			return m_swfInfo.toArray( new DSwfInfo[m_swfInfo.size()] );
		}
	}

	public DSwfInfo getSwfInfo(int at)
	{
		synchronized (m_swfInfo)
		{
			return m_swfInfo.get(at);
		}
	}

	public int getSwfInfoCount()
	{
		synchronized (m_swfInfo)
		{
			return m_swfInfo.size();
		}
	}

	/**
	 * Obtains a SwfInfo object at the given index or if one
	 * doesn't yet exist at that location, creates a new empty
	 * one there and returns it.
	 */
	DSwfInfo getOrCreateSwfInfo(int at)
	{
		synchronized (m_swfInfo)
		{
			DSwfInfo i = (at > -1 && at < getSwfInfoCount()) ? getSwfInfo(at) : null;
			if (i == null)
			{
				// are we above water
				at = (at < 0) ? 0 : at;

				// fill all the gaps with null; really shouldn't be any...
				while(at > m_swfInfo.size())
					m_swfInfo.add(null);

				i = new DSwfInfo(at);
				m_swfInfo.add(at, i);
			}
			return i;
		}
	}

	/**
	 * Get the most recently active swfInfo object.
	 * We define active as the most recently seen swfInfo
	 */
	DSwfInfo getActiveSwfInfo()
	{
		int count = getSwfInfoCount();

		// pick up the last one seen
		DSwfInfo swf = m_lastSwfInfo;

		// still don't have one then get or create the most recent one
		// works if count = 0
		if (swf == null)
			swf = getOrCreateSwfInfo(count-1);

		if (swf.hasAllSource())
		{
			// already full so create a new one on the end
			swf = getOrCreateSwfInfo(count);
		}
		return swf;
	}

	/**
	 * Walk the list of scripts and add them to our swfInfo object
	 * This method may be called when min/max are zero and the swd
	 * has not yet fully loaded in the player or it could be called
	 * before we have all the scripts.
	 */
	void tieScriptsToSwf(DSwfInfo info)
	{
		if (!info.hasAllSource())
		{
			int min = info.getFirstSourceId();
			int max = info.getLastSourceId();
//			System.out.println("attaching scripts "+min+"-"+max+" to "+info.getUrl());
			for(int i=min; i<=max; i++)
			{
				DModule m = getSource(i);
				if (m == null)
				{
					// this is ok, it means the scripts are coming...
				}
				else
				{
					info.addSource(i, m);
				}
			}
		}
	}

	/**
	 * Record a new source file.
	 * @param name filename in "basepath;package;filename" format
	 * @param swfIndex the index of the SWF with which this source is associated,
	 *                 or -1 is we don't know
	 * @return true if our list of source files was modified, or false if we
	 * already knew about that particular source file.
	 */
	private boolean putSource(int swfIndex, int moduleId, int bitmap, String name, String text)
	{
		synchronized (m_source)
		{
			// if we haven't already recorded this script then do so.
			if (!m_source.containsKey(moduleId))
	        {
				DModule s = new DModule(this, moduleId, bitmap, name, text);

	            // put source in our large pool
	            m_source.put(moduleId, s);

	            // put the source in the currently active swf
	            DSwfInfo swf;
				if (swfIndex == -1)				// caller didn't tell us what swf thi is for
					swf = getActiveSwfInfo();	// ... so guess
				else
					swf = getOrCreateSwfInfo(swfIndex);

	            swf.addSource(moduleId, s);

				return true;
	        }

			return false;
		}
	}

	/**
	 * Remove our record of a particular source file.
	 * @param id the id of the file to forget about.
	 * @return true if source file was removed; false if we didn't know about
	 * it to begin with.
	 */
	private boolean removeSource(int id)
	{
		synchronized (m_source)
		{
			try
			{
				m_source.remove(id);
			}
			catch(Exception e)
			{
				return false;
			}
			return true;
		}
	}

	public DModule getSource(int id)
	{
		synchronized (m_source)
		{
			return m_source.get(id);
		}
	}

	// @deprecated
	public DModule[] getSources()
	{
		synchronized (m_source)
		{
			m_sourceListModified = false;

			/* find out the size of the array */
			int count = m_source.size();
			DModule[] ar = new DModule[count];

			count = 0;
			for (DModule sf: m_source.values())
				ar[count++] = sf;
			return ar;
		}
	}

	// @deprecated
	boolean sourceListModified()
	{
		synchronized (m_source)
		{
			return m_sourceListModified;
		}
	}

	public DValue getValue(long id)
	{
		DValue v = m_values.get(id);
		return v;
	}

	/**
	 * Returns the previous value object for the given id -- that is, the value that that
	 * object had the last time the player was suspended.  Never requests it from the
	 * player (because it can't, of course).  Returns <code>null</code> if we don't have
	 * a value for that id.
	 */
	public DValue getPreviousValue(long id)
	{
		return m_previousValues.get(id);
	}

	void putValue(long id, DValue v)
	{
		if (id != Value.UNKNOWN_ID)
		{
			m_values.put(id, v);
		}
	}

	DValue removeValue(long id)
	{
		return m_values.remove((int)id);
	}

	void addVariableMember(long parentId, DVariable child)
	{
		DValue parent = getValue(parentId);
		addVariableMember(parent, child);
	}

	void addVariableMember(DValue parent, DVariable child)
	{
		if (m_attachChildren)
		{
			// There are certain situations when the Flash player will send us more
			// than one variable or getter with the same name.  Basically, when a
			// subclass implements (or overrides) something that was also declared in a
			// superclass, then we'll see that variable or getter in both the
			// superclass and the subclass.
			//
			// Here are a few situations where that affects the debugger in different
			// ways:
			//
			// 1. When a class implements an interface, the class instance actually has
			//    *two* members for each implemented function: One which is public and
			//    represents the implementation function, and another which is internal
			//    to the interface, and represents the declaration of the function.
			//    Both of these come in to us.  In the UI, the one we want to show is
			//    the public one.  They come in in random order (they are stored in a
			//    hash table in the VM), so we don't know which one will come first.
			//
			// 2. When a superclass has a private member "m", and a subclass has its own
			//    private member with the same name "m", we will receive both of them.
			//    (They are scoped by different packages.)  In this case, the first one
			//    the player sent us is the one from the subclass, and that is the one
			//    we want to display in the debugger.
			//
			// The following logic correctly deals with all variations of those cases.
			if (parent != null) 
			{
				DVariable existingChildWithSameName = parent.findMember(child.getName());
				if (existingChildWithSameName != null)
				{
					int existingScope = existingChildWithSameName.getScope();
					int newScope = child.getScope();

					if (existingScope == VariableAttribute.NAMESPACE_SCOPE && newScope == VariableAttribute.PUBLIC_SCOPE)
					{
						// This is the case described above where a class implements an interface,
						// so that class's definition includes both a namespace-scoped declaration
						// and a public declaration, in random order; in this case, the
						// namespace-scoped declaration came first.  We want to use the public
						// declaration.
						parent.addMember(child);
					}
					else if (existingScope == VariableAttribute.PUBLIC_SCOPE && newScope == VariableAttribute.NAMESPACE_SCOPE)
					{
						// One of two things happened here:
						//
						// 1. This is the case described above where a class implements an interface,
						//    so that class's definition includes both a namespace-scoped declaration
						//    and a public declaration, in random order; in this case, the
						//    public declaration came first.  It is tempting to use the public
						//    member in this case, but there is a catch...
						// 2. It might be more complicated than that: Perhaps there is interface I,
						//    and class C1 implements I, but class C2 extends C1, and overrides
						//    one of the members of I that was already implemented by C1.  In this
						//    case, the public declaration from C2 came first, but now we are seeing
						//    a namespace-scoped declaration in C1.  We need to record that the
						//    member is public, but we also need to record that it is a member
						//    of the base class, not just a member of the superclass.
						//
						// The easiest way to deal with both cases is to use the child that came from
						// the superclass, but to change its scope to public.
						child.makePublic();
						parent.addMember(child);
					}
					else if (existingScope != VariableAttribute.PRIVATE_SCOPE && existingScope == newScope)
					{
						// This is a public, protected, internal, or namespace-scoped member which
						// was defined in a base class and overridden in a subclass.  We want to
						// use the member from the base class, to that the debugger knows where the
						// variable was actually defined.
						parent.addMember(child);
					}
					else if (existingScope == VariableAttribute.PRIVATE_SCOPE && existingScope == newScope)
					{
						parent.addInheritedPrivateMember(child);
					}
				}
				else
				{
					parent.addMember(child);
				}
			}
			// put child in the registry if it has an id and not already there
			DValue childValue = (DValue) child.getValue();
			long childId = childValue.getId();
			if (childId != Value.UNKNOWN_ID)
			{
				DValue existingValue = getValue(childId);
				if (existingValue != null)
				{
					assert existingValue == childValue; // TODO is this right? what about getters?
				}
				else
				{
					putValue(childId, childValue);
				}
			}
		}
	}

	// TODO is this right?
	void addVariableMember(long parentId, DVariable child, long doubleAsId)
	{
		addVariableMember(parentId, child);

		// double book the child under another id
		if (m_attachChildren)
			putValue(doubleAsId, (DValue) child.getValue());
	}

	//  @deprecated last pool that was read
	public String[] getConstantPool() { return m_lastConstantPool; }

	/**
	 * Breakpoints
	 */
	public DLocation getBreakpoint(int id)
	{
		synchronized (m_breakpoints)
		{
			DLocation loc = null;
			int which = findBreakpoint(id);
			if (which > -1)
				loc = m_breakpoints.get(which);
			return loc;
		}
	}

	int findBreakpoint(int id)
	{
		synchronized (m_breakpoints)
		{
			int which = -1;
			int size = m_breakpoints.size();
			for(int i=0; which < 0 && i<size; i++)
			{
				DLocation l = m_breakpoints.get(i);
				if (l.getId() == id)
					which = i;
			}
			return which;
		}
	}

	DLocation removeBreakpoint(int id)
	{
		synchronized (m_breakpoints)
		{
			DLocation loc = null;
			int which = findBreakpoint(id);
			if (which > -1)
			{
				loc = m_breakpoints.get(which);
				m_breakpoints.remove(which);
			}

			return loc;
		}
	}

	void addBreakpoint(int id, DLocation l)
	{
		synchronized (m_breakpoints)
		{
			m_breakpoints.add(l);
		}
	}

	public DLocation[] getBreakpoints()
	{
		synchronized (m_breakpoints)
		{
			return m_breakpoints.toArray(new DLocation[m_breakpoints.size()]);
		}
	}

	/**
	 * Watchpoints
	 */
	public DWatch		getWatchpoint(int at)	{ synchronized (m_watchpoints) { return m_watchpoints.get(at); } }
	public int			getWatchpointCount()	{ synchronized (m_watchpoints) { return m_watchpoints.size(); } }
	public DWatch[]		getWatchpoints()		{ synchronized (m_watchpoints) { return m_watchpoints.toArray( new DWatch[m_watchpoints.size()] ); } }

	boolean addWatchpoint(DWatch w)				{ synchronized (m_watchpoints) { return m_watchpoints.add(w); } }

	DWatch removeWatchpoint(int tag)
	{
		synchronized (m_watchpoints)
		{
			DWatch w = null;
			int at = findWatchpoint(tag);
			if (at > -1)
				w = m_watchpoints.remove(at);
			return w;
		}
	}

	int findWatchpoint(int tag)
	{
		synchronized (m_watchpoints)
		{
			int at = -1;
			int size = getWatchpointCount();
			for(int i=0; i<size && at<0; i++)
			{
				DWatch w = getWatchpoint(i);
				if (w.getTag() == tag)
					at = i;
			}
			return at;
		}
	}

	/**
	 * Frame stack management related stuff
	 * @return true if we added this frame; false if we ignored it
	 */
	boolean addFrame(DStackContext ds)
	{
		m_frames.add(ds);
		return true;
	}

	void clearFrames()
	{
		if (m_frames.size() > 0)
			m_previousFrames = m_frames;
		m_frames = new ArrayList<DStackContext>();
	}

	public DStackContext		getFrame(int at)		{ return m_frames.get(at);}
	public int					getFrameCount()			{ return m_frames.size();}
	public DStackContext[]		getFrames()				{ return m_frames.toArray( new DStackContext[m_frames.size()] );	}

	private boolean stringsEqual(String s1, String s2)
	{
		if (s1 == null)
			return s2 == null;
		else
			return s1.equals(s2);
	}

	/**
	 * Correlates the old list of stack frames, from the last time the player
	 * was suspended, with the new list of stack frames, attempting to guess
	 * which frames correspond to each other.  This is done so that
	 * Variable.hasValueChanged() can work correctly for local variables.
	 */
	private void mapOldFramesToNew() {
		int oldSize = m_previousFrames.size();
		int newSize = m_frames.size();

		// discard all old frames (we will restore some of them below)
		DValue[] oldFrames = new DValue[oldSize];
		for (int depth = 0; depth < oldSize; depth++) {
			oldFrames[depth] = (DValue) m_previousValues.remove(Value.BASE_ID - depth);
		}

		// Start at the end of the stack (the stack frame farthest from the
		// current one), and try to match up stack frames
		int oldDepth = oldSize-1;
		int newDepth = newSize-1;
		while (oldDepth >= 0 && newDepth >= 0)
		{
			DStackContext oldFrame = m_previousFrames.get(oldDepth);
			DStackContext newFrame = m_frames.get(newDepth);
			if (oldFrame != null && newFrame != null)
			{
				if (stringsEqual(oldFrame.getCallSignature(), newFrame.getCallSignature()))
				{
					DValue frame = oldFrames[oldDepth];
					if (frame != null)
						m_previousValues.put(Value.BASE_ID - newDepth, frame);
				}
			}
			oldDepth--;
			newDepth--;
		}
	}

	/**
	 * Get function is only supported in players that
	 * recognize the squelch message.
	 */
	public boolean isGetSupported()
	{
		return m_squelchEnabled;
	}

	/**
	 * Returns a suspend information on
	 * why the Player has suspended execution.
	 * @return see SuspendReason
	 */
	public DSuspendInfo getSuspendInfo()
	{
		return m_suspendInfo;
	}

	/**
	 * Event management related stuff
	 */
	public int getEventCount()
	{
		synchronized (m_event) { return m_event.size(); }
	}

	/**
	 * Get an object on which callers can call wait(), in order to wait until
	 * something happens.
	 *
	 * Note: The object will be signalled when EITHER of the following happens:
	 * (1) An event is added to the event queue;
	 * (2) The network connection is broken (and thus there will be no more events).
	 *
	 * @return an object on which the caller can call wait()
	 */
	public Object getEventNotifier()
	{
		return m_event;
	}

	public DebugEvent nextEvent()
	{
		DebugEvent s = null;
		synchronized (m_event)
		{
			if (m_event.size() > 0)
				s = m_event.removeFirst();
		}
		return s;
	}

	public synchronized void addEvent(DebugEvent e)
	{
		synchronized (m_event)
		{
			m_event.add(e);
			m_event.notifyAll(); // wake up listeners (see getEventNotifier())
		}
	}

	/**
	 * Issued when the socket connection to the player is cut
	 */
	public void disconnected()
	{
		synchronized (m_event)
		{
			m_event.notifyAll(); // see getEventNotifier()
		}
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
		/* at this point we just open up a big switch statement and walk through all possible cases */
		int type = msg.getType();
//		System.out.println("manager msg = "+DMessage.inTypeName(type));

		switch(type)
		{
            case DMessage.InVersion:
            {
                long ver = msg.getDWord();
                m_playerVersion = (int)ver;

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

			case DMessage.InErrorExecLimit:
			{
				handleFaultEvent(new RecursionLimitFault());
				break;
			}

			case DMessage.InErrorWith:
			{
				handleFaultEvent(new InvalidWithFault());
				break;
			}

			case DMessage.InErrorProtoLimit:
			{
				handleFaultEvent(new ProtoLimitFault());
				break;
			}

			case DMessage.InErrorURLOpen:
			{
				String url = msg.getString();
				handleFaultEvent(new InvalidURLFault(url));
				break;
			}

			case DMessage.InErrorTarget:
			{
				String name = msg.getString();
				handleFaultEvent(new InvalidTargetFault(name));
				break;
			}

			case DMessage.InErrorException:
			{
				long offset = msg.getDWord();
				// As of FP9, the player will also send the "toString()" message
				// of the exception.  But for backward compatibility with older
				// players, we won't assume that that is there.
				String exceptionMessage;
				boolean willExceptionBeCaught = false;
				Value thrown = null;
				if (msg.getRemaining() > 0)
				{
					exceptionMessage = msg.getString();
					if (msg.getRemaining() > 0)
					{
						if (msg.getByte() != 0)
						{
							willExceptionBeCaught = (msg.getByte() != 0 ? true : false);
							msg.getPtr();
							DVariable thrownVar = extractVariable(msg);
							thrown = thrownVar.getValue();
						}
					}
				}
				else
				{
					exceptionMessage = ""; //$NON-NLS-1$
				}
				handleFaultEvent(new ExceptionFault(exceptionMessage, willExceptionBeCaught, thrown));
				break;
			}

			case DMessage.InErrorStackUnderflow:
			{
				long offset = msg.getDWord();
				handleFaultEvent(new StackUnderFlowFault());
				break;
			}

			case DMessage.InErrorZeroDivide:
			{
				long offset = msg.getDWord();
				handleFaultEvent(new DivideByZeroFault());
				break;
			}

			case DMessage.InErrorScriptStuck:
			{
				handleFaultEvent(new ScriptTimeoutFault());
				break;
			}

			case DMessage.InErrorConsole:
			{
				String s = msg.getString();
				handleFaultEvent(new ConsoleErrorFault(s));
				break;
			}

		    case DMessage.InTrace:
			{
				String text = msg.getString();
				addEvent(new TraceEvent(text));
				break;
			}

			case DMessage.InSquelch:
			{
				long state = msg.getDWord();
				m_squelchEnabled = (state != 0) ? true : false;
				break;
			}

			case DMessage.InParam:
			{
				String name = msg.getString();
				String value = msg.getString();

				// here's where we get movie = URL and password which I'm not sure what to do with?
//				System.out.println(name+"="+value);
				m_parms.put(name, value);

				// if string is a "movie", then this is a URL
				if (name.startsWith("movie")) //$NON-NLS-1$
					m_uri = convertToURI(value);
				break;
			}

			case DMessage.InPlaceObject:
			{
				long objId = msg.getPtr();
				String path = msg.getString();
//				m_bag.placeObject((int)objId, path);
				break;
			}

			case DMessage.InSetProperty:
			{
				long objId = msg.getPtr();
				int item = msg.getWord();
				String value = msg.getString();
				break;
			}

			case DMessage.InNewObject:
			{
				long objId = msg.getPtr();
				break;
			}

			case DMessage.InRemoveObject:
			{
				long objId = msg.getPtr();
//				m_bag.removeObject((int)objId);
				break;
			}

			case DMessage.InSetVariable:
			{
				long objId = msg.getPtr();
				String name = msg.getString();
				int dType = msg.getWord();
				int flags = (int) msg.getDWord();
				String value = msg.getString();

//				m_bag.createVariable((int)objId, name, dType, flags, value);
				break;
			}

			case DMessage.InDeleteVariable:
			{
				long objId = msg.getPtr();
				String name = msg.getString();
//				m_bag.deleteVariable((int)objId, name);
				break;
			}

			case DMessage.InScript:
			{
				int module = (int)msg.getDWord();
				int bitmap = (int)msg.getDWord();
				String name = msg.getString(); // in "basepath;package;filename" format
				String text = msg.getString();
				int swfIndex = -1;

				/* new in flash player 9: player tells us what swf this is for */
				if (msg.getRemaining() >= 4)
					swfIndex = (int)msg.getDWord();

				synchronized (m_source)
				{
					// create new source file
					if (putSource(swfIndex, module, bitmap, name, text))
					{
						// have we changed the list since last query
						if (!m_sourceListModified)
							addEvent(new FileListModifiedEvent());

						m_sourceListModified = true;  /* current source list is stale */
					}
				}
				break;
			}

			case DMessage.InRemoveScript:
			{
				long module = msg.getDWord();
				synchronized (m_source)
				{
					if (removeSource((int)module))
					{
						// have we changed the list since last query
						if (!m_sourceListModified)
							addEvent(new FileListModifiedEvent());

						m_sourceListModified = true;  /* current source list is stale */
					}
				}
				break;
			}

			case DMessage.InAskBreakpoints:
			{
				// the player has just loaded a swf and we know the player
				// has halted, waiting for us to continue.  The only caveat
				// is that it looks like it still does a number of things in
				// the background which take a few seconds to complete.
				if (m_suspendInfo == null)
					m_suspendInfo = new DSuspendInfo(SuspendReason.ScriptLoaded, 0, 0, 0, 0);
				break;
			}

			case DMessage.InBreakAt:
			{
				long bp = msg.getDWord();
				long id = msg.getPtr();
				String stack = msg.getString();
//				System.out.println(msg.getInTypeName()+",bp="+(bp&0xffff)+":"+(bp>>16)+",id="+id+",stack=\n"+stack);

				//System.out.println("InBreakAt");

				int module = DLocation.decodeFile(bp);
				int  line = DLocation.decodeLine (bp);
				addEvent(new BreakEvent(module, line));
				break;
			}

			case DMessage.InContinue:
			{
				/* we are running again so trash all our variable contents */
				continuing();
				break;
			}

			case DMessage.InSetLocalVariables:
			{
				long objId = msg.getPtr();
//				m_bag.markObjectLocal((int)objId, true);
				break;
			}

			case DMessage.InSetBreakpoint:
			{
				long count = msg.getDWord();
				while(count-- > 0)
				{
					long bp = msg.getDWord();

					int fileId = DLocation.decodeFile(bp);
					int line = DLocation.decodeLine(bp);

					DModule file = getSource(fileId);
					DLocation l = new DLocation(file, line);

					if (file != null)
						addBreakpoint((int)bp, l);
				}
				break;
			}

			case DMessage.InNumScript:
			{
				/* lets us know how many scripts there are */
				int num = (int)msg.getDWord();
				DSwfInfo swf;

				/*
				 * New as of flash player 9: another dword indicating which swf this is for.
				 * That means we don't have to guess whether this is for an old SWF
				 * which has just had some more modules loaded, or for a new SWF!
				 */
				if (msg.getRemaining() >= 4)
				{
					int swfIndex = (int) msg.getDWord();
					swf = getOrCreateSwfInfo(swfIndex);
					m_lastSwfInfo = swf;
				}
				else
				{
					/* This is not flash player 9 (or it is an early build of fp9).
					 *
					 * We use this message as a trigger that a new swf has been loaded, so make sure
					 * we are ready to accept the scripts.
					 */
					swf = getActiveSwfInfo();
				}

				// It is NOT an error for the player to have sent us a new,
				// different sourceExpectedCount from whatever we had before!
				// In fact, this happens all the time, whenever a SWF has more
				// than one ABC.
				swf.setSourceExpectedCount(num);
				break;
			}

			case DMessage.InRemoveBreakpoint:
			{
				long count = msg.getDWord();
				while(count-- > 0)
				{
					long bp = msg.getDWord();
					removeBreakpoint((int)bp);
				}
				break;

			}

			case DMessage.InBreakAtExt:
			{
				long bp = msg.getDWord();
				long num = msg.getDWord();

//				System.out.println(msg.getInTypeName()+",bp="+(bp&0xffff)+":"+(bp>>16));
				/* we have stack info to store away */
				clearFrames();  // just in case
				int depth = 0;
				while(num-- > 0)
				{
					long bpi = msg.getDWord();
					long id = msg.getPtr();
					String stack = msg.getString();
					int module = DLocation.decodeFile(bpi);
					int  line = DLocation.decodeLine (bpi);
					DModule m = getSource(module);
					DStackContext c = new DStackContext( module, line, m, id, stack, depth);
					// If addFrame() returns false, that means it chose to ignore this
					// frame, so we do NOT want to increment our depth for the next
					// time through the loop.  If it returns true, then we do want to.
					if (addFrame(c))
						++depth;
//					System.out.println("   this="+id+",@"+(bpi&0xffff)+":"+(bpi>>16)+",stack="+stack);
				}
				mapOldFramesToNew();
				break;

			}

			case DMessage.InFrame:
			{
				// For InFrame the first element is really our frame id
				DValue frame = null;
				DVariable child = null;
				ArrayList<DVariable> v = new ArrayList<DVariable>();
				ArrayList<DVariable> registers = new ArrayList<DVariable>();

				int depth = (int)msg.getDWord(); // depth of frame

				// make sure we have a valid depth
				if (depth > -1)
				{
					// first thing is number of registers
					int num = (int)msg.getDWord();
					for(int i=0; i<num; i++)
						registers.add( extractRegister(msg, i+1) );
				}

				int currentArg = -1;
				boolean gettingScopeChain = false;

				// then our frame itself
				while(msg.getRemaining() > 0)
				{
					long frameId = msg.getPtr();

					if (frame == null)
					{
						frame = getOrCreateValue(frameId);
						extractVariable(msg);  // put the rest of the info in the trash
					}
					else
					{
						child = extractVariable(msg);
						if (currentArg == -1 && child.getName().equals(ARGUMENTS_MARKER))
						{
							currentArg = 0;
							gettingScopeChain = false;
						}
						else if (child.getName().equals(SCOPE_CHAIN_MARKER))
						{
							currentArg = -1;
							gettingScopeChain = true;
						}
						else if (currentArg >= 0)
						{
							// work around a compiler bug: If the variable's name is "undefined",
							// then change its name to "_argN", where "N" is the argument index,
							// e.g. _arg1, _arg2, etc.
							++currentArg;
							if (child.getName().equals("undefined")) //$NON-NLS-1$
								child.setName("_arg" + currentArg); //$NON-NLS-1$
						}

						// All args and locals get added as "children" of
						// the frame; but scope chain entries do not.
						if (!gettingScopeChain)
							addVariableMember(frameId, child);

						// Everything gets added to the ordered list of
						// variables that came in.
						v.add(child);
					}
				}

				// let's transfer our newly gained knowledge into the stack context
				if (depth == 0)
					populateRootNode(frame, v);
				else
					populateFrame(depth, v);

				break;
			}

			case DMessage.InOption:
			{
				String s = msg.getString();
				String v = msg.getString();
				m_options.put(s, v);
				break;
			}

			case DMessage.InGetVariable:
			{
				// For InGetVariable the first element is the original entity we requested
				DValue parent = null;
				DVariable child = null;
				String definingClass = null;
				int level = 0;
				int highestLevelWithMembers = -1;
				List<String> classes = new ArrayList<String>();

				while(msg.getRemaining() > 0)
				{
					long parentId = msg.getPtr();

					// build or get parent node
					if (parent == null)
					{
						String name = msg.getString();

						// pull the contents of the node which normally are disposed of except if we did a 0,name call
						m_lastInGetVariable = extractVariable(msg, name);

						parent = getOrCreateValue(parentId);
					}
					else
					{
						// extract the child and add it to the parent.
						child = extractVariable(msg);
						if (showMember(child)) {
							if (child.isAttributeSet(VariableAttribute.IS_DYNAMIC)) {
								// Dynamic attributes always come in marked as a member of
								// class "Object"; but to the user, it makes more sense to
								// consider them as members of the topmost class.
								if (classes.size() > 0) {
									child.setDefiningClass(0, classes.get(0));
									highestLevelWithMembers = Math.max(highestLevelWithMembers, 0);
								}
							} else {
								child.setDefiningClass(level, definingClass);
								if (definingClass != null) {
									highestLevelWithMembers = Math.max(highestLevelWithMembers, level);
								}
							}
							addVariableMember(parent.getId(), child);
						} else {
							if (isTraits(child)) {
								definingClass = child.getQualifiedName();
								level = classes.size();

								// If the traits name end with "$", then it represents a class object --
								// in other words, the variables inside it are static variables of that
								// class.  In that case, we need to juggle the information.  For example,
								// if we are told that a variable is a member of "MyClass$", we actually
								// store it into the information for "MyClass".
								if (definingClass.endsWith("$")) { //$NON-NLS-1$
									String classWithoutDollar = definingClass.substring(0, definingClass.length() - 1);
									int indexOfClass = classes.indexOf(classWithoutDollar);
									if (indexOfClass != -1) {
										level = indexOfClass;
										definingClass = classWithoutDollar;
									}
								}

								// It wasn't static -- so, add this class to the end of the list of classes
								if (level == classes.size()) {
									classes.add(definingClass);
								}
							}
						}
					}
				}

				if (parent != null && parent.getClassHierarchy(true) == null) {
					parent.setClassHierarchy(classes.toArray(new String[classes.size()]), highestLevelWithMembers+1);
				}

				break;
			}

			case DMessage.InWatch:		// for AS2; sends 16-bit ID field
			case DMessage.InWatch2:		// for AS3; sends 32-bit ID field
			{
				// This message is sent whenever a watchpoint is added
				// modified or removed.
				//
				// For an addition, flags will be non-zero and
				// success will be true.
				//
				// For a modification flags  will be non-zero.
				// and oldFlags will be non-zero and success
				// will be true.  Additionally oldFlags will not
				// be equal to flags.
				//
				// For a removal flags will be zero.  oldFlags
				// will be non-zero.
				//
				// flags identifies the type of watchpoint added,
				// see WatchKind.
				//
				// success indicates whether the operation was successful
				//
				// request.   It will be associated with the watchpoint.
				int success = msg.getWord();
				int oldFlags = msg.getWord();
				int oldTag = msg.getWord();
				int flags = msg.getWord();
				int tag = msg.getWord();
				// for AS2, the ID came in above as a Word.  For AS3, the above value is
				// bogus, and it has been sent again as a DWord.
				long id = ((type == DMessage.InWatch2) ? msg.getPtr() : msg.getWord());
				String name = msg.getString();

				if (success != 0)
				{
					if (flags == 0)
					{
						removeWatchpoint(oldTag);
					}
					else
					{
						// modification or addition is the same to us
						// a new watch is created and added into the table
						// while any old entry if it exists is removed.
						removeWatchpoint(oldTag);
						DWatch w = new DWatch(id, name, flags, tag);
						addWatchpoint(w);
					}
				}
				break;
			}

            case DMessage.InGetSwf:
            {
				// we only house the swf temporarily, PlayerSession then
				// pieces it back into swfinfo record.  Also, we don't
				// send any extra data in the message so that we need not
				// copy the bytes.
				m_swf = msg.getData();
                break;
            }

            case DMessage.InGetSwd:
            {
				// we only house the swd temporarily, PlayerSession then
				// pieces it back into swfinfo record.
				m_swd = msg.getData();
                break;
            }

            case DMessage.InBreakReason:
            {
				// the id map 1-1 with out SuspendReason interface constants
                int suspendReason = msg.getWord();
				int suspendPlayer = msg.getWord();  // item index of player
				int breakOffset = (int)msg.getDWord();  // current script offset
				int prevBreakOffset = (int)msg.getDWord();  // prev script offset
				int nextBreakOffset = (int)msg.getDWord();  // next script offset
				m_suspendInfo = new DSuspendInfo(suspendReason, suspendPlayer, breakOffset, prevBreakOffset, nextBreakOffset);

				// augment the current frame with this information.  It
				// should work ok since we only get this message after a
				// InBreakAtExt message
				try
				{
					DStackContext c = getFrame(0);
					c.setOffset(breakOffset);
					c.setSwfIndex(suspendPlayer);
				}
				catch(Exception e)
				{
					if (Trace.error)
					{
						Trace.trace("Oh my god, gag me with a spoon...getFrame(0) call failed"); //$NON-NLS-1$
						e.printStackTrace();
					}
				}
                break;
            }

			// obtain raw action script byte codes
            case DMessage.InGetActions:
            {
				int item = msg.getWord();
				int rsvd = msg.getWord();
				int at = (int)msg.getDWord();
				int len = (int)msg.getDWord();
				int i = 0;

				m_actions = (len <= 0) ? null : new byte[len];
				while(len-- > 0)
					m_actions[i++] = (byte)msg.getByte();

                break;
            }

			// obtain data about a SWF
			case DMessage.InSwfInfo:
            {
				int count = msg.getWord();
				for(int i=0; i<count; i++)
				{
					long index = msg.getDWord();
					long id = msg.getPtr();

					// get it
					DSwfInfo info = getOrCreateSwfInfo((int)index);

					// remember which was last seen
					m_lastSwfInfo = info;

					if (id != 0)
					{
						boolean  debugComing = (msg.getByte() == 0) ? false : true;
						byte vmVersion = (byte)msg.getByte();  // AS vm version number (1 = avm+, 0 == avm-)
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

						// now we read in the swd debugging map (which provides
						// local to global mappings of the script ids
						long num = msg.getDWord();
						Map<Long, Integer> local2global = new HashMap<Long, Integer>();
						int minId = Integer.MAX_VALUE;
						int maxId = Integer.MIN_VALUE;
						for(int j=0; j<num; j++)
						{
							long local = msg.getPtr();
							int global = (int) msg.getDWord();
							local2global.put(local, global);
							minId = (global < minId) ? global : minId;
							maxId = (global > maxId) ? global : maxId;
						}

						// If its a new record then the swf size would have been unknown at creation time
						boolean justCreated = (info.getSwfSize() == 0);

                        // if we are a avm+ engine then we don't wait for the swd to load
                        if (vmVersion > 0)
                        {
                            debugComing = false;
                            info.setVmVersion(vmVersion);
                            info.setPopulated(); // added by mmorearty on 9/5/05 for RSL debugging
                        }

						// update this swfinfo with the lastest data
						info.freshen(id, path, url, host, port, debugComing, swfSize, swdSize, breakpointCount, offsetCount, scriptCount, local2global, minId, maxId);
						// now tie any scripts that have been loaded into this swfinfo object
						tieScriptsToSwf(info);

						// notify if its newly created
						if (justCreated)
							addEvent(new SwfLoadedEvent(id, (int)index, path, url, host, port, swfSize));
					}
					else
					{
						// note our state before marking it
						boolean alreadyUnloaded = info.isUnloaded();

						// clear it out
						info.setUnloaded();

						// notify if this information is new.
						if (!alreadyUnloaded)
							addEvent(new SwfUnloadedEvent(info.getId(), info.getPath(), (int)index));
					}
//					System.out.println("[SWFLOAD] Loaded "+path+", size="+swfSize+", scripts="+scriptCount);
				}
				break;
			}

			// obtain the constant pool of some player
            case DMessage.InConstantPool:
            {
				int item = msg.getWord();
				int count = (int)msg.getDWord();

				String[] pool = new String[count];
				for(int i=0; i<count; i++)
				{
					long id = msg.getPtr();
					DVariable var = extractVariable(msg);

					// we only need the contents of the variable
					pool[i] = var.getValue().getValueAsString();
				}
				m_lastConstantPool = pool;
                break;
            }

            // obtain one or more function name line number mappings.
            case DMessage.InGetFncNames:
            {
                long id = msg.getDWord();    // module id
                long count = msg.getDWord(); // number of entries

                // get the DModule
                DModule m = getSource((int)id);
                if (m != null)
                {
                    for(int i=0; i<count; i++)
                    {
                        int offset = (int)msg.getDWord();
                        int firstLine = (int)msg.getDWord();
						int lastLine = (int)msg.getDWord();
                        String name = msg.getString();

                        // now add the entries
						m.addLineFunctionInfo(offset, firstLine, lastLine, name);
                    }
                }
                break;
            }

            case DMessage.InCallFunction:
            case DMessage.InBinaryOp:
            {
				// For InCallFunction the first element is the original function we requested
				DValue parent = null;
				DVariable child = null;
				String definingClass = null;
				int level = 0;
				int highestLevelWithMembers = -1;
				List<String> classes = new ArrayList<String>();

				if (type == DMessage.InBinaryOp)
					msg.getDWord(); // id

				while(msg.getRemaining() > 0)
				{
					long parentId = msg.getPtr();

					// build or get parent node
					if (parent == null)
					{
						String name = msg.getString();

						// pull the contents of the node which normally are disposed of except if we did a 0,name call
						DVariable var = extractVariable(msg, name);
						if (type == DMessage.InCallFunction)
							m_lastInCallFunction = var;
						else
							m_lastInBinaryOp = var;

						parent = getOrCreateValue(parentId);
					}
					else
					{
						// extract the child and add it to the parent.
						child = extractVariable(msg);
						if (showMember(child)) {
							if (child.isAttributeSet(VariableAttribute.IS_DYNAMIC)) {
								// Dynamic attributes always come in marked as a member of
								// class "Object"; but to the user, it makes more sense to
								// consider them as members of the topmost class.
								if (classes.size() > 0) {
									child.setDefiningClass(0, classes.get(0));
									highestLevelWithMembers = Math.max(highestLevelWithMembers, 0);
								}
							} else {
								child.setDefiningClass(level, definingClass);
								if (definingClass != null) {
									highestLevelWithMembers = Math.max(highestLevelWithMembers, level);
								}
							}
							addVariableMember(parent.getId(), child);
						} else {
							if (isTraits(child)) {
								definingClass = child.getQualifiedName();
								level = classes.size();

								// If the traits name end with "$", then it represents a class object --
								// in other words, the variables inside it are static variables of that
								// class.  In that case, we need to juggle the information.  For example,
								// if we are told that a variable is a member of "MyClass$", we actually
								// store it into the information for "MyClass".
								if (definingClass.endsWith("$")) { //$NON-NLS-1$
									String classWithoutDollar = definingClass.substring(0, definingClass.length() - 1);
									int indexOfClass = classes.indexOf(classWithoutDollar);
									if (indexOfClass != -1) {
										level = indexOfClass;
										definingClass = classWithoutDollar;
									}
								}

								// It wasn't static -- so, add this class to the end of the list of classes
								if (level == classes.size()) {
									classes.add(definingClass);
								}
							}
						}
					}
				}

				if (parent != null && parent.getClassHierarchy(true) == null) {
					parent.setClassHierarchy(classes.toArray(new String[classes.size()]), highestLevelWithMembers+1);
				}
            	
            	break;
            }

			default:
			{
				break;
			}
		}
	}

	/**
	 * Returns whether a given child member should be shown, or should be filtered out.
	 */
	private boolean showMember(DVariable child)
	{
		if (isTraits(child))
			return false;
		return true;
	}

	/**
	 * Returns whether this is not a variable at all, but is instead a representation
	 * of a "traits" object.  A "traits" object is the Flash player's way of describing
	 * one class.
	 */
	private boolean isTraits(DVariable variable) {
		Value value = variable.getValue();
		if (value.getType() == VariableType.UNKNOWN && Value.TRAITS_TYPE_NAME.equals(value.getTypeName())) {
			return true;
		}
		return false;
	}

	/**
	 * Here's where some ugly stuff happens. Since our context contains
	 * more info than what's contained within the stackcontext, we
	 * augment it  with the variables.  Also, we build up a
	 * list of variables that appears under root, that can be
	 * accessed without further qualification; this includes args,
	 * locals and _global.
	 */
	void populateRootNode(DValue frame, ArrayList<DVariable> orderedChildList)
	{
		// first populate the stack node with children
		populateFrame(0, orderedChildList);

		/**
		 * We mark it as members obtained so that we don't go to the player
		 * and request it, which would be bad, since its our artifical creation.
		 */
		DValue base = getOrCreateValue(Value.BASE_ID);
		base.setMembersObtained(true);

		/**
		 * Technically, we don't need to create the following nodes, but
		 * we like to give them nice type names
		 */

		 // now let's create a _global node and attach it to base
	}

	/**
	 * We are done, so let's look for a number of special variables, since our
	 * frame comes in 3 pieces.  First off is a "this" pointer, followed
	 * by a "$arguments" dummy node, followed by a "super" which marks
	 * the end of the arguments.
	 *
	 * All of this stuff gets pulled apart after we build the frame node.
	 */
	void populateFrame(int depth, ArrayList<DVariable> frameVars)
	{
		// get our stack context
		DStackContext context = null;
		boolean inArgs = false;
		int nArgs = -1;
		boolean inScopeChain = false;

		// create a root node for each stack frame; first is at BASE_ID
		DValue root = getOrCreateValue(Value.BASE_ID-depth);

		if (depth < getFrameCount())
			context = getFrame(depth);

		// trim all current args from this context
		if (context != null)
			context.removeAllVariables();

		// use the ordered child list
		Iterator<DVariable> e = frameVars.iterator();
		while(e.hasNext())
		{
			DVariable v = e.next();
			String name = v.getName();

			// let's clear a couple of attributes that may get in our way
			v.clearAttribute(VariableAttribute.IS_LOCAL);
			v.clearAttribute(VariableAttribute.IS_ARGUMENT);
			if (name.equals("this")) //$NON-NLS-1$
			{
				if (context != null)
					context.setThis(v);

				// from our current frame, put a pseudo this entry into the cache and hang it off base, mark it as an implied arg
				v.setAttribute(VariableAttribute.IS_ARGUMENT);
				addVariableMember(root, v);

				// also add this variable under THIS_ID
				if (depth == 0)
					putValue(Value.THIS_ID, (DValue) v.getValue());
			}
			else if (name.equals("super")) //$NON-NLS-1$
			{
				// we are at the end of the arg list and let's make super part of global
				inArgs = false;
			}
			else if (name.equals(ARGUMENTS_MARKER))
			{
				inArgs = true;

				// see if we can extract an arg count from this variable
				try { nArgs = ((Number)(v.getValue().getValueAsObject())).intValue(); } catch(NumberFormatException nfe){}
			}
			else if (name.equals(SCOPE_CHAIN_MARKER))
			{
				inArgs = false;
				inScopeChain = true;
			}
			else
			{
				// add it to our root, marking it as an arg if we know, otherwise local
				if (inArgs)
				{
					v.setAttribute(VariableAttribute.IS_ARGUMENT);

					if (context != null)
						context.addArgument(v);

					// decrement arg count if we have it
					if (nArgs > -1)
					{
						if (--nArgs <= 0)
							inArgs = false;
					}
				}
				else if (inScopeChain)
				{
					if (context != null)
						context.addScopeChainEntry(v);
				}
				else
				{
					v.setAttribute(VariableAttribute.IS_LOCAL);
					if (context != null)
						context.addLocal(v);
				}

				// add locals and arguments to root
				if (!inScopeChain)
					addVariableMember(root, v);
			}
		}
	}

	/**
	 * Map DMessage / Player attributes to VariableAttributes
	 */
	int toAttributes(int pAttr)
	{
		int attr = pAttr;  /* 1-1 mapping */
		return attr;
	}

	DVariable extractVariable(DMessage msg)
	{
		DVariable v = extractVariable(msg, msg.getString());
		return v;
	}

	/**
	 * Build a variable based on the information we can extract from the messsage
	 */
	DVariable extractVariable(DMessage msg, String name)
	{
		int oType = msg.getWord();
		int flags = (int) msg.getDWord();
		return extractAtom(msg, name, oType, flags);
	}

	/**
	 * Extracts an builds a register variable
	 */
	DVariable extractRegister(DMessage msg, int number)
	{
		int oType = msg.getWord();
		return extractAtom(msg, "$"+number, oType, 0); //$NON-NLS-1$
	}

	/**
	 * Does the job of pulling together a variable based on
	 * the type of object encountered.
	 */
	DVariable extractAtom(DMessage msg, String name, int oType, int flags)
	{
		int vType = VariableType.UNKNOWN;
		Object value = null;
		String typeName = ""; //$NON-NLS-1$
		String className = ""; //$NON-NLS-1$
		boolean isPrimitive = false;

		/* now we vary depending upon type */
		switch(oType)
		{
			case DMessage.kNumberType:
			{
				String s = msg.getString();
				double dval = Double.NaN;
				try
				{
					dval = Double.parseDouble(s);
				}
				catch(NumberFormatException nfe) {}

				value = new Double(dval);
				isPrimitive = true;
				break;
			}

			case DMessage.kBooleanType:
			{
				int bval = msg.getByte();
				value = new Boolean ( (bval == 0) ? false : true );
				isPrimitive = true;
				break;
			}

            case DMessage.kStringType:
            {
                String s = msg.getString();

                value = s;
                isPrimitive = true;
                break;
            }

			case DMessage.kObjectType:
			case DMessage.kNamespaceType:
			{
				long oid = msg.getPtr();
				long cType = (oid == -1) ? 0  : msg.getDWord();
				int isFnc =  (oid == -1) ? 0  : msg.getWord();
				int rsvd =   (oid == -1) ? 0  : msg.getWord();
				typeName =   (oid == -1) ? "" : msg.getString(); //$NON-NLS-1$
				className = DVariable.classNameFor(cType, false);

				value = new Long(oid);
				vType = (isFnc == 0) ? VariableType.OBJECT : VariableType.FUNCTION;
				break;
			}

			case DMessage.kMovieClipType:
			{
				long oid = msg.getPtr();
				long cType = (oid == -1) ? 0  : msg.getDWord();
				long rsvd =  (oid == -1) ? 0  : msg.getDWord();
				typeName =   (oid == -1) ? "" : msg.getString(); //$NON-NLS-1$
				className = DVariable.classNameFor(cType, true);

				value = new Long(oid);
				vType = VariableType.MOVIECLIP;
				break;
			}

            case DMessage.kNullType:
            {
            	value = null;
            	isPrimitive = true;
                break;
            }

            case DMessage.kUndefinedType:
            {
            	value = Value.UNDEFINED;
            	isPrimitive = true;
                break;
            }

            case DMessage.kTraitsType:
            {
            	// This one is special: When passed to the debugger, it indicates
				// that the "variable" is not a variable at all, but rather is a
				// class name.  For example, if class Y extends class X, then
				// we will send a kDTypeTraits for class Y; then we'll send all the
				// members of class Y; then we'll send a kDTypeTraits for class X;
				// and then we'll send all the members of class X.  This is only
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
			default:
			{
//				System.out.println("<unknown>");
				break;
			}
		}

		// create the variable based on the content we received.
		DValue valueObject = null;

		// If value is a Long, then it is the ID of a non-primitive object;
		// look up to see if we already have that object in our cache.  If
		// it is already in our cache, then we just want to modify the
		// existing object with the new values.
		if (value instanceof Long)
		{
			valueObject = getValue(((Long)value).longValue());
		}

		if (valueObject == null)
		{
			// we didn't find it in the cache, so make a new Value

			if (isPrimitive)
			{
				valueObject = DValue.forPrimitive(value);
				valueObject.setAttributes(toAttributes(flags));
			}
			else
			{
				valueObject = new DValue(vType, typeName, className, toAttributes(flags), value);
			}

			if (value instanceof Long && (toAttributes(flags) & VariableAttribute.HAS_GETTER) == 0)
				putValue(((Long)value).longValue(), valueObject);
		}
		else
		{
			// we found it in the cache, so just modify the properties
			// of the old Value

			if (isPrimitive)
			{
				// figure out some of the properties
				DValue temp = DValue.forPrimitive(value);
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

		DVariable var = new DVariable(name, valueObject);
		return var;
	}

	/**
	 * The player sends us a URI using '|' instead of ':'
	 */
	public static String convertToURI(String playerURL)
	{
		int index = playerURL.indexOf('|');
		StringBuilder sb = new StringBuilder(playerURL);
		while(index > 0)
		{
			sb.setCharAt(index, ':');
			index = playerURL.indexOf('|', index+1);
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
	public void beginPlayerCodeExecution()
	{
		m_executingPlayerCode = true;
		m_faultEventDuringPlayerCodeExecution = null;
	}

	/**
	 * Informs us that user code is no longer executing, and returns the fault,
	 * if any, which occurred while the code was executing.
	 */
	public FaultEvent endPlayerCodeExecution()
	{
		m_executingPlayerCode = false;
		FaultEvent e = m_faultEventDuringPlayerCodeExecution;
		m_faultEventDuringPlayerCodeExecution = null;
		return e;
	}

	/**
	 * When we've just received any FaultEvent from the player, this
	 * function gets called.  If a getter/setter is currently executing,
	 * we'll save the fault for someone to get later by calling
	 * endGetterSetter().  Otherwise, normal code execution is taking
	 * place, so we'll add the event to the event queue.
	 */
	private void handleFaultEvent(FaultEvent faultEvent)
	{
		if (m_executingPlayerCode)
		{
			if (m_faultEventDuringPlayerCodeExecution == null) // only save the first fault
			{
				// save the event away so that when someone later calls
				// endGetterSetter(), we can return the fault that
				// occurred
				m_faultEventDuringPlayerCodeExecution = faultEvent;
			}
		}
		else
		{
			// regular code is running; so post the event to the
			// event queue which the client debugger will see
			addEvent(faultEvent);
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.SourceLocator#locateSource(java.lang.String, java.lang.String, java.lang.String)
	 */
	public InputStream locateSource(String path, String pkg, String name)
	{
		if (m_sourceLocator != null)
			return m_sourceLocator.locateSource(path, pkg, name);

		return null;
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.SourceLocator#getChangeCount()
	 */
	public int getChangeCount()
	{
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
	public String getOption(String optionName)
	{
		return m_options.get(optionName);
	}
}
