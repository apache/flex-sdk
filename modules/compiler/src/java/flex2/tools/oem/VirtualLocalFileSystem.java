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

package flex2.tools.oem;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import flash.util.FileUtils;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;

/**
 * The <code>VirtualLocalFileSystem</code> class serves as a factory for creating <code>VirtualLocalFile</code> instances.
 * It also helps <code>VirtualLocalFile</code> instances resolve relative paths that might point to other
 * <code>VirtualLocalFile</code> instances or "real" files in the file system.
 * 
 * @see flex2.tools.oem.VirtualLocalFile
 * @version 2.0.1
 * @author Clement Wong
 */
public class VirtualLocalFileSystem
{
    /**
     * Constructor.
     */
    public VirtualLocalFileSystem()
    {
        files = new HashMap<String, VirtualLocalFile>();
    }
    
    private final Map<String, VirtualLocalFile> files;

    /**
     * Creates a <code>VirtualLocalFile</code> instance.
     *
     * @param name A canonical path. The name must end with a file extension; for example: <code>.mxml</code> or <code>.as</code>.
     * @param text Source code.
     * @param parent The parent directory of this <code>VirtualLocalFile</code> object.
     * @param lastModified The last modified time for the virtual local file.
     * @return A <code>VirtualLocalFile</code>.
     */
    public final VirtualLocalFile create(String name, String text, File parent, long lastModified)
    {
        VirtualLocalFile f = new VirtualLocalFile(name, text, parent, lastModified, this);
        files.put(name, f);
        return f;
    }
    
    /**
     * Updates a <code>VirtualLocalFile</code> with the specified text and timestamp.
     * 
     * @param name A canonical path. The name must end with a file extension; for example: <code>.mxml</code> or <code>.as</code>.
     * @param text Source code.
     * @param lastModified The last modified time.
     * @return <code>true</code> if the <code>VirtualLocalFile</code> was successfully updated; <code>false</code> if a 
     * <code>VirtualLocalFile</code> was not found.
     */
    public final boolean update(String name, String text, long lastModified)
    {
        VirtualLocalFile f = files.get(name);
        if (f != null)
        {
            f.text = text;
            f.lastModified = lastModified;
            return true;
        }
        else
        {
            return false;
        }
    }
    
    final VirtualFile resolve(VirtualLocalFile base, String name)
    {
        // if 'name' is a full name and the VirtualFile instance exists, return it.
        VirtualLocalFile f = files.get(name);
        if (f != null)
        {
            return f;
        }
        
        // if 'name' is relative to 'base', resolve 'name' into a full name.
        String fullName = constructName(base, name);
        
        // try to lookup again.
        f = files.get(fullName);
        if (f != null)
        {
            return f;
        }

        // it's not in the HashMap. let's locate it in the file system.
        File absolute = FileUtil.openFile(name);
        if (absolute != null && FileUtils.exists(absolute))
        {
            return new LocalFile(absolute);
        }
        
        File relative = FileUtil.openFile(fullName);
        if (relative != null && FileUtils.exists(relative))
        {
            return new LocalFile(relative);
        }
        
        return null;
    }
    
    private String constructName(VirtualLocalFile base, String relativeName)
    {
        return FileUtil.getCanonicalPath(FileUtil.openFile(base.getParent() + File.separator + relativeName));
    }
}
