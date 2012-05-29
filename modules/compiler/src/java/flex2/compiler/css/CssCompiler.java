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

package flex2.compiler.css;

import flash.css.StyleSheet;
import flash.fonts.FontManager;
import flash.util.Trace;
import flex2.compiler.AbstractDelegatingSubCompiler;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerBenchmarkHelper;
import flex2.compiler.CompilerContext;
import flex2.compiler.Logger;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.EmbedExtension;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.TextFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.MxmlLogAdapter;
import flex2.compiler.mxml.SourceCodeBuffer;
import flex2.compiler.mxml.gen.VelocityUtil;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.rep.AtEmbed;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.DualModeLineNumberMap;
import flex2.compiler.util.LineNumberMap;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.VelocityException.GenerateException;
import flex2.compiler.util.VelocityException.TemplateNotFound;
import flex2.compiler.util.VelocityException.UnableToWriteGeneratedFile;
import flex2.compiler.util.VelocityManager;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;

/**
 * This subcompiler is used to translate a CSS file into an AS3
 * representation, so it can be compiled by the AS3 delegate compiler
 * into bytecode.  When the resulting SWF is loaded at runtime as a
 * CSS module, the StyleManager will be populated with the styles
 * defined in the CSS file.
 *
 * @author Paul Reilly
 */
public class CssCompiler extends AbstractDelegatingSubCompiler
{
    private static final String TEMPLATE_PATH = "flex2/compiler/css/";
    private static final String STYLE_MODULE_KEY = "styleModule";
    private static final String COMPILER_NAME = "css";

    private String[] mimeTypes;
    private CompilerConfiguration configuration;
    private NameMappings nameMappings;

    public CssCompiler(CompilerConfiguration configuration, Transcoder[] transcoders, NameMappings mappings)
    {
        this.configuration = configuration;
        mimeTypes = new String[]{MimeMappings.CSS};
        nameMappings = mappings;
        String gendir = (configuration.keepGeneratedActionScript()? configuration.getGeneratedDirectory() : null);

        // Create an As3Compiler as our delegate sub-compiler.
        As3Compiler asc = new As3Compiler(configuration);
        asc.addCompilerExtension(new EmbedExtension(transcoders, gendir, configuration.showDeprecationWarnings()));
        delegateSubCompiler = asc;
    }

    /**
     * The name of this compiler as a simple String identifier.
     * 
     * @return This Compiler's name. 
     */
    public String getName()
    {
        return COMPILER_NAME;
    }

    /**
     * If this compiler can process the specified file, return true.
     */
    public boolean isSupported(String mimeType)
    {
        return mimeTypes[0].equals(mimeType);
    }

    private String generateStyleName(Source source)
    {
        String result = source.getName();

        int lastSeparator = result.lastIndexOf(File.separator);

        if (lastSeparator != -1)
        {
            result = result.substring(lastSeparator + 1);

            int extension = result.indexOf(".css");

            if (extension != -1)
            {
                result = result.substring(0, extension);
            }
        }

        return result;
    }

    /**
     * Return supported mime types.
     */
    public String[] getSupportedMimeTypes()
    {
        return mimeTypes;
    }

    /**
     * Pre-process source file.
     */
    public Source preprocess(Source source)
    {
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PREPROCESS, source.getNameForReporting());
        }

        // The defs (mx.core:FlexModuleFactory, mx.core:mx_internal,
        // mx.core:IFlexModule, and mx.core:IFlexModuleFactory) are
        // used in frame 1, so they can't be externed.  ModuleBase is
        // used by the generated source, so it can't be externed
        // either.  The generated source depends on the rest of these
        // defs, but they should already be included in the loading
        // SWF, so we explicitly extern them.  The list was created by
        // examining a link report from a simple CSS compilation.
        // Although, this process is manual, it was alot easier than
        // writing a custom linker.  One alternative was to extern all
        // of framework.swc, but this prevents customers from using
        // skin assets from framework.swc in their runtime CSS
        // modules.
    	if (!configuration.archiveClassesAndAssets())
    	{
    	    StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
    	    
            configuration.addExtern(standardDefs.CLASS_CSSSTYLEDECLARATION);
            configuration.addExtern(standardDefs.CLASS_DOWNLOADPROGRESSBAR);
            configuration.addExtern(standardDefs.CLASS_FLEXEVENT);
            configuration.addExtern(standardDefs.CLASS_FLEXSPRITE);
            configuration.addExtern(standardDefs.CLASS_LOADERCONFIG);
            configuration.addExtern(standardDefs.CLASS_MODULEEVENT);
            configuration.addExtern(standardDefs.CLASS_MODULEMANAGER);
            configuration.addExtern(standardDefs.CLASS_PRELOADER);
            configuration.addExtern(standardDefs.CLASS_STYLEEVENT);
    		// Don't extern StyleManager.  It is needed in case the module
    		// is loaded in a bootstrap topology
            // configuration.addExtern(StandardDefs.CLASS_STYLEMANAGER);
            configuration.addExtern(standardDefs.CLASS_SYSTEMCHILDRENLIST);
            configuration.addExtern(standardDefs.CLASS_SYSTEMMANAGER);
            configuration.addExtern(standardDefs.CLASS_SYSTEMRAWCHILDRENLIST);
            configuration.addExtern(standardDefs.INTERFACE_ICHILDLIST);
            configuration.addExtern(standardDefs.INTERFACE_IFLEXDISPLAYOBJECT);
            configuration.addExtern(standardDefs.INTERFACE_IFOCUSMANAGERCONTAINER);
            configuration.addExtern(standardDefs.INTERFACE_IINVALIDATING);
            configuration.addExtern(standardDefs.INTERFACE_ILAYOUTMANAGERCLIENT);
            configuration.addExtern(standardDefs.INTERFACE_IMODULEINFO);
            configuration.addExtern(standardDefs.INTERFACE_IRAWCHILDRENCONTAINER);
            configuration.addExtern(standardDefs.INTERFACE_ISIMPLESTYLECLIENT);
            configuration.addExtern(standardDefs.INTERFACE_ISTYLECLIENT);
            configuration.addExtern(standardDefs.INTERFACE_ISYSTEMMANAGER);
            configuration.addExtern(standardDefs.INTERFACE_IUICOMPONENT);
    	}
    	
        String componentName = source.getShortName();
        if (!TextParser.isValidIdentifier(componentName))
        {
            InvalidComponentName invalidComponentName = new InvalidComponentName(componentName);
            invalidComponentName.setPath(source.getNameForReporting());
            ThreadLocalToolkit.log(invalidComponentName);
        }

        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PREPROCESS);
        }

        return source;
    }

    /**
     * Parse... The implementation must:
     *
     * 1. create a compilation unit
     * 2. put the Source object and the syntax tree in the compilation unit
     * 3. register unit.includes, unit.dependencies, unit.topLevelDefinitions and unit.metadata
     */
    public CompilationUnit parse1(Source source, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE1, source.getNameForReporting());
        }

        CompilationUnit unit = source.getCompilationUnit();

        if (unit != null && unit.hasTypeInfo)
        {
            return unit;
        }
        
        // System.out.println("parse1: " + source.getNameForReporting());
        FontManager fontManager = configuration.getFontsConfiguration().getTopLevelManager();

        StyleSheet styleSheet = new StyleSheet();
        styleSheet.checkDeprecation(configuration.showDeprecationWarnings());

        InputStream in = null;
        try
        {
            in = source.getInputStream();
            styleSheet.parse(source.getName(),
                             in,
                             ThreadLocalToolkit.getLogger(),
                             fontManager);
        }
        catch (Exception exception)
        {
            if (Trace.error)
            {
                exception.printStackTrace();
            }

            ParseError parseError = new ParseError(exception.getLocalizedMessage());
            parseError.setPath(source.getName());
            ThreadLocalToolkit.log(parseError);
            return null;
        }
        finally
        {
            if (in != null)
            {
                try
                {
                    in.close();
                }
                catch (IOException ex)
                {

                }
            }
        }        

        if (styleSheet.errorsExist())
        {
            // Error
            ThreadLocalToolkit.getLogger().log(new StyleSheetParseError(source.getName()));
        }

        StyleModule styleModule = new StyleModule(source, symbolTable.perCompileData);

        // Flex3 and earlier didn't support qualified types or advanced css.
        if (configuration.getCompatibilityVersion() <= flex2.compiler.common.MxmlConfiguration.VERSION_3_0)
        {
            styleModule.setAdvanced(false);
            styleModule.setQualifiedTypeSelectors(false);
        }
        else
        {
            styleModule.setQualifiedTypeSelectors(configuration.getQualifiedTypeSelectors());
        }

        styleModule.setNameMappings(nameMappings);
        String styleName = generateStyleName(source);
        styleModule.setName(styleName);
        styleModule.extractStyles(styleSheet, false);

        CompilerContext context = new CompilerContext();

        CompilationUnit cssCompilationUnit = source.newCompilationUnit(null, context);

        VirtualFile generatedFile = generateSourceCodeFile(cssCompilationUnit, styleModule);

        Source generatedSource = new Source(generatedFile, source);

        // when building a SWC, we want to locate all the asset sources and ask compc to put them in the SWC.
        Collection<AtEmbed> atEmbeds = styleModule.getAtEmbeds();
        if (atEmbeds != null && configuration.archiveClassesAndAssets())
        {
        	Map<String, LocalFile> archiveFiles = new HashMap<String, LocalFile>();
        	for (Iterator<AtEmbed>  i = atEmbeds.iterator(); i.hasNext(); )
        	{
        		AtEmbed e = (AtEmbed) i.next();
        		String src = (String) e.getAttributes().get(Transcoder.SOURCE);
        		String original = (String) e.getAttributes().get(Transcoder.ORIGINAL);
        		if (src != null)
        		{
        			archiveFiles.put(original, new LocalFile(new File(src)));
        		}
        	}
        	if (archiveFiles.size() > 0)
        	{
        		context.setAttribute(CompilerContext.CSS_ARCHIVE_FILES, archiveFiles);
        	}
        }
        
        // Use MxmlLogAdapter to do filtering, e.g. -generated.as -> .css, as line -> css
        // line, etc...
        Logger original = ThreadLocalToolkit.getLogger();
        LineNumberMap lineNumberMap = styleModule.getLineNumberMap();
        Logger adapter = new MxmlLogAdapter(original, lineNumberMap);
        ThreadLocalToolkit.setLogger(adapter);

        CompilationUnit ascCompilationUnit = delegateSubCompiler.parse1(generatedSource, symbolTable);

        if (ascCompilationUnit != null)
        {
            // transfer includes from the ASC unit to the CSS unit
            cssCompilationUnit.getSource().addFileIncludes(ascCompilationUnit.getSource());
            context.setAttribute(DELEGATE_UNIT, ascCompilationUnit);
            context.setAttribute(LINE_NUMBER_MAP, lineNumberMap);
            Source.transferMetaData(ascCompilationUnit, cssCompilationUnit);
            Source.transferGeneratedSources(ascCompilationUnit, cssCompilationUnit);
            Source.transferDefinitions(ascCompilationUnit, cssCompilationUnit);
            Source.transferInheritance(ascCompilationUnit, cssCompilationUnit);
        }
        else
        {
            cssCompilationUnit = null;
        }

        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE1);
        }

        return cssCompilationUnit;
    }

    public void parse2(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE2, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        super.parse2(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE2);
    }

    public void analyze1(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE1, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        super.analyze1(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE1);
    }

    public void analyze2(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE2, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        super.analyze2(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE2);
    }

    public void analyze3(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE3, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        super.analyze3(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE3);
    }

    public void analyze4(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE4, unit.getSource().getNameForReporting());

        super.analyze4(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE4);
    }

    public void generate(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.GENERATE,unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        super.generate(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.GENERATE);
    }

    public void postprocess(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.POSTPROCESS, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        super.postprocess(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.POSTPROCESS);
    }

    private VirtualFile generateSourceCodeFile(CompilationUnit compilationUnit, StyleModule styleModule)
    {
        Template template;
        StandardDefs standardDefs = compilationUnit.getStandardDefs();
        String templateName = TEMPLATE_PATH + (!configuration.archiveClassesAndAssets() ? standardDefs.getStyleModuleTemplate() : standardDefs.getStyleLibraryTemplate());

        try
        {
            template = VelocityManager.getTemplate(templateName);
        }
        catch (Exception exception)
        {
            ThreadLocalToolkit.log(new TemplateNotFound(templateName));
            return null;
        }

        SourceCodeBuffer sourceCodeBuffer = new SourceCodeBuffer();

        String genFileName = (configuration.getGeneratedDirectory() +
                              File.separatorChar +
                              styleModule.getName() +
                              "-generated.as");

        Source source = compilationUnit.getSource();

        DualModeLineNumberMap lineNumberMap = new DualModeLineNumberMap(source.getNameForReporting(), genFileName);
        styleModule.setLineNumberMap(lineNumberMap);

        try
        {
            VelocityUtil velocityUtil = new VelocityUtil(TEMPLATE_PATH, configuration.debug(),
                                                         sourceCodeBuffer, lineNumberMap);
            VelocityContext velocityContext = VelocityManager.getCodeGenContext(velocityUtil);
            velocityContext.put(STYLE_MODULE_KEY, styleModule);
            template.merge(velocityContext, sourceCodeBuffer);
        }
        catch (Exception e)
        {
            ThreadLocalToolkit.log(new GenerateException(styleModule.getName(), e.getLocalizedMessage()));
            return null;
        }

        String sourceCode = sourceCodeBuffer.toString();

        if (configuration.keepGeneratedActionScript())
        {
            try
            {
                FileUtil.writeFile(genFileName, sourceCode);
            }
            catch (IOException e)
            {
                ThreadLocalToolkit.log(new UnableToWriteGeneratedFile(genFileName, e.getLocalizedMessage()));
            }
        }

        return new TextFile(sourceCode, genFileName, null, MimeMappings.AS, Long.MAX_VALUE);
    }

    public static class InvalidComponentName extends CompilerError
    {
        private static final long serialVersionUID = -6052613984350060542L;
        public final String name;

        public InvalidComponentName(String name)
        {
            this.name = name;
        }
    }

    public static class StyleSheetParseError extends CompilerError
    {
        private static final long serialVersionUID = -2795572334523977344L;
        public final String stylePath;

        public StyleSheetParseError(String stylePath)
        {
            this.stylePath = stylePath;
        }
    }
}
