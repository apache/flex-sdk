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

package flash.util;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Method;
import java.util.NoSuchElementException;
import java.util.StringTokenizer;

// exceptions that are known to wrap other exceptions
import java.lang.reflect.InvocationTargetException;

/**
 * A utility for wrapping exceptions.
 *
 * @author Nick Tsivranidis
 */
public class ExceptionUtil 
{
    /**
     * List of no-arg methods that are known to return a wrapped throwable
     **/
    public static String[] unwrapMethods = { "getRootCause", "getTargetException", 
                                             "getTargetError", "getException", 
                                             "getCausedByException", "getLinkedException" };

	public static Throwable wrappedException(Throwable t)
	{
		// handle these statically since they are core to Java
		if (t instanceof InvocationTargetException)
		{
			return ((InvocationTargetException)t).getTargetException();
		}
        
		return getRootCauseWithReflection(t);
	}

    /**
     * Get to the base exception (if any)
     */
    public static Throwable baseException(Throwable t) {
        Throwable wrapped = wrappedException(t);
        if (wrapped != null)
            return baseException(wrapped);
        else
	    return t;
    }

    /**
     * return the stack trace in a String
     */
    public static String toString(Throwable t) {
        StringWriter strWrt = new StringWriter();
        t.printStackTrace(new PrintWriter(strWrt));

        return strWrt.toString();
    }

    /**
     * return the stack trace up to the first line that starts with prefix
     *
     * Example: ExceptionUtil.getStackTraceUpTo(exception, "jrunx.");
     */
    public static String getStackTraceUpTo(Throwable t, String prefix) {
	StringTokenizer tokens = new StringTokenizer(toString(t), "\n\r");
        
        StringBuilder trace = new StringBuilder();

        boolean done = false;

        String lookingFor = "at " + prefix;
        while (!done && tokens.hasMoreElements())
        {
            String token = tokens.nextToken();
            if (token.indexOf(lookingFor) == -1)
                trace.append(token);
            else
                done = true;
            trace.append("\n");
        }
        
        return trace.toString();
    }
    
    /**
     * return the top n lines of this stack trace
     *
     * Example: ExceptionUtil.getStackTraceLines(exception, 10);
     */
    public static String getStackTraceLines(Throwable t, int numLines) {
	StringTokenizer tokens = new StringTokenizer(toString(t), "\n\r");
        
        StringBuilder trace = new StringBuilder();

        for (int i=0; i<numLines; i++)
        {
            String token = tokens.nextToken();
            trace.append(token);
            trace.append("\n");
        }
        
        return trace.toString();
    }

    /**
     * Return the "nth" method call from the stack trace of "t", where 0 is
     * the top.
     */
    public static String getCallAt(Throwable t, int nth) {
	StringTokenizer tokens = new StringTokenizer(toString(t), "\n\r");
	try {
	    // Skip the first line - the exception message
	    for(int i = 0; i <= nth; ++i)
		tokens.nextToken();
            
            // get the method name from the next token
	    String token = tokens.nextToken();
	    int index1 = token.indexOf(' ');
	    int index2 = token.indexOf('(');
	    StringBuilder call = new StringBuilder();
	    call.append(token.substring(index1 < 0 ? 0 : index1 + 1, index2 < 0 ? call.length() : index2));

	    int index3 = token.indexOf(':', index2 < 0 ? 0 : index2);
	    if(index3 >= 0) {
		int index4 = token.indexOf(')', index3);
	        call.append(token.substring(index3, index4 < 0 ? token.length() : index4));
	    }
	    return call.toString();
	}
	catch(NoSuchElementException e) {}

	return "unknown";
    }
    

    /**
     * Utility method for converting an exception into a string. This
     * method unwinds all wrapped exceptions
     * @param t The throwable exception
     * @return The printable exception
     */
    public static String exceptionToString(Throwable t) 
    {
        StringWriter sw = new StringWriter();
        PrintWriter out = new PrintWriter(sw);

        //print out the exception stack.
        printExceptionStack(t, out, 0);
        return sw.toString();
    }

    /**
     * Recursively prints out a stack of wrapped exceptions.
     */
    protected static void printExceptionStack(Throwable th, PrintWriter out, int depth){
        //only print the stack depth if the depth is greater than 0
        boolean printStackDepth = depth>0;

        Throwable wrappedException = ExceptionUtil.wrappedException(th);
        if (wrappedException != null) 
        {
            printStackDepth = true;
            printExceptionStack(wrappedException, out, depth + 1);
        }
		
        if(printStackDepth){
            out.write("[" + depth + "]");
        }

        th.printStackTrace(out);
    }

    private static Throwable getRootCauseWithReflection(Throwable t)
    {
        for(int i = 0; i < unwrapMethods.length; i++)
        {
            Method m = null;

            try
            {
                m = t.getClass().getMethod(unwrapMethods[i], (Class[])null);
                return (Throwable) m.invoke(t, (Object[])null);
            }
            catch(Exception nsme)
            {
                // ignore
            }
        }
        
        return null;
    }
}
