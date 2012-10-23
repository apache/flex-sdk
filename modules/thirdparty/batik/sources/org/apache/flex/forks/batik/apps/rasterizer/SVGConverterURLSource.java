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

package org.apache.flex.forks.batik.apps.rasterizer;

import java.io.IOException;
import java.io.InputStream;

import org.apache.flex.forks.batik.util.ParsedURL;

/*
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SVGConverterURLSource.java 475477 2006-11-15 22:44:28Z cam $
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
        int n = path.lastIndexOf('/');
        String file = path;
        if (n != -1){
            // The following is safe because we know there is at least ".svg"
            // after the slash.
            file = path.substring(n+1);
        }
        if (file.length() == 0) {
            int idx = path.lastIndexOf('/', n-1);
            file = path.substring(idx+1, n);
        }
        if (file.length() == 0) {
            throw new SVGConverterException(ERROR_INVALID_URL,
                                            new Object[]{url});
        }
        n = file.indexOf('?');
        String args = "";
        if (n != -1) {
            args = file.substring(n+1);
            file = file.substring(0, n);
        }

        name = file;

        //
        // The following will force creation of different output file names
        // for urls with references (e.g., anne.svg#svgView(viewBox(0,0,4,5)))
        //
        String ref = this.purl.getRef();
        if ((ref != null) && (ref.length()!=0)) {
            name += "_" + ref.hashCode();
        }
        if ((args != null) && (args.length()!=0)) {
            name += "_" + args.hashCode();
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
    
    public int hashCode() {
        return purl.hashCode();
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
