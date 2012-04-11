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
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.io.FileUtil;
import flex2.tools.oem.Configuration;
import flex2.tools.oem.Library;
import flex2.tools.oem.internal.OEMConfiguration;
import flex2.tools.oem.internal.OEMUtil;

/**
 * BuilderLibrary is a subclass of flex2.tools.oem.Library. It does
 * not have new methods but it overrides
 * Library.compile().BuilderLibrary.compile() processes the compc
 * command-line arguments in BuilderConfiguration before calling
 * super.compile().  The argument processing extraces the following
 * arguments:
 * 
 * 1.  dump-config: creates a File (absolute or relative to the
 *     current working directory) - same behavior as compc.
 * 2.  compiler.debug: calls Configuration.enableDebugging().
 * 3.  compiler.accessible: calls Configuration.enableAccessibility().
 * 4.  compiler.strict: calls Configuration.enableStrictChecking().
 * 5.  help: do nothing.
 * 6.  output/directory: calls Library.setOutput() if
 *     -directory=false. Calls Library.setDirectory if
 *     -directory=true. The output is absolute or relative to the
 *     current working directory) - same behavior as compc.
 * 7.  version: do nothing.
 * 8.  include-classes: calls Library.addComponent().
 * 9.  include-file: calls Library.addArchiveFile(). The file is
 *     absolute or relative to the current working directory - same
 *     behavior as compc.
 * 10. include-namespaces: calls Library.addComponent().
 * 11. include-resource-bundles: calls Library.addResourceBundle().
 * 12. include-sources: calls Library.addComponent().
 * 
 * No valid compc command-line arguments should cause this argument
 * processing to fail. FB should expect the argument processing to be
 * consistent with compc (including absolute and relative paths). Any
 * inconsistencies are considered Compiler API bugs. If the behavior
 * is the same but it's incorrect, it's considered a compc
 * command-line parsing bug. The only two execeptions are -help and
 * -version. -help and -version will not do anything. FB should use F1
 * for help and `About Flex Builder' for showing compiler version.
 */
public class BuilderLibrary extends Library
{
	public BuilderLibrary()
	{
		super();
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
					ConfigurationBuffer cfgbuf = OEMUtil.getCompcConfigurationBuffer(OEMUtil.getLogger(getLogger(), null), resolver, args);
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
								String isDirectory = cfgbuf.peekSimpleConfigurationVar("directory");
								String value = cfgbuf.peekSimpleConfigurationVar(var);
								if ("true".equals(isDirectory))
								{
									setDirectory(new File(value));
								}
								else
								{
									setOutput(new File(value));
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("size-report".equals(var))
						{
							config.keepSizeReport(true);
						}
						else if ("directory".equals(var))
						{
							// do nothing
						}
						else if ("version".equals(var))
						{
							// do nothing
						}
						else if ("include-classes".equals(var))
						{
							try
							{
								List l = cfgbuf.peekConfigurationVar(var);
								for (int j = 0, len = l == null ? 0 : l.size(); j < len; j++)
								{
									ConfigurationValue val = (ConfigurationValue) l.get(j);
									List valArgs = val.getArgs();
									for (int k = 0, size = valArgs == null ? 0 : valArgs.size(); k < size; k++)
									{
										this.addComponent((String) valArgs.get(k));
									}
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("include-file".equals(var))
						{
							try
							{
								List l = cfgbuf.peekConfigurationVar(var);
								for (int j = 0, len = l == null ? 0 : l.size(); j < len; j++)
								{
									ConfigurationValue val = (ConfigurationValue) l.get(j);
									List valArgs = val.getArgs();
									this.addArchiveFile((String) valArgs.get(0), new File((String) valArgs.get(1))); 
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("include-namespaces".equals(var))
						{
							try
							{
								List l = cfgbuf.peekConfigurationVar(var);
								for (int j = 0, len = l == null ? 0 : l.size(); j < len; j++)
								{
									ConfigurationValue val = (ConfigurationValue) l.get(j);
									List valArgs = val.getArgs();
									for (int k = 0, size = valArgs == null ? 0 : valArgs.size(); k < size; k++)
									{
										try
										{
											this.addComponent(new URI((String) valArgs.get(k)));
										}
										catch (URISyntaxException ex)
										{
											ex.printStackTrace();
										}
									}
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("include-resource-bundles".equals(var))
						{
							try
							{
								List l = cfgbuf.peekConfigurationVar(var);
								for (int j = 0, len = l == null ? 0 : l.size(); j < len; j++)
								{
									ConfigurationValue val = (ConfigurationValue) l.get(j);
									List valArgs = val.getArgs();
									for (int k = 0, size = valArgs == null ? 0 : valArgs.size(); k < size; k++)
									{
										this.addResourceBundle((String) valArgs.get(k));
									}
								}
							}
							catch (ConfigurationException ex)
							{
							}
						}
						else if ("include-sources".equals(var))
						{
							try
							{
								List l = cfgbuf.peekConfigurationVar(var);
								for (int j = 0, len = l == null ? 0 : l.size(); j < len; j++)
								{
									ConfigurationValue val = (ConfigurationValue) l.get(j);
									List valArgs = val.getArgs();
									for (int k = 0, size = valArgs == null ? 0 : valArgs.size(); k < size; k++)
									{
										this.addComponent(new File((String) valArgs.get(k)));
									}
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
		excludes.add("directory");
		excludes.add("help");
		excludes.add("include-classes");
		excludes.add("include-file");
		excludes.add("include-namespaces");
		excludes.add("include-resource-bundles");
		excludes.add("include-sources");
		excludes.add("output");
		excludes.add("version");
		excludes.add("compiler.debug");
		excludes.add("compiler.profile");
		excludes.add("compiler.accessible");
		excludes.add("compiler.strict");
		excludes.add("compiler.verbose-stacktraces");
	}
}
