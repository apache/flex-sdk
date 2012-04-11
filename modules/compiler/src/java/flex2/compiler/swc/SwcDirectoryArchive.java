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
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.FileUtil;

import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;
import java.io.File;
import java.io.OutputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;

import flash.util.FileUtils;
import flash.util.Trace;

/**
 * This SWC archive type leaves the SWC as an exploded directory on
 * disk, and does not support real-time updates of its contents.
 *
 * @author Roger Gonzalez
 */
public class SwcDirectoryArchive implements SwcArchive
{
    public SwcDirectoryArchive( String path )
    {
        this.dir = path;
    }

    public String getLocation()
    {
        return dir;
    }

    /**
     * Populates the fileList.
     */
    public void load()
    {
        String swcPath = filePath( Swc.CATALOG_XML );

        File c = new File( swcPath );

        if (!c.exists())
        {
            throw new SwcException.NotASwcDirectory( dir );
        }

        fileList = new HashSet<String>();
        readFiles( fileList, "", new File( dir ) );
    }

    private void readFiles( Set<String> s, String current, File f )
    {
        if (f.isDirectory())
        {
            File[] files = FileUtils.listFiles( f );

            for (int i = 0; i < files.length; ++i )
            {
                String relpath = FileUtils.addPathComponents( current, files[i].getName(), File.separatorChar );
                File absFile = new File( filePath( relpath ) );
                readFiles( s, relpath, absFile );
            }
        }
        else
        {
            s.add( current.replace(File.separatorChar, '/') );
        }
    }

    public void save()
    {
        // This archive type is always on disk, and doesn't support concurrent read/write
    }

	public void close()
	{
	}

    /**
     * Returns a map of filenames to VirtualFiles.  Implicitly calls
     * <code>load</code>, if the archive hasn't been loaded yet.
     */
    public Map<String, VirtualFile> getFiles()
    {
        if (fileList == null)
        {
            load();
        }

        Map<String, VirtualFile> map = new HashMap<String, VirtualFile>();

        for (String filename : fileList)
        {
            map.put( filename, new RelativeLocalFile( new File( filePath( filename ) ), dir + "$" + filename ) );
        }
        return map;
    }

    /**
     * Returns a VirtualFile for <code>path</code>.  Implicitly calls
     * <code>load</code>, if the archive hasn't been loaded yet.
     */
    public VirtualFile getFile( String path )
    {
        if (fileList == null)
        {
            load();
        }

	    if (fileList.contains( path ))
		    return new RelativeLocalFile( new File( filePath( path ) ), dir + "$" + path );
	    else
		    return null;
    }
    
    public boolean exists(String path)
    {
        if (fileList == null)
        {
            load();
        }

    	return fileList.contains(path);
    }

    private String filePath( String path )
    {
        return FileUtils.addPathComponents( dir, path, File.separatorChar );
    }

    /**
     * Writes the contents of <code>file</code> to disk and adds it to
     * <code>fileList</code>.
     */
    public void putFile( VirtualFile file )
    {
        makeDirectory();

        // remember, the input here is a phony file with a partial filename!
        try
        {
            File tmp = new File( filePath( file.getName() + ".tmp" ) );
            tmp = FileUtils.getAbsoluteFile(tmp);
            if (tmp == null)
            {
                throw new SwcException.FileNotWritten( file.getName(), "" );
            }
            tmp.getParentFile().mkdirs();
            
            OutputStream out = new BufferedOutputStream( new FileOutputStream( tmp ) );
            FileUtil.streamOutput( file.getInputStream(), out );
            out.close();

            File f = new File( filePath( file.getName()));
            FileUtils.renameFile( tmp, f );

            if (fileList == null)
            {
                fileList = new HashSet<String>();
            }

            fileList.add( file.getName() );
        }
        catch (SwcException e)
        {
	        throw e;
        }
        catch (Exception e)
        {
            throw new SwcException.FileNotWritten( file.getName(), e.getMessage() );
        }
    }

    /**
     * Writes <code>data</code> to a file on disk named
     * <code>path</code> and adds it to <code>fileList</code>.
     */
    public void putFile( String path, byte[] data, long lastModified )
    {
        makeDirectory();
        try
        {
            File tmp = new File( filePath( path + ".tmp" ) );

            OutputStream out = new BufferedOutputStream( new FileOutputStream( tmp ) );
            out.write( data );
            out.close();
            File f = new File( filePath( path ) );
            FileUtils.renameFile( tmp, f );

            if (fileList == null)
            {
                fileList = new HashSet<String>();
            }

            fileList.add( path );
        }
        catch (Exception e)
        {
	        if (Trace.error)
	        {
		        e.printStackTrace();
	        }
            throw new SwcException.FileNotWritten( path, e.getMessage() );
        }
    }

    public long getLastModified()
    {
        return 0;
    }

    private void makeDirectory()
    {
        File d = new File( dir );
        if (d.exists() && !d.isDirectory() )
        {
            throw new SwcException.NotADirectory( dir );
        }
        else if (!d.exists())
        {
            try
            {
                d.mkdirs();
            }
            catch (Exception e)
            {
	            if (Trace.error)
	            {
		            e.printStackTrace();
	            }
                throw new SwcException.DirectoryNotCreated(dir);
            }
        }
        if (!d.exists() || !d.isDirectory())
        {
	        throw new SwcException.DirectoryNotCreated(dir);
        }
    }

    private final String dir;
    private Set<String> fileList;

    private static class RelativeLocalFile extends LocalFile
    {
        public RelativeLocalFile( File f, String name )
        {
            super( f );
            this.name = name;
        }
        public String getName()
        {
            return name;
        }
        private String name;
    }
}
