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
 * Represents an error that occurred while invoking a command-line
 * program.  Saves the text error message that was reported
 * by the command-line program.
 * 
 * @author mmorearty
 */
public class CommandLineException extends IOException
{
	private static final long serialVersionUID = -5696392627123516956L;
    
    private String[] m_commandLine;
	private String m_commandOutput;
	private int m_exitValue;

	/**
	 * @param detailMessage
	 *            the detail message, e.g. "Program failed" or whatever
	 * @param commandLine
	 *            the command and arguments that were executed, e.g.
	 *            <code>{ "ls", "-l" }</code>
	 * @param commandOutput
	 *            the text error message that was reported by the command-line
	 *            program. It is common for this message to be more than one
	 *            line.
	 * @param exitValue
	 *            the exit value that was returned by the command-line program.
	 */
	public CommandLineException(String detailMessage, String[] commandLine, String commandOutput, int exitValue)
	{
		super(detailMessage);

		m_commandLine = commandLine;
		m_commandOutput = commandOutput;
		m_exitValue = exitValue;
	}

	public String[] getCommandLine()
	{
		return m_commandLine;
	}

	/**
	 * @return command line message, often multi-line, never <code>null</code>
	 */
	public String getCommandOutput()
	{
		return m_commandOutput;
	}

	/**
	 * @return the exit value that was returned by the command-line program.
	 */
	public int getExitValue()
	{
		return m_exitValue;
	}
}
