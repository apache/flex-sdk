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

import java.net.URL;
import java.net.URLClassLoader;
import java.security.CodeSource;
import java.security.cert.Certificate;
import java.security.Permission;
import java.security.PermissionCollection;
import java.security.Policy;
import java.util.Enumeration;

/**
 * This <tt>ClassLoader</tt> implementation only grants permission to
 * connect back to the server from where the document referencing the
 * jar file was loaded. 
 * 
 * A <tt>URLClassLoader</tt> extension is needed in case the user
 * allows linked jar files to come from a different origin than
 * the document referencing them.
 *
 * @author <a mailto="vincent.hardy@sun.com">Vincent Hardy</a>
 * @version $Id: DocumentJarClassLoader.java 475685 2006-11-16 11:16:05Z cam $
 */
public class DocumentJarClassLoader extends URLClassLoader {
    /**
     * CodeSource for the Document which referenced the Jar file
     * @see #getPermissions
     */
    protected CodeSource documentCodeSource = null;

    /**
     * Constructor
     */
    public DocumentJarClassLoader(URL jarURL,
                                  URL documentURL){
        super(new URL[]{jarURL});

        if (documentURL != null) {
            documentCodeSource = new CodeSource
                (documentURL, (Certificate[])null);
        }
    }

    /**
     * Returns the permissions for the given codesource object.
     * The implementation of this method first gets the permissions
     * granted by the policy, and then adds additional permissions
     * based on the URL of the codesource.
     * <p>
     * Then, if the documentURL passed at construction time is
     * not null, the permissions granted to that URL are added.
     *
     * As a result, the jar file code will only be able to 
     * connect to the server which served the document.
     *
     * @param codesource the codesource
     * @return the permissions granted to the codesource
     */
    protected PermissionCollection getPermissions(CodeSource codesource)
    {
        // First, get the permissions which may be granted 
        // through the policy file(s)
        Policy p = Policy.getPolicy();

        PermissionCollection pc = null;
        if (p != null) {
            pc = p.getPermissions(codesource);
        }

        // Now, add permissions if the documentCodeSource is not null
        if (documentCodeSource != null){
            PermissionCollection urlPC 
                = super.getPermissions(documentCodeSource);

            if (pc != null) {
                Enumeration items = urlPC.elements();
                while (items.hasMoreElements()) {
                    pc.add((Permission)(items.nextElement()));
                }
            } else {
                pc = urlPC;
            }
        }

        return pc;
    }
}
