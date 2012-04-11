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

package flex2.tools.oem.internal;

import flex2.compiler.util.ConsoleLogger;
import flex2.tools.oem.Logger;
import flex2.tools.oem.Message;

/**
 * An OEM API logger implementation that outputs using System.err and
 * System.out.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class OEMConsole extends ConsoleLogger implements Logger
{
	public OEMConsole()
	{
		super();
	}

	public void log(Message message, int errorCode, String source)
	{
		String level = message.getLevel();
		String path = message.getPath();
		int line = message.getLine();
		int col = message.getColumn();
		String text = message.toString();
		
		if (Message.INFO.equals(level))
		{
			if (path == null)
			{
				if (line == -1)
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
					}
				}
				else
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(text);
							}
							else
							{
								super.logInfo(text);
							}
						}
					}
				}
			}
			else
			{
				if (line == -1)
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(path, text);
							}
							else
							{
								super.logInfo(path, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(path, text);
							}
							else
							{
								super.logInfo(path, text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(path, text);
							}
							else
							{
								super.logInfo(path, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(path, text);
							}
							else
							{
								super.logInfo(path, text);
							}
						}
					}
				}
				else
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(path, line, text);
							}
							else
							{
								super.logInfo(path, line, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(path, line, text);
							}
							else
							{
								super.logInfo(path, line, text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logInfo(path, line, col, text);
							}
							else
							{
								super.logInfo(path, line, col, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logInfo(path, line, col, text);
							}
							else
							{
								super.logInfo(path, line, col, text);
							}
						}
					}
				}
			}
		}
		else if (Message.WARNING.equals(level))
		{
			if (path == null)
			{
				if (line == -1)
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
					}
				}
				else
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(text);
							}
							else
							{
								super.logWarning(text);
							}
						}
					}
				}
			}
			else
			{
				if (line == -1)
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(path, text);
							}
							else
							{
								super.logWarning(path, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(path, text, errorCode);
							}
							else
							{
								super.logWarning(path, text, errorCode);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(path, text);
							}
							else
							{
								super.logWarning(path, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(path, text, errorCode);
							}
							else
							{
								super.logWarning(path, text, errorCode);
							}
						}
					}
				}
				else
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(path, line, text);
							}
							else
							{
								super.logWarning(path, line, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(path, line, text, errorCode);
							}
							else
							{
								super.logWarning(path, line, text, errorCode);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logWarning(path, line, col, text);
							}
							else
							{
								super.logWarning(path, line, col, text, source);
							}
						}
						else
						{
							if (source == null)
							{
								super.logWarning(path, line, text, errorCode);
							}
							else
							{
								super.logWarning(path, line, col, text, source, errorCode);
							}
						}
					}
				}
			}
		}
		else if (Message.ERROR.equals(level))
		{
			if (path == null)
			{
				if (line == -1)
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
					}
				}
				else
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(text);
							}
							else
							{
								super.logError(text);
							}
						}
					}
				}
			}
			else
			{
				if (line == -1)
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(path, text);
							}
							else
							{
								super.logError(path, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(path, text, errorCode);
							}
							else
							{
								super.logError(path, text, errorCode);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(path, text);
							}
							else
							{
								super.logError(path, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(path, text, errorCode);
							}
							else
							{
								super.logError(path, text, errorCode);
							}
						}
					}
				}
				else
				{
					if (col == -1)
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(path, line, text);
							}
							else
							{
								super.logError(path, line, text);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(path, line, text, errorCode);
							}
							else
							{
								super.logError(path, line, text, errorCode);
							}
						}
					}
					else
					{
						if (errorCode == -1)
						{
							if (source == null)
							{
								super.logError(path, line, col, text);
							}
							else
							{
								super.logError(path, line, col, text, source);
							}
						}
						else
						{
							if (source == null)
							{
								super.logError(path, line, text, errorCode);
							}
							else
							{
								super.logError(path, line, col, text, source, errorCode);
							}
						}
					}
				}
			}
		}
	}
}
