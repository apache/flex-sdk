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

package flex2.compiler.io;

import java.io.*;
import java.util.List;

/**
 * A helper class used by classes doing file operations.  Part of it's
 * original purpose was to consolidate J# handling, but J# support was
 * dropped many years ago.
 *
 * @author Clement Wong
 */
public final class FileUtil
{
	public static final boolean caseInsensitive = (System.getProperty("os.name").toLowerCase().startsWith("windows") ||
												   System.getProperty("os.name").toLowerCase().startsWith("mac"));

	/**
	 * Return an instance of File...
	 *
	 * @param path
	 * @return File
	 */
	public static File openFile(String path)
	{
		try
		{
			return new File(path);
		}
		catch (Error e) // J#.NET throws an error if the file is not found...
		{
			return null;
		}
	}

	public static File openFile(String path, boolean mkdir)
	{
		File f = new File(path).getAbsoluteFile();

		if (mkdir)
		{
			new File(f.getParent()).mkdirs();
		}

		return f;
	}

	/**
	 * Return an instance of File...
	 *
	 * @param parentPath
	 * @param fileName
	 * @return File
	 */
	public static File openFile(File parentPath, String fileName)
	{
		try
		{
			return new File(parentPath, fileName);
		}
		catch (Error e) // J#.NET throws an error if the file is not found...
		{
			return null;
		}
	}

	/**
	 * Create a temp file. Write the input stream to the file...
	 *
	 * @param in
	 * @return
	 * @throws IOException
	 */
	public static File createTempFile(InputStream in) throws IOException
	{
		File temp = File.createTempFile("Flex2_", "");
		writeBinaryFile(temp, in);
		return temp;
	}

	/**
	 * Return an input stream with BOM consumed...
	 *
	 * @param file
	 * @return
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public static InputStream openStream(File file) throws FileNotFoundException, IOException
	{
		return openStream(file.getAbsolutePath());
	}

	/**
	 * Return an input stream with BOM consumed...
	 *
	 * @param path
	 * @return
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public static InputStream openStream(String path) throws FileNotFoundException, IOException
	{
		return openStream(new FileInputStream(path));
	}

	/**
	 * Return an input stream with BOM consumed...
	 *
	 * @param in
	 * @return
	 * @throws IOException
	 */
	public static InputStream openStream(InputStream in) throws IOException
	{
		byte[] bom = new byte[3];

		in.read(bom, 0, 3);

		if (bom[0] == 0xef && bom[1] == 0xbb && bom[2] == 0xbf)
		{
			return in;
		}
		// else if (bom[0] == 0xff && bom[1] == 0xfe || bom[0] == 0xfe && bom[1] == 0xff)
		else
		{
			return new BOMInputStream(bom, in);
		}
	}

	/**
	 * It's a normal input stream but it serves BOM before bytes in the stream...
	 */
    //TODO make a reader version of this class so calls like
    //         > new BufferedReader(new InputStreamReader(FileUtil.openStream(f)))
    //     don't have so many levels of indirection to get to the stream
	private static final class BOMInputStream extends InputStream
	{
		private BOMInputStream(byte[] bom, InputStream in)
		{
			this.bom = bom;
			bomSize = bom.length;
			this.in = in;
			index = 0;
		}

		private byte[] bom;
		private final int bomSize;
		private final InputStream in;
		private int index;

		public int read() throws IOException
		{
			if (bom == null)
			{
				return in.read();
			}
			else
			{
				int c = bom[index];
				if (index == bomSize - 1)
				{
					bom = null;
				}
				index += 1;
				return c;
			}
		}

		public int read(byte b[], int off, int len) throws IOException
		{
			if (bom == null)
			{
				return in.read(b, off, len);
			}

            int count = 0;
            while ((index < 3) && (count < len))
            {
                b[off+count] = bom[index++];
                ++count;
            }
            if (index == 3)
            {
                bom = null;
            }
            if (len <= count)
                return count;
            int r = in.read(b, off+count, len-count);
            return (r == -1)? -1 : r + count;
		}

		public long skip(long n) throws IOException
		{
			throw new UnsupportedOperationException("supports read() and close() only...");
		}

		public int available() throws IOException
		{
			int num = in.available();
			if (bom == null)
			{
				return num;
			}
			else
			{
				return (bomSize - index) + num;
			}
		}

		public void close() throws IOException
		{
			in.close();
		}

		public synchronized void mark(int readlimit)
		{
			throw new UnsupportedOperationException("supports read() and close() only...");
		}

		public synchronized void reset() throws IOException
		{
			throw new UnsupportedOperationException("supports read() and close() only...");
		}

		public boolean markSupported()
		{
			return false;
		}
	}

	/**
	 * Write a stream of binary data to a file.
	 * @param file
	 * @param in
	 * @throws IOException
	 */
	public static void writeBinaryFile(File file, InputStream in) throws IOException
	{
		OutputStream out = new BufferedOutputStream(new FileOutputStream(file));
		in = new BufferedInputStream(in);
        try
        {
            streamOutput(in, out);
        }
        finally
        {
            out.close();
        }
    }

    public static void streamOutput(InputStream in, OutputStream out)
            throws IOException
    {
        int len = 8192;
        byte[] bytes = new byte[len];
        while ((len = in.read(bytes, 0, len)) != -1)
        {
            out.write(bytes, 0, len);
        }
        // C: caller is responsible for closing the streams.
        out.flush();
    }

    /**
	 * Write a String to a file
	 * @param fileName
	 * @param output
	 * @throws java.io.IOException
	 */
	public static void writeFile(String fileName, String output) throws FileNotFoundException, IOException
	{
		File file = openFile(fileName);
		if (file == null)
		{
			throw new FileNotFoundException(fileName);
		}

		Writer out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF8"));
		try
		{
			out.write(output);
			out.flush();
		}
		finally
		{
			out.close();
		}
	}

	public static void writeBinaryFile(String fileName, byte[] output) throws FileNotFoundException, IOException
	{
		File file = openFile(fileName);
		if (file == null)
		{
			throw new FileNotFoundException(fileName);
		}

		OutputStream out = new BufferedOutputStream(new FileOutputStream(file));
		try
		{
			out.write(output);
			out.flush();
		}
		finally
		{
			out.close();
		}
	}

	public static String getCanonicalPath(String path)
	{
		File f = openFile(path);
		return (f == null) ? null : getCanonicalPath(f);
	}
	
	public static String getCanonicalPath(File f)
	{
		try
		{
			return f.getCanonicalPath();
		}
		catch (IOException ex)
		{
			return f.getAbsolutePath();
		}
	}

	public static File getCanonicalFile(File f)
	{
		try
		{
			return f.getCanonicalFile();
		}
		catch (IOException ex)
		{
			return f.getAbsoluteFile();
		}
	}

	public static String readFile(File f)
	{
		BufferedReader file = null;
		StringBuilder buffer = new StringBuilder((int) f.length());
		String lineSep = System.getProperty("line.separator");

		try
		{
            /* TODO
             * Do we need a BufferedReader layered on a BufferedInputStream?
             * There are so many levels of indirection here that it would be a good idea
             * to have an InputBufferReader (like InputBufferStream) and openReader()
             */
			file = new BufferedReader(new InputStreamReader(FileUtil.openStream(f)));
			String s = null;
			while ((s = file.readLine()) != null)
			{
				buffer.append(s);
				buffer.append(lineSep);
			}
			return buffer.toString();
		}
		catch (FileNotFoundException ex)
		{
			return null;
		}
		catch (IOException ex)
		{
			return null;
		}
		finally
		{
			if (file != null)
			{
				try
				{
					file.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}

	public static String readLine(String f, int line)
	{
		BufferedReader file = null;
		try
		{
			file = new BufferedReader(new InputStreamReader(FileUtil.openStream(f), "UTF8"));
			for (int i = 0; i < line - 1 && file.readLine() != null; i++);
			return file.readLine();
		}
		catch (FileNotFoundException ex)
		{
			return null;
		}
		catch (IOException ex)
		{
			return null;
		}
		finally
		{
			if (file != null)
			{
				try
				{
					file.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}

	public static byte[] readBytes(String f, int line)
	{
		BufferedInputStream in = null;
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		boolean lastIsCR = false;
		int pos = 0, ch = 0, count = 0;
		try
		{
			in = new BufferedInputStream(FileUtil.openStream(f));
			while ((ch = in.read()) != -1)
			{
				if (lastIsCR)
				{
					count++;
					if (line == count)
					{
						return baos.toByteArray();
					}
					else
					{
						baos.reset();
					}

					if (ch == '\n')
					{
						lastIsCR = false;
					}
					else if (ch == '\r')
					{
						lastIsCR = true;
					}
					else
					{
						baos.write(ch);
						lastIsCR = false;
					}
				}
				else
				{
					if (ch == '\n')
					{
						count++;
						if (line == count)
						{
							return baos.toByteArray();
						}
						else
						{
							baos.reset();
						}
						lastIsCR = false;
					}
					else if (ch == '\r')
					{
						lastIsCR = true;
					}
					else
					{
						baos.write(ch);
						lastIsCR = false;
					}
				}
				pos++;
			}
			return null;
		}
		catch (FileNotFoundException ex)
		{
			return null;
		}
		catch (IOException ex)
		{
			return null;
		}
		finally
		{
			if (in != null) { try { in.close(); } catch (IOException ex) {} }
		}
	}
	
	/**
	 * check whether the provided path is a subdirectory of the list of directories and vice versa.
	 * @param path
	 * @param directories
	 * @return -1 if not
	 */
	public static int isSubdirectoryOf(File pathFile, List directories)
	{
		String path = pathFile.toString();
		for (int j = 0, size = directories.size(); j < size; j++)
		{
			File dirFile = FileUtil.getCanonicalFile((File) directories.get(j));
			String dir = dirFile.toString();
			if (! pathFile.getParent().equals(dirFile.getParent()) &&
			    (path.length() > dir.length() && path.startsWith(dir) ||
			     dir.length() > path.length() && dir.startsWith(path)))
			{
				return j;
			}
		}
		return -1;
	}
	
	/**
	 * check whether the provided directory is a subdirectory of the list of directories.
	 * @param directory
	 * @param directories
	 * @return -1 if not
	 */
	public static int isSubdirectoryOf(String directory, VirtualFile[] directories)
	{
		File pathFile = FileUtil.openFile(directory);
		String path = pathFile.toString();
		for (int j = 0, size = directories == null ? 0 : directories.length; j < size; j++)
		{
			File dirFile = FileUtil.openFile(directories[j].getName());
			String dir = dirFile.toString();
			if (!pathFile.getParent().equals(dirFile.getParent()) && path.length() > dir.length() && path.startsWith(dir))
			{
				return j;
			}
		}
		return -1;
	}
	
	public static String getExceptionMessage(Exception ex)
	{
		return getExceptionMessage(ex, true);
	}

	public static String getExceptionMessage(Exception ex, boolean stackDump)
	{
		String m = ex.getMessage();
		
		if (m == null)
		{
			m = ex.getLocalizedMessage();
		}
		
		if (m == null)
		{
			m = "(" + ex.getClass().getName() + ")";
			if (stackDump)
			{
				StringWriter s = new StringWriter();
				PrintWriter p = new PrintWriter(s, true);
				ex.printStackTrace(p);
				m += s.getBuffer().toString();
			}
		}
		
		return m;
	}
}
