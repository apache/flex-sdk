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

package flex.tools.debugger.cli;

import flash.tools.debugger.Session;
import flash.tools.debugger.SourceFile;
import flash.tools.debugger.SwfInfo;
import flash.tools.debugger.InProgressException;
import flash.tools.debugger.NoResponseException;

import flash.util.IntMap;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;

/**
 * FileInfoCache manages a list of files that are unique
 * across multiple swfs.
 */
public class FileInfoCache implements Comparator<SourceFile>
{
	Session m_session;

	/**
	 * We can get at files by module id or path
	 */
	IntMap				m_byInt = new IntMap();
	SourceFile[]		m_files = null;
	SwfInfo				m_swfFilter = null;
	int					m_swfsLoaded = 0;
    boolean             m_dirty = false;

	public FileInfoCache() {}

	public void			bind(Session s)									{ setSession(s); }
	public void			unbind()										{ m_session = null; }
	public SourceFile	getFile(int i)									{ populate(); return (SourceFile)m_byInt.get(i);	}
	public SourceFile[]	getFileList()									{ populate(); return m_files; }
	public Iterator     getAllFiles()									{ populate(); return m_byInt.iterator(); }
    public SwfInfo      getSwfFilter()                                  { return m_swfFilter; }
    public boolean      isSwfFilterOn()                                 { return (m_swfFilter != null); }
    public void         setDirty()                                      { m_dirty = true; }

	void setSession(Session s)
	{
		m_session = s;
		m_swfFilter = null;
		clear();
	}

	void populate()
	{
		// do we have a new swf to load?
		if (m_session != null && (m_dirty || getSwfs().length > m_swfsLoaded))
			reloadCache();
	}

	void reloadCache()
	{
		clear();
		loadCache();
        m_dirty = false;
	}

	void clear()
	{
		m_byInt.clear();
		m_files = null;
	}

	/**
	 * Determine if the given SourceFile is in the current fileList
	 */
	public boolean inFileList(SourceFile f)
	{
		boolean isIt = false;

		SourceFile[] files = getFileList();
		for(int i=0; i<files.length && !isIt; i++)
		{
			if (files[i] == f)
				isIt = true;
		}
		return isIt;
	}

	/**
	 * Go out to the session and request a list of files
	 * But we dump ones that have a name collision.
	 * Also if selectedSwf is set then we only add files
	 * that are contained within the given swf.
	 */
	void loadCache()
	{
		boolean worked = true; // check that all worked correctly
		ArrayList<SourceFile> files = new ArrayList<SourceFile>();
		SwfInfo[] swfs = getSwfs();
		for(int i=0; i<swfs.length; i++)
		{
			if (swfs[i] != null)
				worked = loadSwfFiles(files, swfs[i]) ? worked : false;
		}

		// trim the file list
		ArrayList<SourceFile> fa = trimFileList(files);
		m_files = fa.toArray( new SourceFile[fa.size()] );

		// sort this array in place so calls to getFileList will be ordered
		Arrays.sort(m_files, this);

		// mark our cache complete if all was good.
		if (worked)
			m_swfsLoaded = swfs.length;
	}

	boolean loadSwfFiles(ArrayList<SourceFile> ar, SwfInfo swf)
	{
		boolean worked = true;
		try
		{
			// @todo should we include unloaded swfs?
			SourceFile[] files = swf.getSourceList(m_session);
			ar.ensureCapacity(ar.size()+files.length);

			// add each file to our global source file IntMap and our list
			for(int i=0; i<files.length; i++)
			{
				putFile(files[i]);
				ar.add(files[i]);
			}
		}
		catch(InProgressException ipe)
		{
			// can't load this one, its not ready yet
			worked = false;
		}
		return worked;
	}

	/**
	 * Walk the file list looking for name collisions.
	 * If we find one, then we remove it
	 */
	ArrayList<SourceFile> trimFileList(ArrayList<SourceFile> files)
	{
		HashMap<String, String> names = new HashMap<String, String>();
		ArrayList<SourceFile> list = new ArrayList<SourceFile>();

		int size = files.size();
		for(int i=0; i<size; i++)
		{
			boolean addIt = false;

			SourceFile fi = files.get(i);
			// no filter currently in place so we add the file as long
			// as no duplicates exist.  We use the original Swd full
			// name for matching.
			String fName = fi.getRawName();
			if (m_swfFilter == null)
			{
				// If it exists, then we don't add it!
				if (names.get(fName) == null)
					addIt = true;
			}
			else
			{
				// we have a filter in place so, see
				// if the source file is in our currently
				// selected swf.
				addIt = m_swfFilter.containsSource(fi);
			}

			// did we mark this one to add?
			if (addIt)
			{
				names.put(fName, fName);
				list.add(fi);
			}
		}
		return list;
	}

	/**
	 * All files from all swfs are placed into our byInt map
	 * since we know that ids are unique across the entire
	 * Player session.
	 *
	 * This is also important in the case that the player
	 * halts in one of these files, that the debugger
	 * be able to locate the SourceFile so that we can
	 * display the correct context for the user.
	 */
	void putFile(SourceFile s)
	{
		int i = s.getId();
		m_byInt.put(i, s);
	}

	/**
	 * Attempt to set a swf as a filter
	 * for the file list that we create
	 */
	public boolean setSwfFilter(String swfName)
	{
		// look for a match in our list
		boolean worked = false;
		if (swfName == null)
		{
			m_swfFilter = null;
			worked = true;
		}
		else
		{
			SwfInfo[] swfs = getSwfs();
			for(int i=0; i<swfs.length; i++)
			{
				SwfInfo e = swfs[i];
				if (e != null && nameOfSwf(e).equalsIgnoreCase(swfName))
				{
					worked = true;
					m_swfFilter = e;
					break;
				}
			}
		}

		// reload if it worked
		if (worked)
			reloadCache();

		return worked;
	}

	// list all swfs we know about
	public SwfInfo[] getSwfs()
	{
		SwfInfo[] swfs = null;
		try
		{
			swfs = m_session.getSwfs();
		}
		catch(NoResponseException nre)
		{
			swfs = new SwfInfo[] {};  // oh bery bad
		}
		return swfs;
	}

	/**
	 * Given a SourceFile locate the swf which it came from
	 */
	public SwfInfo swfForFile(SourceFile f)
	{
		// We use the id to determine which swf this source files resides in
		int id = f.getId();
		SwfInfo info = null;
		SwfInfo[] swfs = getSwfs();
		for(int i=0; ( i<swfs.length && (info == null) ); i++)
		{
			if (swfs[i] != null && swfs[i].containsSource(f))
				info = swfs[i];
		}
		return info;
	}

	// locate the name of the swf
	public static String nameOfSwf(SwfInfo e)
	{
		int at = -1;
		String name = e.getUrl();
		if ( (at = e.getUrl().lastIndexOf('/')) > -1)
			name = e.getUrl().substring(at+1);
		if ( (at = e.getUrl().lastIndexOf('\\')) > -1)
			name = e.getUrl().substring(at+1);
		else if ( (at = e.getPath().lastIndexOf('\\')) > -1)
			name = e.getPath().substring(at+1);
		else if ( (at = e.getPath().lastIndexOf('/')) > -1)
			name = e.getPath().substring(at+1);

		// now rip off any trailing ? options
		at = name.lastIndexOf('?');
		name = (at > -1) ? name.substring(0, at) : name;

		return name;
	}

	// locate the name of the swf
	public static String shortNameOfSwf(SwfInfo e)
	{
		String name = nameOfSwf(e);

		// now strip off any leading path
		int at = -1;
		if ( (at = name.lastIndexOf('/')) > -1)
			name = name.substring(at+1);
		else if ( (at = name.lastIndexOf('\\')) > -1)
			name = name.substring(at+1);
		return name;
	}

    /**
     * Given the URL of a specfic swf determine
     * if there is a file within it that appears
     * to be the same as the given source file
     * @param f
     * @return
     */
    public SourceFile similarFileInSwf(SwfInfo info, SourceFile f) throws InProgressException
    {
        SourceFile hit = null;
		SourceFile[] files = info.getSourceList(m_session);
		if (!info.isProcessingComplete())
			throw new InProgressException();

		for(int i=0; i<files.length; i++)
		{
			if (filesMatch(f, files[i]))
				hit = files[i];
		}
        return hit;
    }

	/**
	 * Comparator interface for sorting SourceFiles
	 */
	public int compare(SourceFile o1, SourceFile o2)
	{
		String n1 = o1.getName();
		String n2 = o2.getName();

		return n1.compareTo(n2);
	}

    /**
     * Compare two files and determine if they are the same.
     * Our criteria included only line count package names
     * and the name of the class itself.  If there are
     * any other differences then we won't be able to detect
     * them.  We should probably do something like an MD5
     * computation on the characters in ScriptText. Then
     * we'd really be sure of a match.
     * @param a first file to compare
     * @param b second file to compare
     * @return  true if files appear to be the same
     */
    public boolean filesMatch(SourceFile a, SourceFile b)
    {
        boolean yes = true;

		if (a == null || b == null)
			yes = false;
        else if (a.getPackageName().compareTo(b.getPackageName()) != 0)
            yes = false;
        else if (a.getName().compareTo(b.getName()) != 0)
            yes = false;
        else if (a.getLineCount() != b.getLineCount()) // warning, this is sometimes expensive, so do it last
            yes = false;

        return yes;
    }
    /**
     * Return a array of SourceFiles whose names match
     * the specified string. The array is sorted by name.
	 * The input can be mx.controls.xxx which will
     */
    public SourceFile[] getFiles(String matchString)
    {
        boolean doStartsWith = false;
        boolean doIndexOf = false;
        boolean doEndsWith = false;

        boolean leadingAsterisk = matchString.startsWith("*") && matchString.length() > 1; //$NON-NLS-1$
        boolean trailingAsterisk = matchString.endsWith("*"); //$NON-NLS-1$
        boolean usePath = matchString.indexOf('.') > -1;

        if (leadingAsterisk && trailingAsterisk)
        {
            matchString = matchString.substring(1, matchString.length() - 1);
            doIndexOf = true;
        }
        else if (leadingAsterisk)
        {
            matchString = matchString.substring(1);
            doEndsWith = true;
        }
        else if (trailingAsterisk)
        {
            matchString = matchString.substring(0, matchString.length() - 1);
            doStartsWith = true;
        }
		else if (usePath)
		{
			doIndexOf = true;
		}
		else
        {
            doStartsWith = true;
        }

		SourceFile[] files = getFileList();
        ArrayList<SourceFile> fileList = new ArrayList<SourceFile>();
        int n = files.length;
		int exactHitAt = -1;
		// If the matchString already starts with "." (e.g. ".as" or ".mxml"), then dotMatchString
		// will be equal to matchString; otherwise, dotMatchString will be "." + matchString
		String dotMatchString = (matchString.startsWith(".")) ? matchString : ("." + matchString); //$NON-NLS-1$ //$NON-NLS-2$
        for (int i = 0; i < n; i++)
        {
            SourceFile sourceFile = files[i];
			boolean pathExists = (usePath && sourceFile.getFullPath().matches(".*[/\\\\].*")); //$NON-NLS-1$
            String name = pathExists ? sourceFile.getFullPath() : sourceFile.getName();

			// if we are using the full path string, then prefix a '.' to our matching string so that abc.as and Gabc.as don't both hit
			String match = (usePath && pathExists) ? dotMatchString : matchString;

			name = name.replace('/', '.');  // get rid of path identifiers and use dots
			name = name.replace('\\', '.'); // would be better to modify the input string, but we don't know which path char will be used.

			// exact match? We are done
			if (name.equals(match))
			{
				exactHitAt = i;
				break;
			}
            else if (doStartsWith && name.startsWith(match))
                fileList.add(sourceFile);
			else if (doEndsWith && name.endsWith(match))
                fileList.add(sourceFile);
			else if (doIndexOf && name.indexOf(match) > -1)
				fileList.add(sourceFile);
        }

		// trim all others if we have an exact file match
		if (exactHitAt > -1)
		{
			fileList.clear();
			fileList.add(files[exactHitAt]);
		}

		SourceFile[] fileArray = fileList.toArray( new SourceFile[fileList.size()] );
		Arrays.sort(fileArray, this);
        return fileArray;
    }
}
