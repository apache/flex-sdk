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

package flex2.tools.flexbuilder;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.io.FileUtil;
import flex2.tools.oem.Application;
import flex2.tools.oem.Configuration;
import flex2.tools.oem.LibraryCache;
import flex2.tools.oem.VirtualLocalFile;
import flex2.tools.oem.internal.OEMConfiguration;
import flex2.tools.oem.internal.OEMUtil;

/**
 * BuilderApplication is a subclass of flex2.tools.oem.Application. It
 * does not have new methods but it overrides Application.compile().
 * BuilderApplication.compile() processes the mxmlc command-line
 * arguments in BuilderConfiguration before calling super.compile().
 * The argument processing extracts the following arguments:
 * 
 * 1. dump-config: creates a File (absolute or relative to the current
 *    working directory) - same behavior as mxmlc.
 * 2. compiler.debug: calls Configuration.enableDebugging().
 * 3. compiler.accessible: calls Configuration.enableAccessibility().
 * 4. compiler.strict: calls Configuration.enableStrictChecking().
 * 5. help: do nothing.
 * 6. output: calls Application.setOutput(). The output is absolute or
 *    relative to the current working directory - same behavior as
 *    mxmlc.
 * 7. version: do nothing.
 * 8. warnings: calls Configuration.showActionScriptWarnings() /
 *    showBindingWarnings() / showDeprecatedWarnings() /
 *    showUnusedTypeSelectorWarnings().
 * 
 * No valid mxmlc command-line arguments should cause this argument
 * processing to fail. FB should expect the argument processing to be
 * consistent with mxmlc (including absolute and relative paths). Any
 * inconsistencies are considered Compiler API bugs. If the behavior
 * is the same but it's incorrect, it's considered a mxmlc
 * command-line parsing bug. The only two execeptions are -help and
 * -version. -help and -version will not do anything. FB should use F1
 * for help and `About Flex Builder' for showing compiler version.
 */
public class BuilderApplication extends Application
{
	public BuilderApplication(File file) throws FileNotFoundException
	{
		super(file);
	}
	
    public BuilderApplication(File file, LibraryCache cache) throws FileNotFoundException
    {
        super(file, cache);
    }
    
	public BuilderApplication(VirtualLocalFile file)
	{
		super(file);
	}
	
	public BuilderApplication(VirtualLocalFile[] files)
	{
		super(files);
    }		
	
	private BuilderConfiguration c;
	
	public Configuration getDefaultConfiguration()
	{
		return new BuilderConfiguration(super.getDefaultConfiguration());
	}

	public void setConfiguration(Configuration configuration)
	{
		if (configuration instanceof BuilderConfiguration)
		{
			c = (BuilderConfiguration) configuration;
			super.setConfiguration(c.configuration);
		}
		else
		{
			super.setConfiguration(configuration);
		}
	}
	
	public Configuration getConfiguration()
	{
		return c != null ? c : super.getConfiguration();
	}
	
	protected int compile(boolean incremental)
	{
		File dumpConfigFile = null;
		OEMConfiguration config = null;
		
        // step over special-cased configuration options:
        //     FlexBuilder exposes some compiler options as UI (such as a checkbox for accessibility)
        //     and other compiler options like -help have no meaning when used in FB (since you press F1...)
        //     FB serialzes these and gives it to us as a commandline in OEMConfiguration.extra
        //     So we need to parse those...
		if (c != null)
		{
			String[] args = c.extra;
			if (args != null && args.length > 0)
			{
				config = (OEMConfiguration) c.configuration;
				if (config != null)
				{
					ConfigurationBuffer cfgbuf = OEMUtil.getCommandLineConfigurationBuffer(OEMUtil.getLogger(getLogger(), null), resolver, args);
					if (cfgbuf == null)
					{
						return -1;
					}
					
					List positions = cfgbuf.getPositions();
					for (int i = 0, length = positions.size(); i < length; i++)
					{
						Object[] a = (Object[]) positions.get(i);
						String var = (String) a[0];
						
						if ("link-report".equals(var))
						{
							config.keepLinkReport(true);
						}
						else if ("compiler.debug".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								String debugPassword = cfgbuf.peekSimpleConfigurationVar("debug-password");
								if ("true".equals(value))
								{
									config.enableDebugging(true, debugPassword);
								}
								else if ("false".equals(value))
								{
									config.enableDebugging(false, debugPassword);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("compiler.verbose-stacktraces".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.enableVerboseStacktraces(true);
								}
								else if ("false".equals(value))
								{
									config.enableVerboseStacktraces(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}							
						}
						else if ("compiler.accessible".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.enableAccessibility(true);
								}
								else if ("false".equals(value))
								{
									config.enableAccessibility(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("compiler.strict".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.enableStrictChecking(true);
								}
								else if ("false".equals(value))
								{
									config.enableStrictChecking(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("help".equals(var))
						{
							// do nothing
						}
						else if ("output".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								setOutput(new File(value));
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("size-report".equals(var))
						{
							config.keepSizeReport(true);
						}
						else if ("version".equals(var))
						{
							// do nothing
						}
						else if ("warnings".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.showActionScriptWarnings(true);
									config.showBindingWarnings(true);
									config.showDeprecationWarnings(true);
									config.showUnusedTypeSelectorWarnings(true);
								}
								else if ("false".equals(value))
								{
									config.showActionScriptWarnings(false);
									config.showBindingWarnings(false);
									config.showDeprecationWarnings(false);
									config.showUnusedTypeSelectorWarnings(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("compiler.show-actionscript-warnings".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.showActionScriptWarnings(true);
								}
								else if ("false".equals(value))
								{
									config.showActionScriptWarnings(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("compiler.show-deprecation-warnings".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.showDeprecationWarnings(true);
								}
								else if ("false".equals(value))
								{
									config.showDeprecationWarnings(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
                        else if ("compiler.show-shadowed-device-font-warnings".equals(var))
                        {
                            try
                            {
                                String value = cfgbuf.peekSimpleConfigurationVar(var);
                                if ("true".equals(value))
                                {
                                    config.showShadowedDeviceFontWarnings(true);
                                }
                                else if ("false".equals(value))
                                {
                                    config.showShadowedDeviceFontWarnings(false);
                                }
                            }
                            catch (ConfigurationException ex)
                            {
                            }
                        }
                        else if ("compiler.show-binding-warnings".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.showBindingWarnings(true);
								}
								else if ("false".equals(value))
								{
									config.showBindingWarnings(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("compiler.show-unused-type-selector-warnings".equals(var))
						{
							try
							{
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(value))
								{
									config.showUnusedTypeSelectorWarnings(true);
								}
								else if ("false".equals(value))
								{
									config.showUnusedTypeSelectorWarnings(false);
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
					}

					config.setConfiguration(OEMUtil.trim(args, cfgbuf, excludes));
					// c.extra = null;
				}
			}
		}
		
		int result = super.compile(incremental);
		
		if (dumpConfigFile != null && config != null && config.cfgbuf != null)
		{
            try
            {
                String text = OEMUtil.formatConfigurationBuffer(config.cfgbuf);
            	FileUtil.writeFile(dumpConfigFile.getAbsolutePath(), text);
            }
            catch (Exception ex)
            {
            	ex.printStackTrace();
            }
		}
		
		return result;
	}
	
	private static final Set<String> excludes = new HashSet<String>();

	static
	{
		excludes.add("help");
		excludes.add("output");
		excludes.add("version");
		excludes.add("warnings");
		excludes.add("compiler.debug");
		excludes.add("compiler.profile");
		excludes.add("compiler.accessible");
		excludes.add("compiler.strict");
		excludes.add("compiler.show-actionscript-warnings");		
		excludes.add("compiler.show-unused-type-selector-warnings");
		excludes.add("compiler.show-deprecation-warnings");
        excludes.add("compiler.show-shadowed-device-font-warnings");
		excludes.add("compiler.show-binding-warnings");
		excludes.add("compiler.verbose-stacktraces");
	}
}
