/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.xml;

/**
 * This class encapsulates a general XML error or warning.
 *
 * <p>This class can contain basic error or warning information from
 * either the parser or the application.
 *
 * <p>If the application needs to pass through other types of
 * exceptions, it must wrap those exceptions in a XMLException.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: XMLException.java 475685 2006-11-16 11:16:05Z cam $
 */
public class XMLException extends RuntimeException {

    /**
     * @serial The embedded exception if tunnelling, or null.
     */    
    protected Exception exception;

    /**
     * Creates a new XMLException.
     * @param message The error or warning message.
     */
    public XMLException (String message) {
        super(message);
        exception = null;
    }
    
    /**
     * Creates a new XMLException wrapping an existing exception.
     *
     * <p>The existing exception will be embedded in the new
     * one, and its message will become the default message for
     * the XMLException.
     * @param e The exception to be wrapped in a XMLException.
     */
    public XMLException (Exception e) {
        exception = e;
    }
    
    /**
     * Creates a new XMLException from an existing exception.
     *
     * <p>The existing exception will be embedded in the new
     * one, but the new exception will have its own message.
     * @param message The detail message.
     * @param e The exception to be wrapped in a SAXException.
     */
    public XMLException (String message, Exception e) {
        super(message);
        exception = e;
    }
    
    /**
     * Return a detail message for this exception.
     *
     * <p>If there is a embedded exception, and if the XMLException
     * has no detail message of its own, this method will return
     * the detail message from the embedded exception.
     * @return The error or warning message.
     */
    public String getMessage () {
        String message = super.getMessage();
        
        if (message == null && exception != null) {
            return exception.getMessage();
        } else {
            return message;
        }
    }
    
    /**
     * Return the embedded exception, if any.
     * @return The embedded exception, or null if there is none.
     */
    public Exception getException () {
        return exception;
    }

    /**
     * Prints this <code>Exception</code> and its backtrace to the 
     * standard error stream.
     */
    public void printStackTrace() { 
        if (exception == null) {
            super.printStackTrace();
        } else {
            synchronized (System.err) {
                System.err.println(this);
                super.printStackTrace();
            }
        }
    }

    /**
     * Prints this <code>Exception</code> and its backtrace to the 
     * specified print stream.
     *
     * @param s <code>PrintStream</code> to use for output
     */
    public void printStackTrace(java.io.PrintStream s) { 
        if (exception == null) {
            super.printStackTrace(s);
        } else {
            synchronized (s) {
                s.println(this);
                super.printStackTrace();
            }
        }
    }

    /**
     * Prints this <code>Exception</code> and its backtrace to the specified
     * print writer.
     *
     * @param s <code>PrintWriter</code> to use for output
     */
    public void printStackTrace(java.io.PrintWriter s) { 
        if (exception == null) {
            super.printStackTrace(s);
        } else {
            synchronized (s) {
                s.println(this);
                super.printStackTrace(s);
            }
        }
    }
}
