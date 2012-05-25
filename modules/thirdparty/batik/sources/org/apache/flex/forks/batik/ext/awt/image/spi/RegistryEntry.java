/*

   Copyright 2001  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image.spi;

import java.util.List;

/**
 * The base interface for all image tag registry entries.  To be useful you
 * probably need to implement on of the flavors of registry entries (such as
 * StreamRegistryEntry or URLRegistryEntry).  
 */
public interface RegistryEntry {

    /**
     * Return a List of the common extensions for this file format. The first
     * entry in the list may be used as the default extension for writing files
     * in this format (when we add support for writing that is).  This may also
     * be used to build a selection expression for finding files of this type.
     */
    List getStandardExtensions();

    /**
     * Return a List of mime types for this file format.  The first entry in the
     * list may be used as the default mime type.  */
    List getMimeTypes();

    /**
     * Returns the name of the format. For example "JPEG", "PNG", ...
     */
    String getFormatName();

    /**
     * Returns a search priority for this entry.  For most formats this is not
     * important, but in some cases it is important that some entries occure
     * before or after others.  
     */
    float  getPriority();
}
