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

package com.adobe.fxg.util;

import java.text.MessageFormat;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

/**
 * Utility class to help create localized message for exceptions and logs.
 * 
 * @author Min Plunkett
 */
public class FXGLocalizationUtil
{
    /**
     * Default locale.
     */
	public static final Locale DEFAULT_LOCALE = Locale.ENGLISH;
    
    /**
     * Default exception resource properties.
     */
    public static final String DEFAULT_EXCEPTION_RESOURCE_BASE_NAME = "com.adobe.fxg.FXGException";
    
    /**
     * Default log resource properties.
     */
    public static final String DEFAULT_LOG_RESOURCE_BASE_NAME = "com.adobe.fxg.FXGLog";
    
    /**
     * The current log resource bundle base name. Default to 
     * DEFAULT_LOG_RESOURCE_BASE_NAME.
     */
    private static ThreadLocal<String> logResourceBaseName = new ThreadLocal<String>()
    {
        protected String initialValue()
        {
            return DEFAULT_LOG_RESOURCE_BASE_NAME;
        }
    };
    
    /**
     * The current log resource bundle. Default to null.
     */
    private static ThreadLocal<ResourceBundle> logResourceBundle = new ThreadLocal<ResourceBundle>()
    {
        protected ResourceBundle initialValue()
        {
            return null;
        }
    };    
    
    /**
     * The current exception resource bundle base name. Default to 
     * DEFAULT_EXCEPTION_RESOURCE_BASE_NAME.
     */
    private static ThreadLocal<String> exceptionResourceBaseName = new ThreadLocal<String>()
    {
        protected String initialValue()
        {
            return DEFAULT_EXCEPTION_RESOURCE_BASE_NAME;
        }
    };   
    
    /**
     * The current exception resource bundle. Default to null.
     */
    private static ThreadLocal<ResourceBundle> exceptionResourceBundle = new ThreadLocal<ResourceBundle>()
    {
        protected ResourceBundle initialValue()
        {
            return null;
        }
    };

    /**
     * The default locale. Default to DEFAULT_LOCALE.
     */
    private static ThreadLocal<Locale> defaultLocale = new ThreadLocal<Locale>()
    {
        protected Locale initialValue()
        {
            return DEFAULT_LOCALE;
        }
    };

    /**
     * The current specified locale. Default to DEFAULT_LOCALE.
     */
    private static ThreadLocal<Locale> currentLocale = new ThreadLocal<Locale>()
    {
        protected Locale initialValue()
        {
            return DEFAULT_LOCALE;
        }
    };

    /**
     * Helper function to substitute arguments in a parameterized message.
     * @param parameterized
     * @param arguments
     * @return complete message.
     */
    public static String substituteArguments(String parameterized, Object[] arguments)
    {
        if ((parameterized == null) || (arguments == null))
            return parameterized;
        return MessageFormat.format(parameterized, arguments).trim();
    }

    /**
     * Get the default locale.
     * 
     * @return the default locale
     */
    public static Locale getDefaultLocale()
    {
        return defaultLocale.get();
    }
    
    /**
     * Specifies default locale. If loc passed in is null, DEFAULT_LOCALE is
     * used.
     * 
     * @param loc the new default locale
     */
    public static void setDefaultLocale(Locale loc)
    {
        if (loc == null)
            loc = DEFAULT_LOCALE;

        if (defaultLocale.get().equals(loc))
            return;

        defaultLocale.set(loc);
    }
    
    /**
     * Get the current locale.
     * 
     * @return the locale
     */
    public static Locale getLocale()
    {
        return currentLocale.get();
    }
    
    /**
     * Specifies locale for subsequent getLocalizedMessage() calls if loc passed
     * in is null, defaultLocale is used.
     * 
     * @param loc
     */
    public static void setLocale(Locale loc)
    {
        if (loc == null)
            loc = getDefaultLocale();

        if (currentLocale.get().equals(loc))
            return;

        currentLocale.set(loc);
        setExceptionResourceBundle();
        setLogResourceBundle();
    }
    
    /**
     * Specifies resource base name and locale for initializing resource bundle.
     * If baseName is null, DEFAULT_LOG_RESOURCE_BASE_NAME is used. if loc 
     * is null, defaultLocale is used.
     * 
     * @param baseName
     * @param loc
     */
    public static void setLogResourceBundle(String baseName, Locale loc)
    {

        if (baseName == null)
            baseName = DEFAULT_LOG_RESOURCE_BASE_NAME;

        if (loc == null)
            loc = getDefaultLocale();

        if (logResourceBaseName.get().equals(baseName) && currentLocale.get().equals(loc) 
                && (logResourceBundle.get() != null))
            return;
        
        setLocale(loc);
        logResourceBaseName.set(baseName);
    }
    
    /**
     * Get log resource bundle.
     * @return resource bundle.
     */
    public static ResourceBundle getLogResourceBundle()
    {
        if (logResourceBundle.get() == null)
        {
            setLogResourceBundle();
        }
        return logResourceBundle.get();
    }
    
    /**
     * Specifies resource base name and locale for initializing resource bundle.
     * If baseName is null, DEFAULT_EXCEPTION_RESOURCE_BASE_NAME is used. 
     * If loc in null, defaultLocale is used.
     * 
     * @param baseName
     * @param loc
     */
    public static void setExceptionResourceBundle(String baseName, Locale loc)
    {

        if (baseName == null)
            baseName = DEFAULT_EXCEPTION_RESOURCE_BASE_NAME;

        if (loc == null)
            loc = getDefaultLocale();

        if (exceptionResourceBaseName.get().equals(baseName) && currentLocale.get().equals(loc) 
                && (exceptionResourceBundle.get() != null))
            return;

        setLocale(loc);
        exceptionResourceBaseName.set(baseName);
    }
    
    /**
     * Initializing resource bundle for exceptions using defaults:
     * DEFAULT_EXCEPTION_RESOURCE_BASE_NAME and defaultLocale.
     */
    public static void setExceptionResourceBundle()
    {
        try
        {
            exceptionResourceBundle.set(ResourceBundle.getBundle(exceptionResourceBaseName.get(), currentLocale.get()));
        }
        catch (MissingResourceException e)
        {
            exceptionResourceBundle = null;
        }
    }    
    
    /**
     * Get exception resource bundle.
     * @return resource bundle.
     */
    public static ResourceBundle getExceptionResourceBundle()
    {
        if (exceptionResourceBundle.get() == null)
        {
            setExceptionResourceBundle();
        }
        return exceptionResourceBundle.get();
    }
    
    /**
     * Initializing resource bundle for logs using defaults:
     * DEFAULT_LOG_RESOURCE_BASE_NAME and defaultLocale.
     */
    public static void setLogResourceBundle()
    {
        try
        {
            logResourceBundle.set(ResourceBundle.getBundle(logResourceBaseName.get(), currentLocale.get()));
        }
        catch (MissingResourceException e)
        {
            logResourceBundle.set(null);
        }
    }
}
