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

package flex2.tools.flexbuilder;

import java.io.File;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import flex2.tools.oem.Configuration;
import flex2.tools.oem.internal.OEMConfiguration;

/**
 * This class represents a flex2.tools.oem.Configuration wrapper, so
 * the code in BuilderConfiguration basically delegates calls to the
 * underlying Configuration object.  There is one new method,
 * setConfiguration(String[] args).  It takes an array of mxmlc/compc
 * command-line arguments.  The processing of the arguments is not in
 * BuilderConfiguration.  It's in BuilderApplication.compile() and
 * BuilderLibrary.compile().
 */
public class BuilderConfiguration implements Configuration
{
	BuilderConfiguration(Configuration c)
	{
		configuration = c;
	}
	
	final Configuration configuration;
	String[] extra;

	public void addActionScriptMetadata(String[] md)
	{
		configuration.addActionScriptMetadata(md);
	}

	public void addConfiguration(File file)
	{
		configuration.addConfiguration(file);
	}

	public void addExternalLibraryPath(File[] paths)
	{
		configuration.addExternalLibraryPath(paths);
	}

	public void addExterns(String[] definitions)
	{
		configuration.addExterns(definitions);
	}

	public void addExterns(File[] files)
	{
		configuration.addExterns(files);
	}

	public void addFontManagers(String[] classNames)
	{
		configuration.addFontManagers(classNames);
	}

	public void addIncludes(String[] definitions)
	{
		configuration.addIncludes(definitions);
	}

	public void addLibraryPath(File[] paths)
	{
		configuration.addLibraryPath(paths);
	}

	public void addLocalFontPaths(String[] paths)
	{
	    configuration.addLocalFontPaths(paths);
	}

	public void addRuntimeSharedLibraries(String[] libraries)
	{
		configuration.addRuntimeSharedLibraries(libraries);
	}

	public void addSourcePath(File[] paths)
	{
		configuration.addSourcePath(paths);
	}

	public void addTheme(File[] files)
	{
		configuration.addTheme(files);
	}

	public void allowSourcePathOverlap(boolean b)
	{
		configuration.allowSourcePathOverlap(b);
	}

	public void checkActionScriptWarning(int warningCode, boolean b)
	{
		configuration.checkActionScriptWarning(warningCode, b);
	}

	public void enableAccessibility(boolean b)
	{
		configuration.enableAccessibility(b);
	}

	public void enableDebugging(boolean b, String debugPassword)
	{
		configuration.enableDebugging(b, debugPassword);
	}

	public void enableStrictChecking(boolean b)
	{
		configuration.enableStrictChecking(b);
	}

	public void enableVerboseStacktraces(boolean b)
	{
		configuration.enableVerboseStacktraces(b);
	}
	
	public void enableFlashType(boolean b)
	{
		configuration.enableAdvancedAntiAliasing(b);
	}

	public void enableAdvancedAntiAliasing(boolean b)
	{
		configuration.enableAdvancedAntiAliasing(b);
	}

    public void removeUnusedRuntimeSharedLibraryPaths(boolean b)
    {
        configuration.removeUnusedRuntimeSharedLibraryPaths(b);
    }
    
	public void includeLibraries(File[] libraries)
	{
		configuration.includeLibraries(libraries);
	}

	public void keepAllTypeSelectors(boolean b)
	{
		configuration.keepAllTypeSelectors(b);
	}

	public void keepCompilerGeneratedActionScript(boolean b)
	{
		configuration.keepCompilerGeneratedActionScript(b);
	}

	public void keepLinkReport(boolean b)
	{
		configuration.keepLinkReport(b);
	}
	
	public void keepSizeReport(boolean b)
	{
		configuration.keepSizeReport(b);
	}

	public void keepConfigurationReport(boolean b)
	{
		configuration.keepConfigurationReport(b);
	}

	public void optimize(boolean b)
	{
		configuration.optimize(b);
	}
	
	public void compress(boolean b)
	{
	    configuration.compress(b);
	}

	public void setActionScriptMetadata(String[] md)
	{
		configuration.setActionScriptMetadata(md);
	}

	public void setActionScriptFileEncoding(String encoding)
	{
		configuration.setActionScriptFileEncoding(encoding);
	}

	public void setComponentManifest(String namespaceURI, File manifest)
	{
		configuration.setComponentManifest(namespaceURI, manifest);
	}

    public void setComponentManifests(String namespaceURI, List<File> manifests)
    {
        if (configuration instanceof OEMConfiguration)
            ((OEMConfiguration)configuration).setComponentManifests(namespaceURI, manifests);
    }

	public void setConfiguration(File file)
	{
		configuration.setConfiguration(file);
	}
	
	public void setConfiguration(String[] args)
	{
		extra = args;
	}

	public void setContextRoot(String path)
	{
		configuration.setContextRoot(path);
	}

	public void setDefaultBackgroundColor(int color)
	{
		configuration.setDefaultBackgroundColor(color);
	}

	public void setDefaultCSS(File url)
	{
		configuration.setDefaultCSS(url);
	}

	public void setDefaultFrameRate(int rate)
	{
		configuration.setDefaultFrameRate(rate);
	}

	public void setDefaultScriptLimits(int maxRecursionDepth, int maxExecutionTime)
	{
		configuration.setDefaultScriptLimits(maxRecursionDepth, maxExecutionTime);
	}

	public void setDefaultSize(int width, int height)
	{
		configuration.setDefaultSize(width, height);
	}

	public void setExternalLibraryPath(File[] paths)
	{
		configuration.setExternalLibraryPath(paths);
	}

	public void setExterns(String[] definitions)
	{
		configuration.setExterns(definitions);
	}

	public void setExterns(File[] files)
	{
		configuration.setExterns(files);
	}

	public void setFontLanguageRange(String language, String range)
	{
		configuration.setFontLanguageRange(language, range);
	}

	public void setFontManagers(String[] classNames)
	{
		configuration.setFontManagers(classNames);
	}

	public void setFrameLabel(String label, String[] classNames)
	{
		configuration.setFrameLabel(label, classNames);
	}

	public void setIncludes(String[] definitions)
	{
		configuration.setIncludes(definitions);
	}

	public void setLibraryPath(File[] paths)
	{
		configuration.setLibraryPath(paths);
	}

	public void setLicense(String productName, String serialNumber)
	{
		configuration.setLicense(productName, serialNumber);
	}

    public void setLocalFontPaths(String[] paths)
    {
        configuration.setLocalFontPaths(paths);
    }

	public void setLocalFontSnapshot(File file)
	{
		configuration.setLocalFontSnapshot(file);
	}

	public void setLocale(String[] locales)
	{
		configuration.setLocale(locales);
	}
	
	public void setLocale(Locale locale)
	{
		configuration.setLocale(new String[] { locale.toString() });
	}

	public void setMaximumCachedFonts(int size)
	{
		configuration.setMaximumCachedFonts(size);
	}

	public void setMaximumGlyphsPerFace(int size)
	{
		configuration.setMaximumGlyphsPerFace(size);
	}

	/*
	public void setProjector(File file)
	{
		configuration.setProjector(file);
	}
	*/

	public void setRuntimeSharedLibraries(String[] libraries)
	{
		configuration.setRuntimeSharedLibraries(libraries);
	}

	public void setSWFMetaData(int field, Object value)
	{
		configuration.setSWFMetaData(field, value);
	}

	public void setSWFMetaData(String xml)
	{
		configuration.setSWFMetaData(xml);
	}

	public void setServiceConfiguration(File file)
	{
		configuration.setServiceConfiguration(file);
	}

	public void setSourcePath(File[] paths)
	{
		configuration.setSourcePath(paths);
	}

	public void setTheme(File[] files)
	{
		configuration.setTheme(files);
	}

	public void setToken(String name, String value)
	{
		configuration.setToken(name, value);
	}

	public void showActionScriptWarnings(boolean b)
	{
		configuration.showActionScriptWarnings(b);
	}

	public void showBindingWarnings(boolean b)
	{
		configuration.showBindingWarnings(b);
	}

	public void showDeprecationWarnings(boolean b)
	{
		configuration.showDeprecationWarnings(b);
	}

    public void showShadowedDeviceFontWarnings(boolean b)
    {
        configuration.showShadowedDeviceFontWarnings(b);
    }

	public void showUnusedTypeSelectorWarnings(boolean b)
	{
		configuration.showUnusedTypeSelectorWarnings(b);
	}

	public void useActionScript3(boolean b)
	{
		configuration.useActionScript3(b);
	}

	public void useECMAScript(boolean b)
	{
		configuration.useECMAScript(b);
	}

	public void useHeadlessServer(boolean b)
	{
		configuration.useHeadlessServer(b);
	}

	public void useNetwork(boolean b)
	{
		configuration.useNetwork(b);
	}

	public void useResourceBundleMetaData(boolean b)
	{
		configuration.useResourceBundleMetaData(b);
	}
	
	public String toString()
	{
		return configuration.toString();
	}

	public void setTargetPlayer(int major, int minor, int revision)
	{
		configuration.setTargetPlayer(major, minor, revision);		
	}

	public void setCompatibilityVersion(int major, int minor, int revision)
	{
		configuration.setCompatibilityVersion(major, minor, revision);		
	}

	public void enableDigestComputation(boolean compute)
	{
		configuration.enableDigestComputation(compute);
	}

	public void enableDigestVerification(boolean verify)
	{
		configuration.enableDigestVerification(verify);
	}

	public void addRuntimeSharedLibraryPath(String swc, String[] rslUrls, String[] policyFileUrls)
	{
		configuration.addRuntimeSharedLibraryPath(swc, rslUrls, policyFileUrls);
	}

	public void setRuntimeSharedLibraryPath(String swc, String[] rslUrls, String[] policyFileUrls)
	{
		configuration.setRuntimeSharedLibraryPath(swc, rslUrls, policyFileUrls);
	}

    public void addDefineDirective(String name, String value)
    {
        configuration.addDefineDirective(name, value);
    }

    public void setDefineDirective(String[] names, String[] values)
    {
        configuration.setDefineDirective(names, values);
    }

    public void addExtensionLibraries( File extension, List<String> parameters )
    {
        configuration.addExtensionLibraries( extension, parameters );
    }

    public void setExtensionLibraries( Map<File, List<String>> extensions )
    {
        configuration.setExtensionLibraries( extensions );
    }

    public void addForceRuntimeSharedLibraryPaths(File[] paths)
    {
        configuration.addForceRuntimeSharedLibraryPaths(paths);
    }

    public void setForceRuntimeSharedLibraryPaths(File[] paths)
    {
        configuration.setForceRuntimeSharedLibraryPaths(paths);
    }

    public void setApplicationDomainForRuntimeSharedLibraryPath(File path, String applicationDomainTarget)
    {
        configuration.setApplicationDomainForRuntimeSharedLibraryPath(path, applicationDomainTarget);
    }
    
    public void addApplicationDomainForRuntimeSharedLibraryPath(File path, String applicationDomainTarget)
    {
        configuration.addApplicationDomainForRuntimeSharedLibraryPath(path, applicationDomainTarget);
    }
    
}
