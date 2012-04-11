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

import flash.util.FileUtils;
import flex2.compiler.CompilerAPI;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.ConfigurationPathResolver;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.ThreadLocalToolkit;

import java.io.File;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

/**
 * Support for command line specific configuration options, like
 * -file-specs, -help, -include-resource-bundles, -load-config,
 * -output, -projector, and -version.
 *
 * @author Roger Gonzalez
 * @author Clement Wong
 */
public class CommandLineConfiguration extends ToolsConfiguration
{
	private String resourceModulePath;

	public String getTargetFile()
	{
        if (compilingResourceModule())
		{
			return resourceModulePath;
		}
		
		return (fileSpecs.size() > 0) ? fileSpecs.get( fileSpecs.size() - 1 ) : null;
	}

	public List<String> getFileList()
	{
        if (compilingResourceModule())
		{
			List<String> fileList = new ArrayList<String>();
			fileList.add(resourceModulePath);
			return fileList;
		}

		return fileSpecs;
	}

	public boolean compilingResourceModule()
	{
		boolean b = fileSpecs.size() == 0 && getIncludeResourceBundles().size() > 0;
		if (b && resourceModulePath == null)
		{
			resourceModulePath = I18nUtils.getGeneratedResourceModule(this).getPath();
		}
		return b;
	}

	public void validate(ConfigurationBuffer cfgbuf) throws ConfigurationException
	{
        super.validate( cfgbuf );

        String targetFile = getTargetFile();
		if (targetFile == null)
		{
    	    throw new ConfigurationException.MustSpecifyTarget( null, null, -1);
		}

        VirtualFile virt = getVirtualFile(targetFile);
        if (virt == null && checkTargetFileInFileSystem())
        {
            throw new ConfigurationException.IOError(targetFile);
        }
	}

	/**
	 * Subclass could override this method.
	 */
	protected VirtualFile getVirtualFile(String targetFile) throws ConfigurationException
	{
		return CompilerAPI.getVirtualFile(targetFile);
	}
	
	/**
	 * Subclass could override this method.
	 */
	protected boolean checkTargetFileInFileSystem()
	{
		return true;
	}
	
    private VirtualFile getVirtualFile(String file, ConfigurationValue cfgval)
    {
    	try
    	{
    		return ConfigurationPathResolver.getVirtualFile( file, configResolver, cfgval );
    	}
    	catch (ConfigurationException ex)
    	{
    		return null;
    	}
    }

    //
	// 'file-specs' option
	//
	
	// list of filespecs, default var for command line
	private List<String> fileSpecs = new ArrayList<String>();

	public List<String> getFileSpecs()
	{
		return fileSpecs;
	}

	public void cfgFileSpecs(ConfigurationValue cv, List<String> args) throws ConfigurationException
	{
		this.fileSpecs.addAll( args );
	}

    public static ConfigurationInfo getFileSpecsInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "path-element" } )
        {
            public boolean allowMultiple()
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
	// 'help' option
	//
	
    // dummy, just a trigger for help text
	public void cfgHelp(ConfigurationValue cv, String[] keywords)
	{

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
    // 'include-resource-bundles' option
    //
    
	private List<String> resourceBundles = new LinkedList<String>();

    public List<String> getIncludeResourceBundles()
	{
		return resourceBundles;
	}

	public void cfgIncludeResourceBundles(ConfigurationValue val, List<String> includeResourceBundles)
	{
		resourceBundles.addAll(toQNameString(includeResourceBundles));
	}

	public static ConfigurationInfo getIncludeResourceBundlesInfo()
	{
		return new ConfigurationInfo( -1, new String[] { "bundle" } )
		{
			public boolean allowMultiple()
			{
				return true;
			}
		};
	}
	
	//
	// 'load-config' option
	//
	
	private VirtualFile configFile;

	public VirtualFile getLoadConfig()
	{
		return configFile;
	}

	// dummy, ignored - pulled out of the buffer
	public void cfgLoadConfig(ConfigurationValue cv, String filename) throws ConfigurationException
	{
		// C: resolve the flex-config.xml path to a VirtualFile so incremental compilation can detect timestamp change.
		configFile = ConfigurationPathResolver.getVirtualFile(filename,
		                                                      configResolver,
		                                                      cv);
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
	// 'output' option
	//
	
	public void cfgOutput(ConfigurationValue val, String output) throws ConfigurationException
	{
        this.output = Configuration.getOutputPath(val, output);
	}

	public static ConfigurationInfo getOutputInfo()
	{
	    return new ConfigurationInfo(1, "filename")
	    {
	        public boolean isRequired()
	        {
	            return false;
	        }
	    };
	}

	//
	// 'projector' option (hidden)
	//
	
    private VirtualFile projector;

    public VirtualFile getProjector()
    {
        return projector;
    }

	public void cfgProjector( ConfigurationValue cfgval, String path )
	{
		projector = getVirtualFile(path, cfgval);
	}

    public static ConfigurationInfo getProjectorInfo()
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
	// 'version' option
	//
	
    // dummy, just a trigger for version info
    public void cfgVersion(ConfigurationValue cv, boolean dummy)
    {
        // intercepted upstream in order to allow version into to be printed even when required args are missing
    }

}
