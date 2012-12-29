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
 * This implementation of the <tt>ExternalResourceSecurity</tt> interface only
 * allows external resources embeded in the document, i.e., externalResources
 * embeded with the data protocol.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: EmbededExternalResourceSecurity.java 475477 2006-11-15 22:44:28Z cam $
 */
public class EmbededExternalResourceSecurity implements ExternalResourceSecurity {
    public static final String DATA_PROTOCOL = "data";

    /**
     * Message when trying to load a external resource that is not embeded
     * in the document.
     */
    public static final String ERROR_EXTERNAL_RESOURCE_NOT_EMBEDED
        = "EmbededExternalResourceSecurity.error.external.esource.not.embeded";

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
            throw se;
        }
    }

    /**
     * @param externalResourceURL url for the externalResource, as defined in
     *        the externalResource's xlink:href attribute. If that
     *        attribute was empty, then this parameter should
     *        be null
     */
    public EmbededExternalResourceSecurity(ParsedURL externalResourceURL){
        if ( externalResourceURL == null
             ||
             !DATA_PROTOCOL.equals(externalResourceURL.getProtocol()) ) {
            se = new SecurityException
                (Messages.formatMessage(ERROR_EXTERNAL_RESOURCE_NOT_EMBEDED,
                                        new Object[]{externalResourceURL}));
            
            
        }
    }
}


    
