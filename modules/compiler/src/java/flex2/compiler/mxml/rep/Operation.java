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

package flex2.compiler.mxml.rep;

/**
 * This class represents an operation instance.
 */
public class Operation
{
    public static final int CONCURRENCY_MULTIPLE    = 0;
    public static final int CONCURRENCY_SINGLE      = 1;
    public static final int CONCURRENCY_LAST        = 2;

    public String name;
    public EventHandler faultHandler;
    public EventHandler resultHandler;
    public int concurrency;
    public String resultFormat;
    public Model myRequest;
    public String showBusyCursor;
    public boolean makeObjectsBindable;

    public Operation(String name, String faultHandlerText, String resultHandlerText,
                     int concurrency, String resultFormat, int xmlLineNumber, String showBusyCursor,
                     boolean makeObjectsBindable)
    {
        this.name = name;

        if (faultHandlerText != null)
        {
            faultHandler = new EventHandler(null, null, faultHandlerText);
            faultHandler.setXmlLineNumber(xmlLineNumber);
        }

        if (resultHandlerText != null)
        {
            resultHandler = new EventHandler(null, null, resultHandlerText);
            resultHandler.setXmlLineNumber(xmlLineNumber);
        }

        this.concurrency = concurrency;
        this.resultFormat = resultFormat;
        this.showBusyCursor = showBusyCursor;
        this.makeObjectsBindable = makeObjectsBindable;
    }
}
