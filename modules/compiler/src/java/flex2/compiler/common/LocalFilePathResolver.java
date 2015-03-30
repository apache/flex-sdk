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

package flex2.compiler.common;

import flash.util.FileUtils;
import flash.util.Trace;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.LocalFile;

import java.io.File;

/**
 * This class handles resolving absolute file paths.  This resolver
 * explicitly does not resolve relative paths, because it is included
 * in the ThreadLocalToolkit's global PathResolver.  The
 * ThreadLocalToolkit's global PathResolver is used to resolve things
 * like @Embed assets and we don't want paths which are relative to
 * the current working directory and not relative to the containing
 * Mxml document to be resolved.  For example, if we have:
 *
 *   C:/foo/bar.mxml
 *
 * with:
 *
 *   <mx:Image source="@Embed(source='image.jpg')"/>
 *
 * and:
 *
 *   C:/foo/image.jpg
 *   C:/image.jpg
 *
 * When the current working directory is C:/, we don't want resolve() to return
 * C:/image.jpg.
 */
public class LocalFilePathResolver implements SinglePathResolver
{
    private static final LocalFilePathResolver singleton = new LocalFilePathResolver();

    private LocalFilePathResolver()
    {
    }

    public static LocalFilePathResolver getSingleton()
    {
        return singleton;
    }

    public VirtualFile resolve( String pathStr )
    {
        File path = FileUtil.openFile(pathStr);
        VirtualFile virt = null;

        if (path != null && FileUtils.exists(path) && FileUtils.isAbsolute(path))
        {
            virt = new LocalFile(path);
        }

        if ((virt != null) && Trace.pathResolver)
        {
            Trace.trace("LocalFilePathResolver.resolve: resolved " + pathStr + " to " + virt.getName());
        }

        return virt;
    }
}
