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
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.FileUtil;
import flex2.compiler.swc.zip.ZipEntry;
import flex2.compiler.swc.zip.ZipFile;
import flex2.compiler.swc.zip.ZipOutputStream;
import flex2.compiler.util.MimeMappings;

import java.util.Enumeration;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;

import flash.util.FileUtils;

/**
 * This SwcArchive implementation is somewhat inefficient because it
 * holds a full snapshot of the archive in memory all the time, but it
 * has the ability to be used for both reading and writing.
 *
 * @author Roger Gonzalez
 * @author Paul Reilly
 */
public class SwcDynamicArchive implements SwcArchive
{
    /**
     *
     * @param path Used for output and caching.
     */
    public SwcDynamicArchive( String path )
    {
        this.path = path;
    }

    /**
     *
     * @param out Used for output.
     * @param path Used for caching.
     */
    public SwcDynamicArchive( OutputStream out, String path )
    {
        this.out = out;
        this.path = path;
    }

    public String getLocation()
    {
        return path;
    }

    /**
     * Fills in "files" with an InMemoryFile for each zip file entry.
     */
    public void load()
    {
        files = new HashMap<String, VirtualFile>();
	    ZipFile zipFile = null;

        try
        {
	        zipFile = new ZipFile(path);
	        Enumeration e = zipFile.getEntries();
	        while (e.hasMoreElements())
	        {
		        ZipEntry ze = (ZipEntry)e.nextElement();
                InputStream inputStream = zipFile.getInputStream(ze);
                VirtualFile f = new InMemoryFile( inputStream, ze.getSize(), path + "$" + ze.getName(),
		                MimeMappings.getMimeType(ze.getName()), ze.getTime() );
                files.put( ze.getName(), f );
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
            throw new SwcException.FilesNotRead( e.getMessage() );
        }
        finally
        {
            try
            {
                if (zipFile != null)
                    zipFile.close();
            }
            catch(IOException ioe)
            {
                // ignore
            }
        }
    }

    /**
     * Writes "files" to the output stream or location specified by
     * "path", then nulls out "files".
     */
    public void save() throws Exception
    {
        String tmpPath = null;
        ZipOutputStream zos = null;

	    try
	    {
            assert (out != null) || (path != null) : "Must supply either an output stream or a location";
            if (out != null)
            {
                zos = new ZipOutputStream(out);
            }
            else if (path != null)
            {
                tmpPath = path + ".tmp";
                zos = new ZipOutputStream( new BufferedOutputStream( new FileOutputStream( FileUtil.openFile(tmpPath, true) )));
            }

            for (Map.Entry<String, VirtualFile> mapEntry : files.entrySet())
            {
                VirtualFile f = mapEntry.getValue();
                ZipEntry entry = new ZipEntry(mapEntry.getKey());
                entry.setTime(f.getLastModified());
                zos.putNextEntry( entry );

                BufferedInputStream in = new BufferedInputStream(f.getInputStream());
                FileUtil.streamOutput(in, zos);
                zos.closeEntry();
            }

            zos.close();
            zos = null;

            if ((out == null) && (path != null))
            {
                File tmpFile = new File(tmpPath);
                File file = new File(path);
                if (!FileUtils.renameFile( tmpFile, file ))
                {
                    throw new SwcException.SwcNotRenamed( tmpFile.getAbsolutePath(), file.getAbsolutePath() );
                }
            }

            files = null;
        }
        catch (Exception exception)
        {
            exception.printStackTrace();
        }
        finally
        {
            try
            {
                if (out != null)
                {
                    out.close();
                    out = null;
                }
            }
            catch(IOException ioe)
            {
                // ignore
            }

            try
            {
                if (zos != null)
                    zos.close();
            }
            catch(IOException ioe)
            {
                // ignore
            }
        }
    }

	public void close()
	{
	}

    /**
     * Returns "files", loading on demand.
     */
    public Map<String, VirtualFile> getFiles()
    {
        if (files == null)
        {
            load();
        }

        return files;
    }

    /**
     * Returns the file specified by path, loading it on demand.
     */
    public VirtualFile getFile( String path )
    {
        return getFiles().get( path );
    }

    public void putFile( VirtualFile file )
    {
        if (files == null)
        {
            files = new HashMap<String, VirtualFile>();
        }

        files.put( file.getName(), file );
    }

    public void putFile( String path, byte[] data, long lastModified )
    {
        if (files == null)
        {
            files = new HashMap<String, VirtualFile>();
        }

        InMemoryFile file = new InMemoryFile( data, path, MimeMappings.getMimeType(path), lastModified );
        
        files.put( file.getName(), file );
    }

    public long getLastModified()
    {
        return 0;
    }

    public String toString()
    {
        return path;
    }

    protected OutputStream out;
    protected String path;
    protected Map<String, VirtualFile> files;
}
