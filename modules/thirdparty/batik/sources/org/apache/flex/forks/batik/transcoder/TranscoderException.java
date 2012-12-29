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
package org.apache.flex.forks.batik.transcoder;

/**
 * Thrown when a transcoder is not able to transcode its input.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TranscoderException.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TranscoderException extends Exception {

    /** The enclosed exception. */
    protected Exception ex;

    /**
     * Constructs a new transcoder exception with the specified detail message.
     * @param s the detail message of this exception
     */
    public TranscoderException(String s) {
        this(s, null);
    }

    /**
     * Constructs a new transcoder exception with the specified detail message.
     * @param ex the enclosed exception
     */
    public TranscoderException(Exception ex) {
        this(null, ex);
    }

    /**
     * Constructs a new transcoder exception with the specified detail message.
     * @param s the detail message of this exception
     * @param ex the original exception
     */
    public TranscoderException(String s, Exception ex) {
        super(s);
        this.ex = ex;
    }

    /**
     * Returns the message of this exception. If an error message has
     * been specified, returns that one. Otherwise, return the error message
     * of enclosed exception or null if any.
     */
    public String getMessage() {
        String msg = super.getMessage();
        if (ex != null) {
            msg += "\nEnclosed Exception:\n";
            msg += ex.getMessage();
        }
        return msg;
    }

    /**
     * Returns the original enclosed exception or null if any.
     */
    public Exception getException() {
        return ex;
    }
}
