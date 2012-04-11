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

package flex2.linker;

import flex2.compiler.CompilationUnit;
import flex2.compiler.common.Configuration;
import flex2.compiler.io.FileUtil;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;
import flash.localization.LocalizationManager;
import flash.swf.Movie;

import java.util.List;

/**
 * Flex Linker API.
 *
 * @author Roger Gonzalez
 * @author Clement Wong
 */
public final class LinkerAPI
{
	/**
	 * Put the compilation units together.
	 *
	 * @throws LinkerException
	 */
	public static Movie link(List<CompilationUnit> units, PostLink postLink, Configuration configuration)
	    throws LinkerException
	{
	    FlexMovie movie = new FlexMovie( configuration );
	    movie.topLevelClass = FlexMovie.formatSymbolClassName( configuration.getRootClassName() );
	    movie.generate( units );
		if (ThreadLocalToolkit.getBenchmark() != null)
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new Linking()));
		}

		generateReports(configuration, movie);
		
		// perform post-link optimization...
		if (postLink != null)
		{
			postLink.run(movie);
			if (ThreadLocalToolkit.getBenchmark() != null)
			{
				LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
				ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new Optimizing()));
			}
		}

		return movie;
	}

	private static void generateReports(LinkerConfiguration linkerConfiguration, SimpleMovie movie)
	{
	    if (linkerConfiguration.generateLinkReport() && linkerConfiguration.getLinkReportFileName() != null)
	    {
	    	String fileName = linkerConfiguration.getLinkReportFileName();
	    	try
	    	{
	    		FileUtil.writeFile(fileName, movie.getLinkReport());
	    	}
	    	catch (Exception ex)
	    	{
		        ThreadLocalToolkit.log( new LinkerException.UnableToWriteLinkReport( fileName ) );
	    	}
	    }
	    if (linkerConfiguration.generateRBList() && linkerConfiguration.getRBListFileName() != null)
	    {
	    	String fileName = linkerConfiguration.getRBListFileName();
	    	try
	    	{
	    		FileUtil.writeFile(linkerConfiguration.getRBListFileName(), movie.getRBList());
	    	}
	    	catch (Exception ex)
	    	{
		        ThreadLocalToolkit.log( new LinkerException.UnableToWriteResourceBundleList( fileName ) );
	    	}
	    }
	}
	
	public static ConsoleApplication linkConsole(List<CompilationUnit> units, PostLink postLink, Configuration configuration)
		throws LinkerException
	{
		ConsoleApplication app = new ConsoleApplication(configuration);
	    app.generate( units );
	    if (ThreadLocalToolkit.getBenchmark() != null)
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new Linking()));
		}

		// perform post-link optimization...
		if (postLink != null)
		{
			postLink.run(app);
			if (ThreadLocalToolkit.getBenchmark() != null)
			{
				LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
				ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new Optimizing()));
			}
		}
	
		return app;
	}
	
	public static class Linking extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -6272039409403031493L;

        public Linking()
		{
			super();
		}
	}

	public static class Optimizing extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -455358216852519658L;

        public Optimizing()
		{
			super();
		}
	}
}
