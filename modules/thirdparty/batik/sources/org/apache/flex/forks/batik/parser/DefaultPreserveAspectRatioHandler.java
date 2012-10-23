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
package org.apache.flex.forks.batik.parser;

/**
 * This class provides an adapter for PreserveAspectRatioHandler.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultPreserveAspectRatioHandler.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public class DefaultPreserveAspectRatioHandler
    implements PreserveAspectRatioHandler {
    /**
     * The only instance of this class.
     */
    public static final PreserveAspectRatioHandler INSTANCE
        = new DefaultPreserveAspectRatioHandler();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultPreserveAspectRatioHandler() {
    }

    /**
     * Implements {@link
     * PreserveAspectRatioHandler#startPreserveAspectRatio()}.
     */
    public void startPreserveAspectRatio() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#none()}.
     */
    public void none() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMaxYMax()}.
     */
    public void xMaxYMax() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMaxYMid()}.
     */
    public void xMaxYMid() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMaxYMin()}.
     */
    public void xMaxYMin() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMidYMax()}.
     */
    public void xMidYMax() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMidYMid()}.
     */
    public void xMidYMid() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMidYMin()}.
     */
    public void xMidYMin() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMinYMax()}.
     */
    public void xMinYMax() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMinYMid()}.
     */
    public void xMinYMid() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#xMinYMin()}.
     */
    public void xMinYMin() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#meet()}.
     */
    public void meet() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#slice()}.
     */
    public void slice() throws ParseException {
    }

    /**
     * Implements {@link PreserveAspectRatioHandler#endPreserveAspectRatio()}.
     */
    public void endPreserveAspectRatio() throws ParseException {
    }
}
