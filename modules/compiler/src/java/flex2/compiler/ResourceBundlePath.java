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

package flex2.compiler;

import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.ResourceFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.io.LocalFile;

import java.io.File;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * This class supports looking up a set of sources specified by
 * -resource-bundle-path via findVirtualFiles().
 *
 * @author Clement Wong
 * @author Brian Deitte
 */
public class ResourceBundlePath extends SourcePathBase
{
	public ResourceBundlePath(CompilerConfiguration config, VirtualFile appPath)
	{
		// C: allowSourcePathOverlap is true here because SourcePath will take care of that.
		super(I18nUtils.getTranslationFormat(config).getSupportedMimeTypes(), true);
		
		rbDirectories = new HashMap<String, List<File>>();
		locales = config.getLocales();
		for (int i = 0, size = locales == null ? 0 : locales.length; i < size; i++)
		{
			VirtualFile[] classPath = config.getResourceBundlePathForLocale(locales[i]);
			List<File> directories = new LinkedList<File>();
			
			addApplicationParentToSourcePath(appPath, classPath, directories);
			addPathElements(classPath, directories, allowSourcePathOverlap, warnings);

			rbDirectories.put(locales[i], directories);
		}
	}
	
	private String[] locales;
	private Map<String, List<File>> rbDirectories;
	
	private Source newSource(String name, VirtualFile[] files, VirtualFile[] pathRoots, File pathRoot, String namespaceURI, String localPart)
	{
		return new Source(new ResourceFile(name, locales, files, pathRoots), new LocalFile(pathRoot),
						  namespaceURI.replace('.', '/'), localPart , this, false, false, false);
	}
	
	// see if the Source object continues to be the first choice given a QName.
	boolean checkPreference(Source s)
	{
		assert s.getOwner() == this;
		
		String p, relativePath = s.getRelativePath();
		if (relativePath.length() == 0)
		{
			p = s.getShortName();
		}
		else
		{
			p = (relativePath + "/" + s.getShortName()).replace('/', File.separatorChar);
		}
		ResourceFile rf = (ResourceFile) s.getBackingFile();

		for (int i = 0, length = locales == null ? 0 : locales.length; i < length; i++)
		{
			rf.setLocale(locales[i]);
			VirtualFile resourceFile = rf.getResourceFile();
			List directories = rbDirectories.get(locales[i]);
						
			for (int j = 0, size = directories == null ? 0 : directories.size(); j < size; j++)
			{
				File f, d = (File) directories.get(j);

				try
				{
					if ((f = findFile(d, p, mimeTypes)) != null)
					{
						if (!resourceFile.getName().equals(FileUtil.getCanonicalPath(f)))
						{
							removeSource(s);
							return false;
						}
						else
						{
							break;
						}
					}
				}
				catch (CompilerException ex)
				{
					removeSource(s);
					return false;
				}
			}
		}

		return true;
	}
	
	protected boolean adjustDefinitionName(String namespaceURI, String localPart, Source s, CompilationUnit u)
	{
		return false;
	}

	protected Source findFile(String className, String namespaceURI, String localPart) throws CompilerException
	{
		String p = className.replace(':', '.').replace('.', File.separatorChar);
		VirtualFile[] files = null;
		VirtualFile[] pathRoots = null;
		File pathRoot = null;
		String name = null;
		Source s = null;
		
		for (int i = 0, length = locales == null ? 0 : locales.length; i < length; i++)
		{
			List directories = rbDirectories.get(locales[i]);
			
			for (int j = 0, size = directories == null ? 0 : directories.size(); j < size; j++)
			{
				File f, d = (File) directories.get(j);

				if ((f = findFile(d, p, mimeTypes)) != null)
				{
					if (files == null) files = new VirtualFile[length];
					if (pathRoots == null) pathRoots = new VirtualFile[length];
					
					if (name == null)
					{
						pathRoot = d;
						name = FileUtil.getCanonicalPath(f);
					}
					
					files[i] = new LocalFile(f);
					pathRoots[i] = new LocalFile(d);
					break;
				}
			}
		}

		if (files != null)
		{
			sources.put(className, s = newSource(name, files, pathRoots, pathRoot, namespaceURI, localPart));
		}
		
		return s;
	}
	
	String[] getLocales()
	{
		return locales;
	}
	
	Map<String, List<File>> getResourceBundlePaths()
	{
		return rbDirectories;
	}
	
	public VirtualFile[] findVirtualFiles(String rbName)
	{
		String p = rbName.replace(':', '.').replace('.', File.separatorChar);
		VirtualFile[] files = null;
		
		for (int i = 0, length = locales == null ? 0 : locales.length; i < length; i++)
		{
			List directories = rbDirectories.get(locales[i]);
			
			for (int j = 0, size = directories == null ? 0 : directories.size(); j < size; j++)
			{
				File f, d = (File) directories.get(j);
				try
				{
					if ((f = findFile(d, p, mimeTypes)) != null)
					{
						if (files == null) files = new VirtualFile[length];
						files[i] = new LocalFile(f);
						break;
					}
				}
				catch (CompilerException ex)
				{
				}
			}
		}

		return files;
	}
}
