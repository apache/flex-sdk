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

import flex2.compiler.io.VirtualFile;
import flex2.compiler.io.VirtualZipFile;
import flex2.compiler.io.ZipFileHolder;
import flex2.compiler.swc.zip.ZipEntry;
import flex2.compiler.swc.zip.ZipFile;
import flex2.compiler.util.MimeMappings;

import java.util.Enumeration;
import java.util.HashMap;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import flash.util.Trace;

/**
 * This SwcArchive works like the default SwcDynamicArchive except in
 * its loading, which is done lazily.
 *
 * @author Brian Deitte
 * @author Paul Reilly
 */
public class SwcLazyReadArchive extends SwcDynamicArchive
{
    private ZipFileHolder zipFileHolder;

    public SwcLazyReadArchive( String path )
    {
	    super(path);
    }

    public SwcLazyReadArchive( OutputStream out, String path )
    {
        super(out, path);
    }

    /**
     * Fills in "files" with a VirtualZipFile for each zip file entry.
     */
    public void load()
    {
        assert files == null;
        files = new HashMap<String, VirtualFile>();

        try
        {
	        File file = new File(path);
	        ZipFile zipFile = new ZipFile(file);
	        zipFileHolder = new ZipFileHolder(zipFile, path);
	        Enumeration e = zipFile.getEntries();
            while (e.hasMoreElements())
            {
	            ZipEntry ze = (ZipEntry) e.nextElement();
                String name = ze.getName();
                VirtualFile f = new VirtualZipFile(zipFileHolder,  MimeMappings.getMimeType(name),
                                                   path + "$" + name, name);
                files.put(name, f);
            }
        }
        catch (SwcException.UnknownZipFormat e)
        {
        	throw new SwcException.NotASwcFile(path);
        }
        catch (SwcException e)
        {
	        throw e;
        }
        catch (Exception e)
        {
            if (Trace.error)
            {
                e.printStackTrace();
            }
            throw new SwcException.FilesNotRead( e.getMessage() );
		}
	}

    /**
     * Closes the <code>zipFile</code>.  This is necessary to prevent
     * the <code>zipFile</code> from remaining open after a
     * compilation finishes.
     */
	public void close()
	{
        zipFileHolder.close();
	}
}
