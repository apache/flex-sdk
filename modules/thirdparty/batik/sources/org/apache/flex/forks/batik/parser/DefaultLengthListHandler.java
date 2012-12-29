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
 * This class provides an adapter for LengthListHandler
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultLengthListHandler.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public class DefaultLengthListHandler
    extends    DefaultLengthHandler
    implements LengthListHandler {
    /**
     * The only instance of this class.
     */
    public static final LengthListHandler INSTANCE
        = new DefaultLengthListHandler();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultLengthListHandler() {
    }

    /**
     * Implements {@link LengthListHandler#startLengthList()}.
     */
    public void startLengthList() throws ParseException {
    }

    /**
     * Implements {@link LengthListHandler#endLengthList()}.
     */
    public void endLengthList() throws ParseException {
    }
}
