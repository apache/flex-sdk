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

package flex2.tools.oem;

import java.io.File;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import macromedia.asc.embedding.WarningConstants;

/**
 * The <code>Configuration</code> interface allows clients to set compiler options for Application and Library.
 * The client can not instantiate a <code>Configuration</code> object. It can be obtained by invoking the
 * <code>getDefaultConfiguration()</code> method in <code>Application</code> and <code>Library</code>.
 * 
 * <pre>
 * Application app = new Application(new File("HelloWorld.mxml"));
 * Configuration c1 = app.getDefaultConfiguration();
 * 
 * Library lib = new Library();
 * Configuration c2 = lib.getDefaultConfiguration();
 * </pre>
 * 
 * The compiler populates the default <code>Configuration</code> object with the values in <code>flex-config.xml</code>. 
 * If a local configuration file is also available (for example, <code>HelloWorld-config.xml</code>), the compiler also uses 
 * values in that file to populate the <code>Configuration</code> object. The local configuration file's values take precedence
 * over options set in the <code>flex-config.xml</code> file. If you add a configuration file using the <code>addConfiguration()</code>
 * method, that configuration file's options take precedence over those set in flex-config.xml or in a local configuration file; they
 * do not take precedence over configuration options set using the <code>Configuration</code> interface's methods such as <code>setExterns()</code>.
 * 
 * <p>
 * The order of configuration option precedence is as follows (highest first):
 * <PRE>
 * 1. Methods of the <code>Configuration</code> interface such as <code>setExterns()</code>.
 * 2. Configuration file loaded with the <code>addConfiguration()</code> method.
 * 3. Local configuration file (such as <em>app_name</em>-config.xml).
 * 4. The flex-config.xml file.
 * 5. Default compiler settings.
 * </PRE>
 * 
 * @version 2.0.1
 * @author Clement Wong
 */
public interface Configuration
{
    /**
     * Enables accessibility in the application.
     * This is equivalent to using the <code>accessible</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value that enables or disables accessibility.
     */
    void enableAccessibility(boolean b);
    
    /**
     * Sets the ActionScript file encoding. The compiler uses this encoding to read
     * the ActionScript source files.
     * This is equivalent to using the <code>actionscript-file-encoding</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default encoding is <code>UTF-8</code>.
     * 
     * @param encoding The character encoding; for example <code>UTF-8</code> or <code>Big5</code>.
     */
    void setActionScriptFileEncoding(String encoding);
    
    /**
     * Allows some source path directories to be subdirectories of the other.
     * This is equivalent to using the <code>compiler.allow-source-path-overlap</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * In some J2EE settings, directory overlapping should be allowed; for example:     
     * 
     * <pre>
     * wwwroot/MyAppRoot
     * wwwroot/WEB-INF/flex/source_path1
     * </pre>
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value that allows directory overlapping.
     */
    void allowSourcePathOverlap(boolean b);
    
    /**
     * Uses the ActionScript 3 class-based object model for greater performance and better error reporting.
     * In the class-based object model, most built-in functions are implemented as fixed methods of classes.
     * This is equivalent to using the <code>compiler.as3</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value that determines whether to use the AS3 class-based object model.
     */
    void useActionScript3(boolean b);
    
    /**
     * Sets the context root path so that the compiler can replace <code>{context.root}</code> tokens for
     * service channel endpoints. This is equivalent to using the <code>compiler.context-root</code> option
     * for the mxmlc or compc compilers.
     * 
     * <p>
     * By default, this value is undefined.
     * 
     * @param path An instance of String.
     */
    void setContextRoot(String path);

    /**
     * Enables debugging in the application.
     * This is equivalent to using the <code>compiler.debug</code> and <code>-debug-password=true|false</code> options
     * for the mxmlc or compc compilers.
     * 
     * <p>
     * The default value <code>debug</code> is <code>false</code>. The default debug password is "".
     * 
     * @param b Boolean value that enables or disables debugging.
     * @param debugPassword A password that is embedded in the application.
     */
    void enableDebugging(boolean b, String debugPassword);
    
    /**
     * Sets the location of the default CSS file.
     * This is equivalent to using the <code>compiler.defaults-css-url</code> option of the mxmlc or compc compilers</code>.
     * 
     * @param url An instance of <code>java.io.File</code>.
     */
    void setDefaultCSS(File url);
    
    /**
     * Uses the ECMAScript edition 3 prototype-based object model to allow dynamic overriding
     * of prototype properties. In the prototype-based object model, built-in functions are
     * implemented as dynamic properties of prototype objects.
     * This is equivalent to using the <code>compiler.es</code> option for the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value that enables or disables the use of the ECMAScript edition 3 prototype-based object model.
     */
    void useECMAScript(boolean b);

    /**
     * Sets the list of SWC files or directories to compile against, but to omit from linking.
     * This is equivalent to using the <code>compiler.external-library-path</code> option of the 
     * mxmlc or compc compilers.
     * 
     * @param paths A list of paths. The <code>File.isDirectory()</code> method should return 
     * <code>true</code>; <code>File</code> instances should represent SWC files.
     */
    void setExternalLibraryPath(File[] paths);

    /**
     * Adds to the existing list of SWC files.
     * 
     * @see #setExternalLibraryPath(File[])
     * 
     * @param paths A list of paths. The <code>File.isDirectory()</code> method should return 
     * <code>true</code>; <code>File</code> instances should represent SWC files.
     */
    void addExternalLibraryPath(File[] paths);

    /**
     * Sets a range to restrict the number of font glyphs embedded into the application.
     * This is equivalent to using the <code>compiler.fonts.languages.language-range</code> option
     * for the mxmlc or compc compilers.
     * 
     * <p>
     * For example:
     * 
     * <pre>
     * setFontLanguageRange("englishRange", "U+0020-U+007E");
     * </pre>
     * 
     * @param language Represents the language name.
     * @param range Defines range of glyphs.
     */
    void setFontLanguageRange(String language, String range);
    
    /**
     * Sets the location of the local font snapshot file. The file contains system font data produced by the 
     * <code>flex2.tools.FontSnapshot</code> tool. This is equivalent to using the <code>compiler.fonts.local-fonts-snapshot</code>
     * option for the mxmlc or compc compilers.
     * 
     * @param file Local font snapshot file.
     */
    void setLocalFontSnapshot(File file);

    /**
     * Sets the local font file paths to be searched by the compiler.
     * This is equivalent to using <code>mxmlc/compc --compiler.fonts.local-font-paths</code>.
     * 
     * @param paths an array of file paths.
     */
    void setLocalFontPaths(String[] paths);

    /**
     * Adds local font paths to the existing local font path list.
     * 
     * @see #setLocalFontPaths(String[])
     * @param paths an array of local font file paths.
     */
    void addLocalFontPaths(String[] paths);

    /**
     * Sets the font managers used by the compiler. Replaces the existing list of font managers.
     * The default is <code>flash.fonts.JREFontManager</code>.
     * This is equivalent to using the <code>compiler.fonts.managers</code> option for the mxmlc or compc compilers.
     * 
     * <p>
     * For example:
     * 
     * <pre>
     * setFontManagers("flash.fonts.BatikFontManager");
     * </pre>
     * 
     * @param classNames An array of Java class names.
     */
    void setFontManagers(String[] classNames);
    
    /**
     * Adds font managers to the existing font manager list.
     * 
     * @see #setFontManagers(String[])
     * @param classNames An array of Java class names.
     */
    void addFontManagers(String[] classNames);
    
    /**
     * Sets the maximum number of embedded font faces that can be cached.
     * This is equivalent to using the <code>compiler.fonts.max-cached-fonts</code> option for the 
     * mxmlc or compc compilers.
     * 
     * <p>
     * The default value is 20.
     * 
     * @param size An integer representing the maximum number of embedded font faces.
     */
    void setMaximumCachedFonts(int size);
    
    /**
     * Sets the maximum number of character glyph outlines to cache for each font face.
     * This is equivalent to using the <code>compiler.fonts.max-glyphs-per-face</code> option
     * for the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is 1000.
     *  
     * @param size An integer representing the maximum number of character glyph outlines to cache for each font face.
     */
    void setMaximumGlyphsPerFace(int size);
    
    /**
     * Sets the compiler when it runs on a server without a display.
     * This is equivalent to using the <code>compiler.headless-server</code> option of the mxmlc or compc compilers.
     * 
     * @param b Boolean value that determines if the compiler is running on a server without a display.
     */
    void useHeadlessServer(boolean b);
    
    /**
     * Sets the ActionScript metadata that the compiler keeps in the SWF.
     * This is equivalent to using the <code>compiler.keep-actionscript-metadata</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>{Bindable, Managed, ChangeEvent, NonCommittingChangeEvent, Transient}</code>.
     * 
     * @param md An array of ActionScript metadata names.
     */
    void setActionScriptMetadata(String[] md);
    
    /**
     * Adds the list of ActionScript metadata names to the existing list of ActionScript metadata
     * that the compiler keeps in the SWF.
     * 
     * @see #setActionScriptMetadata(String[])
     * 
     * @param md An array of ActionScript metadata names.
     */
    void addActionScriptMetadata(String[] md);
    
    /**
     * Instructs the compiler to keep a style sheet's type selector in a SWF file, even if that type 
     * (the class) is not used in the application. 
     * This is equivalent to using the <code>compiler.keep-all-type-selectors</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value.
     */
    void keepAllTypeSelectors(boolean b);
    
    /**
     * Saves temporary source files that are generated during MXML compilation.
     * This is equivalent to using the <code>compiler.keep-generated-actionscript</code> option of the 
     * mxmlc and compc compilers.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value.
     */
    void keepCompilerGeneratedActionScript(boolean b);

    /**
     * Instructs the linker to keep a report of the content that is included in the application.
     * You can use the <code>Report.writeLinkReport()</code> method to retrieve the linker report.
     * 
     * @param b Boolean value.
     */
    void keepLinkReport(boolean b);
    
    /**
     * Instructs the linker to keep a SWF size summary.
     * You can use the <code>Report.writeSizeReport()</code> method to retrieve the linker report.
     * 
     * @param b Boolean value.
     */
    void keepSizeReport(boolean b);
    
    /**
     * Instructs the compiler to keep a report of the compiler configuration settings.
     * You can use the <code>Report.writeConfigurationReport()</code> method to retrieve the configuration report.
     * 
     * @param b Boolean value.
     */
    void keepConfigurationReport(boolean b);
    
    /**
     * Includes a list of SWC files to completely include in the application.
     * This is equivalent to using the <code>compiler.include-libraries</code> option of the mxmlc and compc compilers.
     * 
     * @see #setIncludes(String[])
     * @see #setExterns(File[])
     * @see #setExterns(String[])
     * @see #setExternalLibraryPath(File[])
     * 
     * @param libraries An array of <code>File</code> objects. The <code>File.isDirectory()</code> method should return 
     * <code>true</code>; or instances must represent SWC files.
     */
    void includeLibraries(File[] libraries);
    
    /**
     * Sets a list of SWC files or directories that contain SWC files.
     * This is equivalent to using the <code>compiler.library-path</code> option of the mxmlc or compc compilers.
     * 
     * @param paths An array of <code>File</code> objects. The <code>File.isDirectory()</code> method should return 
     * <code>true</code>; instances must represent SWC files.
     */
    void setLibraryPath(File[] paths);

    /**
     * Adds a list of SWC files or directories to the default library path.
     * 
     * @see #setLibraryPath(File[])
     * 
     * @param paths An array of <code>File</code> objects. The <code>File.isDirectory()</code> method should return 
     * <code>true</code>; instances must represent SWC files.
     */
    void addLibraryPath(File[] paths);
    
    /**
     * Sets the locales that the compiler uses to replace <code>{locale}</code> tokens that appear in some configuration values.
     * This is equivalent to using the <code>compiler.locale</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * For example:
     * 
     * <pre>
     * addSourcePath(new File[] { "locale/{locale}" });
     * setLocales(new String[] { "en_US" });
     * </pre>
     * 
     * <p>
     * The compiler adds the <code>locale/en_US</code> directory to the source path.
     *
     * @param locales An array of Strings specifying locales.
     * 
     * @since 3.0
     */
    void setLocale(String[] locales);
    
    /**
     * Sets the locale that the compiler uses to replace <code>{locale}</code> tokens that appear in some configuration values.
     * This is equivalent to using the <code>compiler.locale</code> option of the mxmlc or compc compilers
     * to set a single locale.
     * 
     * <p>
     * For example:
     * 
     * <pre>
     * addSourcePath(new File[] { "locale/{locale}" });
     * setLocale(Locale.US);
     * </pre>
     * 
     * <p>
     * The compiler adds the <code>locale/en_US</code> directory to the source path.
     *
     * @param locale A <code>java.util.Locale</code>.
     * 
     * @deprecated As of 3.0, use setLocale(String[])
     */
    void setLocale(Locale locale);
    
    /**
     * Specifies a URI to associate with a manifest of components for use as MXML elements.
     * This is equivalent to using the <code>compiler.namespaces.namespace</code> option of the mxmlc or compc compilers.
     * 
     * @param namespaceURI A namespace URI.
     * @param manifest A component manifest file (XML).
     */
    void setComponentManifest(String namespaceURI, File manifest);

    /**
     * Enables post-link optimization. This is equivalent to using the <code>compiler.optimize</code> option of the
     * mxmlc or compc compilers. Application sizes are usually smaller with this option enabled.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void optimize(boolean b);
    
    /**
     * Enables ZLIB compression on SWF file. This is equivalent to using the <code>compiler.compress</code> option of the
     * mxmlc or compc compilers. Application sizes are usually smaller with this option enabled.
     * 
     * @param b Boolean value.
     */    
    void compress(boolean b);

    /**
     * Sets the location of the Flex Data Services service configuration file.
     * This is equivalent to using the <code>compiler.services</code> option of the mxmlc and compc compilers.
     * 
     * @param file Instance of the <code>File</code> class.
     */
    void setServiceConfiguration(File file);
    
    /**
     * Runs the ActionScript compiler in a mode that detects legal but potentially incorrect code.
     * This is equivalent to using the <code>compiler.show-actionscript-warnings</code> option of the 
     * mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @see #checkActionScriptWarning(int, boolean)
     * 
     * @param b Boolean value.
     */
    void showActionScriptWarnings(boolean b);
    
    /**
     * Toggles whether warnings generated from data binding code are displayed.
     * This is equivalent to using the <code>compiler.show-binding-warnings</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void showBindingWarnings(boolean b);

    /**
     * Toggles whether the use of deprecated APIs generates a warning.
     * This is equivalent to using the <code>compiler.show-deprecation-warnings</code> option of the mxmlc or compc compilers.
     * 
     * <p>   
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void showDeprecationWarnings(boolean b);
    
    /**
     * Toggles whether warnings are displayed when an embedded font name shadows
     * a device font name.
     * This is equivalent to using the <code>compiler.show-shadowed-device-font-warnings</code> option of the mxmlc or compc compilers.
     * 
     * <p>   
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void showShadowedDeviceFontWarnings(boolean b);

    /**
     * Toggles whether warnings generated from unused type selectors are displayed.
     * This is equivalent to using the <code>compiler.show-unused-type-selector-warnings</code> option of the mxmlc or compc
     * compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void showUnusedTypeSelectorWarnings(boolean b);
    
    /**
     * Sets a list of path elements that form the roots of ActionScript class hierarchies.
     * This is equivalent to using the <code>compiler.source-path</code> option of the mxmlc or compc compilers.
     * 
     * @param paths An array of <code>java.io.File</code> objects. The <code>File.isDirectory()</code> method 
     * must return <code>true</code>.
     */
    void setSourcePath(File[] paths);

    /**
     * Adds a list of path elements to the existing source path list.
     * 
     * @param paths An array of <code>java.io.File</code> objects. The <code>File.isDirectory()</code> method must return <code>true</code>.
     * @see #setSourcePath(File[])
     */
    void addSourcePath(File[] paths);
    
    /**
     * Runs the ActionScript compiler in strict error checking mode.
     * This is equivalent to using the <code>compiler.strict</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void enableStrictChecking(boolean b);
    
    /**
     * Sets a list of CSS or SWC files to apply as a theme.
     * This is equivalent to using the <code>compiler.theme</code> option of the mxmlc or compc compilers.
     * 
     * @param files An array of <code>java.io.File</code> objects.
     */
    void setTheme(File[] files);

    /**
     * Adds a list of CSS or SWC files to the existing list of theme files.
     * 
     * @param files An array of <code>java.io.File</code> objects.
     * @see #setTheme(File[])
     */
    void addTheme(File[] files);

    /**
     * Determines whether resources bundles are included in the application.
     * This is equivalent to using the <code>compiler.use-resource-bundle-metadata</code> option of the mxmlc or compc compilers.
     *
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void useResourceBundleMetaData(boolean b);
    
    /**
     * Generates bytecodes that include line numbers. When a run-time error occurs,
     * the stacktrace shows these line numbers. Enabling this option generates larger SWF files.
     * This is equivalent to using the <code>compiler.verbose-stacktraces</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value.
     */
    void enableVerboseStacktraces(boolean b);

    /**
     * Enables FlashType for embedded fonts, which provides greater clarity for small fonts.
     * This is equilvalent to using the <code>compiler.fonts.flash-type</code> option for the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     * @deprecated
     */
    void enableFlashType(boolean b);

    /**
     * Enables advanced anti-aliasing for embedded fonts, which provides greater clarity for small fonts.
     * This is equilvalent to using the <code>compiler.fonts.advanced-anti-aliasing</code> option for the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     * @since 3.0
     */
    void enableAdvancedAntiAliasing(boolean b);

    /**
     * <code>Array.toString()</code> format has changed.
     */
    int WARN_ARRAY_TOSTRING_CHANGES = WarningConstants.kWarning_ArrayToStringChanges;

    /**
     * Assignment within conditional.
     */
    int WARN_ASSIGNMENT_WITHIN_CONDITIONAL = WarningConstants.kWarning_AssignmentWithinConditional;

    /**
     * Possibly invalid Array cast operation.
     */
    int WARN_BAD_ARRAY_CAST = WarningConstants.kWarning_BadArrayCast;

    /**
     * Non-Boolean value used where a <code>Boolean</code> value was expected.
     */
    int WARN_BAD_BOOLEAN_ASSIGNMENT = WarningConstants.kWarning_BadBoolAssignment;

    /**
     * Invalid <code>Date</code> cast operation.
     */
    int WARN_BAD_DATE_CAST = WarningConstants.kWarning_BadDateCast;

    /**
     * Unknown method.
     */
    int WARN_BAD_ES3_TYPE_METHOD = WarningConstants.kWarning_BadES3TypeMethod;

    /**
     * Unknown property.
     */
    int WARN_BAD_ES3_TYPE_PROP = WarningConstants.kWarning_BadES3TypeProp;

    /**
     * Illogical comparison with <code>NaN</code>. Any comparison operation involving <code>NaN</code> will evaluate to <code>false</code> because <code>NaN != NaN</code>.
     */
    int WARN_BAD_NAN_COMPARISON = WarningConstants.kWarning_BadNaNComparision;

    /**
     * Impossible assignment to <code>null</code>.
     */
    int WARN_BAD_NULL_ASSIGNMENT = WarningConstants.kWarning_BadNullAssignment;

    /**
     * Illogical comparison with <code>null</code>.
     */
    int WARN_BAD_NULL_COMPARISON = WarningConstants.kWarning_BadNullComparision;

    /**
     * Illogical comparison with <code>undefined</code>.  Only untyped variables (or variables of type <code>*</code>) can be <code>undefined</code>.
     */
    int WARN_BAD_UNDEFINED_COMPARISON = WarningConstants.kWarning_BadUndefinedComparision;

    /**
     * <code>Boolean()</code> with no arguments returns <code>false</code> in ActionScript 3.0.
     * <code>Boolean()</code> returned <code>undefined</code> in ActionScript 2.0.
     */
    int WARN_BOOLEAN_CONSTRUCTOR_WITH_NO_ARGS = WarningConstants.kWarning_BooleanConstructorWithNoArgs;

    /**
     * <code>__resolve</code> is deprecated.
     */
    int WARN_CHANGES_IN_RESOLVE = WarningConstants.kWarning_ChangesInResolve;

    /**
     * <code>Class</code> is sealed. It cannot have members added to it dynamically.
     */
    int WARN_CLASS_IS_SEALED = WarningConstants.kWarning_ClassIsSealed;

    /**
     * Constant not initialized.
     */
    int WARN_CONST_NOT_INITIALIZED = WarningConstants.kWarning_ConstNotInitialized;

    /**
     * Function used in new expression returns a value.  Result will be what the function returns, rather than a new instance of that function.
     */
    int WARN_CONSTRUCTOR_RETURNS_VALUE = WarningConstants.kWarning_ConstructorReturnsValue;

    /**
     * EventHandler was not added as a listener.
     */
    int WARN_DEPRECATED_EVENT_HANDLER_ERROR = WarningConstants.kWarning_DepricatedEventHandlerError;

    /**
     * Unsupported ActionScript 2.0 function.
     */
    int WARN_DEPRECATED_FUNCTION_ERROR = WarningConstants.kWarning_DepricatedFunctionError;

    /**
     * Unsupported ActionScript 2.0 property.
     */
    int WARN_DEPRECATED_PROPERTY_ERROR = WarningConstants.kWarning_DepricatedPropertyError;

    /**
     * More than one argument by the same name.
     */
    int WARN_DUPLICATE_ARGUMENT_NAMES = WarningConstants.kWarning_DuplicateArgumentNames;

    /**
     * Duplicate variable definition
     */
    int WARN_DUPLICATE_VARIABLE_DEF = WarningConstants.kWarning_DuplicateVariableDef;

    /**
     * ActionScript 3.0 iterates over an object's properties within a "<code>for x in target</code>" statement in random order.
     */
    int WARN_FOR_VAR_IN_CHANGES = WarningConstants.kWarning_ForVarInChanges;

    /**
     * Importing a package by the same name as the current class will hide that class identifier in this scope.
     */
    int WARN_IMPORT_HIDES_CLASS = WarningConstants.kWarning_ImportHidesClass;

    /**
     * Use of the <code>instanceof</code> operator.
     */
    int WARN_INSTANCEOF_CHANGES = WarningConstants.kWarning_InstanceOfChanges;

    /**
     * Internal error in compiler.
     */
    int WARN_INTERNAL_ERROR = WarningConstants.kWarning_InternalError;

    /**
     * <code>_level</code> is no longer supported. For more information, see the <code>flash.display</code> package.
     */
    int WARN_LEVEL_NOT_SUPPORTED = WarningConstants.kWarning_LevelNotSupported;

    /**
     * Missing namespace declaration (e.g. variable is not defined to be <code>public</code>, <code>private</code>, etc.).
     */
    int WARN_MISSING_NAMESPACE_DECL = WarningConstants.kWarning_MissingNamespaceDecl;

    /**
     * Negative value will become a large positive value when assigned to a <code>uint</code> data type.
     */
    int WARN_NEGATIVE_UINT_LITERAL = WarningConstants.kWarning_NegativeUintLiteral;

    /**
     * Missing constructor.
     */
    int WARN_NO_CONSTRUCTOR = WarningConstants.kWarning_NoConstructor;

    /**
     * The <code>super()</code> statement was not called within the constructor.
     */
    int WARN_NO_EXPLICIT_SUPER_CALL_IN_CONSTRUCTOR = WarningConstants.kWarning_NoExplicitSuperCallInConstructor;

    /**
     * Missing type declaration.
     */
    int WARN_NO_TYPE_DECL = WarningConstants.kWarning_NoTypeDecl;

    /**
     * In ActionScript 3.0, white space is ignored and <code>''</code> returns <code>0</code>.
     * <code>Number()</code> returns <code>NaN</code> in ActionScript 2.0 when the parameter is <code>''</code> or contains white space.
     */
    int WARN_NUMBER_FROM_STRING_CHANGES = WarningConstants.kWarning_NumberFromStringChanges;

    /**
     * Change in scoping for the <code>this</code> keyword.
     * Class methods extracted from an instance of a class will always resolve <code>this</code> back to that instance.
     * In ActionScript 2.0, <code>this</code> is looked up dynamically based on where the method is invoked from.
     */
    int WARN_SCOPING_CHANGE_IN_THIS = WarningConstants.kWarning_ScopingChangeInThis;

    /**
     * Inefficient use of <code>+=</code> on a <code>TextField</code>.
     */
    int WARN_SLOW_TEXTFIELD_ADDITION = WarningConstants.kWarning_SlowTextFieldAddition;

    /**
     * Possible missing parentheses.
     */
    int WARN_UNLIKELY_FUNCTION_VALUE = WarningConstants.kWarning_UnlikelyFunctionValue;

    /**
     * Possible usage of the ActionScript 2.0 <code>XML</code> class.
     */
    int WARN_XML_CLASS_HAS_CHANGED = WarningConstants.kWarning_XML_ClassHasChanged;
     
    /**
     * Enables checking of the following ActionScript warnings:
     * 
     * <pre>
     * --compiler.warn-array-tostring-changes
     * --compiler.warn-assignment-within-conditional
     * --compiler.warn-bad-array-cast
     * --compiler.warn-bad-bool-assignment
     * --compiler.warn-bad-date-cast
     * --compiler.warn-bad-es3-type-method
     * --compiler.warn-bad-es3-type-prop
     * --compiler.warn-bad-nan-comparison
     * --compiler.warn-bad-null-assignment
     * --compiler.warn-bad-null-comparison
     * --compiler.warn-bad-undefined-comparison
     * --compiler.warn-boolean-constructor-with-no-args
     * --compiler.warn-changes-in-resolve
     * --compiler.warn-class-is-sealed
     * --compiler.warn-const-not-initialized
     * --compiler.warn-constructor-returns-value
     * --compiler.warn-deprecated-event-handler-error
     * --compiler.warn-deprecated-function-error
     * --compiler.warn-deprecated-property-error
     * --compiler.warn-duplicate-argument-names
     * --compiler.warn-duplicate-variable-def
     * --compiler.warn-for-var-in-changes
     * --compiler.warn-import-hides-class
     * --compiler.warn-instance-of-changes
     * --compiler.warn-internal-error
     * --compiler.warn-level-not-supported
     * --compiler.warn-missing-namespace-decl
     * --compiler.warn-negative-uint-literal
     * --compiler.warn-no-constructor
     * --compiler.warn-no-explicit-super-call-in-constructor
     * --compiler.warn-no-type-decl
     * --compiler.warn-number-from-string-changes
     * --compiler.warn-scoping-change-in-this
     * --compiler.warn-slow-text-field-addition
     * --compiler.warn-unlikely-function-value
     * --compiler.warn-xml-class-has-changed
     * </pre>
     * 
     * @param warningCode Warning code.
     * @param b Boolean value.
     * 
     * @see #WARN_ARRAY_TOSTRING_CHANGES
     * @see #WARN_ASSIGNMENT_WITHIN_CONDITIONAL
     * @see #WARN_BAD_ARRAY_CAST
     * @see #WARN_BAD_BOOLEAN_ASSIGNMENT
     * @see #WARN_BAD_DATE_CAST
     * @see #WARN_BAD_ES3_TYPE_METHOD
     * @see #WARN_BAD_ES3_TYPE_PROP
     * @see #WARN_BAD_NAN_COMPARISON
     * @see #WARN_BAD_NULL_ASSIGNMENT
     * @see #WARN_BAD_NULL_COMPARISON
     * @see #WARN_BAD_UNDEFINED_COMPARISON
     * @see #WARN_BOOLEAN_CONSTRUCTOR_WITH_NO_ARGS
     * @see #WARN_CHANGES_IN_RESOLVE
     * @see #WARN_CLASS_IS_SEALED
     * @see #WARN_CONST_NOT_INITIALIZED
     * @see #WARN_CONSTRUCTOR_RETURNS_VALUE
     * @see #WARN_DEPRECATED_EVENT_HANDLER_ERROR
     * @see #WARN_DEPRECATED_FUNCTION_ERROR
     * @see #WARN_DEPRECATED_PROPERTY_ERROR
     * @see #WARN_DUPLICATE_ARGUMENT_NAMES
     * @see #WARN_DUPLICATE_VARIABLE_DEF
     * @see #WARN_FOR_VAR_IN_CHANGES
     * @see #WARN_IMPORT_HIDES_CLASS
     * @see #WARN_INSTANCEOF_CHANGES
     * @see #WARN_INTERNAL_ERROR
     * @see #WARN_LEVEL_NOT_SUPPORTED
     * @see #WARN_MISSING_NAMESPACE_DECL
     * @see #WARN_NEGATIVE_UINT_LITERAL
     * @see #WARN_NO_CONSTRUCTOR
     * @see #WARN_NO_EXPLICIT_SUPER_CALL_IN_CONSTRUCTOR
     * @see #WARN_NO_TYPE_DECL
     * @see #WARN_NUMBER_FROM_STRING_CHANGES
     * @see #WARN_SCOPING_CHANGE_IN_THIS
     * @see #WARN_SLOW_TEXTFIELD_ADDITION
     * @see #WARN_UNLIKELY_FUNCTION_VALUE
     * @see #WARN_XML_CLASS_HAS_CHANGED
     */
    void checkActionScriptWarning(int warningCode, boolean b);
    
    /**
     * Sets the default background color. You can override this by using the application code.
     * This is the equivalent of the <code>default-background-color</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>0x869CA7</code>.
     * 
     * @param color An RGB value.
     */
    void setDefaultBackgroundColor(int color);
    
    /**
     * Sets the default frame rate to be used in the application.
     * This is the equivalent of the <code>default-frame-rate</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>24</code>.
     * 
     * @param rate Number of frames per second.
     */
    void setDefaultFrameRate(int rate);
    
    /**
     * Sets the default script execution limits (which can be overridden by root attributes).
     * This is equivalent to using the <code>default-script-limits</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default maximum recursion depth is <code>1000</code>.
     * The default maximum execution time is <code>60</code>.
     * 
     * @param maxRecursionDepth Recursion depth.
     * @param maxExecutionTime Execution time, in seconds. 
     */
    void setDefaultScriptLimits(int maxRecursionDepth, int maxExecutionTime);
    
    /**
     * Sets the default application size.
     * This is equivalent to using the <code>default-size</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default width is <code>500</code>.
     * The default height is <code>375</code>.
     * 
     * @param width The width of the application, in pixels.
     * @param height The height of the application, in pixels.
     */
    void setDefaultSize(int width, int height);
    
    /**
     * Sets a list of definitions to omit from linking when building an application.
     * This is equivalent to using the <code>externs</code> option of the mxmlc and compc compilers.
     * 
     * @param definitions An array of definitions (for example, classes, functions, variables, or namespaces).
     */
    void setExterns(String[] definitions);
    
    /**
     * Adds a list of definitions to the existing list of definitions.
     *
     * @see #setExterns(File[])
     * @see #setExterns(String[])
     * @param definitions An array of definitions (for example, classes, functions, variables, namespaces).
     */
    void addExterns(String[] definitions);

    /**
     * Loads a file containing configuration options. The file format follows the format of the <code>flex-config.xml</code> file.
     * This is equivalent to using the <code>load-config</code> option of the mxmlc or compc compilers.
     * 
     * @param file An instance of the <code>java.io.File</code> class.
     */
    void setConfiguration(File file);

    /**
     * Adds a file to the existing list of configuration files.
     * 
     * @see #setConfiguration(File)
     * @param file An instance of the <code>java.io.File</code> class.
     */
    void addConfiguration(File file);
    
	/**
	 * Sets the configuration parameters. The input should be valid <code>mxmlc/compc</code> command-line arguments.<p>
	 * 
	 * @param args <code>mxmlc/compc</code> command-line arguments
	 */
	void setConfiguration(String[] args);

    /**
     * Sets a list of definitions to omit from linking when building an application.
     * This is equivalent to using the <code>load-externs</code> option of the mxmlc or compc compilers.
     * This option is similar to the <code>setExterns(String[])</code> method. The following is an example of
     * the file format:
     * 
     * <pre>
     * &lt;script>
     *     &lt;!-- use 'dep', 'pre' or 'dep' to specify a definition to be omitted from linking. -->
     *     &lt;def id="mx.skins:ProgrammaticSkin"/>
     *     &lt;pre id="mx.core:IFlexDisplayObject"/>
     *     &lt;dep id="String"/>
     * &lt;/script>
     * </pre>
     * 
     * @see #setExterns(String[])
     * @param files An array of <code>java.io.File</code> objects.
     */
    void setExterns(File[] files);
    
    /**
     * Adds a list of files to the existing list of definitions to be omitted from linking.
     * 
     * @see #setExterns(File[])
     * @see #setExterns(String[])
     * @param files An array of <code>java.io.File</code> objects.
     */
    void addExterns(File[] files);

    /**
     * Sets a SWF frame label with a sequence of class names that are linked onto the frame.
     * This is equivalent to using the <code>frames.frame</code> option of the mxmlc or compc compilers.
     * 
     * @param label A string.
     * @param classNames An array of class names.
     */
    void setFrameLabel(String label, String[] classNames);
    
    /**
     * Sets a list of definitions to always link in when building an application.
     * This is equivalent to using the <code>includes</code> option of the mxmlc or compc compilers.
     * 
     * @param definitions An array of definitions (for example, classes, functions, variables, or namespaces).
     */
    void setIncludes(String[] definitions);
    
    /**
     * Adds a list of definitions to the existing list of definitions.
     *
     * @see #setIncludes(String[])
     * @param definitions An array of definitions (for example, classes, functions, variables, or namespaces).
     */
    void addIncludes(String[] definitions);

    /**
     * Specifies the licenses that the compiler validates before compiling.
     * This is equivalent to using the <code>licenses.license</code> option of the mxmlc or compc compilers.
     * 
     * @param productName A string representing the product name; for example "flexbuilder3".
     * @param serialNumber A serial number.
     */
    void setLicense(String productName, String serialNumber);

    /**
     * A contributor's name to store in the SWF metadata.
     */
    int CONTRIBUTOR = 1;

    /**
     * A creator's name to store in the SWF metadata.
     */
    int CREATOR     = 2;

    /**
     * The creation date to store in the SWF metadata.
     */
    int DATE        = 4;

    /**
     * The default and localized RDF/XMP description to store in the SWF metadata.
     */
    int DESCRIPTION = 8;

    /**
     * The default and localized RDF/XMP title to store in the SWF metadata.
     */
    int TITLE       = 16;

    /**
     * The language to store in the SWF metadata (i.e. EN, FR).
     */
    int LANGUAGE    = 32;

    /**
     * A publisher's name to store in the SWF metadata.
     */
    int PUBLISHER   = 64;
    
    /**
     * Sets the metadata section of the application SWF. This option is equivalent to using the following options of
     * the mxmlc and compc compilers:
     * 
     * <pre>
     * metadata.contributor
     * metadata.creator
     * metadata.date
     * metadata.description
     * metadata.language
     * metadata.localized-description
     * metadata.localized-title
     * metadata.publisher
     * metadata.title
     * </pre>
     * 
     * <p>
     * The valid fields and types of value are specified below:
     * 
     * <pre>
     * CONTRIBUTOR      java.lang.String
     * CREATOR          java.lang.String
     * DATE             java.util.Date
     * DESCRIPTION      java.util.Map<String, String>
     * TITLE            java.util.Map<String, String>
     * LANGUAGE         java.lang.String
     * PUBLISHER        java.lang.String
     * </pre>
     * 
     * For example:
     * 
     * <pre>
     * Map titles = new HashMap();
     * titles.put("EN", "Adobe Flex 2 Application");
     * 
     * Map descriptions = new HashMap();
     * descriptions.put("EN", "http://www.adobe.com/products/flex");
     * 
     * setSWFMetaData(Configuration.LANGUAGE, "EN");
     * setSWFMetaData(Configuration.TITLE, titles);
     * setSWFMetaData(Configuration.DESCRIPTION, descriptions);
     * </pre>
     * 
     * @param field One of: <code>CONTRIBUTOR</code>, <code>CREATOR</code>, 
     * <code>DATE</code>, <code>DESCRIPTION</code>, <code>TITLE</code>, 
     * <code>LANGUAGE</code>, or <code>PUBLISHER</code>.
     * @param value A <code>String</code>, <code>Date</code>, or 
     * <code>Map</code> object.
     * 
     * @see #CONTRIBUTOR
     * @see #CREATOR
     * @see #DATE
     * @see #DESCRIPTION
     * @see #TITLE
     * @see #LANGUAGE
     * @see #PUBLISHER
     */
    void setSWFMetaData(int field, Object value);

    /**
     * Sets the path to the Flash Player executable when building a projector; for example:
     * 
     * <pre>
     * setProjector(new File("C:/.../SAFlashPlayer.exe"));
     * </pre>
     * 
     * This is equivalent to the <code>projector</code> option of the mxlmc or compc compilers.
     * 
     * @param file The Flash Player executable.
     */
    // void setProjector(File file);
    
    /**
     * Sets the metadata section of the application SWF.
     * This is equivalent to the <code>raw-metadata</code> option of the mxmlc or compc compilers.
     * This option overrides anything set by the <code>setSWFMetaData()</code> method.
     * 
     * @see #setSWFMetaData(int, Object)
     * @param xml A well-formed XML fragment.
     */
    void setSWFMetaData(String xml);
    
    /**
     * Sets a list of run-time shared library URLs to be loaded before the application starts.
     * This is equivalent to the <code>runtime-shared-libraries</code> option of the mxmlc or compc compilers.
     * 
     * @param libraries An array of <code>java.lang.String</code> objects.
     */
    void setRuntimeSharedLibraries(String[] libraries);

    /**
     * Adds a list of run-time shared library URLs to the existing list.
     * 
     * @see #setRuntimeSharedLibraries(String[])
     * @param libraries An array of <code>java.lang.String</code> objects.
     */
    void addRuntimeSharedLibraries(String[] libraries);

    /**
     * Toggles whether the application SWF is flagged for access to network resources.
     * This is equivalent to the <code>use-network</code> option of the mxmlc or compc compilers.
     * 
     * <p>
     * The default value is <code>true</code>.
     * 
     * @param b Boolean value.
     */
    void useNetwork(boolean b);
    
    /**
     * Set the default output directory for configuration settings.
     * 
     */
    String DEFAULT_OUTPUT_DIRECTORY_TOKEN = "com.adobe.flex.default.output.directory";
    
    /**
     * Defines a token that can be used for token substitutions. On the command line, you use token substitution in 
     * the following way:
     * 
     * <pre>
     * mxmlc +flexlib=path1 +foo=bar -var=${foo}
     * </pre>
     * 
     * Where <code>var=bar</code> occurs after the substitution of <code>${foo}</code>.
     * 
     * @param name The name of the token.
     * @param value The value of the token.
     */
    void setToken(String name, String value);

    
    /**
     * Sets the version of the Flash Player that is being targeted by the application.  
     * Features requiring a later version of the Player will not be compiled into the application.
     *
     * The default Player targeted is 9.0.0.
     * 
     * @param major The major version. Must be greater than or equal to nine.
     * @param minor The minor version. Must be greater than or equal to zero.
     * @param revision The revsion must be greater than or equal to zero.
     * 
     * @since 3.0
     */
    void setTargetPlayer(int major, int minor, int revision);

    /**
     * Sets the SDK compatibility version. For this release, the only valid value is 2.0.1.
     * 
     * @param major The major version. For this release, this value must be 2.
     * @param minor The minor version. For this release, this value must be 0.
     * @param revision For this release, this value must be 1.
     * 
     * @since 3.0
     */
    void setCompatibilityVersion(int major, int minor, int revision);
 
    /**
     * Set the arguments required to use an RSL with optional failover RSLs.
     * The arguments specify a SWC library and a set of RSL URLs and 
     * Policy File URLs.
     * 
     * This method sets RSL information and removes any other RSL
     * that may be set. To set additional RSLs see the 
     * <code>addRuntimeSharedLibraryPath</code> method.
     * 
     * This is equivalent to the <code>-runtime-shared-library-path</code> 
     * option of the mxmlc compiler.
     * 
     * @param swc path to the swc. The classes in the swc will be excluded from 
     * 			  the compiled application.
     * @param rslUrls array of URLs. The first RSL URL in the list is the primary RSL. The
     * 			   remaining RSL URLs will only be loaded if the primary RSL fails to load.
     * @param policyFileUrls array of policy file URLs. Each entry in the rslUrls array must
     * 				   have a corresponding entry in this array. A policy file may be needed in
     * 				   order to allow the player to read an RSL from another domain. If
     * 				   a policy file is not required, then set it to an empty string.
     * @since 3.0
     * @see #addRuntimeSharedLibraryPath(String, String[], String[])
     * @throws IllegalArgumentException if the length of the rslUrls array is not equal to
     * 								    the length of the policyFileUrls array.
     * @throws NullPointerException if any of the arguments are null.
     */
	public void setRuntimeSharedLibraryPath(String swc, String[] rslUrls, String[] policyFileUrls);
	
	/**
	 * This is equivalent to using more than one <code>runtime-shared-library-path</code>
	 * option when using the mxmlc compiler.
	 * 
     * @param swc path to the swc. The classes in the swc will be excluded from 
     * 			  the compiled application.
     * @param rslUrls array of URLs. The first RSL URL in the list is the primary RSL. The
     * 			   remaining RSL URLs will only be loaded if the primary RSL fails to load.
     * @param policyFileUrls array of policy file URLs. Each entry in the rslUrls array must
     * 				   have a corresponding entry in this array. A policy file may be needed in
     * 				   order to allow the player to read an RSL from another domain. If
     * 				   a policy file is not required, then set it to an empty string.
	 * @since 3.0
	 * @see #setRuntimeSharedLibraryPath(String, String[], String[])
     * @throws IllegalArgumentException if the length of the rslUrls array is not equal to
     * 								    the length of the policyFileUrls array.
     * @throws NullPointerException if any of the arguments is null.
	 */
	public void addRuntimeSharedLibraryPath(String swc, String[] rslUrls, String[] policyFileUrls);
	
    /**
     * Verifies the RSL loaded 
     * has the same digest as the RSL specified when the application was compiled.
     * This is equivalent to using the <code>verify-digests</code>
     * option in the mxmlc compiler.
     * 
     *  The default value is <code>true</code>
     * 
     * @param verify set to true to verify
     * 				 the digest of the loaded RSL matches the digest of the
     * 				 expected RSL. Set to false to disable the checks during
     * 				 the development process but it is highly recommend that 
     * 				 production applications be compiled with <code>verify</code>
     * 				 set to true.  
     * 
     * @since 3.0
     */
    void enableDigestVerification(boolean verify);

    /**
     * Enable or disable the computation of a digest for the created swf library.
     * This is equivalent to using the <code>compiler.computDigest</code> in the compc
     * compiler.
     * 
     * The default value is <code>true</code>
     * 
     * @param compute set to <code>true</code> to create a digest for the compiled library.
     * 
     * @since 3.0
     */
    void enableDigestComputation(boolean compute);
    
    /**
     * Add a global AS3 compiler configuration value and preserve existing definitions.
     * 
     * This is equivalent to a single <code>-define</code> option.
     * 
     * @param name The qualified name of the configuration constant, e.g. "CONFIG::debugging" or "APP::version"
     * @param value The value of the constant, e.g. "true" or "!CONFIG::release" or "3.0"
     * 
     * @since 3.0
     * 
     * @see #setDefineDirective(String[], String[])
     */
    public void addDefineDirective(String name, String value);
    
    /**
     * Set global AS3 compiler configuration values and clear existing definitions.
     * 
     * If either parameter is null, <u>or</u> the arrays of different lengths, this will <i>only</i>
     * clear existing definitions.
     * 
     * @param names A list of qualified names/configuration constants, e.g. "CONFIG::debugging" or "APP::version"
     * @param values A list of values of the constants, e.g. "true" or "!CONFIG::release" or "3.0"
     * 
     * @since 3.0
     * 
     * @see #addDefineDirective(String, String)
     */
    public void setDefineDirective(String[] names, String[] values);
    
    
    /**
     * @param libraries
     */
    public void setExtensionLibraries(Map<File, List<String>> extensions);
    
    public void addExtensionLibraries(File extension, List<String> parameters);
    
    
    /**
     * Enables the removal of RSLs associated with libraries
     * that are not used by an application.
     * This is equivalent to using the
     * <code>remove-unused-rsls</code> option of the mxmlc compiler.
     * 
     * <p>
     * The default value is <code>false</code>.
     * 
     * @param b Boolean value that enables or disables the removal.
     *    
     * @since 4.5
     */
    void removeUnusedRuntimeSharedLibraryPaths(boolean b);

    /**
     * Sets the SWCs that will have their associated RSLs loaded at runtime.
     * The RSLs will be loaded whether they are used in the application or not.
     * This option can be used to override decisions made by the compiler when 
     * using the <code>removed-used-rsls</code> option.
     * 
     * This is equivalent to using the
     * <code>runtime-shared-library-settings.force-rsls</code> option of the 
     * mxmlc compiler.
     * 
     * @param paths An array of <code>File</code> objects. Each <code>File</code> 
     * instance should represent a SWC file. May not be null.
     *    
     * @since 4.5
     * @throws NullPointerException if path is null.
     */
    void setForceRuntimeSharedLibraryPaths(File[] paths);

    /**
     * Adds SWCs to the existing set of SWCs whose RSLs will be loaded at runtime. 
     *  
     * This is equivalent to using the
     * <code>runtime-shared-library-settings.force-rsls</code> option of the 
     * mxmlc compiler.
     *
     * @param paths An array of <code>File</code> objects. Each <code>File</code> 
     * instance should represent a SWC file. May not be null.
     *    
     * @since 4.5
     * @see #setForcedRuntimeSharedLibraryPaths(File[])
     * @throws NullPointerException if path is null.
     */
    void addForceRuntimeSharedLibraryPaths(File[] paths);

    /**
     * Set the application domain of a configured RSL to override the default
     * settings. The default value is 'default'. Other valid values are
     * "current", "parent", or "top-level". The actual application domain is
     * resolved at runtime by the Flex Framework. The default behavior is to
     * load an RSL into the topmost module factory's application domain that has
     * a placeholder RSL. If no placeholder is found the RSL is loaded into the
     * application domain of the loading module factory. The "current",
     * "parent", and "top-level" applications are resolved relative to the
     * module factory loading the RSL.
     * 
     * This is equivalent to using the
     * <code>runtime-shared-library-settings.application-domain</code> option of
     * the mxmlc compiler.
     * 
     * @param path The <code>File</code> instance represents a SWC file with RSL
     *            linkage. The RSL associated with the SWC will have its
     *            application domain modified as specified in the
     *            <code>applicationDomainTarget</code> parameter. Passing null
     *            resets the application domain settings.
     * @param applicationDomainTarget The application domain an RSL will be loaded
     *  into. May only be null when the <code>path</code> parameter is null.
     * 
     * @since 4.5
     * @throws NullPointerException if applicationDomain is null and path is 
     * not null.
     */
    void setApplicationDomainForRuntimeSharedLibraryPath(File path, String applicationDomainTarget);

    /**
     * Add application domain setting to the existing list of application domain
     * settings.
     * 
     * This is equivalent to using the
     * <code>runtime-shared-library-settings.application-domain</code> option of
     * the mxmlc compiler.
     * 
     * @param path The <code>File</code> instance represents a SWC file with RSL
     *            linkage. The RSL associated with the SWC will have its
     *            application domain modified as specified in the
     *            <code>applicationDomainTarget</code> parameter. May not be
     *            null.
     * @param applicationDomainTarget The application domain an RSL will be 
     * loaded into. May not be null.
     * 
     * @since 4.5
     * @see #setApplicationDomainForRuntimeSharedLibraryPath(File, String)
     * @throws NullPointerException if any of the arguments are null.
     */
    void addApplicationDomainForRuntimeSharedLibraryPath(File path, String applicationDomainTarget);
    
}
