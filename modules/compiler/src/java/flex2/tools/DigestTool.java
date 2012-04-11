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

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;

import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.localization.XLRLocalizer;
import flash.util.Trace;
import flex2.compiler.config.CommandLineConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.swc.Digest;
import flex2.compiler.swc.Swc;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.swc.SwcException;
import flex2.compiler.swc.SwcGroup;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * Given the path to a file and a swc, update the digest xml in catalog.xml of the swc
 * with the new digest of the file.
 * 
 * @author dloverin
 *
 */
public class DigestTool extends Tool
{
	static private final String PROGRAM_NAME = "digest";

	/**
	 * @param args
	 */
	public static void main(String[] args)
	{
	    digestTool(args);
	    System.exit(ThreadLocalToolkit.errorCount());

	}

	private static void digestTool(String[] args)
	{
		
        ConfigurationBuffer cfgbuf = new ConfigurationBuffer(DigestRootConfiguration.class, 
           													 DigestConfiguration.getAliases());
        try
        {
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
	        loadDefaults(cfgbuf);
	        
	        DigestRootConfiguration rootConfiguration = processConfiguration(cfgbuf, args, l10n);
	        
	        DigestConfiguration configuration = rootConfiguration.getDigestConfiguration();

	        // load SWC
            SwcCache cache = null;
    		File libraryFile = null;
            BufferedInputStream libraryInput = null;
	        try 
	        {
	        	cache = new SwcCache();
	        	libraryFile = configuration.getRslFile();
	        	libraryInput = new BufferedInputStream(new FileInputStream(libraryFile));
	        	
	            String[] paths = {configuration.getSwcPath()};
	            SwcGroup group = cache.getSwcGroup(paths);
	            
	            // calculate hash of file and update the catalog.
	        	long fileLength = libraryFile.length();
	        	
	        	if (fileLength > Integer.MAX_VALUE)
	        	{
	        		throw new ConfigurationException.FileTooBig(libraryFile.getAbsolutePath(),
	        													"rsl-file", null, 0);
	        	}
	        	
	            byte[] fileBytes = new byte[(int)fileLength];
	            libraryInput.read(fileBytes);
	            
	            Digest digest = new Digest();
	            digest.computeDigest(fileBytes);
	            digest.setSigned(configuration.getSigned());
	            Swc[] swcs = group.getSwcs().values().toArray(new Swc[1]);
	            if (swcs.length != 1) 
	            {
	            	throw new IllegalStateException("expecting one swc file, found " + swcs.length); //$NON-NLS-1$
	            }
	            
	            Swc swc = swcs[0];
	            swc.setDigest(Swc.LIBRARY_SWF, digest);
	            
		        // export SWC
	            cache.export(swc);

	            //confirmation message
	            if (ThreadLocalToolkit.errorCount() == 0)
	            {
	            	ThreadLocalToolkit.log(new OutputMessage(swc.getLocation()));
	            }

	        }
	        finally
	        {
	        	if (libraryInput != null) 
	        	{
	        		libraryInput.close();
	        	}
	        }
	        
        }
        catch (ConfigurationException ex)
        {
            displayStartMessage();
            Mxmlc.processConfigurationException(ex, PROGRAM_NAME);
        }
        catch (SwcException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (Throwable t) // IOException, Throwable
        {
            ThreadLocalToolkit.logError(t.getMessage());
            if (Trace.error)
            {
                t.printStackTrace();
            }
        }
	    finally
        {
	        if (ThreadLocalToolkit.getBenchmark() != null)
	        {
		        ThreadLocalToolkit.getBenchmark().totalTime();
		        ThreadLocalToolkit.getBenchmark().peakMemoryUsage(true);
	        }

	        flex2.compiler.CompilerAPI.removePathResolver();
        }

	}

	private static void loadDefaults(ConfigurationBuffer cfgbuf) throws ConfigurationException
	{
		cfgbuf.setVar("digest.rsl-file", "", "defaults", -1);
		cfgbuf.setVar("digest.swc-path", "", "defaults", -1);
		cfgbuf.setVar("digest.signed", "false", "defaults", -1);
	}


	public static void displayStartMessage()
	{
		LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
		System.out.println(l10n.getLocalizedTextString(new StartMessage(VersionInfo.buildMessage())));
	}


	private static DigestRootConfiguration processConfiguration(ConfigurationBuffer cfgbuf, 
			String[] args, 
			LocalizationManager l10n)
	throws ConfigurationException
	{
		String defaultVar = "digest.rsl-file";

		CommandLineConfigurator.parse( cfgbuf, defaultVar, args);
		
        if (cfgbuf.getVar( "version" ) != null)
        {
            System.out.println(VersionInfo.buildMessage());
            System.exit(0);
        }
        
		Mxmlc.processHelp(cfgbuf, PROGRAM_NAME, defaultVar, l10n, args);
		DigestRootConfiguration configuration = new DigestRootConfiguration();
		cfgbuf.commit( configuration );

		return configuration;
	}


	public static class StartMessage extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -2440824621618753347L;

        public StartMessage(String buildMessage)
		{
			super();
			this.buildMessage = buildMessage;
		}

		public final String buildMessage;
	}

	
    public static class OutputMessage extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -5542944826672307954L;
        
        public OutputMessage(String location)
        {
            this.location = location;
        }
	    public String location;
    }
}
