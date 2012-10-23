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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.MalformedURLException;

/**
 * Describes a file source for the <tt>SVGConverter</tt>
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: SVGConverterFileSource.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class SVGConverterFileSource implements SVGConverterSource {
    File file;
    String ref;

    public SVGConverterFileSource(File file){
        this.file = file;
    }

    public SVGConverterFileSource(File file, String ref){
        this.file = file;
        this.ref = ref;
    }

    public String getName(){
        String name = file.getName();
        if (ref != null && !"".equals(ref)){
            name += '#' + ref;
        }
        return name;
    }

    public File getFile(){
        return file;
    }

    public String toString(){
        return getName();
    }

    public String getURI(){
        try{
            String uri = file.toURL().toString();
            if (ref != null && !"".equals(ref)){
                uri += '#' + ref;
            }
            return uri;
        } catch(MalformedURLException e){
            throw new Error( e.getMessage() );
        }
    }

    public boolean equals(Object o){
        if (o == null || !(o instanceof SVGConverterFileSource)){
            return false;
        }

        return file.equals(((SVGConverterFileSource)o).file);
    }

    public int hashCode() {
        return file.hashCode();
    }

    public InputStream openStream() throws FileNotFoundException{
        return new FileInputStream(file);
    }

    public boolean isSameAs(String srcStr){
        if (file.toString().equals(srcStr)){
            return true;
        }

        return false;
    }

    public boolean isReadable(){
        return file.canRead();
    }
}

