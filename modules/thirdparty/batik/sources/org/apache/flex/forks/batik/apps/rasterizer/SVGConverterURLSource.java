/*

   Copyright 1999-2003  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.util.ParsedURL;

/*
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SVGConverterURLSource.java,v 1.6 2004/10/30 18:38:04 deweese Exp $
 */
public class SVGConverterURLSource implements SVGConverterSource {
    /** 
     * SVG file extension 
     */
    protected static final String SVG_EXTENSION = ".svg";
    protected static final String SVGZ_EXTENSION = ".svgz";

    //
    // Reported when the URL for one of the sources is
    // invalid. This will happen if the URL is malformed or
    // if the URL file does not end with the ".svg" extension.
    // This is needed to be able to create a file name for
    // the ouptut automatically.
    //
    public static final String ERROR_INVALID_URL
        = "SVGConverterURLSource.error.invalid.url";

    ParsedURL purl;
    String name;

    public SVGConverterURLSource(String url) throws SVGConverterException{
        this.purl = new ParsedURL(url);

        // Get the path portion
        String path = this.purl.getPath();
        if (path == null || 
            !(path.toLowerCase().endsWith(SVG_EXTENSION) ||
              path.toLowerCase().endsWith(SVGZ_EXTENSION))){
            throw new SVGConverterException(ERROR_INVALID_URL,
                                            new Object[]{url});
        }

        int n = path.lastIndexOf("/");
        if (n != -1){
            // The following is safe because we know there is at least ".svg"
            // after the slash.
            path = path.substring(n+1);
        }
            
        name = path;

        //
        // The following will force creation of different output file names
        // for urls with references (e.g., anne.svg#svgView(viewBox(0,0,4,5)))
        //
        String ref = this.purl.getRef();
        if (ref != null && (ref.length()!=0)) {
            name += "" + ref.hashCode();
        }
    }

    public String toString(){
        return purl.toString();
    }

    public String getURI(){
        return toString();
    }

    public boolean equals(Object o){
        if (o == null || !(o instanceof SVGConverterURLSource)){
            return false;
        }

        return purl.equals(((SVGConverterURLSource)o).purl);
    }

    public InputStream openStream() throws IOException {
        return purl.openStream();
    }

    public boolean isSameAs(String srcStr){
        return toString().equals(srcStr);
    }

    public boolean isReadable(){
        return true;
    }

    public String getName(){
        return name;
    }
}
