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

import flex2.compiler.common.MxmlConfiguration;
import flex2.compiler.common.PathResolver;
import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.LineNumberMap;
import flex2.compiler.util.LocalLogger;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.oem.ApplicationCache;
import macromedia.asc.semantics.TypeValue;
import macromedia.asc.util.Context;

import java.io.IOException;
import java.io.InputStream;
import java.util.*;
import java.util.Map.Entry;

/**
 * This class represents the information associated with a single file
 * while it's being compiled.  This information includes the
 * <code>pathRoot</code>, the <code>relativePath</code>, the
 * <code>shortName</code>, which is often the class name, the owner,
 * which specifies where the Source came from, and whether the
 * <code>Source</code> is internal, root, and debuggable.
 *
 * @author Clement Wong
 */
public final class Source implements Comparable<Source>
{
	// used by flex2.compiler.i18n.I18nCompiler, InterfaceCompiler and ImplementationCompiler
	public Source(VirtualFile file, Source original)
	{
		this(file, original.pathRoot, original.relativePath, original.shortName, original.owner, original.isInternal, original.isRoot, original.isDebuggable);
		this.delegate = original;
	}

	// used by InterfaceCompiler.createInlineComponentUnit().  Note the owner will be set
	// later by the ResourceContainer when this is passed into addResource() by
	// CompilerAPI.addGeneratedSources().
	public Source(VirtualFile file, Source original, String shortName, boolean isInternal, boolean isRoot)
	{
		this(file, original.pathRoot, original.relativePath, shortName, null, isInternal, isRoot, true);
		this.delegate = original;
	}

	// used by FileSpec
	public Source(VirtualFile file, String relativePath, String shortName, Object owner, boolean isInternal, boolean isRoot)
	{
		this(file, null, relativePath, shortName, owner, isInternal, isRoot, true);
	}

	// used by SourceList and SourcePath
	public Source(VirtualFile file, VirtualFile pathRoot, String relativePath, String shortName, Object owner, boolean isInternal, boolean isRoot)
	{
		this(file, pathRoot, relativePath, shortName, owner, isInternal, isRoot, true);
	}

	// used by StylesContainer, CompilerSwcContext, EmbedEvaluator, DataBindingExtension and PreLink
	public Source(VirtualFile file, String relativePath, String shortName, Object owner, boolean isInternal, boolean isRoot, boolean isDebuggable)
	{
		this(file, null, relativePath, shortName, owner, isInternal, isRoot, isDebuggable);
	}

	Source(VirtualFile file, VirtualFile pathRoot, String relativePath, String shortName, Object owner, boolean isInternal, boolean isRoot, boolean isDebuggable)
	{
		this.file = file;
		this.pathRoot = pathRoot;
		this.relativePath = relativePath;
		this.shortName = shortName;
		this.owner = owner;
		this.isInternal = isInternal;
		this.isRoot = isRoot;
		this.isDebuggable = isDebuggable;

		if (file != null)
		{
			fileTime = file.getLastModified();
		}

		fileIncludeTimes = new HashMap<VirtualFile, Long>(4);
	}

	private VirtualFile file;
	private VirtualFile pathRoot;
	// 'resolver' doesn't need persistence because it's constructed from pathRoot.
	private PathResolver resolver;
	private String relativePath, shortName;
	private Object owner;
	private boolean isInternal;
	private boolean isRoot;
	private boolean isDebuggable;
	private boolean isPreprocessed;

	private CompilationUnit unit;

	private long fileTime;
	private Map<VirtualFile, Long> fileIncludeTimes;

	// 1. path resolution
	// 2. backing file
	// 3. source fragments
	private Source delegate;

	/**
     * This is a per-Source/CompilationUnit logger.  The
     * ThreadLocalToolkit logger is a per-compile logger.  This logger
     * is usually wired to the ThreadLocalToolkit logger.  During the
     * life of a Source, this logger be nulled out, when it's no
     * longer needed to save memory.  If the Source is reused again, a
     * new LocalLogger is created by CompilerAPI.preprocess().
     */
	private LocalLogger logger;

	private Map<String, Object> fragments;
	private Map<String, LineNumberMap> fragmentLineMaps;

	private AssetInfo assetInfo;

	public int lineCount;

    private int reuseCount = 0;
    private int totalDependentCount;

	public CompilationUnit newCompilationUnit(Object syntaxTree, CompilerContext context)
	{
		unit = new CompilationUnit(this, syntaxTree, context);
		unit.setStandardDefs(ThreadLocalToolkit.getStandardDefs());
		return unit;
	}

	public CompilationUnit getCompilationUnit()
	{
		return unit;
	}

	void removeCompilationUnit()
	{
        // CompilationUnit's created from SwcScript's can't be easily
        // recreated, so just remove the type information.  The
        // alternative is to factor out the CompilationUnit creation
        // from CompilerSwcContext.createSource() and modify
        // AbcCompiler.parse1() to call it when the CompilationUnit is
        // null.
        if (isSwcScriptOwner())
        {
            unit.removeTypeInfo();
        }
        else
        {
            unit = null;
        }

		fileTime = file.getLastModified();
		logger = null;
		isPreprocessed = false;

		fileIncludeTimes.clear();

		delegate = null;
		resolver = null;

		if (fragments != null)
		{
			fragments.clear();
			fragmentLineMaps.clear();
		}
	}

	public void setAssetInfo(AssetInfo assetInfo)
	{
		this.assetInfo = assetInfo;
	}

	void setPreprocessed()
	{
		isPreprocessed = true;
	}

	boolean isPreprocessed()
	{
		return isPreprocessed;
	}

	void setLogger(LocalLogger logger)
	{
        this.logger = logger;
	}

	public LocalLogger getLogger()
	{
		return logger;
	}

	public void disconnectLogger()
	{
		if (logger != null && logger.warningCount() == 0 && logger.errorCount() == 0)
		{
			logger = null;
		}
		else if (logger != null)
		{
			// if warning/error exists, keep the logger and just disconnect it from the original logger.
			logger.disconnect();
		}
	}

	boolean hasError()
	{
		return logger != null && logger.errorCount() > 0;
	}

	public Object getOwner()
	{
		return owner;
	}

	// C: do not make this public; only used by ResourceContainer.
	void setOwner(Object owner)
	{
		this.owner = owner;
	}

	public boolean isSourcePathOwner()
	{
		return owner != null && owner instanceof SourcePath && !isResourceBundlePathOwner();
	}

	public boolean isSourceListOwner()
	{
		return owner != null && owner instanceof SourceList;
	}

	public boolean isFileSpecOwner()
	{
		return owner != null && owner instanceof FileSpec;
	}

	public boolean isCompilerSwcContextOwner()
	{
		return owner != null && owner instanceof CompilerSwcContext;
	}

	public boolean isSwcScriptOwner()
	{
		return owner != null && owner instanceof SwcScript;
	}

	public boolean isResourceContainerOwner()
	{
		return owner != null && owner instanceof ResourceContainer;
	}

	public boolean isResourceBundlePathOwner()
	{
		return owner != null && owner instanceof ResourceBundlePath;
	}

	public boolean isInternal()
	{
		return isInternal;
	}

	public boolean isEntryPoint()
	{
		return isFileSpecOwner();
	}

	public boolean isRoot()
	{
		return isRoot;
	}

	public boolean isDebuggable()
	{
		return isDebuggable;
	}

	public boolean isCompiled()
	{
		return unit != null && unit.isBytecodeAvailable();
	}

	public boolean isUpdated()
	{
        long lastModified = file.getLastModified();

		if (lastModified != fileTime)
		{
			return true;
		}
		else
		{
			for (Entry<VirtualFile, Long> entry : fileIncludeTimes.entrySet())
			{
				if (entry.getKey().getLastModified() != entry.getValue().longValue())
				{
					return true;
				}
			}

			return false;
		}
	}

	boolean isUpdated(Source source)
	{
		boolean result = false;

		if (assetInfo != null)
		{
			if (assetInfo.getArgs().size() != source.assetInfo.getArgs().size())
			{
				result = true;
			}
			else
			{
				for (Iterator i = assetInfo.getArgs().entrySet().iterator(); i.hasNext() && !result;)
				{
					Entry entry = (Entry) i.next();
					String key = (String) entry.getKey();
					String value = (String) entry.getValue();

					if (!value.equals(Transcoder.COLUMN) &&
						!value.equals(Transcoder.LINE) &&
						!value.equals(source.assetInfo.getArgs().get(key)))
					{
						result = true;
					}
				}
			}
		}

		return result;
	}

	public boolean exists()
	{
		return file.getLastModified() > 0;
	}

	public String getName()
	{
		return file.getName();
	}

	public String getNameForReporting()
	{
		return file.getNameForReporting();
	}

	// C: This is temporary... only use it when you need to set asc Context.setPath
	public String getParent()
	{
		return file.getParent();
	}

	public long size()
	{
		return file.size();
	}

	public InputStream getInputStream() throws IOException
	{
		return file.getInputStream();
	}

	public byte[] toByteArray() throws IOException
	{
		return file.toByteArray();
	}

	public boolean isTextBased()
	{
		return file.isTextBased();
	}

	public String getInputText()
	{
		return file.toString();
	}

	public String getMimeType()
	{
		return file.getMimeType();
	}

	public long getLastModified()
	{
		return fileTime;
	}

	public VirtualFile resolve(String include)
	{
		return getPathResolver().resolve(include);
	}

	public PathResolver getPathResolver()
	{
		if (resolver == null)
		{
		resolver = new PathResolver();
		resolver.addSinglePathResolver(new Resolver(delegate != null ? delegate.getPathResolver() : null, file, pathRoot));
		resolver.addSinglePathResolver(ThreadLocalToolkit.getPathResolver());
        }

		return resolver;
	}

	static class Resolver implements SinglePathResolver
	{
		Resolver(PathResolver delegate, VirtualFile file, VirtualFile pathRoot)
		{
			this.delegate = delegate;
			this.file = file;
			this.pathRoot = pathRoot;
		}

		private PathResolver delegate;
		private VirtualFile file, pathRoot;

        public VirtualFile resolve(String relative)
        {
            VirtualFile f = null;

            if (relative != null)
            {
                // delegate.resolve() before this.resolve()
                if (delegate != null)
                {
                    f = delegate.resolve(relative);
                }
                else
                {
                    // A leading slash harks back to the Servlet days
                    // and meant look in the context root, so if we
                    // see a leading slash, we skip looking relative
                    // to the file.
                    if (!relative.startsWith("/"))
                    {
                        f = file.resolve(relative);
                    }

                    if ((f == null) && (pathRoot != null))
                    {
                        // See above note about about a leading slash.
                        // We used to blindly chop off the leading
                        // character and many existing apps are now
                        // dependent on the broken behavior.  See the
                        // performance testsuite for examples.
                        if (relative.startsWith("/") ||
                            (ThreadLocalToolkit.getCompatibilityVersion() < MxmlConfiguration.VERSION_4_5))
                        {
                            f = pathRoot.resolve(relative.substring(1));
                        }
                    }
                }
            }

            return f;
		}
	}

	public void setPathResolver(PathResolver pathResolver)
	{
		this.resolver = pathResolver;
	}

	public VirtualFile getBackingFile()
	{
		return (delegate == null)? file : delegate.getBackingFile();
	}

	public String getRelativePath()
	{
		// C: should be /-separated (no backslash)
		return relativePath;
	}

	public String getShortName()
	{
		return shortName;
	}

	public VirtualFile getPathRoot()
	{
		return pathRoot;
	}

	public void addFileIncludes(Source s)
	{
		fileIncludeTimes.putAll(s.fileIncludeTimes);
	}

	public boolean addFileInclude(String path)
	{
		VirtualFile f = resolve(path);

		return addFileInclude(f);
	}

	public boolean addFileInclude(VirtualFile f)
	{
		if (f != null)
		{
			if (!fileIncludeTimes.containsKey(f))
			{
				fileIncludeTimes.put(f, f.getLastModified());
			}

			if (delegate != null)
			{
				delegate.addFileInclude(f);
			}

			return true;
		}
		else
		{
			return false;
		}
	}

	public Iterator<VirtualFile> getFileIncludes()
	{
		return fileIncludeTimes.keySet().iterator();
	}

    /**
     * Returns a copy.
     */
    public Set<VirtualFile> getFileIncludesSet()
    {
        return new HashSet<VirtualFile>(fileIncludeTimes.keySet());
    }

    /**
     * Returns a copy.
     */
    public Map<VirtualFile, Long> getFileIncludeTimes()
    {
        return new HashMap<VirtualFile, Long>(fileIncludeTimes);
    }

	public boolean isIncludedFile(String name)
	{
		for (VirtualFile f : fileIncludeTimes.keySet())
		{
			if (f.getName().equals(name) || f.getNameForReporting().equals(name))
			{
				return true;
			}
		}

		return false;
	}

	public Iterator<VirtualFile> getUpdatedFileIncludes()
	{
		List<VirtualFile> updated = null;

		for (VirtualFile f : fileIncludeTimes.keySet())
		{
			long ts = fileIncludeTimes.get(f).longValue();
			if (f.getLastModified() != ts)
			{
				if (updated == null)
				{
					updated = new ArrayList<VirtualFile>(fileIncludeTimes.size());
				}
				updated.add(f);
			}
		}

		return updated == null ? null : updated.iterator();
	}

	public int getFileIncludeSize()
	{
		return fileIncludeTimes.size();
	}

	long getFileIncludeTime(VirtualFile f)
	{
		return fileIncludeTimes.get(f).longValue();
	}

	public long getFileTime()
	{
		return fileTime;
	}

    public void setFileTime(long fileTime)
    {
		this.fileTime = fileTime;
    }

	public void addSourceFragment(String n, Object f, LineNumberMap m)
	{
		if (fragments == null)
		{
			fragments = new HashMap<String, Object>();
			fragmentLineMaps = new HashMap<String, LineNumberMap>();
		}

		fragments.put(n, f);

        if (m != null)
        {
            fragmentLineMaps.put(n, m);
        }
    }

	public Object getSourceFragment(String n)
	{
		// this.fragment before delegate.fragment
		Object obj = (fragments == null) ? null : fragments.get(n);
		if (obj == null && delegate != null)
		{
			return delegate.getSourceFragment(n);
		}
		else
		{
			return obj;
		}
	}

	public Collection<LineNumberMap> getSourceFragmentLineMaps()
	{
		if (fragmentLineMaps != null)
		{
			return fragmentLineMaps.values();
		}
		else if (delegate != null)
		{
			return delegate.getSourceFragmentLineMaps();
		}
		else
		{
			return null;
		}
	}

	void clearSourceFragments()
	{
		fragments = null;
		fragmentLineMaps = null;

		if (delegate != null)
		{
			delegate.clearSourceFragments();
		}
	}

	/**
	 * Used by the web tier for dependency tracking.
	 *
	 * returns the last modified time of the source file itself
	 * without taking last modified time of any dependent files into account
	 *
	 * does not return a last modified time for in-memory files
	 */
	public long getRawLastModified()
	{
		if (isSwcScriptOwner())
		{
			return ((SwcScript) owner).getLibrary().getSwcCreationTime();
		}
		else if (isFileSpecOwner() || isSourceListOwner() || isSourcePathOwner())
		{
			return fileTime;
		}
		else // if (isResourceBundlePathOwner() || isResourceContainerOwner())
		{
			return -1;
		}
	}

	/**
	 * Used by the web tier for dependency tracking.
	 */
	public String getRawLocation()
	{
		if (isSwcScriptOwner())
		{
			return ((SwcScript) owner).getLibrary().getSwcLocation();
		}
		else
		{
			return getName();
		}
	}

    public int compareTo(Source source)
    {
        return getName().compareTo(source.getName());
    }

    public int hashCode()
    {
        return getName().hashCode();
    }

	public boolean equals(Object object)
	{
		if (object instanceof Source)
		{
			Source s = (Source) object;
			return s.owner == owner && s.getName().equals(getName()) && s.getRelativePath().equals(getRelativePath());
		}
		else
		{
			return false;
		}
	}

	public void close()
	{
		file.close();
	}

	/**
	 * Make a copy of this Source object.  Dependencies are multinames in the clone.
	 */
	public Source copy()
	{
		if (unit != null && unit.isDone())
		{
			// copying Source
			VirtualFile f = new InMemoryFile(unit.getByteCodes(), getName(), MimeMappings.ABC, fileTime);
			Source s = new Source(f, pathRoot, relativePath, shortName, owner, isInternal, isRoot, isDebuggable);

			s.fileIncludeTimes.putAll(fileIncludeTimes);
			s.logger = logger;

			// copying CompilationUnit
			CompilationUnit u = s.newCompilationUnit(null, new CompilerContext());

            copyCompilationUnit(unit, u, true);

			return s;
		}
		else
		{
			return null;
		}
	}

    /**
     * This method copies all the guts of one CompilationUnit into
     * another.  It was formerly called copyMetaData(), but it grew to
     * include more than just metadata, so it was renamed.
     */
	public static void copyCompilationUnit(CompilationUnit fromUnit, CompilationUnit toUnit,
                                           boolean useHistories)
	{
        toUnit.topLevelDefinitions.addAll(fromUnit.topLevelDefinitions);

        if (useHistories)
        {
            // For non-SwcScript based CompilationUnit's we want to
            // copy all the MultiName dependencies from the old
            // CompilationUnit's history into the new CompilationUnit,
            // so they can be resolved again.  This covers the case
            // where an ambiguity was introduced between incremental
            // compiles.
            toUnit.inheritance.addAll(fromUnit.inheritanceHistory.keySet());
            toUnit.types.addAll(fromUnit.typeHistory.keySet());
            toUnit.namespaces.addAll(fromUnit.namespaceHistory.keySet());
            toUnit.expressions.addAll(fromUnit.expressionHistory.keySet());
        }
        else
        {
            // CompilationUnit's from SwcScript's get there
            // dependencies from the catalog.xml file, so we copy them
            // directly to the new CompilationUnit.
            toUnit.inheritance.addAll(fromUnit.inheritance);
            toUnit.types.addAll(fromUnit.types);
            toUnit.namespaces.addAll(fromUnit.namespaces);
            toUnit.expressions.addAll(fromUnit.expressions);
        }

        toUnit.inheritanceHistory = fromUnit.inheritanceHistory;
        toUnit.typeHistory = fromUnit.typeHistory;
        toUnit.namespaceHistory = fromUnit.namespaceHistory;
        toUnit.expressionHistory = fromUnit.expressionHistory;

        toUnit.setSignatureChecksum(fromUnit.getSignatureChecksum());

        if (fromUnit.hasAssets())
        {
            toUnit.getAssets().addAll(fromUnit.getAssets());
        }

		toUnit.auxGenerateInfo = fromUnit.auxGenerateInfo;

        // These values are not type info dependent, so always copy them over.
        toUnit.icon = fromUnit.icon;
        toUnit.iconFile = fromUnit.iconFile;

		if (fromUnit.hasTypeInfo)
		{
			// There is no need to persist these properties because they exists as AS3 metadata in abc[], which
			// PersistenceStore always persists.
			toUnit.styles = fromUnit.styles;
			toUnit.typeInfo = fromUnit.typeInfo;
			toUnit.hasTypeInfo = true;
			toUnit.classTable.putAll(fromUnit.classTable);
			toUnit.swfMetaData = fromUnit.swfMetaData;
			toUnit.loaderClass = fromUnit.loaderClass;
			toUnit.loaderClassBase = fromUnit.loaderClassBase;
			toUnit.extraClasses.addAll(fromUnit.extraClasses);
			toUnit.addAccessibilityClasses(fromUnit);
			toUnit.licensedClassReqs.putAll(fromUnit.licensedClassReqs);
			toUnit.remoteClassAliases.putAll(fromUnit.remoteClassAliases);
            toUnit.effectTriggers.putAll(fromUnit.effectTriggers);
            toUnit.mixins.addAll(fromUnit.mixins);
            toUnit.resourceBundleHistory.addAll(fromUnit.resourceBundleHistory);
            toUnit.bytes = fromUnit.bytes;
		}
	}

	/**
	 * Creates a Source object, given a VirtualFile
	 */
	static Source newSource(VirtualFile f, long fileTime, VirtualFile pathRoot, String relativePath, String shortName, Object owner,
							boolean isInternal, boolean isRoot, boolean isDebuggable, Set<VirtualFile> includes, Map<VirtualFile, Long> includeTimes,
							LocalLogger logger)
	{
		Source s = new Source(f, pathRoot, relativePath, shortName, owner, isInternal, isRoot, isDebuggable);
		s.fileTime = fileTime;
		s.fileIncludeTimes.putAll(includeTimes);
		s.logger = logger;

		return s;
	}

	/**
	 * Creates a Source object, given an abc[]
	 */
	static Source newSource(byte[] abc, String name, long fileTime, VirtualFile pathRoot, String relativePath, String shortName, Object owner,
							boolean isInternal, boolean isRoot, boolean isDebuggable, Set<VirtualFile> includes, Map<VirtualFile, Long> includeTimes,
							LocalLogger logger)
	{
		VirtualFile f = new InMemoryFile(abc, name, MimeMappings.ABC, fileTime);
		return newSource(f, fileTime, pathRoot, relativePath, shortName, owner, isInternal, isRoot, isDebuggable,
		                 includes, includeTimes, logger);
	}

	/**
	 * Populates a Source object.
	 */
	static Source populateSource(Source s, long fileTime, VirtualFile pathRoot, String relativePath, String shortName, Object owner,
								 boolean isInternal, boolean isRoot, boolean isDebuggable, Set<VirtualFile> includes, Map<VirtualFile, Long> includeTimes,
								 LocalLogger logger)
	{
		assert s != null;

		s.fileTime = fileTime;
		s.pathRoot = pathRoot;
		s.relativePath = relativePath;
		s.shortName = shortName;
		s.owner = owner;
		s.isInternal = isInternal;
		s.isRoot = isRoot;
		s.isDebuggable = isDebuggable;
		s.fileIncludeTimes.putAll(includeTimes);
		s.logger = logger;

		return s;
	}

    public void reused()
    {
        reuseCount++;
    }

    public int getReuseCount()
    {
        return reuseCount;
    }

    public int getTotalDependentCount()
    {
        return totalDependentCount;
    }

    public void setTotalDependentCount(int totalDependentCount)
    {
        this.totalDependentCount = totalDependentCount;
    }

	public String toString()
	{
		return getName();
	}

	public static void transferDefinitions(CompilationUnit from, CompilationUnit to)
	{
		to.topLevelDefinitions.addAll(from.topLevelDefinitions);
	}

	public static void transferTypeInfo(CompilationUnit from, CompilationUnit to)
	{
		to.typeInfo = from.typeInfo;
	}

	public static void clearDependencies(CompilationUnit unit)
	{
		unit.inheritance.clear();
		unit.types.clear();
		unit.expressions.clear();
		unit.namespaces.clear();
		unit.importPackageStatements.clear();
		unit.importDefinitionStatements.clear();
	}

	public static void transferInheritance(CompilationUnit from, CompilationUnit to)
	{
		to.inheritance.clear();
		to.inheritance.addAll(from.inheritance);
		to.inheritanceHistory.putAll(from.inheritanceHistory);
	}

	public static void transferDependencies(CompilationUnit from, CompilationUnit to)
	{
		clearDependencies(to);

		to.inheritance.addAll(from.inheritance);
		to.types.addAll(from.types);
		to.expressions.addAll(from.expressions);
		to.namespaces.addAll(from.namespaces);
		to.importPackageStatements.addAll(from.importPackageStatements);
		to.importDefinitionStatements.addAll(from.importDefinitionStatements);

		to.inheritanceHistory.putAll(from.inheritanceHistory);
		to.typeHistory.putAll(from.typeHistory);
		to.expressionHistory.putAll(from.expressionHistory);
		to.namespaceHistory.putAll(from.namespaceHistory);
	}

	public static void transferNamespaces(CompilationUnit from, CompilationUnit to)
	{
		to.namespaces.clear();
		to.namespaces.addAll(from.namespaces);
		to.namespaceHistory.putAll(from.namespaceHistory);
	}

	public static void transferExpressions(CompilationUnit from, CompilationUnit to)
	{
		to.expressions.clear();
		to.expressions.addAll(from.expressions);
		to.expressionHistory.putAll(from.expressionHistory);
	}

	public static void transferAssets(CompilationUnit from, CompilationUnit to)
	{
        if (from.hasAssets())
        {
            to.getAssets().addAll(from.getAssets());
        }
	}

	public static void transferMetaData(CompilationUnit from, CompilationUnit to)
	{
		to.metadata.addAll(from.metadata);
		to.swfMetaData = from.swfMetaData;
		to.icon = from.icon;
		to.iconFile = from.iconFile;
		to.loaderClass = from.loaderClass;
		to.extraClasses.addAll( from.extraClasses );
		to.addAccessibilityClasses(from);
		to.licensedClassReqs.putAll( from.licensedClassReqs );
		to.remoteClassAliases.putAll(from.remoteClassAliases);
		to.effectTriggers.putAll(from.effectTriggers);
		to.mixins.addAll(from.mixins);
		to.resourceBundles.addAll(from.resourceBundles);
		to.resourceBundleHistory.addAll(from.resourceBundleHistory);
        to.setSignatureChecksum(from.getSignatureChecksum());
	}

	public static void transferGeneratedSources(CompilationUnit from, CompilationUnit to)
	{
		to.addGeneratedSources(from.getGeneratedSources());
		from.clearGeneratedSources();
	}

	public static void transferClassTable(CompilationUnit from, CompilationUnit to)
	{
		to.classTable.putAll(from.classTable);
	}

	public static  void transferLoaderClassBase(CompilationUnit from, CompilationUnit to)
	{
		to.loaderClassBase = from.loaderClassBase;
	}

	public static void transferBytecodes(CompilationUnit from, CompilationUnit to)
	{
		to.bytes.clear();
		to.bytes.set(from.bytes.toByteArray(false), from.bytes.size());
		to.getSource().lineCount = from.getSource().lineCount;
	}

	public static void transferStyles(CompilationUnit from, CompilationUnit to)
	{
		to.styles = from.styles;
	}
}
