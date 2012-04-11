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

import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.localization.XLRLocalizer;
import flash.swf.*;
import flex2.compiler.*;
import flex2.compiler.SourceList.UnsupportedFileType;
import flex2.compiler.ResourceBundlePath;
import flex2.compiler.abc.AbcCompiler;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.EmbedExtension;
import flex2.compiler.as3.SignatureExtension;
import flex2.compiler.as3.StyleExtension;
import flex2.compiler.as3.HostComponentExtension;
import flex2.compiler.as3.binding.BindableExtension;
import flex2.compiler.as3.SkinPartExtension;
import flex2.compiler.as3.managed.ManagedExtension;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.css.CssCompiler;
import flex2.compiler.fxg.FXGCompiler;
import flex2.compiler.i18n.I18nCompiler;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.media.*;
import flex2.compiler.mxml.MxmlCompiler;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * This class is used externally by the webtier compiler and
 * internally by some of the other flex tools, like fcsh and mxmlc.
 *
 * @author Clement Wong
 */
public final class WebTierAPI extends Tool
{
	/**
	 * This method is called by flex.webtier.server.j2ee.CompilerFilter.
	 */
	public static Target compile(VirtualFile targetFile, Configuration configuration, SwcCache swcCache, Map licenseMap)
		throws CompilerException
	{
		Target target = new Target();

		try
		{
			if (configuration.benchmark())
			{
				flex2.compiler.CompilerAPI.runBenchmark();
			}
			else
			{
				flex2.compiler.CompilerAPI.disableBenchmark();
			}

			target.configuration = configuration;

			flex2.compiler.CompilerAPI.useAS3();
			flex2.compiler.CompilerAPI.usePathResolver();
			flex2.compiler.CompilerAPI.setupHeadless(configuration);

			// set up for localizing messages
			LocalizationManager l10n = new LocalizationManager();
			l10n.addLocalizer( new XLRLocalizer() );
			l10n.addLocalizer( new ResourceBundleLocalizer() );
			ThreadLocalToolkit.setLocalizationManager( l10n );

			checkSupportedTargetMimeType(targetFile);

			List<VirtualFile> virtualFileList = new ArrayList<VirtualFile>();
			virtualFileList.add(targetFile);

			CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();
			NameMappings mappings = flex2.compiler.CompilerAPI.getNameMappings(configuration);

			//	get standard bundle of compilers, transcoders
			flex2.compiler.Transcoder[] transcoders = getTranscoders(configuration);
			flex2.compiler.SubCompiler[] compilers = getCompilers(compilerConfig, mappings, transcoders);

			// create a FileSpec...
			target.fileSpec = new FileSpec(Collections.<VirtualFile>emptyList(), getFileSpecMimeTypes());

			VirtualFile[] asClasspath = compilerConfig.getSourcePath();

			// create a SourceList...
			target.sourceList = new SourceList(virtualFileList,
											   asClasspath,
											   targetFile,
											   getSourcePathMimeTypes());
			// create a SourcePath...
			target.sourcePath = new SourcePath(asClasspath,
											   targetFile,
											   getSourcePathMimeTypes(),
											   compilerConfig.allowSourcePathOverlap());

			// create a ResourceContainer
			target.resources = new ResourceContainer();

			target.bundlePath = new ResourceBundlePath(configuration.getCompilerConfiguration(), targetFile);

			if (ThreadLocalToolkit.getBenchmark() != null)
			{
				ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new Mxmlc.InitialSetup()));
			}

			// load SWCs
			CompilerSwcContext swcContext = new CompilerSwcContext();
			swcContext.load(compilerConfig.getLibraryPath(),
							Configuration.getAllExcludedLibraries(compilerConfig, configuration),
							compilerConfig.getThemeFiles(),
							compilerConfig.getIncludeLibraries(),
							mappings,
							I18nUtils.getTranslationFormat(compilerConfig),
							swcCache);
			configuration.addExterns(swcContext.getExterns());
			configuration.addIncludes( swcContext.getIncludes() );
			configuration.getCompilerConfiguration().addThemeCssFiles(swcContext.getThemeStyleSheets());

			// validate CompilationUnits in FileSpec, SourceList and SourcePath
			flex2.compiler.CompilerAPI.validateCompilationUnits(target.fileSpec, target.sourceList, target.sourcePath,
                                                                target.bundlePath, target.resources, swcContext, null, configuration);

			// create a SymbolTable...
			final SymbolTable symbolTable = new SymbolTable(configuration);
			target.perCompileData = symbolTable.perCompileData;

			// compile
			target.units = flex2.compiler.CompilerAPI.compile(target.fileSpec, target.sourceList, null, target.sourcePath, target.resources,
													  target.bundlePath, swcContext, symbolTable, mappings, configuration, compilers,
													  new PreLink(), licenseMap, new ArrayList<Source>());

			return target;
		}
		catch (CompilerException ex)
		{
			throw ex;
		}
		catch (Throwable t)
		{
			String message = t.getMessage();
			if (message == null)
			{
				message = t.getClass().getName();
			}
			ThreadLocalToolkit.logError(message);
			throw new CompilerException(message);
		}
		finally
		{
			flex2.compiler.CompilerAPI.removePathResolver();
		}
	}

	/**
	 * This method is used by Toolkit.
	 *
	 * @see flex2.tools.oem.Toolkit
	 */
	public static long optimize(InputStream in, OutputStream out, Configuration configuration) throws IOException
	{
		// decoder
		Movie movie = new Movie();
		TagDecoder tagDecoder = new TagDecoder(in);
		MovieDecoder movieDecoder = new MovieDecoder(movie);
		tagDecoder.parse(movieDecoder);

		// optimize
		optimize(movie, configuration);

		//TODO PERFORMANCE: A lot of unnecessary recopying and buffering here
		// encode
		TagEncoder handler = new TagEncoder();
		MovieEncoder encoder = new MovieEncoder(handler);
		encoder.export(movie);
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		handler.writeTo(baos);
		out.write(baos.toByteArray());
		
		return baos.size();
	}

	/**
	 * This method is used by Optimizer.
	 *
	 * @see flex2.tools.Optimizer
	 */
	static void optimize(Movie m, Configuration configuration)
	{
		// don't keep debug opcodes
		// abc merge
		// peephole optimization
		m.enableDebugger = null;
		m.uuid = null;
		PostLink postLink = (configuration != null) ? new PostLink(configuration) : new PostLink(false, true);
		postLink.run(m);
	}

	/**
	 * This method is used by Toolkit.
	 *
	 * @see flex2.tools.oem.Toolkit
	 */
	public static long optimize(InputStream in, OutputStream out) throws IOException
	{
		return optimize(in, out, null);
	}

	/**
	 * This method is called by flex.webtier.server.j2ee.IncrementalCompilerFilter.
	 */
	public static Transcoder[] getTranscoders( Configuration cfg )
	{
		// create a list of supported transcoders
		return new Transcoder[]{new JPEGTranscoder(), new LosslessImageTranscoder(), //new JAITranscoder(),
								new SVGTranscoder(cfg.getCompilerConfiguration().showDeprecationWarnings()),
                                new SoundTranscoder(), new MovieTranscoder(), new FontTranscoder(cfg),
								new DataTranscoder(), new XMLTranscoder(),
								new SkinTranscoder(), new PBJTranscoder()
		};
	}

	/**
	 * This method is called by flex.webtier.server.j2ee.IncrementalCompilerFilter.
	 */
	public static flex2.compiler.SubCompiler[] getCompilers(CompilerConfiguration compilerConfig, NameMappings mappings,
														 Transcoder[] transcoders)
	{
		// support .AS3
		As3Compiler asc = new As3Compiler(compilerConfig);

		// signature generation should occur before other extensions can touch the syntax tree
		if (!compilerConfig.getDisableIncrementalOptimizations())
		{
			SignatureExtension.init(compilerConfig);
			asc.addCompilerExtension(SignatureExtension.getInstance());
		}
		final String gendir = (compilerConfig.keepGeneratedActionScript()
									? compilerConfig.getGeneratedDirectory()
									: null);
        final boolean generateAbstractSyntaxTree = compilerConfig.getGenerateAbstractSyntaxTree();
		asc.addCompilerExtension(new EmbedExtension(transcoders, gendir, compilerConfig.showDeprecationWarnings()));
		asc.addCompilerExtension(new StyleExtension());
		// IMPORTANT!!!! The HostComponentExtension must run before the BindableExtension!!!!
		asc.addCompilerExtension(new HostComponentExtension(compilerConfig.reportMissingRequiredSkinPartsAsWarnings()));
		asc.addCompilerExtension(new BindableExtension(gendir, generateAbstractSyntaxTree, false));
		asc.addCompilerExtension(new ManagedExtension(gendir, generateAbstractSyntaxTree,
                                                      compilerConfig.getServicesDependencies(), false));
		asc.addCompilerExtension(new SkinPartExtension());
		// asc.addCompilerExtension(new flex2.compiler.util.TraceExtension());
		
		// support MXML
        MxmlCompiler mxmlc = new MxmlCompiler(compilerConfig, compilerConfig,
                                mappings, transcoders);

		// support ABC
		AbcCompiler abc = new AbcCompiler(compilerConfig);
		abc.addCompilerExtension(new StyleExtension());
		
		// abc.addCompilerExtension(new flex2.compiler.util.TraceExtension());

        // support FXG
        FXGCompiler fxg = new FXGCompiler(compilerConfig, mappings);

		// support i18n (.properties)
		I18nCompiler prop = new I18nCompiler(compilerConfig, transcoders);

		// support CSS
		CssCompiler css = new CssCompiler(compilerConfig, transcoders, mappings);

		return new SubCompiler[]{asc, mxmlc, abc, fxg, prop, css};
	}

	/**
	 * This method is used by Mxmlc, Fcsh, and Application.
	 *
	 * @see flex2.tools.Mxmlc
	 * @see flex2.tools.Fcsh
	 * @see flex2.tools.oem.Application
	 */
	public static void checkSupportedTargetMimeType(VirtualFile targetFile) throws CompilerException
	{
		String[] mimeTypes = getTargetMimeTypes();

		for (int i = 0, length = mimeTypes.length; i < length; i++)
		{
			if (mimeTypes[i].equals(targetFile.getMimeType()))
			{
				return;
			}
		}

		UnsupportedFileType ex = new UnsupportedFileType(targetFile.getName());
		ThreadLocalToolkit.log(ex);
		throw ex;
	}

	/**
	 * This method is called by flex.webtier.server.j2ee.IncrementalCompilerFilter.
	 */
	public static String[] getFileSpecMimeTypes()
	{
		return new String[]{MimeMappings.AS, MimeMappings.MXML, MimeMappings.FXG, MimeMappings.CSS, MimeMappings.ABC};
	}

	/**
	 * This method is called by flex.webtier.server.j2ee.IncrementalCompilerFilter.
	 */
	public static String[] getSourceListMimeTypes()
	{
		return new String[]{MimeMappings.AS, MimeMappings.MXML, MimeMappings.FXG, MimeMappings.CSS};
	}

	/**
	 * This method is called by flex.webtier.server.j2ee.IncrementalCompilerFilter.
	 */
	public static String[] getSourcePathMimeTypes()
	{
		return new String[]{MimeMappings.AS, MimeMappings.MXML, MimeMappings.FXG};
	}

	/**
	 * This method is called by flex.webtier.server.j2ee.IncrementalCompilerFilter.
     *
     * FXG is not included in the list of target mime types, because
     * the compiler doesn't support an FXG based root yet and we don't
     * want to allow broken SWF's to be created.
	 */
	public static String[] getTargetMimeTypes()
	{
		return new String[]{MimeMappings.AS, MimeMappings.MXML, MimeMappings.CSS};
	}
}
