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

/**
 * A simple interface to report information while processing an FXG docuemnt.
 */
public interface FXGLogger
{
    
    /** The Constant ALL. */
    public static final int ALL = 0;
    
    /** The Constant DEBUG. */
    public static final int DEBUG = 10000;
    
    /** The Constant INFO. */
    public static final int INFO = 20000;
    
    /** The Constant WARN. */
    public static final int WARN = 30000;
    
    /** The Constant ERROR. */
    public static final int ERROR = 40000;
    
    /** The Constant NONE. */
    public static final int NONE = Integer.MAX_VALUE;

    /**
     * Gets the level.
     * 
     * @return the level
     */
    int getLevel();
    
    /**
     * Sets the level.
     * 
     * @param level the new level
     */
    void setLevel(int level);

    /**
     * Log a debug message. The message code is used to retrieve the localized 
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * @param message Log message code.
     */
    void debug(Object message);
    
    /**
     * Log a debug message with a Throwable. The message code is used to
     * retrieve the localized message. If a locale is not specified,
     * DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     */
    void debug(Object message, Throwable t);
    
    /**
     * Log a debug message with a Throwable, location, line and column number.
     * The message code is used to retrieve the localized message. If a locale
     * is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     */
    void debug(Object message, Throwable t, String location, int line, int column);
    
    /**
     * Log a debug message with a Throwable, location, line, column number and
     * parameter values. The message code is used to retrieve the localized
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     * @param arguments the arguments
     */
    void debug(Object message, Throwable t, String location, int line, int column, Object... arguments);

    /**
     * Log an error message. The message code is used to retrieve the localized 
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * @param message Log message code.
     */
    void error(Object message);
    
    /**
     * Log an error message with a Throwable. The message code is used to
     * retrieve the localized message. If a locale is not specified,
     * DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     */
    void error(Object message, Throwable t);
    
    /**
     * Log an error message with a Throwable, location, line and column number.
     * The message code is used to retrieve the localized message. If a locale
     * is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     */
    void error(Object message, Throwable t, String location, int line, int column);
    
    /**
     * Log an error message with a Throwable, location, line, column number and
     * parameter values. The message code is used to retrieve the localized
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     * @param arguments the arguments
     */
    void error(Object message, Throwable t, String location, int line, int column, Object... arguments);
    
    /**
     * Log an info message. The message code is used to retrieve the localized 
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * @param message Log message code.
     */
    void info(Object message);
    
    /**
     * Log an info message with a Throwable. The message code is used to
     * retrieve the localized message. If a locale is not specified,
     * DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     */
    void info(Object message, Throwable t);
    
    /**
     * Log an info message with a Throwable, location, line and column number.
     * The message code is used to retrieve the localized message. If a locale
     * is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     */
    void info(Object message, Throwable t, String location, int line, int column);
    
    /**
     * Log an info message with a Throwable, location, line, column number and
     * parameter values. The message code is used to retrieve the localized
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     * @param arguments the arguments
     */
    void info(Object message, Throwable t, String location, int line, int column, Object... arguments);

    /**
     * Log a message with a given level. The message code is used to retrieve
     * the localized message. If a locale is not specified, DEFAULT_LOCAL is
     * used.
     * 
     * @param message Log message code.
     * @param level the level
     */
    void log(int level, Object message);
    
    /**
     * Log a message with a level and throwable. The message code is
     * used to retrieve the localized message. If a locale is not specified,
     * DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param level the level
     * @param t the t
     */
    void log(int level, Object message, Throwable t);
    
    /**
     * Log a message with a level, throwable, location, line and column
     * number. The message code is used to retrieve the localized message.
     * If a locale is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param level the level
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     */
    void log(int level, Object message, Throwable t, String location, int line, int column);
    
    /**
     * Log a message with a level, throwable, location, line, column number and
     * parameter values. The message code is used to retrieve the localized
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param level the level
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     * @param arguments the arguments
     */
    void log(int level, Object message, Throwable t, String location, int line, int column, Object... arguments);

    /**
     * Log a warning message. The message code is used to retrieve the localized 
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * @param message Log message code.
     */    
    void warn(Object message);
    
    /**
     * Log a warning message with a Throwable. The message code is used to
     * retrieve the localized message. If a locale is not specified,
     * DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     */
    void warn(Object message, Throwable t);
    
    /**
     * Log a warning message with a Throwable, location, line and column number.
     * The message code is used to retrieve the localized message. If a locale
     * is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     */
    void warn(Object message, Throwable t, String location, int line, int column);
    
    /**
     * Log a warning message with a Throwable, location, line, column number and
     * parameter values. The message code is used to retrieve the localized
     * message. If a locale is not specified, DEFAULT_LOCAL is used.
     * 
     * @param message Log message code.
     * @param t the t
     * @param location the location
     * @param line the line
     * @param column the column
     * @param arguments the arguments
     */
    void warn(Object message, Throwable t, String location, int line, int column, Object... arguments);
}
