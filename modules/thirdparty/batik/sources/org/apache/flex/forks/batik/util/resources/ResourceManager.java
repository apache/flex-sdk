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
package org.apache.flex.forks.batik.util.resources;

import java.util.ArrayList;
import java.util.List;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.StringTokenizer;

/**
 * This class offers convenience methods to decode
 * resource bundle entries
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ResourceManager.java 592619 2007-11-07 05:47:24Z cam $
 */
public class ResourceManager {

    /**
     * The managed resource bundle
     */
    protected ResourceBundle bundle;

    /**
     * Creates a new resource manager
     * @param rb a resource bundle
     */
    public ResourceManager(ResourceBundle rb) {
        bundle = rb;
    }

    /**
     * Returns the string that is mapped with the given key
     * @param  key a key in the resource bundle
     * @throws MissingResourceException if key is not the name of a resource
     */
    public String getString(String key)
        throws MissingResourceException {
        return bundle.getString(key);
    }

    /**
     * Returns the tokens that compose the string mapped
     * with the given key. Delimiters (" \t\n\r\f") are not returned.
     * @param  key          a key of the resource bundle
     * @throws MissingResourceException if key is not the name of a resource
     */
    public List getStringList(String key)
        throws MissingResourceException {
        return getStringList(key, " \t\n\r\f", false);
    }

    /**
     * Returns the tokens that compose the string mapped
     * with the given key. Delimiters are not returned.
     * @param  key          a key of the resource bundle
     * @param  delim        the delimiters of the tokens
     * @throws MissingResourceException if key is not the name of a resource
     */
    public List getStringList(String key, String delim)
        throws MissingResourceException {
        return getStringList(key, delim, false);
    }

    /**
     * Returns the tokens that compose the string mapped
     * with the given key
     * @param  key          a key of the resource bundle
     * @param  delim        the delimiters of the tokens
     * @param  returnDelims if true, the delimiters are returned in the list
     * @throws MissingResourceException if key is not the name of a resource
     */
    public List getStringList(String key, String delim, boolean returnDelims) 
        throws MissingResourceException {
        List            result = new ArrayList();
        StringTokenizer st     = new StringTokenizer(getString(key),
                                                     delim,
                                                     returnDelims);
        while (st.hasMoreTokens()) {
            result.add(st.nextToken());
        }
        return result;
    }

    /**
     * Returns the boolean mapped with the given key
     * @param  key a key of the resource bundle
     * @throws MissingResourceException if key is not the name of a resource
     * @throws ResourceFormatException if the resource is malformed
     */
    public boolean getBoolean(String key)
        throws MissingResourceException, ResourceFormatException {
        String b = getString(key);

        if (b.equals("true")) {
            return true;
        } else if (b.equals("false")) {
            return false;
        } else {
            throw new ResourceFormatException("Malformed boolean",
                                              bundle.getClass().getName(),
                                              key);
        }
    }

    /**
     * Returns the integer mapped with the given string
     * @param key a key of the resource bundle
     * @throws MissingResourceException if key is not the name of a resource
     * @throws ResourceFormatException if the resource is malformed
     */
    public int getInteger(String key)
        throws MissingResourceException, ResourceFormatException {
        String i = getString(key);
        
        try {
            return Integer.parseInt(i);
        } catch (NumberFormatException e) {
            throw new ResourceFormatException("Malformed integer",
                                              bundle.getClass().getName(),
                                              key);
        }
    }

    public int getCharacter(String key)
        throws MissingResourceException, ResourceFormatException {
        String s = getString(key);
        
        if(s == null || s.length() == 0){
            throw new ResourceFormatException("Malformed character",
                                              bundle.getClass().getName(),
                                              key);
        }

        return s.charAt(0);
    }

}
