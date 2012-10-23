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
package org.apache.flex.forks.batik.anim;

import org.apache.flex.forks.batik.anim.timing.TimedElement;

/**
 * An exception class for SMIL animation exceptions.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimationException.java 475954 2006-11-16 22:34:04Z cam $
 */
public class AnimationException extends RuntimeException {

    /**
     * The timed element on which the error occurred.
     */
    protected TimedElement e;

    /**
     * The error code.
     */
    protected String code;

    /**
     * The parameters to use for the error message.
     */
    protected Object[] params;

    /**
     * The message.
     */
    protected String message;

    /**
     * Creates a new AnimationException.
     * @param e the animation element on which the error occurred
     * @param code the error code
     * @param params the parameters to use for the error message
     */
    public AnimationException(TimedElement e, String code, Object[] params) {
        this.e = e;
        this.code = code;
        this.params = params;
    }

    /**
     * Returns the timed element that caused this animation exception.
     */
    public TimedElement getElement() {
        return e;
    }

    /**
     * Returns the error code.
     */
    public String getCode() {
        return code;
    }

    /**
     * Returns the error message parameters.
     */
    public Object[] getParams() {
        return params;
    }

    /**
     * Returns the error message according to the error code and parameters.
     */
    public String getMessage() {
        return TimedElement.formatMessage(code, params);
    }
}
