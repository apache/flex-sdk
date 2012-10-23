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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * This class handles looking up service providers on the class path.
 * It implements the system described in:
 *
 * <a href='http://java.sun.com/j2se/1.3/docs/guide/jar/jar.html#Service Provider'>JAR
 * File Specification Under Service Provider</a>. Note that this
 * interface is very similar to the one they describe which seems to
 * be missing in the JDK.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: Service.java 522271 2007-03-25 14:42:45Z dvholten $
 */
public class Service {

    // Remember providers we have looked up before.
    static HashMap providerMap = new HashMap();

    /**
     * Returns an iterator where each element should implement the
     * interface (or subclass the baseclass) described by cls.  The
     * Classes are found by searching the classpath for service files
     * named: 'META-INF/services/&lt;fully qualified classname&gt; that list
     * fully qualifted classnames of classes that implement the
     * service files classes interface.  These classes must have
     * default constructors.
     *
     * @param cls The class/interface to search for providers of.
     */
    public static synchronized Iterator providers(Class cls) {
        String serviceFile = "META-INF/services/"+cls.getName();

        // System.out.println("File: " + serviceFile);

        List l = (List)providerMap.get(serviceFile);
        if (l != null)
            return l.iterator();

        l = new ArrayList();
        providerMap.put(serviceFile, l);

        ClassLoader cl = null;
        try {
            cl = cls.getClassLoader();
        } catch (SecurityException se) {
            // Ooops! can't get his class loader.
        }
        // Can always request your own class loader. But it might be 'null'.
        if (cl == null) cl = Service.class.getClassLoader();

        // No class loader so we can't find 'serviceFile'.
        if (cl == null) return l.iterator();

        Enumeration e;
        try {
            e = cl.getResources(serviceFile);
        } catch (IOException ioe) {
            return l.iterator();
        }

        while (e.hasMoreElements()) {
            InputStream    is = null;
            Reader         r  = null;
            BufferedReader br = null;
            try {
                URL u = (URL)e.nextElement();
                // System.out.println("URL: " + u);

                is = u.openStream();
                r  = new InputStreamReader(is, "UTF-8");
                br = new BufferedReader(r);

                String line = br.readLine();
                while (line != null) {
                    try {
                        // First strip any comment...
                        int idx = line.indexOf('#');
                        if (idx != -1)
                            line = line.substring(0, idx);

                        // Trim whitespace.
                        line = line.trim();

                        // If nothing left then loop around...
                        if (line.length() == 0) {
                            line = br.readLine();
                            continue;
                        }
                        // System.out.println("Line: " + line);

                        // Try and load the class
                        Object obj = cl.loadClass(line).newInstance();
                        // stick it into our vector...
                        l.add(obj);
                    } catch (Exception ex) {
                        // Just try the next line
                    }
                    line = br.readLine();
                }
            } catch (Exception ex) {
                // Just try the next file...
            } catch (LinkageError le) {
                // Just try the next file...
            } finally {
                // close and release all io-resources to avoid leaks
                if ( is != null ){
                    try {
                        is.close();
                    } catch ( IOException ignored ){}
                    is = null;
                }
                if ( r != null ){
                    try{
                        r.close();
                    } catch ( IOException ignored ){}
                    r = null;
                }
                if ( br == null ){
                    try{
                        br.close();
                    } catch ( IOException ignored ){}
                    br = null;
                }
            }
        }
        return l.iterator();
    }
}
