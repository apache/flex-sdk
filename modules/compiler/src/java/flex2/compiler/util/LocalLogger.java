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

package flex2.compiler.util;

import flash.localization.LocalizationManager;
import flex2.compiler.ILocalizableMessage;
import flex2.compiler.Logger;
import flex2.compiler.Source;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.LinkedList;
import java.util.List;

import macromedia.asc.util.IntegerPool;

/**
 * LocalLogger keeps a local count of warnings of errors.
 *
 * @author Clement Wong
 */
public class LocalLogger implements Logger
{
	public LocalLogger(Logger original, Source source)
	{
		this(original);
		this.source = source;
	}

	public LocalLogger(Logger original)
	{
		assert !(original instanceof LocalLogger);
		this.original = original;
		errorCount = 0;
		warningCount = 0;
		warnings = null;
	}

	private Logger original;
	private Source source;
	private int errorCount, warningCount;
	private List<Warning> warnings;
	private LocalizationManager l10n;

	// C: used by PersistenceStore...
	public void setSource(Source s)
	{
		source = s;
	}
	
	// Disconnect this logger from the original logger...
	public void disconnect()
	{
		original = null;
		source = null;
		l10n = null;
	}

	public boolean isConnected()
	{
		return original != null;
	}

	public int errorCount()
	{
		return errorCount;
	}

	public int warningCount()
	{
		return warningCount;
	}

	public void logInfo(String info)
	{
		if (original != null)
		{
			original.logInfo(info);
		}
	}

	public void logDebug(String debug)
	{
		if (original != null)
		{
			original.logDebug(debug);
		}
	}

	public void logWarning(String warning)
	{
		if (original != null)
		{
			original.logWarning(warning);
		}
		recordWarning(warning);
	}

	public void logError(String error)
	{
		if (original != null)
		{
			original.logError(error);
		}
		errorCount++;
	}

	public void logInfo(String path, String info)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, null, null, info, null, null);
			if (misrouteInfo == null)
			{
				original.logInfo(path, info);
			}
			else
			{
				original.logInfo(source.getNameForReporting(), info + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}
		}
	}

	public void logDebug(String path, String debug)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, null, null, debug, null, null);
			if (misrouteInfo == null)
			{
				original.logDebug(path, debug);
			}
			else
			{
				original.logDebug(source.getNameForReporting(), debug + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}
		}
	}

	public void logWarning(String path, String warning)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, null, null, warning, null, null);
			if (misrouteInfo == null)
			{
				original.logWarning(path, warning);
			}
			else
			{
				original.logWarning(source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, warning);
	}

	public void logWarning(String path, String warning, int errorCode)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, null, null, warning, null, IntegerPool.getNumber(errorCode));
			if (misrouteInfo == null)
			{
				original.logWarning(path, warning, errorCode);
			}
			else
			{
				original.logWarning(source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, warning, errorCode);
	}

	public void logError(String path, String error)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, null, null, error, null, null);
			if (misrouteInfo == null)
			{
				original.logError(path, error);
			}
			else
			{
				original.logError(source.getNameForReporting(), error + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		errorCount++;
	}

	public void logError(String path, String error, int errorCode)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, null, null, error, null, IntegerPool.getNumber(errorCode));
			if (misrouteInfo == null)
			{
				original.logError(path, error, errorCode);
			}
			else
			{
				original.logError(source.getNameForReporting(), error + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		errorCount++;
	}

	public void logInfo(String path, int line, String info)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), null, info, null, null);
			if (misrouteInfo == null)
			{
				original.logInfo(path, line, info);
			}
			else
			{
				original.logInfo(source.getNameForReporting(), info + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
	}

	public void logDebug(String path, int line, String debug)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), null, debug, null, null);
			if (misrouteInfo == null)
			{
				original.logDebug(path, line, debug);
			}
			else
			{
				original.logDebug(source.getNameForReporting(), debug + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
	}

	public void logWarning(String path, int line, String warning)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), null, warning, null, null);
			if (misrouteInfo == null)
			{
				original.logWarning(path, line, warning);
			}
			else
			{
				original.logWarning(source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, line, warning);
	}

	public void logWarning(String path, int line, String warning, int errorCode)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), null, warning, null, IntegerPool.getNumber(errorCode));
			if (misrouteInfo == null)
			{
				original.logWarning(path, line, warning, errorCode);
			}
			else
			{
				original.logWarning(source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, line, warning, errorCode);
	}

	public void logError(String path, int line, String error)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), null, error, null, null);
			if (misrouteInfo == null)
			{
				original.logError(path, line, error);
			}
			else
			{
				original.logError(source.getNameForReporting(), error + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		errorCount++;
	}

	public void logError(String path, int line, String error, int errorCode)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), null, error, null, IntegerPool.getNumber(errorCode));
			if (misrouteInfo == null)
			{
				original.logError(path, line, error, errorCode);
			}
			else
			{
				original.logError(source.getNameForReporting(), error + misrouteInfo);
			}

		}
		errorCount++;
	}

	public void logInfo(String path, int line, int col, String info)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), info, null, null);
			if (misrouteInfo == null)
			{
				original.logInfo(path, line, col, info);
			}
			else
			{
				original.logInfo(source.getNameForReporting(), info + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
	}

	public void logDebug(String path, int line, int col, String debug)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), debug, null, null);
			if (misrouteInfo == null)
			{
				original.logDebug(path, line, col, debug);
			}
			else
			{
				original.logDebug(source.getNameForReporting(), debug + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
	}

	public void logWarning(String path, int line, int col, String warning)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), warning, null, null);
			if (misrouteInfo == null)
			{
				original.logWarning(path, line, col, warning);
			}
			else
			{
				original.logWarning(source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, line, col, warning);
	}

	public void logError(String path, int line, int col, String error)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), error, null, null);
			if (misrouteInfo == null)
			{
				original.logError(path, line, col, error);
			}
			else
			{
				original.logError(source.getNameForReporting(), error + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		errorCount++;
	}

	public void logWarning(String path, int line, int col, String warning, String source)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), warning, source, null);
			if (misrouteInfo == null)
			{
				original.logWarning(path, line, col, warning, source);
			}
			else
			{
				original.logWarning(this.source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, line, col, warning, source);
	}

	public void logWarning(String path, int line, int col, String warning, String source, int errorCode)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), source, null, IntegerPool.getNumber(errorCode));
			if (misrouteInfo == null)
			{
				original.logWarning(path, line, col, warning, source, errorCode);
			}
			else
			{
				original.logWarning(this.source.getNameForReporting(), warning + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		recordWarning(path, line, col, warning, source, errorCode);
	}

	public void logError(String path, int line, int col, String error, String source)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), error, source, null);
			if (misrouteInfo == null)
			{
				original.logError(path, line, col, error, source);
			}
			else
			{
				original.logError(this.source.getNameForReporting(), error + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		errorCount++;
	}

	public void logError(String path, int line, int col, String error, String source, int errorCode)
	{
		if (original != null)
		{
			String misrouteInfo = checkPath(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), error, source, IntegerPool.getNumber(errorCode));
			if (misrouteInfo == null)
			{
				original.logError(path, line, col, error, source, errorCode);
			}
			else
			{
				original.logError(this.source.getNameForReporting(), error + misrouteInfo);
				logUnmappedError(misrouteInfo);
			}

		}
		errorCount++;
	}

	public void log(ILocalizableMessage m)
	{
		log(m, null);
	}

	public void log(ILocalizableMessage m, String source)
	{
		if (m.getLevel() == ILocalizableMessage.ERROR)
		{
			errorCount++;
		}
		else if (m.getLevel() == ILocalizableMessage.WARNING)
		{
			warningCount++;
			recordWarning(m.getPath(), m.getLine(), m.getColumn(), l10n.getLocalizedTextString(m));
		}
		if (original != null)
		{
			String misrouteInfo = null;
			if (m.isPathAvailable())
			{
				misrouteInfo = checkPath(m.getPath(), IntegerPool.getNumber(m.getLine()), IntegerPool.getNumber(m.getColumn()), null, null, null);
			}
			if (misrouteInfo == null)
			{
				if (source == null)
				{
					original.log(m);
				}
				else
				{
					original.log(m, source);
				}
			}
			else
			{
				//	NOTE: no way to tack CODEGEN locator onto error message in this case
				m.setPath(this.source.getNameForReporting());
				m.setLine(-1);
				m.setColumn(-1);
				original.log(m);
				logUnmappedError(misrouteInfo);
			}
		}
	}

	public void needsCompilation(String path, String reason)
	{
		if (original != null)
		{
			original.needsCompilation(path, reason);
		}
	}

	public void includedFileUpdated(String path)
	{
		if (original != null)
		{
			original.includedFileUpdated(path);
		}
	}

	public void includedFileAffected(String path)
	{
		if (original != null)
		{
			original.includedFileAffected(path);
		}
	}

	public void setLocalizationManager(LocalizationManager mgr)
	{
		l10n = mgr;
	}

	/**
	 * Compact diagnostic text containing generated-code locator info. Can be appended to error message.
	 */
	private String checkPath(String p, Integer line, Integer col, String msg, String source, Integer errorCode)
	{
		boolean result = !this.source.getNameForReporting().equals(p) &&
						 !this.source.isIncludedFile(p);
						 // !this.source.getCompilationUnit().getAssets().exists(p);
		
		if (result)
		{
			return (new StringBuilder(" [")
				.append(new GeneratedCodeMarker().getMessage())).append(": ")
				.append(new PathInfo(p).getMessage()).append(", ")
				.append(new LineInfo(line == null ? 0 : line.intValue()).getMessage()).append(", ")
				.append(new ColumnInfo(col == null ? 0 : col.intValue()).getMessage()).append("]")
				.toString();
		}
		else
		{
			return null;
		}
	}

	/**
	 * Log a debug message with details on an error that came in with an invalid path (assumed to be generated
	 * code derived from the current Source).
	 * TODO this should be controllable via the commandline for diagnostics etc.
	 * Unfortunately, debug logging seems to always be enabled at the console currently, so for 2.0 GMC we
	 * just stuff it.
	 */
	private void logUnmappedError(String misrouteInfo)
	{
		//	original.logDebug(misrouteInfo);
	}

	/**
	 * Full diagnostic text, including stack dump.
	 */
	@SuppressWarnings("unused")
    private String checkPathFull(String p, Integer line, Integer col, String msg, String source, Integer errorCode)
	{
		boolean result = !this.source.getNameForReporting().equals(p) &&
						 !this.source.isIncludedFile(p);
						 // !this.source.getCompilationUnit().getAssets().exists(p);

		if (result)
		{
			StringWriter misrouteInfo = new StringWriter();
			PrintWriter pw = new PrintWriter(misrouteInfo, true);
			pw.println(new ErrMsgBug().getMessage());
			pw.println(new PathInfo(p).getMessage());
			if (line != null)
			{
				pw.println(new LineInfo(line.intValue()).getMessage());
			}
			if (col != null)
			{
				pw.println(new ColumnInfo(col.intValue()).getMessage());
			}
			if (msg != null)
			{
				pw.println(new MessageInfo(msg).getMessage());
			}
			if (source != null)
			{
				pw.println(new SourceInfo(source).getMessage());
			}
			if (errorCode != null)
			{
				pw.println(new ErrorCodeInfo(errorCode.intValue()).getMessage());
			}
			new Exception(new StackTraceInfo().getMessage()).printStackTrace(pw);
			return misrouteInfo.toString();
		}
		else
		{
			return null;
		}
	}

	public static class GeneratedCodeMarker extends CompilerMessage.CompilerInfo {

        private static final long serialVersionUID = -7628545867822633628L;}

	public static class ErrMsgBug extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = 8033874361803199059L;

        public ErrMsgBug()
		{
			super();
		}
	}

	public static class PathInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -6570823652701358227L;

        public PathInfo(String p)
		{
			filepath = p;
		}

		public final String filepath;
	}

	public static class LineInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -87438910186526222L;

        public LineInfo(int l)
		{
			fileline = l;
		}

		public final int fileline;
	}

	public static class ColumnInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = 1134311690698586756L;

        public ColumnInfo(int c)
		{
			filecol = c;
		}

		public final int filecol;
	}

	public static class MessageInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = 3056765623916777257L;

        public MessageInfo(String m)
		{
			filemsg = m;
		}

		public final String filemsg;
	}

	public static class SourceInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -4219876071297989808L;

        public SourceInfo(String s)
		{
			filesource = s;
		}

		public final String filesource;
	}

	public static class ErrorCodeInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = 2382276768592926066L;

        public ErrorCodeInfo(int e)
		{
			fileerrorCode = e;
		}

		public final int fileerrorCode;
	}

	public static class StackTraceInfo extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = 2730713000203583580L;

        public StackTraceInfo()
		{
			super();
		}
	}

	public void displayWarnings(Logger logger)
	{
		for (int i = 0, size = warnings == null ? 0 : warnings.size(); i < size; i++)
		{
			Warning w = warnings.get(i);
			if (w.path != null)
			{
				if (w.line == null && w.col == null && w.source == null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.warning);
				}
				else if (w.line == null && w.col == null && w.source == null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.warning, w.errorCode.intValue());
				}
				else if (w.line == null && w.col == null && w.source != null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.warning);
				}
				else if (w.line == null && w.col == null && w.source != null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.warning, w.errorCode.intValue());
				}
				else if (w.line == null && w.col != null && w.source == null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.warning);
				}
				else if (w.line == null && w.col != null && w.source == null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.warning, w.errorCode.intValue());
				}
				else if (w.line == null && w.col != null && w.source != null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.warning);
				}
				else if (w.line == null && w.col != null && w.source != null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.warning, w.errorCode.intValue());
				}
				else if (w.line != null && w.col == null && w.source == null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.warning);
				}
				else if (w.line != null && w.col == null && w.source == null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.warning, w.errorCode.intValue());
				}
				else if (w.line != null && w.col == null && w.source != null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.warning);
				}
				else if (w.line != null && w.col == null && w.source != null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.warning, w.errorCode.intValue());
				}
				else if (w.line != null && w.col != null && w.source == null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.col.intValue(), w.warning);
				}
				else if (w.line != null && w.col != null && w.source == null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.warning, w.errorCode.intValue());
				}
				else if (w.line != null && w.col != null && w.source != null && w.errorCode == null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.col.intValue(), w.warning, w.source);
				}
				else if (w.line != null && w.col != null && w.source != null && w.errorCode != null)
				{
					logger.logWarning(w.path, w.line.intValue(), w.col.intValue(), w.warning, w.source, w.errorCode.intValue());
				}
			}
			else
			{
				logger.logWarning(w.warning);
			}
		}
	}

	public List<Warning> getWarnings()
	{
		return warnings;
	}

	private void recordWarning(String warning)
	{
		recordWarning(null, null, null, warning, null, null);
	}

	private void recordWarning(String path, String warning)
	{
		recordWarning(path, null, null, warning, null, null);
	}

	private void recordWarning(String path, String warning, int errorCode)
	{
		recordWarning(path, null, null, warning, null, IntegerPool.getNumber(errorCode));
	}

	private void recordWarning(String path, int line, String warning)
	{
		recordWarning(path, IntegerPool.getNumber(line), null, warning, null, null);
	}

	private void recordWarning(String path, int line, String warning, int errorCode)
	{
		recordWarning(path, IntegerPool.getNumber(line), null, warning, null, IntegerPool.getNumber(errorCode));
	}

	private void recordWarning(String path, int line, int col, String warning)
	{
		recordWarning(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), warning, null, null);
	}

	private void recordWarning(String path, int line, int col, String warning, String source)
	{
		recordWarning(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), warning, source, null);
	}

	private void recordWarning(String path, int line, int col, String warning, String source, int errorCode)
	{
		recordWarning(path, IntegerPool.getNumber(line), IntegerPool.getNumber(col), warning, source, IntegerPool.getNumber(errorCode));
	}

	public void recordWarning(String path, Integer line, Integer col, String warning, String source, Integer errorCode)
	{
		Warning w = new Warning();
		w.path = path;
		w.warning = warning;
		w.source = source;
		w.line = line;
		w.col = col;
		w.errorCode = errorCode;

		if (warnings == null)
		{
			warnings = new LinkedList<Warning>();
		}

		warnings.add(w);
		warningCount++;
	}

	public static class Warning
	{
		public String path, warning, source;
		public Integer line, col, errorCode;
	}

}
