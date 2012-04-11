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

import flex2.compiler.ILocalizableMessage;
import flex2.compiler.CompilerException;
import flash.localization.LocalizationManager;

/**
 * This class provides a common base class for all localizable
 * exceptions thrown by the compiler.  It can be used in catch
 * statements, but it shouldn't be constructed directly.  A subclass
 * should be used when reporting an error or warning.
 *
 * @author Roger Gonzalez
 */
public class CompilerMessage extends CompilerException implements ILocalizableMessage
{
    private static final long serialVersionUID = 3500487484906739205L;

    public CompilerMessage(String level, String path, int line, int col)
    {
        this.level = level;
        this.path = path;
        this.line = line;
        this.column = col;
        isPathAvailable = true;
    }

    public CompilerMessage(String level, String path, int line, int col, Throwable rootCause)
    {
        super(rootCause);
        this.level = level;
        this.path = path;
        this.line = line;
        this.column = col;
        isPathAvailable = true;
        if (rootCause instanceof Exception)
            detailEx = (Exception)rootCause;
    }

    public String getLevel()
    {
        return level;
    }

    public String getPath()
    {
        return path;
    }

    public void setPath(String path)
    {
        this.path = path;
    }

    public int getLine()
    {
        return line;
    }

    public void setLine(int line)
    {
        this.line = line;
    }

    public int getColumn()
    {
        return column;
    }

    public void setColumn(int column)
    {
        this.column = column;
    }

    public Exception getExceptionDetail()
    {
        return detailEx;
    }

	public String getMessage()
	{
		String msg = super.getMessage();
		if (msg != null)
		{
			return msg;
		}
		else
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			if (l10n == null)
			{
				return null;
			}
			else
			{
				return l10n.getLocalizedTextString(this);
			}
		}
	}
	
	public String toString()
	{
		return getMessage();
	}

	public boolean isPathAvailable()
	{
		return isPathAvailable;
	}

	protected void noPath()
	{
		isPathAvailable = false;
	}
	
    public String level;
    public String path;
    public int line;
    public int column;
    private Exception detailEx; 
    private boolean isPathAvailable;


    // TODO - add ctors to these as needed

    public static class CompilerError extends CompilerMessage
    {
        private static final long serialVersionUID = -4267301959263918376L;

        public CompilerError()
        {
            super(ERROR, null, -1, -1);
        }

        public CompilerError(Throwable rootCause)
        {
            super(ERROR, null, -1, -1, rootCause);
        }
    }

    public static class CompilerWarning extends CompilerMessage
    {
        private static final long serialVersionUID = -6415139860097981650L;

        public CompilerWarning()
        {
            super(WARNING, null, -1, -1);
        }

        public CompilerWarning(Throwable rootCause)
        {
            super(WARNING, null, -1, -1, rootCause);
        }
    }

    public static class CompilerInfo extends CompilerMessage
    {
        private static final long serialVersionUID = 7011676633916976231L;

        public CompilerInfo()
        {
            super(INFO, null, -1, -1);
        }

        public CompilerInfo(Throwable rootCause)
        {
            super(INFO, null, -1, -1, rootCause);
        }
    }
}
