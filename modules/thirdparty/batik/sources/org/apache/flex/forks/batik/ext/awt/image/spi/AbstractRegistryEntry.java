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
package org.apache.flex.forks.batik.ext.awt.image.spi;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 *
 * @version $Id: AbstractRegistryEntry.java 501094 2007-01-29 16:35:37Z deweese $
 */
public abstract class AbstractRegistryEntry
    implements RegistryEntry, ErrorConstants {

    String name;
    float  priority;
    List   exts;
    List   mimeTypes;

    public AbstractRegistryEntry(String    name,
                                 float     priority,
                                 String [] exts,
                                 String [] mimeTypes) {
        this.name     = name;
        this.priority = priority;

        this.exts     = new ArrayList(exts.length);
        for (int i=0; i<exts.length; i++)
            this.exts.add(exts[i]);
        this.exts = Collections.unmodifiableList(this.exts);

        this.mimeTypes     = new ArrayList(mimeTypes.length);
        for (int i=0; i<mimeTypes.length; i++)
            this.mimeTypes.add(mimeTypes[i]);
        this.mimeTypes = Collections.unmodifiableList(this.mimeTypes);
    }

    public AbstractRegistryEntry(String name,
                                 float  priority,
                                 String ext,
                                 String mimeType) {
        this.name = name;
        this.priority = priority;

        this.exts = new ArrayList(1);
        this.exts.add(ext);
        this.exts = Collections.unmodifiableList(exts);

        this.mimeTypes = new ArrayList(1);
        this.mimeTypes.add(mimeType);
        this.mimeTypes = Collections.unmodifiableList(mimeTypes);
    }


    public String getFormatName() {
        return name;
    }

    public List   getStandardExtensions() {
        return exts;
    }

    public List   getMimeTypes() {
        return mimeTypes;
    }

    public float  getPriority() {
        return priority;
    }
}
