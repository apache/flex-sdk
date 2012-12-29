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
package org.apache.flex.forks.batik.css.parser;

import org.w3c.css.sac.CSSParseException;
import org.w3c.css.sac.ErrorHandler;

/**
 * This class provides a default implementation of the
 * {@link ErrorHandler} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultErrorHandler.java 478283 2006-11-22 18:53:40Z dvholten $
 */
public class DefaultErrorHandler implements ErrorHandler {

    /**
     * The instance of this class.
     */
    public static final ErrorHandler INSTANCE = new DefaultErrorHandler();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultErrorHandler() {
    }

    /**
     * <b>SAC</b>: Implements {ErrorHandler#warning(CSSParseException)}.
     */
    public void warning(CSSParseException e) {
        // Do nothing
    }

    /**
     * <b>SAC</b>: Implements {ErrorHandler#error(CSSParseException)}.
     */
    public void error(CSSParseException e) {
        // Do nothing
    }

    /**
     * <b>SAC</b>: Implements {ErrorHandler#fatalError(CSSParseException)}.
     */
    public void fatalError(CSSParseException e) {
        throw e;
    }
}
