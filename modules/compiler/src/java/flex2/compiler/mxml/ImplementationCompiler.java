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

package flex2.compiler.mxml;

import flex2.compiler.*;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.As3Configuration;
import flex2.compiler.as3.BytecodeEmitter;
import flex2.compiler.as3.EmbedExtension;
import flex2.compiler.as3.HostComponentExtension;
import flex2.compiler.as3.SignatureExtension;
import flex2.compiler.as3.StyleExtension;
import flex2.compiler.as3.binding.BindableExtension;
import flex2.compiler.as3.binding.DataBindingExtension;
import flex2.compiler.as3.managed.ManagedExtensionError;
import flex2.compiler.as3.SkinPartExtension;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.TextFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.builder.DocumentBuilder;
import flex2.compiler.mxml.dom.AnalyzerAdapter;
import flex2.compiler.mxml.dom.DocumentNode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.gen.VelocityUtil;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.DocumentInfo;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.*;
import macromedia.asc.util.ContextStatics;
import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This class handles the second pass of the mxml subcompiler.  It
 * generates a full implementation and generates byte code.
 *
 * @author Clement Wong
 * 
 * Changed to extend AbstractSubCompiler to clean up benchmarking code and enable 
 * embedded compiler benchmarking - bfrazer
 */
class ImplementationCompiler extends flex2.compiler.AbstractSubCompiler
{
	private static final String DOC_KEY = "doc";
	private static final String COMMENTS_KEY = "processcomment";
	private static final String CLASSDEF_TEMPLATE_PATH = "flex2/compiler/mxml/gen/";

	private static final String EMPTY_STRING = "";
	private boolean processComments = false;
	
	public ImplementationCompiler(MxmlConfiguration mxmlConfiguration,
	                              As3Configuration ascConfiguration,
	                              NameMappings mappings, Transcoder[] transcoders, boolean processComments )
	{
		this.mxmlConfiguration = mxmlConfiguration;
        this.ascConfiguration = ascConfiguration;
		this.nameMappings = mappings;
        this.processComments = processComments;
        
		mimeTypes = new String[]{MimeMappings.MXML};
		generateDocComments = ascConfiguration.doc();

		// set up ASC and extensions -- mostly mirrors flex2.tools.WebTierAPI.getCompilers()
		asc = new As3Compiler(ascConfiguration);
        
        // signature generation should occur before other extensions can touch the syntax tree.
        if ((ascConfiguration instanceof CompilerConfiguration)
                // currently, both configs reference same object, and are CompilerConfigurations
                && !((CompilerConfiguration)ascConfiguration).getDisableIncrementalOptimizations())
        {
            // SignatureExtension was already initialized in flex2.tools.WebTierAPI.getCompilers()
            asc.addCompilerExtension(SignatureExtension.getInstance());
        }
        String gendir = (mxmlConfiguration.keepGeneratedActionScript()? mxmlConfiguration.getGeneratedDirectory() : null);
		asc.addCompilerExtension(new EmbedExtension(transcoders, gendir, mxmlConfiguration.showDeprecationWarnings()));
		asc.addCompilerExtension(new StyleExtension());
		
		// IMPORTANT!!!! The HostComponentExtension must run before the BindableExtension!!!!
		asc.addCompilerExtension(new HostComponentExtension(mxmlConfiguration.reportMissingRequiredSkinPartsAsWarnings()));
		asc.addCompilerExtension(new SkinPartExtension());
		
		// add binding extension only when processComments is false.
		if(!processComments) 
		{
		    asc.addCompilerExtension(new BindableExtension(gendir, mxmlConfiguration.getGenerateAbstractSyntaxTree(), false));
		} 
		
		asc.addCompilerExtension(new DataBindingExtension(gendir, mxmlConfiguration.showBindingWarnings(),
														  mxmlConfiguration.getGenerateAbstractSyntaxTree(),
                                                          ascConfiguration.getDefine()));
		asc.addCompilerExtension(new ManagedExtensionError());
        // asc.addCompilerExtension(new flex2.compiler.util.TraceExtension());
    }

	private As3Configuration ascConfiguration;
	private MxmlConfiguration mxmlConfiguration;
	private boolean generateDocComments;
	private NameMappings nameMappings;
	private String[] mimeTypes;
	private As3Compiler asc;

	As3Compiler getASCompiler()
	{
		return asc;
	}
	
	public boolean isSupported(String mimeType)
	{
        for (int i = 0; i < mimeTypes.length; i++)
        {
            if (mimeTypes[i].equals(mimeType))
                return true;
        }
        return false;
	}

	public String[] getSupportedMimeTypes()
	{
		return mimeTypes;
	}

	public Source preprocess(Source source)
	{
		return source;
	}

	/**
	 * Traverse the MXML DOM, building an MxmlDocument object. Then use that object to generate AS3 source code.
	 * Then parse that source. 
	 * <p>Note that we're guaranteed to have all the types we need to walk the DOM, due to InterfaceCompiler's
	 * previous traversal which registered the necessary types as dependencies. However, it's still our responsibility
	 * to e.g. generate imports for Classes that are used in the generated program, and so on.
	 */
	public CompilationUnit parse1(Source source, SymbolTable symbolTable)
	{
        CompilationUnit unit = source.getCompilationUnit();

	    // use TypeTable to do the encapsulation - SymbolTable can be too low-level for MXML...
		TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(MxmlCompiler.TYPE_TABLE);
		if (typeTable == null)
		{
			typeTable = new TypeTable(symbolTable, nameMappings, unit.getStandardDefs(),
                                      mxmlConfiguration.getThemeNames());
			symbolTable.getContext().setAttribute(MxmlCompiler.TYPE_TABLE, typeTable);
		}

		/**
		 * Note: because of the way the Compiler framework works, if it's ever the case that <strong>every type request
		 * made by a given iteration of InterfaceCompiler.postprocess() fails to resolve, then postprocess() will not
		 * be reinvoked.<strong> Hence the following.
		 */
		if (hasUnresolvedNodes(unit))
		{
			return null;
		}

		DocumentNode app = (DocumentNode)unit.getSyntaxTree();
		assert app != null;

		DocumentInfo info = (DocumentInfo)unit.getContext().removeAttribute(MxmlCompiler.DOCUMENT_INFO);
		assert info != null;

		//	build MxmlDocument from MXML DOM
		MxmlDocument document = new MxmlDocument(unit, typeTable, info, mxmlConfiguration);
        DocumentBuilder builder = new DocumentBuilder(unit, typeTable, mxmlConfiguration, document);
		app.analyze(builder);

        if (ThreadLocalToolkit.errorCount() > 0)
        {
            return null;
        }

		Source genSource;
		CompilationUnit ascUnit;
		Logger original = ThreadLocalToolkit.getLogger();

		if (mxmlConfiguration.getGenerateAbstractSyntaxTree())
		{
			Logger adapter = new AbstractSyntaxTreeLogAdapter(original);
			ThreadLocalToolkit.setLogger(adapter);

			genSource = generateImplementationAST(document, 
												  symbolTable.perCompileData,
												  symbolTable.emitter);

			// C: null out MxmlDocument after generation
			document.getStylesContainer().setMxmlDocument(null);
			document = null;
			// C: MXML DOM no longer needed
			unit.setSyntaxTree(null);
			
			ascUnit = asc.parse1(genSource, symbolTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return null;
			}
		}
		else
		{
			// generate AS3 code
			VirtualFile genFile = generateImplementation(document);
			// obtain the line number map...
			DualModeLineNumberMap lineMap = document.getLineNumberMap();

			if (genFile != null && ThreadLocalToolkit.errorCount() == 0)
			{
				genSource = new Source(genFile, source);
				// C: I don't think this is necessary...
				genSource.addFileIncludes(source);
			}
			else
			{
				return null;
			}

			// use MxmlLogAdapter to do filtering, e.g. -generated.as -> .mxml, as line -> mxml line, etc...
			Logger adapter = new MxmlLogAdapter(original, lineMap);
			ThreadLocalToolkit.setLogger(adapter);

			// C: null out MxmlDocument after generation
			document.getStylesContainer().setMxmlDocument(null);
			document = null;
			// C: MXML DOM no longer needed
			unit.setSyntaxTree(null);
			
			// 6. invoke asc
			ascUnit = asc.parse1(genSource, symbolTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				ThreadLocalToolkit.setLogger(original);
				return null;
			}
			
			unit.getContext().setAttribute(MxmlCompiler.LINE_NUMBER_MAP, lineMap);
			// set this so asc can use the line number map to re-map line numbers for debug-mode movies.
			ascUnit.getContext().setAttribute(MxmlCompiler.LINE_NUMBER_MAP, lineMap);
		}

		ThreadLocalToolkit.setLogger(original);

		unit.getContext().setAttribute(MxmlCompiler.DELEGATE_UNIT, ascUnit);

		List bindingExpressions = (List) unit.getContext().getAttribute(CompilerContext.BINDING_EXPRESSIONS);
		ascUnit.getContext().setAttribute(CompilerContext.BINDING_EXPRESSIONS, bindingExpressions);

		unit.getSource().addFileIncludes(ascUnit.getSource());

		Source.transferMetaData(ascUnit, unit);
		Source.transferGeneratedSources(ascUnit, unit);
		Source.transferDefinitions(ascUnit, unit);
		Source.transferInheritance(ascUnit, unit);
		Source.transferExpressions(ascUnit, unit);

		// 7. return CompilationUnit
		return unit;
	}

	public void parse2(CompilationUnit unit, SymbolTable symbolTable)
	{
		CompilationUnit ascUnit = (CompilationUnit) unit.getContext().getAttribute(MxmlCompiler.DELEGATE_UNIT);
		Source.transferInheritance(unit, ascUnit);

		Logger original = setLogAdapter(unit);
		asc.parse2(ascUnit, symbolTable);
		ThreadLocalToolkit.setLogger(original);

		Source.transferAssets(ascUnit, unit);
		Source.transferGeneratedSources(ascUnit, unit);
	}

	public void analyze1(CompilationUnit unit, SymbolTable symbolTable)
	{
		CompilationUnit ascUnit = (CompilationUnit) unit.getContext().getAttribute(MxmlCompiler.DELEGATE_UNIT);

		Logger original = setLogAdapter(unit);
		asc.analyze1(ascUnit, symbolTable);
		ThreadLocalToolkit.setLogger(original);

		Source.transferTypeInfo(ascUnit, unit);
		Source.transferNamespaces(ascUnit, unit);
	}

	public void analyze2(CompilationUnit unit, SymbolTable symbolTable)
	{
		CompilationUnit ascUnit = (CompilationUnit) unit.getContext().getAttribute(MxmlCompiler.DELEGATE_UNIT);
		Source.transferDependencies(unit, ascUnit);

		Logger original = setLogAdapter(unit);
		asc.analyze2(ascUnit, symbolTable);
		ThreadLocalToolkit.setLogger(original);

		Source.transferDependencies(ascUnit, unit);
	}

	public void analyze3(CompilationUnit unit, SymbolTable symbolTable)
	{
		CompilationUnit ascUnit = (CompilationUnit) unit.getContext().getAttribute(MxmlCompiler.DELEGATE_UNIT);
		Source.transferDependencies(unit, ascUnit);

		Logger original = setLogAdapter(unit);
		asc.analyze3(ascUnit, symbolTable);
		ThreadLocalToolkit.setLogger(original);
	}

	public void analyze4(CompilationUnit unit, SymbolTable symbolTable)
	{
		CompilationUnit ascUnit = (CompilationUnit) unit.getContext().getAttribute(MxmlCompiler.DELEGATE_UNIT);
		Logger original = ThreadLocalToolkit.getLogger();

		if (mxmlConfiguration.getGenerateAbstractSyntaxTree())
		{
			Logger adapter = new AbstractSyntaxTreeLogAdapter(original);
			ThreadLocalToolkit.setLogger(adapter);
		}
		else
		{
			LineNumberMap map = (LineNumberMap) unit.getContext().getAttribute(MxmlCompiler.LINE_NUMBER_MAP);
			MxmlLogAdapter adapter = new MxmlLogAdapter(original, map);
			adapter.setRenamedVariableMap( (Map) ascUnit.getContext().getAttribute(CompilerContext.RENAMED_VARIABLE_MAP) );
			ThreadLocalToolkit.setLogger(adapter);
		}

		asc.analyze4(ascUnit, symbolTable);

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			ThreadLocalToolkit.setLogger(original);
			return;
		}

		ThreadLocalToolkit.setLogger(original);

		Source.transferExpressions(ascUnit, unit);
		Source.transferMetaData(ascUnit, unit);
		Source.transferLoaderClassBase(ascUnit, unit);
		Source.transferClassTable(ascUnit, unit);
		Source.transferStyles(ascUnit, unit);
	}

	public void generate(CompilationUnit unit, SymbolTable symbolTable)
	{
		CompilationUnit ascUnit = (CompilationUnit) unit.getContext().getAttribute(MxmlCompiler.DELEGATE_UNIT);

		Logger original = ThreadLocalToolkit.getLogger();

		if (mxmlConfiguration.getGenerateAbstractSyntaxTree())
		{
			Logger adapter = new AbstractSyntaxTreeLogAdapter(original);
			ThreadLocalToolkit.setLogger(adapter);
		}
		else
		{
			LineNumberMap lineNumberMap = (LineNumberMap) unit.getContext().getAttribute(MxmlCompiler.LINE_NUMBER_MAP);

			if (lineNumberMap instanceof DualModeLineNumberMap)
			{
				((DualModeLineNumberMap) lineNumberMap).flushTemp();	//  flush all compile-error-only line number mappings
			}

			Logger adapter = new MxmlLogAdapter(original, lineNumberMap);
			ThreadLocalToolkit.setLogger(adapter);
		}

		asc.generate(ascUnit, symbolTable);

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			ThreadLocalToolkit.setLogger(original);
			return;
		}

		ThreadLocalToolkit.setLogger(original);

		Source.transferGeneratedSources(ascUnit, unit);
		Source.transferBytecodes(ascUnit, unit);
	}

	public void postprocess(CompilationUnit unit, SymbolTable symbolTable)
	{
        // This method is never called, because generate() always produces bytecode, which
        // causes CompilerAPI.postprocess() to skip calling the flex2.compiler.mxml.MxmlCompiler
        // postprocess() method.
	}

	/**
	 *
	 */
	private boolean hasUnresolvedNodes(CompilationUnit unit)
	{
		Set checkNodes = (Set)unit.getContext().removeAttribute(MxmlCompiler.CHECK_NODES);
		if (checkNodes != null && !checkNodes.isEmpty())
		{
			for (Iterator iter = checkNodes.iterator(); iter.hasNext(); )
			{
				Node node = (Node)iter.next();
				ThreadLocalToolkit.log(new AnalyzerAdapter.CouldNotResolveToComponent(node.image), unit.getSource());
			}
		}
        return ThreadLocalToolkit.errorCount() > 0;
	}

	/**
	 *
	 */
	private final VirtualFile generateImplementation(MxmlDocument doc)
	{
	    StandardDefs standardDefs = doc.getStandardDefs();
	    String classDefTemplate = CLASSDEF_TEMPLATE_PATH + standardDefs.getClassDefTemplate();
	    String classDefLibTemplate = CLASSDEF_TEMPLATE_PATH + standardDefs.getClassDefLibTemplate();

		//	load template
		Template template = VelocityManager.getTemplate(classDefTemplate, classDefLibTemplate);
		if (template == null)
		{
			ThreadLocalToolkit.log(new UnableToLoadTemplate(classDefTemplate));
			return null;
		}

		//	evaluate template against document
		String genFileName = MxmlCompiler.getGeneratedName(mxmlConfiguration, doc.getPackageName(), doc.getClassName(),
		                                                        "-generated.as");

		Source source = doc.getCompilationUnit().getSource();

		// C: I would like to guesstimate this number based on MXML component size...
		SourceCodeBuffer out = new SourceCodeBuffer((int) (source.size() * 4));
		try
		{
            DualModeLineNumberMap lineMap = new DualModeLineNumberMap(source.getNameForReporting(), genFileName);
            doc.setLineNumberMap(lineMap);

            VelocityUtil util = new VelocityUtil(CLASSDEF_TEMPLATE_PATH, mxmlConfiguration.debug(), out, lineMap);
			VelocityContext vc = VelocityManager.getCodeGenContext(util);
			vc.put(DOC_KEY, doc);
			// pass whether to care for comments or not 
			vc.put(COMMENTS_KEY, processComments);
		
            template.merge(vc, out);
		}
		catch (Exception e)
		{
			ThreadLocalToolkit.log(new CodeGenerationException(doc.getSourcePath(), e.getLocalizedMessage()));
			return null;
		}

		//	(flush and) return result
		if (out.getBuffer() != null)
		{
			String code = out.toString();

			if (mxmlConfiguration.keepGeneratedActionScript())
			{
				try
				{
					FileUtil.writeFile(genFileName, code);
				}
				catch (IOException e)
				{
					ThreadLocalToolkit.log(new VelocityException.UnableToWriteGeneratedFile(genFileName, e.getLocalizedMessage()));
				}
			}

			// -generated.as should use the originating source timestamp
			return new TextFile(code, genFileName, doc.getCompilationUnit().getSource().getParent(),
			                    MimeMappings.AS, doc.getCompilationUnit().getSource().getLastModified());
		}
		else
		{
			return null;
		}
	}

	private Source generateImplementationAST(MxmlDocument mxmlDocument, ContextStatics contextStatics,
											 BytecodeEmitter bytecodeEmitter)
	{
		String genFileName = MxmlCompiler.getGeneratedName(mxmlConfiguration, mxmlDocument.getPackageName(),
                                                           mxmlDocument.getClassName(), "-generated.as");
		Source source = mxmlDocument.getCompilationUnit().getSource();
		VirtualFile emptyFile = new TextFile(EMPTY_STRING, genFileName, source.getParent(), MimeMappings.AS,
											 System.currentTimeMillis());
		Source result = new Source(emptyFile, source);

		ImplementationGenerator implementationGenerator =
			new ImplementationGenerator(mxmlDocument, generateDocComments, contextStatics,
										result, bytecodeEmitter, ascConfiguration.getDefine(), processComments);

		CompilerContext context = new CompilerContext();
		context.setAscContext(implementationGenerator.getContext());

		Object syntaxTree = implementationGenerator.getSyntaxTree();
		result.newCompilationUnit(syntaxTree, context).setSyntaxTree(syntaxTree);

		return result;
	}

    // error messages

	public static class UnableToLoadTemplate extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 4986512756206073031L;

        public UnableToLoadTemplate(String template)
		{
			this.template = template;
			noPath();
		}

		public String template;
	}

	public static class CodeGenerationException extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -5873407973653883428L;

        public CodeGenerationException(String template, String message)
		{
			super();
			this.template = template;
			this.message = message;
		}

		public final String template, message;
	}

	
    // not needed (we don't expect to ever be a "top level compiler"
    public String getName()
    {
    	assert(false);
        return null;
    }
    
    /**
     * pass down a benchmarker to we can account for time in asc compiler
     * 
     */
    public void setHelper(CompilerBenchmarkHelper helper, boolean isEmb)
    {
    	assert(isEmb);	// we expect that people will pass down the embedded to us, since we are
    					// going to turn around and use is as the MAIN benchmarker for asc.
    	
    	asc.setHelper(helper, false); // Here is the "tricky" bit: we are being passed the embedded helper, 
    			// from above, but we turn anround and pass it to our bemcedded compiler as the "main" helper.
    			// This 
    }

	private Logger setLogAdapter(CompilationUnit unit)
	{
		Logger original = ThreadLocalToolkit.getLogger();

		if (mxmlConfiguration.getGenerateAbstractSyntaxTree())
		{
			Logger adapter = new AbstractSyntaxTreeLogAdapter(original);
			ThreadLocalToolkit.setLogger(adapter);
		}
		else
		{
			LineNumberMap map = (LineNumberMap) unit.getContext().getAttribute(MxmlCompiler.LINE_NUMBER_MAP);
			Logger adapter = new MxmlLogAdapter(original, map);
			ThreadLocalToolkit.setLogger(adapter);
		}

		return original;
	}
}
