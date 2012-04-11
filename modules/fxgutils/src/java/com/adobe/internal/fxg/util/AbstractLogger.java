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

package com.adobe.internal.fxg.util;

import java.util.Enumeration;
import java.util.Locale;
import java.util.ResourceBundle;

import com.adobe.fxg.util.FXGLogger;
import com.adobe.fxg.util.FXGLocalizationUtil;

/**
 * An abstract FXGLogger implementation to redirect the various utility
 * logging methods to the core log() API:
 * <pre>
 * void log(int level, Object message, Throwable t, String location, int line, int column);
 * <pre> 
 */
public abstract class AbstractLogger implements FXGLogger
{
    protected int level;

    protected AbstractLogger(int level)
    {
        this.level = level;
    }

    /**
     * {@inheritDoc}
     */
    public void debug(Object message)
    {
        log(DEBUG, message);
    }

    /**
     * {@inheritDoc}
     */
    public void debug(Object message, Throwable t)
    {
        log(DEBUG, message, t);
    }

    /**
     * {@inheritDoc}
     */
    public void debug(Object message, Throwable t, String location, int line, int column)
    {
        log(DEBUG, message, t, location, line, column);
    }
    
    /**
     * {@inheritDoc}
     */
    public void debug(Object message, Throwable t, String location, int line, int column, Object...arguments)
    {
        log(DEBUG, message, t, location, line, column, arguments);
    }

    /**
     * {@inheritDoc}
     */
    public void error(Object message)
    {
        log(ERROR, message);
    }

    /**
     * {@inheritDoc}
     */
    public void error(Object message, Throwable t)
    {
        log(ERROR, message, t);
    }

    /**
     * {@inheritDoc}
     */
    public void error(Object message, Throwable t, String location, int line, int column)
    {
        log(ERROR, message, t, location, line, column);
    }
    
    /**
     * {@inheritDoc}
     */
    public void error(Object message, Throwable t, String location, int line, int column, Object...arguments)
    {
        log(ERROR, message, t, location, line, column, arguments);
    }
    
    /**
     * {@inheritDoc}
     */
    public void info(Object message)
    {
        log(INFO, message);
    }

    /**
     * {@inheritDoc}
     */
    public void info(Object message, Throwable t)
    {
        log(INFO, message, t);
    }

    /**
     * {@inheritDoc}
     */
    public void info(Object message, Throwable t, String location, int line, int column)
    {
        log(INFO, message, t, location, line, column);
    }
    
    /**
     * {@inheritDoc}
     */
    public void info(Object message, Throwable t, String location, int line, int column, Object...arguments)
    {
        log(INFO, message, t, location, line, column, arguments);
    }
    
    /**
     * {@inheritDoc}
     */
    public int getLevel()
    {
        return level;
    }

    /**
     * {@inheritDoc}
     */
    public void setLevel(int value)
    {
        level = value;
    }

    /**
     * {@inheritDoc}
     */
    public void log(int level, Object message)
    {
        log(level, message, null);
    }

    /**
     * {@inheritDoc}
     */
    public void log(int level, Object message, Throwable t)
    {
        log(level, message, t, null, 0, 0);
    }

    /**
     * {@inheritDoc}
     */
    public void log(int level, Object message, Throwable t, String location, int line, int column)
    {
        log(level, message, t, location, line, column, (Object[])null);
    }
    
    /**
     * {@inheritDoc}
     */
    public void warn(Object message)
    {
        log(WARN, message);
    }

    /**
     * {@inheritDoc}
     */
    public void warn(Object message, Throwable t)
    {
        log(WARN, message, t);
    }

    /**
     * {@inheritDoc}
     */
    public void warn(Object message, Throwable t, String location, int line, int column)
    {
        log(WARN, message, t, location, line, column);
    }
    
    /**
     * {@inheritDoc}
     */
    public void warn(Object message, Throwable t, String location, int line, int column, Object...arguments)
    {
        log(WARN, message, t, location, line, column, arguments);
    }
    
    protected String getMessage(String message, Object... arguments)
    {
        synchronized (AbstractLogger.class)
        {
            FXGLocalizationUtil.setLogResourceBundle(null, null);
            return getLocalizedMessage(message, arguments);
        }
    }
    
    /**
     * @param locale - the Locale to use for the message.
     * @param message - message code.
     * @param arguments - parameter values.
     * @return Returns localized error message.
     */
    protected String getLocalizedMessage(String message, Object... arguments)
    {
        synchronized (AbstractLogger.class)
        {
            ResourceBundle resourceBundle = FXGLocalizationUtil.getLogResourceBundle();
            String paramMsg = message;
            if (resourceBundle != null)
            {
                Enumeration<String> keys = resourceBundle.getKeys();
                while (keys.hasMoreElements())
                {
                    String key = keys.nextElement();
                    if (key.equals(paramMsg))
                    {
                        paramMsg = resourceBundle.getString(message);
                        break;
                    }
                }
            }
            return FXGLocalizationUtil.substituteArguments(paramMsg, arguments);
        }
    }
    
    /**
     * @param locale - the Locale to use for the message.
     * @param message - message code.
     * @param arguments - parameter values.
     * @return Returns localized error message for the Locale specified.
     */
    protected String getLocalizedMessage(Locale locale, String message, Object... arguments)
    {
        synchronized (AbstractLogger.class)
        {
            FXGLocalizationUtil.setLocale(locale);
            return getLocalizedMessage(message, arguments);
        }
    }
}
