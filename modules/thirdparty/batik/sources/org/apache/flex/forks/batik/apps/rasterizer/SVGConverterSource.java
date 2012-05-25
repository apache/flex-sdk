/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.apps.rasterizer;

import java.io.IOException;
import java.io.InputStream;

/**
 * Interface used to handle both Files and URLs in the 
 * <tt>SVGConverter</tt>
 * 
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SVGConverterSource.java,v 1.5 2004/08/18 07:12:26 vhardy Exp $
 */
public interface SVGConverterSource {
    /**
     * Returns the name of the source. That would be the 
     * name for a File or URL
     */
    public String getName();
    
    /**
     * Gets a <tt>TranscoderInput</tt> for that source
     */
    public InputStream openStream() throws IOException;
    
    /**
     * Checks if same as source described by srcStr
     */
    public boolean isSameAs(String srcStr);
    
    /**
     * Checks if source can be read
     */
    public boolean isReadable();

    /**
     * Returns a URI string corresponding to this source
     */
    public String getURI();
}

