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
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringWriter;

import flash.tools.debugger.AlreadyActiveApplicationException;
import flash.tools.debugger.CommandLineException;
import flash.tools.debugger.ILaunchNotification;

/**
 * Listens to several things about a process: captures its stdout/stderr messages,
 * detects when the process exits, and captures its exit code.
 * <p>
 * When a process exits, the ProcessListener can send out a notification.  If
 * you want that to happen, call startLaunchNotifier().
 */
public class ProcessListener
{
	private Process					m_process;
	private ILaunchNotification		m_launchNotification;
	private boolean					m_isDebugging;
	private boolean					m_isAIRapp;
	private final String[]			m_launchCommand;
	private StringWriter			m_processMessages;

	/**
	 * A background thread that will wait until the process terminates, and then
	 * call the launch listener.
	 */
	private Thread m_launchNotifierThread = new Thread("DJAPI ProcessListener") //$NON-NLS-1$
	{
		@Override
		public void run()
		{
			try
			{
				m_process.waitFor();

				IOException e = null;
				if (getProcessExitValue() != 0)
					e = createLaunchFailureException();
				m_launchNotification.notify(e);
			}
			catch (InterruptedException e)
			{
				// this will happen if anyone calls Thread.interrupt()
			}
		}
	};
	private boolean m_isRunLaunch;

	/**
	 * Starts listening to stdout and stderr of the launched process.  The caller
	 * can later call getProcessMessages() to capture that output.
	 */
	public ProcessListener(String[] launchCommand, Process process, ILaunchNotification launchNotification, boolean forDebugging, boolean isAIRapp)
	{
		m_launchCommand = launchCommand;
		m_process = process;
		m_launchNotification = launchNotification;
		m_isDebugging = forDebugging;
		m_isAIRapp = isAIRapp;
		m_processMessages = new StringWriter();
		startMessageListener();
	}

	private void startMessageListener()
	{
		new StreamListener(new InputStreamReader(m_process.getInputStream()), m_processMessages).start();
		new StreamListener(new InputStreamReader(m_process.getErrorStream()), m_processMessages).start();
		try
		{
			OutputStream stm = m_process.getOutputStream();
			if (stm != null)
				stm.close();
		}
		catch (IOException e)
		{
			/* not serious; ignore */
		}
	}

	/**
	 * Creates a background thread that will call the launch notifier when the
	 * process terminates.
	 */
	public void startLaunchNotifier()
	{
		if (m_launchNotification == null)
			throw new NullPointerException();

		m_launchNotifierThread.setDaemon(true);
		m_launchNotifierThread.start();
	}

	/**
	 * Returns the command args that were used to launch the process.
	 */
	public String[] getLaunchCommand()
	{
		return m_launchCommand;
	}

	public boolean isAIRApp()
	{
		return m_isAIRapp;
	}

	public boolean isProcessDead()
	{
		// If the process is still alive, then exitValue() will throw an exception:
		try {
			m_process.exitValue();
			return true;
		} catch (IllegalThreadStateException e) {
			return false;
		}
	}

	public int getProcessExitValue() throws IllegalThreadStateException
	{
		return m_process.exitValue();
	}

	/**
	 * Returns all messages that were sent to stdout and stderr by the process,
	 * combined into one string.
	 */
	public String getProcessMessages()
	{
		return m_processMessages.toString();
	}

	/**
	 * Creates an exception indicating that the process terminated with some sort
	 * of error.  The returned exception may be an AlreadyActiveApplicationException
	 * or a CommandLineException.
	 */
	public IOException createLaunchFailureException()
	{
		IOException e = null;
		String detailMessage;

		if (m_isDebugging)
		{
			detailMessage = PlayerSessionManager.getLocalizationManager().getLocalizedTextString(
					"processTerminatedWithoutDebuggerConnection"); //$NON-NLS-1$
		}
		else
		{
			detailMessage = PlayerSessionManager.getLocalizationManager().getLocalizedTextString(
					"processTerminatedUnexpectedly"); //$NON-NLS-1$
		}

		// You can only call this function if the process has terminated
		if (!isProcessDead())
		{
			throw new IllegalThreadStateException();
		}

		/*
		 * When adding auto-terminate for run launch, we notice that on clicking the 
		 * terminate button, the process exits with exitValue = 1 (due to unexpected
		 * termination). We just ignore this error message.
		 * Since we anyways now allow exitValue = 1(previously for app already running)
		 * for run launch, we shall skip displaying the message.
		 */
		
		int exitValue = getProcessExitValue();
		
		if (m_isAIRapp && exitValue == 1)         //ADL Exit Code: Successful invocation of an already running AIR application. ADL exits immediately.
		{
			if(!m_isRunLaunch) {
				e = new AlreadyActiveApplicationException(detailMessage, m_isDebugging);
			}
		}
		else
		{
			e = new CommandLineException(detailMessage, getLaunchCommand(), getProcessMessages(), exitValue);
		}	

		return e;
	}

	public void setIsRunLaunch(boolean forRunLaunching) {
		m_isRunLaunch = forRunLaunching;
	}
}
