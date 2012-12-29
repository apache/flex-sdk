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


/**
 * This implementation does not allow any external resources to be 
 * referenced from an SVG document.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: NoLoadExternalResourceSecurity.java 475477 2006-11-15 22:44:28Z cam $
 */
public class NoLoadExternalResourceSecurity implements ExternalResourceSecurity {
    /**
     * Message when trying to load an external resource
     */
    public static final String ERROR_NO_EXTERNAL_RESOURCE_ALLOWED
        = "NoLoadExternalResourceSecurity.error.no.external.resource.allowed";

    /**
     * The exception is built in the constructor and thrown if 
     * not null and the checkLoadExternalResource method is called.
     */
    protected SecurityException se;

    /**
     * Controls whether the external resource should be loaded or not.
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
     */
    public NoLoadExternalResourceSecurity(){
        se = new SecurityException
            (Messages.formatMessage(ERROR_NO_EXTERNAL_RESOURCE_ALLOWED,
                                    null));
        
    }
}


    
