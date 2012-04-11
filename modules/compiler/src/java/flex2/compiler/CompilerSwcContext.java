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

import flash.localization.LocalizationManager;
import flash.swf.tags.DefineTag;
import flex2.compiler.i18n.TranslationFormat;
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.ResourceFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.swc.SwcComponent;
import flex2.compiler.swc.Swc;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.swc.SwcDependencySet;
import flex2.compiler.swc.SwcGroup;
import flex2.compiler.swc.SwcLibrary;
import flex2.compiler.swc.SwcPathResolver;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.QNameMap;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.Mxmlc;
import java.io.UnsupportedEncodingException;
import java.util.*;

/**
 * Loads and merges all the SWC specified by the
 * external-library-path, rsl-library-path, and library-path, then
 * supports various queries, like getSource() and getResourceBundle().
 * Most of the work is handled by SwcGroup.
 *
 * @author Roger Gonzalez
 * @author Brian Deitte
 * @see flex2.compiler.swc.SwcGroup
 */
public class CompilerSwcContext
{
	private final static String DOT_CSS = ".css";
	private final static String DOT_PROPERTIES = ".properties";
	private final static String LOCALE_SLASH = "locale/";

	public CompilerSwcContext()
	{
		this(false);
	}

	/**
	 * 
	 * @param cacheSwcCompilationUnits - set to true to allow toolchains, such as the OEM interface, 
	 *     to share the SwcCache singleton among multiple compile targets.
	 */
	public CompilerSwcContext(boolean cacheSwcCompilationUnits)
	{
		this.cacheSwcCompilationUnits = cacheSwcCompilationUnits;
	}

    public int load( VirtualFile[] libPath,
                     VirtualFile[] rslPath,
                     VirtualFile[] themeFiles,
					 VirtualFile[] includeLibraries,
					 NameMappings mappings,
					 TranslationFormat format,
                     SwcCache swcCache )
    {
        if (ThreadLocalToolkit.getBenchmark() != null)
        {
            ThreadLocalToolkit.getBenchmark().benchmark2("start loading swcs", true);
        }

        SwcGroup libGroup = null;
        if ((libPath != null) && (libPath.length > 0))
        {
            libGroup = swcCache.getSwcGroup(libPath);
	        addTimeStamps(libGroup);
        }

		SwcGroup rslGroup = null;
        if ((rslPath != null) && (rslPath.length > 0))
        {
            rslGroup = swcCache.getSwcGroup(rslPath);
            externs.addAll( rslGroup.getScriptMap().keySet() );
	        addTimeStamps(rslGroup);
        }

		SwcGroup includeGroup = null;
		if ((includeLibraries != null) && (includeLibraries.length > 0))
		{
			includeGroup = swcCache.getSwcGroup(includeLibraries);
			includes.addAll(includeGroup.getScriptMap().keySet());
			addResourceIncludes(includeGroup.getFiles());
			addTimeStamps(includeGroup);

            files.putAll( includeGroup.getFiles() );
        }

		List<SwcGroup> groupList = new LinkedList<SwcGroup>();
        groupList.add( libGroup );
        groupList.add( rslGroup );
		groupList.add( includeGroup );

		for (int i = 0; themeFiles != null && i < themeFiles.length; ++i)
        {
            if (themeFiles[i].getName().endsWith( DOT_CSS ))
            {
                themeStyles.add( themeFiles[i] );
	            ts.append(themeFiles[i].getLastModified());
            }
            else
            {
                SwcGroup tmpThemeGroup = swcCache.getSwcGroup( new VirtualFile[] {themeFiles[i] } );
                groupList.add( tmpThemeGroup );
                for (Iterator it = tmpThemeGroup.getFiles().values().iterator(); it.hasNext();)
                {
                    VirtualFile f = (VirtualFile) it.next();
	                ts.append(f.getLastModified());
                    if (f.getName().endsWith( DOT_CSS ))
                        themeStyles.add( f );
                }
            }
        }

        swcGroup = swcCache.getSwcGroup( groupList, rslGroup );

        if (swcGroup == null)
        {
            return 0;
        }

        toQNameMap(def2script, swcGroup.getScriptMap()); // populate def2script
        updateResourceBundles(swcGroup.getFiles(), format);
        updateObsoletedSources();
        
	    Set qnames = swcGroup.getQNames();
	    for (Iterator iterator = qnames.iterator(); iterator.hasNext();)
	    {
		    QName qName = (QName)iterator.next();
		    packageNames.add(qName.getNamespace());
	    }

        ThreadLocalToolkit.getPathResolver().addSinglePathResolver(new SwcPathResolver(swcGroup));

        mappings.addMappings( swcGroup.getNameMappings() );
        int num = swcGroup.getNumberLoaded();
        loaded += num;
        
        if (ThreadLocalToolkit.getBenchmark() != null)
        {
            LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
            ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new Mxmlc.LoadedSWCs(loaded)));
        }

        return num;
    }

	public int load( VirtualFile[] libPath,
					 NameMappings mappings,
					 String resourceFileExt,
					 SwcCache swcCache)
	{
		int retval = load(libPath, null, null, null, mappings, null, swcCache);
		if (swcGroup != null)
		{
			updateResourceBundles(swcGroup.getFiles(), resourceFileExt);
		}
		return retval;
	}

    private void addResourceIncludes(Map<String, VirtualFile> files)
    {
        Iterator<String> iterator = files.keySet().iterator();

        while (iterator.hasNext())
        {
            String fileName = iterator.next();

            if (fileName.startsWith(LOCALE_SLASH) && fileName.endsWith(DOT_PROPERTIES))
            {
                int begin = LOCALE_SLASH.length();
                begin = fileName.indexOf("/", begin) + 1;
                int end = fileName.length() - DOT_PROPERTIES.length();
                resourceIncludes.put(fileName.substring(begin, end).replace('/', '.'),
                                     files.get(fileName));
            }
        }
    }

	/**
	 * Get a file from specific SWC.   This should only be used for files already resolved by getFiles().
	 * Format is swclocation$filename
 	 */
	public VirtualFile getFile(String name)
	{
		return (swcGroup != null) ? swcGroup.getFile(name) : null;
	}

	/**
	 * Get a map for files that are in this context's SwcGroup.
	 * 
	 * @return Map of file in this context's swc group; key = filename, value = VirtualFile
 	 */
	public Map<String, VirtualFile> getFiles()
	{
		return (swcGroup != null) ? swcGroup.getFiles() : Collections.<String, VirtualFile>emptyMap();
	}


	private void addTimeStamps(SwcGroup libGroup)
	{
		if (libGroup != null)
		{
			List lastModified = libGroup.getSwcTimes();
			for (int i = 0, size = lastModified.size(); i < size; i++)
			{
				ts.append(lastModified.get(i));
			}
		}
	}

	public VirtualFile[] getVirtualFiles(String[] locales, String namespaceURI, String localPart)
	{
        Map rbFiles = rb2file.get(namespaceURI, localPart); 
        if (rbFiles == null || locales.length == 0)
        {
        	return null;
        }
        
        VirtualFile[] rbList = locales.length == 0 ? null : new VirtualFile[locales.length];
        for (int i = 0; i < locales.length; i++)
        {
        	rbList[i] = (VirtualFile) rbFiles.get(locales[i]);
        }
        
        return rbList;        
	}
	
	public Source getResourceBundle(String[] locales, String namespaceURI, String localPart)
	{
		if (locales.length == 0) return null;
		
        if (rb2source.containsKey( namespaceURI, localPart ))
            return rb2source.get( namespaceURI, localPart );
                
        Source s = null;
        
        VirtualFile[] rbList = getVirtualFiles(locales, namespaceURI, localPart);
        if (rbList != null && rbList.length > 0)
        {
        	String name = null;
        	
        	for (int i = 0; i < rbList.length; i++)
        	{
        		if (rbList[i] != null)
        		{
        			name = rbList[i].getName();
        			break;
        		}
        	}
        	
        	if (name != null)
        	{
        		rb2source.put(namespaceURI, localPart,
        					  s = new Source(new ResourceFile(name, locales, rbList, new VirtualFile[rbList.length]),
        							  		 null,
        							  		 namespaceURI.replace('.', '/'),
        							  		 localPart,
        							  		 this,
        							  		 false,
        							  		 false,
        							  		 false));
        	}
        }
        
        return s;
	}

    public Map<Source, String> getObsoletedSources()
    {
        return obsoletedSources;
    }

    public Source getSource( String namespaceURI, String localPart )
    {
        Source s = def2source.get( namespaceURI, localPart );

        if (s == null)
        {
            SwcScript script = def2script.get( namespaceURI, localPart );

            if (script != null)
            {
                s = createSource(script);

                if (s != null)
                {
                    Iterator<String> iterator = script.getDefinitionIterator();

                    while (iterator.hasNext())
                    {
                        def2source.put(new QName(iterator.next()), s);
                    }

                    name2source.put(s.getName(), s);

                    CompilationUnit cachedCompilationUnit = script.getCompilationUnit();

                    if ((cachedCompilationUnit != null) && (s.isInternal() || cachedCompilationUnit.hasTypeInfo))
                    {
                        Source.copyCompilationUnit(cachedCompilationUnit, s.getCompilationUnit(), false);
                    }

                    if (cacheSwcCompilationUnits)
                    {
                        script.setCompilationUnit(s.getCompilationUnit());
                    }
                }
            }
        }

        return s;
    }
    
    private Source createSource(SwcScript script)
    {
        String loc = script.getLibrary().getSwcLocation();
        InMemoryFile f = new InMemoryFile( script.getABC(), script.toString(), MimeMappings.ABC, script.getLastModified() );

	    // FIXME: C: I tried to set playerglobal.swc as an externally lib, but FlexMovie seems to allow externs on the last frame??
	    Source s = (loc.endsWith(StandardDefs.SWC_PLAYERGLOBAL) ||
					loc.endsWith(StandardDefs.SWC_AIRGLOBAL) ||
					loc.endsWith(StandardDefs.SWC_AVMPLUS)) ?
					new Source(f, "", "", script, true, false, false):
					new Source(f, "", "", script, false, false, false);
		// C: abc-based Sources don't need path resolution. null is fine...
		s.setPathResolver(null);
        CompilationUnit u = s.newCompilationUnit(null, new CompilerContext());
        u.setSignatureChecksum(script.getSignatureChecksum());

        for (Iterator i = script.getDefinitionIterator(); i.hasNext();)
        {
            u.topLevelDefinitions.add(new QName((String) i.next()));
        }

        SwcDependencySet set = script.getDependencySet();

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.INHERITANCE); i != null && i.hasNext();)
        {
            u.inheritance.add(new MultiName((String) i.next()));
        }

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.SIGNATURE); i != null && i.hasNext();)
        {
            u.types.add(new MultiName((String) i.next()));
        }

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.NAMESPACE); i != null && i.hasNext();)
        {
            u.namespaces.add(new MultiName((String) i.next()));
        }

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.EXPRESSION); i != null && i.hasNext();)
        {
            u.expressions.add(new MultiName((String) i.next()));
        }
        
        // C: use symbol dependencies to obtain additional class dependencies,
        //    i.e. classX --> symbolX --> symbolY --> classY, but there is no dependency between classX and classY.
        for (Iterator i = script.getSymbolClasses().iterator(); i.hasNext(); )
        {
        	u.expressions.add(new MultiName((String) i.next()));
        }

        for (Iterator i = script.getDefinitionIterator(); i.hasNext();)
        {
            String name = (String) i.next();
            DefineTag tag = script.getLibrary().getSymbol( name );
            if (tag != null)
            {
                u.getAssets().add( name, tag );
            }
        }

        if (loc.trim().length() < loc.length())
        {
            errlocations.add( loc.trim() );
            return null;
        }
        return s;
    }

    public int getNumberLoaded()
    {
        return loaded;
    }

    public Set<String> getExterns()
    {
        return externs;
    }

	public Set<String> getIncludes()
	{
		return includes;
	}

	public Map<String, VirtualFile> getResourceIncludes()
	{
		return resourceIncludes;
	}

    public Map<String, VirtualFile> getIncludeFiles()
    {
        return files;
    }

    public boolean hasPackage(String packageName)
	{
		return packageNames.contains(packageName);
	}

	public boolean hasDefinition(QName qName)
	{
		return def2script.get(qName.getNamespace(), qName.getLocalPart()) != null;
	}

	public List<VirtualFile> getThemeStyleSheets()
    {
        return themeStyles;
    }

    public List<String> errorLocations()
    {
        return errlocations;
    }

	public int checksum()
	{
		byte[] b = null;

		try
		{
			b = ts.toString().getBytes("UTF8");
		}
		catch (UnsupportedEncodingException ex)
		{
			b = ts.toString().getBytes();
		}

		int checksum = 0;

		// C: There are better algorithms to calculate checksums than this. Let's worry about it later.
		for (int i = 0; i < b.length; i++)
		{
			checksum += b[i];
		}

		return checksum;
	}

	public void close()
	{
        if (!locked && swcGroup != null)
		{
			swcGroup.close();
		}
	}

    public void setLock(boolean lock)
    {
        locked = lock;
    }
    

    /**
	 * Get an individual swc.
	 * 
	 * @param name - name of the swc's virtual filename, may not be null.
	 * @return Swc - the swc in this context or null if the swc is not found.
	 * @throws NullPointerException - if name is null 
	 */
    public Swc getSwc(String name) 
    {
    	return (swcGroup != null) ? swcGroup.getSwc(name) : null;
    }

    private boolean locked = false;

    private SwcGroup swcGroup;
	private QNameMap<Source> def2source = new QNameMap<Source>();
    private QNameMap<SwcScript> def2script = new QNameMap<SwcScript>();
    private Map<String, Source> name2source = new HashMap<String, Source>();
    private QNameMap<Source> rb2source = new QNameMap<Source>();
    private QNameMap<Map<String, VirtualFile>> rb2file = new QNameMap<Map<String, VirtualFile>>();
    private Set<SwcComponent> components;
	private Set<String> packageNames = new HashSet<String>();
    private Set<String> externs = new HashSet<String>();
    private Set<String> includes = new LinkedHashSet<String>();
    private Map<String, VirtualFile> resourceIncludes = new HashMap<String, VirtualFile>();
    private Map<String, VirtualFile> files = new HashMap<String, VirtualFile>();
    private int loaded = 0;
    private List<VirtualFile> themeStyles = new LinkedList<VirtualFile>();
    private List<String> errlocations = new LinkedList<String>();
	private StringBuilder ts = new StringBuilder(); // last modified time of all the swc and css files...
	private boolean cacheSwcCompilationUnits; // if true, we setup storage for intermediate type info objects when doing incremental compilation...
    private Map<Source, String> obsoletedSources = new HashMap<Source, String>();
    
    /**
     * Copy a script map from the SWC cache into the compiler's script map.
     * @param qNameMap - destination map.
     * @param scriptMap - source map
     */
	private void toQNameMap(QNameMap<SwcScript> qNameMap, Map<String, SwcScript> scriptMap)
	{
		for (String key : scriptMap.keySet() )
		{
			qNameMap.put(new QName(key), scriptMap.get(key));
		}
	}
	
    private void updateObsoletedSources()
    {
        Map<SwcScript, String> obsoleted = swcGroup.getObsoleted();

        for (Map.Entry<SwcScript, String> entry : obsoleted.entrySet())
        {
            SwcScript swcScript = entry.getKey();
            CompilationUnit compilationUnit = swcScript.getCompilationUnit();
                    
            if (compilationUnit != null)
            {
                Source source = compilationUnit.getSource();
                
                if ((source != null) && (source.getOwner() == swcScript))
                {
                    obsoletedSources.put(source, entry.getValue());
                }
            }
        }
    }

	private void updateResourceBundles(Map files, TranslationFormat format)
	{
		for (Iterator i = files.keySet().iterator(); format != null && i.hasNext();)
		{
			String name = (String) i.next();
			if (name.startsWith("locale/"))
			{
				VirtualFile file = (VirtualFile) files.get(name);
				int prefixLength = "locale/".length(), index = name.indexOf('/', prefixLength);
				String mimeType = file.getMimeType();
				if (index != -1 && format.isSupported(mimeType))
				{
					String locale = name.substring(prefixLength, index);
					String ext = MimeMappings.getExtension(mimeType);
					QName rbName = new QName(NameFormatter.toColon(name.substring(index + 1, name.length() - ext.length()).replace('/', '.')));
					
					Map<String, VirtualFile> rbFiles = rb2file.get(rbName);
					if (rbFiles == null)
					{
						rb2file.put(rbName, rbFiles = new HashMap<String, VirtualFile>());
					}
					rbFiles.put(locale, file);
				}
			}
		}
	}
	
	private void updateResourceBundles(Map files, String ext)
	{
		for (Iterator i = files.keySet().iterator(); ext != null && i.hasNext();)
		{
			String name = (String) i.next();
			if (name.startsWith("locale/") && name.endsWith(ext))
			{
				VirtualFile file = (VirtualFile) files.get(name);
				int prefixLength = "locale/".length(), index = name.indexOf('/', prefixLength);
				if (index != -1)
				{
					String locale = name.substring(prefixLength, index);
					QName rbName = new QName(NameFormatter.toColon(name.substring(index + 1, name.length() - ext.length()).replace('/', '.')));
					
					Map<String, VirtualFile> rbFiles = rb2file.get(rbName);
					if (rbFiles == null)
					{
						rb2file.put(rbName, rbFiles = new HashMap<String, VirtualFile>());
					}
					rbFiles.put(locale, file);
				}
			}
		}
	}
	
	public Iterator<QName> getDefinitionIterator()
	{
		return def2script.keySet().iterator();
	}

    /**
     * Used by CompilerAPI to lookup potential replacements for
     * removed scripts, without creating a Source, which would happen
     * if getSource() was used.
     */
    SwcScript getScript(QName qName)
    {
        return def2script.get(qName);
    }

	// C: Only the Flex Compiler API (flex-compiler-oem.jar) uses this method.
	//    Do not use it in the mxmlc/compc codepath.
	public flex2.tools.oem.Script getScript(QName def, boolean includeBytecodes)
	{
		SwcScript s = def2script.get(def);
		return (s != null) ? s.toScript(includeBytecodes) : null;
	}

	// C: Only the Flex Compiler API (flex-compiler-oem.jar) uses this method.
	//    Do not use it in the mxmlc/compc codepath.
	public Iterator<SwcComponent> getComponentIterator()
	{
		if (components == null)
		{
			components = new HashSet<SwcComponent>();
			
			for (Iterator<QName> i = getDefinitionIterator(); i.hasNext(); )
			{
				QName def = i.next();
				SwcScript script = def2script.get(def);
				SwcComponent c = script.getLibrary().getSwc().getComponent(def.toString());
				if (c != null)
				{
					components.add(c);
				}
			}
		}
		
		return components.iterator();
	}
	
	public NameMappings getNameMappings()
	{
		return (swcGroup != null) ? swcGroup.getNameMappings() : null;
	}
	
	/**
	 * Find the signature checksum of a definition.
	 * 
	 * @param def - may not be null
	 * @return Signature checksum of def, null if def not found or a 
	 * 			signature checksum does not exist for def.
	 * @throws NullPointerException if def is null.
	 */
	public Long getChecksum(QName def)
	{
		if (def == null)
		{
			throw new NullPointerException("getCheckSum: def may not be null");
		}
		
		SwcScript script = def2script.get(def);
		if (script != null)
		{
			return script.getSignatureChecksum();
		}
		
		return null;
	}

    /**
     * Used by CompilerAPI to lookup the associated script for a
     * Source, so it can be cleaned up when a dependency changes.
     */
    SwcScript getCachedScript(QName qName)
    {
        return def2script.get(qName);
    }

    /**
     * Returns the Source for each SwcScript, which is internal or has
     * type information, but is not obsoleted and not removed.
     */
    Set<Source> cachedSources()
    {
        Set<Source> result = new HashSet<Source>();

        for (SwcScript swcScript : def2script.values())
        {
            CompilationUnit compilationUnit = swcScript.getCompilationUnit();

            if (compilationUnit != null)
            {
                Source source = compilationUnit.getSource();
                            
                if ((source != null) && 
                    (source.getCompilationUnit() != null) &&
                    (source.isInternal() ||
                     source.getCompilationUnit().hasTypeInfo))
                {
                    result.add(source);
                }
            }
        }

        return result;
    }

	public static class Loaded extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 250929749146786933L;

        public Loaded(int loaded)
        {
            super();
            this.loaded = loaded;
        }

        public final int loaded;
    }
}
