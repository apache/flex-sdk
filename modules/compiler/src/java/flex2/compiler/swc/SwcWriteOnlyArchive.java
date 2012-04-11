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

package flex2.compiler.swc;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import flex2.compiler.io.FileUtil;
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.zip.ZipEntry;
import flex2.compiler.swc.zip.ZipOutputStream;
import flex2.compiler.util.MimeMappings;

/**
 * A SwcArchive implementation specialized for writing.  It's not
 * currently used.
 */
public class SwcWriteOnlyArchive implements SwcArchive
{
    public SwcWriteOnlyArchive( String name, OutputStream out )
    {
        this.out = out;
        this.name = name;
    }

    public String getLocation()
    {
        return name;
    }

    public void load()
    {
    	throw new UnsupportedOperationException();
    }

    public void save() throws Exception
    {
        ZipOutputStream zos = null;
	    try
	    {
            zos = new ZipOutputStream(out);

            for (Iterator<VirtualFile> it = files.values().iterator(); it.hasNext(); )
            {
                VirtualFile f = it.next();

                ZipEntry entry = new ZipEntry( f.getName() );
                entry.setTime(f.getLastModified());
                zos.putNextEntry( entry );

                BufferedInputStream in = new BufferedInputStream(f.getInputStream());
                FileUtil.streamOutput(in, zos);
                zos.closeEntry();
            }

            zos.flush();
        }
        finally
        {
            try { if (zos != null) zos.close(); } catch(IOException ioe) {}
        }
    }

	public void close()
	{
	}

    public Map<String, VirtualFile> getFiles()
    {
        return files;
    }

    public VirtualFile getFile( String path )
    {
        return files.get( path );
    }

    public void putFile( VirtualFile file )
    {
        files.put( file.getName(), file );
    }

    public void putFile( String path, byte[] data, long lastModified )
    {
        InMemoryFile file = new InMemoryFile( data, path, MimeMappings.getMimeType(path), lastModified );
        files.put( file.getName(), file );
    }

    public long getLastModified()
    {
        return 0;
    }

    protected final OutputStream out;
    protected final String name;
    protected Map<String, VirtualFile> files = new HashMap<String, VirtualFile>();
}
