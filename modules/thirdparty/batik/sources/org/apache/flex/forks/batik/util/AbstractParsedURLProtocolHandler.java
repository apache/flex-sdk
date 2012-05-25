/*

   Copyright 2001  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.util;

/**
 * Very simple abstract base class for ParsedURLProtocolHandlers.
 * Just handles the 'what protocol part'.
 */
public abstract class AbstractParsedURLProtocolHandler 
 implements ParsedURLProtocolHandler {

    protected String protocol;

    /**
     * Constrcut a ProtocolHandler for <tt>protocol</tt>
     */
    public AbstractParsedURLProtocolHandler(String protocol) {
        this.protocol = protocol;
    }


    /**
     * Returns the protocol to be handled by this class.
     * The protocol must _always_ be the part of the URL before the
     * first ':'.
     */
    public String getProtocolHandled() {
        return protocol;
    }
}

