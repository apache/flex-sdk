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

import flash.css.StyleCondition;
import flash.css.StyleDeclaration;
import flash.css.StyleDeclarationBlock;
import flash.css.StyleProperty;
import flash.css.StyleSelector;
import flash.swf.tags.DefineFont;
import flash.swf.tags.DefineTag;
import flash.util.FileUtils;
import flash.util.StringJoiner;
import flash.util.Trace;
import flex2.compiler.config.ServicesDependenciesWrapper;
import flex2.compiler.*;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.as3.binding.ClassInfo;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.css.StyleDef;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.FramesConfiguration;
import flex2.compiler.common.MxmlConfiguration;
import flex2.compiler.common.RuntimeSharedLibrarySettingsConfiguration;
import flex2.compiler.common.Configuration.RslPathInfo;
import flex2.compiler.common.FramesConfiguration.FrameInfo;
import flex2.compiler.css.StylesContainer;
import flex2.compiler.extensions.ExtensionManager;
import flex2.compiler.extensions.IPreLinkExtension;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.TextFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.swc.Digest;
import flex2.compiler.swc.Swc;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.Name;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.SwcDependencyUtil;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.VelocityException;
import flex2.linker.CULinkable;
import flex2.linker.DependencyWalker.LinkState;
import flex2.linker.LinkerException;

import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * A flex2.compiler.PreLink implementation, which creates the FlexInit
 * and SystemManager subclass.
 *
 * @author Clement Wong
 * @author Roger Gonzalez (mixin, flexinit, bootstrap)
 * @author Basil Hosmer (service config)
 * @author Brian Deitte (font)
 * @author Cathy Murphy (accessibility)
 * @author Gordon Smith (i18n)
 */
public class PreLink implements flex2.compiler.PreLink
{
    private final static String DEFAULTS_CSS = "defaults.css";
    private final static String DEFAULTS_DASH = "defaults-";
    private final static String DOT_CSS = ".css";

    public boolean run(List<Source> sources, List<CompilationUnit> units,
                    FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath, ResourceBundlePath bundlePath,
                    ResourceContainer resources, SymbolTable symbolTable, CompilerSwcContext swcContext,
                    NameMappings nameMappings, Configuration configuration)
    {
        int initialSourceCount = sources.size();

        Set<IPreLinkExtension> extensions = 
            ExtensionManager.getPreLinkExtensions( configuration.getCompilerConfiguration().getExtensionsConfiguration().getExtensionMappings() );
        for ( IPreLinkExtension extension : extensions )
        {
            if(ThreadLocalToolkit.errorCount() == 0) {
                extension.run( sources, units, fileSpec, sourceList, sourcePath, bundlePath, resources, symbolTable,
                                  swcContext, configuration );
            }
        }
        boolean reRunPrelink = processMainUnit(sources, units, resources, symbolTable, nameMappings, configuration);

        // Check if additional sources were generated after processing the
        // main compilation unit. The compiler will need to re-run pre-link.
        if (sources.size() > initialSourceCount || reRunPrelink)
        {
        	return true;
        }

        return false;
    }

    /**
     * generate sources for units which require complete set of original units as type context
     */
    public void postRun(List<Source> sources, List<CompilationUnit> units,
                        ResourceContainer resources,
                        SymbolTable symbolTable,
                        CompilerSwcContext swcContext,
                        NameMappings nameMappings,
                        Configuration configuration)
    {
        LinkedList<Source> extraSources = new LinkedList<Source>();
        LinkedList<String> mixins = new LinkedList<String>();
        LinkedList<DefineTag> fonts = new LinkedList<DefineTag>();
        Set<String> contributingSwcs = new HashSet<String>();
        
        // Build a set, such as { "core", "controls" }, of the names
        // of all resource bundles used in all compilation units.
        // This will be used to set the compiledResourceBundleNames
        // property of the module factory's info() Object
        // and the compileResourceBundleNames property
        // of the _CompileResourceBundleInfo class.
        processResourceBundleNames(units, configuration);

        // TODO - factor out the unit iteration / list discovery to a more clear separate step

        // Autogenerate the _MyApp_FlexInit class.
        processInitClass(units, configuration, extraSources, mixins, fonts, contributingSwcs, swcContext);

        // Autogenerate the _MyApp_mx_managers_SystemManager class.
        boolean generatedLoaderClass = processLoaderClass(units, configuration, extraSources, 
                                                          mixins, fonts, contributingSwcs, 
                                                          swcContext);

        // Autogenerate the _CompiledResourceBundleInfo class if we didn't autogenerate a loader class.
        // This enables non-framework apps which simply extend Sprite to use the ResourceManager.
        if (!generatedLoaderClass)
            processCompiledResourceBundleInfoClass(units, configuration, extraSources, mixins, fonts, swcContext);

        // Add the autogenerated sources to the ResourceContainer, so
        // they can be resolved in subsequent incremental compilations,
        // where the main unit doesn't require recompilation.
        for (Source extraSource : extraSources)
        {
            sources.add(resources.addResource(extraSource));
        }

        CompilerConfiguration compilerConfiguration = configuration.getCompilerConfiguration();
        int compatibilityVersion = compilerConfiguration.getCompatibilityVersion();

        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
        TypeAnalyzer typeAnalyzer = symbolTable.getTypeAnalyzer();
        assert(typeAnalyzer != null);
        
        for (int i = 0, length = units.size(); i < length; i++)
        {
            CompilationUnit u = (CompilationUnit) units.get(i);

            if (u.isRoot())
            {
                StylesContainer stylesContainer =
                    (StylesContainer) symbolTable.getContext().getAttribute(StylesContainer.class.getName());
                StylesContainer rootStylesContainer = u.getStylesContainer();

                // If the backgroundColor wasn't specified inline, go looking for it in CSS.
                if ((u.swfMetaData == null) || (u.swfMetaData.getValue("backgroundColor") == null))
                {
                    QName qName = u.topLevelDefinitions.last();
                    
                    if (qName != null)
                    {
                        String def = qName.toString();
                        lookupBackgroundColor(stylesContainer, rootStylesContainer, u.styleName,
                                              NameFormatter.toDot(def), symbolTable, configuration);
                    }
                }

                if (rootStylesContainer != null)
                {
                    // Swap in root's Logger, so warnings get associated correctly.
                    Logger originalLogger = ThreadLocalToolkit.getLogger();
                    ThreadLocalToolkit.setLogger(u.getSource().getLogger());
                    rootStylesContainer.validate(symbolTable, nameMappings, u.getStandardDefs(),
                                                 compilerConfiguration.getThemeNames(), null);
                    ThreadLocalToolkit.setLogger(originalLogger);
                }

                Source source = u.getSource();

                // Now that we're done validating the StyleContainer,
                // we can disconnect the root's logger.
                source.disconnectLogger();

                // Clear the root's path resolver, so the
                // CompilationUnit doesn't hold onto the global path
                // resolver, which has strong references to things
                // like the SourcePath, which we want freed up at the
                // end of a compilation.  All the other
                // CompilationUnit's have their PathResolver cleared
                // when they reach the ABC state.  We hold onto the
                // root's path resolver until now, because of the
                // styles
                source.setPathResolver(null);

                // C: we don't need the styles container anymore
                u.setStylesContainer(null);
            }
            else if (generatedLoaderClass && !u.getSource().isInternal() && !u.getSource().isSwcScriptOwner())
            {
                // Check if the source is a module or an application. If it is and we know it 
                // is not the root then generate a warning.
                if (typeAnalyzer != null)
                {
                    for (QName qName : u.topLevelDefinitions)
                    {
                        ClassInfo info = typeAnalyzer.getClassInfo(qName.toString());
                        checkForModuleOrApplication(standardDefs, typeAnalyzer, info, qName, configuration);
                    }
                }
            }
            
            // Only check the dependencies of hand written compilation units.
            if (!u.getSource().isSwcScriptOwner() && compilerConfiguration.enableSwcVersionFiltering())
            {
                Set<Name> dependencies = new HashSet<Name>();
                dependencies.addAll(u.inheritance);
                dependencies.addAll(u.namespaces);
                dependencies.addAll(u.expressions);
                dependencies.addAll(u.types);

                for (Name name : dependencies)
                {
                    if (name instanceof QName)
                    {
                        Source dependent = symbolTable.findSourceByQName((QName) name);

                        if (dependent.isSwcScriptOwner())
                        {
                            SwcScript swcScript = (SwcScript) dependent.getOwner();
                            Swc swc = swcScript.getLibrary().getSwc();
                        
                            // Make sure each dependency's minimum
                            // supported version is less than or equal to
                            // the compatibility version.
                            if (compatibilityVersion < swc.getVersions().getMinimumVersion())
                            {
                                DependencyNotCompatible message =
                                    new DependencyNotCompatible(swcScript.getName().replace('/', '.'),
                                                                swc.getLocation(),
                                                                swc.getVersions().getMinimumVersionString(),
                                                                compilerConfiguration.getCompatibilityVersionString());
                                ThreadLocalToolkit.log(message, u.getSource());
                            }
                        }
                    }
                }
            }
        }
    }

    
    /**
     * Determine if the class is a module or an application.
     * 
     * @param standardDefs
     * @param typeAnalyzer
     * @param info - ClassInfo of the class being check.
     * @param root - CompilationUnit of the root, may not be null.
     * @param qName - qName of the class being checked.
     * @param configuration
     */
    private void checkForModuleOrApplication(StandardDefs standardDefs, TypeAnalyzer typeAnalyzer,
                                        ClassInfo info, QName qName, Configuration configuration)
    {
        if (info != null)
        {
            // Does the class implement IModule or extend one of the Application classes.
            if (info.implementsInterface(standardDefs.getModulesPackage(), 
                                         StandardDefs.INTERFACE_IMODULE_NO_PACKAGE) ||
                info.extendsClass(StandardDefs.CLASS_APPLICATION) ||
                info.extendsClass(StandardDefs.CLASS_SPARK_APPLICATION))
            {
                // Now test that the root does not extend or implement this class before we generate a
                // warning.
                ClassInfo rootInfo = typeAnalyzer.getClassInfo(configuration.getMainDefinition());
                if (rootInfo != null &&
                    !rootInfo.implementsInterface(qName.getNamespace(), qName.getLocalPart()) &&
                    !rootInfo.extendsClass(qName.toString()))
                {
                    ThreadLocalToolkit.getLogger().log(new CompiledAsAComponent(qName.toString(), 
                                                       configuration.getMainDefinition()));
                }
            }
        }
        
    }

    private void locateStyleDefaults(List<CompilationUnit> units, CompilerConfiguration compilerConfiguration)
    {
        Set<VirtualFile> defaultsCssFiles = new HashSet<VirtualFile>();
        String versionDefaultsCssFileName = null;

        if (compilerConfiguration.getCompatibilityVersionString() != null)
        {
            versionDefaultsCssFileName = DEFAULTS_DASH + compilerConfiguration.getCompatibilityVersionString() + DOT_CSS;
        }

        for (int i = 0, length = units.size(); i < length; i++)
        {
            CompilationUnit compilationUnit = (CompilationUnit) units.get(i);
            assert compilationUnit != null : "Must have missed a forcedToStop() check after the most recent batch()";
            Source source = compilationUnit.getSource();

            if (source.isSwcScriptOwner())
            {
                SwcScript swcScript = (SwcScript) source.getOwner();
                Swc swc = swcScript.getLibrary().getSwc();
                VirtualFile defaultsCssFile = null;

                if (versionDefaultsCssFileName != null)
                {
                    defaultsCssFile = swc.getFile(versionDefaultsCssFileName);
                }

                if (defaultsCssFile == null)
                {
                    defaultsCssFile = swc.getFile(DEFAULTS_CSS);
                }

                if (defaultsCssFile != null)
                {
                    defaultsCssFiles.add(defaultsCssFile);
                }
            }
        }

        // TODO: figure out how to get these into the correct order
        compilerConfiguration.addDefaultsCssFiles(defaultsCssFiles);
    }

    private boolean processMainUnit(List<Source> sources, List<CompilationUnit> units, ResourceContainer resources,
                                 SymbolTable symbolTable, NameMappings nameMappings, Configuration configuration)
    {
        boolean generatedSources = false;

        for (int i = 0, length = units.size(); i < length; i++)
        {
            CompilationUnit u = (CompilationUnit) units.get(i);

            if (u.isRoot())
            {
                swfmetadata(u, configuration);

                if (u.loaderClass != null)
                {
                    configuration.setRootClassName(u.loaderClass);
                }

                // set the last top level definition as the main definition.  Setting the last one allows
                // for Embed classes at the top of the file
                QName qName = u.topLevelDefinitions.last();

                if (qName != null)
                {
                    String def = qName.toString();
                    configuration.setMainDefinition(def);
                    u.getContext().setAttribute("mainDefinition", def);

					// i.e. isApplication... need loader class for styles.
					// We also need styles for an AS file that subclasses Application or Module.
                    if (u.loaderClass != null || u.loaderClassBase != null)
                    {
                        CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();

                        StylesContainer stylesContainer =
                            (StylesContainer) symbolTable.getContext().getAttribute(StylesContainer.class.getName());

                        if (stylesContainer == null)
                        {
                            stylesContainer = new StylesContainer(compilerConfig, u, symbolTable.perCompileData);
                            stylesContainer.setNameMappings(nameMappings);
                            symbolTable.getContext().setAttribute(StylesContainer.class.getName(), stylesContainer);
                        }

                        // locate style defaults each time through,
                        // because new dependencies could have brought
                        // in new SWC files with a defaults.css file.
                        List<VirtualFile> cssFiles = compilerConfig.getDefaultsCssFiles();
                        Set<String> cssFilesSet = new HashSet<String>();
                        
                        for (VirtualFile cssFile : cssFiles )
                        {
                            cssFilesSet.add(cssFile.getName());
                        }
                        
                        locateStyleDefaults(units, compilerConfig);
                        
                        cssFiles = compilerConfig.getDefaultsCssFiles();
                        Set<String> addedCssFilesSet = null;
                        
                        if (!cssFilesSet.isEmpty())
                        {
                            Set<String> secondCssFilesSet = new HashSet<String>();
                            
                            for (VirtualFile cssFile : cssFiles )
                            {
                                secondCssFilesSet.add(cssFile.getName());
                            }
                            
                            addedCssFilesSet = new HashSet<String>();
                            for (String cssName : secondCssFilesSet )
                            {
                                if (!cssFilesSet.contains(cssName))
                                {
                                    addedCssFilesSet.add(cssName);
                                }
                            }
                        }
                        
                        stylesContainer.loadDefaultStyles();
                        stylesContainer.validate(symbolTable, nameMappings, u.getStandardDefs(), compilerConfig.getThemeNames(), addedCssFilesSet);

                        List<CULinkable> linkables = new LinkedList<CULinkable>();

                        for (Iterator it2 = units.iterator(); it2.hasNext();)
                        {
                            linkables.add( new CULinkable( (CompilationUnit) it2.next() ) );
                        }

                        try
                        {
                            LinkState state = new LinkState(linkables, new HashSet(), configuration.getIncludes(), new HashSet<String>());

                            // C: generate style classes for components which we want to link in.
                            List<Source> styleSources = new ArrayList<Source>();
                            generatedSources = stylesContainer.processDependencies(styleSources, state.getDefNames(), resources, 
                                                                    u.getSource().getRelativePath().replace('/', '.'),
                                                                    u.getSource().getShortName());

                            // Sweep through and remove any previous style sources.
                            Iterator<Source> iterator = sources.iterator();

                            while (iterator.hasNext())
                            {
                                Source source = iterator.next();

                                for (Source styleSource : styleSources)
                                {
                                    if (source.getName().equals(styleSource.getName()))
                                    {
                                        iterator.remove();
                                        break;
                                    }
                                }
                            }

                            // Now add the new style sources.
                            sources.addAll(styleSources);
                        }
                        catch (LinkerException e)
                        {
                            ThreadLocalToolkit.log( e );
                        }
                    }
                }
                else
                {
                    ThreadLocalToolkit.log(new NoExternalVisibleDefinition(), u.getSource());
                }

                break;
            }
        }

        return generatedSources;
    }

    /**
     * Looks up the backgroundColor.  The first time through, if an
     * inline styleName from the MXML tag is available, it is used to
     * lookup a class selector.  Otherwise, we look for a styleName in
     * the local StylesContainer and then the global StylesContainer.
     * If found, we use it to lookup a class selector.  If a class
     * selector is found, we look for a backgroundColor style
     * property.  If a backgroundColor style property is not found, we
     * look for a type selector in the local StylesContainer and then
     * the global StylesContainer.  If found, we look for a
     * backgroundColor style property.  If the backgroundColor is
     * still not found, we recursively call lookupBackgroundColor()
     * using the super type.  If the backgroundColor is still not
     * found, we look for the backgroundColor in the global selector.
     */
    private static void lookupBackgroundColor(StylesContainer globalStylesContainer,
                                              StylesContainer localStylesContainer,
                                              String inlineStyleName,
                                              String className,
                                              SymbolTable symbolTable,
                                              Configuration configuration)
    {
        assert NameFormatter.toDot(className).equals(className);
        String styleName = inlineStyleName;

        if ((styleName == null) && (localStylesContainer != null))
        {
            styleName = lookupStyleName(localStylesContainer, className);
        }

        if ((styleName == null) && (globalStylesContainer != null))
        {
            styleName = lookupStyleName(globalStylesContainer, className);
        }

        int backgroundColor = -1;

        if ((styleName != null) && (localStylesContainer != null))
        {
            backgroundColor = lookupClassSelectorBackgroundColor(localStylesContainer, styleName);
        }

        if ((backgroundColor == -1) && (styleName != null) && (globalStylesContainer != null))
        {
            backgroundColor = lookupClassSelectorBackgroundColor(globalStylesContainer, styleName);
        }        

        if ((backgroundColor == -1) && (localStylesContainer != null))
        {
            backgroundColor = lookupTypeSelectorBackgroundColor(localStylesContainer, className);
        }

        if ((backgroundColor == -1) && (globalStylesContainer != null))
        {
            backgroundColor = lookupTypeSelectorBackgroundColor(globalStylesContainer, className);
        }

        if (backgroundColor == -1)
        {
            AbcClass abcClass = symbolTable.getClass(NameFormatter.toColon(className));

            if (abcClass != null)
            {
                String superTypeName = abcClass.getSuperTypeName();

                if (superTypeName != null)
                {
                    // The styleName is intentionally not passed in,
                    // because we've already tried doing a lookup with it.
                    lookupBackgroundColor(globalStylesContainer, localStylesContainer, null,
                                          NameFormatter.toDot(superTypeName),
                                          symbolTable, configuration);
                }
                else
                {
                    // A null superTypeName means that we've gone up
                    // the whole inheritance chain, so try the global
                    // selector.
                    if (localStylesContainer != null)
                    {
                        backgroundColor = lookupTypeSelectorBackgroundColor(localStylesContainer, "global");
                    }

                    if ((backgroundColor == -1) && (globalStylesContainer != null))
                    {
                        backgroundColor = lookupTypeSelectorBackgroundColor(globalStylesContainer, "global");
                    }
                }
            }
        }

        if (backgroundColor != -1)
        {
            configuration.setBackgroundColor(backgroundColor);
        }
    }

    /**
     * Looks for the backgroundColor in a type selector in the
     * StylesContainer.
     */
    private static int lookupTypeSelectorBackgroundColor(StylesContainer stylesContainer, String className)
    {
        int result = -1;
        StyleDef styleDef = stylesContainer.getStyleDef(className);
                        
        if (styleDef != null)
        {
            Map<String, StyleDeclaration> declarations = styleDef.getDeclarations();

            if (declarations != null)
            {
                for (StyleDeclaration styleDeclaration : declarations.values())
                {
                    Collection<StyleDeclarationBlock> blocks = styleDeclaration.getDeclarationBlocks();
                    for (StyleDeclarationBlock block : blocks)
                    {
                        StyleProperty styleProperty = block.getProperties().get("backgroundColor");
    
                        if (styleProperty != null)
                        {
                            Object value = styleProperty.getValue();
    
                            if (value instanceof String)
                            {
                                String backgroundColor = (String) value;
    
                                try
                                {
                                    result = Integer.decode(backgroundColor).intValue();
                                }
                                catch (NumberFormatException numberFormatException)
                                {
                                    ThreadLocalToolkit.log(new InvalidBackgroundColor(backgroundColor),
                                                           styleDeclaration.getPath(),
                                                           styleProperty.getLineNumber());
                                }
                            }
                            // If value is not a String an error will have been reported upstream.
                        }
                    }
                }
            }
        }

        return result;
    }

    /**
     * Looks for the backgroundColor in a class selector in the
     * StylesContainer.
     */
    private static int lookupClassSelectorBackgroundColor(StylesContainer stylesContainer, String styleName)
    {
        int result = -1;
        StyleDef styleDef = stylesContainer.getStyleDef("global");
                        
        if (styleDef != null)
        {
            Map<String, StyleDeclaration> declarations = styleDef.getDeclarations();

            if (declarations != null)
            {
                for (StyleDeclaration styleDeclaration : declarations.values())
                {
                    StyleSelector styleSelector = styleDeclaration.getSelector();

                    if (styleSelector != null)
                    {
                        List<StyleCondition> conditions = styleSelector.getConditions();

                        if (conditions != null)
                        {
                            for (StyleCondition styleCondition : conditions)
                            {
                                if ((styleCondition.getKind() == StyleCondition.CLASS_CONDITION) &&
                                    styleCondition.getValue().equals(styleName))
                                {
                                    Collection<StyleDeclarationBlock> blocks = styleDeclaration.getDeclarationBlocks();
                                    for (StyleDeclarationBlock block : blocks)
                                    {
                                        StyleProperty styleProperty = block.getProperties().get("backgroundColor");
    
                                        if (styleProperty != null)
                                        {
                                            Object value = styleProperty.getValue();
    
                                            if (value instanceof String)
                                            {
                                                String backgroundColor = (String) value;
    
                                                try
                                                {
                                                    result = Integer.decode(backgroundColor).intValue();
                                                }
                                                catch (NumberFormatException numberFormatException)
                                                {
                                                    ThreadLocalToolkit.log(new InvalidBackgroundColor(backgroundColor),
                                                                           styleDeclaration.getPath(),
                                                                           styleProperty.getLineNumber());
                                                }
                                            }
                                            // If value is not a String an error will have been reported upstream.
                                        }
                                    }
                                }
                                // The id attribute is not allowed on the
                                // root tag, so we don't need to handle
                                // StyleCondition.ID_CONDITION here.
                                // Also, StyleCondition.PSEUDO_CONDITION
                                // does not apply, because the root tag
                                // can not be in a state.
                            }
                        }
                    }
                }
            }
        }

        return result;
    }

    /**
     * Looks for the styleName in a type selector in the
     * StylesContainer.
     */
    private static String lookupStyleName(StylesContainer stylesContainer, String className)
    {
        String result = null;
        StyleDef styleDef = stylesContainer.getStyleDef(className);
                        
        if (styleDef != null)
        {
            for (StyleDeclaration styleDeclaration : styleDef.getDeclarations().values())
            {
                Collection<StyleDeclarationBlock> blocks = styleDeclaration.getDeclarationBlocks();
                for (StyleDeclarationBlock block : blocks)
                {
                    StyleProperty styleProperty = block.getProperties().get("styleName");
    
                    if (styleProperty != null)
                    {
                        Object value = styleProperty.getValue();
    
                        if (value instanceof String)
                        {
                            result = (String) value;
                        }
                    }
                }
            }
        }

        return result;
    }

    private static void swfmetadata(CompilationUnit u, Configuration cfg)
    {
        if (u.swfMetaData != null)
        {
            String widthString = u.swfMetaData.getValue("width");
            if (widthString != null)
            {
                cfg.setWidth(widthString);
            }

            String heightString = u.swfMetaData.getValue("height");
            if (heightString != null)
            {
                cfg.setHeight(heightString);
            }

            String widthPercent = u.swfMetaData.getValue("widthPercent");
            if (widthPercent != null)
            {
                cfg.setWidthPercent(widthPercent);
            }

            String heightPercent = u.swfMetaData.getValue("heightPercent");
            if (heightPercent != null)
            {
                cfg.setHeightPercent(heightPercent);
            }

            String scriptRecursionLimit = u.swfMetaData.getValue("scriptRecursionLimit");
            if (scriptRecursionLimit != null)
            {
                try
                {
                    cfg.setScriptRecursionLimit(Integer.parseInt(scriptRecursionLimit));
                }
                catch (NumberFormatException nfe)
                {
                    ThreadLocalToolkit.log(new CouldNotParseNumber(scriptRecursionLimit, "scriptRecursionLimit"));
                }
            }

            String scriptTimeLimit = u.swfMetaData.getValue("scriptTimeLimit");
            if (scriptTimeLimit != null)
            {
                try
                {
                    cfg.setScriptTimeLimit(Integer.parseInt(scriptTimeLimit));
                }
                catch (NumberFormatException nfe)
                {
                    ThreadLocalToolkit.log(new CouldNotParseNumber(scriptTimeLimit, "scriptTimeLimit"));
                }
            }

            String frameRate = u.swfMetaData.getValue("frameRate");
            if (frameRate != null)
            {
                try
                {
                    cfg.setFrameRate(Integer.parseInt(frameRate));
                }
                catch (NumberFormatException nfe)
                {
                    ThreadLocalToolkit.log(new CouldNotParseNumber(frameRate, "frameRate"));
                }
            }

            String backgroundColor = u.swfMetaData.getValue("backgroundColor");
            if (backgroundColor != null)
            {
                try
                {
                    cfg.setBackgroundColor(Integer.decode(backgroundColor).intValue());
                }
                catch (NumberFormatException numberFormatException)
                {
                    ThreadLocalToolkit.log(new InvalidBackgroundColor(backgroundColor), u.getSource());
                }
            }

            String pageTitle = u.swfMetaData.getValue("pageTitle");
            if (pageTitle != null)
            {
                cfg.setPageTitle(pageTitle);
            }
            
            String useDirectBlit = u.swfMetaData.getValue("useDirectBlit");
            if(useDirectBlit != null)
            {
            	cfg.setUseDirectBlit(Boolean.parseBoolean(useDirectBlit));
            }
            
            String useGPU = u.swfMetaData.getValue("useGPU");
            if(useGPU != null)
            {
            	cfg.setUseGpu(Boolean.parseBoolean(useGPU));
            }

            // fixme: error on SWF metadata we don't understand
        }
    }

    private SortedSet<String> resourceBundleNames = new TreeSet<String>();
    private SortedSet<String> externalResourceBundleNames = new TreeSet<String>();

    private void processResourceBundleNames(List units, flex2.compiler.common.Configuration configuration)
    {
        Set externs = configuration.getExterns();

         for (Iterator it = units.iterator(); it.hasNext();)
        {
            CompilationUnit unit = (CompilationUnit) it.next();
            if (unit.resourceBundleHistory.size() > 0)
            {
                resourceBundleNames.addAll(unit.resourceBundleHistory);

                if (externs.contains(unit.topLevelDefinitions.first().toString()))
                {
                    externalResourceBundleNames.addAll(unit.resourceBundleHistory);
                }
            }
        }
    }

    private String codegenFlexInit(String flexInitClassName, Set<String> accessibilityList,
                                   Map<String, String> remoteClassAliases, Map<String, String> effectTriggers,
                                   Set<String> inheritingStyles, Configuration configuration)
    {
        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
        CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();
        ServicesDependenciesWrapper servicesDependencies = compilerConfig.getServicesDependencies();

        StringBuilder sb = new StringBuilder();
        sb.append("package {\n");
        sb.append("import flash.display.DisplayObject;\n");
        sb.append("import flash.utils.*;\n");
        sb.append("import ").append(standardDefs.INTERFACE_IFLEXMODULEFACTORY_DOT).append(";\n");
        sb.append("import ").append(standardDefs.INTERFACE_ISTYLEMANAGER2_DOT).append(";\n");
        sb.append("import ").append(standardDefs.CLASS_REQUEST_DOT).append(";\n");
        sb.append("import ").append(standardDefs.CLASS_STYLEMANAGERIMPL_DOT).append(";\n");
        sb.append("import ").append(standardDefs.CLASS_SYSTEMMANAGERCHILDMANAGER_DOT).append(";\n");
        sb.append("import ").append(standardDefs.CLASS_TEXTFIELDFACTORY_DOT).append("; TextFieldFactory;\n");
        sb.append(codegenAccessibilityImports(accessibilityList));
        sb.append(codegenRemoteClassImports( remoteClassAliases ));
        sb.append(codegenEffectTriggerImports(effectTriggers, standardDefs));
        if (servicesDependencies != null)
            sb.append(servicesDependencies.getImports());
        
        sb.append(codegenResourceBundleMetadata(externalResourceBundleNames));
        
        sb.append("\n[Mixin]\n");
        sb.append("public class " + flexInitClassName + "\n");
        sb.append("{\n");
        sb.append("   public function " + flexInitClassName + "()\n");
        sb.append("   {\n");
        sb.append("       super();\n");
        sb.append("   }\n");
        sb.append("   public static function init(fbs:IFlexModuleFactory):void\n");
        sb.append("   {\n");
        sb.append("       new ChildManager(fbs);\n");

        sb.append("       var styleManager:IStyleManager2;\n");
        if ((configuration.getCompatibilityVersion() <= flex2.compiler.common.MxmlConfiguration.VERSION_3_0))
        {
            // For backwards compatibility use the top level style manager. 
            sb.append("       styleManager = StyleManagerImpl.getInstance();\n");
            sb.append("       fbs.registerImplementation(\"mx.styles::IStyleManager2\", styleManager);\n");
        }
        else if (!configuration.getCompilerConfiguration().getIsolateStyles())
        {
            // If this module factory is not creating its own style factory, then use its parent if available.
            // Fall back to using the top level style manager.
            sb.append("       var request:mx.events.Request = new mx.events.Request(mx.events.Request.GET_PARENT_FLEX_MODULE_FACTORY_REQUEST);\n");
            sb.append("       DisplayObject(fbs).dispatchEvent(request);\n");
            sb.append("       var moduleFactory:IFlexModuleFactory = request.value as IFlexModuleFactory;\n");
            sb.append("       if (moduleFactory)\n");
            sb.append("           styleManager = IStyleManager2(moduleFactory.getImplementation(\"mx.styles::IStyleManager2\"));\n\n");
            sb.append("       if (!styleManager)\n");
            sb.append("           styleManager = StyleManagerImpl.getInstance();\n");
            sb.append("       fbs.registerImplementation(\"mx.styles::IStyleManager2\", styleManager);\n");
        }
        else
        {
            sb.append("       styleManager = new StyleManagerImpl(fbs);\n");
        }
        
        sb.append(codegenQualifiedTypeSelectors(configuration));
        sb.append(codegenEffectTriggerRegistration(effectTriggers));
        sb.append(codegenAccessibilityList(accessibilityList));
        sb.append(codegenRemoteClassAliases(remoteClassAliases, flexInitClassName, configuration));
        sb.append(codegenInheritingStyleRegistration(inheritingStyles));
        if (servicesDependencies != null)
            sb.append(servicesDependencies.getServerConfigXmlInit());
        sb.append("   }\n");
        if (servicesDependencies != null)
            sb.append(servicesDependencies.getReferences());

        sb.append("}  // FlexInit\n");
        sb.append("}  // package\n");

        return sb.toString();
    }

    private void processInitClass(List units, Configuration configuration,
                                  List<Source> extraSources, LinkedList<String> mixins, 
                                  LinkedList<DefineTag> fonts,
                                  Set<String> contributingSwcs,
                                  CompilerSwcContext swcContext)
    {
        Set<String> accessibilityList = null;
        Map<String, String> remoteClassAliases = new TreeMap<String, String>()
      {
            private static final long serialVersionUID = -8015004853369794727L;

            /**
             *  Override so warning messages can be logged. 
             */
            public String put(String key, String value)
            {
                // check for duplicate values and log a warning if any remote 
                // classes try to use the same alias.
                if (containsValue(value))
                {
                   Object existingKey = null;
                   for (Iterator iter = entrySet().iterator(); iter.hasNext();)
                   {
                       Map.Entry entry = (Map.Entry)iter.next();
                       if (value != null && value.equals(entry.getValue()))
                       {
                           existingKey = entry.getKey();
                           break;
                       }
                   }
                   ThreadLocalToolkit.log(new ClassesMappedToSameRemoteAlias((String)key, (String)existingKey, (String)value));
                }
                return super.put(key, value);
            }
        
        };

        Map<String, String> effectTriggers = new TreeMap<String, String>();
        Set<String> inheritingStyles = new HashSet<String>();
        CompilationUnit mainUnit = null;
        Set externs = swcContext.getExterns();
        boolean removeUnusedRSLs = configuration.getRemoveUnusedRsls();
        
        for (int i = 0, size = units.size(); i < size; i++)
        {
            CompilationUnit u = (CompilationUnit) units.get(i);

            if (u.isRoot())
            {
                mainUnit = u;
            }

            if (u.hasAssets())
            {
                List<DefineFont> fontList = u.getAssets().getFonts();

                // don't add font assets for definitions that have been externed.
                if (fontList != null && !fontList.isEmpty() &&
                    !isCompilationUnitExternal(u, externs) &&
                    !u.getSource().isInternal())
                {
                    fonts.addAll(fontList);    // save for later...
                }
            }

            remoteClassAliases.putAll( u.remoteClassAliases );

            effectTriggers.putAll( u.effectTriggers );
            mixins.addAll( u.mixins );

            inheritingStyles.addAll( u.styles.getInheritingStyles() );

            if (configuration.getCompilerConfiguration().accessible())
            {
                Set<String> unitAccessibilityList = u.getAccessibilityClasses();
                if (unitAccessibilityList != null)
                {
                    if (accessibilityList == null)
                    {
                        accessibilityList = new HashSet<String>();
                    }
                    accessibilityList.addAll(unitAccessibilityList);
                }
            }
            
            if (removeUnusedRSLs)
            {
                // Record which swcs have contributed the scripts. We will use
                // this later to figure out which RSLs to load.
                Source source = u.getSource();
                
                if (!source.isInternal() && source.isSwcScriptOwner())
                {
                    SwcScript script = (SwcScript)source.getOwner();
                    contributingSwcs.add(script.getSwcLocation());
                }
            }
        }

        String flexInitClass = null;
        if (mainUnit != null)
        {
            for (Iterator it = mainUnit.extraClasses.iterator(); it.hasNext();)
            {
                String extraClass = (String) it.next();
                // FIXME - Depending on the contents of the classname is not the solution we want.
                if (extraClass.indexOf("FlexInit") != -1)
                {
                    flexInitClass = extraClass;
                    break;
                }
            }
        }

        if (flexInitClass != null)
        {
            String code = codegenFlexInit(flexInitClass, accessibilityList, remoteClassAliases,
                                          effectTriggers, inheritingStyles, configuration);
            String name = flexInitClass + "-generated.as";
            
            if (configuration.getCompilerConfiguration().keepGeneratedActionScript())
            {
                saveGenerated(name, code, configuration.getCompilerConfiguration().getGeneratedDirectory());
            }

            Source s = new Source(new TextFile(code, name, null, MimeMappings.getMimeType(name)), "", flexInitClass, null, false, false, false);
            // C: It doesn't look like this Source needs any path resolution. null is fine...
            s.setPathResolver(null);
            extraSources.add(s);
            mixins.addFirst( flexInitClass );   // we already iterated, lets put this one at the head in any case
        }

    }

    /**
     *
     * @param unit compilation unit, may not be null
     * @param externs - list of externs, may not be null
     * @return true if the compilation unit, u, has any definitions that are in the list of
     *            interns.
     */
    public static boolean isCompilationUnitExternal(CompilationUnit unit, Set externs)
    {
        for (int i = 0, size = unit == null ? 0 : unit.topLevelDefinitions.size(); i < size; i++)
        {
            if (externs.contains(unit.topLevelDefinitions.get(i).toString()))
            {
                return true;
            }
        }

        return false;
    }


    private boolean processLoaderClass(List units,
                                       Configuration configuration,
                                       List<Source> sources,
                                       List<String> mixins,
                                       List<DefineTag> fonts,
                                       Set<String> contributingSwcs,
                                       CompilerSwcContext swcContext)
    {
        if (!configuration.generateFrameLoader)
        {
            return false;
        }

        LinkedList<FrameInfo> frames = new LinkedList<FrameInfo>();
        frames.addAll( configuration.getFrameList() );

        CompilationUnit mainUnit = null;
         for (Iterator it = units.iterator(); it.hasNext();)
        {
            CompilationUnit unit = (CompilationUnit) it.next();
            if (unit.isRoot())
            {
                mainUnit = unit;
                break;
            }
        }

        if (mainUnit == null)
        {
            return false;
        }

        // If we built the main unit from source on this pass, we will have saved
        // off information that will help us determine whether we need to generate
        // an IFlexModuleFactory derivative.
        //
        // IMPORTANT: Having frame metadata is NOT the indicator!  We only generate
        // a system manager in sync with compiling a MXML application from source;
        // otherwise, the generated class is assumed to already exist!

        String generateLoaderClass = null;
        String baseLoaderClass = null;
        String windowClass = null;
        //String preloaderClass = null;
        Map<String, Object> rootAttributes = null;
        Map<String, Object> rootAttributeEmbedVars = null;
        Map<String, Object> rootAttributeEmbedNames = null;
        //boolean usePreloader = false;
        List<RslPathInfo> cdRsls = configuration.getRslPathInfo();
        List<String> rsls = configuration.getRuntimeSharedLibraries();
        String[] locales = configuration.getCompilerConfiguration().getLocales();

        // ALGORITHM:
        // Generate a loader class iff all the below are true:
        // 1a. We compiled MXML on this compilation run.
        //   or
        // 1b. We were not MXML but the base class does know a loader.
        // 2. We found Frame loaderClass metadata in a superclass
        // 3. We did not find Frame loaderClass metadata in the app



        if ((mainUnit.loaderClass != null) && (mainUnit.auxGenerateInfo != null))
        {
            generateLoaderClass = (String) mainUnit.auxGenerateInfo.get("generateLoaderClass");
            baseLoaderClass = (String) mainUnit.auxGenerateInfo.get("baseLoaderClass");
            windowClass = (String) mainUnit.auxGenerateInfo.get("windowClass");
            //preloaderClass = (String) mainUnit.auxGenerateInfo.get("preloaderClass");
            //Boolean b = (Boolean) mainUnit.auxGenerateInfo.get("usePreloader");

            @SuppressWarnings("unchecked")
            Map<String, Object> tmpRootAttributes = (Map<String, Object>) mainUnit.auxGenerateInfo.get("rootAttributes");
            rootAttributes = tmpRootAttributes;
            @SuppressWarnings("unchecked")
            Map<String, Object> tmpRootAttributeEmbedVars = (Map<String, Object>) mainUnit.auxGenerateInfo.get("rootAttributeEmbedVars");
            rootAttributeEmbedVars = tmpRootAttributeEmbedVars;
            @SuppressWarnings("unchecked")
            Map<String, Object> tmpRootAttributeEmbedNames = (Map<String, Object>) mainUnit.auxGenerateInfo.get("rootAttributeEmbedNames");
            rootAttributeEmbedNames = tmpRootAttributeEmbedNames;

            // mainUnit.auxGenerateInfo = null;    // All done, thanks!

            assert generateLoaderClass != null;

            //usePreloader = ((b == null) || b.booleanValue());

            //assert usePreloader || (preloaderClass != null);

            // Is there any way we can eliminate having default class here?
            // Seems like this should be in SystemManager, not the compiler.

            //if (usePreloader && (preloaderClass == null))   //
            //{
            //    preloaderClass = "mx.preloaders.DownloadProgressBar";
            //}
        }
        else if ((mainUnit.loaderClass == null) && (mainUnit.loaderClassBase != null))
        {
            // AS project, but the base class knows of a loader.
            baseLoaderClass = mainUnit.loaderClassBase;
            windowClass = mainUnit.topLevelDefinitions.last().toString();
            generateLoaderClass = (windowClass + "_" + mainUnit.loaderClassBase).replaceAll("[^A-Za-z0-9]", "_");

            mainUnit.loaderClass = generateLoaderClass;
        }
        else if ((mainUnit.loaderClass == null) &&
                ((rsls.size() > 0) || (cdRsls.size() > 0)))
        {
            ThreadLocalToolkit.log(new MissingFactoryClassInFrameMetadata(), mainUnit.getSource());
            return false;
        }
        else
        {
            return false;
        }

        String generatedLoaderCode = codegenModuleFactory(baseLoaderClass.replace(':', '.'),
                                                              generateLoaderClass.replace(':', '.'),
                                                              windowClass.replace(':', '.'),
                                                              rootAttributes,
                                                              rootAttributeEmbedVars,
                                                              rootAttributeEmbedNames,
                                                              cdRsls,
                                                              rsls,
                                                              mixins,
                                                              fonts,
                                                              frames,
                                                              locales,
                                                              resourceBundleNames,
                                                              externalResourceBundleNames,
                                                              configuration,
                                                              contributingSwcs,
                                                              swcContext,
                                                              false);

        String generatedLoaderFile = generateLoaderClass + ".as";

        TextFile genSource = new TextFile(generatedLoaderCode,
                generatedLoaderFile,
                mainUnit.getSource().getParent(),
                MimeMappings.AS);

        Source s = new Source(genSource, mainUnit.getSource(), generateLoaderClass, false, false);
        sources.add(s);

        if (configuration.getCompilerConfiguration().keepGeneratedActionScript())
        {
            saveGenerated(generatedLoaderFile, generatedLoaderCode, configuration.getCompilerConfiguration().getGeneratedDirectory());
        }

        return true;
    }


    private String codegenAccessibilityImports(Set<String> accessibilityImplementations)
    {
        StringBuilder sb = new StringBuilder();

        sb.append("import flash.system.*\n");
        if (accessibilityImplementations != null)
        {
            for (Iterator<String> it = accessibilityImplementations.iterator(); it.hasNext();)
            {
                sb.append("import " + it.next() + ";\n");
            }
        }

        return sb.toString();
    }

    //    TODO save to alt location instead of mangling name, to keep code compilable under OPD
    //    TODO make sure code generators obey OPD in name <-> code
    public static void saveGenerated(String name, String code, String dir)
    {
        final String suffix = "-generated.as";
        final String as3ext = ".as";
        if (!name.endsWith(suffix) && name.endsWith(as3ext))
        {
            name = name.substring(0, name.length() - as3ext.length()) + suffix;
        }

        name = FileUtils.addPathComponents( dir, name, File.separatorChar );

        try
        {
            FileUtil.writeFile(name, code);
        }
        catch (IOException e)
        {
            ThreadLocalToolkit.log(new VelocityException.UnableToWriteGeneratedFile(name, e.getLocalizedMessage()));
        }
    }


    /**
     * Codegen the cdRsls and placeholderRsls arrays.
     * 
     * @param cdRsls List of cross-domain rsls in the configuration.
     * @param requiredRsls true if we are writing out required rsls (cdRsls).
     * @param unusedRsls set of RSL that are not used by the application.
     * @param configuration
     * @param swcContext
     * @return
     */
    private static String codegenCdRslList(List<RslPathInfo> cdRsls,
                                    boolean requiredRsls,
                                    Set<String> unusedRsls,
                                    Configuration configuration,
                                    CompilerSwcContext swcContext)
    {

        // ignore -rslp option if -static-rsls is set
        if (configuration.getStaticLinkRsl()) {
            return "[]";
        }

        StringBuilder buf = new StringBuilder();
        buf.append("[\n");
        int i = 0;      // keep track of rsl index;
        for (Iterator<Configuration.RslPathInfo> iter = cdRsls.iterator(); iter.hasNext(); i++)
        {
            Configuration.RslPathInfo info = (Configuration.RslPathInfo)iter.next();

            // skip if the associated swc is filtered from our context.
            if (swcContext.getSwc(info.getSwcVirtualFile().getName()) == null)
                continue;
            
            String swcPath = info.getSwcVirtualFile().getName();
            
            // Write out either the required rsls (to cdRsls) or the 
            // unused rsls (to placeholderRsls).
            if (requiredRsls && unusedRsls.contains(swcPath) ||
                !requiredRsls && !unusedRsls.contains(swcPath))
                continue;
            
            // output message about rsl urls.
            if (requiredRsls)
            {
                List<String>rslUrls = info.getRslUrls();
                
                switch (rslUrls.size())
                {
                    case 0:
                        assert false; // One RSL URL is required.
                        break;
                    case 1:
                        ThreadLocalToolkit.log(new RequiredRslUrl(rslUrls.get(0)));                    
                        break;
                    case 2:
                        ThreadLocalToolkit.log(new RequiredRslUrlWithFailover(rslUrls.get(0)));
                        break;
                    default:
                        ThreadLocalToolkit.log(new RequiredRslUrlWithMultipleFailovers(
                                rslUrls.get(0),
                                rslUrls.size() - 1));
                        break;
                }
            }

            // Write out the rsl info and fail over info into an array of rsl objects.
            buf.append("[");
            codegenRslInfoObject(swcContext, configuration, info, unusedRsls, buf);
            buf.append("]");

            if (iter.hasNext())
                buf.append(",\n");
        }

        // end of all rsls
        buf.append("]\n");

        return buf.toString();
    }


    /**
     * Figure out which rsls we can remove. The tricky part is we may need to load
     * an unused rsl because a downstream rsl has inheritance dependencies on it.
     *  
     * @param cdRsls
     * @param contributingSwcs
     * @param configuration
     * @param swcContext
     * @return Set of Strings where each string is the location of a swc file.
     */
    private static Set<String> calculateUnusedRsls(List<RslPathInfo> cdRsls, 
                                Set<String> contributingSwcs, 
                                Configuration configuration, 
                                CompilerSwcContext swcContext)
    {
        if (!configuration.getRemoveUnusedRsls())
        {
            return Collections.emptySet();
        }            
            
        Set<String> forceRsls = configuration.
                                getRuntimeSharedLibrarySettingsConfiguration().
                                getForceRslsPaths();

        List<String> unusedRsls = new LinkedList<String>(); // running list of unused rsls
        Set<String>downstreamRsls = new HashSet<String>();  // loaded rsls downstream from first unused rsl
        boolean addDownstreamRsl = false;
        
        // Get unused RSLs and verify that there are no downstream RSLs that have
        // and inheritance dependency on them.
        for (RslPathInfo info : cdRsls)
        {
            // skip if the associated swc is filtered from our context.
            if (swcContext.getSwc(info.getSwcVirtualFile().getName()) == null)
                continue;

            // skip loading the RSL if it does not contribute any classes to 
            // the application and it is not forced.
            String swcPath = info.getSwcVirtualFile().getName();
            if (!contributingSwcs.contains(swcPath) &&
                !forceRsls.contains(swcPath))
            {
                unusedRsls.add(info.getSwcVirtualFile().getName());
                addDownstreamRsl = true;
            }
            else if (addDownstreamRsl)
            {
                downstreamRsls.add(swcPath);
            }
        }

        if (unusedRsls.size() == 0)
        {
            return Collections.emptySet();
        }
        
        Set<String> requiredInheritanceRsls = SwcDependencyUtil.
                                              checkInheritanceDependencies(unusedRsls, 
                                                      downstreamRsls, 
                                                      swcContext);
        if (!requiredInheritanceRsls.isEmpty())
            unusedRsls.removeAll(requiredInheritanceRsls);
        
        return new HashSet<String>(unusedRsls);
    }

    /**
     * Append a rsl info to the cross-domain startup info.
     * This is all the properties of the primary rsl and 
     * its fail overs.
     *
     * @param swcContext
     * @param info cross-domain rsl info
     * @param index chooses the rsl info from the primary rsl and fail overs.
     * @param buf StringBuilder to append info to
     */
    private static void codegenRslInfoObject(CompilerSwcContext swcContext,
                                     Configuration configuration,
                                     Configuration.RslPathInfo info,
                                     Set<String> unusedRsls,
                                     StringBuilder buf) {
        List<String>rslUrls = info.getRslUrls();
        RuntimeSharedLibrarySettingsConfiguration rslSettingsConfig = 
            configuration.getRuntimeSharedLibrarySettingsConfiguration();
        
        for (int i = 0; i < rslUrls.size(); i++)
        {
            // start new object
            buf.append("new RSLData(");
            String url = rslUrls.get(i);
            buf.append("\"" + url + "\",\n");

            // write policy url
            buf.append("\"" +
                    info.getPolicyFileUrls().get(i) +
                    "\",\n");
            
            // get the swc for current rsl
            String swcPath = info.getSwcVirtualFile().getName();
            Swc swc = swcContext.getSwc(swcPath);

            // write digest for each rsl in the list
            boolean secureRsls = configuration.getVerifyDigests();
            Boolean isSigned = (Boolean)info.getSignedFlags().get(i);
            Digest digest = swc.getDigest(Swc.LIBRARY_SWF,
                    Digest.SHA_256,
                    isSigned.booleanValue());

            if (digest == null || !digest.hasDigest())
            {
                // if the digest is not available then throw an exception,
                // "No digest found in catalog.xml. Either compile the application with
                // the -verify-digests=false or compile the library with
                // -create-digest=true"
                if (isSigned.booleanValue()) {
                    ThreadLocalToolkit.log(new MissingSignedLibraryDigest(swc.getLocation()));
                }
                else {
                    ThreadLocalToolkit.log(new MissingUnsignedLibraryDigest(swc.getLocation()));
                }
                return;
            }
            
            buf.append("\"" + digest.getValue() + "\",\n");
            buf.append("\"" + digest.getType() + "\",");
            buf.append(info.getSignedFlags().get(i) + ",");
            buf.append(secureRsls + ",");
            buf.append("\"" +  rslSettingsConfig.getApplicationDomain(swcPath) + "\"");
            
            // end of one object in the array
            buf.append(")");

            if (i + 1 < rslUrls.size())
                buf.append(",\n");
        }
    }


    private static String codegenRslList(List<String> rsls)
    {
        if ((rsls != null) && (rsls.size() > 0))
        {
            StringBuilder rb = new StringBuilder();

            rb.append("[");
            for (Iterator<String> it = rsls.iterator(); it.hasNext();)
            {
                String rslUrl = (String)it.next();
                
                ThreadLocalToolkit.log(new RequiredRslUrl(rslUrl)); 
                
                rb.append("{url: \"" + rslUrl + "\", size: -1}");
                if (it.hasNext())
                {
                    rb.append(", ");
                }
            }
            rb.append("]\n");

            return rb.toString();
        }
        return "[]";
    }

    private static String codegenMixinList(List<String> mixins)
    {
        assert mixins != null && mixins.size() > 0;
        StringJoiner.ItemStringer itemStringer = new StringJoiner.ItemQuoter();
        return "[ " + StringJoiner.join(mixins, ", ", itemStringer) + " ]";
    }

    private static String codegenFrameClassList(List<FrameInfo> frames)
    {
        assert frames != null && frames.size() > 0;
        StringBuilder mb = new StringBuilder();
        mb.append("{");

        for (Iterator<FrameInfo> it = frames.iterator(); it.hasNext();)
        {
            FramesConfiguration.FrameInfo frameInfo = it.next();
            mb.append("\"");
            mb.append(frameInfo.label);
            mb.append("\":\"");
            mb.append(frameInfo.frameClasses.get(0));
            mb.append("\"");
            if (it.hasNext())
            {
                mb.append(", ");
            }
        }
        mb.append("}\n");
        return mb.toString();
    }



    private static String codegenFontList(List<DefineTag> fonts)
    {
        if ((fonts == null) || (fonts.size() == 0))
        {
            return "";
        }

        class FontInfo
        {
            boolean plain;
            boolean bold;
            boolean italic;
            boolean bolditalic;
        }

        Map<String, FontInfo> fontMap = new TreeMap<String, FontInfo>();
        for (Iterator<DefineTag> it = fonts.iterator(); it.hasNext();)
        {
            DefineFont font = (DefineFont) it.next();
            FontInfo fi = fontMap.get( font.getFontName() );
            if (fi == null)
            {
                fi = new FontInfo();
                fontMap.put( font.getFontName(), fi );
            }

            fi.plain |= (!font.isBold() && !font.isItalic());
            fi.bolditalic |= (font.isBold() && font.isItalic());
            fi.bold |= font.isBold();
            fi.italic |= font.isItalic();
        }

        StringBuilder sb = new StringBuilder();

        sb.append("      {\n");

        for (Iterator it = fontMap.entrySet().iterator(); it.hasNext();)
        {
            Map.Entry e = (Map.Entry) it.next();
            String fontName = (String) e.getKey();
            FontInfo fontInfo = (FontInfo) e.getValue();

            sb.append("\"" + fontName + "\" : {" +
                      "regular:" + (fontInfo.plain? "true":"false") +
                      ", bold:" + (fontInfo.bold? "true":"false") +
                      ", italic:" + (fontInfo.italic? "true":"false") +
                      ", boldItalic:" + (fontInfo.bolditalic? "true":"false") + "}\n");
            if (it.hasNext())
            {
                sb.append(",\n");
            }
        }
        sb.append("}\n");

        return sb.toString();
    }

    private String codegenAccessibilityList(Set<String> accessibilityImplementations)
    {
        if ((accessibilityImplementations == null) || (accessibilityImplementations.size() == 0))
        {
            return "";
        }

        StringBuilder sb = new StringBuilder();

        if ((accessibilityImplementations != null) && (accessibilityImplementations.size() != 0))
        {
            sb.append("       // trace(\"Flex accessibility startup: \" + Capabilities.hasAccessibility);\n");
            sb.append("       if (Capabilities.hasAccessibility) {\n");
            for (Iterator<String> it = accessibilityImplementations.iterator(); it.hasNext();)
            {
                sb.append("          " + it.next() + ".enableAccessibility();\n");
            }
            sb.append("       }\n");
        }

        if (Trace.accessible)
        {
            Trace.trace("codegenAccessibilityList");
            if (sb.length() > 0)
            {
                Trace.trace(sb.toString());
            }
            else
            {
                Trace.trace("empty");
            }
        }

        return sb.toString();
    }

    private String codegenRemoteClassImports( Map<String, String> remoteClassAliases )
    {
        StringBuilder sb = new StringBuilder();

        if (remoteClassAliases.size() > 0)
        {
            sb.append( "import flash.net.registerClassAlias;\nimport flash.net.getClassByAlias;\n" );
            sb.append( "import mx.managers.SystemManagerGlobals;\n");
            sb.append( "import mx.resources.ResourceManager;\n");
        }

        for (Iterator<String> it = remoteClassAliases.keySet().iterator(); it.hasNext(); )
        {
            String className = it.next();
            sb.append( "import " + className + ";\n" );
        }
        return sb.toString();

    }
    private String codegenRemoteClassAliases( Map<String, String> remoteClassAliases, 
                                              String initClassName,
                                              Configuration configuration)
    {
        StringBuilder sb = new StringBuilder();

        for (Map.Entry<String, String> e : remoteClassAliases.entrySet())
        {
            String className = (String) e.getKey();
            String alias = (String) e.getValue();
            sb.append( "       // " + className + "\n");
            sb.append( "       try \n");
            sb.append( "       { \n");
            sb.append( "           if (flash.net.getClassByAlias(\"" + alias + "\") != " + className + ") \n");
            sb.append( "           { \n");
            sb.append( "               flash.net.registerClassAlias(\"" + alias + "\", " + className + "); \n");
            // Only generate the diagnostic code if compiling for debug.
            if (configuration.debug())
            {
                sb.append( "               if (fbs != SystemManagerGlobals.topLevelSystemManagers[0]) \n");
                sb.append( "               { \n");
                sb.append( "                   trace(ResourceManager.getInstance().getString( \"core\", \n");
                sb.append( "                         \"remoteClassMemoryLeak\",\n");
                sb.append( "                         [\"" + className + "\",\"" + 
                                                     configuration.getMainDefinition() + "\",\"" +  
                                                     initClassName + "\"]));\n");
                sb.append( "               } \n");
            }
            sb.append( "           } \n");
            sb.append( "       } \n");
            sb.append( "       catch (e:Error) \n");
            sb.append( "       { \n");
            sb.append( "           flash.net.registerClassAlias(\"" + alias + "\", " + className + "); \n");
            // Only generate the diagnostic code if compiling for debug.
            if (configuration.debug())
            {
                sb.append( "           if (fbs != SystemManagerGlobals.topLevelSystemManagers[0]) \n");
                sb.append( "           { \n");
                sb.append( "               trace(ResourceManager.getInstance().getString( \"core\", \n");
                sb.append( "                     \"remoteClassMemoryLeak\",\n");
                sb.append( "                     [\"" + className + "\",\"" + 
                                                 configuration.getMainDefinition() + "\",\"" +  
                                                 initClassName + "\"]));\n");
                sb.append( "           } \n");
            }
            sb.append( "       } \n\n");
        }
        return sb.toString();
    }

    private String codegenEffectTriggerImports(Map<String, String> effectTriggers, StandardDefs standardDefs)
    {
        if (effectTriggers.size() > 0)
        {
            return "import " + standardDefs.CLASS_EFFECTMANAGER_DOT + ";\n" + "import " + standardDefs.NAMESPACE_MX_INTERNAL_DOT + ";\n";
        }
        else
        {
            return "";
        }
    }

    private String codegenEffectTriggerRegistration( Map<String, String> effectTriggers )
    {
        StringBuilder sb = new StringBuilder();

        for (Iterator it = effectTriggers.entrySet().iterator(); it.hasNext(); )
        {
            Map.Entry e = (Map.Entry) it.next();
            String name = (String) e.getKey();
            String event = (String) e.getValue();

            sb.append( "       EffectManager.mx_internal::registerEffectTrigger(\"" + name + "\", \"" + event + "\");\n");
        }

        return sb.toString();
    }

    private String codegenInheritingStyleRegistration( Set<String> inheritingStyles )
    {
        StringBuilder sb = new StringBuilder();
        sb.append("       var styleNames:Array = [");

        Iterator<String> iterator = inheritingStyles.iterator();

        while ( iterator.hasNext() )
        {
            String styleName = iterator.next();
            sb.append("\"" + styleName + "\"");
            if ( iterator.hasNext() )
            {
                sb.append(", ");
            }
        }

        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();

        sb.append("];\n\n");
        sb.append("       for (var i:int = 0; i < styleNames.length; i++)\n");
        sb.append("       {\n");
        sb.append("          styleManager.registerInheritingStyle(styleNames[i]);\n");
        sb.append("       }\n");

        return sb.toString();
    }

    /**
     * Returns a string like
     *   [ "en_US", "ja_JP" ]
     */
    private static String codegenCompiledLocales( String[] locales )
    {
        StringJoiner.ItemStringer itemStringer = new StringJoiner.ItemQuoter();
        return "[ " + StringJoiner.join(locales, ", ", itemStringer) + " ]";
    }

    /**
     * Returns a string like
     *   [ "core", "controls", "MyApp" ]
     */
    private static String codegenCompiledResourceBundleNames( SortedSet<String> bundleNames )
    {
        StringJoiner.ItemStringer itemStringer = new StringJoiner.ItemQuoter();
        return "[ " + StringJoiner.join(bundleNames, ", ", itemStringer) + " ]";
    }

    private static String codegenCompatibilityCall(Configuration configuration)
    {
        String compatibilityCall;
        String compatibilityVersionString = configuration.getCompatibilityVersionString();

        if (configuration.getCompatibilityVersion() == MxmlConfiguration.CURRENT_VERSION || 
        	compatibilityVersionString == null)
        {
            compatibilityCall = "";
        }
        else
        {
            compatibilityCall = "        FlexVersion.compatibilityVersionString = \"" + compatibilityVersionString + "\";";
        }
        return compatibilityCall;
    }

    private static String codegenQualifiedTypeSelectors(Configuration configuration)
    {
        // If we're not using qualified type selectors, change the runtime default to false.
        boolean qualified = configuration.getQualifiedTypeSelectors();
        return qualified ? "" : "       styleManager.qualifiedTypeSelectors = false;\n";
    }

    static String codegenModuleFactory(String base,
                                        String rootClassName,
                                        String topLevelWindowClass,
                                        Map<String, Object> rootAttributes,
                                        Map<String, Object> rootAttributeEmbedVars,
                                        Map<String, Object> rootAttributeEmbedNames,
                                        List<RslPathInfo> cdRsls,
                                        List<String> rsls,
                                        List<String> mixins,
                                        List<DefineTag> fonts,
                                        List<FrameInfo> frames,
                                        String[] locales,
                                        SortedSet<String> resourceBundleNames,
                                        SortedSet<String> externalResourceBundleNames,
                                        Configuration configuration,
                                        Set<String> contributingSwcs,
                                        CompilerSwcContext swcContext,
                                        boolean isLibraryCompile)
    {
        String lineSep = System.getProperty("line.separator");
        boolean hasFonts = (fonts == null ? false : fonts.size() > 0);
        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();

        String[] codePieces = new String[]
        {
            "package", lineSep,
            "{", lineSep, lineSep,
            codegenImports(base, rootAttributes, rootAttributeEmbedVars, fonts, configuration, standardDefs, isLibraryCompile, hasFonts),
            codegenResourceBundleMetadata(null /*externalResourceBundleNames*/),
            "[ExcludeClass]", lineSep,
            "public class ", rootClassName, lineSep,
            "    extends ", base, lineSep,
            "    implements IFlexModuleFactory, ISWFContext", lineSep,
            "{", lineSep,
            codegenLinkInCrossDomainRSLItem(configuration, lineSep, cdRsls, standardDefs),
            "    public function ", rootClassName, "()", lineSep,
            "    {", lineSep,
            codegenCompatibilityCall(configuration), lineSep,
            "        super();", lineSep,
            codegenAddRslCompleteListener(isLibraryCompile, hasFonts, lineSep),
            "    }", lineSep, lineSep,
            /**
             *  Calls a function in the modules context.  Needed for
             *  ElementFormat.getFontMetrics so we'll generalize in case
             *  we find a need to do this for some other method.
             */
            !isLibraryCompile ?
            "    override " : "",
            "    public function callInContext(fn:Function, thisArg:Object, argArray:Array, returns:Boolean=true):*", lineSep,
            "    {", lineSep,
            "        if (returns)", lineSep,
	        "           return fn.apply(thisArg, argArray);", lineSep,
            "        else", lineSep,
            "           fn.apply(thisArg, argArray);", lineSep,
            "    }", lineSep, lineSep,
            codegenAddPreloadedRSLStub(isLibraryCompile, lineSep),
            codegenGetRegisterImplementationStubs(isLibraryCompile, lineSep),
            !isLibraryCompile ?
            "    override " : "",
            "    public function create(... params):Object", lineSep,
            "    {", lineSep,
            codegenCreateApply(isLibraryCompile, lineSep),
            codegenGetMainClassName(topLevelWindowClass, configuration, lineSep),
            "        var mainClass:Class = Class(getDefinitionByName(mainClassName));", lineSep,
            "        if (!mainClass)", lineSep,
            "            return null;", lineSep, lineSep,
            "        var instance:Object = new mainClass();", lineSep,
            "        if (instance is IFlexModule)", lineSep,
            "            (IFlexModule(instance)).moduleFactory = this;", lineSep,
            codegenRegisterEmbeddedFonts(fonts, lineSep),
            "        return instance;", lineSep,
            "    }", lineSep, lineSep,
            codegenEmbeddedApplicaitonAttributes(rootAttributeEmbedVars),
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     */", lineSep,
            "    private var _info:Object;", lineSep, lineSep,
            !isLibraryCompile ?
            "    override" : "",
            "    public function info():Object", lineSep,
            "    {", lineSep,
            "        if (!_info)", lineSep,
            "        {", lineSep,
            "            _info = {", lineSep,
            codegenInfo(topLevelWindowClass, rootAttributes, rootAttributeEmbedNames, cdRsls, rsls, mixins, fonts,
                        frames, locales, resourceBundleNames, configuration, 
                        contributingSwcs, swcContext),
            "            }", lineSep,
            "        }", lineSep,
            "        return _info;", lineSep,
            "    }", lineSep, lineSep,
            codegenRSLSecurityWrapper(isLibraryCompile, lineSep), lineSep,
            codegenModuleFactorySecurityWrapper(isLibraryCompile, hasFonts, lineSep), lineSep,
            codegenRslCompleteListener(isLibraryCompile, hasFonts, lineSep),
            "}", lineSep, lineSep,
            "}", lineSep,
        };

        return StringJoiner.join(codePieces, null);
    }


    private static String codegenLinkInCrossDomainRSLItem(
                                        Configuration configuration, String lineSep,
                                        List cdRsls, StandardDefs standardDefs)
    {
        if (cdRsls == null || cdRsls.isEmpty())
        {
            return "";
        }

        String[] code = {
                "    // Cause the CrossDomainRSLItem class to be linked into this application.", lineSep,
                "    import ", standardDefs.CLASS_CROSSDOMAINRSLITEM_DOT, "; CrossDomainRSLItem;", lineSep, lineSep,
        };

        return StringJoiner.join(code, null);
    }

    private static String codegenImportEmbeddedFontRegistry(List<DefineTag> fonts,
            String lineSep, StandardDefs standardDefs)
    {
        if (fonts == null || fonts.size() == 0)
        {
            return "";
        }

        String[] code = {
                "import ", standardDefs.CLASS_EMBEDDEDFONTREGISTRY_DOT, ";", lineSep,
                "import ", standardDefs.CLASS_SINGLETON_DOT, ";", lineSep,
        };

        return StringJoiner.join(code, null);
    }


    private static String codegenRegisterEmbeddedFonts(List<DefineTag> fonts, String lineSep)
    {
        if (fonts == null || fonts.size() == 0)
        {
            return "";
        }

        String[] code = {
        "        if (params.length == 0) {", lineSep,
        "            Singleton.registerClass(\"mx.core::IEmbeddedFontRegistry\",", lineSep,
        "                Class(getDefinitionByName(\"mx.core::EmbeddedFontRegistry\")));", lineSep,
        "            EmbeddedFontRegistry.registerFonts(info()[\"fonts\"], this);", lineSep,
        "}"
        };

        return StringJoiner.join(code, null);
    }

    private static String codegenCreateApply(boolean isLibraryCompile, String lineSep)
    {
        if (isLibraryCompile)
        {
            return "";
        }

        String[] code = {
        "        if (params.length > 0 && !(params[0] is String))", lineSep,
        "            return super.create.apply(this, params);", lineSep, lineSep,
        };

        return StringJoiner.join(code, null);
    }

    private static String codegenGetMainClassName(String topLevelWindowClass, Configuration configuration, String lineSep)
    {
        String[] code = {
                topLevelWindowClass == null ?
                "        var mainClassName:String = String(params[0])" :
                "        var mainClassName:String = params.length == 0 ? \"",
                topLevelWindowClass == null ? "" : topLevelWindowClass,
                topLevelWindowClass == null ? "" : "\" : String(params[0]);", lineSep,
        };
        return StringJoiner.join(code, null);


    }

    private static String codegenResourceBundleMetadata(SortedSet<String> resourceBundleNames)
    {
        if (resourceBundleNames == null)
        {
            return "";
        }
        String lineSep = System.getProperty("line.separator");

        StringBuilder codePieces = new StringBuilder();
        for (Iterator<String> i = resourceBundleNames.iterator(); i.hasNext(); )
        {
            codePieces.append("[ResourceBundle(\"" + i.next() + "\")]" + lineSep);
        }

        return codePieces.toString();
    }


    private static String codegenImports(String base, Map<String, Object> rootAttributes, 
    									Map<String, Object> rootAttributeEmbedVars,	List<DefineTag> fonts,
                                        Configuration configuration, StandardDefs standardDefs, 
                                        boolean isLibraryCompile, boolean hasFonts)
    {
        String lineSep = System.getProperty("line.separator");

        StringBuilder sb = new StringBuilder(512);
        sb.append(codegenEventImport(isLibraryCompile, hasFonts, lineSep));
        sb.append("import flash.display.LoaderInfo;").append(lineSep);
        sb.append("import flash.text.Font;").append(lineSep);
        sb.append("import flash.text.TextFormat;").append(lineSep);
        sb.append("import flash.text.engine.TextBlock;").append(lineSep);
        sb.append("import flash.text.engine.TextLine;").append(lineSep);
        sb.append("import flash.system.ApplicationDomain;").append(lineSep);
        sb.append("import flash.system.Security").append(lineSep);
        sb.append("import flash.utils.Dictionary;").append(lineSep);
        sb.append("import flash.utils.getDefinitionByName;").append(lineSep);
        sb.append("import flashx.textLayout.compose.ISWFContext;").append(lineSep);
        sb.append("import ").append(standardDefs.INTERFACE_IFLEXMODULE_DOT).append(";").append(lineSep);
        sb.append("import ").append(standardDefs.INTERFACE_IFLEXMODULEFACTORY_DOT).append(";").append(lineSep);
        sb.append(codegenImportEmbeddedFontRegistry(fonts, lineSep, standardDefs));
        sb.append("import mx.core.RSLData;").append(lineSep);
        sb.append("import mx.events.RSLEvent;").append(lineSep);
        
        if (configuration.getCompatibilityVersionString() != null)
        {
            sb.append("import ").append(standardDefs.CLASS_FLEXVERSION_DOT).append(";").append(lineSep);
        }

        // If we're not using qualified type selectors, change the runtime default to false.
        if (!configuration.getQualifiedTypeSelectors())
        {
            sb.append("import ").append(standardDefs.CLASS_STYLEMANAGER_DOT).append(";").append(lineSep);
            sb.append("import ").append(standardDefs.NAMESPACE_MX_INTERNAL_DOT).append(";").append(lineSep);
        }

        sb.append("import ").append(base).append(";").append(lineSep);

        // Import runtimeDPIProvider class if it exists.
        String runtimeDPIProviderClass = getRuntimeDPIProviderClass(rootAttributes, configuration);
        if (runtimeDPIProviderClass != null)
        {
            sb.append("import ").append(runtimeDPIProviderClass).append(";").append(lineSep);
        }
        
        // TODO - eliminate any special handling of preloaderDisplayClass!
        String preloader = getPreloaderClass(rootAttributes, configuration);
        if (preloader != null)
        {
            sb.append("import ").append(preloader).append(";").append(lineSep);
        }

        // If the splashScreenImage was specified as a Class and not @Embed, we need to import it here
        if (rootAttributes != null && rootAttributes.containsKey("splashScreenImage") && 
            (rootAttributeEmbedVars == null || !rootAttributeEmbedVars.containsKey("splashScreenImage")))
        {
            String splashImageClass = (String) rootAttributes.get("splashScreenImage");
            sb.append("import ").append(splashImageClass).append(";").append(lineSep);
        }

        sb.append(lineSep);

        return sb.toString();
    }
    
    private static String getRuntimeDPIProviderClass(Map<String, Object> rootAttributes, Configuration configuration)
    {
        // Is dpiMapping attribute defined on the root tag?
        if (rootAttributes != null && rootAttributes.containsKey("runtimeDPIProvider"))
            return (String)rootAttributes.get("runtimeDPIProvider");
        
        return null;
    }
    
    private static String getPreloaderClass(Map<String, Object> rootAttributes, Configuration configuration)
    {
        // Is preloader attribute defined on the root tag?
        if (rootAttributes != null && rootAttributes.containsKey("preloader"))
            return (String)rootAttributes.get("preloader");

        // Is preloader specified in the compiler arguments?
        String preloader = configuration.getCompilerConfiguration().getPreloader();
        if (preloader != null)
        {
        	preloader = preloader.trim();
        	return preloader.length() == 0 ? null : preloader;
        }

        int version = configuration.getCompatibilityVersion();
        if (version < MxmlConfiguration.VERSION_4_0)
            return "mx.preloaders.DownloadProgressBar";
        else
            return "mx.preloaders.SparkDownloadProgressBar";
    }

    /**
     * Add mx.events.Event import to support RSL event handler.
     * Only needed when compiling a SWC.
     *
     * @param isLibraryCompile
     * @param hasFonts
     * @param lineSep
     * @return
     */
     private static String codegenEventImport(boolean isLibraryCompile,
                                              boolean hasFonts, String lineSep)
    {
        if (!(isLibraryCompile && hasFonts))
        {
            return "";
        }

        String[] eventImport = {"import flash.events.Event", lineSep,};
        return StringJoiner.join(eventImport, null);

    }

    private static String codegenEmbeddedApplicaitonAttributes(Map<String, Object> rootAttributeEmbedVars)
    {
        if (rootAttributeEmbedVars == null || rootAttributeEmbedVars.size() == 0)
            return "";

        String lineSep = System.getProperty("line.separator");
        return StringJoiner.join(rootAttributeEmbedVars.values(), lineSep) + lineSep;
    }

    private static String codegenInfo(String topLevelWindowClass,
                       Map<String, Object> rootAttributes,
                       Map<String, Object> rootAttributeEmbedNames,
                       List<RslPathInfo> cdRsls,
                       List<String> rsls,
                       List<String> mixins,
                       List<DefineTag> fonts,
                       List<FrameInfo> frames,
                       String[] locales,
                       SortedSet<String> resourceBundleNames,
                       Configuration configuration,
                       Set<String> contributingSwcs,
                       CompilerSwcContext swcContext)
    {
        // Build a map of the name/value pairs for the info
        TreeMap<String, Object> t = new TreeMap<String, Object>();

        t.put("currentDomain", "ApplicationDomain.currentDomain");

        if (topLevelWindowClass != null)
        {
            t.put("mainClassName", "\"" + topLevelWindowClass + "\"");
        }

        if (rootAttributes != null)
        {
            for (Iterator<Map.Entry<String, Object>> it = rootAttributes.entrySet().iterator(); it.hasNext(); )
            {
                Map.Entry<String, Object> e = it.next();

                // TODO - eliminate any special handling of preloaderDisplayClass!
                if ("preloader".equals(e.getKey()))
                {
                    // skip, will handle preloader after the loop
                }
                else if ("usePreloader".equals(e.getKey()))
                {
                    t.put(e.getKey(), e.getValue());
                }
                else if ("runtimeDPIProvider".equals(e.getKey()))
                {
                    // skip, will handle runtimeDPIProvider after the loop
                }
                else if ("implements".equals(e.getKey()))
                {
                    // skip
                }
                else if ("backgroundColor".equals(e.getKey()))
                {
                    t.put(e.getKey(), "\"0x" + Integer.toHexString(configuration.backgroundColor()).toUpperCase() + "\"");
                }
                else
                {
                    String embedName = null;
                    if (rootAttributeEmbedNames != null)
                        embedName = (String) rootAttributeEmbedNames.get(e.getKey());

                    if (embedName != null)
                        t.put(e.getKey(), embedName);
                    else if ("splashScreenImage".equals(e.getKey()))
                        t.put(e.getKey(), e.getValue()); // SplashScreenImage is a special attribute of type Class.
                    else
                        t.put(e.getKey(), "\"" + e.getValue() + "\"");
                }
            }
            
            String preloader = getPreloaderClass(rootAttributes, configuration);
            if (preloader != null)
            {
                // we use the actual class in order to get a link dependency
                t.put("preloader", preloader);
            }

            String runtimeDPIProvider = getRuntimeDPIProviderClass(rootAttributes, configuration);
            if (runtimeDPIProvider != null)
            {
            	t.put("runtimeDPIProvider", runtimeDPIProvider);
            }
        }

        boolean hasCdRsls = (cdRsls != null) && (cdRsls.size() > 0);
        boolean hasRsls = (rsls != null) && (rsls.size() > 0);
        
        if (hasCdRsls || hasRsls)
            ThreadLocalToolkit.log(new RequiredRsls());     //log "Required RSLs:" message
        
        if (hasCdRsls)
        {
            // The required RSLs are put in "cdRsls", the others are put in "placeholderRsls".
            // get the rsls that we can remove.
            Set<String> unusedRsls = calculateUnusedRsls(cdRsls, contributingSwcs, 
                                                    configuration, swcContext);

            t.put("cdRsls", codegenCdRslList(cdRsls, true, unusedRsls, configuration, swcContext));
            t.put("placeholderRsls", codegenCdRslList(cdRsls, false, unusedRsls, configuration, swcContext));
        }

        if (hasRsls)
            t.put("rsls", codegenRslList(rsls));

        if ((mixins != null) && (mixins.size() > 0))
            t.put("mixins", codegenMixinList(mixins));

        if ((fonts != null) && (fonts.size() > 0))
            t.put("fonts", codegenFontList(fonts) );

        if ((frames != null) && (frames.size() > 0))
            t.put("frames", codegenFrameClassList(frames));

        if (locales != null)
            t.put("compiledLocales", codegenCompiledLocales(locales));

        if ((resourceBundleNames != null) && (resourceBundleNames.size() > 0))
            t.put("compiledResourceBundleNames", codegenCompiledResourceBundleNames(resourceBundleNames));

        // Codegen a string from that map.
        String lineSep = System.getProperty("line.separator");
        StringJoiner.ItemStringer itemStringer = new StringJoiner.MapEntryItemWithColon();
        return "            " +
               StringJoiner.join(t.entrySet(), "," + lineSep + "            ", itemStringer) +
               lineSep;
    }

    /**
     * Add an RSL complete listener to this RSL.
     *
     * @param isLibraryCompile true if we are compiling the library.swf for a swc.
     * @param lineSep
     * @return ActionScript code to add an RSL complete listener. If we are not compiling
     *         the library.swf(RSL) of a SWC then no code is added.
     */
    private static String codegenAddRslCompleteListener(boolean isLibraryCompile, boolean hasFonts,
                              String lineSep) {
    
        if (!(isLibraryCompile && hasFonts)) 
        {
            return "";
        }

        String[] addCompleteListenerCall = {
                "        this.root.loaderInfo.addEventListener(Event.COMPLETE, RSLRootCompleteListener);",
                lineSep };
        return StringJoiner.join(addCompleteListenerCall, null);
    }


    /**
     * Add an RSL complete listener handler to this RSL.
     *
     * @param isLibraryCompile true if we are compiling the library.swf for a swc.
     * @param lineSep
     * @return ActionScript code to add an RSL complete listener. If we are not compiling
     *         the library.swf(RSL) of a SWC then no code is added.
     */
    private static String codegenRslCompleteListener(boolean isLibraryCompile, boolean hasFonts,
                                String lineSep)
    {
        if (!(isLibraryCompile && hasFonts)) 
        {
            return "";
        }

        String[] completeListener = {
                "    private function RSLRootCompleteListener(event:Event):void", lineSep,
                "    {", lineSep,
                "        EmbeddedFontRegistry.registerFonts(info()[\"fonts\"], this)", lineSep,
                "        this.root.removeEventListener(Event.COMPLETE, RSLRootCompleteListener);", lineSep,
                "    }", lineSep,    };

        return StringJoiner.join(completeListener, null);
    }

    /**
     * Implement the allowDomain() and allowInsecureDomain() of the IFlexModuleFactory interface.
     * This code is only generated for compiled applications and modules, not for RSLs code in a SWC.
     * 
     * @param isLibraryCompile true if we are compiling the library.swf for a swc.
     * @param lineSep
     * @return
     */
    private static String codegenModuleFactorySecurityWrapper(boolean isLibraryCompile, boolean hasFonts, 
                            String lineSep)
    {
        if (isLibraryCompile && !hasFonts) 
        {
            return "";
        }

        if (isLibraryCompile)
            return codegenModuleFactorySecurityWrapperStubs(lineSep);

        String[] code = {
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     */", lineSep,
            "    private var _preloadedRSLs:Dictionary; // key: LoaderInfo, value: Vector.<RSLData>", lineSep, lineSep,
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     */", lineSep,
            "    private var _allowDomainParameters:Vector.<Array>;", lineSep, lineSep,
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     */", lineSep,
            "    private var _allowInsecureDomainParameters:Vector.<Array>;", lineSep, lineSep,
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     *  The RSLs loaded by this system manager before the application",  lineSep,
            "     *  starts. RSLs loaded by the application are not included in this list.", lineSep,
            "     */", lineSep,
            "    override public function get preloadedRSLs():Dictionary", lineSep,
            "    {", lineSep,
            "        if (_preloadedRSLs == null)", lineSep,
            "           _preloadedRSLs = new Dictionary(true);", lineSep,
            "        return _preloadedRSLs;", lineSep,                
            "    }", lineSep, lineSep, 
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     *  Calls Security.allowDomain() for the SWF associated with this IFlexModuleFactory", lineSep,
            "     *  plus all the SWFs assocatiated with RSLs preLoaded by this IFlexModuleFactory.", lineSep,
            "     *", lineSep, 
            "     */", lineSep,
            "    override public function allowDomain(... domains):void", lineSep,
            "    {", lineSep,
            "        Security.allowDomain.apply(null, domains);", lineSep, lineSep,
            "        for (var loaderInfo:Object in _preloadedRSLs)", lineSep,
            "        {", lineSep,
            "            if (loaderInfo.content && (\"allowDomainInRSL\" in loaderInfo.content))", lineSep,
            "                loaderInfo.content[\"allowDomainInRSL\"].apply(null, domains);", lineSep,
            "        }", lineSep, lineSep,
            "        if (!_allowDomainParameters)", lineSep,
            "            _allowDomainParameters = new Vector.<Array>();", lineSep,
            "        _allowDomainParameters.push(domains);", lineSep, lineSep,
            "        // Run our handler before the default handlers so the RSL is trusted before the", lineSep,
            "        // default handlers run.", lineSep,
            "        addEventListener(RSLEvent.RSL_ADD_PRELOADED, addPreloadedRSLHandler, false, 50);", lineSep,
            "    }", lineSep, lineSep,
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     *  Calls Security.allowInsecureDomain() for the SWF associated with this IFlexModuleFactory", lineSep,
            "     *  plus all the SWFs assocatiated with RSLs preLoaded by this IFlexModuleFactory.", lineSep,
            "     *", lineSep, 
            "     */", lineSep,
            "    override public function allowInsecureDomain(... domains):void", lineSep,
            "    {", lineSep,
            "        Security.allowInsecureDomain.apply(null, domains);", lineSep, lineSep,
            "        for (var loaderInfo:Object in _preloadedRSLs)", lineSep,
            "        {", lineSep,
            "            if (loaderInfo.content && (\"allowInsecureDomainInRSL\" in loaderInfo.content))", lineSep,
            "                loaderInfo.content[\"allowInsecureDomainInRSL\"].apply(null, domains);", lineSep,
            "        }", lineSep,
            "        if (!_allowInsecureDomainParameters)", lineSep,
            "            _allowInsecureDomainParameters = new Vector.<Array>();", lineSep,
            "        _allowInsecureDomainParameters.push(domains);", lineSep, lineSep,
            "        // Run our handler before the default handlers so the RSL is trusted before the", lineSep,
            "        // default handlers run.", lineSep,
            "        addEventListener(RSLEvent.RSL_ADD_PRELOADED, addPreloadedRSLHandler, false, 50);", lineSep,
            "    }", lineSep, lineSep,
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     */", lineSep,
            "    private function addPreloadedRSLHandler(event:RSLEvent):void", lineSep,
            "    {", lineSep,
            "        var loaderInfo:LoaderInfo = event.loaderInfo;", lineSep,
            "        if (!loaderInfo || !loaderInfo.content)", lineSep,
            "            return;", lineSep,
            "        var domains:Array", lineSep,
            "        if (allowDomainsInNewRSLs && _allowDomainParameters)", lineSep,
            "        {", lineSep,
            "            for each (domains in _allowDomainParameters)", lineSep,
            "            {", lineSep,
            "                if (\"allowDomainInRSL\" in loaderInfo.content)", lineSep,
            "                    loaderInfo.content[\"allowDomainInRSL\"].apply(null, domains);", lineSep,
            "            }", lineSep,
            "        }", lineSep, lineSep,
            "        if (allowInsecureDomainsInNewRSLs && _allowInsecureDomainParameters)", lineSep,
            "        {", lineSep,
            "            for each (domains in _allowInsecureDomainParameters)", lineSep,
            "            {", lineSep,
            "                if (\"allowInsecureDomainInRSL\" in loaderInfo.content)", lineSep,
            "                    loaderInfo.content[\"allowInsecureDomainInRSL\"].apply(null, domains);", lineSep,
            "            }", lineSep,
            "        }", lineSep,
            "    }", lineSep, lineSep,
            
        };
        
        return StringJoiner.join(code, null);
    }
    
    /**
     * Generate stubs for the security wrappers of the IFlexModuleFactory interface.
     * This code is only generated for RSLs code in a SWC has contains fonts.
     * 
     * @param lineSep
     * @return
     */
    private static String codegenModuleFactorySecurityWrapperStubs(String lineSep)
    {
        String[] stubs = {
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     */", lineSep,
                "    public function get allowDomainsInNewRSLs():Boolean", lineSep,
                "    {", lineSep,
                "        return false;", lineSep,                
                "    }", lineSep, lineSep, 
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     */", lineSep,
                "    public function set allowDomainsInNewRSLs(value:Boolean):void", lineSep,
                "    {", lineSep,
                "    }", lineSep, lineSep, 
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     */", lineSep,
                "    public function get allowInsecureDomainsInNewRSLs():Boolean", lineSep,
                "    {", lineSep,
                "        return false;", lineSep,                
                "    }", lineSep, lineSep, 
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     */", lineSep,
                "    public function set allowInsecureDomainsInNewRSLs(value:Boolean):void", lineSep,
                "    {", lineSep,
                "    }", lineSep, lineSep, 
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     */", lineSep,
                "    public function get preloadedRSLs():Dictionary", lineSep,
                "    {", lineSep,
                "        return null;", lineSep,                
                "    }", lineSep, lineSep, 
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     */", lineSep,
                "    public function allowDomain(... domains):void", lineSep,
                "    {", lineSep,
                "    }", lineSep, lineSep,
                "    /**", lineSep,
                "     *  @private", lineSep,
                "     *  Stub for RSL", lineSep,
                "     *", lineSep, 
                "     */", lineSep,
                "    public function allowInsecureDomain(... domains):void", lineSep,
                "    {", lineSep,
                "    }", lineSep, lineSep,
        };

       return StringJoiner.join(stubs, null);
    }
    
    /**
     * Generate flash player Security wrapper calls.
     * 
     * @param lineSep
     * @return
     */
    static String codegenRSLSecurityWrapper(boolean isLibraryCompile, String lineSep)
    {
        if (!isLibraryCompile)
            return "";
        
        String[] code = {               
                "   /*", lineSep,
                "    *  Calls Security.allowDomain() for the SWF associated with this RSL", lineSep,
                "    *  @param a list of domains to trust. This parameter is passed to Security.allowDomain().", lineSep,
                "    */", lineSep,
                "   public function allowDomainInRSL(... domains):void", lineSep,
                "   {", lineSep,
                "       Security.allowDomain.apply(null, domains);", lineSep,
                "   }", lineSep, lineSep,
                "   /*", lineSep,
                "    *  Calls Security.allowInsecureDomain() for the SWF associated with this RSL", lineSep,
                "    *  @param a list of domains to trust. This parameter is passed to Security.allowInsecureDomain().", lineSep,
                "    */", lineSep,
                "   public function allowInsecureDomainInRSL(... domains):void", lineSep,
                "   {", lineSep,
                "       Security.allowInsecureDomain.apply(null, domains);", lineSep,
                "   }", lineSep,
        };
        
        return StringJoiner.join(code, null);
    }

    /**
     * Generate stubs for getImplementation() and registerImplemenation() if we are 
     * compiling a module factory for a SWC, instead of a SWF file. For a SWF file
     * use don't override the implementation.
     * 
     * @param isLibraryCompile true if we are compiling the library.swf for a swc.
     * @param lineSep
     * @return
     */
    private static String codegenGetRegisterImplementationStubs(boolean isLibraryCompile,
                                                                String lineSep)
    {
        if (!isLibraryCompile) 
        {
            return "";
        }
        
        String[] code = {
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     *  Stub for RSL", lineSep,
            "     */", lineSep,
            "    public function getImplementation(interfaceName:String):Object", lineSep,
            "    {", lineSep,
            "        return null;", lineSep,                
            "    }", lineSep, lineSep, 
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     *  Stub for RSL", lineSep,
            "     */", lineSep,
            "    public function registerImplementation(interfaceName:String,", lineSep,
            "                                           impl:Object):void", lineSep,
            "    {", lineSep,
            "    }", lineSep, lineSep,
        };
        
        return StringJoiner.join(code, null);
    }
    
    /**
     * Generate stubs for addPreloadedRSL()if we are 
     * compiling a module factory for a SWC, instead of a SWF file. For a SWF file
     * use don't override the implementation.
     * 
     * @param isLibraryCompile true if we are compiling the library.swf for a swc.
     * @param lineSep
     * @return
     */
    private static String codegenAddPreloadedRSLStub(boolean isLibraryCompile,
                                                                String lineSep)
    {
        if (!isLibraryCompile) 
        {
            return "";
        }
        
        String[] code = {
            "    /**", lineSep,
            "     *  @private", lineSep,
            "     *  Stub for RSL", lineSep,
            "     */", lineSep,
            "    public function addPreloadedRSL(loaderInfo:LoaderInfo, rsl:Vector.<RSLData>):void", lineSep,
            "    {", lineSep,
            "    }", lineSep, lineSep, 
        };
        
        return StringJoiner.join(code, null);
    }

    private void processCompiledResourceBundleInfoClass(List units,
            Configuration configuration,
            List<Source> sources,
            List<String> mixins,
            List<DefineTag> fonts,
            CompilerSwcContext swcContext)
    {
        CompilerConfiguration config = configuration.getCompilerConfiguration();

        // Don't add the _CompiledResourceBundleInfo class
        // if we are compiling in Flex 2 compatibility mode,
        // or if there are no locales,
        // or if there are no resource bundle names.

        int version = config.getCompatibilityVersion();
        if (version < MxmlConfiguration.VERSION_3_0)
        {
            return;
        }

        String[] locales = config.getLocales();
        if (locales.length == 0)
        {
            return;
        }

        if (resourceBundleNames.size() == 0)
        {
            return;
        }

        String className = I18nUtils.COMPILED_RESOURCE_BUNDLE_INFO;
        String code = I18nUtils.codegenCompiledResourceBundleInfo(locales, resourceBundleNames);

        String generatedFileName = className + "-generated.as";
        if (config.keepGeneratedActionScript())
        {
            saveGenerated(generatedFileName, code, config.getGeneratedDirectory());
        }

        Source s = new Source(new TextFile(code, generatedFileName, null,
                              MimeMappings.getMimeType(generatedFileName)),
                              "", className, null, false, false, false);
        s.setPathResolver(null);
        sources.add(s);

        // Ensure that this class gets linked in,
        // because no other code depends on it.
        // (ResourceManager looks it up by name.)
        configuration.getIncludes().add(className);
    }

    // error messages

    public static class DependencyNotCompatible extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -917715346261180364L;

        public String definition;
        public String swc;
        public String swcMinimumVersion;
        public String compatibilityVersion;

        public DependencyNotCompatible(String definition, String swc,
                                       String swcMinimumVersion, String compatibilityVersion)
        {
            this.definition = definition;
            this.swc = swc;
            this.swcMinimumVersion = swcMinimumVersion;
            this.compatibilityVersion = compatibilityVersion;
        }
    }

    public static class NoExternalVisibleDefinition extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -917715346261180363L;

        public NoExternalVisibleDefinition()
        {
            super();
        }
    }

    public static class MissingFactoryClassInFrameMetadata extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 1064989348731483344L;

        public MissingFactoryClassInFrameMetadata()
        {
            super();
        }
    }

    public static class InvalidBackgroundColor extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -623864938378435687L;

        public String backgroundColor;

        public InvalidBackgroundColor(String backgroundColor)
        {
            super();
            this.backgroundColor = backgroundColor;
        }
    }

    public static class CouldNotParseNumber extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 2186380089141871093L;

        public CouldNotParseNumber(String num, String attribute)
        {
            this.num = num;
            this.attribute = attribute;
        }

        public String num;
        public String attribute;
    }

    public static class MissingSignedLibraryDigest extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -1865860949469218550L;

        public MissingSignedLibraryDigest(String libraryPath)
        {
            this.libraryPath = libraryPath;
        }

        public String libraryPath;
    }

    public static class MissingUnsignedLibraryDigest extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 8092666584208136222L;

        public MissingUnsignedLibraryDigest(String libraryPath)
        {
            this.libraryPath = libraryPath;
        }

        public String libraryPath;
    }

	/**
	 *  Warn users with [RemoteClass] metadata that ends up mapping more than one class to the same alias. 
	 */
    public static class ClassesMappedToSameRemoteAlias extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 4365280637418299961L;
        
        public ClassesMappedToSameRemoteAlias(String className, String existingClassName, String alias)
        {
            this.className = className;
            this.existingClassName = existingClassName;
            this.alias = alias;
        }

        public String className;
        public String existingClassName;
        public String alias;
    }

    /**
     *  Tell the user they are making a mistake by compiling a module or application as a component. 
     */
    public static class CompiledAsAComponent extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -2874508107726441350L;

        public CompiledAsAComponent(String className, String mainDefinition)
        {
            this.className = className;
            this.mainDefinition = mainDefinition;
        }
        
        public String className;
        public String mainDefinition;

    }    
  
    /**
     *  "Required RSLs:" message. 
     */
    public static class RequiredRsls extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 2303666861783668660L;

        public RequiredRsls()
        {
        }

    }
    
    /**
     *  Display RSL URL with no failovers. 
     */
    public static class RequiredRslUrl extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 2303666861783668660L;

        public RequiredRslUrl(String rslUrl)
        {
            this.rslUrl = rslUrl;
        }

        public String rslUrl;
    }

    /**
     *  Display RSL URL with one failover. 
     */
    public static class RequiredRslUrlWithFailover extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 2303666861783668660L;

        public RequiredRslUrlWithFailover(String rslUrl)
        {
            this.rslUrl = rslUrl;
        }

        public String rslUrl;
    }

    /**
     *  Display RSL URL with more than one failovers. 
     */
    public static class RequiredRslUrlWithMultipleFailovers extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 2303666861783668660L;

        public RequiredRslUrlWithMultipleFailovers(String rslUrl, int failoverCount)
        {
            this.rslUrl = rslUrl;
            this.failoverCount = failoverCount;
        }
        
        public String rslUrl;
        public int failoverCount;

    }
    
}
