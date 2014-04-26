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

import java.util.HashMap;
import java.util.Map;

import flash.tools.debugger.Isolate;

/**
 * This class can be to count the number of messages
 * received during a debug session.
 *
 */
public class DMessageCounter implements DProtocolNotifierIF
{
	long[] m_inCounts;
	long[] m_outCounts;
	long m_lastIsolate;
	Object m_isolateLock;
	boolean m_isolate;
	
	Map<Long, DMessageCounter> m_isolateCounterMap;

	public DMessageCounter()
	{
		m_inCounts = new long[DMessage.InSIZE+1];
		m_outCounts = new long[DMessage.OutSIZE+1];
		m_lastIsolate = 1;
		m_isolateCounterMap = new HashMap<Long, DMessageCounter>();
		m_isolateLock = new Object();
		clearArray(m_inCounts);
		clearArray(m_outCounts);
	}

	public void disconnected()
	{
		// We're being notified (via the DProtocolNotifierIF interface) that
		// the socket connection has been broken.  If anyone is waiting for
		// a message to come in, they ain't gonna get one.  So, we'll notify()
		// them so that they can wake up and realize that the connection has
		// been broken.
		Object inLock = getInLock();
		synchronized (inLock) { inLock.notifyAll(); }
		Object outLock = getOutLock();
		synchronized (outLock) { outLock.notifyAll(); }
	}

	/**
	 * Returns the object on which external code can call "wait" in order
	 * to block until a message is received.
	 */
	public Object getInLock() { return m_inCounts; }

	/**
	 * Returns the object on which external code can call "wait" in order
	 * to block until a message is sent.
	 */
	public Object getOutLock() { return m_outCounts; }
	
	/**
	 * Collect stats on outgoing messages 
	 */
	public void messageSent(DMessage msg)
	{
	    int type = msg.getType();
		if (type < 0 || type >=DMessage.OutSIZE)
			type = DMessage.OutSIZE;
		long targetIsolate = msg.getTargetIsolate();
		Object outLock = getOutLock();
		if (!m_isolate) {
			synchronized (m_isolateLock) {
				if (m_lastIsolate != Isolate.DEFAULT_ID) {
					DMessageCounter counter = m_isolateCounterMap.get(m_lastIsolate);
					outLock = counter.getOutLock();
				}
			}
		}
		synchronized (outLock) {
			
			if (!m_isolate && targetIsolate != Isolate.DEFAULT_ID) {
//				if (m_isolateCounterMap.containsKey(targetIsolate)) {
					DMessageCounter counter = m_isolateCounterMap.get(targetIsolate);				
					counter.messageSent(msg);
					m_outCounts[type] += 1;
					outLock.notifyAll(); // tell anyone who is waiting that a message has been sent
					//counter.getOutLock().notifyAll();
//				}
//				else {
//					System.out.println("No counter for worker " + targetIsolate);
//					m_outCounts[type] += 1;
//					outLock.notifyAll(); // tell anyone who is waiting that a message has been sent
//				}
			}
			else {
				m_outCounts[type] += 1;
				outLock.notifyAll(); // tell anyone who is waiting that a message has been sent
			}
		}
	}
	
	public void setIsolate(boolean value) {
		m_isolate = value;
	}

	/** 
	 * Collect stats on the messages 
	 */
	public void messageArrived(DMessage msg, DProtocol which)
	{
		/* extract type */
		int type = msg.getType();

//		System.out.println("msg counter ="+type);

		/* anything we don't know about goes in a special slot at the end of the array. */
		if (type < 0 || type >= DMessage.InSIZE)
			type = DMessage.InSIZE;
		Object inLock = getInLock();
		if (!m_isolate) {
			synchronized (m_isolateLock) {
				if (m_lastIsolate != Isolate.DEFAULT_ID) {
					DMessageCounter counter = m_isolateCounterMap.get(m_lastIsolate);
					inLock = counter.getInLock();
				}
			}
		}
		
		synchronized (inLock) {
			if (type == DMessage.InIsolate) {
				long isolate = msg.getDWord();				
				if (isolate != Isolate.DEFAULT_ID) {
					/** Check if our map has a counter for this isolate */
					if (!m_isolateCounterMap.containsKey(isolate)) {
						DMessageCounter isolateCounter = new DMessageCounter();
						isolateCounter.setIsolate(true);
						m_isolateCounterMap.put(isolate, isolateCounter);
					}
				}
				synchronized (m_isolateLock) {
					m_lastIsolate = isolate;
				}
				m_inCounts[type] += 1;
				inLock.notifyAll(); // tell anyone who is waiting that a message has been received
			}
			else if (!m_isolate && m_lastIsolate != Isolate.DEFAULT_ID) {
				DMessageCounter counter = m_isolateCounterMap.get(m_lastIsolate);
				counter.messageArrived(msg, which);
				synchronized (counter.getInLock()) {
					counter.getInLock().notifyAll();
				}
				
			}
			else {
				m_inCounts[type] += 1;
				inLock.notifyAll(); // tell anyone who is waiting that a message has been received
			}
		}
	}

	/* getters */
	public long   getInCount(int type)  { synchronized (getInLock()) { return m_inCounts[type]; } }
	public long   getOutCount(int type) { synchronized (getOutLock()) { return m_outCounts[type]; } }
	
	public long   getIsolateInCount(long isolate, int type)  { 
		DMessageCounter counter = m_isolateCounterMap.get(isolate);
		return counter.getInCount(type); 
	}

	public long getIsolateOutCount(long isolate, int type) { 
		DMessageCounter counter = m_isolateCounterMap.get(isolate);
		return counter.getOutCount(type); 
	}

	public Object getIsolateInLock(long isolate)  { 
		DMessageCounter counter = m_isolateCounterMap.get(isolate);
		return counter.getInLock(); 
	}


	/* setters */
	public void clearInCounts()			{ synchronized (getInLock()) { clearArray(m_inCounts); } }
	public void clearOutCounts()		{ synchronized (getOutLock()) { clearArray(m_outCounts); } }

	/**
	 * Clear out the array 
	 */
	void clearArray(long[] ar)
	{
		for(int i=0; i<ar.length; i++)
			ar[i] = 0;
	}
}
