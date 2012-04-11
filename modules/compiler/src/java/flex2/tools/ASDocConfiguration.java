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

import flex2.compiler.CompilerAPI;
import flex2.compiler.common.Configuration;
import flex2.compiler.config.AdvancedConfigurationInfo;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.asdoc.PackagesConfiguration;
import flash.util.FileUtils;

import java.io.File;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * asdoc specific configuration.
 *
 * @author Brian Deitte
 */
public class ASDocConfiguration extends ToolsConfiguration
{
	private PackagesConfiguration packagesConfig = new PackagesConfiguration();

	public static Map<String, String> getAliases()
    {
        Map<String, String> map = new HashMap<String, String>();
        map.put( "o", "output" );
        map.put( "dc", "doc-classes" );
        map.put( "dn", "doc-namespaces" );
        map.put( "ds", "doc-sources" );
	    map.putAll(Configuration.getAliases());
		return map;
    }

	public void validate( ConfigurationBuffer cfgbuf ) throws ConfigurationException
    {
		super.validate(cfgbuf);
		
		String appHome = cfgbuf.getToken( "flexlib" );
	    File templatesPathFile;
	    if (templatesPath != null)
	    {
		    templatesPathFile = new File(templatesPath);
	    }
	    else
	    {
		    templatesPathFile = new File(appHome, "asdoc" + File.separator + "templates");
		    if (! templatesPathFile.isDirectory())
		    {
			    templatesPathFile = new File(appHome, ".." + File.separator + "asdoc" + File.separator + "templates");
		    }
	    }
	    if (! templatesPathFile.isDirectory())
	    {
		    throw new ConfigurationException.NotDirectory( templatesPath, null, null, -1 );
	    }
	    templatesPath = getFileStr(templatesPathFile);

	    File outputFile;
	    if (output != null)
	    {
		    outputFile = new File(output);
	    }
	    else
	    {
		    outputFile = new File(appHome, "asdoc-output");
	    }
	    outputFile.mkdirs();
	    if (outputFile.exists() && !outputFile.isDirectory())
	    {
		    throw new ConfigurationException.NotDirectory( output, null, null, -1 );
	    }
	    output = getFileStr(outputFile);

        if (getDocSources().isEmpty() && getClasses().isEmpty() && getNamespaces().isEmpty())
	    {
		    throw new ConfigurationException.NoASDocInputs();
        }

	    if (! getDocSources().isEmpty() && excludeDependencies)
	    {
		    throw new ConfigurationException.BadExcludeDependencies();
	    }	    
    }

	private String getFileStr(File file)
	{
		String str = file.getAbsolutePath();
	    if (! str.endsWith(File.separator))
	    {
		    str += File.separator;
	    }
		return str;
	}

	// FIXME: hide parameters from extended Configuration.
	// rework CommandLineConfiguration (or ConfigurationInfo setup?) to allow 'hidden' to be the default

	// FIXME: turn off warning/strict by default?  Not really useful, thought there was some case where it
	// was annoying when they were on.  Would need to change common.Configuration to make CompilerConfiguration
	// overridable (or change CompilerAPI.compileSwc?)

	//
	// 'doc-classes' option
	//
	
    private List classes = new LinkedList();

    public List getClasses()
    {
        return classes;
    }

    public void cfgDocClasses(ConfigurationValue cv, List args) throws ConfigurationException
    {
        classes.addAll( args );
    }

    public static ConfigurationInfo getDocClassesInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "class" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }

	//
	// 'doc-namespaces' option
	//
	
    private List namespaces = new LinkedList();

    public List getNamespaces()
	{
	    return namespaces;
	}

	public void cfgDocNamespaces(ConfigurationValue val, List DocNamespaces)
	{
	    namespaces.addAll(DocNamespaces);
	}

	public static ConfigurationInfo getDocNamespacesInfo()
	{
	    return new ConfigurationInfo( -1, new String[] { "uri" } )
	    {
	        public boolean allowMultiple()
	        {
	            return true;
	        }
	    };
	}

	//
	// 'doc-sources' option
	//
	
    private List sources = new LinkedList();

    public List getDocSources()
    {
        return sources;
    }

    public void cfgDocSources(ConfigurationValue cv, List args) throws ConfigurationException
    {
        sources.addAll( args );
    }

    public static ConfigurationInfo getDocSourcesInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "path-element" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isPath()
            {
                return true;
            }
        };
    }

	//
	// 'examples-path' option
	//
	
	private String examplesPath;

	public String getExamplesPath()
	{
		return examplesPath;
	}

	public void cfgExamplesPath(ConfigurationValue cv, String str) throws ConfigurationException
	{
		File file = new File(str);
		if (! file.isDirectory())
		{
			throw new ConfigurationException.NotDirectory( str, cv.getVar(), cv.getSource(), cv.getLine() );
		}
		examplesPath = file.getAbsolutePath().replace('\\', '/');
	}

	//
	// 'exclude-classes' option
	//
	
	private List excludeClasses = new LinkedList();

	public List getExcludeClasses()
	{
	    return excludeClasses;
	}

	public void cfgExcludeClasses(ConfigurationValue cv, List args) throws ConfigurationException
	{
	    excludeClasses.addAll( args );
	}

	public static ConfigurationInfo getExcludeClassesInfo()
	{
	    return new ConfigurationInfo( -1, new String[] { "class" } )
	    {
	        public boolean allowMultiple()
	        {
	            return true;
	        }
	    };
	}

	//
	// 'exclude-dependencies' option
	//
	
	private boolean excludeDependencies;

	public boolean excludeDependencies()
	{
		return excludeDependencies;
	}

	public void cfgExcludeDependencies(ConfigurationValue val, boolean bool)
	{
	    this.excludeDependencies = bool;
	}

	//
	// 'footer' option
	//
	
	private String footer;

	public String getFooter()
	{
		return footer;
	}

	public void cfgFooter(ConfigurationValue cv, String str) throws ConfigurationException
	{
		 footer = str;
	}

	//
	// 'help' option
	//
	
    // dummy, just a trigger for help text
    public void cfgHelp(ConfigurationValue cv, String[] keywords)
    {
        // intercepted upstream in order to allow help text to be printed even when args are otherwise bad
    }
    
    public static ConfigurationInfo getHelpInfo()
    {
        return new ConfigurationInfo( -1, "keyword" )
        {
            public boolean isGreedy()
			{
				return true;
			}

            public boolean isDisplayed()
			{
				return false;
			}
        };
    }
	//
	// 'keep-xml' option
	//
	
	private boolean keepXML;

	public boolean keepXml()
	{
		return keepXML;
	}

	public void cfgKeepXml(ConfigurationValue cv, boolean b) throws ConfigurationException
	{
		keepXML = b;
	}

	public static ConfigurationInfo getKeepXmlInfo()
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
	// 'left-frameset-width' option
	//
	
	private int leftFramesetWidth;

	public int getLeftFramesetWidth()
	{
		return leftFramesetWidth;
	}

	public void cfgLeftFramesetWidth(ConfigurationValue val, int left)
	{
		this.leftFramesetWidth = left;
	}

	//
	// 'load-config' p[topm
	//
	
    // dummy, ignored - pulled out of the buffer
    public void cfgLoadConfig(ConfigurationValue cv, String filename) throws ConfigurationException
    {
    }

    public static ConfigurationInfo getLoadConfigInfo()
    {
        return new ConfigurationInfo( 1, "filename" )
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }

	//
	// 'main-title' option
	//
	
	private String mainTitle;

	public String getMainTitle()
	{
		return mainTitle;
	}

	public void cfgMainTitle(ConfigurationValue cv, String str) throws ConfigurationException
	{
		 mainTitle = str;
	}

	//
	// 'output' option
	//
	
	private String output;

	public String getOutput()
    {
        return output;
    }

    public String getTargetFile()
    {
        return null;
    }

    public void cfgOutput(ConfigurationValue val, String str) throws ConfigurationException
    {
		if (str != null && (str.startsWith(File.separator) || str.startsWith("/") || FileUtils.isAbsolute(new File(str))))
		{
			output = str;
		}
		else if (val.getContext() != null)
        {
            output = FileUtils.addPathComponents( val.getContext(), str, File.separatorChar );
        }
        else
        {
            output = str;
        }
    }

    public static ConfigurationInfo getOutputInfo()
    {
        return new ConfigurationInfo(1, "filename")
        {
        };
    }

	//
	// 'packages.*' options
	//
	
	public PackagesConfiguration getPackagesConfiguration()
	{
		return packagesConfig;
	}
	
	//
	// 'package-description-file' option
	//
	private String packageDescriptionFile;

	public String getPackageDescriptionFile()
	{
		return packageDescriptionFile;
	}

	public void cfgPackageDescriptionFile(ConfigurationValue cv, String str) throws ConfigurationException
	{
		File file = new File(str);
		if (!file.exists() || file.isDirectory())
		{
			throw new ConfigurationException.NotAFile( str, cv.getVar(), cv.getSource(), cv.getLine() );
		}
		packageDescriptionFile = file.getAbsolutePath().replace('\\', '/');
	}	

	//
	// 'skip-xsl' option
	//
	
	private boolean skipXSL;

	public boolean skipXsl()
	{
		return skipXSL;
	}

	public void cfgSkipXsl(ConfigurationValue cv, boolean b) throws ConfigurationException
	{
		skipXSL = b;
	}

	public static ConfigurationInfo getSkipXslInfo()
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
	// 'templates-path' option
	//
	
	private String templatesPath;

	public String getTemplatesPath()
    {
        return templatesPath;
    }

    public void cfgTemplatesPath(ConfigurationValue val, String basedir) throws ConfigurationException
    {
        this.templatesPath = basedir;
    }

	//
	// 'version' option
	//
	
    // dummy, just a trigger for version info
    public void cfgVersion(ConfigurationValue cv, boolean dummy)
    {
        // intercepted upstream in order to allow version into to be printed even when required args are missing
    }

	//
	// 'window-title' option
	//
	
	private String windowTitle;

	public String getWindowTitle()
	{
		return windowTitle;
	}

	public void cfgWindowTitle(ConfigurationValue cv, String str) throws ConfigurationException
	{
		 windowTitle = str;
	}
	
	//
	// 'include-lookup-only' option
	//
	
	private boolean includeLookupOnly = false;

	public boolean getIncludeLookupOnly()
	{
		return includeLookupOnly;
	}

	/**
	 * include-lookup-only (hidden) if true, manifest entries with
	 * lookupOnly=true are included in SWC catalog. default is false.
	 * This exists only so that manifests can mention classes that
	 * come in from filespec rather than classpath, e.g. in
	 * playerglobal.swc.
     */
    /* 
     * TODO could make this a per-namespace setting. Or, if we modify
	 * catalog-builder to handle defs from filespecs, could remove it
	 * entirely.
	 */
	public void cfgIncludeLookupOnly(ConfigurationValue val, boolean includeLookupOnly)
	{
		this.includeLookupOnly = includeLookupOnly;
	}

	public static ConfigurationInfo getIncludeLookupOnlyInfo()
	{
		return new AdvancedConfigurationInfo();
	}
	
    //
    // 'restore-builtin-classes' option
    //
    
    private boolean restoreBuiltinClasses;

    public boolean restoreBuiltinClasses()
    {
        return restoreBuiltinClasses;
    }

    public void cfgRestoreBuiltinClasses(ConfigurationValue cv, boolean b) throws ConfigurationException
    {
        restoreBuiltinClasses = b;
    }

    // restore-builtin-classes is only for internal use
    public static ConfigurationInfo getRestoreBuiltinClassesInfo()
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
    // 'lenient' option
    //
    
    private boolean lenient;

    public boolean isLenient()
    {
        return lenient;
    }

    public void cfgLenient(ConfigurationValue cv, boolean b) throws ConfigurationException
    {
        lenient = b;
    }
    
    //
    // 'exclude-sources' option
    //
    
    private List excludeSources = new LinkedList();

    public List getExcludeSources()
    {
        return excludeSources;
    }

    public void cfgExcludeSources(ConfigurationValue cv, List args) throws ConfigurationException
    {
        excludeSources.addAll( args );
    }

    public static ConfigurationInfo getExcludeSourcesInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "path-element" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isPath()
            {
                return true;
            }
        };
    }

    //
    // 'date-in-footer' option
    //
    
    private boolean dateInFooter = true;

    public boolean getDateInFooter()
    {
        return dateInFooter;
    }

    public void cfgDateInFooter(ConfigurationValue cv, boolean b) throws ConfigurationException
    {
        dateInFooter = b;
    }
    
    //
    // 'include-all-for-asdoc' option
    //
    private boolean includeAllForAsdoc;

    public boolean isIncludeAllForAsdoc()
    {
        return includeAllForAsdoc;
    }

    public void cfgIncludeAllForAsdoc(ConfigurationValue cv, boolean b) throws ConfigurationException
    {
    	includeAllForAsdoc = b;
    }

    // include-all-only is only for internal use
    public static ConfigurationInfo getIncludeAllForAsdoc()
    {
        return new ConfigurationInfo()
        {
            public boolean isHidden()
            {
                return true;
            }
        };
    }    
}
