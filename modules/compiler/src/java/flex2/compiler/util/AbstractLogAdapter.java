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

/**
 * This class is a default implementation of Logger.  It just passes
 * through each call to the wrapped Logger.  It is useful if you want
 * to filter a subset of the Logger's methods.
 *
 * @author Paul Reilly
 */
public abstract class AbstractLogAdapter implements Logger
{
    protected Logger original;

    public AbstractLogAdapter(Logger original)
    {
        this.original = original;
    }

    public int errorCount()
    {
        return original.errorCount();
    }

    public int warningCount()
    {
        return original.warningCount();
    }

    public void logInfo(String info)
    {
        original.logInfo(info);
    }

    public void logDebug(String debug)
    {
        original.logDebug(debug);
    }

    public void logWarning(String warning)
    {
        original.logWarning(warning);
    }

    public void logError(String error)
    {
        original.logError(error);
    }

    public void logInfo(String path, String info)
    {
        original.logInfo(path, info);
    }

    public void logDebug(String path, String debug)
    {
        original.logDebug(path, debug);
    }

    public void logWarning(String path, String warning)
    {
        original.logWarning(path, warning);
    }

    public void logWarning(String path, String warning, int errorCode)
    {
        original.logWarning(path, warning, errorCode);
    }

    public void logError(String path, String error)
    {
        original.logError(path, error);
    }

    public void logError(String path, String error, int errorCode)
    {
        original.logError(path, error, errorCode);
    }

    public void logInfo(String path, int line, String info)
    {
        original.logInfo(path, line, info);
    }

    public void logDebug(String path, int line, String debug)
    {
        original.logDebug(path, line, debug);
    }

    public void logWarning(String path, int line, String warning)
    {
        original.logWarning(path, line, warning);
    }

    public void logWarning(String path, int line, String warning, int errorCode)
    {
        original.logWarning(path, line, warning, errorCode);
    }

    public void logError(String path, int line, String error)
    {
        original.logError(path, line, error);
    }

    public void logError(String path, int line, String error, int errorCode)
    {
        original.logError(path, line, error, errorCode);
    }

    public void logInfo(String path, int line, int col, String info)
    {
        original.logInfo(path, line, col, info);
    }

    public void logDebug(String path, int line, int col, String debug)
    {
        original.logDebug(path, line, col, debug);
    }

    public void logWarning(String path, int line, int col, String warning)
    {
        original.logWarning(path, line, col, warning);
    }

    public void logError(String path, int line, int col, String error)
    {
        original.logError(path, line, col, error);
    }

    public void logWarning(String path, int line, int col, String warning, String source)
    {
        original.logWarning(path, line, col, warning, source);
    }

    public void logWarning(String path, int line, int col, String warning, String source, int errorCode)
    {
        original.logWarning(path, line, col, warning, source, errorCode);
    }

    public void logError(String path, int line, int col, String error, String source)
    {
        original.logError(path, line, col, error, source);
    }

    public void logError(String path, int line, int col, String error, String source, int errorCode)
    {
        original.logError(path, line, col, error, source, errorCode);
    }

    public void log(ILocalizableMessage m)
    {
        original.log(m);
    }

    public void log(ILocalizableMessage m, String source)
    {
        original.log(m, source);
    }

    public void needsCompilation(String path, String reason)
    {
        original.needsCompilation(path, reason);
    }

    public void includedFileUpdated(String path)
    {
        original.includedFileUpdated(path);
    }

    public void includedFileAffected(String path)
    {
        original.includedFileAffected(path);
    }

    public void setLocalizationManager(LocalizationManager mgr)
    {
        original.setLocalizationManager(mgr);
    }
}
