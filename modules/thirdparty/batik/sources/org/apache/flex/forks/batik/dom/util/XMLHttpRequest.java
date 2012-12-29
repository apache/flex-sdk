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
package org.apache.flex.forks.batik.dom.util;

import org.w3c.dom.Document;
import org.w3c.dom.events.EventListener;

/**
 * An interface for objects that can fetch HTTP resources.
 * <b>This interface will likely move to a different package at some point
 *   (perhaps org.w3c.dom.webapi).</b>
 *
 * @see <a href="http://www.w3.org/TR/XMLHttpRequest/">The XMLHttpRequest Object</a>
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id$
 */
public interface XMLHttpRequest {

    short UNSENT = 0;
    short OPENED = 1;
    short HEADERS_RECEIVED = 2;
    short LOADING = 3;
    short DONE = 4;

    EventListener getOnreadystatechange();

    void setOnreadystatechange(EventListener l);

    short getReadyState();

    void open(String method, String url);
    void open(String method, String url, boolean async);
    void open(String method, String url, boolean async, String user);
    void open(String method, String url, boolean async, String user,
              String password);
    void setRequestHeader(String header, String value);
    void send();
    void send(String data);
    void send(Document data);
    void abort();
    String getAllResponseHeaders();
    String getResponseHeader(String header);
    String getResponseText();
    String getResponseXML();
    short getStatus();
    String getStatusText();
}
