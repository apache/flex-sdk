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

package flex2.compiler.fxg;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGParser;
import com.adobe.fxg.FXGParserFactory;
import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGLocalizationUtil;
import com.adobe.fxg.util.FXGLog;
import com.adobe.fxg.util.FXGLogger;
import com.adobe.internal.fxg.dom.GraphicNode;

import flash.localization.LocalizationManager;
import flash.util.FileUtils;
import flex2.compiler.AbstractDelegatingSubCompiler;
import flex2.compiler.AbstractSubCompiler;
import flex2.compiler.AssetInfo;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerBenchmarkHelper;
import flex2.compiler.CompilerContext;
import flex2.compiler.Logger;
import flex2.compiler.Source;
import flex2.compiler.SubCompiler;
import flex2.compiler.SymbolTable;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.TextFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * This FXG sub-compiler is similar to the MXML sub-compiler but it instead
 * of compiling FXG documents as MXML it creates a display list based on
 * optimized SWF graphics primitives. The root DefineSprite is linked to a
 * generated ActionScript class using SymbolClass. A two-pass compile
 * is still required to resolve dependent types and participate in the
 * top level driver, i.e. CompilerAPI.
 * 
 * <p>
 * Since &lt;TextGraphic&gt; cannot be fully represented using SWF tags, 
 * additional ActionScript classes will be generated to programmatically 
 * instantiate instances of RichText and link them to a DefineSprite in the
 * appropriate location in the SWF primitive display list.
 * </p>
 * @author Pete Farland
 */
public class FXGCompiler extends AbstractSubCompiler
{
    private static final String COMPILER_NAME = "fxg";

    /**
     * COMPILATION_STATE is used to indicate progress through double-pass
     * compilation process.
     */
    private static final String COMPILATION_STATE = "FXGCompileState";
    private static final int STATE_SKELETON_PARSED = 0;
    private static final int STATE_SKELETON_GENERATED = 1;
    private static final int STATE_IMPLEMENTATION_PARSED = 2;
    private static final int STATE_IMPLEMENTATION_GENERATED = 3;

    private static final String FXG_DOM_ROOT = "FXG_DOM_ROOT";
    private static final MultiName MULTINAME_SPRITEVISUALELEMENT = new MultiName(StandardDefs.CLASS_SPARK_SPRITEVISUALELEMENT);

    private String[] mimeTypes;
    private NameMappings nameMappings;
    private String generatedOutputDir;
    private SkeletonCompiler skeletonCompiler;
    private ImplementationCompiler implementationCompiler;
    private Set<String> themeNames;
    private String profile = FXG_PROFILE_DESKTOP;

    /**
     * Construct a new FXGCompiler.
     * 
     * @param configuration - a CompilerConfiguration is required to construct
     * a delegate As3Compiler to compile any generated ActionScript and to
     * determine if generated code should be written to disk.
     * 
     * @param nameMappings - NameMappings are used to construct a TypeTable
     * so that the ActionScript text APIs can be queried to determine if an
     * FXG attribute applies to a property or a style.
     */
    public FXGCompiler(CompilerConfiguration configuration, NameMappings nameMappings)
    {
        mimeTypes = new String[]{MimeMappings.FXG};
        this.nameMappings = nameMappings;
        generatedOutputDir = configuration.keepGeneratedActionScript() ? configuration.getGeneratedDirectory() : null;
        skeletonCompiler = new SkeletonCompiler(configuration);
        implementationCompiler = new ImplementationCompiler(configuration);
        themeNames = configuration.getThemeNames();

        // Honor the compiler's mobile profile flag
        boolean mobile = configuration.getMobile();
        if (mobile)
        	profile = FXG_PROFILE_MOBILE;

        // Bridge the compiler's Locale to fxgutils' localization system
        LocalizationManager lm = ThreadLocalToolkit.getLocalizationManager();
        if (lm != null)
        {
        	Locale locale = lm.getLocale();
        	FXGLocalizationUtil.setDefaultLocale(locale);
            FXGLocalizationUtil.setLocale(locale);
        }
    }

    //--------------------------------------------------------------------------
    //
    // SubCompiler Implementation  
    //
    //--------------------------------------------------------------------------

    /**
     * @return the name of this compiler.
     */
    public String getName()
    {
        return COMPILER_NAME;
    }

    /**
     * @param mimeType The MIME type to check.
     * @return true if the MIME type is supported by the FXG compiler.
     */
    public boolean isSupported(String mimeType)
    {
        for (int i = 0; i < mimeTypes.length; i++)
        {
            if (mimeTypes[i].equals(mimeType))
                return true;
        }
        return false;
    }

    /**
     * @return The list of supported MIME types for the FXG compiler. Currently
     * this is *.fxg files. 
     */
    public String[] getSupportedMimeTypes()
    {
        return mimeTypes;
    }

    //---------------------
    // Compilation Phases  
    //---------------------

    public Source preprocess(Source source)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PREPROCESS, source.getNameForReporting());

        // Check the source name is a valid component name.
        String componentName = source.getShortName();
        if (!TextParser.isValidIdentifier(componentName))
        {
            CompilerMessage m = new InvalidComponentName(componentName);
            m.setPath(source.getNameForReporting());
            ThreadLocalToolkit.log(m);
        }

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PREPROCESS);

        return source;
    }

    public CompilationUnit parse1(Source source, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE1, source.getNameForReporting());

        CompilationUnit unit = source.getCompilationUnit();

        if (unit != null && unit.hasTypeInfo)
        {
            return unit;
        }

        // If no compilation unit is associated with the Source then this is
        // our first pass for our two-pass compiler.
        if (unit == null)
        {
            unit = skeletonCompiler.parse1(source, symbolTable);
            if (unit != null)
            {
                setCompileState(unit, STATE_SKELETON_PARSED);
            }
        }
        else
        {
            // We're starting our second pass.
            if (getCompileState(unit) == STATE_SKELETON_GENERATED)
            {
                unit = implementationCompiler.parse1(source, symbolTable);
                if (unit != null)
                {
                    advanceCompilationState(unit);
                }
            }
            else
            {
                //  no-op
            }
        }

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE1);

        return unit;
    }

    public void parse2(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE2, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        getCompilerForCompileState(unit).parse2(unit, symbolTable);

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

        getCompilerForCompileState(unit).analyze1(unit, symbolTable);

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

        getCompilerForCompileState(unit).analyze2(unit, symbolTable);

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

        getCompilerForCompileState(unit).analyze3(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE3);
    }

    public void analyze4(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE4, unit.getSource().getNameForReporting());

		if (unit != null && unit.hasTypeInfo)
		{
            flex2.compiler.as3.reflect.TypeTable typeTable = null;

            if (symbolTable != null)
            {
                typeTable = (flex2.compiler.as3.reflect.TypeTable) symbolTable.getContext().getAttribute(As3Compiler.AttrTypeTable);

                if (typeTable == null)
                {
                    typeTable = new flex2.compiler.as3.reflect.TypeTable(symbolTable);
                    symbolTable.getContext().setAttribute(As3Compiler.AttrTypeTable, typeTable);
                }
            }

            for (Map.Entry<String, AbcClass> entry : unit.classTable.entrySet())
            {
                AbcClass c = entry.getValue();
                c.setTypeTable(typeTable);
                symbolTable.registerClass(entry.getKey(), c);
            }

			return;
		}

        getCompilerForCompileState(unit).analyze4(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE4);
    }

    public void generate(CompilationUnit unit, SymbolTable symbolTable)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.GENERATE, unit.getSource().getNameForReporting());

        if (unit != null && unit.hasTypeInfo)
        {
            return;
        }

        getCompilerForCompileState(unit).generate(unit, symbolTable);
        advanceCompilationState(unit);

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
        
        getCompilerForCompileState(unit).postprocess(unit, symbolTable);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.POSTPROCESS);
    }

    //--------------------------------------------------------------------------
    //
    // Two-Pass Compilation State Management  
    //
    //--------------------------------------------------------------------------

    /**
     * Moves the given CompilationUnit's compile state one step forward.
     */
    private void advanceCompilationState(CompilationUnit unit)
    {
        int state = getCompileState(unit);
        assert state < STATE_IMPLEMENTATION_GENERATED : "FXGCompiler advanceState called with state == " + state;
        setCompileState(unit, state + 1);
    }

    /**
     * Gets the compile state of the given CompilationUnit.
     * 
     * @param unit - the CompilationUnit to query for compilation state.
     * @return the current compile state as an int
     */
    private int getCompileState(CompilationUnit unit)
    {
        assert unit.getContext().getAttribute(COMPILATION_STATE) != null : "FXGCompiler: CompilationUnit lacks " + COMPILATION_STATE + " attribute.";
        return ((Integer)unit.getContext().getAttribute(COMPILATION_STATE)).intValue();
    }

    /**
     * Sets the compiler state of the CompilationUnit.
     * 
     * @param unit - the CompilationUnit to be updated with the given
     * compilation state.
     * @param state - the new compile state
     */
    private void setCompileState(CompilationUnit unit, int state)
    {
        unit.getContext().setAttribute(COMPILATION_STATE, new Integer(state));
    }

    /**
     * @return an inner compiler based the compilation state
     */
    private SubCompiler getCompilerForCompileState(CompilationUnit unit)
    {
        return getCompileState(unit) < STATE_IMPLEMENTATION_PARSED ? skeletonCompiler : implementationCompiler;
    }

    //--------------------------------------------------------------------------
    //
    // Utility Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Package and class is derived from Source name and location.
     * 
     * @param source - the given Source 
     * @return the QName representing the package and class name.
     */
    private static QName getQNameFromSource(Source source)
    {
        String className = source.getShortName();
        String packageName = source.getRelativePath().replace('/', '.');
        return new QName(packageName, className);
    }

    /**
     * @param packageName - the package name to be interpreted as
     * sub-directories under the generated output directory. 
     * @param className - the class name to be used as the file name.
     * @param suffix - to be appended after the file name and provide the file
     * type extension.
     * @return a file name for the given package and class name in the
     * generated output directory.
     */
    private String getGeneratedFileName(String packageName, String className, String suffix)
    {
        String dir = generatedOutputDir;
        if (packageName != null && packageName.length() > 0)
        {
            dir = FileUtils.addPathComponents(dir, packageName.replace('.', File.separatorChar), File.separatorChar);
        }

        return FileUtils.addPathComponents(dir, className + suffix, File.separatorChar);
    }

    /**
     * Initializes a Flex specific logger to bridge FXG messages back to the
     * Flex compiler's logging system.
     */
    private void setupLogger()
    {
        Logger logger = ThreadLocalToolkit.getLogger();
        if (logger != null)
        {
            FXGLogger fxgLogger = FXGLog.getLogger();
            if (!(fxgLogger instanceof FlexLoggerAdapter))
            {
                fxgLogger = new FlexLoggerAdapter(FXGLogger.ALL);
                FXGLog.setLogger(fxgLogger);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Inner Compilers (for Two-Pass Compilation)
    //
    //--------------------------------------------------------------------------

    /**
     * SkeletonCompiler creates a small ActionScript class to introduce
     * dependencies on types that must be compiled before we generate the
     * concrete ActionScript implementation.
     */
    private final class SkeletonCompiler extends AbstractDelegatingSubCompiler
    {
        private SkeletonCompiler(CompilerConfiguration config)
        {
            // Create an As3Compiler as our delegate sub-compiler for
            // generated ActionScript.
            As3Compiler asc = new As3Compiler(config);
            delegateSubCompiler = asc;
        }

        public String getName()
        {
            return FXGCompiler.COMPILER_NAME;
        }

        public boolean isSupported(String mimeType)
        {
            return FXGCompiler.this.isSupported(mimeType);
        }

        public String[] getSupportedMimeTypes()
        {
            return FXGCompiler.this.getSupportedMimeTypes();
        }

        /**
         * We parse the FXG document and build a custom DOM representation.
         * <p>
         * We also establish the qualified name of our generated ActionScript
         * class and ensure its base class 'spark.core.SpriteVisualElement' is
         * listed in the inheritance dependencies (so that the CompilerAPI
         * will resolve it before we attempt to compile the ActionScript in
         * later phases).
         * </p>
         */
        public CompilationUnit parse1(Source source, SymbolTable symbolTable)
        {
            CompilerContext context = new CompilerContext();
            CompilationUnit unit = source.newCompilationUnit(null, context);

            // Setup a logger to bridge FXG and Flex logging systems
            setupLogger();

            // Setup the FXG Parser using either the mobile or desktop profile
            FXGParser parser;
            if (FXG_PROFILE_MOBILE.equals(profile))
            	parser = FXGParserFactory.createDefaultParserForMobile();
            else
            	parser = FXGParserFactory.createDefaultParser();

            // Register Flex specific FXG nodes
            parser.registerElementNode(1.0, FXG_NAMESPACE, FXG_GRAPHIC_ELEMENT, FlexGraphicNode.class);
            parser.registerElementNode(1.0, FXG_NAMESPACE, FXG_TEXTGRAPHIC_ELEMENT, FlexTextGraphicNode.class);
            parser.registerElementNode(1.0, FXG_NAMESPACE, FXG_P_ELEMENT, FlexParagraphNode.class);
            parser.registerElementNode(1.0, FXG_NAMESPACE, FXG_SPAN_ELEMENT, FlexSpanNode.class);
            parser.registerElementNode(2.0, FXG_NAMESPACE, FXG_GRAPHIC_ELEMENT, FlexGraphicNode.class);
            parser.registerElementNode(2.0, FXG_NAMESPACE, FXG_RICHTEXT_ELEMENT, FlexRichTextNode.class);

            try
            {
                // Parse FXG to a DOM
                FXGNode node = parser.parse(source.getInputStream(), source.getNameForReporting());
                context.setAttribute(FXG_DOM_ROOT, node);

                QName topLevelQName = getQNameFromSource(source);
                unit.topLevelDefinitions.add(topLevelQName);

                MultiName baseMultiName = MULTINAME_SPRITEVISUALELEMENT;
                if (node instanceof GraphicNode)
                {
                	GraphicNode graphicNode = (GraphicNode)node;
                	if (graphicNode.baseClassName != null)
                	{
                		String pkg = "";
                		String baseClassName = graphicNode.baseClassName;
                		String className = baseClassName;
                		int lastDot = baseClassName.lastIndexOf(".");
                		if (lastDot > -1)
                		{
                			pkg = baseClassName.substring(0, lastDot);
                			className = baseClassName.substring(lastDot + 1);
                		}
                		baseMultiName = new MultiName(NameFormatter.toColon(pkg, className));
                	}
                }
                // We add the base class for our generated skeleton here so that
                // the type will be resolved after returning from parse1() and
                // before we get to analyze2().
                unit.inheritance.add(baseMultiName);
            }
            catch (FXGException ex)
            {
                ThreadLocalToolkit.log(new FXGParseException(ex),
                        source, ex.getLineNumber(), ex.getColumnNumber());
                unit = null;
            }
            catch (IOException ex)
            {
                ThreadLocalToolkit.log(new FXGParseException(ex),
                		source);
                unit = null;
            }

            return unit;
        }

        /**
         * We now generate the skeleton class and introduce additional
         * dependencies on ActionScript types needed before our second pass
         * compilation, such as our implementation of &lt;TextGraphic&gt; and
         * any of it child tags (if the FXG DOM says that they're needed). 
         */
        @Override
        public void parse2(CompilationUnit unit, SymbolTable symbolTable)
        {
            Source generatedSource = null;
            Source originalSource = unit.getSource();

            // Determine whether we need to introduce text class dependencies
            FXGNode rootNode = (FXGNode)unit.getContext().getAttribute(FXG_DOM_ROOT);
            boolean hasTextGraphic = false;
            String baseClassName = null;
            double version = 1.0;

            if (rootNode instanceof FlexGraphicNode)
            {
                FlexGraphicNode graphicNode = (FlexGraphicNode)rootNode;
                FXGVersion v = graphicNode.getVersion();
                version = v != null ? v.asDouble() : 1.0;
                hasTextGraphic = graphicNode.hasText;
                baseClassName = graphicNode.baseClassName;
            }

            try
            {
                generatedSource = generateSource(originalSource, symbolTable, version, hasTextGraphic, baseClassName);
            }
            catch (IOException ex)
            {
                ThreadLocalToolkit.log(new SourceGenerationException(ex), originalSource);
                return;
            }

            // Compile our generated source with ASC 
            CompilationUnit interfaceUnit = delegateSubCompiler.parse1(generatedSource, symbolTable);

            if (interfaceUnit != null)
            {
                unit.getSource().addFileIncludes(interfaceUnit.getSource());
                unit.getContext().setAttribute(DELEGATE_UNIT, interfaceUnit);

                //TODO: Establish FXG -> generated ActionScript line number map
                //unit.getContext().setAttribute(LINE_NUMBER_MAP, lineNumberMap);

                Source.transferMetaData(interfaceUnit, unit);
            }
            else
            {
                return;
            }

            delegateSubCompiler.parse2(interfaceUnit, symbolTable);
        }

        /**
         * Does nothing. By not producing byte code here the CompilerAPI will
         * reset its compilation workflow and start again giving us the chance
         * to do our second-pass and create a concrete implementation.
         */
        @Override
        public void generate(CompilationUnit unit, SymbolTable symbolTable)
        {
            // No-op.
        }

        /**
         * Generates a skeleton ActionScript file with a name in the form of
         * '[packageName]/[className]-interface.as' to introduce class
         * dependencies to ensure they are compiled before the concrete
         * implementation in generated in the second pass.
         *
         * <p>For example, given a document '/assets/SampleGraphic.fxg' that
         * made use of &lt;TextGraphic&gt;, the following skeleton class would
         * be generated:</p>
         * <pre>
         * package assets
         * {
         * 
         * import flashx.textLayout.elements.ParagraphElement;
         * import flashx.textLayout.elements.SpanElement;
         * import spark.components.RichText;
         * import spark.core.SpriteVisualElement;
         * 
         * public class SampleGraphic extends SpriteVisualElement
         * {
         *     public function SampleGraphic()
         *     {
         *         super();
         *     }
         * 
         *     private static var _temp0:ParagraphElement;
         *     private static var _temp1:SpanElement;
         *     private static var _temp2:RichText;
         * }
         * }
         * </pre>
         * @param originalSource - the .fxg source file
         * @param symbolTable - the symbol table of ActionScript types
         * @param version - the FXG version
         * @param hasText - whether the document made use of text 
         */
        private Source generateSource(Source originalSource, SymbolTable symbolTable,
                double version, boolean hasText, String baseClassName) throws IOException
        {
            // Derive package/class names from source name and location
            String className = originalSource.getShortName();
            String packageName = originalSource.getRelativePath().replace('/','.');
            String generatedName = getGeneratedFileName(packageName, className, "-interface.as");

            // Generate ActionScript source code for our skeleton class
            StringBuilder buf = new StringBuilder(384);
            buf.append("package ").append(packageName).append("\n{\n\n");

            if (hasText)
            {
                if (version >= 2.0)
                {
                    buf.append("import flashx.textLayout.elements.*;\n");
                    buf.append("import flashx.textLayout.formats.TextLayoutFormat;\n");
                }
                else
                {
                    buf.append("import flashx.textLayout.elements.ParagraphElement;\n");   
                    buf.append("import flashx.textLayout.elements.SpanElement;\n");
                }
                buf.append("import spark.components.RichText;\n");
            }

            if (baseClassName != null)
            {
                buf.append("import ");
                buf.append(baseClassName);
                buf.append(";\n\n");
                buf.append("public class ").append(className).append(" extends ");
                buf.append(baseClassName);
                buf.append("\n{\n");            	
            }
            else
            {
                buf.append("import spark.core.SpriteVisualElement;\n\n");
                buf.append("public class ").append(className).append(" extends SpriteVisualElement\n{\n");            	
            }
            buf.append("    public function ").append(className).append("()\n");
            buf.append("    {\n");
            buf.append("        super();\n");
            buf.append("    }\n\n");

            if (hasText)
            {
                buf.append("    private static var _temp0:ParagraphElement;\n");
                buf.append("    private static var _temp1:SpanElement;\n");
                buf.append("    private static var _temp2:RichText;\n");

                if (version >= 2.0)
                {
                    buf.append("    private static var _temp3:DivElement;\n");
                    buf.append("    private static var _temp4:InlineGraphicElement;\n");
                    buf.append("    private static var _temp5:LinkElement;\n");
                    buf.append("    private static var _temp6:TabElement;\n");
                    buf.append("    private static var _temp7:TCYElement;\n");
                    buf.append("    private static var _temp8:TextLayoutFormat;\n");
                }
            }

            buf.append("}\n");
            buf.append("}\n");
            String generatedCode = buf.toString();
            buf = null;

            // Create a text file for our generated source 
            TextFile generatedFile = new TextFile(generatedCode, generatedName,
                    originalSource.getParent(), MimeMappings.AS,
                    originalSource.getLastModified());

            if (generatedOutputDir != null)
            {
                new File(generatedName).getParentFile().mkdirs();
                FileUtil.writeFile(generatedName, generatedCode);
            }

            // Create a new Source for the generated file but based on our
            // original Source to preserve information like last modified. 
            Source generatedSource = new Source(generatedFile, originalSource);

            return generatedSource;
        }
       
    }

    /**
     * Generates the concrete ActionScript implementation and associated
     * SWF DefineSprite based transcoded asset.
     */
    private final class ImplementationCompiler extends AbstractDelegatingSubCompiler
    {
        private ImplementationCompiler(CompilerConfiguration config)
        {
            // Create an As3Compiler as our delegate sub-compiler.
            As3Compiler asc = new As3Compiler(config);
            delegateSubCompiler = asc;
        }

        public String getName()
        {
            return FXGCompiler.COMPILER_NAME;
        }

        public boolean isSupported(String mimeType)
        {
            return FXGCompiler.this.isSupported(mimeType);
        }

        public String[] getSupportedMimeTypes()
        {
            return FXGCompiler.this.getSupportedMimeTypes();
        }

        /**
         * Transcode our DOM to SWF graphics primitives and generate the
         * concrete ActionScript source for ASC compilation.
         */
        public CompilationUnit parse1(Source source, SymbolTable symbolTable)
        {
            CompilationUnit unit = source.getCompilationUnit();

            // Now we can generate the concrete implementation for the FXG DOM
            // saved in the CompilationUnit's context from the parse1() phase
            // of SkeletonCompiler.
            try
            {
                Source generatedSource = generateSource(unit, symbolTable);
                if (generatedSource != null)
                    generatedSource.addFileIncludes(source);

                // Then we delegate to ASC to process our generated source.
                CompilationUnit implementationUnit = delegateSubCompiler.parse1(generatedSource, symbolTable);
                if (implementationUnit != null)
                {
                    // Transfer includes from the ASC unit to the FXG unit
                    unit.getSource().addFileIncludes(implementationUnit.getSource());
                    unit.getContext().setAttribute(DELEGATE_UNIT, implementationUnit);
                    //context.setAttribute(LINE_NUMBER_MAP, lineNumberMap);
                    Source.transferMetaData(implementationUnit, unit);
                    Source.transferGeneratedSources(implementationUnit, unit);
                    Source.transferDefinitions(implementationUnit, unit);
                    Source.transferInheritance(implementationUnit, unit);
                }
                else
                {
                    unit = null;
                }
            }
            catch (FXGException ex)
            {
                ThreadLocalToolkit.log(new SourceGenerationException(ex),
                        source, ex.getLineNumber(), ex.getColumnNumber());
                unit = null;
            }
            catch (IOException ex)
            {
                ThreadLocalToolkit.log(new SourceGenerationException(ex), source);
                unit = null;
            }

            return unit;
        }

        //----------------------------------------------------------------------
        //
        //  Source Generation
        //
        //----------------------------------------------------------------------

        /**
         * Takes an FXG DOM from the CompilationUnit context and converts it to
         * a SWF graphic primitive DefineSprite based display list. It also
         * generates an ActionScript class that will be linked to this
         * DefineSprite symbol by registering it as an asset of the
         * CompilationUnit. Additional symbols will be generated for child
         * sprites corresponding to &lt;TextGraphic&gt; nodes.
         */
        private Source generateSource(CompilationUnit unit, SymbolTable symbolTable) throws IOException
        {
            Source originalSource = unit.getSource();

            // package/class is derived from source name and location
            String className = originalSource.getShortName();
            String packageName = originalSource.getRelativePath().replace('/','.');

            // TypeTable will be used to determine if an text related FXG
            // attribute apply to a property or style of the associated
            // ActionScript API.
            TypeTable typeTable = new TypeTable(symbolTable, nameMappings, unit.getStandardDefs(),
                                                themeNames);

            // Transcode the FXG DOM to SWF graphics primitives
            FXGSymbolClass asset = transcodeFXG(unit, packageName, className, typeTable);

            // Generate the main source and associate the top level DefineSprite
            Source generatedSource = generateMainSource(unit, packageName, className, asset);

            // Handle any additional generated child sprite classes
            List<FXGSymbolClass> additionalAssets = asset.getAdditionalSymbolClasses();
            if (additionalAssets != null && additionalAssets.size() > 0)
            {
                Map<QName, Source> additionalSources = new HashMap<QName, Source>(additionalAssets.size());
                for (FXGSymbolClass additionalAsset : additionalAssets)
                {
                    if (additionalAsset.getSymbol() != null)
                    {
                        Source additionalSource = generateAdditionalSource(unit, additionalAsset);
                        if (additionalSource != null)
                        {
                            QName additionalQName = new QName(additionalAsset.getPackageName(), additionalAsset.getClassName()); 
                            additionalSources.put(additionalQName, additionalSource);
                        }
                    }
                }
                unit.addGeneratedSources(additionalSources);
            }

            return generatedSource;
        }

        /**
         * Generates the concrete ActionScript implementation for our FXG
         * symbol and associate the DefineSprite asset with the CompilationUnit.
         * 
         * @param unit - the CompilationUnit for the FXG component.
         * @param packageName - the package of the FXG component.
         * @param className - the className of the FXG component.
         * @param asset - the result of transcoding the FXG document.
         * @return the generated source.
         * @throws IOException
         */
        private Source generateMainSource(CompilationUnit unit,
                String packageName, String className, FXGSymbolClass asset) throws IOException
        {
            Source originalSource = unit.getSource();

            String generatedName = getGeneratedFileName(packageName, className, "-generated.as");

            if (generatedOutputDir != null)
            {
                new File(generatedName).getParentFile().mkdirs();
                FileUtil.writeFile(generatedName, asset.getGeneratedSource());
            }

            // Create a TextFile for our generated source 
            TextFile generatedFile = new TextFile(asset.getGeneratedSource(), generatedName,
                    originalSource.getParent(), MimeMappings.AS,
                    originalSource.getLastModified());

            // Create an AssetInfo for our DefineSprite symbol
            AssetInfo assetInfo = new AssetInfo(asset.getSymbol(), generatedFile,
                    originalSource.getLastModified(), null);
            unit.getAssets().add(asset.getQualifiedClassName(), assetInfo);

            // Create a Source and associate our symbol's AssetInfo 
            Source generatedSource = new Source(generatedFile, originalSource);
            generatedSource.setAssetInfo(assetInfo);

            return generatedSource;
        }

        /**
         * Additional sources may be generated after transcoding an
         * FXG document if &lt;TextGraphic&gt; was encountered. This method
         * mimics mxmlc DefineSprite-based asset transcoding by generating a
         * source and associates the DefineSprite using an AssetInfo with the
         * CompilationUnit.
         * 
         * @param unit - the CompilationUnit for the FXG component.
         * @param asset - an additional asset created while transcoded the
         * FXG document.
         * @return the generated source.
         * @throws IOException
         */
        private Source generateAdditionalSource(CompilationUnit unit,
                FXGSymbolClass asset) throws IOException
        {
            Source originalSource = unit.getSource();

            String packageName = asset.getPackageName();
            String className = asset.getClassName();
            String generatedName = getGeneratedFileName(packageName, className, ".as");

            if (generatedOutputDir != null)
            {
                new File(generatedName).getParentFile().mkdirs();
                FileUtil.writeFile(generatedName, asset.getGeneratedSource());
            }

            // Create a TextFile for our additional generated source 
            TextFile generatedFile = new TextFile(asset.getGeneratedSource(),
                    generatedName, originalSource.getParent(), MimeMappings.AS,
                    originalSource.getLastModified());

            // Create an AssetInfo for our DefineSprite symbol
            AssetInfo assetInfo = new AssetInfo(asset.getSymbol(),
                    generatedFile, originalSource.getLastModified(), null);
            unit.getAssets().add(asset.getQualifiedClassName(), assetInfo);

            String relativePath = "";
            if (packageName != null)
            {
                relativePath = packageName.replace( '.', '/' );
            }

            // Create a Source and associate our symbol's AssetInfo 
            Source generatedSource = new Source(generatedFile, relativePath,
                    className, null, false, false, false);
            generatedSource.setAssetInfo(assetInfo);
            generatedSource.setPathResolver(unit.getSource().getPathResolver());

            return generatedSource;
        }

        /**
         * Transcodes an FXG DOM to a DefineSprite hierarchy and associated
         * symbol classes.
         * 
         * @param unit - the CompilationUnit for the FXG component.
         * @param packageName - the package of the FXG component.
         * @param className - the className of the FXG component.
         * @param typeTable - the TypeTable to resolve type information from
         * the ActionScript text classes.
         * @return the SWF asset information for the transcoded FXG (potentially
         * several symbol classes and DefineSprites if &lt;TextGraphic&gt; was
         * used in the document). 
         */
        private FXGSymbolClass transcodeFXG(CompilationUnit unit,
                String packageName, String className, TypeTable typeTable)
        {
            FXGNode rootNode = (FXGNode)unit.getContext().getAttribute(FXG_DOM_ROOT);

            FlexFXG2SWFTranscoder transcoder = new FlexFXG2SWFTranscoder(typeTable);
            PathResolver pathResolver = unit.getSource().getPathResolver();
            FlexResourceResolver resolver = new FlexResourceResolver(pathResolver);
            transcoder.setResourceResolver(resolver);

            FXGSymbolClass asset = transcoder.transcode(rootNode, packageName, className);
            return asset;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Errors and Warnings
    //
    //--------------------------------------------------------------------------

    // Invalid component name '${name}': component name must be legal ActionScript class name.
    public static class InvalidComponentName extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4116465034363649658L;
        public final String name;
        public InvalidComponentName(String name)
        {
            this.name = name;
        }
    }

    // FXG parse exception
    public static class FXGParseException extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4714330790773345898L;

        public FXGParseException(Throwable rootCause)
        {
            super(rootCause);
        }
    }

    // FXG source generation exception
    public static class SourceGenerationException extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -395170674941663888L;

        public SourceGenerationException(Throwable rootCause)
        {
            super(rootCause);
        }
    }
}
