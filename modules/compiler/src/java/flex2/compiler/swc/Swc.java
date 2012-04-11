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

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import flash.swf.Movie;
import flash.swf.MovieEncoder;
import flash.swf.TagEncoder;
import flash.swf.TagEncoderReporter;
import flash.swf.tools.SizeReport;
import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.CompilerAPI.UnableToWriteSizeReport;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.MxmlConfiguration;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.catalog.CatalogReader;
import flex2.compiler.swc.catalog.CatalogWriter;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.Name;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.linker.LinkerConfiguration;
import flex2.linker.LinkerException;
import flex2.linker.SimpleMovie;
import flex2.tools.PreLink;
import flex2.tools.VersionInfo;


/**
 * The representation of a SWC.  Contains the main entry points for
 * the compiler to use when getting information about a SWC.
 *
 * A Swc can be used by multiple threads at the same time so it should
 * not hold onto anything from a specific compile.  It also can be
 * dumped when its stale so it should not be stored (or pieces of it
 * stored, like the Catalog) from anywhere other than SwcGroup.
 *
 * Reading:
 *  - A SWC can exist in a partially decoded state.
 *  - When the SWC is fully read, it is FULLY READ AND CLOSED, and the
 *    backing file can be deleted.
 *  - The SWC should be able to discern if the in-memory snapshot is
 *    out of date.
 *
 * Writing:
 *  - The state of the SWC object after writing should be the same as
 *    if it had been fully read in.
 *
 * Updating:
 *  - The SWC should be entirely rewritten to a temporary location,
 *    then copied atomically to the new location.
 *
 * @author Brian Deitte
 * @author Roger Gonzalez
 */
public class Swc
{
    protected static boolean FNORD = false;      // change this when we ship, true = release, false = alpha

    public static String LIBRARY_SWF = "library.swf";
    public static String CATALOG_XML = "catalog.xml";
    
    public Swc( SwcArchive archive ) throws Exception
    {
        this( archive, false );
    }

    // not public on purpose- use SwcCache.getSwcGroup() instead
    Swc( SwcArchive archive, boolean load ) throws Exception
    {
        this.archive = archive;
        if (load)
        {
            read();
        }
    }

    long getLastModified()
    {
        return lastModified;
    }

    void setLastModified(long lastModified)
    {
        this.lastModified = lastModified;
    }

    /**
     * The location of the swc in the file system
     */
    public String getLocation()
    {
        return archive.getLocation();
    }

    public Iterator<SwcLibrary> getLibraryIterator()
    {
        return libraries.values().iterator();
    }

    public SwcLibrary buildLibrary( String libname, LinkerConfiguration linkerConfiguration, List<CompilationUnit> units )
    		throws IOException, LinkerException
    {
    	SwcMovie m = flex2.compiler.swc.SwcAPI.link(linkerConfiguration, units);
    	return buildLibrary(libname, linkerConfiguration, m);
    }

    /**
     * buildLibrary - Given a bunch of compile state, produce a SwcLibrary and all associated SwcScripts
     */
    public SwcLibrary buildLibrary( String libname, LinkerConfiguration linkerConfiguration, SwcMovie movie)
            throws IOException
    {
        int version = linkerConfiguration.getCompatibilityVersion();
        forceLibraryVersion1 = version < MxmlConfiguration.VERSION_3_0;
        versions.setMinimumVersion(linkerConfiguration.getMinimumSupportedVersionString());
        
        // get SWF bytes
        ByteArrayOutputStream swfOut = new ByteArrayOutputStream();
        TagEncoder encoder = linkerConfiguration.generateSizeReport() ? new TagEncoderReporter() : new TagEncoder();
        new MovieEncoder(encoder).export(movie, true); // always compress library.swf
        encoder.writeTo(swfOut);
        generateSizeReport(linkerConfiguration, movie, encoder);

        swfOut.flush();
        byte[] swf = swfOut.toByteArray();
        swfOut.close();

        String libPath = libname + ".swf";

        SwcLibrary lib = new SwcLibrary( this, libPath );
        VirtualFile swfFile = new InMemoryFile(swf, libPath,
                                               MimeMappings.getMimeType(libPath), new Date().getTime());
        archive.putFile( swfFile );
        libraries.put( libPath, lib );

        // check if we should compute the digest.
        if (linkerConfiguration.getComputeDigest())
        {
            // set digest info
            Digest digest = new Digest();
            digest.setSigned(false);
            digest.setType(Digest.SHA_256);
            digest.computeDigest(swf);
            
            lib.setDigest(digest);
        }
        
        // initialize metadata from configuration
        initMetadata(lib, linkerConfiguration);
        
        // If we linked without error, the unresolved list will contain nothing but valid externs.
        Set<String> externs = lib.getExterns();
        externs.addAll( linkerConfiguration.getUnresolved() );
        
        Set<SwcLibrary> librariesProcessed = new HashSet<SwcLibrary>();

        for (CompilationUnit unit : movie.getExportedUnits())
        {
            Source unitSource = unit.getSource();

            SwcDependencySet depset = new SwcDependencySet();
            addDeps( depset, SwcDependencySet.INHERITANCE, unit.inheritance );
            addDeps( depset, SwcDependencySet.SIGNATURE, unit.types );
            addDeps( depset, SwcDependencySet.NAMESPACE, unit.namespaces );
            addDeps( depset, SwcDependencySet.EXPRESSION, unit.expressions );

            addExtraClassesDeps( depset, unit.extraClasses );

            Set<String> scriptDefs = unit.topLevelDefinitions.getStringSet();
            checkDefs(scriptDefs, unitSource.getName());

            String sourceName = NameFormatter.nameFromSource(unitSource);
            SwcScript newScript = lib.addScript(sourceName, scriptDefs, depset,
                                                unitSource.getLastModified(),
                                                unit.getSignatureChecksum());
            newScript.setCompilationUnit(unit);
            addIcons(unit, sourceName);
            
            // find the source and add the metadata
            if (unitSource.isSwcScriptOwner() && !unitSource.isInternal() && 
                !PreLink.isCompilationUnitExternal(unit, externs))
            {
                SwcScript script = (SwcScript)unitSource.getOwner();
                SwcLibrary library = script.getLibrary();
                
                // lots of scripts, but not many swcs, so avoid added the same metadata
                // over and over.
                if (!librariesProcessed.contains(library))
                {
                    librariesProcessed.add(library);
                    lib.addMetadata(script.getLibrary().getMetadata());
                }
            }
        }
        return lib;
    }

    private static void generateSizeReport(LinkerConfiguration config, Movie movie, TagEncoder encoder)
    {
        if (config.generateSizeReport() && movie instanceof SimpleMovie && 
        		encoder instanceof TagEncoderReporter)
        {
            String report = ((TagEncoderReporter)encoder).getSizeReport();
            ((SimpleMovie)movie).setSizeReport(report);
            String fileName = config.getSizeReportFileName();
            
            if (fileName != null)
            {
	            try
	            {
	                FileUtil.writeFile(fileName, report);
	            }
	            catch (Exception ex)
	            {
	                ThreadLocalToolkit.log( new UnableToWriteSizeReport( fileName ) );
	            }
            }
        }
    }
    
    /**
     * init metadata from -keep-as3-metadata option
     * 
     * @param linkerConfiguration
     */
    private void initMetadata(SwcLibrary swcLibrary, LinkerConfiguration linkerConfiguration)
    {
    	String[] configMetaData = linkerConfiguration.getMetadataToKeep();
    	
    	if (configMetaData == null) 
    	{
    		return;
    	}
    	
    	if (configMetaData.length > 0)
    	{
    		swcLibrary.addMetadata(Arrays.asList(configMetaData));
    	}
    }
    
    /**
     * This method handles adding icons specified via [IconFile]
     * metadata to the SWC.  Icons are used by IDE's in component
     * toolbars.
     */
    private void addIcons(CompilationUnit unit, String sourceName)
            throws IOException
    {
        if (unit.icon != null)
        {
            // We used to resolve the icon here, but that was moved
            // upstream to SyntaxTreeEvaluator.processIconFileMetaData(),
            // so we don't have to hang on to the PathResolver until now.
            VirtualFile iconFile = unit.iconFile;
            Source source = unit.getSource();

            // If the source came from a SWC, try looking for the icon in the SWC.
            if ((iconFile == null) && source.isSwcScriptOwner())
            {
                for (int i = 0, s = unit.topLevelDefinitions.size();i < s; i++)
                {
                    String def = unit.topLevelDefinitions.get(i).toString();
                    if (components.containsKey(def))
                    {
                        String swcIcon = components.get(def).getIcon();
                        if (swcIcon != null)
                        {
                            iconFile = (((SwcScript) source.getOwner()).getLibrary().getSwc().getFile(swcIcon));
                            if (iconFile != null)
                            {
                                // we then put the resolved file into an InMemoryFile so that we can changed its name
                                VirtualFile inMemFile = new InMemoryFile(iconFile.getInputStream(), swcIcon,
                                                                         MimeMappings.getMimeType(swcIcon),
                                                                         iconFile.getLastModified());
                                archive.putFile( inMemFile );
                                return;
                            }
                        }
                    }
                }

                // It seems like this will never be true, because if
                // the icon was missing when the original SWC was
                // created, a MissingIconFile would have been thrown.
                if (iconFile == null)
                {
                    return;
                }
            }

            if (iconFile == null)
            {
                throw new SwcException.MissingIconFile(unit.icon, sourceName);
            }

            // yes using both toDot and toColon here feels very wacky
            String workingSourceName = NameFormatter.toColon(NameFormatter.toDot(sourceName, '/'));
            SwcComponent comp = components.get(workingSourceName);
            String rel = source.getRelativePath();
            String iconName = (rel == null || rel.length() == 0) ? unit.icon : rel + "/" + unit.icon;
            if (comp != null)
            {
                comp.setIcon(iconName);
            }

            // we then put the resolved file into an InMemoryFile so that we can changed its name
            VirtualFile inMemFile = new InMemoryFile(iconFile.getInputStream(), iconName,
                                                     MimeMappings.getMimeType(iconName), 
                                                     iconFile.getLastModified());
            archive.putFile( inMemFile );
        }
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void checkDefs(Set<String> scriptDefs, String sourceName)
    {
        for (Iterator<String> iter2 = scriptDefs.iterator(); iter2.hasNext();)
        {
            String str = iter2.next();
            String script = defs.get(str);
            if (script != null)
            {
                throw new SwcException.DuplicateDefinition(str, script, sourceName);
            }
            defs.put(str, sourceName);
        }
    }

    private static void addDeps( SwcDependencySet depset, String type, Set<Name> nameSet )
    {
        for (Name name : nameSet)
        {
            if (name instanceof MultiName)
            {
                MultiName mname = (MultiName) name;
                if (mname.getNumQNames() == 1)
                {
                    depset.addDependency( type, mname.getQName( 0 ).toString() );
                }
            }
            else
            {
                assert name instanceof QName;
                depset.addDependency( type, name.toString() );
            }
        }
    }

    private static void addExtraClassesDeps( SwcDependencySet depset, Set extraClasses )
    {
        for (Iterator it = extraClasses.iterator(); it.hasNext();)
        {
            String extraClass = (String) it.next();
            depset.addDependency(SwcDependencySet.EXPRESSION, extraClass);
        }
    }

    // not public on purpose- use SwcCache.export() instead
    synchronized boolean save() throws Exception
    {
        ByteArrayOutputStream byteOut = new ByteArrayOutputStream();
	    Writer out = new OutputStreamWriter(byteOut, "UTF-8");

	    // TODO - move feature setting out somewhere
	    if (components.size() > 0)
		    swcFeatures.setComponents( true );
	    if (archive.getFiles().size() > 0)
		    swcFeatures.setFiles( true );

		/*System.out.println("catalog save: VersionInfo.getLibVersion() = " + VersionInfo.getLibVersion() +
				", VersionInfo.getFlexVersion() = " + VersionInfo.getFlexVersion() +
				", VersionInfo.getBuildAsLong() = " + VersionInfo.getBuildAsLong());*/

	    // get the version we will save the swc libraries as.
	    String currentVersion = determineSwcLibraryVersion();
	    
		versions.setLibVersion(currentVersion);
	    versions.setFlexVersion(VersionInfo.getFlexVersion());
	    versions.setFlexBuild(VersionInfo.getBuild());

	    for (Iterator<SwcLibrary> it = libraries.values().iterator(); it.hasNext();)
	    {
		    SwcLibrary l = it.next();
		    if (l.getExterns().size() > 0)
		    {
			    swcFeatures.setExternalDeps( true );
			    break;
		    }
	    }
	   
	    CatalogWriter writer = new CatalogWriter(out, versions, swcFeatures, 
	    										components.values(), 
	    										libraries.values(),
	                                            archive.getFiles().entrySet());
	    writer.write();
	    out.close();
	    archive.putFile( CATALOG_XML, byteOut.toByteArray(), new Date().getTime() );
	    archive.save();

	    return ThreadLocalToolkit.errorCount() == 0;
    }

    /**
     * Get the version this swc should be saved as.
     *
     */
    private String determineSwcLibraryVersion() {
        
        // the flex library version was 1.0 in Flex 2.0.1 sdk.
        if (forceLibraryVersion1)
        {
            return VersionInfo.LIB_VERSION_1_0; 
        }
        
        return VersionInfo.LIB_VERSION_1_2;            
    }
    
    public Map<String, VirtualFile> getCatalogFiles()
    {
        return archive.getFiles();
    }

    public VirtualFile getFile(String path)
    {
        return archive.getFile(path);
    }

    public void addFile( VirtualFile file )
    {
        archive.putFile( file );
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void read() throws Exception
    {
        VirtualFile catalogFile = null;
	    InputStream stream = null;

	    try
	    {
		    catalogFile = archive.getFile( CATALOG_XML );

		    if (catalogFile == null)
		    {
			    throw new SwcException.CatalogNotFound();
		    }
		    stream = catalogFile.getInputStream();
		    CatalogReader reader = new CatalogReader(new BufferedInputStream(stream), this, archive);
		    reader.read();

		    versions = reader.getVersions();
		    swcFeatures = reader.getFeatures();
		    components = reader.getComponents();
		    libraries = reader.getLibraries();

			/**
			 * version checking:
			 * - a failure results in a warning, not an error
			 * - we do an across-the-board check for SWC major lib version <= compiler major lib version
			 * - all other checks are ad-hoc and will accumulate as we rev lib version
			 * - see VersionInfo for more version info
			 */
		    // double swcLibVersion = versions.getLibVersion();
		    // double compilerLibVersion = VersionInfo.getLibVersion();

			//	System.out.println("read(): swcLibVersion=" + swcLibVersion + ", compilerLibVersion=" + compilerLibVersion);

			//	Warn if the SWC was built with a newer compiler
			// if (Math.floor(swcLibVersion) > Math.floor(compilerLibVersion))
		    if (versions.getLibVersion() != null && VersionInfo.IsNewerLibVersion(versions.getLibVersion(), true))
		    {
			    OldVersion oldVersion = new OldVersion(archive.getLocation(), versions.getLibVersion(),
						VersionInfo.getLibVersion());
			    ThreadLocalToolkit.log(oldVersion);
		    }

			/**
			 * Other major-version-specific range tests would go here
			 */
		}
	    finally
	    {
		    if (stream != null)
		    {
			    try
                {
				    stream.close();
			    }
			    catch (IOException ioe)
                {
				    // ignore
			    }
		    }

            if (catalogFile != null)
            {
                // Null out any cached bytes, because we won't need them again.
                catalogFile.close();
	    }
    }
    }

	public void close()
	{
		archive.close();
	}

    public Iterator<SwcComponent> getComponentIterator()
    {
        return components.values().iterator();
    }
    
    public SwcComponent getComponent(String className)
    {
    	return components.get(className);
    }

	public Versions getVersions()
	{
	    return versions;
	}

    public SwcFeatures getFeatures()
    {
        return swcFeatures;
    }

 
    /**
     * Get the digest of a specified library, using the default hash type.
     * 
     * @param libPath
     * 			name of library path. If in doubt pass in LIBRARY_PATH.
     * @param isSigned
     * 			if true return a signed digest, if false return an unsigned digest.
     * 
     * @return the digest of the specified library. May be null if not digest is found.
     */
    public Digest getDigest(String libPath, boolean isSigned)
    {
    	return getDigest(libPath, Digest.SHA_256, isSigned);
    }
    
    
    /**
     * Get the digest of a specified library.
     * 
     * @param libPath
     * 			name of library path. If in doubt pass in LIBRARY_PATH.
     * @param hashType
     * 			type of hash. Only valid choice is Digest.SHA_256.
     * @param isSigned
     * 			if true return a signed digest, if false return an unsigned digest.
     * 
     * @return the digest of the specified library. May be null if not digest is found.
     */
    public Digest getDigest(String libPath, String hashType, boolean isSigned)
    {
    	if (libPath == null)
    	{
    		throw new NullPointerException("libPath may not be null");
    	}
    	
    	if (hashType == null)
    	{
    		throw new NullPointerException("hashType may not be null");
    	}
    	
        SwcLibrary lib = libraries.get(Swc.LIBRARY_SWF);
        if (lib != null)
        {
            return lib.getDigest(hashType, isSigned);
        }
        
        return null;
    }
    
    
    /**
     * Add a new digest to the swc or replace the existing digest if a
     * digest for libPath already exists.
     * 
     * @param libPath name of the library file, may not be null
     * @param digest digest of libPath
     * @throws NullPointerException if libPath or digest are null.
     */
    public void setDigest(String libPath, Digest digest)
    {
    	if (libPath == null)
    	{
    		throw new NullPointerException("setDigest: libPath may not be null"); // $NON-NLS-1$
    	}
    	if (digest == null)
    	{
    		throw new NullPointerException("setDigest:  digest may not be null");  // $NON-NLS-1$
    	}

    	SwcLibrary lib = libraries.get(Swc.LIBRARY_SWF);
        if (lib != null)
        {
            lib.setDigest(digest);
        }
    }
    
    
    public void addComponent(SwcComponent c)
    {
        components.put( c.getClassName(), c );
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    SwcArchive getArchive()
    {
        return archive;
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected final SwcArchive archive;
    private long lastModified = -1;

    /** Each object in the Map is of type SwcLibrary.
     *  The object is hashed into the Map with the path of the library.
     */
    // changed next 5 from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected Map<String, SwcLibrary> libraries = new HashMap<String, SwcLibrary>();
    protected Map<String, SwcComponent> components = new TreeMap<String, SwcComponent>();
	protected Versions versions = new Versions();
    protected SwcFeatures swcFeatures = new SwcFeatures();
    private Map<String, String> defs = new HashMap<String, String>();
    private boolean forceLibraryVersion1;       // if true for swc to library version 1.0
    
    
	public static class OldVersion extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = 6737124293703916205L;
        public OldVersion(String swc, String swcVer, String compilerVer)
		{
			this.swc = swc;
			this.swcVer = swcVer;
			this.compilerVer = compilerVer;
		}
		public String swc;
		public String swcVer;
		public String compilerVer;
	}
}
