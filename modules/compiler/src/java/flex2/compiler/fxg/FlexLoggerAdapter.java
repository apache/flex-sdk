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

package flex2.compiler.fxg;

import com.adobe.fxg.util.FXGLogger;
import com.adobe.internal.fxg.util.AbstractLogger;

import flex2.compiler.Logger;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * An adapter to bridge the FXGUtils and Flex compiler logging systems.
 * 
 * @author Peter Farland
 */
public class FlexLoggerAdapter extends AbstractLogger
{
    public FlexLoggerAdapter(int level)
    {
        super(level);
    }

    public void log(int level, Object message, Throwable t, String location, int line, int column, Object... arguments)
    {
        Logger delegateLogger = ThreadLocalToolkit.getLogger();
        if (delegateLogger != null)
        {
            String messageString = null;
            if (message != null)
                messageString = getLocalizedMessage(message.toString(), arguments);

            if (level == FXGLogger.ERROR)
            {
                delegateLogger.logError(location, line, column, messageString);
            }
            else if (level == FXGLogger.WARN)
            {
                delegateLogger.logWarning(location, line, column, messageString);
            }
            else if (level == FXGLogger.INFO)
            {
                delegateLogger.logInfo(location, line, column, messageString);
            }
            else if (level == FXGLogger.DEBUG)
            {
                delegateLogger.logDebug(location, line, column, messageString);
            }
        }
    }
} 
