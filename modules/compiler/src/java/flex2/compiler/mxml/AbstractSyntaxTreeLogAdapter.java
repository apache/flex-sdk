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

package flex2.compiler.mxml;

import flex2.compiler.ILocalizableMessage;
import flex2.compiler.Logger;
import flex2.compiler.util.AbstractLogAdapter;
import java.util.HashMap;
import java.util.Map;

/**
 * This is a Logger implementation for use with AST generation.  It
 * has two jobs.  The first is to mimic MxmlLogAdapter's filtering of
 * duplicate errors and warnings.  The second is to swallow the source
 * param.  Downstream loggers like ConsoleLogger will lookup the
 * actual line text using the path and the line number.
 *
 * @author Paul Reilly
 */
public class AbstractSyntaxTreeLogAdapter extends AbstractLogAdapter
{
    /**
     * Some ASC errors and warnings, like those caused by data binding
     * expressions, will get reported twice, so we store them in the
     * following Map and only report them to the user the first time
     * we see them.
     */
    private Map<String, String> messages = new HashMap<String, String>();

    public AbstractSyntaxTreeLogAdapter(Logger original)
    {
        super(original);
    }

    public void log(ILocalizableMessage m, String source)
    {
        original.log(m);
    }

    public void logWarning(String path, int line, String warning, int errorCode)
    {
        String key = path + line;

        if (!warning.equals(messages.get(key)))
        {
            original.logWarning(path, line, warning, errorCode);
            messages.put(key, warning);
        }
    }

    public void logWarning(String path, int line, int col, String warning, String source)
    {
        String key = path + line;

        if (!warning.equals(messages.get(key)))
        {
            original.logWarning(path, line, warning);
            messages.put(key, warning);
        }
    }

    public void logWarning(String path, int line, int col, String warning, String source, int errorCode)
    {
        String key = path + line;

        if (!warning.equals(messages.get(key)))
        {
            original.logWarning(path, line, warning, errorCode);
            messages.put(key, warning);
        }
    }

    public void logError(String path, int line, String error, int errorCode)
    {
        String key = path + line;

        if (!error.equals(messages.get(key)))
        {
            original.logError(path, line, error, errorCode);
            messages.put(key, error);
        }
    }

    public void logError(String path, int line, int col, String error, String source)
    {
        String key = path + line;

        if (!error.equals(messages.get(key)))
        {
            original.logError(path, line, error);
            messages.put(key, error);
        }
    }

    public void logError(String path, int line, int col, String error, String source, int errorCode)
    {
        String key = path + line;

        if (!error.equals(messages.get(key)))
        {
            original.logError(path, line, error, errorCode);
            messages.put(key, error);
        }
    }
}
