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

import flex2.compiler.ILocalizableMessage;
import flex2.compiler.util.AbstractLogger;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.oem.*;

/**
 * Extends AbstractLogger to support logging to an OEM API logger.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class OEMLogAdapter extends AbstractLogger
{
	public OEMLogAdapter(Logger l)
	{
		init(ThreadLocalToolkit.getLocalizationManager());
		setLogger(l);
	}

	private Logger oemLogger;
	private int errorCount;
	private int warningCount;

	public void setLogger(Logger l)
	{
		oemLogger = l;
	}

	public int errorCount()
	{
		return errorCount;
	}

	public void includedFileAffected(String path)
	{
        this.logInfo(path, -1, -1, "");
	}

	public void includedFileUpdated(String path)
	{
        this.logInfo(path, -1, -1, "");
	}

	public void log(ILocalizableMessage m)
	{
		this.log(m, null);
	}

	public void log(ILocalizableMessage m, String source)
	{
		if (ILocalizableMessage.WARNING.equals(m.getLevel()))
		{
			warningCount++;
		}
		else if (ILocalizableMessage.ERROR.equals(m.getLevel()))
		{
			errorCount++;
		}

		if (oemLogger != null)
		{
			oemLogger.log(m, -1, null);
		}
	}

	public void logDebug(String debug)
	{
	}

	public void logDebug(String path, String debug)
	{
	}

	public void logDebug(String path, int line, String debug)
	{
	}

	public void logDebug(String path, int line, int col, String debug)
	{
	}

	public void logError(String error)
	{
		this.logError(null, -1, -1, error, null, -1);
	}

	public void logError(String path, String error)
	{
		this.logError(null, -1, -1, error, null, -1);
	}

	public void logError(String path, String error, int errorCode)
	{
		this.logError(path, -1, -1, error, null, errorCode);
	}

	public void logError(String path, int line, String error)
	{
		this.logError(path, line, -1, error, null, -1);
	}

	public void logError(String path, int line, String error, int errorCode)
	{
		this.logError(path, line, -1, error, null, errorCode);
	}

	public void logError(String path, int line, int col, String error)
	{
		this.logError(path, line, col, error, null, -1);
	}

	public void logError(String path, int line, int col, String error, String source)
	{
		this.logError(path, line, col, error, source, -1);
	}

	public void logError(String path, int line, int col, String error, String source, int errorCode)
	{
		errorCount++;
		if (oemLogger != null)
		{
			oemLogger.log(new GenericMessage(Message.ERROR, path, line, col, error), errorCode, source);
		}
	}

	public void logInfo(String info)
	{
		this.logInfo(null, -1, -1, info);
	}

	public void logInfo(String path, String info)
	{
		this.logInfo(path, -1, -1, info);
	}

	public void logInfo(String path, int line, String info)
	{
		this.logInfo(path, line, -1, info);
	}

	public void logInfo(String path, int line, int col, String info)
	{
		if (oemLogger != null)
		{
			oemLogger.log(new GenericMessage(Message.INFO, path, line, col, info), -1, null);
		}
	}

	public void logWarning(String warning)
	{
		this.logWarning(null, -1, -1, warning, null, -1);
	}

	public void logWarning(String path, String warning)
	{
		this.logWarning(path, -1, -1, warning, null, -1);
	}

	public void logWarning(String path, String warning, int errorCode)
	{
		this.logWarning(path, -1, -1, warning, null, errorCode);
	}

	public void logWarning(String path, int line, String warning)
	{
		this.logWarning(path, line, -1, warning, null, -1);
	}

	public void logWarning(String path, int line, String warning, int errorCode)
	{
		this.logWarning(path, line, -1, warning, null, errorCode);
	}

	public void logWarning(String path, int line, int col, String warning)
	{
		this.logWarning(path, line, col, warning, null, -1);
	}

	public void logWarning(String path, int line, int col, String warning, String source)
	{
		this.logWarning(path, line, col, warning, source, -1);
	}

	public void logWarning(String path, int line, int col, String warning, String source, int errorCode)
	{
		warningCount++;
		if (oemLogger != null)
		{
			oemLogger.log(new GenericMessage(Message.WARNING, path, line, col, warning), errorCode, source);
		}
	}

	public void needsCompilation(String path, String reason)
	{
        this.logInfo(path, -1, -1, reason);
	}

	public int warningCount()
	{
		return warningCount;
	}
}
