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
package org.apache.flex.forks.batik.util;

/**
 * Provider interface for new url protocols, used by the ParsedURL class.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: ParsedURLProtocolHandler.java 478169 2006-11-22 14:23:24Z dvholten $
 */
public interface ParsedURLProtocolHandler {
    /**
     * Returns the protocol to be handled by this class.
     * The protocol must _always_ be the part of the URL before the
     * first ':'.
     */
    String getProtocolHandled();
    /**
     * Parse an absolute url string.
     */
    ParsedURLData parseURL(String urlStr);
    /**
     * Parse a relative url string of this protocol.
     */
    ParsedURLData parseURL(ParsedURL basepurl, String urlStr);
}

