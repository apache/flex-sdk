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
import flash.util.Trace;
import flex2.compiler.as3.SignatureExtension;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.config.FileConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.lang.reflect.Method;
import java.util.Iterator;

/**
 * Common base class for most tool specific configurations.
 */
public abstract class ToolsConfiguration extends Configuration
{
    public ToolsConfiguration()
    {
    }

    private VirtualFile licenseFile;

    public VirtualFile getLicenseFile()
    {
        return licenseFile;
    }

    private void processDeprecatedOptions(ConfigurationBuffer configurationBuffer)
    {
		for (Iterator i = configurationBuffer.getVarIterator(); i.hasNext(); )
		{
			String var = (String) i.next();
			ConfigurationInfo info = configurationBuffer.getInfo(var);
			if (info.isDeprecated() && configurationBuffer.getVar(var) != null)
			{
				CompilerMessage.CompilerWarning warning = info.getDeprecatedMessage();
				String replacement = info.getDeprecatedReplacement();
				String since = info.getDeprecatedSince();
				
				if (warning != null)
				{
					ThreadLocalToolkit.log(warning);
				}
				else
				{
					ThreadLocalToolkit.log(new DeprecatedConfigurationOption(var, replacement, since));
				}
			}
		}		
    }
    
    public static class DeprecatedConfigurationOption extends CompilerMessage.CompilerWarning
    {
    	private static final long serialVersionUID = 5523004100027677184L;

        public DeprecatedConfigurationOption(String var, String replacement, String since)
    	{
    		this.var = var;
    		this.replacement = replacement;
    		this.since = since;
    	}
    	
    	public final String var, replacement, since;
    }

	protected String output;

	public String getOutput()
    {
        return output;
    }

    abstract protected String getTargetFile();

    private String createOutputDirectory(ConfigurationBuffer configurationBuffer,
                                         String directory)
    {
        String result = directory;
        String parent =
            configurationBuffer.getToken(flex2.tools.oem.Configuration.DEFAULT_OUTPUT_DIRECTORY_TOKEN);
        
        if (parent == null)
        {
            String output = getOutput();

            if (output != null)
            {
                parent = (new File(output)).getParent();
            }
            else
            {
                // Fall back on the target file as a last resort.
                String targetFile = getTargetFile();

                if (targetFile != null)
                {
                    parent = (new File(targetFile)).getParent();
                }
            }
        }

        if (parent != null)
        {
            result = FileUtils.addPathComponents(parent, directory, File.separatorChar);
        }

        return result;
    }

	public void validate(ConfigurationBuffer configurationBuffer) throws ConfigurationException
    {
		// process the merged configuration buffer. right, can't just process the args.
		processDeprecatedOptions(configurationBuffer);

		// For Apache Flex there is no license check.
		
		// If license.jar is present, call flex.license.OEMLicenseService.getLicenseFilename().
//		try
//		{
//			Class oemLicenseServiceClass = Class.forName("flex.license.OEMLicenseService");
//			Method method = oemLicenseServiceClass.getMethod("getLicenseFilename", (Class[])null);
//			String licenseFileName = (String)method.invoke(null, (Object[])null);
//			licenseFile = configResolver.resolve(licenseFileName);
//		}
//		catch (Exception e)
//		{
//		}
//
//        if (Trace.license)
//        {
//            final String file = (licenseFile != null) ? licenseFile.getName() : "";
//            Trace.trace("ToolsConfiguration.validate: licenseFile = '" + file + "'");
//        }
        
	    // validate the -AS3, -ES and -strict settings
	    boolean strict = "true".equalsIgnoreCase(configurationBuffer.peekSimpleConfigurationVar(CompilerConfiguration.STRICT));
	    boolean as3 = "true".equalsIgnoreCase(configurationBuffer.peekSimpleConfigurationVar(CompilerConfiguration.AS3));
	    boolean es = "true".equalsIgnoreCase(configurationBuffer.peekSimpleConfigurationVar(CompilerConfiguration.ES));

	    if ((as3 && es) || (!as3 && !es))
	    {
		    throw new BadAS3ESCombination(as3, es);
	    }
	    else if (strict && es)
	    {
		    ThreadLocalToolkit.log(new BadESStrictCombination(es, strict));
	    }
        
        // if we're saving signatures to files and the directory is unset, use the default.
        final CompilerConfiguration compilerConfiguration = getCompilerConfiguration();

        validateKeepGeneratedSignatures(configurationBuffer, compilerConfiguration);
        validateKeepGeneratedActionScript(configurationBuffer, compilerConfiguration);
        validateDumpConfig(configurationBuffer);
    }

    private void validateDumpConfig(ConfigurationBuffer configurationBuffer)
        throws ConfigurationException
    {
        if (dumpConfigFile != null)
        {
            ThreadLocalToolkit.log(new Mxmlc.DumpConfig(dumpConfigFile));
            File f = new File(dumpConfigFile);
            // fixme - nuke the private string for the localization prefix...
            String text = FileConfigurator.formatBuffer(configurationBuffer, "flex-config",
                                                        ThreadLocalToolkit.getLocalizationManager(),
                                                        "flex2.configuration");
            try
            {
                PrintWriter out = new PrintWriter(new BufferedOutputStream(new FileOutputStream(f)));
                out.write(text);
                out.close();
            }
            catch (Exception e)
            {
                throw new ConfigurationException.IOError(dumpConfigFile);
            }
        }
    }

    private void validateKeepGeneratedSignatures(ConfigurationBuffer configurationBuffer,
                                                 CompilerConfiguration compilerConfiguration)
        throws ConfigurationException
    {
        if (compilerConfiguration.getKeepGeneratedSignatures())
        {
            String dir = compilerConfiguration.getSignatureDirectory();

            if (dir == null)
            {
                dir = createOutputDirectory(configurationBuffer, SignatureExtension.DEFAULT_SIG_DIR);
            }
            else if (!FileUtils.isAbsolute(new File(dir)))
            {
                dir = createOutputDirectory(configurationBuffer, dir);
            }

            assert dir != null;

            if (dir != null)
            {
                File file = new File(dir);
                file.mkdirs();
                compilerConfiguration.setSignatureDirectory(FileUtils.canonicalPath(file));
            }
        }
    }

    private void validateKeepGeneratedActionScript(ConfigurationBuffer configurationBuffer,
                                                 CompilerConfiguration compilerConfiguration)
    {
        if (compilerConfiguration.keepGeneratedActionScript())
        {
            String dir = compilerConfiguration.getGeneratedDirectory();

            if (dir == null)
            {
                dir = createOutputDirectory(configurationBuffer, "generated");
            }
            else if (!FileUtils.isAbsolute(new File(dir)))
            {
                dir = createOutputDirectory(configurationBuffer, dir);
            }

            assert dir != null;

            if (dir != null)
            {
                File file = new File(dir);
                file.mkdirs();
                compilerConfiguration.setGeneratedDirectory(FileUtils.canonicalPath(file));
            }
        }
    }

	public static class BadAS3ESCombination extends ConfigurationException
	{
	    private static final long serialVersionUID = 4418178171352281793L;

        public BadAS3ESCombination(boolean as3, boolean es)
	    {
	        super("");
		    this.as3 = as3;
		    this.es = es;
	    }

		public final boolean as3, es;
	}

	public static class BadESStrictCombination extends ConfigurationException
	{
	    private static final long serialVersionUID = 384624904213418743L;

        public BadESStrictCombination(boolean es, boolean strict)
	    {
	        super("");
		    this.es = es;
		    this.strict = strict;
	    }

		public final boolean es, strict;

		public String getLevel()
		{
		    return WARNING;
		}
	}
    
    //
    // 'warnings' option
    //
    
    private boolean warnings = true;
    
    public boolean getWarnings()
    {
        return warnings;
    }

    public void cfgWarnings(ConfigurationValue cv, boolean b)
    {
        warnings = b;
    }

    public static ConfigurationInfo getWarningsInfo()
    {
        return new ConfigurationInfo();
    }
    
    //
    // 'dump-config-file' option
    //

    private String dumpConfigFile = null;

    public String getDumpConfig()
    {
        return dumpConfigFile;
    }

    public void cfgDumpConfig(ConfigurationValue cv, String filename)
    {
        dumpConfigFile = Configuration.getOutputPath(cv, filename);
        // can't print here, we want to aggregate all the settings found and then print.
    }

    public static ConfigurationInfo getDumpConfigInfo()
    {
        return new ConfigurationInfo( 1, "filename" )
        {
            public boolean isAdvanced()
            {
                return true;
            }

            public boolean isDisplayed()
            {
                return false;
            }
        };
    }
}

