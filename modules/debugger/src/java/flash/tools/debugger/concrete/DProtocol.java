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

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InterruptedIOException;
import java.net.Socket;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.EnumMap;

import flash.tools.debugger.SessionManager;
import flash.util.Trace;

/**
 * Implements the lower portion of Flash Player debug protocol.  This class is able to
 * communicate with the Flash Player sending and receiving any and all messages neccessary
 * in order to continue a debug session with the Player.
 * 
 * It does not understand the context of messages that it receives and merely provides
 * a channel for formatting and unformatting the messages.
 *  
 * The messages are defined on the flash side in core/debugtags.h and handled in the 
 * code under core/playerdebugger.cpp
 * 
 * Messages that are received via this class are packaged in a DMessage and then
 * provided to any listeners if requested.   Filtering of incoming messages 
 * at this level is not supported.
 */
public class DProtocol implements Runnable
{
	public static final int DEBUG_PORT = 7935;
	
	/* We connect to AIR in the case of AIR on Android over USB */
	public static final int DEBUG_CONNECT_PORT = 7936;

	private final BufferedInputStream	m_in;
	private final BufferedOutputStream	m_out;
	private final EnumMap<ListenerIndex, DProtocolNotifierIF> m_listeners; // WARNING: accessed from multiple threads
	private long						m_msgRx;		// WARNING: accessed from multiple threads; use synchronized (this)
	private long						m_msgTx;		// WARNING: accessed from multiple threads; use synchronized (this)
	private volatile boolean			m_stopRx;		// WARNING: accessed from multiple threads
	private volatile Thread				m_rxThread;		// WARNING: accessed from multiple threads
	private volatile Exception m_disconnectCause;
	private volatile Socket m_socket;
	private boolean m_detectBrokenSocket;

	public enum ListenerIndex
	{
		PlayerSession,

		/**
		 * The DMessageCounter must always be the LAST listener, so that the message has
		 * been fully processed before we wake up any threads that were waiting until a
		 * message comes in.
		 */
		MessageCounter
	}

	public DProtocol(BufferedInputStream in, BufferedOutputStream out)
	{
		m_in = in;
		m_out = out;
		m_listeners = new EnumMap<ListenerIndex, DProtocolNotifierIF>(ListenerIndex.class);
		m_msgRx = 0;
		m_msgTx = 0;
		m_stopRx = false;
		m_rxThread = null;
		m_socket = null;
		m_detectBrokenSocket = false;
		// Create a message counter, which will listen to us for messages
		addListener(ListenerIndex.MessageCounter, new DMessageCounter());
	}
	
	public DProtocol(BufferedInputStream in, BufferedOutputStream out, 
			Socket s, boolean detectBrokenSocket)
	{
		this(in, out);
		m_socket = s;
		m_detectBrokenSocket = detectBrokenSocket;
	}
	
	/**
	 * Set the base socket options
	 * @throws SocketException
	 */
	static void applyBaseSocketSettings(Socket s) throws SocketException 
	{
		// For performance reasons, it is very important that we setTcpNoDelay(true),
		// thus disabling Nagle's algorithm.  Google for TCP_NODELAY or Nagle
		// for more information.
		//
		// In addition, we now use a BufferedOutputStream instead of an OutputStream.
		//
		// These changes result in a huge speedup on the Mac.
		s.setTcpNoDelay(true);		
	}
	
	static DProtocol createDProtocolFromSocket(Socket s, boolean detectBrokenSocket) throws IOException
	{
		BufferedInputStream in = new BufferedInputStream(s.getInputStream());
		BufferedOutputStream out = new BufferedOutputStream(s.getOutputStream());

		DProtocol dp = new DProtocol(in, out, s, detectBrokenSocket);
		return dp;
	}

	/**
     * Build a DProtocol object from a the given socket connection.
     */
	static DProtocol createFromSocket(Socket s) throws IOException
	{
		applyBaseSocketSettings(s);
		return createDProtocolFromSocket(s, false);
	}
	
	/**
     * Build a DProtocol object from a the given socket connection
     * and applies socket specific settings set in SessionManager
     * like socket timeout.
     */
	static DProtocol createFromSocket(Socket s, SessionManager sessionManager) throws IOException
	{
		applyBaseSocketSettings(s);
		int socketTimeout = sessionManager.getPreference(SessionManager.PREF_SOCKET_TIMEOUT);
		boolean checkSocket = false;
		if (socketTimeout > 0)
		{
			s.setSoTimeout(socketTimeout);
			checkSocket = true;
		}
		return createDProtocolFromSocket(s, checkSocket);
	}

	/**
	 * Allow outside entities to listen for incoming DMessages.
	 * 
	 * @param index
	 *            the index of this listener. Listeners have a strictly defined
	 *            order.
	 * @param n
	 *            the listener
	 */
	public boolean addListener(ListenerIndex index, DProtocolNotifierIF n)
	{
		synchronized (m_listeners)
		{
			m_listeners.put(index, n);
		}
		return true;
	}

	public long messagesReceived()		{ synchronized (this) { return m_msgRx; } }
	public long messagesSent()			{ synchronized (this) { return m_msgTx; } }

	/**
	 * Entry point for our receive thread 
	 */
	public void run()
	{
		try
		{
			m_stopRx = false;
			listenForMessages();
		}
		catch(Exception ex) 
		{  
			m_disconnectCause = ex;
			if (Trace.error &&
				!(ex instanceof SocketException && ex.getMessage().equalsIgnoreCase("socket closed"))) // closed-socket is not an error //$NON-NLS-1$
			{
				ex.printStackTrace();
			}
		}

		/* notify our listeners that we are no longer listening;  game over */
		DProtocolNotifierIF[] listeners;
		synchronized (m_listeners)
		{
			listeners = m_listeners.values().toArray(new DProtocolNotifierIF[m_listeners.size()]); // copy the list to avoid multithreading problems
		}
		for (int i=0; i<listeners.length; ++i)
		{
			DProtocolNotifierIF elem = listeners[i];
			try
			{
				elem.disconnected();
			}
			catch(Exception exc) /* catch unchecked exceptions */
			{
				if (Trace.error)
					exc.printStackTrace();
			}
		}

		// final notice that this thread is dead! 
		m_rxThread = null;
		m_socket = null;
	}

	/** 
	 * Create and start up a thread for our receiving messages.  
	 */
	public boolean bind()
	{
		/* create a new thread object for us which just listens to incoming messages */
		boolean worked = true;
		if (m_rxThread == null)
		{
			getMessageCounter().clearInCounts();
			getMessageCounter().clearOutCounts();

			m_rxThread = new Thread(this, "DJAPI message listener"); //$NON-NLS-1$
			m_rxThread.setDaemon(true);
			m_rxThread.start();
		}
		else
			worked = false;

		return worked;
	}

	/**
	 * Shutdown our receive thread 
	 */
	public boolean unbind()
	{
		boolean worked = true;
		if (m_rxThread == null)
			worked = false;
		else
			m_stopRx = true;

		return worked;
	}

	/**
	 * Main rx loop which waits for commands and then issues them to anyone listening.
     */
	void listenForMessages() throws IOException
	{
		DProtocolNotifierIF[] listeners = new DProtocolNotifierIF[0];

		while(!m_stopRx)
		{
			/* read the data */
			try
			{
				DMessage msg = rxMessage();

				/* Now traverse our list of interested parties and let them deal with the message */
				synchronized (m_listeners)
				{
					listeners = m_listeners.values().toArray(listeners); // copy the array to avoid multithreading problems
				}
				for (int i=0; i<listeners.length; ++i)
				{
					DProtocolNotifierIF elem = listeners[i];
					try
					{
						elem.messageArrived(msg, this);
					}
					catch (Exception exc) /* catch unchecked exceptions */
					{
						if (Trace.error) 
						{
							System.err.println("Error in listener parsing incoming message :"); //$NON-NLS-1$
							System.err.println(msg.inToString(16));
							exc.printStackTrace(); 
						}
					}
					msg.reset();  /* allow others to reparse the message */
				}

				/* now dispose with the message */
				DMessageCache.free(msg);
			}
			catch(InterruptedIOException iio)
			{ 
				// this is a healthy exception that we simply ignore, since it means we haven't seen
				// data for a while; is all.
			}
		}
	}

	/**
	 * Transmit the message down the socket.
	 * 
	 * This function is not synchronized; it is only called from one place, which is
	 * PlayerSession.sendMessage().  That function is synchronized.
	 */
	void txMessage(DMessage message) throws IOException
	{
		int size = message.getSize();
		int command = message.getType();

        //System.out.println("txMessage: " + DMessage.outTypeName(command) + " size=" + size);

        writeDWord(size);
		writeDWord(command);
		writeData(message.getData(), size);

		m_out.flush();
		synchronized (this) { m_msgTx++; }
		getMessageCounter().messageSent(message);
	}

	class SendThread extends Thread {
		public IOException exception = null;
		public volatile boolean completed = false;
		
		@Override
		public void run() {
			try {
				DMessage dm = DMessageCache.alloc(4);
				dm.setType(DMessage.OutSetSquelch);
				dm.putDWord(1);
				txMessage(dm);
				DMessageCache.free(dm);
				this.completed = true;
			}
			catch (IOException e) {
				this.exception = e;
			}
		}
	}
	/** 
     * Get the next message on the input stream, using the context contained within 
     * the message itself to demark its end
     */
	private DMessage rxMessage() throws IOException
	{
        int size = -1;
		int command = 0;

		try 
		{
			size = (int)readDWord();
			command = (int)readDWord();
		}
		catch (SocketTimeoutException e) 
		{
			if (!m_detectBrokenSocket)
				throw e;
			//schedule a simple message to be sent for
			//heartbeat check 
			/**
			 * Our logic kicks in after PREF_SOCKET_TIMEOUT 
			 * milliseconds to try and detect broken connection by writing 
			 * a squelch message to the player. If the write 
			 * succeeds, we assume everything is normal 
			 * (we don't wait for an ack). Otherwise, we save the error
			 * that clients of FDB can use.
			 * 
			 * On Mac, the write() blocks which is why it must
			 * be done in a separate thread. The thread may take
			 * upto five minutes to die even after interrupt().
			 * 
			 * On Windows, the write() succeeds, but we later get
			 * a recv abort.
			 */
			int oldBufferSize = -1;
			
			if (m_socket != null) {
				oldBufferSize = m_socket.getSendBufferSize();
				m_socket.setSendBufferSize(1);				
			}
			
			SendThread t = new SendThread();
			t.start();
			long waitBegin = System.currentTimeMillis();
			
			while (true) {
				try {
					t.join(1000);
					if (t.completed)
						break;
				} catch (InterruptedException e1) {
					break;
				}
				long waitEnd = System.currentTimeMillis();
				if (waitEnd - waitBegin > 10000)
					break;
			}
			boolean success = true;
			if (t.isAlive()) {
				t.interrupt();
				success = false;
			}
			if (oldBufferSize > 0) {
				m_socket.setSendBufferSize(oldBufferSize);
			}
			if (!t.completed) {
				success = false;
			}
			if (t.exception != null) {
				throw t.exception;
			}
			if (success)
				throw e;
			else
				throw new SocketException("Broken pipe"); //$NON-NLS-1$
		}
        //System.out.println("rxMessage: " + DMessage.inTypeName(command) + " size=" + size);

		if (size < 0)
			throw new IOException("socket closed"); //$NON-NLS-1$

		/** 
		 * Ask our message cache for a message
		 */
		DMessage message = DMessageCache.alloc(size);
		byte[] messageContent = message.getData();
		int offset = 0;

		/* block until we get the entire message, which may come in pieces */
		while (offset < size)
			offset += m_in.read(messageContent, offset, size - offset);

		/* now we have the data of the message, set its type and we are done */
		message.setType(command);
		synchronized (this) { m_msgRx++; }
		return message;
	}

	void writeDWord(long dw) throws IOException
	{
		byte b0 = (byte)(dw & 0xff);
		byte b1 = (byte)((dw >> 8) & 0xff);
		byte b2 = (byte)((dw >> 16) & 0xff);
		byte b3 = (byte)((dw >> 24) & 0xff);

		m_out.write(b0);
		m_out.write(b1);
		m_out.write(b2);
		m_out.write(b3);
	}

	void writeData(byte[] data, long size) throws IOException
	{
		if (size > 0)
			m_out.write(data, 0, (int)size);
	}


	/**
	 * Extract the next 4 bytes, which form a 32b integer, from the stream
	 */
	long readDWord() throws IOException
	{
		int b0 = m_in.read();
		int b1 = m_in.read();
		int b2 = m_in.read();
		int b3 = m_in.read();
		
		long value = ((b3 << 24) & 0xff000000) | ((b2 << 16) & 0xff0000) | ((b1 << 8) & 0xff00) | (b0 & 0xff);
		return value;
	}

	public DMessageCounter getMessageCounter()
	{
		synchronized (m_listeners)
		{
			return (DMessageCounter) m_listeners.get(ListenerIndex.MessageCounter);
		}
	}

	public Exception getDisconnectCause() {
		return m_disconnectCause;
	}
	
}
