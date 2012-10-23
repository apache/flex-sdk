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

/**
 * Signals a format error in a resource bundle
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ResourceFormatException.java 592619 2007-11-07 05:47:24Z cam $
 */
public class ResourceFormatException extends RuntimeException {

    /**
     * The class name of the resource bundle requested
     * @serial
     */
    protected String className;

    /**
     * The name of the specific resource requested by the user
     * @serial
     */
    protected String key;

    /**
     * Constructs a ResourceFormatException with the specified information.
     * A detail message is a String that describes this particular exception.
     * @param s the detail message
     * @param className the name of the resource class
     * @param key the key for the malformed resource.
     */
    public ResourceFormatException(String s, String className, String key) {
        super(s);
        this.className = className;
        this.key = key;
    }

    /**
     * Gets parameter passed by constructor.
     */
    public String getClassName() {
        return className;
    }

    /**
     * Gets parameter passed by constructor.
     */
    public String getKey() {
        return key;
    }

    /**
     * Returns a printable representation of this object
     */
    public String toString() {
        return super.toString()+" ("+getKey()+", bundle: "+getClassName()+")";
    }
}
