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
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;

import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.swf.Movie;
import flash.swf.MovieDecoder;
import flash.swf.MovieEncoder;
import flash.swf.TagDecoder;
import flash.swf.TagEncoder;
import flash.util.Trace;
import flex2.compiler.common.DefaultsConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationFilter;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.io.FileUtil;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * The post-link optimizer as a command-line tool...
 * 
 * @author Clement Wong
 */
public class Optimizer
{
	public static void main(String[] args)
	{
        flex2.compiler.CompilerAPI.useAS3();

        // setup the path resolver
        flex2.compiler.CompilerAPI.usePathResolver();

        LocalizationManager l10n = new LocalizationManager();
        l10n.addLocalizer( new ResourceBundleLocalizer() );
        ThreadLocalToolkit.setLocalizationManager(l10n);
        
		flex2.compiler.CompilerAPI.useConsoleLogger();
 
		// create of list of options that we want. All the other options that 
		// we inherit will be filtered out.
		final String[] configVars = new String[]{"help", "version", "load-config", "input", "output",
											   "compiler.keep-as3-metadata", "compiler.debug"};
		Arrays.sort(configVars);
		ConfigurationBuffer cfgbuf = new ConfigurationBuffer(OptimizerConfiguration.class, 
				new HashMap<String, String>(),
				new ConfigurationFilter() {

			public boolean select(String name)
			{
				return Arrays.binarySearch(configVars, name) >= 0;
			}

		});
		
        cfgbuf.setDefaultVar("input");
        try
        {
        	DefaultsConfigurator.loadMinimumDefaults(cfgbuf);
	        OptimizerConfiguration configuration = (OptimizerConfiguration) Mxmlc.processConfiguration(
	                l10n, "optimizer", args, cfgbuf, OptimizerConfiguration.class, "input", true);

	        // user is not allowed to control "debug" and "optimize" settings so
	        // set them here.
    		configuration.setDebug(configuration.debug());
    		configuration.setOptimize(true);
	       
        	//OptimizerConfiguration configuration = (OptimizerConfiguration) processConfiguration(cfgbuf, args, l10n);
        	String input = configuration.getInput(), output = configuration.getOutput();
        	
        	File inputFile = FileUtil.openFile(input), outputFile = FileUtil.openFile(output);
        	if (inputFile.exists())
        	{
        		InputStream in = new BufferedInputStream(new FileInputStream(inputFile));
        		System.out.println(input + " (" + inputFile.length() + " bytes)");
        		
        		// decoder
        		Movie movie = new Movie();
        		TagDecoder tagDecoder = new TagDecoder(in);
        		MovieDecoder movieDecoder = new MovieDecoder(movie);
        		tagDecoder.parse(movieDecoder);

        		if (movie.version > 0) {
            		// optimize
            		flex2.tools.WebTierAPI.optimize(movie, configuration);

                    //TODO PERFORMANCE: A lot of unnecessary recopying and buffering here
            		// encode
            		TagEncoder handler = new TagEncoder();
            		MovieEncoder encoder = new MovieEncoder(handler);
            		encoder.export(movie, true);
            		ByteArrayOutputStream out = new ByteArrayOutputStream();
            		handler.writeTo(out);
            		
            		FileUtil.writeBinaryFile(output, out.toByteArray());
            		System.out.println(output + " (" + outputFile.length() + " bytes)");        			
        		}
        		else 
        		{
    				ThreadLocalToolkit.logError(l10n.getLocalizedTextString(new NotAValidSwfFile(inputFile.getAbsolutePath())));
        		}
        		
        	}
        }
        catch (ConfigurationException ex)
        {
            Mxmlc.processConfigurationException(ex, "optimizer");
        }
        catch (IOException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
        }
	}

    /**
     * A configuration which extends CommandLineConfiguration by
     * adding -input and -output.
     */
	public static class OptimizerConfiguration extends CommandLineConfiguration
	{
	    //
		// 'input' option
		//
		
		private String input = null;

		public String getInput()
		{
			return input;
		}

		public void cfgInput(ConfigurationValue val, String input) throws ConfigurationException
		{
	        this.input = input;
		}

		public static ConfigurationInfo getInputInfo()
		{
		    return new ConfigurationInfo(1, "filename")
		    {
		        public boolean isRequired()
		        {
		            return true;
		        }
		    };
		}

		//
		// 'output' option
		//
		
		private String output = "output.swf";
		
		public String getOutput()
		{
		    return output;
		}

		public void cfgOutput(ConfigurationValue val, String output) throws ConfigurationException
		{
	        this.output = output;
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

		/*
		 * Since we are filtering out a lot of command line options, we need to override validate to 
		 * keep it from throwing an exception.
		 * 
		 * (non-Javadoc)
		 * @see flex2.tools.CommandLineConfiguration#validate(flex2.compiler.config.ConfigurationBuffer)
		 */
		public void validate(ConfigurationBuffer cfgbuf) throws ConfigurationException
		{
			// nothing to validate
		}
		
		
	}
	
	public static class NotAValidSwfFile extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 4755466826283937173L;
        
        public String fileName;
		
		public NotAValidSwfFile(String fileName)
		{
			super();
			this.fileName = fileName;
		}
	}

}
