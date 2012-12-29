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

import java.util.Map;

/**
 * This is a utility class that can be used by transcoders that
 * support transcoding hints and/or error handler.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: TranscoderSupport.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TranscoderSupport {

    static final ErrorHandler defaultErrorHandler = new DefaultErrorHandler();

    /** The transcoding hints. */
    protected TranscodingHints hints = new TranscodingHints();
    /** The error handler used to report warnings and errors. */
    protected ErrorHandler handler = defaultErrorHandler;

    /**
     * Constructs a new <tt>TranscoderSupport</tt>.
     */
    public TranscoderSupport() { }

    /**
     * Returns a copy of the transcoding hints of this transcoder.
     */
    public TranscodingHints getTranscodingHints() {
        return new TranscodingHints(hints);
    }

    /**
     * Sets the value of a single preference for the transcoding process.
     * @param key the key of the hint to be set
     * @param value the value indicating preferences for the specified
     * hint category.
     */
    public void addTranscodingHint(TranscodingHints.Key key, Object value) {
        hints.put(key, value);
    }

    /**
     * Removes the value of a single preference for the transcoding process.
     * @param key the key of the hint to remove
     */
    public void removeTranscodingHint(TranscodingHints.Key key) {
        hints.remove(key);
    }

    /**
     * Replaces the values of all preferences for the transcoding algorithms
     * with the specified hints.
     * @param hints the rendering hints to be set
     */
    public void setTranscodingHints(Map hints) {
        this.hints.putAll(hints);
    }

    /**
     * Sets the values of all preferences for the transcoding algorithms
     * with the specified hints.
     * @param hints the rendering hints to be set
     */
    public void setTranscodingHints(TranscodingHints hints) {
        this.hints = hints;
    }

    /**
     * Sets the error handler this transcoder may use to report
     * warnings and errors.
     * @param handler to ErrorHandler to use
     */
    public void setErrorHandler(ErrorHandler handler) {
        this.handler = handler;
    }

    /**
     * Returns the error handler this transcoder uses to report
     * warnings and errors, or null if any.
     */
    public ErrorHandler getErrorHandler() {
        return handler;
    }
}


