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
 *
 * @author  tonny@kiyut.com
 * @version $Id: DefaultNumberListHandler.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class DefaultNumberListHandler implements NumberListHandler {
    /**
     * The only instance of this class.
     */
    public static final NumberListHandler INSTANCE
        = new DefaultNumberListHandler();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultNumberListHandler() {
    }

    /**
     * Implements {@link NumberListHandler#startNumberList()}.
     */
    public void startNumberList() throws ParseException {
    }

    /**
     * Implements {@link NumberListHandler#endNumberList()}.
     */
    public void endNumberList() throws ParseException {
    }

    /**
     * Implements {@link NumberListHandler#startNumber()}.
     */
    public void startNumber() throws ParseException {
    }

    /**
     * Implements {@link NumberListHandler#numberValue(float)}.
     */
    public void numberValue(float v) throws ParseException {
    }

    /**
     * Implements {@link NumberListHandler#endNumber()}.
     */
    public void endNumber() throws ParseException {
    }

}
