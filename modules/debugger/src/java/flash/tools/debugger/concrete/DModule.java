/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger.concrete;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SourceFile;
import flash.tools.debugger.SourceLocator;
import flash.tools.debugger.VersionException;
import flash.util.FileUtils;

/**
 * A module which is uniquly identified by an id, contains
 * a short and long name and also a script
 */
public class DModule implements SourceFile
{
	private ScriptText			m_script;			// lazy-initialized by getScript()
	private boolean				m_gotRealScript;
	private final String		m_rawName;
	private final String		m_shortName;
	private final String		m_path;
	private final String		m_basePath;
	private final int			m_id;
	private final int			m_bitmap;
	private final ArrayList<Integer>		m_line2Offset;
	private final ArrayList<Object>			m_line2Func;		// each array is either null, String, or String[]
	private final HashMap<String, Integer>	m_func2FirstLine;	// maps function name (String) to first line of function (Integer)
	private final HashMap<String, Integer>	m_func2LastLine;	// maps function name (String) to last line of function (Integer)
	private String				m_packageName;
	private boolean				m_gotAllFncNames;
	private int					m_anonymousFunctionCounter = 0;
	private SourceLocator		m_sourceLocator;
	private int					m_sourceLocatorChangeCount;
	private int m_isolateId;
	private final static String	m_newline = System.getProperty("line.separator"); //$NON-NLS-1$

	/**
	 * @param name filename in "basepath;package;filename" format
	 */
	public DModule(SourceLocator sourceLocator, int id, int bitmap, String name, String script, int isolateId)
	{
		// If the caller gave us the script text, then we will create m_script
		// now.  But if the caller gave us an empty string, then we won't bother
		// looking for a disk file until someone actually asks for it.
		if (script != null && script.length() > 0)
		{
			m_script = new ScriptText(script);
			m_gotRealScript = true;
		}

		NameParser nameParser = new NameParser(name);

		m_sourceLocator = sourceLocator;
		m_rawName = name;
		m_basePath = nameParser.getBasePath(); // may be null
		m_bitmap = bitmap;
		m_id = id;
		m_shortName = generateShortName(nameParser);
		m_path = generatePath(nameParser);
		m_line2Offset = new ArrayList<Integer>();
		m_line2Func = new ArrayList<Object>();
		m_func2FirstLine = new HashMap<String, Integer>();
		m_func2LastLine = new HashMap<String, Integer>();
		m_packageName = nameParser.getPackage();
        m_gotAllFncNames = false;
        m_isolateId = isolateId;
	}

	public synchronized ScriptText getScript()
	{
		// If we have been using "dummy" source, and the user has changed the list of
		// directories that are searched for source, then we want to search again
		if (!m_gotRealScript &&
			m_sourceLocator != null &&
			m_sourceLocator.getChangeCount() != m_sourceLocatorChangeCount)
		{
			m_script = null;
		}

		// lazy-initialize m_script, so that we don't read a disk file until
		// someone actually needs to look at the file
		if (m_script == null)
		{
            String script = scriptFromDisk(getRawName());
			if (script == null)
			{
				script = ""; // use dummy source for now //$NON-NLS-1$
			}
			else
			{
				m_gotRealScript = true; // we got the real source
			}
			m_script = new ScriptText(script);
		}
		return m_script;
	}

	/* getters */
	public String		getBasePath()			{ return m_basePath; }
	public String		getName()				{ return m_shortName; }
	public String		getFullPath()			{ return m_path; }
	public String       getPackageName()		{ return (m_packageName == null) ? "" : m_packageName; } //$NON-NLS-1$
	public String		getRawName()			{ return m_rawName; }
	public int			getId()					{ return m_id; }
	public int			getBitmap()				{ return m_bitmap; }
	public int			getLineCount()			{ return getScript().getLineCount(); }
	public String		getLine(int i)			{ return (i > getLineCount()) ? "// code goes here" : getScript().getLine(i); } //$NON-NLS-1$

	void setPackageName(String name)    { m_packageName = name; }

	/**
	 * @return the offset within the swf for a given line 
	 * of source.  0 if unknown.
	 */
	public int getOffsetForLine(int line)
	{ 
		int offset = 0;
		if (line < m_line2Offset.size())
		{
			Integer i = m_line2Offset.get(line);
			if (i != null)
				offset = i.intValue();
		}
		return offset;
	}

	public int getLineForFunctionName(Session s, String name)
	{
		int value = -1;
        primeAllFncNames(s);
		Integer i = m_func2FirstLine.get(name);
		if (i != null)
			value = i.intValue();

		return value;
	}

    /*
     * @see flash.tools.debugger.SourceFile#getFunctionNameForLine(flash.tools.debugger.Session, int)
     */
    public String getFunctionNameForLine(Session s, int line)
    {
        primeFncName(s, line);

    	String[] funcNames = getFunctionNamesForLine(s, line);

    	if (funcNames != null && funcNames.length == 1)
    		return funcNames[0];
    	else
    		return null;
    }

	/**
	 * Return the function names for a given line number, or an empty array
	 * if there are none; never returns <code>null</code>.
	 */
    private String[] getFunctionNamesForLine(Session s, int line)
    {
        primeFncName(s, line);

		if (line < m_line2Func.size())
		{
			Object obj = m_line2Func.get(line);
			
			if (obj instanceof String)
				return new String[] { (String) obj };
			else if (obj instanceof String[])
				return (String[]) obj;
		}

		return new String[0];
    }

	public String[] getFunctionNames(Session s)
	{
		/* find out the size of the array */
        primeAllFncNames(s);
		int count = m_func2FirstLine.size();
		return m_func2FirstLine.keySet().toArray(new String[count]);
	}

	private static String generateShortName(NameParser nameParser)
	{
		String name = nameParser.getOriginalName();
		String s = name;

		if (nameParser.isPathPackageAndFilename()) {
			s = nameParser.getFilename();
		} else {
			/* do we have a file name? */
			int dotAt = name.lastIndexOf('.');
			if (dotAt > 1)
			{
				/* yes let's strip the directory off */
				int lastSlashAt = name.lastIndexOf('\\', dotAt);
				lastSlashAt = Math.max(lastSlashAt, name.lastIndexOf('/', dotAt));
	
				s = name.substring(lastSlashAt+1);
			}
			else
			{
				/* not a file name ... */
				s = name;
			}
		}
		return s.trim();
	}

	/**
	 * Produce a name that contains a file specification including full path.
	 * File names may come in as 'mx.bla : file:/bla.foo.as' or as
	 * 'file://bla.foo.as' or as 'C:\'(?) or as 'basepath;package;filename'
	 */
	private static String generatePath(NameParser nameParser)
	{
		String name = nameParser.getOriginalName();
		String s = name;

		/* strip off first colon of stuff if package exists */
		int colonAt = name.indexOf(':');
		if (colonAt > 1 && !name.startsWith("Actions for")) //$NON-NLS-1$
		{
			if (name.charAt(colonAt+1) == ' ')
				s = name.substring(colonAt+2);
		}
		else if (name.indexOf('.') > -1 && name.charAt(0) != '<' )
		{
			/* some other type of file name */
			s = nameParser.recombine();
		}
		else
		{
			// no path
			s = ""; //$NON-NLS-1$
		}
		return s.trim();
	}

	public void lineMapping(StringBuilder sb)
	{
		Map<String, String> args = new HashMap<String, String>();
		args.put("fileName", getName() ); //$NON-NLS-1$
		args.put("fileNumber", Integer.toString(getId()) ); //$NON-NLS-1$
        sb.append(PlayerSessionManager.getLocalizationManager().getLocalizedTextString("functionsInFile", args)); //$NON-NLS-1$
		sb.append(m_newline);

		String[] funcNames = m_func2FirstLine.keySet().toArray(new String[m_func2FirstLine.size()]);
		Arrays.sort(funcNames, new Comparator<String>() {

			public int compare(String o1, String o2) {
				int line1 = m_func2FirstLine.get(o1).intValue();
				int line2 = m_func2FirstLine.get(o2).intValue();
				return line1 - line2;
			}
			
		});

		for (int i=0; i<funcNames.length; ++i)
		{
			String name = funcNames[i];
			int firstLine = m_func2FirstLine.get(name).intValue();
			int lastLine = m_func2LastLine.get(name).intValue();

			sb.append(" "); //$NON-NLS-1$
			sb.append(name);
			sb.append(" "); //$NON-NLS-1$
			sb.append(firstLine);
			sb.append(" "); //$NON-NLS-1$
			sb.append(lastLine);
			sb.append(m_newline);
		}
	}

    int compareTo(DModule other)
    {
        return getName().compareTo(other.getName());
    }

    /**
     * Called in order to make sure that we have a function name available
     * at the given location.  For AVM+ swfs we don't need a swd and therefore
     * don't have access to function names in the same fashion.
     * We need to ask the player for a particular function name.
     */
    void primeFncName(Session s, int line)
    {
		// for now we do all, optimize later
		primeAllFncNames(s);
    }

    void primeAllFncNames(Session s)
    {
        // send out the request for all functions that the player knows
        // about for this module

        // we block on this call waiting for an answer and after we get it
        // the DManager thread should have populated our mapping tables
        // under the covers.  If its fails then no biggie we just won't
        // see anything in the tables.
        PlayerSession ps = (PlayerSession)s;
        if (!m_gotAllFncNames && ps.playerVersion() >= 9)
        {
            try
            {
                ps.requestFunctionNames(m_id, -1, m_isolateId);
            }
            catch (VersionException e)
            {
                ;
            }
            catch (NoResponseException e)
            {
                ;
            }
        }
        m_gotAllFncNames = true;
    }

	void addLineFunctionInfo(int offset, int line, String funcName)
	{
		addLineFunctionInfo(offset, line, line, funcName);
	}

	/**
	 * Called by DSwfInfo in order to add function name / line / offset mapping
	 * information to the module.  
	 */
	void addLineFunctionInfo(int offset, int firstLine, int lastLine, String funcName)
	{
		int line;

		// strip down the function name
		if (funcName == null || funcName.length() == 0)
		{
			funcName = "<anonymous$" + (++m_anonymousFunctionCounter) + ">"; //$NON-NLS-1$ //$NON-NLS-2$
		}
		else
		{
			// colons or slashes then this is an AS3 name, strip off the core::
			int colon = funcName.lastIndexOf(':');
			int slash = funcName.lastIndexOf('/');
			if (colon > -1 || slash > -1)
			{
				int greater = Math.max(colon, slash);
                funcName = funcName.substring(greater+1);
            }
            else
            {
    			int dot = funcName.lastIndexOf('.');
	    		if (dot > -1)
		    	{
                    // extract function and package
                    String pkg = funcName.substring(0, dot);
                    funcName = funcName.substring(dot+1);

                    // attempt to set the package name while we're in here
                    setPackageName(pkg);
//					System.out.println(m_id+"-func="+funcName+",pkg="+pkg);
                }
            }
		}

//		System.out.println(m_id+"@"+offset+"="+getPath()+".adding func="+funcName);

		// make sure m_line2Offset is big enough for the lines we're about to set
		m_line2Offset.ensureCapacity(firstLine+1);
		while (firstLine >= m_line2Offset.size())
			m_line2Offset.add(null);

		// add the offset mapping
		m_line2Offset.set(firstLine, new Integer(offset));

		// make sure m_line2Func is big enough for the lines we're about to se
		m_line2Func.ensureCapacity(lastLine+1);
		while (lastLine >= m_line2Func.size())
			m_line2Func.add(null);

		// offset and byteCode ignored currently, only add the name for the first hit
		for (line = firstLine; line <= lastLine; ++line)
		{
			Object funcs = m_line2Func.get(line);
			// A line can correspond to more than one function.  The most common case
			// of that is an MXML tag with two event handlers on the same line, e.g.
			//		<mx:Button mouseOver="overHandler()" mouseOut="outHandler()" />;
			// another case is the line that declares an inner anonymous function:
			//		var f:Function = function() { trace('hi') }
			// In any such case, we store a list of function names separated by commas,
			// e.g. "func1, func2"
			if (funcs == null)
			{
				m_line2Func.set(line, funcName);
			}
			else if (funcs instanceof String)
			{
				String oldFunc = (String) funcs;
				m_line2Func.set(line, new String[] { oldFunc, funcName });
			}
			else if (funcs instanceof String[])
			{
				String[] oldFuncs = (String[]) funcs;
				String[] newFuncs = new String[oldFuncs.length + 1];
				System.arraycopy(oldFuncs, 0, newFuncs, 0, oldFuncs.length);
				newFuncs[newFuncs.length - 1] = funcName;
				m_line2Func.set(line, newFuncs);
			}
		}

		// add to our function name list
		if (m_func2FirstLine.get(funcName) == null)
		{
			m_func2FirstLine.put(funcName, new Integer(firstLine));
			m_func2LastLine.put(funcName, new Integer(lastLine));
		}
	}

    /**
     * Scan the disk looking for the location of where the source resides.  May
     * also peel open a swd file looking for the source file.
     * @param name original full path name of the source file
     * @return string containing the contents of the file, or null if not found
     */
    private String scriptFromDisk(String name)
    {
        // we expect the form of the filename to be in the form
        // "c:/src/project;debug;myFile.as"
        // where the semicolons demark the include directory searched by the
        // compiler followed by package directories then file name.
        // any slashes are to be forward slash only!

        // translate to neutral form
        name = name.replace('\\','/');  //@todo remove this when compiler is complete

        // pull the name apart
        final char SEP = ';';
        String pkgPart = ""; //$NON-NLS-1$
        String pathPart = ""; //$NON-NLS-1$
        String namePart = ""; //$NON-NLS-1$
        int at = name.indexOf(SEP);
        if (at > -1)
        {
            // have at least 2 parts to name
            int nextAt = name.indexOf(SEP, at+1);
            if (nextAt > -1)
            {
                // have 3 parts
                pathPart = name.substring(0, at);
                pkgPart = name.substring(at+1, nextAt);
                namePart = name.substring(nextAt+1);
            }
            else
            {
                // 2 parts means no package.
                pathPart = name.substring(0, at);
                namePart = name.substring(at+1);
            }
        }
        else
        {
            // should not be here....
            // trim by last slash
            at = name.lastIndexOf('/');
            if (at > -1)
            {
				// cheat by looking for dirname "mx" in path
				int mx = name.lastIndexOf("/mx/"); //$NON-NLS-1$
				if (mx > -1)
				{
					pathPart = name.substring(0, mx);
					pkgPart = name.substring(mx+1, at);
				}
				else
				{
					pathPart = name.substring(0, at);
				}
				
                namePart = name.substring(at+1);
            }
            else
            {
                pathPart = "."; //$NON-NLS-1$
                namePart = name;
            }
        }

        String script = null;
        try
        {
            // now try to locate the thing on disk or in a swd.
        	Charset realEncoding = null;
        	Charset bomEncoding = null;
        	InputStream in = locateScriptFile(pathPart, pkgPart, namePart);
        	if (in != null)
        	{
        		try
        		{
        			// Read the file using the appropriate encoding, based on
        			// the BOM (if there is a BOM) or the default charset for
        			// the system (if there isn't a BOM)
                    BufferedInputStream bis = new BufferedInputStream( in );
                    bomEncoding = getEncodingFromBOM(bis);
        			script = pullInSource(bis, bomEncoding);

        			// If the file is an XML file with an <?xml> directive,
        			// it may specify a different directive 
        			realEncoding = getEncodingFromXMLDirective(script);
        		}
        		finally
        		{
        			try { in.close(); } catch (IOException e) {}
        		}
        	}
        	
        	// If we found an <?xml> directive with a specified encoding, and
        	// it doesn't match the encoding we used to read the file initially,
        	// start over.
        	if (realEncoding != null && !realEncoding.equals(bomEncoding))
        	{
	            in = locateScriptFile(pathPart, pkgPart, namePart);
	            if (in != null)
	            {
					try
					{
						// Read the file using the real encoding, based on the
						// <?xml...> directive
	                    BufferedInputStream bis = new BufferedInputStream( in );
	                    getEncodingFromBOM(bis);
	        			script = pullInSource(bis, realEncoding);
					}
					finally
					{
						try { in.close(); } catch (IOException e) {}
					}
	            }
        	}
        }
        catch(FileNotFoundException fnf)
        {
            fnf.printStackTrace();  // shouldn't really happen
        }
        return script;
    }

    /**
     * Logic to poke around on disk in order to find the given
     * filename.  We look under the mattress and all other possible
     * places for the silly thing.  We always try locating
     * the file directly first, if that fails then we hunt out
     * the swd.
     */
    InputStream locateScriptFile(String path, String pkg, String name) throws FileNotFoundException
    {
		if (m_sourceLocator != null)
		{
			m_sourceLocatorChangeCount = m_sourceLocator.getChangeCount();
			InputStream is = m_sourceLocator.locateSource(path, pkg, name);
			if (is != null)
				return is;
		}

        // convert slashes first
        path = path.replace('/', File.separatorChar);
        pkg = pkg.replace('/', File.separatorChar);
        File f;

        // use a package base directory if it exists
		if (path.length() > 0)
		{
	        try
	        {
				String pkgAndName = ""; //$NON-NLS-1$
				if (pkg.length() > 0) // have to do this so we don't end up with just "/filename"
					pkgAndName += pkg + File.separatorChar;
				pkgAndName += name;
	            f = new File(path, pkgAndName);
	            if (f.exists())
	                return new FileInputStream(f);
	        }
	        catch(NullPointerException npe)
	        {
	            // skip it.
	        }
		}

        // try the current directory plus package
		if (pkg.length() > 0) // new File("", foo) looks in root directory!
		{
			f = new File(pkg, name);
			if (f.exists())
				return new FileInputStream(f);
		}

        // look in the current directory without the package
        f = new File(name);
        if (f.exists())
            return new FileInputStream(f);

        // @todo try to pry open a swd file...
               
        return null;
    }
    
    /**
     * See if this document starts with a BOM and try to figure
     * out an encoding from it.
     * @param bis		BufferedInputStream for document (so that we can reset the stream
     * 					if we establish that the first characters aren't a BOM)
     * @return			CharSet from BOM (or system default / null)
     */
	private Charset getEncodingFromBOM(BufferedInputStream bis)
	{
		Charset bomEncoding = null;
		bis.mark(3);
		String bomEncodingString;
		try
		{
			bomEncodingString = FileUtils.consumeBOM(bis, null);
		}
		catch (IOException e)
		{
			bomEncodingString = System.getProperty("file.encoding"); //$NON-NLS-1$
		}

		bomEncoding = Charset.forName(bomEncodingString);

		return bomEncoding;
	}

    /**
     * Syntax for an <?xml ...> directive with an encoding (used by getEncodingFromXMLDirective)
     */
    private static final Pattern sXMLDeclarationPattern = Pattern.compile("^<\\?xml[^>]*encoding\\s*=\\s*(\"([^\"]*)\"|'([^']*)')"); //$NON-NLS-1$
    
    /**
     * See if this document starts with an <?xml ...> directive and
     * try to figure out an encoding from it.
     * @param entireSource		source of document
     * @return					specified Charset (or null)
     */
    private Charset getEncodingFromXMLDirective(String entireSource)
    {
    	String encoding = null;
    	Matcher xmlDeclarationMatcher = sXMLDeclarationPattern.matcher(entireSource);
    	if (xmlDeclarationMatcher.find())
    	{
    		encoding = xmlDeclarationMatcher.group(2);
    		if (encoding == null)
    			encoding = xmlDeclarationMatcher.group(3);
    		
    		try
    		{
    			return Charset.forName(encoding);
    		}
    		catch (IllegalArgumentException e)
    		{}
    	}
    	return null;
    }

    /**
     * Given an input stream containing source file contents, read in each line
     * @param in			stream of source file contents (with BOM removed)
     * @param encoding		encoding to use (based on BOM, system default, or <?xml...> directive
     * 						if this is null, the system default will be used)
     * @return				source file contents (as String)
     */
    String pullInSource(InputStream in, Charset encoding)
    {
        String script = ""; //$NON-NLS-1$
        BufferedReader f = null;
        try
        {
        	StringBuilder sb = new StringBuilder();
        	Reader reader = null;
        	if (encoding == null)
        		reader = new InputStreamReader(in);
        	else
        		reader = new InputStreamReader(in, encoding);
            f = new BufferedReader(reader);
            String line;
            while((line = f.readLine()) != null)
            {
                sb.append(line);
                sb.append('\n');
            }
            script = sb.toString();
        }
        catch (IOException e)
        {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        return script;
    }

    /** for debugging */
    @Override
	public String toString()
    {
    	return getFullPath();
    }
 
	/**
	 * Given a filename of the form "basepath;package;filename", return an
	 * array of 3 strings, one for each segment.
	 * @param name a string which *may* be of the form "basepath;package;filename"
	 * @return an array of 3 strings for the three pieces; or, if 'name' is
	 * not of expected form, returns null
	 */
	private static class NameParser
	{
		private String fOriginalName;
		private String fBasePath;
		private String fPackage;
		private String fFilename;
		private String fRecombinedName;

		public NameParser(String name)
		{
			fOriginalName = name;

			/* is it of "basepath;package;filename" format? */
			int semicolonCount = 0;
			int i = 0;
			int firstSemi = -1;
			int lastSemi = -1;
			while ( (i = name.indexOf(';', i)) >= 0 )
			{
				++semicolonCount;
				if (firstSemi == -1)
					firstSemi = i;
				lastSemi = i;
				++i;
			}

			if (semicolonCount == 2)
			{
				fBasePath = name.substring(0, firstSemi);
				fPackage = name.substring(firstSemi+1, lastSemi);
				fFilename = name.substring(lastSemi+1);
			}
		}

		public boolean isPathPackageAndFilename()
		{
			return (fBasePath != null);
		}

		public String getOriginalName()
		{
			return fOriginalName;
		}

		public String getBasePath()
		{
			return fBasePath;
		}

		public String getFilename()
		{
			return fFilename;
		}

		public String getPackage()
		{
			return fPackage;
		}

		/**
		 * Returns a "recombined" form of the original name.
		 * 
		 * For filenames which came in in the form "basepath;package;filename",
		 * the recombined name is the original name with the semicolons replaced
		 * by platform-appropriate slash characters.  For any other type of original
		 * name, the recombined name is the same as the incoming name.
		 */
		public String recombine()
		{
			if (fRecombinedName == null)
			{
				if (isPathPackageAndFilename())
				{
					char slashChar;
					if (fOriginalName.indexOf('\\') != -1)
						slashChar = '\\';
					else
						slashChar = '/';

					fRecombinedName = fOriginalName.replaceAll(";;", ";").replace(';', slashChar); //$NON-NLS-1$ //$NON-NLS-2$
				}
				else
				{
					fRecombinedName = fOriginalName;
				}
			}
			return fRecombinedName;
		}
	}

}
