/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.fxg;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import com.adobe.fxg.util.FXGResourceResolver;

import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.VirtualFile;

/**
 * Provides a bridge between mxmlc's SinglePathResolver and fxgutils'
 * FXGResourceResolver.
 *
 * @author Pete Farland
 */
public class FlexResourceResolver implements FXGResourceResolver
{
    protected SinglePathResolver resolver;
    protected String rootPath;

    public FlexResourceResolver(SinglePathResolver resolver)
    {
        this.resolver = resolver;
    }

    public String getRootPath()
    {
        return rootPath;
    }

    public void setRootPath(String dir)
    {
        rootPath = dir;
    }

    public String resolve(String relative)
    {
        VirtualFile f = resolver.resolve(relative);
        if (f != null)
            return f.getName();

        return null; 
    }
    
    public InputStream openStream(String path) throws IOException
    {
        VirtualFile f = resolver.resolve(path);
        if (f != null)
            return f.getInputStream();

        return null;
    }

    public InputStream openStream(URL url) throws IOException
    {
        return url.openStream();
    }
}
