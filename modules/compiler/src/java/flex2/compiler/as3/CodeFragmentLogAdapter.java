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

package flex2.compiler.as3;

import flex2.compiler.ILocalizableMessage;
import flex2.compiler.Logger;
import flex2.compiler.util.AbstractLogAdapter;

/**
 * This is a Logger implementation for use with direct AST generation.
 * It handles offsetting the line number reported from ASC with the
 * line number of the code fragment in the MXML document.
 *
 * @author Paul Reilly
 */
public final class CodeFragmentLogAdapter extends AbstractLogAdapter
{
    private int lineNumberOffset;

    public CodeFragmentLogAdapter(Logger original, int lineNumberOffset)
    {
        super(original);
        this.lineNumberOffset = lineNumberOffset  - 1;
    }

    public void logInfo(String path, int line, String info)
    {
        original.logInfo(path, line + lineNumberOffset, info);
    }

    public void logDebug(String path, int line, String debug)
    {
        original.logDebug(path, line + lineNumberOffset, debug);
    }

    public void logWarning(String path, int line, String warning)
    {
        original.logWarning(path, line + lineNumberOffset, warning);
    }

    public void logWarning(String path, int line, String warning, int errorCode)
    {
        original.logWarning(path, line + lineNumberOffset, warning, errorCode);
    }

    public void logError(String path, int line, String error)
    {
        original.logError(path, line + lineNumberOffset, error);
    }

    public void logError(String path, int line, String error, int errorCode)
    {
        original.logError(path, line + lineNumberOffset, error, errorCode);
    }

    public void logInfo(String path, int line, int col, String info)
    {
        original.logInfo(path, line + lineNumberOffset, info);
    }

    public void logDebug(String path, int line, int col, String debug)
    {
        original.logDebug(path, line + lineNumberOffset, debug);
    }

    public void logWarning(String path, int line, int col, String warning)
    {
        original.logWarning(path, line + lineNumberOffset, warning);
    }

    public void logError(String path, int line, int col, String error)
    {
        original.logError(path, line + lineNumberOffset, error);
    }

    public void logWarning(String path, int line, int col, String warning, String source)
    {
        original.logWarning(path, line + lineNumberOffset, warning);
    }

    public void logWarning(String path, int line, int col, String warning, String source, int errorCode)
    {
        original.logWarning(path, line + lineNumberOffset, warning, errorCode);
    }

    public void logError(String path, int line, int col, String error, String source)
    {
        original.logError(path, line + lineNumberOffset, error);
    }

    public void logError(String path, int line, int col, String error, String source, int errorCode)
    {
        original.logError(path, line + lineNumberOffset, error, errorCode);
    }

    public void log(ILocalizableMessage m)
    {
        m.setLine(m.getLine() + lineNumberOffset);
        original.log(m);
    }

    public void log(ILocalizableMessage m, String source)
    {
        m.setLine(m.getLine() + lineNumberOffset);
        original.log(m, source);
    }
}
