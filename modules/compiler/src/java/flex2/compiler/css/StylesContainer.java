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

import flex2.compiler.CompilationUnit;
import flex2.compiler.ResourceContainer;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.TextFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.io.VirtualZipFile;
import flex2.compiler.mxml.MxmlCompiler;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.SourceCodeBuffer;
import flex2.compiler.mxml.gen.VelocityUtil;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.AtEmbed;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.CompilerMessage.CompilerWarning;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.VelocityException;
import flex2.compiler.util.VelocityManager;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import flash.css.MediaList;
import flash.css.StyleDeclaration;
import flash.css.StyleDeclarationBlock;
import flash.css.StyleProperty;
import flash.css.StyleSelector;
import flash.css.StyleSheet;
import flash.fonts.FontManager;
import flash.util.Trace;
import macromedia.asc.util.ContextStatics;

import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;

/**
 * This class is an MXML document specific override of StyleModule. It provides
 * a context that manages style declarations for both default styles/themes
 * and document style nodes. 
 *
 * @author Paul Reilly
 * @author Pete Farland
 */
public class StylesContainer extends StyleModule
{
	private static final String TEMPLATE_PATH = "flex2/compiler/css/";
	private static final String ATEMBEDS_KEY = "atEmbeds";
    private static final String CLASSNAME_KEY = "className";
    //private static final String PACKAGENAME_KEY = "packageName"; TODO: get packageName working
    private static final String STYLEDEFLIST_KEY = "styleDefList";

    private static final String _FONTFACERULES = "_FontFaceRules";

    protected MxmlDocument mxmlDocument;
    private QName mxmlDocumentQName;
    protected MxmlConfiguration mxmlConfiguration;
    protected CompilationUnit compilationUnit;
    protected Set<String> localStyleTypeNames = new HashSet<String>();
    protected List<VirtualFile> implicitIncludes = new ArrayList<VirtualFile>();
    protected StyleDefList lastStyleDefList;      // prevent generating the styles source unnecessarily
    
    /**
     * Called by PreLink to load style declarations from defaults.css and
     * themes from SWCs.
     *
     * Also, called by MxmlDocument in preparation for local
     * StyleNodes.  DocumentBuilder.analyze(StyleNode) will call
     * extractStyles().
     * 
     * @param mxmlConfiguration
     * @param compilationUnit
     * @param perCompileData
     */
    public StylesContainer(MxmlConfiguration mxmlConfiguration,
                           CompilationUnit compilationUnit,
                           ContextStatics perCompileData)
    {
        super(compilationUnit.getSource(), perCompileData);
        this.mxmlConfiguration = mxmlConfiguration;
        this.compilationUnit = compilationUnit;

        if (mxmlConfiguration != null)
        {
            if (mxmlConfiguration.getCompatibilityVersion() <= flex2.compiler.common.MxmlConfiguration.VERSION_3_0)
            {
                setAdvanced(false);
                setQualifiedTypeSelectors(false);
            }
            else
            {
                setQualifiedTypeSelectors(mxmlConfiguration.getQualifiedTypeSelectors());
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    // Properties - MXML
    //
    //--------------------------------------------------------------------------

    MxmlDocument getMxmlDocument()
    {
        return mxmlDocument;
    }

    public void setMxmlDocument(MxmlDocument doc)
    {
        mxmlDocument = doc;

        // Store the QName, so that we can use it during validation.
        // ImplementationCompiler.parse1() nulls out the mxmlDocument.
        if (mxmlDocument != null)
        {
            mxmlDocumentQName = mxmlDocument.getQName();
        }
    }

    //--------------------------------------------------------------------------
    //
    // Methods - Public Entry Points
    //
    //--------------------------------------------------------------------------

    /**
     * Generate style classes for components which we want to link in. Called
     * from PreLink.processMainUnit() Update for Flex4: Put all the style defs
     * in one class instead of one class for each style def.
     * 
     * @param defNames
     * @param resources
     * @param packageName - package the className lives in. May be null for the default package.
     * @param className - name of the application class with the package. This
     * becomes the base of the generated style class name. If the class name if
     * null, then no sources will be generated.
     * @return true if a new source was generated
     */
    public boolean processDependencies(List<Source> extraSources, Set<String> defNames, ResourceContainer resources, 
                                            String packageName, String className)
    {
        if (className == null)
            return false;

        boolean regeneratedStyleSource = false;
        
        if (!fontFaceRules.isEmpty())
        {
            // C: mixins in the generated FlexInit class are referred to by
            // "name". that's why extraClasses is necessary.
            compilationUnit.extraClasses.add(_FONTFACERULES);
            compilationUnit.mixins.add(_FONTFACERULES);

            extraSources.add(generateFontFaceRules(resources));
        }

        Set<String> processedDefNames = new HashSet<String>();
        Iterator<String> defNameIterator = defNames.iterator();
        while (defNameIterator.hasNext())
        {
            String defName = defNameIterator.next();
            if (qualifiedTypeSelectors)
                processedDefNames.add(NameFormatter.toDot(defName));
            else
                processedDefNames.add(defName.replaceFirst(".*:", ""));
        }

        StyleDefList filteredStyleDefs = new StyleDefList();
        Iterator<Entry<String, StyleDef>> iterator = styleDefs.entrySet().iterator();
        while (iterator.hasNext())
        {
            Entry<String, StyleDef> entry = iterator.next();
            String styleName = entry.getKey();
            StyleDef styleDef = entry.getValue();
            String typeName = StyleDef.dehyphenize(styleName);
            
            if (!styleDef.isTypeSelector() || 
                (processedDefNames.contains(typeName) ||
                mxmlConfiguration.keepAllTypeSelectors()) || 
                styleName.equals(StyleDef.GLOBAL))
            {
                filteredStyleDefs.add(styleDef);
            }
        }

        if (filteredStyleDefs.size() > 0)
        {
            regeneratedStyleSource = true;
            className = "_" + className + "_Styles";

//            TODO: Get package name working.
//            String qualifiedClassName = className;
//            if (packageName != null && packageName.length() > 0)
//                qualifiedClassName = packageName + "." + className;
            
            compilationUnit.extraClasses.add(className);
            compilationUnit.mixins.add(className);

            // Determine whether we need to regenerate the style source based
            // on whether any new style definitions were included
            String genFileName = generateStyleSourceName(packageName, className);
            Source styleSource = resources.findSource(genFileName);
            if (styleSource != null)
            {
                if (styleSource.getCompilationUnit() == null) 
                {
                    // if no compilationUnit, then we need to generate source so we can recompile.
                    styleSource = null;
                }
                else 
                {
                    // If the styles are the same as the last time we generated the source then return
                    // the existing source. We can get called here multiple times while compiling the same file 
                    // so this check keeps us from generating the same source each time. We will always generate
                    // a new style file the first time we are called here because lastStyleDefList will be null.
                    if (lastStyleDefList != null && lastStyleDefList.getStyleDefs().equals(filteredStyleDefs.getStyleDefs()))
                    {
                        regeneratedStyleSource = false;                 
                    }
                }
            }

            lastStyleDefList = filteredStyleDefs;

            if (regeneratedStyleSource)
            {
                styleSource = generateStyleSource(filteredStyleDefs, resources, packageName, className, genFileName);
            }

            extraSources.add(styleSource);
        }

        return regeneratedStyleSource;
    }

    /**
     * Warn if we have a type selector outside of the root MXML (Application).
     */
    private boolean hasNonRootTypeSelectors(String subject, String selector, int lineNumber)
    {
        if (!compilationUnit.isRoot() && !StyleDef.UNIVERSAL.equals(subject))
        {
            // [preilly] This restriction should be removed once the
            // app model supports encapsulation of CSS styles.
            ComponentTypeSelectorsNotSupported componentTypeSelectorsNotSupported =
                new ComponentTypeSelectorsNotSupported(getSource().getName(),
                                                       lineNumber,
                                                       selector);
            ThreadLocalToolkit.log(componentTypeSelectorsNotSupported);
            return true;
        }

        return false;
    }

    /**
     * Check for simple type selectors that were not needed as the associated
     * component definition was not used in the Application.
     * 
     * Called from PreLink.processMainUnit()
     */
    public void validate(SymbolTable symbolTable, NameMappings nameMappings,
                         StandardDefs standardDefs, Set<String> themeNames, Set<String> addedCSSFiles)
    {
        Set<String> classNames;
        TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(MxmlCompiler.TYPE_TABLE);

        if (typeTable == null)
        {
            typeTable = new TypeTable(symbolTable, nameMappings, standardDefs, themeNames);
        }

        if (qualifiedTypeSelectors)
        {
            classNames = symbolTable.getClassNames();
        }
        else
        {
            classNames = new HashSet<String>();

            for (String className : symbolTable.getClassNames())
            {
                if (qualifiedTypeSelectors)
                    classNames.add(NameFormatter.toDot(className));
                else
                    classNames.add(className.replaceFirst(".*:", ""));
            }
        }

        // Strip off the leading '[' and trailing ']'.
        String themeNamesString = themeNames.toString();
        themeNamesString = themeNamesString.substring(1, themeNamesString.length() - 1);

        for (Entry<String, StyleDef> entry : styleDefs.entrySet())
        {
            String styleName = entry.getKey();
            StyleDef styleDef = entry.getValue();
            String typeName = StyleDef.dehyphenize(styleName);

            Map<String, StyleDeclaration> declarations = styleDef.getDeclarations();

            if (declarations != null)
            {
                for (StyleDeclaration styleDeclaration : declarations.values())
                {
                    Collection<StyleDeclarationBlock> blocks = styleDeclaration.getDeclarationBlocks();
                    for (StyleDeclarationBlock block : blocks)
                    {
                        Map<String, StyleProperty> styleProperties = block.getProperties();
    
                        if (addedCSSFiles == null || addedCSSFiles.contains(styleDeclaration.getPath()))
                        {
                            if (styleDef.isTypeSelector())
                            {
                                if (qualifiedTypeSelectors && mxmlConfiguration.showInvalidCssPropertyWarnings())
                                {
                                    Type type = typeTable.getType(NameFormatter.toColon(typeName));
    
                                    if (type != null)
                                    {
                                        validateTypeSelectorProperties(styleProperties, type, styleDef,
                                                                       typeName, themeNamesString);
                                    }
                                }
                            }
    
                            if (mxmlDocumentQName != null)
                            {
                                // Don't use getType(QName), because that
                                // tries to lookup the class name in the
                                // manifest.  Use getType(String) instead.
                                Type mxmlDocumentType = typeTable.getType(mxmlDocumentQName.toString());
                                assert mxmlDocumentType != null;
                                validatePropertyReferences(styleProperties, mxmlDocumentType);
                            }
                        }
                    }
                }

                if (localStyleTypeNames.contains(styleName) &&
                    !classNames.contains(NameFormatter.toColon(typeName)) &&
                    !styleName.equals(StyleDef.GLOBAL))
                {
                    if (mxmlConfiguration.showUnusedTypeSelectorWarnings())
                    {
                        ThreadLocalToolkit.log(new UnusedTypeSelector(getPathForReporting(styleDef),
                                                                      styleDef.getLineNumber(),
                                                                      styleName));
                    }
                }
            }
        }
    }

    /**
     * Validate that each type selector property matches up with a
     * defined style with a matching theme in the type selector's
     * type.
     */
    private void validateTypeSelectorProperties(Map<String, StyleProperty> styleProperties,
                                                Type type, StyleDef styleDef, String typeName,
                                                String themeNamesString)
    {
        if (styleProperties != null)
        {
            for (StyleProperty styleProperty : styleProperties.values())
            {
                String stylePropertyName = styleProperty.getName();

                if (type.getStyle(stylePropertyName) == null)
                {
                    String styleThemes = type.getStyleThemes(stylePropertyName);

                    if (type.isExcludedStyle(stylePropertyName))
                    {
                        ThreadLocalToolkit.log(new ExcludedStyleProperty(styleProperty.getPath(),
                                                                         styleProperty.getLineNumber(),
                                                                         stylePropertyName,
                                                                         typeName));
                    }
                    else if (styleThemes != null)
                    {
                        ThreadLocalToolkit.log(new InvalidStyleTheme(styleProperty.getPath(),
                                                                     styleProperty.getLineNumber(),
                                                                     stylePropertyName,
                                                                     typeName,
                                                                     styleThemes));
                    }
                    else if (mxmlDocument != null)
                    {
                        ThreadLocalToolkit.log(new InvalidStyleProperty(styleProperty.getPath(),
                                                                        styleProperty.getLineNumber(),
                                                                        stylePropertyName,
                                                                        typeName));
                    }
                }
            }
        }
    }

    /**
     * Validate that each property reference matches up with a document property.
     */
    private void validatePropertyReferences(Map<String, StyleProperty> styleProperties,
                                            Type mxmlDocumentType)
    {
        if (styleProperties != null)
        {
            for (StyleProperty styleProperty : styleProperties.values())
            {
                Object value = styleProperty.getValue();

                if (value instanceof Reference)
                {
                    Reference reference = (Reference) value;

                    // We only allow property references to document properties.  See SDK-22995.
                    if (!reference.isClassReference() &&
                        (mxmlDocumentType.getProperty(reference.getValue()) == null))
                    {
                        InvalidPropertyReference invalidPropertyReference =
                            new InvalidPropertyReference(reference.getValue());
                        invalidPropertyReference.path = styleProperty.getPath();
                        invalidPropertyReference.line = styleProperty.getLineNumber();
                        ThreadLocalToolkit.log(invalidPropertyReference);
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    // Methods - MXML Overrides
    //
    //--------------------------------------------------------------------------

    @Override
    /**
     * This MXML Specific Override only allows type selectors to be declared
     * on the root document.
     */
    protected void addSelectorToStyleDef(String subject, StyleDeclaration declaration,
            boolean isTypeSelector, boolean isLocal, int lineNumber)
    {
        // Only allow type selectors on the root (Application). StyleManager is
        // a singleton so type selector overrides in arbitrary custom components
        // would be difficult to track down and not behave as expected.
        if (isTypeSelector && hasNonRootTypeSelectors(subject, subject, lineNumber))
            return;

        StyleDef styleDef;

        if (isTypeSelector && isLocal)
        {
            localStyleTypeNames.add(subject);
        }

        if (styleDefs.containsKey(subject))
        {
            styleDef = styleDefs.get(subject);
        }
        else
        {
            styleDef = new StyleDef(subject, isTypeSelector, mxmlDocument, mxmlConfiguration,
                    compilationUnit.getSource(), lineNumber, perCompileData);
            styleDefs.put(subject, styleDef);
        }

        styleDef.addDeclaration(declaration);

        if (mxmlDocument != null)
        {
            Iterator<Import> iterator = styleDef.getImports().iterator();
            while (iterator.hasNext())
            {
                Import importObject = iterator.next();
                mxmlDocument.addImport(importObject.getValue(), importObject.getLineNumber());
            }
        }
    }

    @Override
    /**
     * This MXML Specific Override only allows type selectors to be declared
     * on the root document.
     */
    protected void addAdvancedSelectorToStyleDef(StyleDeclaration declaration,
            MediaList mediaList, boolean isLocal, int lineNumber)
    {
        String subject = declaration.getSubject();
        StyleSelector selector = declaration.getSelector();

        // Only allow type selectors on the root (Application). StyleManager is
        // a singleton so type selector overrides in arbitrary custom components
        // would be difficult to track down and not behave as expected.
        if (hasNonRootTypeSelectors(subject, selector.toString(), lineNumber))
            return;

        StyleDef styleDef;
        String styleDefKey = subject;

        // Treat a "*" subject like Flex's special "global" subject to follow
        // mxmlc's distinction of type selectors vs. universal selectors for
        // the purposes of code-generation.
        if (StyleDef.UNIVERSAL.equals(subject))
        {
            styleDefKey = StyleDef.GLOBAL;

            // If we have conditions, we can make "*" implied.
            if (selector.getConditions() != null && selector.getConditions().size() > 0)
            {
                selector.setValue("");
            }
        }

        if (styleDefs.containsKey(styleDefKey))
        {
            styleDef = styleDefs.get(styleDefKey);
        }
        else
        {
            if (isLocal && !StyleDef.GLOBAL.equals(styleDefKey))
                localStyleTypeNames.add(subject);

            styleDef = new StyleDef(subject, mxmlDocument, mxmlConfiguration, 
            		                getSource(), lineNumber, perCompileData);
            styleDefs.put(styleDefKey, styleDef);
        }

        styleDef.addAdvancedDeclaration(declaration, mediaList);

        if (mxmlDocument != null)
        {
            Iterator<Import> iterator = styleDef.getImports().iterator();
            while (iterator.hasNext())
            {
                Import importObject = iterator.next();
                mxmlDocument.addImport(importObject.getValue(),
                        importObject.getLineNumber());
            }
        }
    }

    @Override
    protected void addAtEmbed(AtEmbed atEmbed)
    {
        if (mxmlDocument != null)
        {
            mxmlDocument.addAtEmbed(atEmbed);
        }
        else if (!atEmbeds.containsKey(atEmbed.getPropName()))
        {
            atEmbeds.put(atEmbed.getPropName(), atEmbed);
        }
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods - Font Face Rules 
    //
    //--------------------------------------------------------------------------

	private String generateFontFaceRuleSourceName()
	{
		String genFileName;
		String genDir = mxmlConfiguration.getGeneratedDirectory();
	    if (genDir != null)
	    {
		    genFileName = genDir + File.separatorChar + "_FontFaceRules.as";
	    }
	    else
	    {
		    genFileName = "_FontFaceRules.as";
	    }
		return genFileName;
	}

    private Source generateFontFaceRules(ResourceContainer resources)
    {
	    String genFileName = generateFontFaceRuleSourceName();
	    Source styleSource = resources.findSource(genFileName);
	    if (styleSource != null)
	    {
            if (styleSource.getCompilationUnit() == null) 
            {
                // if no compilationUnit, then we need to generate source so we can recompile.
                styleSource = null;
            }
            else 
            {
                // C: it is safe to return because this method deals with per-app styles, like defaults.css and themes.
                //    ResourceContainer will not have anything if any of the theme files is touched.
                return styleSource;
            }
	    }

	    StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
	    String fontFaceRulesTemplate = TEMPLATE_PATH + standardDefs.getFontFaceRulesTemplate();
		Template template;

        try
		{
            template = VelocityManager.getTemplate(fontFaceRulesTemplate);
        }
        catch (Exception exception)
        {
			ThreadLocalToolkit.log(new VelocityException.TemplateNotFound(fontFaceRulesTemplate));
			return null;
		}

		SourceCodeBuffer out = new SourceCodeBuffer();

		try
		{
			VelocityUtil util = new VelocityUtil(TEMPLATE_PATH, mxmlConfiguration.debug(), out, null);
			VelocityContext vc = VelocityManager.getCodeGenContext(util);
            vc.put(ATEMBEDS_KEY, atEmbeds);
			template.merge(vc, out);
		}
		catch (Exception e)
		{
			ThreadLocalToolkit.log(new VelocityException.GenerateException(compilationUnit.getSource().getRelativePath(),
                                                                           e.getLocalizedMessage()));
			return null;
		}

	    return resources.addResource(createSource(genFileName, out, Long.MAX_VALUE));
    }

    //--------------------------------------------------------------------------
    //
    // Methods - ActionScript Code Generation 
    //
    //--------------------------------------------------------------------------

    private Source createSource(String fileName, SourceCodeBuffer sourceCodeBuffer, long lastModifiedTime)
    {
        Source result = null;

        if (sourceCodeBuffer.getBuffer() != null)
        {
            String sourceCode = sourceCodeBuffer.toString();

            if (mxmlConfiguration.keepGeneratedActionScript())
            {
                try
                {
                    FileUtil.writeFile(fileName, sourceCode);
                }
                catch (IOException e)
                {
                    ThreadLocalToolkit.log(new VelocityException.UnableToWriteGeneratedFile(fileName, e.getMessage()));
                }
            }

            VirtualFile genFile = new TextFile(sourceCode, fileName, null, MimeMappings.AS, lastModifiedTime);
            String shortName = fileName.substring(0, fileName.lastIndexOf('.'));

            result = new Source(genFile, "", shortName, null, false, false, false);
            result.setPathResolver(compilationUnit.getSource().getPathResolver());

            Iterator<VirtualFile> iterator = implicitIncludes.iterator();

            while ( iterator.hasNext() )
            {
                VirtualFile virtualFile = iterator.next();
                result.addFileInclude(virtualFile);
            }
        }

        return result;
    }

    private Source generateStyleSource(StyleDefList styleDefList, ResourceContainer resources, 
                                       String packageName, String className, String genFileName)
    {
	    //	load template

	    Template template;
        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
        String styleDefTemplate = TEMPLATE_PATH + standardDefs.getStyleDefTemplate();

        try
		{
            template = VelocityManager.getTemplate(styleDefTemplate);
        }
        catch (Exception exception)
        {
			ThreadLocalToolkit.log(new VelocityException.TemplateNotFound(styleDefTemplate));
			return null;
		}

		SourceCodeBuffer out = new SourceCodeBuffer();

		try
		{
			VelocityUtil util = new VelocityUtil(TEMPLATE_PATH, mxmlConfiguration.debug(), out, null);
			VelocityContext vc = VelocityManager.getCodeGenContext(util);
			vc.put(STYLEDEFLIST_KEY, styleDefList);
            // vc.put(PACKAGENAME_KEY, packageName); TODO: get packagename working
			vc.put(CLASSNAME_KEY, className);
			template.merge(vc, out);
		}
		catch (Exception e)
		{
			ThreadLocalToolkit.log(new VelocityException.GenerateException(compilationUnit.getSource().getRelativePath(),
                                                                           e.getLocalizedMessage()));
			return null;
		}

        // Set a last modified time so the old compilation unit will be thrown 
		// out when we add our new source.
	    return resources.addResource(createSource(genFileName, out, System.currentTimeMillis()));
    }

    private String generateStyleSourceName(String packageName, String className)
    {
        String genFileName;
        String genDir = mxmlConfiguration.getGeneratedDirectory();

        if (genDir != null)
        {
            genFileName = genDir + File.separatorChar + className + ".as";
//                          TODO: get packageName working            
//                          File.separatorChar + 
//                          packageName.replace('.', File.separatorChar ) +
//                          File.separatorChar + className + ".as";
        }
        else
        {
            genFileName = className + ".as";
//              TODO: get packageName working            
//                packageName.replace('.', File.separatorChar) +
//                          File.separatorChar + className + ".as";
        }

        return genFileName;
    }

    //--------------------------------------------------------------------------
    //
    // Initialization and defaults.css
    //
    //--------------------------------------------------------------------------

    public void loadDefaultStyles()
    {
        VirtualFile defaultsCSSFile = resolveDefaultsCssFile();

        // Load the per SWC default styles first
        for (VirtualFile swcDefaultsCssFile : mxmlConfiguration.getDefaultsCssFiles())
        {
            // Make sure that we resolve things relative to the SWC.
            ThreadLocalToolkit.getPathResolver().addSinglePathResolver(0, swcDefaultsCssFile);
            processStyleSheet(swcDefaultsCssFile);
            ThreadLocalToolkit.getPathResolver().removeSinglePathResolver(swcDefaultsCssFile);
        }

        // Load the default styles next, so they can override the SWC defaults
        if (defaultsCSSFile != null)
        {
            // Only load the defaults if it's not from a SWC.
            // Defaults from a SWC will have already been loaded if a
            // component from the SWC has been used in the compilation.
            if (!(defaultsCSSFile instanceof VirtualZipFile))
            {
                processStyleSheet(defaultsCSSFile);
            }
        }
        else
        {
            ThreadLocalToolkit.log(new DefaultCSSFileNotFound());
        }

        // Load the theme styles next, so they can override the defaults
        for (Iterator<VirtualFile> it = mxmlConfiguration.getThemeCssFiles().iterator(); it.hasNext();)
        {
            VirtualFile themeCssFile = it.next();

            // Make sure that we resolve things in the theme relative
            // to the theme SWC first.
            ThreadLocalToolkit.getPathResolver().addSinglePathResolver(0, themeCssFile);
            processStyleSheet(themeCssFile);
            ThreadLocalToolkit.getPathResolver().removeSinglePathResolver(themeCssFile);
        }
    }

    private VirtualFile resolveDefaultsCssFile()
    {
        VirtualFile defaultsCSSFile = mxmlConfiguration.getDefaultsCssUrl();

        if (defaultsCSSFile == null)
        {
            PathResolver resolver = ThreadLocalToolkit.getPathResolver();

            String version = mxmlConfiguration.getCompatibilityVersionString();

            if (version != null)
            {
                defaultsCSSFile = resolver.resolve("defaults-" + version + ".css");
            }

            if (defaultsCSSFile == null)
            {
                defaultsCSSFile = resolver.resolve("defaults.css");
            }
        }

        return defaultsCSSFile;
    }

    private void processStyleSheet(VirtualFile cssFile)
    {
        implicitIncludes.add(cssFile);
        InputStream cssFileStream = null;

        try
        {
            FontManager fontManager = mxmlConfiguration.getFontsConfiguration().getTopLevelManager();
            StyleSheet styleSheet = new StyleSheet();
            styleSheet.checkDeprecation(mxmlConfiguration.showDeprecationWarnings());
            cssFileStream = cssFile.getInputStream();
            styleSheet.parse(cssFile.getName(), cssFileStream, ThreadLocalToolkit.getLogger(), fontManager);
            extractStyles(styleSheet, false);
        }
        catch (Exception exception)
        {
            CompilerMessage m = new ParseError(exception.getLocalizedMessage());
            m.setPath(cssFile.getName());
            ThreadLocalToolkit.log(m);
        }
        finally
        {
            if (cssFileStream != null)
            {
                try
                {
                    cssFileStream.close();
                }
                catch (IOException e)
                {
                    // print the stack trace so we know we had a failure but
                    // otherwise ignore.
                    if (Trace.error)
                        e.printStackTrace();
                }
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    // Errors and Warnings 
    //
    //--------------------------------------------------------------------------

    private String getPathForReporting(StyleDef styleDef)
    {
        if (styleDef.isAdvanced())
        {
            // Return the path of the first StyleDeclaration that refers to
            // the subject of this StyleDef
            Map<String, StyleDeclaration> declarations = styleDef.getDeclarations(); 
            for (StyleDeclaration decl : declarations.values())
            {
                if (decl != null && decl.getPath() != null)
                {
                    return decl.getPath();
                }
            }
        }

        return compilationUnit.getSource().getName();
    }

    /**
     * Simple class that contains a list of StyleDefs. This class is only used
     * to temporary contain a list of style defs that we will pass to the
     * StyleDef velocity template to generate the style code. The StyleDef
     * template now generates code for a list of styles in one class instead of
     * a class for every style. The API is minimal to just add entries to the
     * list and to satisfy the needs of StyleDef.vm. For example the is an "add"
     * method but no "remove" or "clear". This is because the whole list is
     * garbage collected after it is used.
     */
    public class StyleDefList
    {
        List<StyleDef> styleDefs;

        public StyleDefList()
        {
            styleDefs = new ArrayList<StyleDef>();
        }

        public List<StyleDef> getStyleDefs()
        {
            return styleDefs;
        }

        public void add(StyleDef styleDef)
        {
            styleDefs.add(styleDef);
        }

        public int size()
        {
            return styleDefs.size();
        }

        public boolean isAdvanced()
        {
            for (StyleDef styleDef : styleDefs)
            {
                if (styleDef.isAdvanced())
                    return true;
            }

            return false;
        }

        public boolean getAllowDuplicateDefaultStyleDeclarations()
        {
            for (StyleDef styleDef : styleDefs)
            {
                if (styleDef.getAllowDuplicateDefaultStyleDeclarations())
                    return true;
            }

            return false;
        }
        
        /**
         * @return imports with duplicates removed. 
         */
        public Set<Import> getImports()
        {
            Set<Import> result = new HashSet<Import>();

            for (StyleDef styleDef : styleDefs)
                result.addAll(styleDef.getImports());
            
            return result;            
        }

        /**
         * @return AtEmbeds with duplicates removed.
         */
        public Set<AtEmbed> getAtEmbeds()
        {
            Set<AtEmbed> result = new HashSet<AtEmbed>();

            for (StyleDef styleDef : styleDefs)
                result.addAll(styleDef.getAtEmbeds());
            
            return result;            
        }        
    }
    
    public static class DefaultCSSFileNotFound extends CompilerWarning
    {
        private static final long serialVersionUID = -7274067342526310418L;

        public DefaultCSSFileNotFound()
        {
        }
    }

    public static class ExcludedStyleProperty extends CompilerWarning
    {
        private static final long serialVersionUID = -655374071288180325L;
        public String stylePropertyName;
        public String typeName;

        public ExcludedStyleProperty(String path, int line, String stylePropertyName,
                                     String typeName)
        {
            this.path = path;
            this.line = line;
            this.stylePropertyName = stylePropertyName;
            this.typeName = typeName;
        }
    }

    public static class InvalidStyleProperty extends CompilerWarning
    {
        private static final long serialVersionUID = -655374071288180326L;
        public String stylePropertyName;
        public String typeName;

        public InvalidStyleProperty(String path, int line, String stylePropertyName,
                                    String typeName)
        {
            this.path = path;
            this.line = line;
            this.stylePropertyName = stylePropertyName;
            this.typeName = typeName;
        }
    }

    public static class InvalidStyleTheme extends CompilerWarning
    {
        private static final long serialVersionUID = -655374071288180328L;

        public String stylePropertyName;
        public String typeName;
        public String styleThemes;

        public InvalidStyleTheme(String path, int line, String stylePropertyName,
                                 String typeName, String styleThemes)
        {
            this.path = path;
            this.line = line;
            this.stylePropertyName = stylePropertyName;
            this.typeName = typeName;
            this.styleThemes = styleThemes;
        }
    }

    public static class UnusedTypeSelector extends CompilerWarning
    {
        private static final long serialVersionUID = -655374071288180326L;
        public String styleName;

        public UnusedTypeSelector(String path, int line, String styleName)
        {
            this.path = path;
            this.line = line;
            this.styleName = styleName;
        }
    }

    public static class ComponentTypeSelectorsNotSupported extends CompilerWarning
    {
        private static final long serialVersionUID = -1211821282841071569L;
        public String selector;

        public ComponentTypeSelectorsNotSupported(String path, int line, String selector)
        {
            this.path = path;
            this.line = line;
            this.selector = selector;
        }
    }

    public static class InvalidPropertyReference extends CompilerError
    {
        private static final long serialVersionUID = 3730898410175891395L;
        public String value;

        public InvalidPropertyReference(String value)
        {
            this.value = value;
        }
    }
}
