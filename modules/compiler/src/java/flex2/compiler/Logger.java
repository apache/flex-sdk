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

package flex2.compiler;

import flash.localization.LocalizationManager;

/**
 * The base interface of all loggers in the compiler.
 *
 * @author Clement Wong
 */
public interface Logger
{
    int errorCount();

    int warningCount();

    void logInfo(String info);

    void logDebug(String debug);

    void logWarning(String warning);

    void logError(String error);

    void logInfo(String path, String info);

    void logDebug(String path, String debug);

    void logWarning(String path, String warning);

	void logWarning(String path, String warning, int errorCode);

    void logError(String path, String error);

	void logError(String path, String error, int errorCode);

    void logInfo(String path, int line, String info);

    void logDebug(String path, int line, String debug);

    void logWarning(String path, int line, String warning);

	void logWarning(String path, int line, String warning, int errorCode);

    void logError(String path, int line, String error);

	void logError(String path, int line, String error, int errorCode);

    void logInfo(String path, int line, int col, String info);

    void logDebug(String path, int line, int col, String debug);

    void logWarning(String path, int line, int col, String warning);

    void logError(String path, int line, int col, String error);

    void logWarning(String path, int line, int col, String warning, String source);

	void logWarning(String path, int line, int col, String warning, String source, int errorCode);

    void logError(String path, int line, int col, String error, String source);

	void logError(String path, int line, int col, String error, String source, int errorCode);

    void log(ILocalizableMessage m);

	void log(ILocalizableMessage m, String source);

    void needsCompilation(String path, String reason);

	void includedFileUpdated(String path);

	void includedFileAffected(String path);

    void setLocalizationManager( LocalizationManager mgr );
}
