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
package org.apache.flex.forks.batik.apps.svgbrowser;

/**
 * This interface defines constants for the possible resource
 * origins.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: ResourceOrigin.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public interface ResourceOrigin {
    /**
     * Any origin
     */
    int ANY = 1;

    /**
     * Same as document
     */
    int DOCUMENT = 2;

    /**
     * Embeded into the document
     */
    int EMBEDED = 4;

    /**
     * No origin is ok
     */
    int NONE = 8;
}
