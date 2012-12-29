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

import java.net.MalformedURLException;
import java.net.URL;

/**
 * Protocol Handler for the 'jar' protocol.
 * This appears to have the format:
 * jar:<URL for jar file>!<path in jar file>
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: ParsedURLJarProtocolHandler.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class ParsedURLJarProtocolHandler 
    extends ParsedURLDefaultProtocolHandler {

    public static final String JAR = "jar";

    public ParsedURLJarProtocolHandler() {
        super(JAR);
    }


    // We mostly use the base class parse methods (that leverage
    // java.net.URL.  But we take care to ignore the baseURL if urlStr
    // is an absolute URL.
    public ParsedURLData parseURL(ParsedURL baseURL, String urlStr) {
        String start = urlStr.substring(0, JAR.length()+1).toLowerCase();
        
        // urlStr is absolute...
        if (start.equals(JAR+":"))
            return parseURL(urlStr);

        // It's relative so base it off baseURL.
        try {
            URL context = new URL(baseURL.toString());
            URL url     = new URL(context, urlStr);
            return constructParsedURLData(url);
        } catch (MalformedURLException mue) {
            return super.parseURL(baseURL, urlStr);
        }
    }
}

