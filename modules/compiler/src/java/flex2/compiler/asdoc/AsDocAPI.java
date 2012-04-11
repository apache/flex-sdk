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

package flex2.compiler.asdoc;

import flex2.tools.*;
import flex2.compiler.abc.AbcCompiler;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.HostComponentExtension;
import flex2.compiler.as3.binding.BindableExtension;
import flex2.compiler.as3.managed.ManagedExtension;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.CompilerAPI;
import flex2.compiler.CompilerException;
import flex2.compiler.Source;
import flex2.compiler.SourceList;
import flex2.compiler.SubCompiler;
import flex2.compiler.Transcoder;
import flex2.compiler.SourcePath;
import flex2.compiler.FileSpec;
import flex2.compiler.ResourceContainer;
import flex2.compiler.ResourceBundlePath;
import flex2.compiler.CompilerSwcContext;
import flex2.compiler.swc.SwcAPI;
import flex2.compiler.swc.SwcComponent;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.css.CssCompiler;
import flex2.compiler.fxg.FXGCompiler;
import flex2.compiler.i18n.I18nCompiler;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.MxmlCompiler;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage;

import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.File;
import java.io.FileFilter;
import java.io.FilenameFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;
import java.util.Arrays;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.Iterator;

import org.xml.sax.InputSource;

import javax.xml.parsers.SAXParserFactory;
import javax.xml.parsers.SAXParser;

import flash.util.Trace;
import flash.util.FileUtils;
import flash.localization.LocalizationManager;

/**
 * The API class for ASDoc.  A call to ASDoc has four main parts:
 * 1. parameter handling, which done outside of this class in ConfigurationBuffer as well as in createASDocConfig()
 *    and createOverviews()
 * 2. a call to asc and mxml compiler, done in createTopLevelXML()
 * 3. Breaks the toplevel.xml into multiple DITA xml files (one for each package)
 * 4. XSL processing, done in createHTML()
 * 
 * For parameter handling and calling asc, this class works in the same way that Mxmlc
 * and Compc do. Parameters go through the Flex configuration scheme and the ASC call uses
 * Flex's infastructure for compiling. The XSLT processing is done by calling
 * net.sf.saxon.Transform process.
 *
 * @author Brian Deitte
 */
public class AsDocAPI
{
    /**
     * Reads the ASDoc_Config_Base.xml from the templates folder and creates a temporary ASDoc_Config.xml in the outut folder.
     * 
     * @param config asdoc configuration
     * @throws CompilerException
     */
	public static void createASDocConfig(ASDocConfiguration config) throws CompilerException
	{
		String templatesPath = config.getTemplatesPath();
		String ditaPath = config.getOutput() + "tempdita" + File.separator;
		
		
		File ditaDir = new File(ditaPath);
		if(!ditaDir.exists()) {
			ditaDir.mkdirs();
		}
		
		BufferedWriter writer = null;
		Reader reader = null;
		try
		{
			writer = new BufferedWriter(new OutputStreamWriter(
                            new FileOutputStream(ditaPath + "ASDoc_Config.xml"), "UTF-8"));
			reader = new BufferedReader(new InputStreamReader(
                            new FileInputStream(templatesPath + "ASDoc_Config_Base.xml"), "UTF-8"));

			ASDocConfigHandler h = new ASDocConfigHandler(writer, config);
		    InputSource source = new InputSource(reader);

			SAXParserFactory factory = SAXParserFactory.newInstance();
			SAXParser parser = factory.newSAXParser();
		    parser.parse(source, h);
		}
		catch (Exception e)
		{
			if (Trace.error)
				e.printStackTrace();

			CompilerMessage c = new CouldNotCreate("ASDoc_Config.xml", e.getMessage());
			ThreadLocalToolkit.log(c);
			throw c;
		}
		finally
		{
			if (writer != null)
			{
				try { writer.close(); } catch(IOException ioe) {}
			}
			if (reader != null)
			{
				try { reader.close(); } catch(IOException ioe) {}
			}
		}
	}

	/**
	 * Reads the Overviews_Base.xml from the templates folder and creates a temporary overviews.xml in the output folder
	 * 
	 * @param config asdoc configuration
	 * @throws CompilerException
	 */
	public static void createOverviews(ASDocConfiguration config) throws CompilerException
	{
		String templatesPath = config.getTemplatesPath();
		String ditaPath = config.getOutput() + "tempdita" + File.separator;
		BufferedWriter writer = null;
		Reader reader = null;
		try
		{
			writer = new BufferedWriter(new FileWriter(ditaPath + "overviews.xml"));
			if(config.getPackageDescriptionFile() != null)
			{
				reader = new BufferedReader(new FileReader(config.getPackageDescriptionFile()));
			}
			else 
			{
				reader = new BufferedReader(new FileReader(templatesPath + "Overviews_Base.xml"));
			}

			OverviewsHandler h = new OverviewsHandler(writer, config);
			InputSource source = new InputSource(reader);

			SAXParserFactory factory = SAXParserFactory.newInstance();
		    SAXParser parser = factory.newSAXParser();
		    parser.parse(source, h);
		}
		catch (Exception e)
		{
			if (Trace.error)
				e.printStackTrace();

			CompilerMessage c = new CouldNotCreate("overviews.xml", e.getMessage());
			ThreadLocalToolkit.log(c);
			throw c;
		}
		finally
		{
			if (writer != null)
			{
				try { writer.close(); } catch(IOException ioe) {}
			}
			if (reader != null)
			{
				try { reader.close(); } catch(IOException ioe) {}
			}
		}
	}

	/** 
	 * This method reads the input asdoc configuration. The it uses helper methods to get the various compilers.
	 * It then adds the asdoc extension to the compiler which is used to generate the toplevel.xml file after 
	 * compiling the sources. 
	 * 
	 * @param configuration asdoc configuration
	 * @param l10n
	 * @throws ConfigurationException
	 * @throws CompilerException
	 */
	public static void createTopLevelXML(ASDocConfiguration configuration, LocalizationManager l10n)
			throws ConfigurationException, CompilerException
	{
		flex2.compiler.CompilerAPI.setupHeadless(configuration);
		
		// set to true so source file takes precedence over source from swc.
		flex2.compiler.CompilerAPI.setSkipTimestampCheck(true);

		String[] sourceMimeTypes = flex2.tools.WebTierAPI.getSourcePathMimeTypes();

		CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();

		// asdoc should always have -doc=true so that it emits doc info. If it is false force it back to true.
		if(!compilerConfig.doc())
		{
		    compilerConfig.cfgDoc(null, true);
		}
		
		// create a SourcePath...
		SourcePath sourcePath = new SourcePath(sourceMimeTypes, compilerConfig.allowSourcePathOverlap());
		sourcePath.addPathElements( compilerConfig.getSourcePath() );

		List<VirtualFile>[] array = flex2.compiler.CompilerAPI.getVirtualFileList(configuration.getDocSources(), java.util.Collections.<VirtualFile>emptySet(),
                new HashSet<String>(Arrays.asList(sourceMimeTypes)),
                sourcePath.getPaths(), configuration.getExcludeSources());		
		
		NameMappings mappings = flex2.compiler.CompilerAPI.getNameMappings(configuration);

		//	get standard bundle of compilers, transcoders
		Transcoder[] transcoders = flex2.tools.WebTierAPI.getTranscoders( configuration );
		flex2.compiler.SubCompiler[] compilers = getCompilers(compilerConfig, mappings, transcoders);

		// create a FileSpec... can reuse based on appPath, debug settings, etc...
		FileSpec fileSpec = new FileSpec(array[0], flex2.tools.WebTierAPI.getFileSpecMimeTypes(), false);

        // create a SourceList...
        SourceList sourceList = new SourceList(array[1], compilerConfig.getSourcePath(), null,
        									   flex2.tools.WebTierAPI.getSourceListMimeTypes(), false);

		ResourceContainer resources = new ResourceContainer();
		ResourceBundlePath bundlePath = new ResourceBundlePath(configuration.getCompilerConfiguration(), null);

		Map<String, Source> classes = new HashMap<String, Source>();
		List nsComponents = SwcAPI.setupNamespaceComponents(configuration.getNamespaces(), mappings,
                                                            sourcePath, sourceList, classes,
                                                            configuration.getIncludeLookupOnly(),
                                                            configuration.isIncludeAllForAsdoc());
		SwcAPI.setupClasses(configuration.getClasses(), sourcePath, sourceList, classes);

		// if exclude-dependencies is true, then we create a list of the only classes that we want to document
		Set<String> includeOnly = null;
		if (configuration.excludeDependencies())
		{
			includeOnly = new HashSet<String>();
			for (Iterator iterator = nsComponents.iterator(); iterator.hasNext();)
			{
				SwcComponent component = (SwcComponent)iterator.next();
				includeOnly.add(component.getClassName());
			}
			includeOnly.addAll(configuration.getClasses());
		}

		// set up the compiler extension which writes out toplevel.xml
		List excludeClasses = configuration.getExcludeClasses();
		Set packages = configuration.getPackagesConfiguration().getPackageNames();
		ASDocExtension asdoc = new ASDocExtension(excludeClasses, includeOnly, packages, configuration.restoreBuiltinClasses());
		As3Compiler asc = (flex2.compiler.as3.As3Compiler)compilers[0];
		asc.addCompilerExtension(asdoc);
		
		// IMPORTANT!!!! The HostComponentExtension must run before the BindableExtension!!!!
		asc.addCompilerExtension(new HostComponentExtension(configuration.getCompilerConfiguration().reportMissingRequiredSkinPartsAsWarnings()) );
		
		String gendir = (compilerConfig.keepGeneratedActionScript()? compilerConfig.getGeneratedDirectory() : null);
		asc.addCompilerExtension(new BindableExtension(gendir, compilerConfig.getGenerateAbstractSyntaxTree(),true) );
		asc.addCompilerExtension(new ManagedExtension(gendir, compilerConfig.getGenerateAbstractSyntaxTree(),true) );

		((flex2.compiler.mxml.MxmlCompiler)compilers[1]).addImplementationCompilerExtension(asdoc);

		if (ThreadLocalToolkit.getBenchmark() != null)
		{
			ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new flex2.tools.Mxmlc.InitialSetup()));
		}

		// load SWCs
		CompilerSwcContext swcContext = new CompilerSwcContext();
		SwcCache cache = new SwcCache();
		
		// lazy read should only be set by mxmlc/compc/asdoc
		cache.setLazyRead(true);
		// for asdoc the theme and include-libraries values have been purposely not passed in below.
		swcContext.load( compilerConfig.getLibraryPath(),
		                 compilerConfig.getExternalLibraryPath(),
		                 null,
		                 null,
						 mappings,
						 I18nUtils.getTranslationFormat(compilerConfig),
						 cache );
		configuration.addExterns( swcContext.getExterns() );

		// validate CompilationUnits in FileSpec and SourcePath
		flex2.compiler.CompilerAPI.validateCompilationUnits(fileSpec, sourceList, sourcePath, bundlePath,
                                                            resources, swcContext, null, configuration);

		Map licenseMap = configuration.getLicensesConfiguration().getLicenseMap();

		// we call compileSwc (and use CompcPreLink, both of which should probably be renamed) to "compile" ASDoc.
		// everything runs through the normal compilation route, but we discard all of the output other than
		// what ASDocExtension creates
		CompilerAPI.compile(fileSpec, sourceList, classes.values(), sourcePath, resources, bundlePath, swcContext,
                            mappings, configuration, compilers, new CompcPreLink(null, null, true), 
                            licenseMap, new ArrayList<Source>());

		asdoc.finish(configuration.restoreBuiltinClasses());
		asdoc.saveFile(new File(configuration.getOutput(), "toplevel.xml"));

		if (excludeClasses.size() != 0)
		{
			StringBuilder sb = new StringBuilder();
			for (Iterator iterator = excludeClasses.iterator(); iterator.hasNext();)
			{
				sb.append(' ');
				sb.append(iterator.next());
			}
			ThreadLocalToolkit.log(new NotFound("exclude-classes", sb.toString()));
		}

		if (packages.size() != 0)
		{
			StringBuilder sb = new StringBuilder();
			for (Iterator iterator = packages.iterator(); iterator.hasNext();)
			{
				sb.append(' ');
				sb.append(iterator.next());
			}

			ThreadLocalToolkit.log(new NotFound("packages", sb.toString()));
		}
	}

	/** 
	 * Helper method to get the various sub compilers (AS3, MXML, ABC, FXG, il8n, Css). 
	 * 
	 * @param compilerConfig
	 * @param mappings
	 * @param transcoders
	 * @return
	 */
	public static flex2.compiler.SubCompiler[] getCompilers(CompilerConfiguration compilerConfig, NameMappings mappings,
	                                                     Transcoder[] transcoders)
	{
		// support AS3
		As3Compiler asc = new As3Compiler(compilerConfig);
		
		// support MXML.. call constructor with processComments as true. 
		MxmlCompiler mxmlc = new MxmlCompiler(compilerConfig, compilerConfig,
		                             mappings, transcoders, true);

		// support ABC
		AbcCompiler abc = new AbcCompiler(compilerConfig);

        // support FXG
        FXGCompiler fxg = new FXGCompiler(compilerConfig, mappings);

		// support i18n (.properties)
		I18nCompiler prop = new I18nCompiler(compilerConfig, transcoders);

		// support CSS
		CssCompiler css = new CssCompiler(compilerConfig, transcoders, mappings);

		return new SubCompiler[]{asc, mxmlc, abc, fxg, prop, css};
	}

	/**
	 * This method is called to kick off the DITA generation process. 
	 * It uses the ASDocHelper class as entry point to DITA generation.
	 *  
	 * @param outputDir output directory
	 * @param templatesPath path to templates directory
	 * @param lenient boolean flag to represent whether to be lenient for HTML errors
	 * @throws CompilerException
	 */
	public static void createTopLevelClassesXML(String outputDir, String templatesPath, boolean lenient) throws CompilerException
	{
		try
		{
			AsDocHelper asDocHelp = new AsDocHelper(outputDir + "toplevel.xml",
					                     outputDir + "tempdita",
					                     outputDir,
					                     outputDir + "tempdita" + File.separator +  "ASDoc_Config.xml");
			asDocHelp.createTopLevelClasses(lenient);
		}
		catch (Throwable t)
		{
			t.printStackTrace();

			CompilerMessage c = new CouldNotCreate("toplevel.xml", t.getMessage());
			ThreadLocalToolkit.log(c);
			throw c;
		}
	}

	/** 
	 * This methods runs the various dita xml files through xslt processing. It uses 
	 * net.sf.saxon.Transform for xslt processing. The end result of this method is
	 * the final asdoc html.
	 * 
	 * @param outputDir output direcctory
	 * @param templatesDir templates directory
	 * @param config asdoc configuration
	 * @throws Exception
	 */
	public static void createHTML(String outputDir, String templatesDir, ASDocConfiguration config)
			throws Exception
	{
		// the XSL processing only works with forward slashes
		templatesDir = templatesDir.replace('\\', '/');
		String outputDitaDir = outputDir + "tempdita/";
		File indexTmp = new File(outputDir + "index.tmp");
		// 0_processHTML
		String inputFile = indexTmp.toString();
		while (inputFile.indexOf('\\') != -1)
		{
			inputFile = inputFile.replace('\\', '/');
		}

		try
		{
			// copy xslt files to tempdita
			copyFile(templatesDir + "all-classes.xslt", outputDitaDir  + "all-classes.xslt");
			copyFile(templatesDir + "all-index.xslt", outputDitaDir  + "all-index.xslt");
			copyFile(templatesDir + "asdoc-util.xslt", outputDitaDir  + "asdoc-util.xslt");
			copyFile(templatesDir + "ASDoc_terms.xml", outputDitaDir  + "ASDoc_terms.xml");
			
			copyFile(templatesDir + "class-files.xslt", outputDitaDir  + "class-files.xslt");
			copyFile(templatesDir + "class-list.xslt", outputDitaDir  + "class-list.xslt");
			copyFile(templatesDir + "class-parts.xslt", outputDitaDir  + "class-parts.xslt");
			copyFile(templatesDir + "class-summary.xslt", outputDitaDir  + "class-summary.xslt");
			copyFile(templatesDir + "Classes.xslt", outputDitaDir  + "Classes.xslt");
			copyFile(templatesDir + "ClassHeader.xslt", outputDitaDir  + "ClassHeader.xslt");
			
			copyFile(templatesDir + "eventsGeneratedSummary.xslt", outputDitaDir  + "eventsGeneratedSummary.xslt");
			copyFile(templatesDir + "effectsSummary.xslt", outputDitaDir  + "effectsSummary.xslt");
			
			copyFile(templatesDir + "fieldSummary.xslt", outputDitaDir  + "fieldSummary.xslt");
			
			copyFile(templatesDir + "merge_dita_xml.xslt", outputDitaDir  + "merge_dita_xml.xslt");
			copyFile(templatesDir + "methodSummary.xslt", outputDitaDir  + "methodSummary.xslt");
			
			copyFile(templatesDir + "processHTML.xslt", outputDitaDir  + "processHTML.xslt");
			copyFile(templatesDir + "PostProcessing.xslt", outputDitaDir  + "PostProcessing.xslt");
			copyFile(templatesDir + "package-list.xslt", outputDitaDir  + "package-list.xslt");
			copyFile(templatesDir + "package-detail.xslt", outputDitaDir  + "package-detail.xslt");
			copyFile(templatesDir + "package-summary.xslt", outputDitaDir  + "package-summary.xslt");
			copyFile(templatesDir + "package.xslt", outputDitaDir  + "package.xslt");
			
			copyFile(templatesDir + "stylesSummary.xslt", outputDitaDir  + "stylesSummary.xslt");
			
			copyFile(templatesDir + "index.html", outputDitaDir  + "index.html");
			copyFile(templatesDir + "package-frame.html", outputDitaDir  + "package-frame.html");
			copyFile(templatesDir + "title-bar.html", outputDitaDir  + "title-bar.html");
		
			// warnings:silent|recover
			String warnings = "silent";
			
			//process_html_dita
			String[] args = new String[] { "-s", outputDitaDir + "index.html",
					"-o",  inputFile,
                   "-xsl", outputDitaDir + "processHTML.xslt",
                   "index-file=index.html",
                   "prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);
			
			args = new String[] { "-s", outputDitaDir + "package-frame.html",
					"-o", outputDir + "package-frame.html",
					"-xsl", outputDitaDir + "processHTML.xslt",
					"package-frame=package-frame.html",
					"prog_language_name=ActionScript"};
			net.sf.saxon.Transform.main(args);
			
			args = new String[] { "-s", templatesDir + "index-list.html",
					"-o", outputDir + "index-list.html",
					"-xsl", outputDitaDir + "processHTML.xslt" };
			net.sf.saxon.Transform.main(args);
			
			args = new String[] { "-s", outputDitaDir + "title-bar.html",
					"-o", outputDir + "title-bar.html",
					"-xsl", outputDitaDir + "processHTML.xslt",
					"titleBarFile=title-bar.html",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);
			
			//create_merge_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-o", outputDitaDir + "packagemap.xml",
					"-xsl", outputDitaDir + "merge_dita_xml.xslt" };
			net.sf.saxon.Transform.main(args);

			//create_classes_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-o", outputDitaDir + "Classes.xml",
					"-xsl", outputDitaDir + "Classes.xslt" };
			net.sf.saxon.Transform.main(args);

			//create_classheader_xml
			args = new String[] { "-s", outputDitaDir  + "Classes.xml",
					"-o", outputDitaDir + "ClassHeader.xml",
					"-xsl", outputDitaDir + "ClassHeader.xslt" };
			net.sf.saxon.Transform.main(args);

			//create_fieldSummary_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-o", outputDitaDir + "pp_fieldSummary.xml",
					"-warnings:" + warnings,
					"-xsl", outputDitaDir + "fieldSummary.xslt"};
			net.sf.saxon.Transform.main(args);
			
			args = new String[] { "-s", outputDitaDir  + "pp_fieldSummary.xml",
					"-warnings:" + warnings,
					"-o", outputDitaDir + "fieldSummary.xml",
					"-xsl", outputDitaDir + "PostProcessing.xslt" };
			net.sf.saxon.Transform.main(args);			
			//create_methodSummary_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDitaDir + "pp_methodSummary.xml",
					"-xsl", outputDitaDir + "methodSummary.xslt" };
			net.sf.saxon.Transform.main(args);
			
			args = new String[] { "-s", outputDitaDir  + "pp_methodSummary.xml",
					"-warnings:" + warnings,
					"-o", outputDitaDir + "methodSummary.xml",
					"-xsl", outputDitaDir + "PostProcessing.xslt" };
			net.sf.saxon.Transform.main(args);			

			//create_eventsGeneratedSummary_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDitaDir + "eventsGeneratedSummary.xml",
					"-xsl", outputDitaDir + "eventsGeneratedSummary.xslt" };
			net.sf.saxon.Transform.main(args);

			//create_stylesSummary_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDitaDir + "stylesSummary.xml",
					"-xsl", outputDitaDir + "stylesSummary.xslt" };
			net.sf.saxon.Transform.main(args);
			
			//create_effectsSummary_dita_xml
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDitaDir + "effectsSummary.xml",
					"-xsl", outputDitaDir + "effectsSummary.xslt" };
			net.sf.saxon.Transform.main(args);
			
			//create_class_files_dita
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDir + "dummy.html",
					"-xsl", outputDitaDir + "class-files.xslt",
					"showIncludeExamples=true",
					"prog_language_name=ActionScript",
					"process_xref_href_attribute=1"};
			net.sf.saxon.Transform.main(args);

			//create_all_classes_dita
			args = new String[] { "-s", outputDitaDir  + "packagemap.xml",
					"-warnings:" + warnings,
					"-o", outputDir + "all-classes.html",
					"-xsl", outputDitaDir + "all-classes.xslt",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);			

			//create_package_list_dita
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDir + "package-list.html",
					"-xsl", outputDitaDir + "package-list.xslt" };
			net.sf.saxon.Transform.main(args);			

			//create_class_summary_dita
			args = new String[] { "-s", outputDitaDir  + "packagemap.xml",
					"-warnings:" + warnings,
					"-o", outputDir + "class-summary.html",
					"-xsl", outputDitaDir + "class-summary.xslt",
					"localTitle=allClasses",
					"filter=*" };
			net.sf.saxon.Transform.main(args);			
			
			//create_package_detail_dita
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDir + "dummy.html",
					"-xsl", outputDitaDir + "package-detail.xslt",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);			
			
			//create_package_summary_dita
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDir + "package-summary.html",
					"-xsl", outputDitaDir + "package-summary.xslt",
					"localTitle=allPackages",
					"filter=*",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);			
			
			//create_class_list_dita
			args = new String[] { "-s", outputDitaDir  + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDir + "dummy.html",
					"-xsl", outputDitaDir + "class-list.xslt",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);			
			

			//create_all_index_dita
			args = new String[] { "-s", outputDitaDir  + "packagemap.xml",
					"-warnings:" + warnings,
					"-o", outputDir + "dummy.html",
					"-xsl", outputDitaDir + "all-index.xslt",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);
			
			//create_package_dita
			args = new String[] { "-s", outputDitaDir + "packages.dita",
					"-warnings:" + warnings,
					"-o", outputDir + "dummy.html",
					"-xsl", outputDitaDir + "package.xslt",
					"prog_language_name=ActionScript" };
			net.sf.saxon.Transform.main(args);			

			(new File(outputDir + "dummy.html")).delete();
		}
		catch(Exception ex) 
		{
			ex.printStackTrace();
			throw ex;
		}
		

		File indexHtml = new File(outputDir + "index.html");
		if (config.getLeftFramesetWidth() == -1)
		{
			// we can't just originally name this as index.html because then the renaming in the other
			// case fails (because of Java)
			FileUtils.renameFile(indexTmp, indexHtml);
		}
		else
		{
			// here we do something that doesn't fit well into XSL, which is replacing the first frameset
			// value we find in index.html

			BufferedReader reader = null;
			BufferedWriter writer = null;
			File indexTmp2 = new File(outputDir + "index2.tmp");
			try
			{
				reader = new BufferedReader(new FileReader(indexTmp));
				writer = new BufferedWriter(new FileWriter(indexTmp2));
				boolean foundFrameset = false;
				String s;
				String search1 = "frameset cols=";
				String search2 = ",";
				while ((s = reader.readLine()) != null)
				{
					if (! foundFrameset)
					{
						int ind = s.indexOf(search1);
						if (ind != -1)
						{
							foundFrameset = true;
							int ind2 = s.indexOf(search2, ind);
							if (ind2 != -1)
							{
								s = s.substring(0, ind + search1.length() + 1) + config.getLeftFramesetWidth() + s.substring(ind2);
							}
						}

					}
					writer.write(s);
					writer.newLine();
				}
			}
			catch (Exception ex)
			{
				ex.printStackTrace();

				CompilerMessage c = new CouldNotCreate("index.html", ex.getMessage());
				ThreadLocalToolkit.log(c);
				throw c;
			}
			finally
			{
				if (writer != null)
				{
					try { writer.close(); } catch(IOException ioe) {}
				}
				if (reader != null)
				{
					try { reader.close(); } catch(IOException ioe) {}
				}

				FileUtils.renameFile(indexTmp2, indexHtml);
			}
		}
	}

	/** 
	 * Helper method to copy various images, js, and css files file templates to the output folder.
	 * 
	 * @param outputDir output directory
	 * @param templatesPath templates folder
	 * @throws IOException
	 */
	public static void copyFiles(String outputDir, String templatesPath) throws IOException
	{
		File templateFile = new File(templatesPath);
		File[] temArr = templateFile.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name)
			{
				name = name.toLowerCase();
				return (name.endsWith(".js") || name.endsWith(".css"));
			}}
		);
		for (int i = 0; i < temArr.length; i++)
		{
			File f = temArr[i];
			copyFile(new File(templatesPath, f.getName()), new File(outputDir, f.getName()));
		}

		File outImages = new File(outputDir, "images");
		outImages.mkdir();

		File temImages = new File(templatesPath, "images");
		File[] imageArr = temImages.listFiles(new FileFilter() {
            public boolean accept(File f)
            {
                //does not accept hidden files or files that cannot be read or .* files
                if (f.getName().startsWith(".") || f.isHidden() || !f.canRead() || f.isDirectory())
                    return false;
                return true;
            }
        });
		for (int i = 0; i < imageArr.length; i++)
		{
			File f = imageArr[i];
			copyFile(new File(temImages, f.getName()), new File(outImages, f.getName()));
		}
	}

	/**
	 * Helper method to copy file to a new location
	 * 
	 * @param fromFile file to be copied
	 * @param toFile target location of the output file
	 * @throws IOException
	 */
	public static void copyFile(String fromFile, String toFile) throws IOException{
		copyFile(new File(fromFile), new File(toFile));
	}
	
	/**
     * Helper method to copy file to a new location
     * 
     * @param fromFile file to be copied
     * @param toFile target location of the output file
     * @throws IOException
     */
	public static void copyFile(File fromFile, File toFile) throws IOException
	{
	    FileInputStream fileInputStream = new FileInputStream( fromFile );
	    FileOutputStream fileOutputStream = new FileOutputStream( toFile );
	    int i;
	    byte bytes[] = new byte[ 2048 ];
	    while ( ( i = fileInputStream.read(bytes) ) != -1 )
	    {
	        fileOutputStream.write( bytes, 0, i );
	    }
	    fileInputStream.close();
	    fileOutputStream.close();
	}

	/** 
	 * method to clean up temporary files after the asdoc generation is complete. 
	 * It cleans up the dita xml files and out files that were copied from the templates folder.
	 * 
	 * @param outputDir
	 * @param templatesPath
	 */
	public static void removeXML(String outputDir, String templatesPath)
	{
		(new File(templatesPath + "ASDoc_Config.xml")).delete();
		(new File(templatesPath + "overviews.xml")).delete();
		(new File(outputDir + "index.tmp")).delete();
		(new File(outputDir + "index2.tmp")).delete();
		(new File(outputDir + "toplevel.xml")).delete();
		File outputDitaDir = new File(outputDir + "tempdita/");
		if(outputDitaDir.exists()) {
			File files[] = outputDitaDir.listFiles();
			for ( int ix=0; ix < files.length; ix++ ){
				files[ix].delete();
			}
			outputDitaDir.delete();
		}
	}

	/**
	 * Exception class used to get the localized error message when 
	 * a file can not be created. 
	 */
	public static class CouldNotCreate extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -6183856182026536203L;
        public CouldNotCreate(String file, String message)
		{
			super();
			this.file = file;
			this.message = message;
		}

		public String file;
		public String message;
	}

	/**
     * Exception class used to get the localized error message when 
     * a file can not be found. 
     */
	public static class NotFound extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = -1859901085068385739L;
        public NotFound(String property, String names)
		{
			super();
			this.property = property;
			this.names = names;
		}

		public String property;
		public String names;
	}
	

}
