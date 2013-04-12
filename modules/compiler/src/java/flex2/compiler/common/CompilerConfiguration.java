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

import flash.util.FileUtils;
import flash.util.StringUtils;
import flex2.compiler.config.ServicesDependenciesWrapper;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.as3.As3Configuration;
import flex2.compiler.config.AdvancedConfigurationInfo;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.extensions.ExtensionsConfiguration;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.tools.CompcConfiguration;
import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.util.ObjectList;

import java.io.File;
import java.io.InputStream;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

/**
 * This class defines the compiler related configuration options.  All
 * of these options have an optional prefix of "compiler", as long as
 * the option can be resolved unambiguously.  For example,
 * "-compiler.debug", can be abbreviated to "-debug".
 *
 * @author Roger Gonzalez
 */
public class CompilerConfiguration implements As3Configuration,
                                              flex2.compiler.mxml.MxmlConfiguration, Cloneable
{
	// ATTENTION: Please set default values in DefaultsConfigurator.

	public static final String LOCALE_TOKEN = "{locale}";
    public static final String TARGET_PLAYER_MAJOR_VERSION_TOKEN = "{targetPlayerMajorVersion}";
    public static final String TARGET_PLAYER_MINOR_VERSION_TOKEN = "{targetPlayerMinorVersion}";
 
    // Special Case for Apache.  These are not currently exposed with command line options.
    public static final String PLAYERGLOBAL_HOME_TOKEN = "{playerglobalHome}";
    public static final String AIR_HOME_TOKEN = "{airHome}";
    
    // this is passed as the list of soft prerequisites for options like
    // library-path, source-path which need to have {locale}, etc., set already
    private static final String[] PATH_TOKENS = {
        "locale", // compiler.locale
        // Jono: "target-player" -- target-player is one level 'above' compiler.*
        // which, I hope, means that it's guaranteed to be committed already
    };
    
    public static final String STRICT = "compiler.strict";
	public static final String AS3 = "compiler.as3";
	public static final String ES = "compiler.es";
    
    private final Configuration parentConfiguration;

	public CompilerConfiguration(Configuration parentConfiguration)
	{
        assert parentConfiguration != null;
        this.parentConfiguration = parentConfiguration;
        
		namespaces = new NamespacesConfiguration();
        fontsConfig = new FontsConfiguration();
		fontsConfig.setCompilerConfiguration(this);
		mxmlConfig = new MxmlConfiguration();
		extensionsConfig = new ExtensionsConfiguration();
	}

    /**
     * Generate SWFs for debugging.
     */
    private ConfigurationPathResolver configResolver;

    public void setConfigPathResolver( ConfigurationPathResolver resolver )
    {
        this.configResolver = resolver;
        this.fontsConfig.setConfigPathResolver(configResolver);
        this.namespaces.setConfigPathResolver(configResolver);
        this.mxmlConfig.setConfigPathResolver(configResolver);
        this.extensionsConfig.setConfigPathResolver(configResolver);
    }

    /**
     * Fast utility method to merge arrays.
     */
    public static <T> Object[] merge( Object[] a, Object[] b, Class<T> klass)
    {
        if(a == null) return b;
        if(b == null) return a;

        Object[] arrrrray = (Object[]) Array.newInstance(klass, (a.length + b.length));
        System.arraycopy(a, 0, arrrrray, 0, a.length);
        System.arraycopy(b, 0, arrrrray, a.length, b.length);

        return arrrrray;
    }
    
    /**
     * All path-tokens get expanded from this method, e.g. {locale} and {targetPlayerMajorVersion}
     */
    public VirtualFile[] expandTokens(String[] pathlist, String[] locales, ConfigurationValue cv)
        throws ConfigurationException
    {
        // {playerglobalHome} and {airHome}
        pathlist = expandRuntimeTokens(pathlist);
        
        // {targetPlayerMajorVersion}, {targetPlayerMinorVersion}
        pathlist = expandTargetPlayerToken(pathlist, parentConfiguration);
        
        // {locale}
        return expandLocaleToken(pathlist, locales, cv);
    }

    /**
     * Replaces instances of {targetPlayerMajorVersion} and {targetPlayerMinorVersion} 
     * with configuration. Doesn't turn the paths into VirtualFiles (yet, 
     * @see expandLocaleToken()). 
     */
    private static String[] expandTargetPlayerToken(String[] pathlist, Configuration configuration)
    {
        final String[] processed = new String[pathlist.length];
        
        final String targetPlayerMajorVersion
            = String.valueOf(configuration.getTargetPlayerMajorVersion());
        
        final String targetPlayerMinorVersion
            = String.valueOf(configuration.getTargetPlayerMinorVersion());
        
        for (int i = 0; i < pathlist.length; i++)
        {
            processed[i] = StringUtils.substitute(pathlist[i], 
                TARGET_PLAYER_MAJOR_VERSION_TOKEN, targetPlayerMajorVersion);
            processed[i] = StringUtils.substitute(processed[i], 
            	TARGET_PLAYER_MINOR_VERSION_TOKEN, targetPlayerMinorVersion);
        }

        return processed;
    }
      
    /**
     * Load the env.properties file from the classpath.
     
     * @return null if env.properties does not exist in classpath or could not be loaded
     */
    private Properties loadEnvPropertyFile()
    {
        Properties properties = null;
        InputStream in = null;
         
        try 
        {
            in = getClass().getClassLoader().getResourceAsStream("env.properties");
            if (in == null)
               return null;
            
            properties = new Properties();
            properties.load(in);
            in.close();
        } 
        catch (Exception e) 
        {
        }
        
        return properties;
    }

    /**
     * Replaces instances of {playerglobalHome} and {airHome}.
     * Values can come from either ../env.properties (relative to jar file) or
     * environment variables. The property file values have precedence.
     * The pairs are env.PLAYERGLOBAL_HOME and PLAYERGLOBAL_HOME, and,
     * env.AIR_HOME and AIR_HOME.
     */
    private String[] expandRuntimeTokens(String[] pathlist)
    {
        final String[] processed = new String[pathlist.length];
           
        // Look at property file first, if it exists, and see if the particular property
        // is defined.  If not found, then look for the environment variable.
        // If there is neither leave the token in place since it is easier to
        // diagnose the problem with a token in the error message path then it is with
        // a "" in the path.
        Properties envProperties = loadEnvPropertyFile();
        
        String playerglobalHome = envProperties != null ?
            envProperties.getProperty("env.PLAYERGLOBAL_HOME", System.getenv("PLAYERGLOBAL_HOME")) :
            System.getenv("PLAYERGLOBAL_HOME");
        
        if (playerglobalHome == null)
            playerglobalHome = PLAYERGLOBAL_HOME_TOKEN;
            
        String airHome = envProperties != null ?
            envProperties.getProperty("env.AIR_HOME", System.getenv("AIR_HOME")) :
            System.getenv("AIR_HOME");

        if (airHome == null)
            airHome = AIR_HOME_TOKEN;
            
        for (int i = 0; i < pathlist.length; i++)
        {
            processed[i] = StringUtils.substitute(pathlist[i], 
                PLAYERGLOBAL_HOME_TOKEN, playerglobalHome);
            processed[i] = StringUtils.substitute(processed[i], 
                AIR_HOME_TOKEN, airHome);
        }
        
        return processed;
    }

	/**
	 * Expands the {locale} token in a list of path elements
	 * for the source-path or library-path,
	 * and converts each path element from a String
	 * to a VirtualFile.
	 *
	 * The treatment of a path element containing "{locale}"
	 * depends on whether we are processing a source-path
	 * or a library-path, and on whether we are compiling for
	 * a single locale, multiple locales, or no locale:
	 *
	 * -source-path=foo,bar/{locale},baz -locale=en_US
	 *   -> foo,bar/en_US,baz
	 * -source-path=foo,bar/{locale},baz -locale=en_US,ja_JP
	 *   -> foo,bar/en_US,bar/ja_JP,baz
	 * -source-path=foo,bar/{locale},baz -locale=
	 *   -> foo,baz
	 * -library-path=foo,bar/{locale},baz -locale=en_US
	 *   -> foo,bar/en_US,baz
	 * -library-path=foo,bar/{locale},baz -locale=en_US,ja_JP
	 *   -> foo,bar/en_US,bar/ja_JP,baz
	 * -library-path=foo,bar/{locale},baz -locale=
	 *   -> foo,baz
	 */
	private VirtualFile[] expandLocaleToken(String[] pathlist, String[] locales, ConfigurationValue cv)
		throws ConfigurationException
	{
		ArrayList<VirtualFile> list = new ArrayList<VirtualFile>(pathlist.length);

		// Process each path element.
		for (int i = 0; i < pathlist.length; i++)
		{
			String pathElement = pathlist[i];

			// Look for "{locale}".
			int localeTokenIndex = pathElement.indexOf(LOCALE_TOKEN);
			if (localeTokenIndex != -1)
			{
				// Expand this {locale}-containing path element
				// into 0, 1, or N path elements.
				for (int j = 0; j < locales.length; j++)
				{
					String pathElementWithSubstitution = StringUtils.substitute(pathElement, LOCALE_TOKEN, locales[j]);
					addPathElementToListAsVirtualFile(pathElementWithSubstitution, list, cv);
				}
			}
			else
			{
				addPathElementToListAsVirtualFile(pathElement, list, cv);
			}
		}

		VirtualFile[] vfa = new VirtualFile[list.size()];
		list.toArray(vfa);
		return vfa;
	}

	/**
	 * Helper method for getLocaleFileList().
	 */
	private void addPathElementToListAsVirtualFile(String pathElement, ArrayList<VirtualFile> list, ConfigurationValue cv)
		throws ConfigurationException
	{
		try
		{
			VirtualFile vf = getVirtualFile(pathElement, cv);
			list.add(vf);
		}
		catch(ConfigurationException e)
		{
			if (cv == null)
			{
				throw new ConfigurationException.CannotOpen(
						pathElement, null, null, -1);
			}
			else
			{
				throw new ConfigurationException.CannotOpen(
						pathElement, cv.getVar(), cv.getSource(), cv.getLine());
			}
		}
	}

    private VirtualFile[] toVirtualFileArray(String[] files, ConfigurationValue cv)
    	throws ConfigurationException
    {
    	VirtualFile[] vfiles = new VirtualFile[files != null ? files.length : 0];
    	for (int i = 0, length = vfiles.length; i < length; i++)
    	{
    		vfiles[i] = getVirtualFile(files[i], cv);
    	}
    	return vfiles;
    }

    private VirtualFile getVirtualFile(String file, ConfigurationValue cv)
    	throws ConfigurationException
    {
    	return ConfigurationPathResolver.getVirtualFile( file, configResolver, cv );
    }

    private File[] toFileArray(String[] files)
    {
    	File[] fileArray = new File[files != null ? files.length : 0];
    	for (int i = 0, length = files.length; i < length; i++)
    	{
    		fileArray[i] = new File(files[i]);
    	}
    	return fileArray;
    }

    private Set<String> externs = new HashSet<String>();

    Set<String> getExterns()
    {
        return externs;
    }

    public void addExtern(String extern)
    {
        this.externs.add(extern);
    }

    //
    // 'compiler.accessible' option
    //

    private boolean accessible;

    public boolean accessible()
    {
        return accessible;
    }

    public void setAccessible(boolean accessible)
    {
        this.accessible = accessible;
    }

    public void cfgAccessible( ConfigurationValue cv, boolean accessible )
    {
        this.accessible = accessible;
    }

	//
    // 'compiler.actionscript-file-encoding' option
    //

	// user-defined AS3 file encoding
	private String actionscriptFileEncoding = null;

	public String getActionscriptFileEncoding()
	{
		return actionscriptFileEncoding;
	}

	public String getEncoding()
	{
		return getActionscriptFileEncoding();
	}

	public void cfgActionscriptFileEncoding(ConfigurationValue cv, String encoding)
	{
		actionscriptFileEncoding = encoding;
	}

	//
    // 'compiler.adjust-opdebugline' option (hidden)
    //

	// C: for internal use only. set it to false so that debugging mxmlc auto-generated code is easier.
	private boolean adjustOpDebugLine = true;

	public boolean adjustOpDebugLine()
	{
		return adjustOpDebugLine;
	}

	public void cfgAdjustOpdebugline(ConfigurationValue cv, boolean b)
	{
		adjustOpDebugLine = b;
	}

	public static ConfigurationInfo getAdjustOpdebuglineInfo()
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
    // 'compiler.allow-source-path-overlap' option
    //

	private boolean allowSourcePathOverlap = false;

	public boolean allowSourcePathOverlap()
	{
		return allowSourcePathOverlap;
	}

	public void cfgAllowSourcePathOverlap(ConfigurationValue cv, boolean b)
	{
		allowSourcePathOverlap = b;
	}

	public static ConfigurationInfo getAllowSourcePathOverlapInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.as3' option
    //

	public static final int AS3Dialect = 10, ESDialect = 9;
	private int dialect = AS3Dialect;

	public int dialect()
	{
		return dialect;
	}

	public void cfgAs3(ConfigurationValue cv, boolean b)
	{
		dialect = b ? AS3Dialect : ESDialect;
	}

	public static ConfigurationInfo getAs3Info()
	{
	    return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.define' option
    //

    /**
     * Syntax:<br/>
     * <code>-define=&lt;name&gt;,&lt;value&gt;</code>
     * where name is <code>NAMESPACE::name</code> and value is a legal definition value
     * (e.g. <code>true</code> or <code>1</code> or <code>!CONFIG::debugging</code>)
     *
     * Example: <code>-define=CONFIG::debugging,true</code>
     *
     * In <code>flex-config.xml</code>:<br/>
     * <pre>
     * <flex-config>
     *    <compiler>
     *       <define>
     *          <name>CONFIG::debugging</name>
     *          <value>true</value>
     *       </define>
     *       ...
     *    </compile>
     * </flex-config>
     * </pre>
     *
     * Values:<br/>
     * Values are ActionScript expressions that must coerce and evaluate to constants at compile-time.
     * Effectively, they are replaced in AS code, verbatim, so <code>-define=TEST::oneGreaterTwo,"1>2"</code>
     * will get coerced and evaluated, at compile-time, to <code>false</code>.
     *
     * It is good practice to wrap values with double-quotes,
     * so that MXMLC correctly parses them as a single argument:<br/>
     * <code>-define=TEST::oneShiftRightTwo,"1 >> 2"</code>
     *
     * Values may contain compile-time constants and other configuration values:<br/>
     * <code>-define=CONFIG::bool2,false -define=CONFIG::and1,"CONFIG::bool2 && false" TestApp.mxml</code>
     *
     * String values on the command-line <i>must</i> be surrounded by double-quotes, and either
     * escape-quoted (<code>"\"foo\""</code> or <code>"\'foo\'"</code>) or single-quoted
     * (<code>"'foo'"</code>).
     *
     * String values in configuration files need only be single- or double- quoted:<br/>
     * <pre>
     * <flex-config>
     *    <compiler>
     *       <define>
     *          <name>NAMES::Company</name>
     *          <value>'Apache Software Foundation'</value>
     *       </define>
     *       <define>
     *          <name>NAMES::Application</name>
     *          <value>"Flex 4.7"</value>
     *       </define>
     *       ...
     *    </compile>
     * </flex-config>
     * </pre>
     *
     * Empty strings <i>must</i> be passed as <code>"''"</code> on the command-line, and
     * <code>''</code> or <code>""</code> in configuration files.
     * 
     * Finally, if you have existing definitions in a configuration file, and you would
     * like to add to them with the command-line (let's say most of your build settings
     * are in the configuration, and that you are adding one temporarily using the
     * command-line), you use the following syntax:
     * <code>-define+=TEST::temporary,false</code> (noting the plus sign)
     * 
     * Note that definitions can be overridden/redefined if you use the append ("+=") syntax
     * (on the commandline or in a user config file, for instance) with the same namespace
     * and name, and a new value.
     * 
     * Definitions cannot be removed/undefined. You can undefine ALL existing definitions
     * from (e.g. from flex-config.xml) if you do not use append syntax ("=" or append="false").
     * 
     * IMPORTANT FOR FLEXBUILDER
     * If you are using "Additional commandline arguments" to "-define", don't use the following
     * syntax though I suggest it above:
     *     -define+=CONFIG::foo,"'value'"
     * The trouble is that FB parses the double quotes incorrectly as <"'value'> -- the trailing
     * double-quote is dropped. The solution is to avoid inner double-quotes and put them around the whole expression:
     *    -define+="CONFIG::foo,'value'"
     */
	private ObjectList<ConfigVar> configVars = new ObjectList<ConfigVar>();
    
    /**
     * @return A list of ConfigVars
     */
    public ObjectList<ConfigVar> getDefine()
    {
        return configVars;
    }

    public void cfgDefine( ConfigurationValue _cv, final String _name, String _value )
        throws ConfigurationException
    {
        assert _name  != null;
        assert _value != null;
        assert _cv    != null;

        // macromedia.asc.embedding.Main.parseConfigVar(_name + "=" + _value)
        final int ns_end = _name.indexOf("::");
        if( (ns_end == -1) || (ns_end == 0) || (ns_end == _name.length()-2) )
        {
            throw new ConfigurationException.BadDefinition(_name + " " + _value,
                                                           _cv.getVar(),
                                                           _cv.getSource(),
                                                           _cv.getLine());
        }
        
        final String ns = _name.substring(0, ns_end);
        final String name = _name.substring(ns_end + 2);
        
        if (configVars == null)
        {
            configVars = new ObjectList<ConfigVar>();
        }

        // try removing any existing definition
        for (final Iterator<ConfigVar> iter = configVars.iterator(); iter.hasNext();)
        {
            final ConfigVar other = iter.next();
            if (ns.equals(other.ns) && name.equals(other.name))
            {
                iter.remove();
                break;
            }
        }
        
        configVars.add(new ConfigVar(ns, name, _value));
    }
    
    public static ConfigurationInfo getDefineInfo()
    {
        return new ConfigurationInfo(new String[] {"name", "value"})
        {
            public boolean allowMultiple() { return true; }
            public boolean isAdvanced()    { return true; }
        };
    }

	//
    // 'compiler.conservative' option (hidden)
    //

	// compiler algorithm settings
	private boolean useConservativeAlgorithm = false;

	public boolean useConservativeAlgorithm()
	{
		return useConservativeAlgorithm;
	}

	public void cfgConservative(ConfigurationValue cv, boolean c)
	{
		useConservativeAlgorithm = c;
	}

	public static ConfigurationInfo getConservativeInfo()
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
    // 'compiler.context-root' option
    //

    /**
     * --context-root is used to resolve {context.root} tokens
     * in services configuration files to improve portability.
     */
    private String contextRoot;

    public String getContextRoot()
    {
        return contextRoot;
    }

    public void setContextRoot(String contextRoot)
    {
        this.contextRoot = contextRoot;
    }

    public void cfgContextRoot( ConfigurationValue cv, String contextRoot )
    {
        this.contextRoot = contextRoot;
    }

    public static ConfigurationInfo getContextRootInfo()
    {
        return new ConfigurationInfo( 1, "context-path" )
        {
        };
    }

    //
    // 'compiler.debug' option
    //

    // this general debug setting in the CompilerConfiguration maps to different
    // settings on the implemented interfaces; they get split up here for clarity
    private boolean debug;
    
    public boolean debug()
    {
        return debug;
    }
    
    public void setDebug(boolean debug)
    {
        this.debug = debug;
    }

    public void cfgDebug(ConfigurationValue cv, boolean debug)
    {
        this.debug = debug;
    }

    //
    // 'compiler.compress' option (default is true)
    //
    
    private boolean useCompression = true;
    
    public void cfgCompress( ConfigurationValue cv, boolean useCompression )
    {
        this.useCompression = useCompression;
    }
    
    /**
     * Setting {@code -compiler.compress=false} will force compiler not to compress the output SWF.
     */
    public boolean useCompression()
    {
        return this.useCompression;
    }
    
    //
    // 'compiler.defaults-css-url' option
    //

    /**
     * Location of defaults stylesheet.
     */
    private VirtualFile defaultsCssUrl;

    public VirtualFile getDefaultsCssUrl()
    {
        return defaultsCssUrl;
    }

    public void cfgDefaultsCssUrl( ConfigurationValue cv, String defaultsCssUrlPath ) throws ConfigurationException
    {
        defaultsCssUrl = ConfigurationPathResolver.getVirtualFile( defaultsCssUrlPath,
                                                                   configResolver,
                                                                   cv );
    }

    public static ConfigurationInfo getDefaultsCssUrlInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.doc' option (hidden)
    //

	private boolean doc;

	public boolean doc()
	{
		return this.doc;
	}

	public void cfgDoc(ConfigurationValue cv, boolean doc)
	{
		this.doc = doc;
	}

	public static ConfigurationInfo getDocInfo()
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
    // 'compiler.es' option
    //

	public void cfgEs(ConfigurationValue cv, boolean b)
	{
		dialect = b ? ESDialect : AS3Dialect;
	}

	public static ConfigurationInfo getEsInfo()
	{
	    return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.external-library-path' option
    //

    private VirtualFile[] externalLibraryPath;

    public VirtualFile[] getExternalLibraryPath()
    {
        return externalLibraryPath;
    }

	private boolean compilingForAIR = false;

	public boolean getCompilingForAIR()
	{
		return compilingForAIR;
	}

    public void cfgExternalLibraryPath( ConfigurationValue cv, String[] pathlist ) throws ConfigurationException
    {
		// We are "compiling for AIR" if airglobal.swc is in the pathlist.
		for (int i = 0; i < pathlist.length; i++)
		{
			String path = pathlist[i];
			if (path.equals(StandardDefs.SWC_AIRGLOBAL) ||
				path.endsWith("/" + StandardDefs.SWC_AIRGLOBAL) ||
				path.endsWith("\\" + StandardDefs.SWC_AIRGLOBAL))
			{
				compilingForAIR = true;
				break;
			}
		}

    	String[] locales = getLocales();
    	VirtualFile[] newPathElements = expandTokens(pathlist, locales, cv);
    	externalLibraryPath = (VirtualFile[])merge(externalLibraryPath, newPathElements, VirtualFile.class);
	}

    public static ConfigurationInfo getExternalLibraryPathInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "path-element" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }

	        public String[] getSoftPrerequisites()
	        {
		        return PATH_TOKENS;
	        }

            public boolean isPath()
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
    // 'compiler.fonts.*' options
    //

    private FontsConfiguration fontsConfig;

    public FontsConfiguration getFontsConfiguration()
    {
        return fontsConfig;
    }

    public void setFontsConfiguration(FontsConfiguration fc)
    {
        fontsConfig = fc;
	    fontsConfig.setCompilerConfiguration(this);
    }

    //
    // 'compiler.generated-directory' option (incomplete)
    //

    private String generatedDir = null;     // set based on the target file

    public String getGeneratedDirectory()
    {
        return generatedDir;
    }

    public void setGeneratedDirectory( String gd )
    {
        this.generatedDir = gd;
    }

    //
    // 'compiler.headless-server' option
    //

    private boolean headlessServer;

    public boolean headlessServer()
    {
        return headlessServer;
    }

    public void cfgHeadlessServer( ConfigurationValue cv, boolean headlessServer )
    {
        this.headlessServer = headlessServer;
    }

    public static ConfigurationInfo getHeadlessServerInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.include-libraries' option
    //

	private VirtualFile[] includeLibraries;

	public VirtualFile[] getIncludeLibraries()
	{
		return includeLibraries;
	}

	public void cfgIncludeLibraries(ConfigurationValue cv, String[] pathlist)
			throws ConfigurationException
	{
    	String[] locales = getLocales();
    	VirtualFile[] newPathElements = expandTokens(pathlist, locales, cv);
		includeLibraries = (VirtualFile[])merge(includeLibraries, newPathElements, VirtualFile.class);
	}

	public static ConfigurationInfo getIncludeLibrariesInfo()
	{
		return new ConfigurationInfo( -1, new String[] { "library" } )
		{
			public boolean allowMultiple()
			{
				return true;
			}

	        public String[] getSoftPrerequisites()
	        {
		        return PATH_TOKENS;
	        }

            public boolean isPath()
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
    // 'compiler.incremental' option
    //

	private boolean incremental = false;

	public boolean getIncremental()
	{
		return incremental;
	}

	public void cfgIncremental(ConfigurationValue cv, boolean b)
	{
		incremental = b;
	}

    //
    // 'compiler.keep-all-type-selectors' option.  This was initially
    // used by Flex Builder when building design view, but they no
    // longer use it.
    //

	private boolean keepAllTypeSelectors;

	public boolean keepAllTypeSelectors()
	{
		return keepAllTypeSelectors;
	}

	public void setKeepAllTypeSelectors( boolean keepAllTypeSelectors )
	{
		this.keepAllTypeSelectors = keepAllTypeSelectors;
	}

	public void cfgKeepAllTypeSelectors( ConfigurationValue cv, boolean keepAllTypeSelectors )
	{
		this.keepAllTypeSelectors = keepAllTypeSelectors;
	}

    public static ConfigurationInfo getKeepAllTypeSelectorsInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.keep-as3-metadata' option
    //

    private String[] as3metadata = null;

    public String[] getKeepAs3Metadata()
    {
    	return as3metadata;
    }

    public void cfgKeepAs3Metadata(ConfigurationValue cv, String[] md)
    {
    	if (as3metadata == null)
    	{
    		as3metadata = md;
    	}
    	else if (md != null)
    	{
    		Set<String> s = new HashSet<String>(Arrays.asList(as3metadata));
    		s.addAll(Arrays.asList(md));
    		as3metadata = new String[s.size()];
    		int k = 0;
    		for (Iterator<String> i = s.iterator(); i.hasNext(); k++)
    		{
    			as3metadata[k] = i.next();
    		}
    	}
    }

    public boolean keepEmbedMetadata()
    {
        if( as3metadata != null )
        {
            for( int i = 0; i < as3metadata.length; ++i )
            {
                if(StandardDefs.MD_EMBED.equals(as3metadata[i]))
                {
                    return true;
                }
            }
        }
        return false;
    }

    public static ConfigurationInfo getKeepAs3MetadataInfo()
    {
        return new ConfigurationInfo(-1, new String[] { "name" })
        {
            public boolean isAdvanced()
            {
            	return true;
            }

			public boolean allowMultiple()
			{
				return true;
			}
        };
    }

    //
    // 'compiler.keep-generated-actionscript' option
    //

    private boolean keepGeneratedActionScript = true;

    public boolean keepGeneratedActionScript()
    {
        return keepGeneratedActionScript;
    }

    public void setKeepGeneratedActionScript(boolean keepGeneratedActionScript)
    {
        this.keepGeneratedActionScript = keepGeneratedActionScript;

        // Force AST generation off if the user wants to see the AS equivalent.
        if (keepGeneratedActionScript)
        {
            generateAbstractSyntaxTree = false;
        }
    }

    public void cfgKeepGeneratedActionscript(ConfigurationValue cv, boolean keep)
    {
        setKeepGeneratedActionScript(keep);
    }

    public static ConfigurationInfo getKeepGeneratedActionscriptInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.keep-generated-signatures' option (hidden)
    //
    private boolean keepGeneratedSignatures; // = false;

    public boolean getKeepGeneratedSignatures()
    {
        return keepGeneratedSignatures;
    }

    public void setKeepGeneratedSignatures(boolean keepGeneratedSignatures)
    {
        this.keepGeneratedSignatures = keepGeneratedSignatures;
    }

    public void cfgKeepGeneratedSignatures(ConfigurationValue cv, boolean keep)
    {
        this.keepGeneratedSignatures = keep;
    }

    public static ConfigurationInfo getKeepGeneratedSignaturesInfo()
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
    // 'compiler.enable-runtime-design-layers' option
    //

    private boolean enableRuntimeDesignLayers = true;

    public boolean enableRuntimeDesignLayers()
    {
        return enableRuntimeDesignLayers;
    }

    public void setEnableRuntimeDesignLayers(boolean enableDesignLayers)
    {
        this.enableRuntimeDesignLayers = enableDesignLayers;
    }

    public void cfgEnableRuntimeDesignLayers(ConfigurationValue cv, boolean enable)
    {
        setEnableRuntimeDesignLayers(enable);
    }
    
    //
    // 'compiler.enable-swc-version-filtering' option
    //

    private boolean enableSwcVersionFiltering = true;

    public boolean enableSwcVersionFiltering()
    {
        return enableSwcVersionFiltering;
    }

    public void setEnableSwcVersionFiltering(boolean enableSwcFiltering)
    {
        this.enableSwcVersionFiltering = enableSwcFiltering;
    }

    public void cfgEnableSwcVersionFiltering(ConfigurationValue cv, boolean enable)
    {
    	setEnableSwcVersionFiltering(enable);
    }
    
    public static ConfigurationInfo getEnableSwcVersionFilteringInfo()
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
    // 'compiler.library-path' option
    //

    /**
     * A list of SWC component libraries or directories containing SWCs.
     * All SWCs found in the library-path are merged together
     * and resolved via priority and version.
     * The order in the library-path is ignored.
     *
     * The specified compiler.library-path can have path elements
     * which contain a special {locale} token.
     * If you compile for a single locale,
     * this token is replaced by the specified locale.
     * If you compile for multiple locales,
     * any path element with the {locale} token
	 * is expanded into multiple path elements,
	 * one for each locale.
     * If you compile for no locale,
     * any path element with {locale} is ignored.
     */
    private VirtualFile[] libraryPath;

    public VirtualFile[] getLibraryPath()
    {
        return libraryPath;
    }

    public void cfgLibraryPath( ConfigurationValue cv, String[] pathlist ) throws ConfigurationException
    {
    	String[] locales = getLocales();
    	VirtualFile[] newPathElements = expandTokens(pathlist, locales, cv);
    	libraryPath = (VirtualFile[])merge(libraryPath, newPathElements, VirtualFile.class);
    }

    public static ConfigurationInfo getLibraryPathInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "path-element" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }

	        public String[] getSoftPrerequisites()
	        {
		        return PATH_TOKENS;
	        }

            public boolean isPath()
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
    // 'compiler.locale' option
    //

    /*
     * This is never null. If you specify "no locales"
     * with -locale= then it is an empty array.
     */
    private String[] locales = new String[] {};

    public String[] getLocales()
    {
        return locales;
    }

	public String locale()
	{
		return locales.length > 0 ? locales[0] : null;
	}

    public void cfgLocale( ConfigurationValue cv, String[] newLocales )
    {
        locales = (String[])merge(newLocales, locales, String.class);
    }

    public static ConfigurationInfo getLocaleInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "locale-element" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }

    //
    // 'compiler.local-fonts-snapshot' option (hidden)
    //

	/**
	 * Location of localFonts.ser
	 */
	/**private VirtualFile localFontsSnapshot;

	public VirtualFile getLocalFontsSnapshot()
	{
	    return localFontsSnapshot;
	}

	public void cfgLocalFontsSnapshot( ConfigurationValue cv, String localFontsSnapshotPath ) throws ConfigurationException
	{
		try
		{
			localFontsSnapshot = ConfigurationPathResolver.getVirtualFile( localFontsSnapshotPath,
					configResolver,
					cv );

			System.out.println(localFontsSnapshot);

		}
		catch(ConfigurationException ce)
		{
			// ignore, error will be shown later if needed
		}
	}

	public static ConfigurationInfo getLocalFontsSnapshotInfo()
	{
	    return new ConfigurationInfo()
	    {
	        public boolean isHidden()
	        {
	            return true;
	        }
	    };
	}
	**/

	//
    // 'compiler.memory-usage-factor' option (hidden)
    //

	private int factor = 1000;

	public int factor()
	{
		return factor;
	}

	public void cfgMemoryUsageFactor(ConfigurationValue cv, int f)
	{
		factor = f;
	}

	public static ConfigurationInfo getMemoryUsageFactorInfo()
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
    // 'compiler.metadata-export' option (incomplete)
    //

    private boolean metadataExport;

    public boolean metadataExport()
    {
        return metadataExport;
    }

    // metadataExport does not have the normal configuration setter because it is not
    // a normal configuration value but rather something set by the compiler
    public void setMetadataExport(boolean metadataExport)
    {
        this.metadataExport = metadataExport;
    }


    //
    // 'compiler.mobile' option
    //

    private boolean mobile = false;

    /**
     * @return determines whether the target runtime is a mobile device. This
     * may alter the features available, such as certain blend-modes when
     * compiling FXG.
     */
    public boolean getMobile()
    {
        return mobile;
    }

    public void setMobile(boolean value)
    {
        mobile = value;
	}

    public void cfgMobile(ConfigurationValue cv, boolean b)
    {
        mobile = b;
    }


    // 'compiler.mxml.*' options

    private MxmlConfiguration mxmlConfig;

    public MxmlConfiguration getMxmlConfiguration()
    {
    	return mxmlConfig;
    }

    //
    // 'compiler.mxml.compatibility-version' option
    //

    public String getCompatibilityVersionString()
    {
        return mxmlConfig.getCompatibilityVersionString();
    }

	public int getCompatibilityVersion()
	{
		return mxmlConfig.getCompatibilityVersion();
	}

    //
    // 'compiler.mxml.minimum-supported-version' option
    //

    public String getMinimumSupportedVersionString()
    {
        return mxmlConfig.getMinimumSupportedVersionString();
    }

    public int getMinimumSupportedVersion()
    {
        return mxmlConfig.getMinimumSupportedVersion();
    }

    public void cfgMinimumSupportedVersion(ConfigurationValue cv, String version) throws ConfigurationException
    {
        mxmlConfig.cfgMinimumSupportedVersion(cv, version);
    }
    
    //
    // 'qualified-type-selectors' option
    //
	
    public boolean getQualifiedTypeSelectors()
    {
        return mxmlConfig.getQualifiedTypeSelectors();
    }

    //
    // 'compiler.namespaces.*' options
    //

	private NamespacesConfiguration namespaces;

	public NamespacesConfiguration getNamespacesConfiguration()
	{
		return namespaces;
	}

    //
    // 'compiler.omit-trace-statements' option
    //

	private boolean omitTraceStatements = true;

	public boolean omitTraceStatements()
	{
		return omitTraceStatements;
	}

	public void cfgOmitTraceStatements(ConfigurationValue cv, boolean b)
	{
		omitTraceStatements = b;
	}

    //
    // 'compiler.optimize' option
    //

	private boolean optimize = false;

	public boolean optimize()
	{
		return optimize;
	}

	public boolean getOptimize()
	{
		return optimize;
	}

	public void setOptimize(boolean optimize)
	{
		this.optimize = optimize;
	}

	public void cfgOptimize(ConfigurationValue cv, boolean b)
	{
		optimize = b;
	}
	
	//
    // 'compiler.preloader' option
    //

	private String preloader = null;

	public String getPreloader()
	{
		return preloader;
	}

	public void cfgPreloader(ConfigurationValue cv, String value)
	{
		preloader = value;
	}

	//
    // 'compiler.resource-hack' option
    //

    // This undocumented option is for compiler performance testing.
	// It allows the Flex 3 compiler to compile the Flex 2 framework
	// and Flex 2 apps. This is not an officially-supported combination.
	private boolean resourceHack = false;

	public boolean getResourceHack()
	{
		return resourceHack;
	}

	public void cfgResourceHack(ConfigurationValue cv, boolean b)
	{
		resourceHack = b;
	}

	public static ConfigurationInfo getResourceHackInfo()
	{
	    return new ConfigurationInfo()
	    {
	        public boolean isHidden()
	        {
	            return true;
	        }
	    };
	}

	//
    // 'compiler.services' option
    //

	private VirtualFile servicesConfigFile;

	protected ServicesDependenciesWrapper servicesDependencies;

	public VirtualFile getServices()
	{
		return servicesConfigFile;
	}

    /**
     * Used by the compiler to record the client dependencies
     * from the Flex Data Services configuration file.
     */
    public ServicesDependenciesWrapper getServicesDependencies()
    {
        if (servicesDependencies == null && servicesConfigFile != null)
        {
            String servicesPath = servicesConfigFile.getName();
            servicesDependencies = new ServicesDependenciesWrapper(servicesPath, null, getContextRoot());
        }

        return servicesDependencies;
    }

    public void setServicesDependencies(ServicesDependenciesWrapper deps)
    {
        servicesDependencies = deps;
    }

    public void cfgServices(ConfigurationValue cv, String servicesPath) throws ConfigurationException
    {
        try
        {
	        servicesConfigFile = ConfigurationPathResolver.getVirtualFile(servicesPath,
	                                                                      configResolver, cv);
        }
        catch(Throwable t)
        {
            throw new ConfigurationException.CannotOpen( servicesPath, cv.getVar(), cv.getSource(), cv.getLine() );
        }
    }

    public static ConfigurationInfo getServicesInfo()
    {
        return new ConfigurationInfo( 1, "filename" )
        {
        };
    }

    //
    // 'compiler.show-actionscript-warnings' option
    //

    /**
     * Enable asc -warnings
     */
    private boolean ascWarnings;

    public boolean warnings()
    {
        return this.ascWarnings;
    }

    public void cfgShowActionscriptWarnings( ConfigurationValue cv, boolean ascWarnings )
    {
        this.ascWarnings = ascWarnings;
    }

    //
    // 'compiler.show-binding-warnings' option
    //

    /**
     * Controls whether binding warnings are displayed.
     */
    private boolean showBindingWarnings = true;

    public boolean showBindingWarnings()
    {
        return showBindingWarnings;
    }

    public void cfgShowBindingWarnings(ConfigurationValue cv, boolean show)
    {
        this.showBindingWarnings = show;
    }

    //
    // 'compiler.show-dependency-warnings' option (hidden)
    //

    private boolean showDependencyWarnings = false;

    public boolean showDependencyWarnings()
    {
        return showDependencyWarnings;
    }

    public void cfgShowDependencyWarnings(ConfigurationValue cv, boolean show)
    {
        this.showDependencyWarnings = show;
    }

    public static ConfigurationInfo getShowDependencyWarningsInfo()
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
    // 'compiler.report-invalid-styles-as-warnings' option
    /**
     * Controls whether invalid styles are report as errors or
     * warnings.
     */
    private boolean reportInvalidStylesAsWarnings = false;

    public boolean reportInvalidStylesAsWarnings()
    {
        return reportInvalidStylesAsWarnings;
    }

    public void setReportInvalidStylesAsWarnings(boolean reportInvalidStylesAsWarnings)
    {
        this.reportInvalidStylesAsWarnings = reportInvalidStylesAsWarnings;
    }

    public void cfgReportInvalidStylesAsWarnings(ConfigurationValue cv, boolean show)
    {
        this.reportInvalidStylesAsWarnings = show;
    }
    
    //
    // 'compiler.report-missing-required-skin-parts-as-warnings' option
    //

    private boolean reportMissingRequiredSkinPartsAsWarnings = false;

    /**
     * Allow the user to configure whether it should be considered an error to
     * not create a required skin part or if it should just be a warning.
     */
    public boolean reportMissingRequiredSkinPartsAsWarnings()
    {
        return reportMissingRequiredSkinPartsAsWarnings;
    }

    public void cfgReportMissingRequiredSkinPartsAsWarnings(ConfigurationValue cv, boolean b)
    {
        reportMissingRequiredSkinPartsAsWarnings = b;
    }

    public static ConfigurationInfo getReportMissingRequiredSkinPartsAsWarningsInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.show-invalid-css-property-warnings' option
    /**
     * Controls whether warnings are displayed when styles, which
     * don't apply to the current theme(s), are used in CSS.
     */
    private boolean showInvalidCssPropertyWarnings = true;

    public boolean showInvalidCssPropertyWarnings()
    {
        return showInvalidCssPropertyWarnings;
    }

    public void setShowInvalidCssPropertyWarnings(boolean showInvalidCssPropertyWarnings)
    {
        this.showInvalidCssPropertyWarnings = showInvalidCssPropertyWarnings;
    }

    public void cfgShowInvalidCssPropertyWarnings(ConfigurationValue cv, boolean show)
    {
        this.showInvalidCssPropertyWarnings = show;
    }

    //
    // 'compiler.show-deprecation-warnings' option
    //

    /**
     * Controls whether warnings are displayed when a deprecated API is used.
     */
    private boolean showDeprecationWarnings = false;

    public boolean showDeprecationWarnings()
    {
        return showDeprecationWarnings;
    }

    public void setShowDeprecationWarnings(boolean showDeprecationWarnings)
    {
        this.showDeprecationWarnings = showDeprecationWarnings;
    }

    public void cfgShowDeprecationWarnings(ConfigurationValue cv, boolean show)
    {
        this.showDeprecationWarnings = show;
    }
    
    public static ConfigurationInfo getShowDeprecationWarningsInfo()
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
    // 'compiler.show-shadowed-device-font-warnings' option
    //

    /**
     * Controls whether warnings are displayed when an embedded font name
     * shadows a device font name. The default is true.
     */
    private boolean showShadowedDeviceFontWarnings = true;

    public boolean showShadowedDeviceFontWarnings()
    {
        return showShadowedDeviceFontWarnings;
    }

    public void setShowShadowedDeviceFontWarnings(boolean showShadowedDeviceFontWarnings)
    {
        this.showShadowedDeviceFontWarnings = showShadowedDeviceFontWarnings;
    }

    public void cfgShowShadowedDeviceFontWarnings(ConfigurationValue cv, boolean show)
    {
        this.showShadowedDeviceFontWarnings = show;
    }
    
    //
    // 'compiler.show-unused-type-selector-warnings' option
    //

    private boolean showUnusedTypeSelectorWarnings = true;

    public boolean showUnusedTypeSelectorWarnings()
    {
        return showUnusedTypeSelectorWarnings;
    }

    public void setShowUnusedTypeSelectorWarnings(boolean showUnusedTypeSelectorWarnings)
    {
        this.showUnusedTypeSelectorWarnings = showUnusedTypeSelectorWarnings;
    }

    public void cfgShowUnusedTypeSelectorWarnings(ConfigurationValue cv, boolean show)
    {
        this.showUnusedTypeSelectorWarnings = show;
    }

    //
    // 'disable-incremental-optimizations' option (hidden)
    // Back-door to disable optimizations in case they are causing problems.
    //

    private boolean disableIncrementalOptimizations = false;
    public boolean getDisableIncrementalOptimizations()
    {
        return disableIncrementalOptimizations;
    }
    public void setDisableIncrementalOptimizations(boolean disable)
    {
        disableIncrementalOptimizations = disable;
    }
    public void cfgDisableIncrementalOptimizations(ConfigurationValue cv, boolean disable)
    {
        disableIncrementalOptimizations = disable;
    }
    public static ConfigurationInfo getDisableIncrementalOptimizationsInfo()
    {
        return new ConfigurationInfo()
        {

            public boolean isAdvanced()
            {
                return true;
            }

            public boolean isHidden()
            {
                return true;
            }
        };
    }

    //
    // 'compiler.signature-directory' option (hidden)
    //

    private String signatureDirectory;

    public String getSignatureDirectory()
    {
        return signatureDirectory;
    }

    public void setSignatureDirectory(String signatureDirectory) throws ConfigurationException
    {
        this.signatureDirectory = signatureDirectory;
    }

    public void cfgSignatureDirectory( ConfigurationValue cv, String path ) throws ConfigurationException
    {
        // configure to a canonical path
        final File dir;
        {
            String parent = null;

            if (cv != null)
            {
                parent = cv.getBuffer().getToken(flex2.tools.oem.Configuration.DEFAULT_OUTPUT_DIRECTORY_TOKEN);
            }

            if (parent == null)
            {
                parent = configResolver.resolve(".").getNameForReporting();
            }

            if (!(new File(path)).isAbsolute())
            {
                // if the given path is relative... to the parent
                dir = new File(FileUtils.addPathComponents(parent,
                                                           path,
                                                           File.separatorChar));
            }
            else
            {
                // otherwise it's absolute
                dir = new File(path);
            }

            signatureDirectory = FileUtils.canonicalPath(dir);

        }

        // create the directory and validate it
        if (!(dir.isDirectory() || dir.mkdirs()))
        {
            if (cv == null)
            {
                throw new ConfigurationException.NotDirectory( path, null, null, -1 );
            }
            else
            {
                throw new ConfigurationException.NotDirectory( path, cv.getVar(), cv.getSource(), cv.getLine() );
            }
        }
    }

    public static ConfigurationInfo getSignatureDirectoryInfo()
    {
        return new ConfigurationInfo(new String[] { "relative-directory" } )
        {
            public boolean isPath()
            {
                return true;
            }

            public boolean isAdvanced()
            {
                return true;
            }

            public boolean isHidden()
            {
                return true;
            }
        };
    }

    //
    // 'compiler.source-path' option
    //

    /**
     * Source path elements searched for ActionScript class files,
	 * possibly containing a {locale} token.
     */
    private File[] unexpandedSourcePath;

    /**
     * Directories searched for ActionScript class files.
     *
     * The specified compiler.source-path can have path elements
     * which contain a special {locale} token.
     * If you compile for a single locale,
     * this token is replaced by the specified locale.
     * If you compile for multiple locales,
     * any path element with the {locale} token is ignored,
     * because we do not support compiling, for example,
     * both en_US and ja_JP versions of MyComponent into the same SWF.
     * A path element with {locale} is similarly ignored
     * if you compile for no locale.
     */
    private VirtualFile[] sourcePath;
    
    public void setSourcePath(VirtualFile[] sourcePath) {
        this.sourcePath = sourcePath;
    }

    /**
     * Directories searched for .properties files for resource bundles,
     * for each locale.
     *
     * These are determined by the same compiler.source-path option
     * which determines sourcePath
     * There is a separate list for each locale.
     * For example, if you set
     *   -source-path=foo,bar/{locale},baz -locale=en_US,ja_JP
     * then the source directories searched when compiling the
     * en_US resource bundles are foo, bar/en_US, and baz
     * while the source directories searched when compiling the
     * ja_JP resource bundles are foo, bar/ja_JP, and baz.
     */
    private Map<String, VirtualFile[]> resourceBundlePaths = new HashMap<String, VirtualFile[]>();

    public File[] getUnexpandedSourcePath()
    {
    	return unexpandedSourcePath;
    }

    public VirtualFile[] getSourcePath()
    {
        return sourcePath;
    }

    public VirtualFile[] getResourceBundlePathForLocale(String locale)
    {
    	VirtualFile[] path = resourceBundlePaths.get(locale);
    	return path;
    }

	public void cfgSourcePath( ConfigurationValue cv, String[] pathlist ) throws ConfigurationException
	{
		unexpandedSourcePath = (File[])merge(unexpandedSourcePath, toFileArray(pathlist), File.class);

        String[] locales = getLocales();

        VirtualFile[] newPathElements = expandTokens(pathlist, locales, cv);
        checkNewSourcePathElements(newPathElements, cv);
        sourcePath = (VirtualFile[])merge(sourcePath, newPathElements, VirtualFile.class);

		for (int i = 0; i < locales.length; i++)
		{
			String locale = locales[i];
			newPathElements = expandTokens(pathlist, new String[] { locale }, cv);
			checkNewSourcePathElements(newPathElements, cv);
			VirtualFile[] bundlePath = resourceBundlePaths.get(locale);
			bundlePath = (VirtualFile[])merge(bundlePath, newPathElements, VirtualFile.class);
			resourceBundlePaths.put(locale, bundlePath);
		}
	}

	private void checkNewSourcePathElements(VirtualFile[] newPathElements, ConfigurationValue cv) throws ConfigurationException
	{
        for (int i = 0; i < newPathElements.length; i++)
		{
			VirtualFile pathElement = newPathElements[i];
			if (!pathElement.isDirectory())
			{
				if (cv == null)
				{
					throw new ConfigurationException.NotDirectory(
							pathElement.getName(), null, null, -1);
				}
				else
				{
					throw new ConfigurationException.NotDirectory(
							pathElement.getName(), cv.getVar(), cv.getSource(), cv.getLine());
				}
			}
		}
	}

	public static ConfigurationInfo getSourcePathInfo()
	{
		return new ConfigurationInfo( -1, new String[] { "path-element" } )
		{
			public boolean allowMultiple()
			{
				return true;
			}

			public String[] getSoftPrerequisites()
			{
				return PATH_TOKENS;
			}

            public boolean isPath()
            {
                return true;
            }
        };
	}

    //
    // 'compiler.strict' option
    //

    /**
     * Run the AS3 compiler in strict mode
     */
    private boolean strict;

    public boolean strict()
    {
        return this.strict;
    }

    public void cfgStrict( ConfigurationValue cv, boolean strict )
    {
        this.strict = strict;
    }

	//
    // 'compiler.suppress-warnings-in-incremental' option (incomplete)
    //

	// for Zorn
	//
	// When doing incremental compilation, the compiler doesn't recompile codes that are previously compiled with
	// warnings. It only outputs the warning messages so as to remind users of the warnings.
	//
	// The command-line tool and Zorn work differently in that Zorn keeps the warning logger while the commnad-line
	// tool, of course, can't keep the warning logger alive...
	//
	// Zorn needs this flag to tell the compiler not to output warnings again in incremental compilations because
	// it keeps its own log.
	private boolean suppressWarningsInIncremental = false;

	public boolean suppressWarningsInIncremental()
	{
		return suppressWarningsInIncremental;
	}

	public void setSuppressWarningsInIncremental(boolean b)
	{
		suppressWarningsInIncremental = b;
	}

    //
    // 'compiler.theme' option
    //

    private VirtualFile[] themeFiles;

    public VirtualFile[] getThemeFiles()
    {
        // Swap in the default Flex 3 theme of Halo.
        if ((mxmlConfig.getCompatibilityVersion() <= MxmlConfiguration.VERSION_3_0) &&
            ((themeFiles != null) && ((themeFiles.length == 1))))
        {
            File file = new File("/themes/Spark/spark.css");

            if (themeFiles[0].getName().endsWith(file.getPath()))
            {
                String name = themeFiles[0].getName();
                int index = name.indexOf(file.getPath());
                themeFiles[0] = new LocalFile(new File(name.substring(0, index) + "/themes/Halo/halo.swc"));
                themeNames.remove("spark");
                themeNames.add("halo");
            }
        }

        return themeFiles;
    }

    public void cfgTheme( ConfigurationValue cv, List paths ) throws ConfigurationException
    {
        VirtualFile[] vfa = new VirtualFile[paths.size()];

        int i = 0;
        for (Iterator it = paths.iterator(); it.hasNext();)
        {
            String path = (String) it.next();
            addThemeName(path);
            VirtualFile theme = ConfigurationPathResolver.getVirtualFile( path,
                                                                          configResolver,
                                                                          cv );
            if (theme == null)
            {
                throw new ConfigurationException.ConfigurationIOError( path, cv.getVar(), cv.getSource(), cv.getLine() );
            }
            vfa[i++] = theme;
        }
        themeFiles = (VirtualFile[])merge( themeFiles, vfa, VirtualFile.class );
    }

    public static ConfigurationInfo getThemeInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "filename" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean doChecksum()
            {
            	return false;
            }
        };
    }

    private Set<String> themeNames = new HashSet<String>();
    
    private void addThemeName(String path)
    {
        File file = new File(path);
        String fileName = file.getName();
        int end = fileName.indexOf("-");

        if (end == -1)
        {
            end = fileName.lastIndexOf(".");
        }

        if (end != -1)
        {
            String themeName = fileName.substring(0, end);
            themeNames.add(themeName);
        }
    }

    public Set<String> getThemeNames()
    {
        return themeNames;
    }
    
    //
    // 'compiler.defaults-css-files' option
    //
    
    /*
     * This allows you to insert CSS files into compilation the same way that a per-SWC
     * defaults.css file works, but without having to re-zip the SWC to test each change.
     * 
     * These CSS files have a higher precedence than those already in existing SWCs (e.g. specifying
     * this option will override definitions in framework.swc$defaults.css), however, they have the
     * same overall precedence as SWCs.
     * 
     * This takes one-or-more files, the CSS precedence is left-to-right, then SWCs.
     * 
     * NOTE: This does NOT actually insert the CSS file into the SWC, it simulates it. When you are
     * done developing the CSS, you should rebuild the SWC with the new CSS integrated.
     */
    
    /**
     * Location of defaults style stylesheets (css only).
     * 
     * Contract: -defaults-css-files=A,B,C
     *    'A' should have precedence over 'B', then 'C', then SWCs
     *    defaultsCssFiles should have the order: SWCS, C, B, A
     */
    private List<VirtualFile> defaultsCssFiles = new LinkedList<VirtualFile>();
    
    public List<VirtualFile> getDefaultsCssFiles()
    {
        return defaultsCssFiles;
    }

    public void addDefaultsCssFiles( Collection<VirtualFile> files )
    {
        // this list works backwards, the first CSS has lowest precedence
        // so each add should insert at the front
        // (see the javadoc for defaultsCssFiles)
        defaultsCssFiles.addAll( 0, files );
    }

    public void cfgDefaultsCssFiles( ConfigurationValue cv, List paths )
        throws ConfigurationException
    {
        final int defaultsCssFilesLastIndex = defaultsCssFiles.size();
        
        // verify and add the paths given
        for (Iterator it = paths.iterator(); it.hasNext();)
        {
            final String path = (String) it.next();
            VirtualFile css = ConfigurationPathResolver.getVirtualFile(path,
                                                                       configResolver,
                                                                       cv);
            if (css == null)
            {
                throw new ConfigurationException.ConfigurationIOError(path,
                                                                      cv.getVar(),
                                                                      cv.getSource(),
                                                                      cv.getLine());
            }

            // I start from defaultsCssFilesLastIndex so that the paths are in the correct
            // precedence order (see the javadoc for defaultsCssFiles)
            defaultsCssFiles.add(defaultsCssFilesLastIndex, css);
        }
    }

    public static ConfigurationInfo getDefaultsCssFilesInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "filename" } )
        {
            public boolean allowMultiple() { return true;  }
            public boolean isAdvanced()    { return true;  }
            public boolean doChecksum()    { return false; }
        };
    }
    
    /**
     * Location of theme style stylesheets (css only, configured via themefiles above).
     */
    private List<VirtualFile> themeCssFiles = new LinkedList<VirtualFile>();

    public List<VirtualFile> getThemeCssFiles()
    {
        return themeCssFiles;
    }

    public void addThemeCssFiles( List<VirtualFile> files )
    {
        themeCssFiles.addAll( files );
    }

    //
    // 'compiler.translation-format' option (hidden)
    //

	private String translationFormat;

    public String getTranslationFormat()
    {
        return translationFormat;
    }

    public void cfgTranslationFormat(ConfigurationValue cv, String t)
    {
        this.translationFormat = t;
    }

    public static ConfigurationInfo getTranslationFormatInfo()
    {
        return new ConfigurationInfo()
        {
            public boolean isHidden()
            {
                return true;
            }
        };
    }

	//
    // 'compiler.use-resource-bundle-metadata' option
    //

	private boolean useResourceBundleMetadata = false;

	public boolean useResourceBundleMetadata()
	{
		return useResourceBundleMetadata;
	}

	public void cfgUseResourceBundleMetadata(ConfigurationValue cv, boolean b)
	{
		useResourceBundleMetadata = b;
	}

	public static ConfigurationInfo getuseResourceBundleMetadataInfo()
	{
	    return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.verbose-stacktraces' option
    //

    private boolean verboseStacktraces;

    public boolean verboseStacktraces()
    {
        return verboseStacktraces;
    }

    public void setVerboseStacktraces(boolean verboseStacktraces)
	{
	    this.verboseStacktraces = verboseStacktraces;
	}

    public void cfgVerboseStacktraces( ConfigurationValue cv, boolean verboseStacktraces )
    {
        this.verboseStacktraces = verboseStacktraces;
    }

	//
    // 'compiler.warn-array-tostring-changes' option
    //

	private boolean warn_array_tostring_changes = false;

	public boolean warn_array_tostring_changes()
	{
		return warn_array_tostring_changes;
	}

	public void cfgWarnArrayTostringChanges(ConfigurationValue cv, boolean b)
	{
		warn_array_tostring_changes = b;
	}

	public static ConfigurationInfo getWarnArrayTostringChangesInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-assignment-within-conditional' option
    //

	private boolean warn_assignment_within_conditional = true;

	public boolean warn_assignment_within_conditional()
	{
		return warn_assignment_within_conditional;
	}

	public void cfgWarnAssignmentWithinConditional(ConfigurationValue cv, boolean b)
	{
		warn_assignment_within_conditional = b;
	}

	public static ConfigurationInfo getWarnAssignmentWithinConditionalInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-array-cast' option
    //

	private boolean warn_bad_array_cast = true;

	public boolean warn_bad_array_cast()
	{
		return warn_bad_array_cast;
	}

	public void cfgWarnBadArrayCast(ConfigurationValue cv, boolean b)
	{
		warn_bad_array_cast = b;
	}

	public static ConfigurationInfo getWarnBadArrayCastInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-bool-assignment' option
    //

	private boolean warn_bad_bool_assignment = true;

	public boolean warn_bad_bool_assignment()
	{
		return warn_bad_bool_assignment;
	}

	public void cfgWarnBadBoolAssignment(ConfigurationValue cv, boolean b)
	{
		warn_bad_bool_assignment = b;
	}

	public static ConfigurationInfo getWarnBadBoolAssignmentInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-date-cast' option
    //

	private boolean warn_bad_date_cast = true;

	public boolean warn_bad_date_cast()
	{
		return warn_bad_date_cast;
	}

	public void cfgWarnBadDateCast(ConfigurationValue cv, boolean b)
	{
		warn_bad_date_cast = b;
	}

	public static ConfigurationInfo getWarnBadDateCastInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-es3-type-method' option
    //

	private boolean warn_bad_es3_type_method = true;

	public boolean warn_bad_es3_type_method()
	{
		return warn_bad_es3_type_method;
	}

	public void cfgWarnBadEs3TypeMethod(ConfigurationValue cv, boolean b)
	{
		warn_bad_es3_type_method = b;
	}

	public static ConfigurationInfo getWarnBadEs3TypeMethodInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-es3-type-prop' option
    //

	private boolean warn_bad_es3_type_prop = true;

	public boolean warn_bad_es3_type_prop()
	{
		return warn_bad_es3_type_prop;
	}

	public void cfgWarnBadEs3TypeProp(ConfigurationValue cv, boolean b)
	{
		warn_bad_es3_type_prop = b;
	}

	public static ConfigurationInfo getWarnBadEs3TypePropInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-nan-comparison' option
    //

	private boolean warn_bad_nan_comparison = true;

	public boolean warn_bad_nan_comparison()
	{
		return warn_bad_nan_comparison;
	}

	public void cfgWarnBadNanComparison(ConfigurationValue cv, boolean b)
	{
		warn_bad_nan_comparison = b;
	}

	public static ConfigurationInfo getWarnBadNanComparisonInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-null-assignment' option
    //

	private boolean warn_bad_null_assignment = true;

	public boolean warn_bad_null_assignment()
	{
		return warn_bad_null_assignment;
	}

	public void cfgWarnBadNullAssignment(ConfigurationValue cv, boolean b)
	{
		warn_bad_null_assignment = b;
	}

	public static ConfigurationInfo getWarnBadNullAssignmentInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-null-comparison' option
    //

	private boolean warn_bad_null_comparison = true;

	public boolean warn_bad_null_comparison()
	{
		return warn_bad_null_comparison;
	}

	public void cfgWarnBadNullComparison(ConfigurationValue cv, boolean b)
	{
		warn_bad_null_comparison = b;
	}

	public static ConfigurationInfo getWarnBadNullComparisonInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-bad-undefined-comparison' option
    //

	private boolean warn_bad_undefined_comparison = true;

	public boolean warn_bad_undefined_comparison()
	{
		return warn_bad_undefined_comparison;
	}

	public void cfgWarnBadUndefinedComparison(ConfigurationValue cv, boolean b)
	{
		warn_bad_undefined_comparison = b;
	}

	public static ConfigurationInfo getWarnBadUndefinedComparisonInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-boolean-constructor-with-no-args' option
    //

	private boolean warn_boolean_constructor_with_no_args = false;

	public boolean warn_boolean_constructor_with_no_args()
	{
		return warn_boolean_constructor_with_no_args;
	}

	public void cfgWarnBooleanConstructorWithNoArgs(ConfigurationValue cv, boolean b)
	{
		warn_boolean_constructor_with_no_args = b;
	}

	public static ConfigurationInfo getWarnBooleanConstructorWithNoArgsInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-changes-in-resolve' option
    //

	private boolean warn_changes_in_resolve = false;

	public boolean warn_changes_in_resolve()
	{
		return warn_changes_in_resolve;
	}

	public void cfgWarnChangesInResolve(ConfigurationValue cv, boolean b)
	{
		warn_changes_in_resolve = b;
	}

	public static ConfigurationInfo getWarnChangesInResolveInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-class-is-sealed' option
    //

	private boolean warn_class_is_sealed = false;

	public boolean warn_class_is_sealed()
	{
		return warn_class_is_sealed;
	}

	public void cfgWarnClassIsSealed(ConfigurationValue cv, boolean b)
	{
		warn_class_is_sealed = b;
	}

	public static ConfigurationInfo getWarnClassIsSealedInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-const-not-initialized' option
    //

	private boolean warn_const_not_initialized = true;

	public boolean warn_const_not_initialized()
	{
		return warn_const_not_initialized;
	}

	public void cfgWarnConstNotInitialized(ConfigurationValue cv, boolean b)
	{
		warn_const_not_initialized = b;
	}

	public static ConfigurationInfo getWarnConstNotInitializedInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-constructor-returns-value' option
    //

	private boolean warn_constructor_returns_value = false;

	public boolean warn_constructor_returns_value()
	{
		return warn_constructor_returns_value;
	}

	public void cfgWarnConstructorReturnsValue(ConfigurationValue cv, boolean b)
	{
		warn_constructor_returns_value = b;
	}

	public static ConfigurationInfo getWarnConstructorReturnsValueInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-deprecated-event-handler-error' option
    //

	private boolean warn_deprecated_event_handler_error = false;

	public boolean warn_deprecated_event_handler_error()
	{
		return warn_deprecated_event_handler_error;
	}

	public void cfgWarnDeprecatedEventHandlerError(ConfigurationValue cv, boolean b)
	{
		warn_deprecated_event_handler_error = b;
	}

	public static ConfigurationInfo getWarnDeprecatedEventHandlerErrorInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-deprecated-function-error' option
    //

	private boolean warn_deprecated_function_error = false;

	public boolean warn_deprecated_function_error()
	{
		return warn_deprecated_function_error;
	}

	public void cfgWarnDeprecatedFunctionError(ConfigurationValue cv, boolean b)
	{
		warn_deprecated_function_error = b;
	}

	public static ConfigurationInfo getWarnDeprecatedFunctionErrorInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-deprecated-property-error' option
    //

	private boolean warn_deprecated_property_error = false;

	public boolean warn_deprecated_property_error()
	{
		return warn_deprecated_property_error;
	}

	public void cfgWarnDeprecatedPropertyError(ConfigurationValue cv, boolean b)
	{
		warn_deprecated_property_error = b;
	}

	public static ConfigurationInfo getWarnDeprecatedPropertyErrorInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-duplicate-argument-names' option
    //

	private boolean warn_duplicate_argument_names = true;

	public boolean warn_duplicate_argument_names()
	{
		return warn_duplicate_argument_names;
	}

	public void cfgWarnDuplicateArgumentNames(ConfigurationValue cv, boolean b)
	{
		warn_duplicate_argument_names = b;
	}

	public static ConfigurationInfo getWarnDuplicateArgumentNamesInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-duplicate-variable-def' option
    //

	private boolean warn_duplicate_variable_def = true;

	public boolean warn_duplicate_variable_def()
	{
		return warn_duplicate_variable_def;
	}

	public void cfgWarnDuplicateVariableDef(ConfigurationValue cv, boolean b)
	{
		warn_duplicate_variable_def = b;
	}

	public static ConfigurationInfo getWarnDuplicateVariableDefInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-for-var-in-changes' option
    //

	private boolean warn_for_var_in_changes = false;

	public boolean warn_for_var_in_changes()
	{
		return warn_for_var_in_changes;
	}

	public void cfgWarnForVarInChanges(ConfigurationValue cv, boolean b)
	{
		warn_for_var_in_changes = b;
	}

	public static ConfigurationInfo getWarnForVarInChangesInfo()
	{
		return new AdvancedConfigurationInfo();
	}

    //
    // 'compiler.warn-import-hides-class' option
    //

	private boolean warn_import_hides_class = true;

	public boolean warn_import_hides_class()
	{
		return warn_import_hides_class;
	}

	public void cfgWarnImportHidesClass(ConfigurationValue cv, boolean b)
	{
		warn_import_hides_class = b;
	}

	public static ConfigurationInfo getWarnImportHidesClassInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-instance-of-changes' option
    //

	private boolean warn_instance_of_changes = true;

	public boolean warn_instance_of_changes()
	{
		return warn_instance_of_changes;
	}

	public void cfgWarnInstanceOfChanges(ConfigurationValue cv, boolean b)
	{
		warn_instance_of_changes = b;
	}

	public static ConfigurationInfo getWarnInstanceOfChangesInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-internal-error' option
    //

	private boolean warn_internal_error = true;

	public boolean warn_internal_error()
	{
		return warn_internal_error;
	}

	public void cfgWarnInternalError(ConfigurationValue cv, boolean b)
	{
		warn_internal_error = b;
	}

	public static ConfigurationInfo getWarnInternalErrorInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-level-not-supported' option
    //

	private boolean warn_level_not_supported = false;

	public boolean warn_level_not_supported()
	{
		return warn_level_not_supported;
	}

	public void cfgWarnLevelNotSupported(ConfigurationValue cv, boolean b)
	{
		warn_level_not_supported = b;
	}

	public static ConfigurationInfo getWarnLevelNotSupportedInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-missing-namespace-decl' option
    //

	private boolean warn_missing_namespace_decl = true;

	public boolean warn_missing_namespace_decl()
	{
		return warn_missing_namespace_decl;
	}

	public void cfgWarnMissingNamespaceDecl(ConfigurationValue cv, boolean b)
	{
		warn_missing_namespace_decl = b;
	}

	public static ConfigurationInfo getWarnMissingNamespaceDeclInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-negative-uint-literal' option
    //

	private boolean warn_negative_uint_literal = true;

	public boolean warn_negative_uint_literal()
	{
		return warn_negative_uint_literal;
	}

	public void cfgWarnNegativeUintLiteral(ConfigurationValue cv, boolean b)
	{
		warn_negative_uint_literal = b;
	}

	public static ConfigurationInfo getWarnNegativeUintLiteralInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-no-constructor' option
    //

	private boolean warn_no_constructor = true;

	public boolean warn_no_constructor()
	{
		return warn_no_constructor;
	}

	public void cfgWarnNoConstructor(ConfigurationValue cv, boolean b)
	{
		warn_no_constructor = b;
	}

	public static ConfigurationInfo getWarnNoConstructorInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-no-explicit-super-call-in-constructor' option
    //

	private boolean warn_no_explicit_super_call_in_constructor = false;

	public boolean warn_no_explicit_super_call_in_constructor()
	{
		return warn_no_explicit_super_call_in_constructor;
	}

	public void cfgWarnNoExplicitSuperCallInConstructor(ConfigurationValue cv, boolean b)
	{
		warn_no_explicit_super_call_in_constructor = b;
	}

	public static ConfigurationInfo getWarnNoExplicitSuperCallInConstructorInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-no-type-decl' option
    //

	private boolean warn_no_type_decl = true;

	public boolean warn_no_type_decl()
	{
		return warn_no_type_decl;
	}

	public void cfgWarnNoTypeDecl(ConfigurationValue cv, boolean b)
	{
		warn_no_type_decl = b;
	}

	public static ConfigurationInfo getWarnNoTypeDeclInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-number-from-string-changes' option
    //

	private boolean warn_number_from_string_changes = false;

	public boolean warn_number_from_string_changes()
	{
		return warn_number_from_string_changes;
	}

	public void cfgWarnNumberFromStringChanges(ConfigurationValue cv, boolean b)
	{
		warn_number_from_string_changes = b;
	}

	public static ConfigurationInfo getWarnNumberFromStringChangesInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-scoping-change-in-this' option
    //

	private boolean warn_scoping_change_in_this = false;

	public boolean warn_scoping_change_in_this()
	{
		return warn_scoping_change_in_this;
	}

	public void cfgWarnScopingChangeInThis(ConfigurationValue cv, boolean b)
	{
		warn_scoping_change_in_this = b;
	}

	public static ConfigurationInfo getWarnScopingChangeInThisInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-slow-text-field-addition' option
    //

	private boolean warn_slow_text_field_addition = true;

	public boolean warn_slow_text_field_addition()
	{
		return warn_slow_text_field_addition;
	}

	public void cfgWarnSlowTextFieldAddition(ConfigurationValue cv, boolean b)
	{
		warn_slow_text_field_addition = b;
	}

	public static ConfigurationInfo getWarnSlowTextFieldAdditionInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-unlikely-function-value' option
    //

	private boolean warn_unlikely_function_value = true;

	public boolean warn_unlikely_function_value()
	{
		return warn_unlikely_function_value;
	}

	public void cfgWarnUnlikelyFunctionValue(ConfigurationValue cv, boolean b)
	{
		warn_unlikely_function_value = b;
	}

	public static ConfigurationInfo getWarnUnlikelyFunctionValueInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
    // 'compiler.warn-xml-class-has-changed' option
    //

	private boolean warn_xml_class_has_changed = false;

	public boolean warn_xml_class_has_changed()
	{
		return warn_xml_class_has_changed;
	}

	public void cfgWarnXmlClassHasChanged(ConfigurationValue cv, boolean b)
	{
		warn_xml_class_has_changed = b;
	}

	public static ConfigurationInfo getWarnXmlClassHasChangedInfo()
	{
		return new AdvancedConfigurationInfo();
	}

	//
	// compiler.archive-classes-and-assets
	//

	private boolean archiveClassesAndAssets = false;

	public boolean archiveClassesAndAssets()
	{
		return archiveClassesAndAssets;
	}

	public void cfgArchiveClassesAndAssets(ConfigurationValue cv, boolean b)
	{
		archiveClassesAndAssets = b;
	}

	public static ConfigurationInfo getArchiveClassesAndAssetsInfo()
	{
		return new ConfigurationInfo()
		{
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
	// compiler.generate-abstract-syntax-tree
	//

	private boolean generateAbstractSyntaxTree = true;

	public void cfgGenerateAbstractSyntaxTree(ConfigurationValue cv, boolean b)
	{
		generateAbstractSyntaxTree = b;
	}

	public boolean getGenerateAbstractSyntaxTree()
	{
		return generateAbstractSyntaxTree;
	}

	public static ConfigurationInfo getGenerateAbstractSyntaxTreeInfo()
	{
		return new ConfigurationInfo()
		{
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
    // 'compiler.extensions.*' option
    //

    private ExtensionsConfiguration extensionsConfig;

    public ExtensionsConfiguration getExtensionsConfiguration()
    {
        return this.extensionsConfig;
    }

    //
    // 'compiler.isolateStyles' option
    //

    // Allow the user to decide if the compiled application/module should have its
    // own style manager. Turn off isolate styles for compatibility less than 4.0.
    private boolean isolateStyles = true;

    public boolean getIsolateStyles()
    {
        return isolateStyles &&
               (getCompatibilityVersion() >= flex2.compiler.common.MxmlConfiguration.VERSION_4_0);
    }

    public void cfgIsolateStyles( ConfigurationValue cv, boolean isolateStyles )
    {
        this.isolateStyles = isolateStyles;
    }

    public static ConfigurationInfo getIsolateStylesInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.allow-duplicate-style-declaration' option
    //

    // If true, a style manager will add style declarations to the local
    // style manager without checking to see if the parent already
    // has the same style selector with the same properties. If false,
    // a style manager will check the parent to make sure a style
    // with the same properties does not already exist before adding
    // one locally.
	// If there is no local style manager created for this application, 
    // then don't check for duplicates. Just use the old "selector exists" test. 
    private boolean allowDuplicateDefaultStyleDeclarations = false;

    public boolean getAllowDuplicateDefaultStyleDeclarations()
    {
    	if (getIsolateStyles())
    		return allowDuplicateDefaultStyleDeclarations;
    	else
    		return true;
    }

    public void cfgAllowDuplicateDefaultStyleDeclarations( ConfigurationValue cv, boolean allowDuplicateDefaultStyleDeclarations)
    {
        this.allowDuplicateDefaultStyleDeclarations = allowDuplicateDefaultStyleDeclarations;
    }

    public static ConfigurationInfo getAllowDuplicateDefaultStyleDeclarationsInfo()
    {
        return new AdvancedConfigurationInfo()
        {
			public boolean isHidden()
            {
                return true;
            }
        };
    }

    // 'compiler.java-profiler' option
	
    //  When set, the compiler will attempt to load the specified
    //  profiler class by name and use it as the profile event sink.
    private String javaProfilerClass = null;
    
    public void cfgJavaProfilerClass(ConfigurationValue cv, String profilerClass)
    {
        this.javaProfilerClass = profilerClass;
    }
    
    public String getJavaProfilerClass()
    {
        return this.javaProfilerClass;
    }
    
    public static ConfigurationInfo getJavaProfilerClassInfo()
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
    // 'compiler.advanced-telemetry' option
    //

    private boolean advancedTelemetry;

    public boolean getAdvancedTelemetry()
    {
        return advancedTelemetry;
    }

    public void setAdvancedTelemetry(boolean accessible)
    {
        this.advancedTelemetry = advancedTelemetry;
    }

    public void cfgAdvancedTelemetry( ConfigurationValue cv, boolean advancedTelemetry )
    {
        this.advancedTelemetry = advancedTelemetry;
    }
    
    @Override
    public Object clone()
        throws CloneNotSupportedException
    {
        return super.clone();
    }
    
    
    
}
