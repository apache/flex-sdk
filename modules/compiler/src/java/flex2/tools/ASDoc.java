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

import flex2.compiler.*;
import flex2.compiler.swc.SwcException;
import flex2.compiler.common.DefaultsConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.util.*;
import flash.localization.LocalizationManager;
import flash.localization.XLRLocalizer;
import flash.localization.ResourceBundleLocalizer;
import flash.util.Trace;

/**
 * The entry-point for ASDoc.
 *
 * @see flex2.compiler.asdoc.AsDocAPI
 * @author Brian Deitte
 */
public class ASDoc extends Tool
{
    public static void main(String[] args)
    {
	    asdoc(args);
	    System.exit(ThreadLocalToolkit.errorCount());
    }

	public static void asdoc(String[] args)
	{
		String outputStr = null, templatesPath = null;
		boolean keepXML = false;
        try
        {
	        flex2.compiler.CompilerAPI.useAS3();

            ConfigurationBuffer cfgbuf = new ConfigurationBuffer(ASDocConfiguration.class, ASDocConfiguration.getAliases());

            // setup the path resolver
	        flex2.compiler.CompilerAPI.usePathResolver();

            // set up for localizing messages
            LocalizationManager l10n = new LocalizationManager();
            l10n.addLocalizer( new XLRLocalizer() );
            l10n.addLocalizer( new ResourceBundleLocalizer() );
            ThreadLocalToolkit.setLocalizationManager( l10n );

            // setup a console-based logger...
	        flex2.compiler.CompilerAPI.useConsoleLogger();

            // process configuration
	        DefaultsConfigurator.loadASDocDefaults( cfgbuf );

	        // Setting defaultVar as "no-default-arg" - which is a nonexistent variable. 
	        // This is to avoid assertion errors when configurations are parsed.
	        ASDocConfiguration configuration = (ASDocConfiguration) Mxmlc.processConfiguration(
                l10n, "asdoc", args, cfgbuf, ASDocConfiguration.class, "no-default-arg");

            flex2.compiler.CompilerAPI.useConsoleLogger(true, true, configuration.getWarnings(), true);
            
	        if (configuration.benchmark())
	        {
		        flex2.compiler.CompilerAPI.runBenchmark();
	        }
	        else
	        {
		        flex2.compiler.CompilerAPI.disableBenchmark();
	        }

	        keepXML = configuration.keepXml();
	        outputStr = configuration.getOutput();
	        templatesPath = configuration.getTemplatesPath();

	        if (Trace.asdoc) System.out.println("Creating ASDoc_Config.xml");
	        flex2.compiler.asdoc.AsDocAPI.createASDocConfig(configuration);

	        if (Trace.asdoc) System.out.println("Creating overviews.xml");
	        flex2.compiler.asdoc.AsDocAPI.createOverviews(configuration);

	        if (Trace.asdoc) System.out.println("Creating toplevel.xml");
	        flex2.compiler.asdoc.AsDocAPI.createTopLevelXML(configuration, l10n);

	        if (Trace.asdoc) System.out.println("Creating toplevel_classes.xml");
	        flex2.compiler.asdoc.AsDocAPI.createTopLevelClassesXML(outputStr, templatesPath, configuration.isLenient());

	        if (! configuration.skipXsl())
	        {
		        if (Trace.asdoc) System.out.println("Create HTML pages");
		        flex2.compiler.asdoc.AsDocAPI.createHTML(outputStr, templatesPath, configuration);

		        if (Trace.asdoc) System.out.println("Copying files");
		        flex2.compiler.asdoc.AsDocAPI.copyFiles(outputStr, templatesPath);

		        ThreadLocalToolkit.log(new OutputMessage(outputStr));
	        }
        }
        catch (ConfigurationException ex)
        {
            displayStartMessage();
            Mxmlc.processConfigurationException(ex, "asdoc");
        }
        catch (CompilerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (SwcException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (Throwable t) // IOException, Throwable
        {
            if (Trace.error)
            {
                t.printStackTrace();
            }
        }
	    finally
        {
	        if (! keepXML && outputStr != null && templatesPath != null)
	        {
		        flex2.compiler.asdoc.AsDocAPI.removeXML(outputStr, templatesPath);
	        }

	        if (ThreadLocalToolkit.getBenchmark() != null)
	        {
		        ThreadLocalToolkit.getBenchmark().totalTime();
		        ThreadLocalToolkit.getBenchmark().peakMemoryUsage(true);
	        }

	        flex2.compiler.CompilerAPI.removePathResolver();
        }
    }

	public static void displayStartMessage()
	{
		LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
		System.out.println(l10n.getLocalizedTextString(new StartMessage(VersionInfo.buildMessage())));
	}

	public static class StartMessage extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -3402061641251926273L;

        public StartMessage(String buildMessage)
		{
			super();
			this.buildMessage = buildMessage;
		}

		public final String buildMessage;
	}

    public static class OutputMessage extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -482145457062841654L;
        
        public OutputMessage(String location)
        {
            this.location = location;
        }
	    public String location;
    }
    
    public static class ValidationMessage extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -482145457062841654L;
        
        public ValidationMessage(String file)
        {
            this.file = file;
        }
        public String file;
    }    
}

