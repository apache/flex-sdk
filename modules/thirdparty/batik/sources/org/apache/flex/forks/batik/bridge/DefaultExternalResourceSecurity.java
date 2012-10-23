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
package org.apache.flex.forks.batik.bridge;

import org.apache.flex.forks.batik.util.ParsedURL;

/**
 * Default implementation for the <tt>ExternalResourceSecurity</tt> interface.
 * It allows all types of external resources to be loaded, but only if they
 * come from the same server as the document they are referenced from.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: DefaultExternalResourceSecurity.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DefaultExternalResourceSecurity implements ExternalResourceSecurity {
    public static final String DATA_PROTOCOL = "data";
    /**
     * Message when trying to load a external resource file and the Document
     * does not have a URL
     */
    public static final String ERROR_CANNOT_ACCESS_DOCUMENT_URL
        = "DefaultExternalResourceSecurity.error.cannot.access.document.url";

    /**
     * Message when trying to load a externalResource file from a server 
     * different than the one of the document.
     */
    public static final String ERROR_EXTERNAL_RESOURCE_FROM_DIFFERENT_URL
        = "DefaultExternalResourceSecurity.error.external.resource.from.different.url";

    /**
     * The exception is built in the constructor and thrown if 
     * not null and the checkLoadExternalResource method is called.
     */
    protected SecurityException se;

    /**
     * Controls whether the externalResource should be loaded or not.
     *
     * @throws SecurityException if the externalResource should not be loaded.
     */
    public void checkLoadExternalResource(){
        if (se != null) {
            se.fillInStackTrace();
            throw se;
        }
    }

    /**
     * @param externalResourceURL url for the externalResource, as defined in
     *        the externalResource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     * @param docURL url for the document into which the 
     *        externalResource was found.
     */
    public DefaultExternalResourceSecurity(ParsedURL externalResourceURL,
                                           ParsedURL docURL){
        // Make sure that the archives comes from the same host
        // as the document itself
        if (docURL == null) {
            se = new SecurityException
                (Messages.formatMessage(ERROR_CANNOT_ACCESS_DOCUMENT_URL,
                                        new Object[]{externalResourceURL}));
        } else {
            String docHost    = docURL.getHost();
            String externalResourceHost = externalResourceURL.getHost();
            
            if ((docHost != externalResourceHost) &&
                ((docHost == null) || (!docHost.equals(externalResourceHost)))){
                
                if ( externalResourceURL == null
                     ||
                     !DATA_PROTOCOL.equals(externalResourceURL.getProtocol()) ) {
                se = new SecurityException
                    (Messages.formatMessage(ERROR_EXTERNAL_RESOURCE_FROM_DIFFERENT_URL,
                                            new Object[]{externalResourceURL}));
                }
                
            }
        }
    }
}


    
