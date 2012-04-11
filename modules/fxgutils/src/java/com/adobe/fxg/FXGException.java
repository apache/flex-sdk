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

package com.adobe.fxg;

import java.util.Enumeration;
import java.util.Locale;
import java.util.ResourceBundle;

import com.adobe.fxg.util.FXGLocalizationUtil;

/**
 * Base type for exceptions encountered while processing FXG.
 */
public class FXGException extends RuntimeException
{
    private static final long serialVersionUID = -7393979231178285695L;

    private Object[] arguments;
    private String message;
    private int lineNumber;
    private int columnNumber;

    /**
     * Instantiates a new fXG exception.
     */
    public FXGException()
    {
        super();
        arguments = null;
        message = null;
        lineNumber = -1;
        columnNumber = -1;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param cause the cause
     */
    public FXGException(Throwable cause)
    {
        super(cause);
        this.arguments = null;
        message = null;
        lineNumber = -1;
        columnNumber = -1;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param message the message
     * @param cause the cause
     * @param arguments the arguments
     */
    public FXGException(String message, Throwable cause, Object... arguments)
    {
        super(message, cause);
        this.arguments = arguments;
        message = null;
        lineNumber = -1;
        columnNumber = -1;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param message the message
     * @param arguments the arguments
     */
    public FXGException(String message, Object... arguments)
    {
        super(message);
        this.arguments = arguments;
        message = null;
        lineNumber = -1;
        columnNumber = -1;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param lineNumber the line number
     * @param columnNumber the column number
     */
    public FXGException(int lineNumber, int columnNumber)
    {
        super();
        arguments = null;
        message = null;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param lineNumber the line number
     * @param columnNumber the column number
     * @param cause the cause
     */
    public FXGException(int lineNumber, int columnNumber, Throwable cause)
    {
        super(cause);
        this.arguments = null;
        message = null;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param lineNumber the line number
     * @param columnNumber the column number
     * @param message the message
     * @param cause the cause
     * @param arguments the arguments
     */
    public FXGException(int lineNumber, int columnNumber, String message, Throwable cause, Object... arguments)
    {
        super(message, cause);
        this.arguments = arguments;
        message = null;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
    }

    /**
     * Instantiates a new fXG exception.
     * 
     * @param lineNumber the line number
     * @param columnNumber the column number
     * @param message the message
     * @param arguments the arguments
     */
    public FXGException(int lineNumber, int columnNumber, String message, Object... arguments)
    {
        super(message);
        this.arguments = arguments;
        message = null;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
    }



    /**
     * Get non-localized message.
     * 
     * @see java.lang.Throwable#getMessage()
     */
    @Override
    public String getMessage()
    {
        // check if message is already cached
        if (message != null)
            return message;

        synchronized (FXGException.class)
        {
            FXGLocalizationUtil.setExceptionResourceBundle(null, null);
            message = getLocalizedMessage();
            return message;
        }
    }

    /**
     * Gets the line number.
     * 
     * @return the line number
     */
    public int getLineNumber()
    {
        return lineNumber;
    }
    
    /**
     * Gets the column number.
     * 
     * @return the column number
     */
    public int getColumnNumber()
    {
        return columnNumber;
    }
    
    /**
     * Get localized message.
     * 
     * @see java.lang.Throwable#getLocalizedMessage()
     */
    @Override
    public String getLocalizedMessage()
    {
        synchronized (FXGException.class)
        {
            ResourceBundle resourceBundle = FXGLocalizationUtil.getExceptionResourceBundle();
            String paramMsg = super.getMessage();
            if (resourceBundle != null)
            {
                Enumeration<String> keys = resourceBundle.getKeys();
                while (keys.hasMoreElements())
                {
                    String key = keys.nextElement();
                    if (key.equals(paramMsg))
                    {
                        paramMsg = resourceBundle.getString(super.getMessage());
                    }
                }
            }
            return FXGLocalizationUtil.substituteArguments(paramMsg, arguments);
        }
    }

    /**
     * Gets the localized message.
     * 
     * @param locale - the Locale to use for the message.
     * 
     * @return Returns localized error message for the Locale specified.
     */
    public String getLocalizedMessage(Locale locale)
    {
        synchronized (FXGException.class)
        {
            FXGLocalizationUtil.setLocale(locale);
            return getLocalizedMessage();
        }
    }
}