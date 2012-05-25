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

package flex2.tools;

import java.io.File;
import java.io.ObjectOutputStream;
import java.io.IOException;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.io.OutputStream;
import java.util.StringTokenizer;
import java.util.HashMap;
import java.util.Map;
import java.lang.reflect.Method;

import org.apache.flex.forks.batik.svggen.font.Font;
import org.apache.flex.forks.batik.svggen.font.table.Os2Table;
import org.apache.flex.forks.batik.svggen.font.table.NameTable;
import org.apache.flex.forks.batik.svggen.font.table.Table;
import flash.fonts.LocalFont;

/**
 * A tool that takes a snapshot of all font information, storing it in LocalFont objects that are serialized
 * into localFonts.ser.  This data is read in by JREFontManager.
 *
 * The fonts are found by looking at the Sun-specific APIs for finding the system font path.  If this API is
 * not available, then the system font directories can be passed in.
 *
 * This is done as a separate tool and not as part of a compilation because of speed.  Reading all of
 * the fonts on a system takes a non-trivial amount of time. 
 *
 * @author Brian Deitte
 */
public class FontSnapshot
{
	private static Method getFontPath;
	private Map<String, LocalFont> fonts = new HashMap<String, LocalFont>();

	// for JREFontManager's initDefaultLocalFonts()
	private static boolean printForMap = true;

	public static void main(String[] args) throws Exception
	{
		FontSnapshot snapshot = new FontSnapshot(args);
		snapshot.save();
	}

	public FontSnapshot(String[] paths)
	{
		findFonts(paths);
	}

	protected void findFonts(String[] paths)
	{
		if (paths != null && paths.length != 0)
		{
			for (int i = 0; i < paths.length; i++)
			{
				findFonts(paths[i]);
			}
		}

		// FIXME: add system font dirs to FontLicenseChecker as well?
		// find the system font directories
		if (getFontPath != null)
		{
			String fPath;
			try
			{
				fPath = (String)getFontPath.invoke(null, new Object[] { Boolean.TRUE });
			}
			catch(Exception e)
			{
				throw new RuntimeException("Could not call getFontPath() for initializing system fonts: " + e, e);
			}
			StringTokenizer parser = new StringTokenizer(fPath, File.pathSeparator);
			while (parser.hasMoreTokens())
			{
				findFonts(parser.nextToken());
			}
		}
	}

	protected void findFonts(String path)
	{
		File file = new File(path);

		if (! file.exists())
		{
			throw new RuntimeException("Font or dir not found: " + file);
		}

		if (file.isDirectory())
		{
			File[] children = file.listFiles();
			if (children != null)
			{
				for (int i = 0; i < children.length; i++)
				{
					File child = children[i];
					if (child.isDirectory() || child.toString().toLowerCase().endsWith(".ttf"))
					{
						findFonts(child.toString());
					}
				}
			}
		}
		else
		{
			Font font = null;
			String err = null;
			try
			{
				font = Font.create(file.toString());
			}
			catch(Exception e)
			{
				err = e.toString();
			}

			if (font == null || font.getOS2Table() == null || font.getNameTable() == null)
			{
				System.err.println("Error reading " + file + ": " + err);
			}
			else
			{
				Os2Table os2Table = font.getOS2Table();
				int fsType = os2Table.getLicenseType();

				NameTable name = font.getNameTable();
				String copyright = name.getRecord(Table.nameCopyrightNotice);
				String trademark = name.getRecord(Table.nameTrademark);

				String postScriptName = name.getRecord(Table.namePostscriptName);
				LocalFont localFont = new LocalFont(postScriptName, path, fsType, copyright, trademark);
				LocalFont cachedFont = fonts.get(postScriptName);

				if (cachedFont != null)
				{
					if (! localFont.equals(cachedFont))
					{
						// FIXME: localize if we're keeping this class
						System.out.println("Found different fonts with the same postscript name. Keeping font " +
								postScriptName + " found at  " + cachedFont.path + " and ignoring " + localFont.path);
					}
				}
				else
				{
					fonts.put(postScriptName, localFont);

					if (printForMap)
					{
						System.out.println("defaultLocalFonts.put(\"" + postScriptName + "\", new LocalFont(\"" +
								postScriptName + "\", null, " + fsType + ", \"" + copyright + "\", \"" + trademark + "\"));");
					}
				}
			}
		}
	}

	public void save() throws IOException
	{
		if (fonts.size() == 0)
		{
			System.err.println("No fonts were found.  You must specify the system font directories.");
		}

		OutputStream buffStream = new BufferedOutputStream(new FileOutputStream("localFonts.ser"));
		ObjectOutputStream out = new ObjectOutputStream(buffStream);
		out.writeObject(fonts);
		out.flush();
		buffStream.close();
	}

	static
	{
		try
		{
			Class cls = Class.forName("sun.awt.font.NativeFontWrapper", true, Thread.currentThread().getContextClassLoader());
			//Method method = cls.getMethod("getFontPath", new Class[] { Boolean.class });
			// this is painful... don't know why do we have to do this instead of calling the commented-out call above
			Method[] meth = cls.getMethods();
			for (int i = 0; i < meth.length; i++)
			{
				Method method = meth[i];
				if (method.getName().equals("getFontPath"))
				{
					getFontPath = method;
					break;
				}
			}
		}
		catch(Exception e)
		{
			// ignore exception, not on Sun jdk 1.4 or lower

			try
			{
				Class cls = Class.forName("sun.font.FontManager", true, Thread.currentThread().getContextClassLoader());
				getFontPath = cls.getMethod("getFontPath", new Class[] { Boolean.class });
			}
			catch(Exception e2)
			{
				// ignore exception, not on Sun jdk 1.5
			}
		}

	}
}
