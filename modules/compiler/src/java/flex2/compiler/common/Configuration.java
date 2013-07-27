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

package flex2.compiler.common;

import flash.localization.LocalizationManager;
import flex2.compiler.common.FramesConfiguration.FrameInfo;
import flex2.compiler.config.AdvancedConfigurationInfo;
import flex2.compiler.config.CommandLineConfigurator;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.linker.LinkerConfiguration;
import flex2.tools.LicensesConfiguration;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.LinkedList;
import java.util.Locale;
import java.util.HashSet;
import java.util.Set;
import java.util.Collection;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;
import java.io.File;

import flash.util.FileUtils;

import javax.xml.parsers.SAXParserFactory;
import javax.xml.parsers.SAXParser;

import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.ObjectList;

import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

/**
 * Tools like mxmlc and compc use configuration objects to store
 * configuration options parsed from config files and command-line options.
 *
 * The configuration object is produced by
 * flex2.tools.Mxmlc.processConfiguration().
 * This method can produce instances of various subclasses:
 *
 *   Configuration
 *     ToolsConfiguration
 *       ASDocConfiguration (for asdoc command-line tool)
 *       CommandLineConfiguration (for mxmlc command-line tool)
 *       CompcConfiguration (for compc command-line tool)
 *       ApplicationCompilerConfiguration (for OEM ApplicationCompiler)
 *       LibraryCompilerConfiguration (for OEM LibraryCompiler)
 *
 * There are also "sub-configuration" classes such as
 * CompilerConfiguration and MetadataConfiguration.
 * Instances of these classes store dotted/nested config options.
 * For example, the -compiler.library-path command line option
 * (corresponding to <compiler><library-path>...</libraryPath></compiler>
 * in an XML config file) is stored in CompilerConfiguration,
 * which is owned by Configuration.
 *
 * A configuration class does not have to extend Configuration
 * or implement any interface.
 * Instead, configuration objects get populated with configuration
 * information via reflection.
 * A configuration class declares that it support a particular
 * option such as -library-path / <library-path> simply by having
 * the public methods getLibraryPathInfo() and cfgLibraryPath().
 * (Note the change in spelling from library-path to LibraryPath.)
 *
 * A method like getLibraryPathInfo() returns a ConfigurationInfo object
 * which has metadata about the option, such as its description,
 * whether it can have a single value or multiple values, etc.
 *
 * After the ConfigurationBuffer has accumulated all ConfigurationValue
 * objects parsed from various source by "configurators"
 * such as DefaultsConfigurator, SystemPropertyConfiguration,
 * FileConfigurator, and CommandLineConfigurator, it pushes these
 * ConfigurationValues into the configuration objects that accept them
 * via methods like cfgLibraryPath().
 * The ConfigurationBuffer inspects the type of the second parameter
 * of this method and can pass, for example, a String array
 * in addition to the general ConfigurationValue.
 * 
 * Typically a cfgXXX() method will simply store the option value,
 * or some transformed version of it, in a private field such as
 * libraryPath.
 * A public method such as getLibraryPath() -- whose name doesn't
 * matter because it doesn't get called through reflection --
 * then exposes the option to the tool.
 * 
 * You can force one configuration option to be set before another,
 * and avoid race conditions, by using the
 * ConfigurationInfo.getSoftPrerequisites() method.
 *
 * @author Roger Gonzalez
 * @author Gordon Smith (notes below)
 */
public class Configuration implements LinkerConfiguration, Cloneable
{
    // ATTENTION:
    // Please specify default values inside DefaultsConfigurator.

    public Configuration()
    {
        this.compilerConfiguration = new CompilerConfiguration(this);
        frames = new FramesConfiguration();
        metadataConfiguration = new MetadataConfiguration();
        licensesConfiguration = new LicensesConfiguration();
        rslSettingsConfiguration = new RuntimeSharedLibrarySettingsConfiguration(this);
    }

    
    /**
     * 
     * @param compilerConfig - may not be null
     * @param configuration - may be null
     * @return excluded libraries summed from all configuration options
     */
    public static VirtualFile[] getAllExcludedLibraries(CompilerConfiguration compilerConfig,
    												Configuration configuration)
    {
    	return (VirtualFile[]) CompilerConfiguration.merge(
                                           compilerConfig.getExternalLibraryPath(),
                                           ((configuration == null) ? null
                                                                    : configuration.getRslExcludedLibraries()),
                                           VirtualFile.class);
    }
    
    
    /**
     * The path of a given file name based on the context of the
     * configuration value or the default output directory token.
     * 
     * @param cv
     * @param fileName
     * @return the full path of the file.
     */
    public static String getOutputPath(ConfigurationValue cv, String fileName)
    {
        String result = fileName;

        if (fileName != null) 
        {
        	File file = new File(fileName);
        	if (!FileUtils.isAbsolute(file))
        	{
	            String directory = cv.getBuffer().getToken(flex2.tools.oem.Configuration.DEFAULT_OUTPUT_DIRECTORY_TOKEN);
	
	            // if no default output directory, then use the configuration context.
	            if (directory == null)
	            {
	                directory = cv.getContext();
	            }
	
	            if (directory != null)
	            {
	                result = FileUtils.addPathComponents(directory, fileName, File.separatorChar);
	            }
        	}
        }

        return result;
    }
    
    
    protected ConfigurationPathResolver configResolver;

    public void setConfigPathResolver( ConfigurationPathResolver resolver )
    {
        this.configResolver = resolver;
        this.compilerConfiguration.setConfigPathResolver( resolver );
        this.rslSettingsConfiguration.setConfigPathResolver(resolver);
    }

	static private Map<String, String> aliases = null;
    
    static public Map<String, String> getAliases()
    {
        if (aliases == null)
        {
            aliases = new HashMap<String, String>();

            aliases.put( "l", "compiler.library-path" );
            aliases.put( "el", "compiler.external-library-path" );
            aliases.put( "sp", "compiler.source-path");
            aliases.put( "rsl", "runtime-shared-libraries");
            aliases.put( "keep", "compiler.keep-generated-actionscript");
	        aliases.put( "o", "output" );
	        aliases.put("rslp", "runtime-shared-library-path");
	        aliases.put("static-rsls", "static-link-runtime-shared-libraries");
            aliases.put("rsl-domain", "runtime-shared-library-settings.application-domain");
        }
        return aliases;
    }

 	/**
     * SWF width
     */
    
    private String width = null;
    private String widthPercent = null;
   
    public String width()
    {
        return width;
    }

    public String widthPercent()
    {
        return widthPercent;
    }

    public void setWidth( String width )
    {
        this.width = width;
    }

    public void setWidthPercent(String widthPercent)
    {
        this.widthPercent = widthPercent;
    }

    /**
     * SWF height
     */

    private String height = null;
    private String heightPercent = null;

    public String height()
    {
        return height;
    }

    public String heightPercent()
    {
        return heightPercent;
    }

    public void setHeight( String height )
    {
        this.height = height;
    }

    public void setHeightPercent(String heightPercent)
    {
        this.heightPercent = heightPercent;
    }
    
	/**
     * Page title
     */
    
    private String pageTitle = null;

    public String pageTitle()
    {
        return pageTitle;
    }

    public void setPageTitle(String title)
    {
        this.pageTitle = title;
    }

	/**
     * Root class name
     */
    
    private String rootClassName;

    public String getRootClassName()
    {
        return (rootClassName != null)? rootClassName : mainDefinition;
    }

    public void setRootClassName( String rootClassName )
    {
        this.rootClassName = rootClassName;
    }

	/**
     * Main definition
     */

    private String mainDefinition;

    public String getMainDefinition()
    {
        return mainDefinition;
    }

    public void setMainDefinition( String mainDefinition )
    {
        this.mainDefinition = mainDefinition;
    }

	/**
     * Resource bundles
     */

	private SortedSet<String> resourceBundles = new TreeSet<String>();

	// this list is just used for resourceBundleList.  See CU.resourceBundle for the
	// names of resource bundles that are linked in
	public SortedSet<String> getResourceBundles()
	{
		return resourceBundles;
	}
 
    /**
     * Unresolved
     */

    private Set<String> unresolved = new HashSet<String>();

	public Set<String> getUnresolved()
    {
        return unresolved;
    }


    //
    // 'framework' option
    //
    private static final String DEFAULT_FRAMEWORK = "halo";

    private String framework = DEFAULT_FRAMEWORK;

    public String getFramework()
    {
        return framework;
    }

    public void cfgFramework(ConfigurationValue cv, String s)
    {
        framework = s;
    }


    //
    // 'benchmark' option
    //
    
    private boolean benchmark = false;

    public boolean benchmark()
    {
        return benchmark;
    }

    public void cfgBenchmark(ConfigurationValue cv, boolean b)
    {
        benchmark = b;
    }

    public static ConfigurationInfo getBenchmarkInfo()
    {
        return new ConfigurationInfo() {

            public boolean doChecksum()
            {
                return false;
            }
            
        };
    }

    
    private int benchmarkCompilerDetails;  // 0 = none, 1 = light, 5 = verbose
    
    public int getBenchmarkCompilerDetails()
    {
        return benchmarkCompilerDetails;
    }
    
    /**
     * @param cv
     * @param b
     */
    public void cfgBenchmarkCompilerDetails(ConfigurationValue cv, int details)
    {
        benchmarkCompilerDetails = details;
    }
    
    
    public static ConfigurationInfo getBenchmarkCompilerDetailsInfo()
    {
        return new ConfigurationInfo() {

            public boolean isHidden()
            {
                return true;
            }

            public boolean doChecksum()
            {
                return false;
            }
            
        };
    }

    private long benchmarkTimeFilter;  // min time of units to log in ms
    
    public long getBenchmarkTimeFilter()
    {
        return benchmarkTimeFilter;
    }
    
    /**
     * @param cv
     * @param b
     */
    public void cfgBenchmarkTimeFilter(ConfigurationValue cv, long timeFilter)
    {
        benchmarkTimeFilter = timeFilter;
    }
    
    
    public static ConfigurationInfo getBenchmarkTimeFilterInfo()
    {
        return new ConfigurationInfo() {

            public boolean isHidden()
            {
                return true;
            }

            public boolean doChecksum()
            {
                return false;
            }
            
        };
    }


    //
    // 'compiler.*' options
    //
    
    private CompilerConfiguration compilerConfiguration;

    public CompilerConfiguration getCompilerConfiguration()
    {
        return compilerConfiguration;
    }

    public boolean debug()
    {
        return compilerConfiguration.debug();
    }

    public void setDebug(boolean debug)
    {
    	compilerConfiguration.setDebug(debug);
    }

    public boolean verboseStacktraces()
    {
        return compilerConfiguration.verboseStacktraces();
    }

    public boolean optimize()
    {
        return compilerConfiguration.optimize();
    }

    public void setOptimize(boolean optimize)
    {
    	compilerConfiguration.setOptimize(optimize);
    }

    /**
     * Includes user specified metadata and extra metadata added by the linker.
     */
    public String[] getMetadataToKeep()
    {
        return getCompilerConfiguration().getKeepAs3Metadata();
    }
    
    //
    // 'debug-password' option
    //
    
    private String debugPassword;

    /**
     * The password to include in debuggable swfs.
     */
    public String debugPassword()
    {
        return debugPassword;
    }
    
    public void setDebugPassword(String debugPassword)
    {
        this.debugPassword = debugPassword;
    }
    
    public void cfgDebugPassword( ConfigurationValue cv, String debugPassword )
    {
        this.debugPassword = debugPassword;
    }
    
    public static ConfigurationInfo getDebugPasswordInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'default-background-color' option
    //
    
    private int backgroundColor = 0x50727E;

    public int backgroundColor()
    {
        return this.backgroundColor;
    }

    public void setBackgroundColor( int backgroundColor )
    {
        this.backgroundColor = backgroundColor;
    }

    public void cfgDefaultBackgroundColor( ConfigurationValue cv, int backgroundColor )
    {
        this.backgroundColor = backgroundColor;
    }

    public static ConfigurationInfo getDefaultBackgroundColorInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'default-frame-rate' option
    //
    
    private int frameRate = 24;

    public int getFrameRate()
    {
        return frameRate;
    }
    
    public void setFrameRate( int rate )
    {
        frameRate = rate;
    }

    public void cfgDefaultFrameRate( ConfigurationValue cv, int rate )
        throws ConfigurationException
    {
        if (rate <= 0)
            throw new ConfigurationException.GreaterThanZero( cv.getVar(),
                                              cv.getSource(), cv.getLine() );
        frameRate = rate;
    }

    public static ConfigurationInfo getDefaultFrameRateInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'default-script-limits' option
    //
    
    private int scriptLimit = 60;
    private int scriptRecursionLimit = 1000;
    private boolean scriptLimitsSet = false;

    public int getScriptTimeLimit()
    {
        return scriptLimit;
    }

    public int getScriptRecursionLimit()
    {
        return scriptRecursionLimit;
    }

    public void setScriptTimeLimit( int scriptLimit )
    {
        scriptLimitsSet = true;
        this.scriptLimit = scriptLimit;
    }

    public void setScriptRecursionLimit( int recursionLimit )
    {
        scriptLimitsSet = true;
        this.scriptRecursionLimit = recursionLimit;
    }

    public boolean scriptLimitsSet()
    {
        return scriptLimitsSet;
    }

    public void cfgDefaultScriptLimits( ConfigurationValue cv, int maxRecursionDepth, int maxExecutionTime )
        throws ConfigurationException
    {
        if (maxRecursionDepth <= 0)
            throw new ConfigurationException.GreaterThanZero( cv.getVar(), cv.getSource(), cv.getLine() );

        if (maxExecutionTime <= 0)
            throw new ConfigurationException.GreaterThanZero( cv.getVar(),
                                              cv.getSource(), cv.getLine() );

        this.scriptLimitsSet = true;
        this.scriptLimit = maxExecutionTime;
        this.scriptRecursionLimit = maxRecursionDepth;
    }

    public static ConfigurationInfo getDefaultScriptLimitsInfo()
    {
        return new ConfigurationInfo( new String[] { "max-recursion-depth", "max-execution-time" } )
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };

    }

    //
    // 'default-size' option
    //
    
    private int defaultWidth = 500;
    private int defaultHeight = 375;

    public int defaultWidth()
    {
        return defaultWidth;
    }

    public int defaultHeight()
    {
        return defaultHeight;
    }

    public void cfgDefaultSize( ConfigurationValue cv, int width, int height )
        throws ConfigurationException
    {
        if ((width < 1) || (width > 4096) || (height < 1) || (height > 4096))    // whatever
        {
           throw new ConfigurationException.IllegalDimensions( width, height, cv.getVar(), cv.getSource(), cv.getLine() );
        }

        this.defaultWidth = width;
        this.defaultHeight = height;
    }

    public static ConfigurationInfo getDefaultSizeInfo()
    {
        return new ConfigurationInfo( new String[] {"width", "height"} )
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    //
    // 'externs' option
    //
    
    private Set<String> externs = new HashSet<String>();

    public Set<String> getExterns()
    {
        Collection<String> compilerExterns = compilerConfiguration.getExterns();

        if (compilerExterns != null)
        {
            externs.addAll(compilerExterns);
        }

        return externs;
    }

    public void addExterns( Collection<String> externs )
    {
        this.externs.addAll( externs );
    }
    
    public void addExterns(QName[] qNames)
    {
    	for (int i = 0, len = qNames == null ? 0 : qNames.length; i < len; i++)
    	{
    		this.externs.add(qNames[i].toString());
    	}
    }

	public void cfgExterns( ConfigurationValue cfgval, List<String> vals )
    {
		externs.addAll(toQNameString(vals));
    }

    public static ConfigurationInfo getExternsInfo()
    {
        return new ConfigurationInfo( -1, "symbol" )
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isAdvanced()
            {
                return true;
            }
            
            public boolean doChecksum()
            {
            	return false;
            }
        };
    }

    public void removeExterns(Collection<String> externs)
    {
        this.externs.removeAll(externs);
    }

    protected List<String> toQNameString(List<String> vals)
    {
    	for (int i = 0, size = vals == null ? 0 : vals.size(); i < size; i++)
    	{
            String name = vals.get(i);
            if ((name.indexOf( ':' ) == -1) && (name.indexOf( '.' ) != -1))
            {
                int dot = name.lastIndexOf( '.' );
                name = name.substring( 0, dot ) + ':' + name.substring( dot + 1 );
            }
            vals.set(i, name);
    	}
    	
    	return vals;
    }

    //
    // 'frames.*' options
    //
    
    private FramesConfiguration frames;

    public FramesConfiguration getFramesConfiguration()
    {
        return frames;
    }

    public List<FrameInfo> getFrameList()
    {
        return frames.getFrameList();
    }

    //
    // 'generated-frame-loader' option (hidden)
    //
    
    public boolean generateFrameLoader = true;
    
    public void cfgGenerateFrameLoader( ConfigurationValue cv, boolean value )
    {
        this.generateFrameLoader = value;
    }

    public static ConfigurationInfo getGenerateFrameLoaderInfo()
    {
        return new AdvancedConfigurationInfo()
        {
            public boolean isHidden()
            {
                return true;
            }
        };
    }

    //
    // 'generated-output' option
    //

    /*
    // TODO - enable this, add hooks to use it!
    private String generatedOutput = null;

    public String getGeneratedOutput()
    {
        return generatedOutput;
    }

    public void cfgGeneratedOutput( ConfigurationValue cfgVal, String path )
    {
        // We should probably resolve this here or in validate, but its kinda painful right now.
        generatedOutput = path;
    }

    public static ConfigurationInfo getGeneratedOutputInfo()
    {
        return new ConfigurationInfo( 1, "directory" )
        {
            public boolean isHidden()
			{
				return true;
			}

            public String[] getPrerequisites()
			{
				return new String[] { "flexlib" };
			}
        };
    }

    */
    
    //
    // 'includes' option
    //
    
	private Set<String> includes = new LinkedHashSet<String>();

	public Set<String> getIncludes()
	{
	    return includes;
	}

	public void addIncludes( Collection<String> includes )
	{
	    this.includes.addAll(includes);
	}

    public void cfgIncludes( ConfigurationValue cfgval, List<String> vals )
    {
    	includes.addAll(toQNameString(vals));
    }

    public static ConfigurationInfo getIncludesInfo()
    {
        return new ConfigurationInfo( -1, "symbol" )
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    //
    // 'lazy-init' option (hidden)
    //
    
    private boolean lazyInit = false;

    public boolean lazyInit()
    {
        return lazyInit;
    }

    public void cfgLazyInit(ConfigurationValue cv, boolean b)
    {
        lazyInit = b;
    }

    public static ConfigurationInfo getLazyInitInfo()
    {
        return new AdvancedConfigurationInfo()
        {
            public boolean isHidden()
            {
            	return true;
            }
        };
    }

    //
    // 'link-report' option
    //
    
    private String linkReportFileName = null;

    public String getLinkReportFileName()
    {
        return linkReportFileName;
    }
    
    public boolean generateLinkReport()
    {
    	return linkReportFileName != null;
    }

    public void cfgLinkReport( ConfigurationValue cv, String filename )
    {
       	this.linkReportFileName = getOutputPath(cv, filename);
    }
    
    public static ConfigurationInfo getLinkReportInfo()
    {
        return new ConfigurationInfo(new String[] {"filename"})
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };
    }
    
    //
    // 'size-report' option
    //
    
    private String sizeReportFileName = null;

    public String getSizeReportFileName()
    {
        return sizeReportFileName;
    }
    
    public boolean generateSizeReport()
    {
    	return sizeReportFileName != null;
    }

    public void cfgSizeReport( ConfigurationValue cv, String filename )
    {
       	this.sizeReportFileName = getOutputPath(cv, filename);
    }
    
    public static ConfigurationInfo getSizeReportInfo()
    {
        return new ConfigurationInfo(new String[] {"filename"})
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    //
    // 'load-externs' option
    //
    
    public void cfgLoadExterns( ConfigurationValue cfgval, String filename ) throws ConfigurationException
    {
        VirtualFile f = ConfigurationPathResolver.getVirtualFile( filename, configResolver, cfgval );

        SAXParserFactory factory = SAXParserFactory.newInstance();
        factory.setNamespaceAware(false);

        try
        {
            SAXParser parser = factory.newSAXParser();
            parser.parse(f.getInputStream(),
                         new DefaultHandler()
                         {
                             public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
                             {
                                 if ("def".equals( qName ) || "pre".equals( qName ) || "ext".equals( qName ))
                                 {
                                     String id = attributes.getValue( "id" );
                                     externs.add( id );
                                 }
                             }
                         });
        }
        catch (Exception e)
        {
            throw new ConfigurationException.ConfigurationIOError( filename, cfgval.getVar(), cfgval.getSource(), cfgval.getLine() );
        }
    }
    
    public static ConfigurationInfo getLoadExternsInfo()
    {
        return new ConfigurationInfo( 1, "filename" )
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    //
    // 'metadata.*' options
    //
    
    private MetadataConfiguration metadataConfiguration;

    public MetadataConfiguration getMetadataConfiguration()
    {
        return metadataConfiguration;
    }

    //
    // 'license.*' options.  These must be here rather than in 
    // ToolsConfiguration so they can be discovered when
    // introspection is done on Configuration.class to discover the options.
    //
    private LicensesConfiguration licensesConfiguration;
 
    public LicensesConfiguration getLicensesConfiguration()
    {
        return licensesConfiguration;
    }
    
    /**
     *  The RuntimeSharedLibraryPathItem Configuration contains
     *  options to modify runtime-shared-library-path options
     *  the user has already specified.
     */
    private RuntimeSharedLibrarySettingsConfiguration rslSettingsConfiguration;
    
    public RuntimeSharedLibrarySettingsConfiguration getRuntimeSharedLibrarySettingsConfiguration()
    {
        return rslSettingsConfiguration;
    }
    
    //
    // 'raw-metadata' option
    //
    
    private String metadata = null;

    public String getMetadata()
    {
        return (metadata == null)? getMetadataConfiguration().toString() : metadata;
    }

    public void cfgRawMetadata( ConfigurationValue cv, String xml )
            throws ConfigurationException
    {
        if (metadata != null)
        {
            throw new ConfigurationException.BadMetadataCombo( cv.getVar(), cv.getSource(), cv.getLine() );
        }

        this.metadata = xml;
    }

    public static ConfigurationInfo getRawMetadataInfo()
    {
        return new ConfigurationInfo( 1, "text" )
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    //
    // 'resource-bundle-list' option
    //
    
	private String rbListFileName = null;

	public String getRBListFileName()
	{
	    return rbListFileName;
	}
	
	public boolean generateRBList()
	{
		return rbListFileName != null;
	}

	public void cfgResourceBundleList( ConfigurationValue cv, String filename )
	{
	    this.rbListFileName = getOutputPath(cv, filename);
	}
    
	public static ConfigurationInfo getResourceBundleListInfo()
	{
	    return new ConfigurationInfo(new String[] {"filename"})
	    {
	        public boolean isAdvanced()
	        {
	            return true;
	        }
	    };
	}

    //
    // 'resource-shared-libraries' option
    //
    
    private List<String> rslList = new LinkedList<String>();
    
    public List<String> getRuntimeSharedLibraries()
    {
        return rslList;
    }
    
    public void cfgRuntimeSharedLibraries( ConfigurationValue cfgval, String[] urls ) throws ConfigurationException
    {
        for (int i = 0; i < urls.length; ++i)
        {
            // can't really validate these easily...
            rslList.add( urls[i] );
        }
    }

    public static ConfigurationInfo getRuntimeSharedLibrariesInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "url" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }

    //
    // 'use-network' option
    //
    
    private boolean useNetwork;

    public boolean useNetwork()
    {
        return useNetwork;
    }

    public void cfgUseNetwork( ConfigurationValue cv, boolean b)
    {
        this.useNetwork = b;
    }

    

	/**
	 * Capture the information in one argument specifing -runtime-shared-libraries-path
	 * information.
	 * 
	 * @author dloverin
	 * 
	 */
	public class RslPathInfo
	{
		/**
		 * The extension given to a signed RLS that is assumed to be signed.
		 * Unsigned RSLs should use the standard "swf" extension.
		 */
		public static final String SIGNED_RSL_URL_EXTENSION = "swz";
		public static final String SIGNED_RSL_URL_DOT_EXTENSION = "." + SIGNED_RSL_URL_EXTENSION;
		
		// path to swc to link against, this is logically added
		// -external-library-path option
		private String swcPath;
		private VirtualFile swcVf;	// the swc's virtual file		
		
		// rsls in the order to load. The first if the primary rsl, the
		// others are failover rsls.
		private List<String> rslUrls;

		// policy file urls, optional. The first in the list if applies to the
		// first rsl in _rslUrls. The second in the list applies to the second
		// in _rslUrls and so on. If there are more policy file urls than rsl
		// urls,
		// then display a warning.
		private List<String> policyFileUrls;

		//
		// List of type Boolean. Entry i in this list tells if entry i in the list
		// given by getRslUrls() is targeting a signed or unsigned rsl.
		//
		private List<Boolean> isSignedList;
		
		
		/**
		 * Create a new cross-domain RSL entry. The info specified the swc file to 
		 * exclude put a list of RSL urls and policy file urls. The first RSL url/policy
		 * file url pair are the primary urls. The remaining urls are failovers and are
		 * only used if the primary RSL fails to load.
		 *
		 */
		public RslPathInfo()
		{
			rslUrls = new ArrayList<String>();
		}

		/**
		 * Test is the url is signed.
		 * 
		 * @param url url to test, the file specified by the url does not 
		 * 			  need to exist.
		 * @return true if the url specifies a signed rsl, false otherwise.
		 */
		public boolean isRslUrlSigned(String url) {
			if (url == null) {
				return false;
			}
			
			return url.endsWith(SIGNED_RSL_URL_DOT_EXTENSION);
		}

		
		/**
		 * Set the path to the swc.
		 * 
		 * @param swcPath
		 */
		public void setSwcPath(String swcPath)
		{
			this.swcPath = swcPath;
		}

		/**
		 * 
		 * @return the path to the swc
		 */
		public String getSwcPath()
		{
			return swcPath;
		}

		/**
		 * Set the virtual file associated with the swc path.
		 * 
		 * @param vf
		 */
		public void setSwcVf(VirtualFile vf)
		{
			swcVf = vf;
		}
		
		
		/**
		 * 
		 * @return 
		 */
		public VirtualFile getSwcVirtualFile() {
			return swcVf;
		}
		
		
		/**
		 * Add an RSL to the list of RSLs.
		 * 
		 * @param url url of the RSL, may not be null
		 */
		public void addRslUrl(String url)
		{
			if (url == null) {
				throw new NullPointerException("url may not be null"); // $NON-NLS-1$
			}
			
			rslUrls.add(url);
			addSignedFlag(isRslUrlSigned(url));
		}

		/**
		 * 
		 * @return List of urls to RSLs. Each entry in the list is of type <code>String</code>.
		 */
		public List<String> getRslUrls()
		{
			return rslUrls;
		}

		
		/**
		 * Add a policy file to support the associated entry in the RSL URL list. Policy file
		 * entries my be empty, but must be specified.
		 * @param url url of the policy file.
		 */
		public void addPolicyFileUrl(String url)
		{
			if (policyFileUrls == null)
			{
				policyFileUrls = new ArrayList<String>();
			}

			policyFileUrls.add(url == null ? "" : url); // $NON-NLS-1$
		}

		/**
		 * Get the list of policy files.
		 * 
		 * @return Listof policy file urls. Each entry in the list of type <code>String</code>
		 */
		public List<String> getPolicyFileUrls()
		{
			return policyFileUrls == null ? Collections.<String>emptyList() : policyFileUrls;
		}
		
		
		/**
		 * Return a list of booleans that indicate if an RSL URL is signed or unsigned. There is a matching entry
		 * is this list for every entry in the RSL URL list.
		 * 
		 * @return List of boolean signed flags for the RSL URL list. Each entry in the list is 
		 * 		   of type <code>Boolean</code>.
		 */
		public List<Boolean> getSignedFlags() {
			return isSignedList;
		}
		
		/**
		 * Add a signed flag to the list of flags. This flag is determines if the RSL URL
		 * associated with this entry is considered signed or unsigned. 
		 * 
		 * @param isSigned true if the RSL URL is signed.
		 */
		private void addSignedFlag(boolean isSigned) {
			if (isSignedList == null) {
				isSignedList = new ArrayList<Boolean>();
			}
			
			isSignedList.add(Boolean.valueOf(isSigned));
		}

	}

	private List<RslPathInfo> rslPathInfoList; // list of CdRslInfo objects
    private Set<String> loadedRsls;            // swc location of the rsls that will be loaded
	
	/**
	 * @return List of of all the -runtime-shared-libraries-path options.
	 * 	 	Each-runtime-shared-libraries-path option supplied results in 
	 * 		a RslPathInfo object.
	 * 		Each object in the list is of type RslPathInfo. 
	 * 		The list will be empty if -static-link-runtime-shared-libraries=true.
	 */
	public List<RslPathInfo> getRslPathInfo() {
		return rslPathInfoList == null ? Collections.<RslPathInfo>emptyList() : rslPathInfoList;
	}

	public VirtualFile[] getRslExcludedLibraries() {
		
		if (rslPathInfoList == null || getStaticLinkRsl()) {
			return new VirtualFile[0];	
		}
		
		List<VirtualFile> libraries = new ArrayList<VirtualFile>();

		for (Iterator<RslPathInfo> iter = rslPathInfoList.iterator(); iter.hasNext();)
		{
			RslPathInfo info = iter.next();
			libraries.add(info.getSwcVirtualFile());
		}

		return libraries.toArray(new VirtualFile[0]);
	}

	public void cfgRuntimeSharedLibraryPath(ConfigurationValue cfgval,
			String[] urls) throws ConfigurationException
	{

		if (urls.length == 0) {
			return;	// ignore option
		}
		
		// Usage rule: if you use -rslp on the command line
		// it will take effect unless you also specify -static-rsls=true on the command line.
		if (CommandLineConfigurator.SOURCE_COMMAND_LINE.equals(cfgval.getSource())) {
			setOverrideStaticLinkRsl(false);			
		}
		
		// ignore rsl if told to
		if (getStaticLinkRsl()) {
			return;
		}
		
		if (urls.length < 2)
		{
			// insufficent arguments
			throw new ConfigurationException.MissingArgument("rsl-url",
					"runtime-shared-library-path", cfgval.getSource(), 
					cfgval.getLine());
		}

		RslPathInfo info = new RslPathInfo();

		// validate the first argument, the swc or open directory, required.
		VirtualFile include = ConfigurationPathResolver.getVirtualFile(urls[0],
																	configResolver,
																	cfgval );
		
		info.setSwcPath(urls[0]);
		info.setSwcVf(include);
		
		// the rest of the args are: rsl-url, policy-file-url, rsl-url, policy-file-url,... 
		for (int i = 1; i < urls.length; ++i)
		{
			if ((i + 1) % 2 == 0)
			{
				if (urls[i].length() == 0) {
					// rsl urls is required
					throw new ConfigurationException.MissingArgument("rsl-url",
							"runtime-shared-library-path", cfgval.getSource(), 
							cfgval.getLine());
				}
				info.addRslUrl(urls[i]);				
			}
			else {
				info.addPolicyFileUrl(urls[i]);				
			}
		}

		// if the last policy file was not specified, then add an empty one so
		// there are always the same number of rsls and policy files.
		if ((urls.length % 2) == 0) {
			info.addPolicyFileUrl("");	// $NON-NLS-1$
		}
		
		// take local variables and add to overall arguments.
		if (rslPathInfoList == null)
		{
			rslPathInfoList = new ArrayList<RslPathInfo>();
		}

		rslPathInfoList.add(info);
	}

	public static ConfigurationInfo getRuntimeSharedLibraryPathInfo()
	{
		return new ConfigurationInfo()
		{
			public boolean allowMultiple()
			{
				return true;
			}

			public String[] getSoftPrerequisites()
			{
				return new String[] {"static-link-runtime-shared-libraries"};
			}

			public String getArgName(int argnum)
			{
				String argName = null;
				
				if (argnum == 0) 
				{
					argName = "path-element";
				}
				else 
				{
					argnum = (argnum + 1) % 2;
					if (argnum == 0)
					{
						argName = "rsl-url";
					}
					else 
					{
						argName = "policy-file-url";
					}
				}
				return argName;
			}
			
			public boolean doChecksum()
			{
				return false;
			}
		};
	}

	//
	// 'static-link-runtime-shared-libraries' option
	// 
	
	private boolean staticLinkRsl = true;
	private String staticLinkRslSource;
	
	
	/**
	 * 
	 * @return true if -cd-rsl option should be used. False otherwise.
	 */
	public boolean getStaticLinkRsl()
	{
		return staticLinkRsl;
	}
	
	
	/**
	 * Allow another option, namely -rslp to override the value of
	 * static-rsls. But you can not override a -static-rsls option that came from the command line. 
	 * 
	 * @param staticLinkRsl
	 */
	protected void setOverrideStaticLinkRsl(boolean staticLinkRsl) 
	{
		if (CommandLineConfigurator.SOURCE_COMMAND_LINE.equals(staticLinkRslSource)) 
		{
			return;
		}
		
		this.staticLinkRsl = staticLinkRsl;
	}
	
	
	/**
	 * 
	 * @param cv
	 * @param b
	 */
	public void cfgStaticLinkRuntimeSharedLibraries(ConfigurationValue cv, boolean b)
	{
		staticLinkRsl = b;
		staticLinkRslSource = cv.getSource();
	}
	
	
	//
	// 'verify-digests' options
	// 
	
	private boolean verifyDigests = true;
	
	/**
	 * 
	 * @return true if digest information associated with the  
	 * 		  -cd-rsl option is used by the application at runtime. False otherwise.
	 */
	public boolean getVerifyDigests()
	{
		return verifyDigests;
	}
	
	/**
	 * 
	 * @param cv
	 * @param b
	 */
	public void cfgVerifyDigests(ConfigurationValue cv, boolean b)
	{
		verifyDigests = b;
	}
	
	
	public static ConfigurationInfo getVerifyDigestsInfo()
	{
		return new AdvancedConfigurationInfo();
	}
	
    //
    // 'remove-unused-rsls' option
    // 
    
    private boolean removeUnusedRSLs = true;
    
    /**
     * 
     * @return true if the user wants to remove unused RSLs. Otherwise false.
     */
    public boolean getRemoveUnusedRsls()
    {
        return removeUnusedRSLs;
    }
    
    /**
     * 
     * @param cv
     * @param b
     */
    public void cfgRemoveUnusedRsls(ConfigurationValue cv, boolean b)
    {
        removeUnusedRSLs = b;
    }
    
    
    public static ConfigurationInfo getRemoveUnusedRslsInfo()
    {
        return new AdvancedConfigurationInfo();
    }
    
    //
    // '-include-inheritance-dependencies-only' option
    // 
    
    private boolean includeInheritanceDependenciesOnly = false;
    
    /**
     * 
     * @return true if the user want to include inheritance dependencies only. 
     */
    public boolean getIncludeInheritanceDependenciesOnly()
    {
        return includeInheritanceDependenciesOnly;
    }
    
    /**
     * 
     * @param cv
     * @param b
     */
    public void cfgIncludeInheritanceDependenciesOnly(ConfigurationValue cv, boolean b)
    {
        includeInheritanceDependenciesOnly = b;
    }
    
    
    public static ConfigurationInfo getIncludeInheritanceDependenciesOnlyInfo()
    {
        return new AdvancedConfigurationInfo();
    }
    
	//
	// 'target-player' option
	// 
    
    /**
     * Returns the correct macromedia.asc.embedding.avmplus.Features.TARGET_AVM*
     * for the current target player.
     * 
     * @see macromedia.asc.util.ContextStatics.getTargetAVM()
     */
    public int getTargetPlayerTargetAVM()
    {
        return getTargetPlayerTargetAVM(getTargetPlayerMajorVersion());
    }
    
    /**
     * Returns the correct macromedia.asc.embedding.avmplus.Features.TARGET_AVM*
     * for the given target player major revision (e.g. 10).
     * 
     * @see macromedia.asc.util.ContextStatics.getTargetAVM()
     */
    public static int getTargetPlayerTargetAVM(int targetPlayerMajorVersion)
    {
        return ContextStatics.getTargetAVM(targetPlayerMajorVersion);
    }
    
    /**
     * Returns an ObjectList filled with the correct namespaces that need to be
     * automagically opened for the current target player, e.g. flash10.
     * 
     * @see macromedia.asc.util.ContextStatics.use_namespaces
     */
    public ObjectList<String> getTargetPlayerRequiredUseNamespaces()
    {
        return getTargetPlayerRequiredUseNamespaces(getTargetPlayerMajorVersion());
    }
    
    /**
     * Returns an ObjectList filled with the correct namespaces that need to be
     * automagically opened for the current target player, e.g. flash10.
     * 
     * @see macromedia.asc.util.ContextStatics.use_namespaces
     */
    public static ObjectList<String> getTargetPlayerRequiredUseNamespaces(int targetPlayerMajorVersion)
    {
        return ContextStatics.getRequiredUseNamespaces(targetPlayerMajorVersion);
    }
    
	// targeted player version (also set in DefaultsConfigurator)
	private int majorVersionTarget = 11;
	private int minorVersionTarget = 1;
	private int revisionTarget = 0;
	
	/**
	 * 
	 * @return The major version of the player targeted by this application.
	 * 		   The returned value will be greater to or equal to 9.  
	 */
	public int getTargetPlayerMajorVersion()
	{
		return majorVersionTarget;
	}
	
	/**
	 * 
	 * @return The minor version of the player targeted by this application.
	 * 		   The returned value will be greater to or equal to 0.  
	 */
	public int getTargetPlayerMinorVersion()
	{
		return minorVersionTarget;
	}
	
	/**
	 * 
	 * @return The revision of the player targeted by this application.
	 * 		   The returned value will be greater to or equal to 0.  
	 */
	public int getTargetPlayerRevision()
	{
		return revisionTarget;
	}
	
	/**
	 * 
	 * @param cv
	 * @param b
	 */
	public void cfgTargetPlayer(ConfigurationValue cv, String version)
        throws ConfigurationException
	{
		if (version == null)
		{
			return;
		}
		
		String[] results = version.split("\\.");
		
		if (results.length == 0)
		{
			throw new ConfigurationException.BadVersion(version, "target-player");

		}
		
		for (int i = 0; i < results.length; i++)
		{
			int versionNum = 0;
			
			try
			{
				versionNum = Integer.parseInt(results[i]);
			}
			catch (NumberFormatException e)
			{
				throw new ConfigurationException.BadVersion(version, "target-player");				
			}
			
			if (i == 0)
			{
				if (versionNum >= 9) 
				{
					this.majorVersionTarget = versionNum;
				}
				else 
				{
					throw new ConfigurationException.BadVersion(version, "target-player");
				}				
			}
			else 
			{
				if (versionNum >= 0) 
				{
					if (i == 1)
					{
						this.minorVersionTarget = versionNum;						
					}
					else
					{
						this.revisionTarget = versionNum;
					}
				}
				else 
				{
					throw new ConfigurationException.BadVersion(version, "target-player");
				}				
			}
		}
	}
	
	public static ConfigurationInfo getTargetPlayerInfo()
	{
		return new ConfigurationInfo(new String[] {"version"});
	}
	
	//
	// 'swf-version' option
	//
	
	private int swfVersion = 14;
	
	public int getSwfVersion()
	{
		assert swfVersion > 0;
		return swfVersion;
	}
	
	public void setSwfVersion(final int version)
	{
		assert version > 0;
		swfVersion = version;
	}
	
	public void cfgSwfVersion(ConfigurationValue cv, int version)
	{
		setSwfVersion(version);
	}
	
	public boolean getComputeDigest()
	{
		throw new InternalError("compute-digest");
	}
	
	//
	// 'use-direct-blit' option
	//

	private boolean useDirectBlit = false;
	
	public boolean getUseDirectBlit()
	{
		return useDirectBlit;
	}
	
	public void setUseDirectBlit(boolean value)
	{
		useDirectBlit = value;
	}
	
	public void cfgUseDirectBlit(ConfigurationValue cv, boolean value)
	{
		setUseDirectBlit(value);
	}
	
	//
	// 'use-gpu' option
	//
	
	private boolean useGpu = false;
	
	public boolean getUseGpu()
	{
		return useGpu;
	}
	
	public void setUseGpu(boolean value)
	{
		useGpu = value;
	}
	
	public void cfgUseGpu(ConfigurationValue cv, boolean value)
	{
		setUseGpu(value);
	}
	
	//
	// 'swc-checksum' options
	// 
	
	private boolean swcChecksumEnabled = true;
	
	/**
	 * 
	 * @return true if optimization using signature checksums are enabled.
	 */
	public boolean isSwcChecksumEnabled()
	{
		return swcChecksumEnabled;
	}
	
	/**
	 * 
	 * @param cv
	 * @param b
	 */
	public void cfgSwcChecksum(ConfigurationValue cv, boolean b)
	{
		swcChecksumEnabled = b;
	}
	
	public static ConfigurationInfo getSwcChecksumInfo()
	{
		return new ConfigurationInfo() {

			public boolean isHidden()
			{
				return true;
			}

			public boolean doChecksum()
			{
				return false;
			}
			
		};
	}

	// cssArchiveFiles and l10nArchiveFiles
	
	private Map<String, VirtualFile> cssArchiveFiles;
	private Map<String, VirtualFile> l10nArchiveFiles;
	
	public void addCSSArchiveFiles(Map<String, VirtualFile> m)
	{
		if (cssArchiveFiles == null)
		{
			cssArchiveFiles = new HashMap<String, VirtualFile>();
		}
		cssArchiveFiles.putAll(m);
	}
	
	public Map<String, VirtualFile> getCSSArchiveFiles()
	{
		return cssArchiveFiles;
	}
	
	public void addL10nArchiveFiles(Map<String, VirtualFile> m)
	{
		if (l10nArchiveFiles == null)
		{
			l10nArchiveFiles = new HashMap<String, VirtualFile>();
		}
		l10nArchiveFiles.putAll(m);
	}
	
	public Map<String, VirtualFile> getL10NArchiveFiles()
	{
		return l10nArchiveFiles;
	}


    /**
     * The compatibility version specified in the configuration.
     */
    public String getCompatibilityVersionString()
    {
        return compilerConfiguration.getCompatibilityVersionString();
    }

 	public int getCompatibilityVersion()
	{
		return compilerConfiguration.getCompatibilityVersion();
	}

    /**
     * The minimum supported library version specified in the configuration.
     */
    public String getMinimumSupportedVersionString()
    {
        return compilerConfiguration.getMinimumSupportedVersionString();
    }

    public int getMinimumSupportedVersion()
    {
        return compilerConfiguration.getMinimumSupportedVersion();
    }
    
    public boolean getQualifiedTypeSelectors()
    {
        return compilerConfiguration.getQualifiedTypeSelectors();
    }

    /**
     * Configures the LocalizationManager's locale, which is used when
     * reporting compile time errors, warnings, and info.
     *
     * @param toolsLocale A locale in Java format.  For example, "en" or "ja_JP".
     * @throws ConfigurationException When the specified toolsLocale is
     *         not available a ToolsLocaleNotAvailable error is reported.
     */
    public void cfgToolsLocale(ConfigurationValue cv, String toolsLocale)
        throws ConfigurationException
    {
        Locale[] locales = Locale.getAvailableLocales();

        for (int i = 0; i < locales.length; i++)
        {
            if (locales[i].toString().equals(toolsLocale))
            {
                LocalizationManager localizationManager = ThreadLocalToolkit.getLocalizationManager();

                if (localizationManager != null)
                {
                    localizationManager.setLocale(locales[i]);
                }
                else
                {
                    assert false : "LocalizationManager not setup yet.";
                }

                return;
            }
        }

        throw new ConfigurationException.ToolsLocaleNotAvailable(cv.getVar(),
                                                                 cv.getSource(),
                                                                 cv.getLine() );
    }
    
    public void setAdvancedTelemetry(boolean enableTelemetry)
    {
    	compilerConfiguration.setAdvancedTelemetry(enableTelemetry);
    }


 	public boolean getAdvancedTelemetry()
	{
		return compilerConfiguration.getAdvancedTelemetry();
	}

 	
 	@Override
 	public Configuration clone()
 	    throws CloneNotSupportedException
 	{
 	    Configuration cloneConfig = (Configuration) super.clone();
 	    CompilerConfiguration cloneCompilerConfiguration = (CompilerConfiguration) this.compilerConfiguration.clone();
 	    cloneConfig.compilerConfiguration = cloneCompilerConfiguration;
 	    return cloneConfig;
 	}
}
