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

package flash.util;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * A collection of file related utilities.
 */
public final class FileUtils
{
	public static final String canonicalPath(String rootPath)
	{
		if (rootPath == null)
			return null;
        return canonicalPath(new File(rootPath));
    }

    public static String canonicalPath(File file)
    {
        return canonicalFile(file).getPath();
    }

    public static File canonicalFile(File file)
    {
        try
		{
			return file.getCanonicalFile();
		}
		catch (IOException e)
		{
			return file.getAbsoluteFile();
		}
    }

    static private HashMap<String, String> filemap = null;
    static private boolean checkCase = false;

    /**
     * Canonicalize on Win32 doesn't fix the case of the file to match what is on disk.
     * Its annoying that this exists.  It will be very slow until the server stabilizes.
     * If this is called with a pattern where many files from the same directory will be
     * needed, then the cache should be changed to hold the entire directory contents
     * and check the modtime of the dir.  It didn't seem like this was worth it for now.
     * @param f
     * @return
     */
    public static synchronized String getTheRealPathBecauseCanonicalizeDoesNotFixCase( File f )
    {
        if (filemap == null)
        {
            filemap = new HashMap<String, String>();
            checkCase = System.getProperty("os.name").toLowerCase().startsWith("windows");
        }

        String path = FileUtils.canonicalPath( f );

        if (!checkCase || !f.exists())    // if the file doesn't exist, then we can't do anything about it.
            return path;

        // We're going to ignore the issue where someone changes the capitalization of a file on the fly.
        // If this becomes an important issue we'll have to make this cache smarter.

        if (filemap.containsKey( path ))
            return filemap.get( path );

        String file = f.getName();

        File canonfile = new File(path);

        File dir = new File(canonfile.getParent());

		// removing dir.listFiles() because it is not supproted in .NET
		String[] ss = dir.list();
        if (ss != null)
        {
            int n = ss.length;
            File[] files = new File[n];
            for (int i = 0; i < n; i++)
            {
                files[i] = new File(canonfile.getPath(), ss[i]);
            }

            for (int i = 0; i < files.length; ++i)
            {
                if (files[i].getName().equalsIgnoreCase( file ))
                {
                    filemap.put( path, files[i].getAbsolutePath() );
                    return files[i].getAbsolutePath();
                }
            }
        }
        // If we got here, it must be because we can't read the directory?
        return path;
    }

    public static String readFile(File file, String default_encoding) throws IOException
	{
	    FileInputStream fileInputStream = new FileInputStream(file);

		try
		{
            StringBuilder returnVal = new StringBuilder((int) file.length() );
            BufferedInputStream in = new BufferedInputStream(fileInputStream);
            in.mark(3);
            
			Reader reader = new InputStreamReader(in, consumeBOM(in, default_encoding));
			
            char[] line = new char[2000];
            int count = 0;
            
            while ((count = reader.read(line, 0, line.length)) >= 0)
            {
                returnVal.append(line, 0, count);
            }
            
            return returnVal.toString();
		}
		finally
		{
			fileInputStream.close();
		}
	}

	public static String readFile(String filename, String default_encoding) throws IOException
	{
	    return readFile(new File(filename), default_encoding);
	}
    
    /**
     * @param in input stream
     * @param default_encoding default encoding. null or "" => system default
     * @return file encoding..
     * @throws IOException
     */
    public static final String consumeBOM(InputStream in, String default_encoding) throws IOException
    {
        return consumeBOM(in, default_encoding, false);
    }
    
    /**
     * @param in input stream
     * @param default_encoding default encoding. null or "" => system default
     * @param alwaysConsumeBOM If true, then consume the UTF-16 BOM. 
     *                         If false use the previous behavior that consumes
     *                         a UTF-8 BOM but not a UTF-16 BOM.
     *                         This flag is useful when reading a file into
     *                         a string that is then passed to a parser. The parser may 
     *                         not know to strip out the BOM. 
     * @return file encoding..
     * @throws IOException
     */
	public static final String consumeBOM(InputStream in, 
                                        String default_encoding,
                                        boolean alwaysConsumeBOM) throws IOException
	{
		in.mark(3);
		// Determine file encoding...
		// ASCII - no header (use the supplied encoding)
		// UTF8  - EF BB BF
		// UTF16 - FF FE or FE FF (decoder chooses endian-ness)
		if (in.read() == 0xef && in.read() == 0xbb && in.read() == 0xbf)
		{
			// UTF-8 reader does not consume BOM, so do not reset
			if (System.getProperty("flex.platform.CLR") != null)
			{
				return "UTF8";
			}
			else
			{
				return "UTF-8";
			}
		}
		else
	    {
	        in.reset();
	        int b0 = in.read();
	        int b1 = in.read();
	        if (b0 == 0xff && b1 == 0xfe || b0 == 0xfe && b1 == 0xff)
	        {
                // If we don't consume the BOM is its assumed a
                // UTF-16 reader will consume BOM
                if (!alwaysConsumeBOM) 
                {
                    in.reset();
                }

				if (System.getProperty("flex.platform.CLR") != null)
				{
					return "UTF16";
				}
				else
				{
					return "UTF-16";
				}
	        }
	        else
	        {
	            // no BOM found
	            in.reset();
				if (default_encoding != null && default_encoding.length() != 0)
                {
                    return default_encoding;
                }
                else
                {
                    return System.getProperty("file.encoding");
                }
	        }
	    }
	}

	/* post-1.2 File methods */

	public static File getAbsoluteFile(File f)
	{
		File absolute = null;
		
		try
		{
			absolute = f == null ? null : f.getAbsoluteFile();
		}
		catch (SecurityException se)
		{
			if (Trace.pathResolver)
			{
				Trace.trace(se.getMessage());
			}
		}
		
		return absolute;
	}

	public static File getCanonicalFile(File f)
        throws IOException
	{
		return new File(f.getCanonicalPath());
	}

	public static File getParentFile(File f)
	{
		String p = f.getParent();
		if (p == null)
		{
			return null;
		}
		return new File(p);
	}

	public static File[] listFiles(File dir)
	{
		String[] fileNames = dir.list();

		if (fileNames == null)
		{
			return null;
		}

		File[] fileList = new File[fileNames.length];
		for (int i=0; i<fileNames.length; i++) 
		{
			fileList[i] = new File(dir.getPath(), fileNames[i]);
		}
		return fileList;
	}

	public static File[] listFiles(File dir, FilenameFilter filter)
	{
		String[] fileNames = dir.list();

		if (fileNames == null)
		{
			return null;
		}

		ArrayList<File> filteredFiles = new ArrayList<File>();
		for (int i=0; i < fileNames.length; i++) 
		{
			if ((filter == null) || filter.accept(dir, fileNames[i])) 
			{
				filteredFiles.add(new File(dir.getPath(), fileNames[i]));
			}
		}

		return (filteredFiles.toArray(new File[0]));
	}

	public static URL toURL(File f)
		throws MalformedURLException 
	{
		String s = f.getAbsolutePath();
		if (File.separatorChar != '/')
		{
			s = s.replace(File.separatorChar, '/');
		}
		if (!s.startsWith("/"))
		{
			s = "/" + s;
		}
		if (!s.endsWith("/") && f.isDirectory())
		{
			s = s + "/";
		}
		return new URL("file", "", s);
	}

    public static String addPathComponents(String p1, String p2, char sepchar)
    {
        if (p1 == null)
            p1 = "";
        if (p2 == null)
            p2 = "";

        int r1 = p1.length() - 1;

        while ((r1 >= 0) && ((p1.charAt( r1 ) == sepchar)))
            --r1;

        int r2 = 0;
        while ((r2 < p2.length()) && (p2.charAt( r2 ) == sepchar ))
            ++r2;

        String left = p1.substring( 0, r1 + 1 );
        String right = p2.substring( r2 );

        String sep = "";
        if ((left.length() > 0) && (right.length() > 0))
            sep += sepchar;

        return left + sep + right;
    }

    /**
     * Java's File.renameTo doesn't try very hard.
     * @param from  absolute origin
     * @param to    absolute target
     * @return true if rename succeeded
     */
    public static boolean renameFile( File from, File to)
    {
        if (!from.exists())
        {
            return false;
        }
        long length = from.length();
        try
        {
            if (to.exists())
            {
                if (!to.delete())
                {
                    File old = new File( to.getAbsolutePath() + ".old" );

                    if (old.exists())
                    {
                        old.delete();
                    }
                    if (to.renameTo( old ) && !old.delete())
                    {
                        // unbefrickinlievable

                        // TODO - this isn't supported on .Net, write a replacement FileUtils.rename!!
//                        old.deleteOnExit();
                    }
                }
            }
        }
        catch (Exception e)
        {
            // eat exception, keep on going...
        }

        try
        {
            if (from.renameTo( to ))
            {
                return true;
            }

            // everything seems to have failed.  copy the bits.

            BufferedInputStream in = new BufferedInputStream(new FileInputStream( from ));
            BufferedOutputStream out = new BufferedOutputStream(new FileOutputStream( to ));
            byte[] buf = new byte[8 * 1024];

            long remain = from.length();

            try
            {
                while ( remain > 0 )
                {
                    int r = in.read( buf );
                    if (r < 0)
                    {
                        return false;
                    }
                    remain -= r;
                    out.write( buf, 0, r );
                    out.flush();
                }
            }
            finally
            {
                in.close();
                out.close();
            }
            long tolength = to.length();
            if (tolength == length)
            {
                from.delete();
                // TODO - .Net doesn't support this!!!
                //to.setLastModified( from.lastModified() );
                return true;
            }
            else
            {
                return false;
            }
        }
        catch (Exception e)
        {
            return false;
        }
    }

    public static byte[] toByteArray(InputStream in)
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream(8192);
        byte[] buffer = new byte[8192];
        int num = 0;
        InputStream inputStream = new BufferedInputStream(in);
        try
        {
            while ((num = inputStream.read(buffer)) != -1)
            {
                baos.write(buffer, 0, num);
            }
        }
        catch (IOException ex)
        {
            if (Trace.error)
                 ex.printStackTrace();
            
            // FIXME: do we really want to catch this without an exception?
        }
        finally
        {
            try
            {
                if (in != null)
                    in.close();
            }
            catch (IOException ex)
            {
            }
        }

        return baos.toByteArray();
    }

    public static byte[] toByteArray(InputStream in, int length) throws IOException
    {
        BufferedInputStream inputStream = new BufferedInputStream(in);
        byte[] buffer = new byte[length];

        try
        {
            int bytesRead = 0;
            int index = 0;

            while ((bytesRead >= 0) && (index < buffer.length))
            {
                bytesRead = inputStream.read(buffer, index, buffer.length - index);
                index += bytesRead;
            }
        }
        finally
        {
            inputStream.close();
        }
        return buffer;
    }

	public static void writeClassToFile(String baseDir, String packageName, String className, String str)
			throws IOException
	{
		String reldir = packageName.replace( '.', File.separatorChar );
		String dir = FileUtils.addPathComponents( baseDir, reldir, File.separatorChar );
		new File( dir ).mkdirs();
		String generatedName = FileUtils.addPathComponents( dir, className, File.separatorChar );
		BufferedWriter fileWriter = null;

		try
		{
			fileWriter = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(generatedName), "UTF-8"));
			fileWriter.write( str );
			fileWriter.flush();
		}
		finally
		{
			if (fileWriter != null)
			{
				try
				{
					fileWriter.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}
	
    /**
     * returns whether the file is absolute
     * if a security exception is thrown, always returns false
     */
    public static boolean isAbsolute(File f)
    {
        boolean absolute = false;
        try
        {
            absolute = f.isAbsolute();
        }
        catch (SecurityException se)
        {
            if (Trace.pathResolver)
            {
                Trace.trace(se.getMessage());
            }
        }

        return absolute;
    }

    /**
     * returns whether the file is absolute
     * if a security exception is thrown, always returns false
     */
    public static boolean exists(File f)
    {
        boolean exists = false;
        try
        {
            exists = f.exists();
        }
        catch (SecurityException se)
        {
            if (Trace.pathResolver)
            {
                Trace.trace(se.getMessage());
            }
        }

        return exists;
    }
    
    /**
     * returns whether it's a file
     * if a security exception is thrown, always returns false
     */
    public static boolean isFile(File f)
    {
        boolean isFile = false;
        try
        {
            isFile = f.isFile();
        }
        catch (SecurityException se)
        {
            if (Trace.pathResolver)
            {
                Trace.trace(se.getMessage());
            }
        }

        return isFile;
    }

    /**
     * returns whether it's a directory
     * if a security exception is thrown, always returns false
     */
    public static boolean isDirectory(File f)
    {
        boolean isDirectory = false;
        try
        {
            isDirectory = f.isDirectory();
        }
        catch (SecurityException se)
        {
            if (Trace.pathResolver)
            {
                Trace.trace(se.getMessage());
            }
        }

        return isDirectory;
    }

}
