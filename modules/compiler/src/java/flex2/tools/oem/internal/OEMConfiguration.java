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

package flex2.tools.oem.internal;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.Map.Entry;

import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.util.ObjectList;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.FontsConfiguration;
import flex2.compiler.common.FramesConfiguration;
import flex2.compiler.common.NamespacesConfiguration;
import flex2.compiler.common.RuntimeSharedLibrarySettingsConfiguration;
import flex2.compiler.common.Configuration.RslPathInfo;
import flex2.compiler.common.FramesConfiguration.FrameInfo;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;
import flex2.tools.LicensesConfiguration;
import flex2.tools.ToolsConfiguration;
import flex2.tools.oem.Configuration;

/**
 * A ToolsConfiguration wrapper, which provides strongly typed
 * configuration getters and setters, which internally storing them
 * loosely typed for later processing.  This is part of a complex
 * scheme to only expose some of the compiler's configurability while
 * supporting merging with configuration defaults.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class OEMConfiguration implements Configuration, ConfigurationConstants, Cloneable
{
	/**
	 *  Created to enable picking out cross-domain args by type.
	 */
	class RslPathList extends ArrayList<String[]>
    {
		private static final long serialVersionUID = 0L;
	}
	
    /**
     *  Ditto for conditional compilation
     */
    class CompilerDefinitionList extends ArrayList<String>
    {
        private static final long serialVersionUID = 0L;
    }
	
    /**
     *  Ditto for application-domains
     */
    class ApplicationDomainsList extends ArrayList<String[]>
    {
        private static final long serialVersionUID = 0L;
    }
    
	OEMConfiguration(ConfigurationBuffer cfgbuf, ToolsConfiguration configuration)
	{
		this.cfgbuf = cfgbuf;
		this.configuration = configuration;
		
		args = new LinkedHashMap<String, Object>();
		more = new LinkedHashMap<String, Object>();
		linker_args = new LinkedHashMap<String, Object>();
		linker_more = new LinkedHashMap<String, Object>();
		newLinkerOptionsAfterCompile = new HashSet<String>();
		
		if (configuration != null)
		{
			populateDefaults(configuration);
		}
		
		defaults = args;
		args = new LinkedHashMap<String, Object>();
		linker_args = new LinkedHashMap<String, Object>();
		newLinkerOptionsAfterCompile.clear();
		
		keepLinkReport = false;
		keepSizeReport = false;
		keepConfigurationReport = false;
		
		tokens = new TreeMap<String, String>();
	}

	public ConfigurationBuffer cfgbuf;
	public final ToolsConfiguration configuration;
	
	private Map<String, Object> args, defaults, more, linker_args, linker_more;
	private String[] extras;
	public final Set<String> newLinkerOptionsAfterCompile;
	private boolean keepLinkReport, keepSizeReport, keepConfigurationReport;
	
	private Map<String, String> tokens;

	/**
	 * 
	 * @param c
	 */
	void importDefaults(OEMConfiguration c)
	{
		args.putAll(c.defaults);
	}
	
	/**
	 * 
	 * @return
	 */
	public String[] getCompilerOptions()
	{
		return getOptions(args, more, true);
	}
	
	/**
	 * 
	 * @return
	 */
	public String[] getLinkerOptions()
	{
		return getOptions(linker_args, linker_more, false);
	}
	
	/**
	 * 
	 * @return
	 */
    
    //TEST ME
	private String[] getOptions(Map<String, Object> args, Map<String, Object> more, boolean processExtras)
	{
		ArrayList<String> buffer = new ArrayList<String>();
		
        //TODO this can be optimized to use the entrySet
		for (Iterator<String> i = tokens.keySet().iterator(); i.hasNext(); )
		{
			String key = i.next();
			String value = tokens.get(key);
			buffer.add("+" + key + "=" + value);
		}
		
		for (Iterator<String> i = args.keySet().iterator(); i.hasNext(); )
		{
			String key = (String) i.next();
			Object value = args.get(key);

			if (value instanceof Boolean)
			{
				buffer.add(key + "=" + value);
			}
			else if (value instanceof Number)
			{
				buffer.add(key);
				buffer.add(value.toString());
			}
			else if (COMPILER_CONTEXT_ROOT.equals(key) && value instanceof String)
			{				
				buffer.add(key);
				buffer.add((String)value);
			}
			else if (value instanceof String)
			{				
				if (!"".equals(value))
				{
					buffer.add(key);
					buffer.add((String)value);
				}
				else
				{
					buffer.add(key + "=");
				}
			}
			else if (value instanceof File)
			{
				String p = ((File) value).getPath();
				if (!"".equals(p))
				{
					buffer.add(key);
					buffer.add(p);
				}
				else
				{
					buffer.add(key + "=");
				}
			}
			else if (value instanceof URL)
			{
				String u = ((URL) value).toExternalForm();
				if (!"".equals(u))
				{
					buffer.add(key);
					buffer.add(u);
				}
				else
				{
					buffer.add(key + "=");
				}
			}
			else if (value instanceof java.util.Date)
			{
				buffer.add(key);
				buffer.add(value.toString());
			}
			else if (value instanceof Map)
			{
				Map m = (Map) value;
				for (Iterator j = m.keySet().iterator(); j.hasNext(); )
				{
					String k = (String) j.next();
					Object v = m.get(k);
					
					if (v instanceof String)
					{
						buffer.add(key);
						buffer.add(k);
						buffer.add((String)v);
					}
					else if (v instanceof File)
					{
						buffer.add(key);
						buffer.add(k);
						buffer.add(((File) v).getPath());
					}
					else if (v instanceof String[])
					{
						buffer.add(key);
						buffer.add(k);
						buffer.add(toCommaSeparatedString((String[]) v));
					}
					else if (v instanceof List)
					{
						buffer.add(key);
						buffer.add(k);
						Iterator it = ((List)v).iterator();
						while (it.hasNext())
						{
							Object next = it.next();
							if (next != null)
								buffer.add(next.toString());
						}
					}
					else if (v != null)
					{
						assert false;
					}
				}
			}
			else if (value instanceof int[])
			{
				int[] a = (int[]) value;
				buffer.add(key);
				buffer.add(String.valueOf(a[0]));
				buffer.add(String.valueOf(a[1]));
			}
			else if (value instanceof String[])
			{
				String[] a = merge((String[]) args.get(key), (String[]) more.get(key));
				int length = a == null ? 0 : a.length;
				if (length > 0)
				{
					buffer.add(key);
				}
				else
				{
					buffer.add(key + "=");
				}
				for (int j = 0; j < length; j++)
				{
					if (a[j] != null)
					{
						buffer.add(a[j]);
					}
				}
			}
			else if (LOAD_CONFIG.equals(key) && value instanceof File[])
			{
				File[] a = merge((File[]) args.get(key), (File[]) more.get(key));
				for (int j = 0, length = a == null ? 0 : a.length; j < length; j++)
				{
					if (a[j] != null)
					{
						buffer.add(key);
						buffer.add(a[j].getPath());
					}
				}
			}
			else if (value instanceof File[])
			{
				File[] a = merge((File[]) args.get(key), (File[]) more.get(key));
				int length = a == null ? 0 : a.length;
				if (length > 0)
				{
					buffer.add(key);
				}
				else
				{
					buffer.add(key + "=");
				}
				for (int j = 0; j < length; j++)
				{
					if (a[j] != null)
					{
						buffer.add(a[j].getPath());
					}
				}
			}
			else if (value instanceof URL[])
			{
				URL[] a = merge((URL[]) args.get(key), (URL[]) more.get(key));
				int length = a == null ? 0 : a.length;
				if (length > 0)
				{
					buffer.add(key);
				}
				else
				{
					buffer.add(key + "=");
				}
				for (int j = 0; j < length; j++)
				{
					if (a[j] != null)
					{
						buffer.add(a[j].toExternalForm());
					}
				}
			}
			else if (value instanceof RslPathList)
			{
				RslPathList valueList = (RslPathList)value;
				for (Iterator<String[]> iter = valueList.iterator(); iter.hasNext();) 
				{
					StringBuilder sb = new StringBuilder(RUNTIME_SHARED_LIBRARY_PATH);
					sb.append("=");
					String[] cdArgs = iter.next();
					sb.append(cdArgs[0]);
					for (int j = 1; j < cdArgs.length; j++)
					{
						sb.append(",");
						sb.append(cdArgs[j]);
					}
					buffer.add(sb.toString());
				}
			}
            else if (value instanceof CompilerDefinitionList)
            {
                final CompilerDefinitionList defs = (CompilerDefinitionList)value;
                for (Iterator<String> iter = defs.iterator(); iter.hasNext();)
                {
                    // String.valueOf will help turn null into "null"
                    String name = String.valueOf(iter.next());
                    String val  = String.valueOf(iter.next());
                    
                    // handle empty-string values
                    
                    // technically, name should not ever be empty length (value can be),
                    // but we don't want to do error handling, CompilerConfiguration.cfgDefine()
                    // will do it for us later
                    if (name.length() == 0)
                    {
                        name = "\"\"";
                    }
                    
                    if (val.length() == 0)
                    {
                        val = "\"\"";
                    }
                    
                    /* note '+=': defines from all flex-config.xmls will be collected (just '=' would
                     * always ignore all but the most recent definitions), hopefully in a meaningful
                     * order (flex-config, user-config, commandline) since we now allow re-definitions.
                     */
                    buffer.add(COMPILER_DEFINE + "+=" + name + "," + val);
                }
            }
            else if (value instanceof ApplicationDomainsList)
            {
                ApplicationDomainsList valueList = (ApplicationDomainsList)value;
                
                if (valueList.size() == 0)
                    buffer.add(key + "=");  // we should only ever come here for the first and only key.
                else
                    buffer.add(key);
                
                for (String[] adArgs : valueList) 
                {
                    for (int j = 0; j < adArgs.length; j++)
                    {
                        buffer.add(adArgs[j]);
                    }
                }
            }
			else if (value != null)
			{
				assert false;
			}
			else
			{
				// System.err.println("unprocessed compiler options: " + key + "=" + value);
			}
		}
		
		for (Iterator<String> i = more.keySet().iterator(); i.hasNext(); )
		{
			String key = (String) i.next();
			Object value = more.get(key);

			if (value instanceof String[])
			{
				if (!args.containsKey(key))
				{
					buffer.add(key + "+=" + toCommaSeparatedString((String[]) value));
				}
			}
			/*
			else if (LOAD_CONFIG.equals(key) && value instanceof File[])
			{
				if (!args.containsKey(key))
				{
					File[] a = merge(null, (File[]) more.get(key));
					for (int j = 0, length = a == null ? 0 : a.length; j < length; j++)
					{
						if (a[j] != null)
						{
							buffer.add(key);
							buffer.add(a[j].getPath());
						}
					}
				}
			}
			*/
			else if (value instanceof File[])
			{
				if (!args.containsKey(key))
				{
					buffer.add(key + "+=" + toCommaSeparatedString((File[]) value));
				}
			}
			else if (value instanceof URL[])
			{
				if (!args.containsKey(key))
				{
					buffer.add(key + "+=" + toCommaSeparatedString((URL[]) value));
				}
			}
			else if (value instanceof Map)
			{
				Map m = (Map) value;
				for (Iterator j = m.keySet().iterator(); j.hasNext(); )
				{
					String k = (String) j.next();
					Object v = m.get(k);
					
					if (v instanceof List)
					{
						Iterator it = ((List)v).iterator();
						while (it.hasNext())
						{
							Object next = it.next();
							if (next != null)
                                buffer.add(key + "+=" + k + "," + next.toString());
						}
					}
					else if (v != null)
					{
						assert false;
					}
				}
			}
			else if (value instanceof Map)
			{
				Map m = (Map) value;
				for (Iterator j = m.keySet().iterator(); j.hasNext(); )
				{
					String k = (String) j.next();
					Object v = m.get(k);
					
					if (v instanceof List)
					{
						Iterator it = ((List)v).iterator();
						while (it.hasNext())
						{
							Object next = it.next();
							if (next != null)
                                buffer.add(key + "+=" + k + "," + next.toString());
						}
					}
					else if (v != null)
					{
						assert false;
					}
				}
			}
			else if (value != null)
			{
				assert false;
			}
			else
			{
				// System.err.println("unprocessed compiler options: " + key + "=" + value);
			}
		}

		for (int i = 0, length = extras == null ? 0 : extras.length; processExtras && i < length; i++)
		{
			if (extras[i] != null)
			{
				buffer.add(extras[i]);
			}
		}
		
		String[] options = new String[buffer.size()];
		buffer.toArray(options);
		
		return options;
	}
	
	/**
	 * Enables accessibility in the application.
	 * This is equivalent to using <code>mxmlc/compc --compiler.accessible</code>.<p>
	 * By default, this is disabled.
	 * 
	 * @param b boolean value
	 */
	public void enableAccessibility(boolean b)
	{
		args.put(COMPILER_ACCESSIBLE, b ? Boolean.TRUE : Boolean.FALSE);
		linker_args.put(COMPILER_ACCESSIBLE, b ? Boolean.TRUE : Boolean.FALSE);
		newLinkerOptionsAfterCompile.add(COMPILER_ACCESSIBLE);
	}
	
	/**
	 * Sets the ActionScript file encoding. The compiler will use this encoding to read
	 * the ActionScript source files.
	 * This is equivalent to using <code>mxmlc/compc --compiler.actionscript-file-encoding</code>.<p>
	 * By default, the encoding is <code>UTF-8</code>.
	 * 
	 * @param encoding charactere encoding, e.g. <code>UTF-8</code>, <code>Big5</code>
	 */
	public void setActionScriptFileEncoding(String encoding)
	{
		args.put(COMPILER_ACTIONSCRIPT_FILE_ENCODING, encoding);
	}
	
	/**
	 * Allows some source path directories to be subdirectories of the other.
	 * This is equivalent to using <code>mxmlc/compc --compiler.allow-source-path-overlap</code>.<p>
	 * By default, this is disabled.<p>
	 * 
	 * In some J2EE settings, directory overlapping should be allowed. For example,
	 * 
	 * <pre>
	 * wwwroot/MyAppRoot
	 * wwwroot/WEB-INF/flex/source_path1
	 * </pre>
	 * 
	 * @param b boolean value
	 */
	public void allowSourcePathOverlap(boolean b)
	{
		args.put(COMPILER_ALLOW_SOURCE_PATH_OVERLAP, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
	/**
	 * Uses the ActionScript 3 class based object model for greater performance and better error reporting.
	 * In the class based object model, most built-in functions are implemented as fixed methods of classes.
	 * This is equivalent to using <code>mxmlc/compc --compiler.as3</code>.<p>
	 * By default, this is enabled.
	 * 
	 * @param b boolean value
	 */
	public void useActionScript3(boolean b)
	{
		args.put(COMPILER_AS3, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
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
	public void setContextRoot(String path)
	{
		args.put(COMPILER_CONTEXT_ROOT, path);
	}

	/**
	 * Enables debugging in the application.
	 * This is equivalent to using <code>mxmlc/compc --compiler.debug</code> and <code>--debug-password</code>.<p>
	 * By default, debug is <code>false</code> and the debug password is "".
	 * 
	 * @param b boolean value
	 * @param debugPassword a password that is embedded in the application.
	 */
	public void enableDebugging(boolean b, String debugPassword)
	{
		args.put(COMPILER_DEBUG, b ? Boolean.TRUE : Boolean.FALSE);
		args.put(DEBUG_PASSWORD, debugPassword);
		
		linker_args.put(COMPILER_DEBUG, b ? Boolean.TRUE : Boolean.FALSE);
		linker_args.put(DEBUG_PASSWORD, debugPassword);
		
		newLinkerOptionsAfterCompile.add(COMPILER_DEBUG);
		newLinkerOptionsAfterCompile.add(DEBUG_PASSWORD);
	}

	/**
	 * Sets the location of the default CSS file.
	 * This is equivalent to using <code>mxmlc/compc --compiler.defaults-css-url</code>.
	 * 
	 * @param url an instance of <code>java.io.File</code>.
	 */
	public void setDefaultCSS(File url)
	{
		args.put(COMPILER_DEFAULTS_CSS_URL, url);
	}
	
	/**
	 * Uses the ECMAScript edition 3 prototype based object model to allow dynamic overriding
	 * of prototype properties. In the prototype based object model built-in functions are
	 * implemented as dynamic properties of prototype objects.
	 * This is equivalent to using <code>mxmlc/compc --compiler.es</code>.<p>
	 * By default, this is disabled.
	 * 
	 * @param b boolean value
	 */
	public void useECMAScript(boolean b)
	{
		args.put(COMPILER_ES, b ? Boolean.TRUE : Boolean.FALSE);
	}

	/**
	 * Sets the list of SWC files or directories to compile against but to omit from linking.
	 * This is equivalent to using <code>mxmlc/compc --compiler.external-library-path</code>.
	 * 
	 * @param paths <code>File.isDirectory()</code> should return <code>true</code> or <code>File</code> instances should represent SWC files.
	 */
	public void setExternalLibraryPath(File[] paths)
	{
		args.put(COMPILER_EXTERNAL_LIBRARY_PATH, paths);
		more.remove(COMPILER_EXTERNAL_LIBRARY_PATH);
	}

	/**
	 * Adds to the existing list of SWC files.
	 * 
	 * @see #setExternalLibraryPath(File[])
	 * @param paths <code>File.isDirectory()</code> should return <code>true</code> or <code>File</code> instances should represent SWC files.
	 */
	public void addExternalLibraryPath(File[] paths)
	{
		addFiles(COMPILER_EXTERNAL_LIBRARY_PATH, paths);
	}

	/**
	 * Sets a range to restrict the number of font glyphs embedded into the application.
	 * This is equivalent to using <code>mxmlc/compc --compiler.fonts.languages.language-range</code>.
	 * For example,
	 * 
	 * <pre>
	 * setFontLanguageRange("englishRange", "U+0020-U+007E");
	 * </pre>
	 * 
	 * @param language language name
	 * @param range a range of glyphs
	 */
    public void setFontLanguageRange(String language, String range)
	{
		if (!args.containsKey(COMPILER_FONTS_LANGUAGES_LANGUAGE_RANGE))
		{
			args.put(COMPILER_FONTS_LANGUAGES_LANGUAGE_RANGE, new TreeMap<String, String>());
		}
		
        // I am ONLY doing this because we set it three lines above
		@SuppressWarnings("unchecked")
		Map<String, String> map = (Map<String, String>) args.get(COMPILER_FONTS_LANGUAGES_LANGUAGE_RANGE);
		map.put(language, range);
	}
	
	/**
	 * Sets the location of the local font snapshot file. The file contains system font data produced by
	 * <code>flex2.tools.FontSnapshot</code>. This is equivalent to using <code>mxmlc/compc --compiler.fonts.local-fonts-snapshot</code>.
	 * 
	 * @param file file
	 */
	public void setLocalFontSnapshot(File file)
	{
		args.put(COMPILER_FONTS_LOCAL_FONTS_SNAPSHOT, file);
	}

   /**
     * Sets the local font file paths to be searched by the compiler.
     * This is equivalent to using <code>mxmlc/compc --compiler.fonts.local-font-paths</code>.
     * 
     * @param paths an array of file paths.
     */
    public void setLocalFontPaths(String[] paths)
    {
        args.put(COMPILER_FONTS_LOCAL_FONT_PATHS, paths);
        more.remove(COMPILER_FONTS_LOCAL_FONT_PATHS);
    }

    /**
     * Adds local font paths to the existing local font path list.
     * 
     * @see #setLocalFontPaths(String[])
     * @param paths an array of local font file paths.
     */
    public void addLocalFontPaths(String[] paths)
    {
        addStrings(COMPILER_FONTS_LOCAL_FONT_PATHS, paths);
    }

	/**
	 * Sets the font managers used by the compiler.
	 * This is equivalent to using <code>mxmlc/compc --compiler.fonts.managers</code>.
	 * 
	 * @param classNames an array of Java class names.
	 */
	public void setFontManagers(String[] classNames)
	{
		args.put(COMPILER_FONTS_MANAGERS, classNames);
		more.remove(COMPILER_FONTS_MANAGERS);
	}
	
	/**
	 * Adds font managers to the existing font manager list.
	 * 
	 * @see #setFontManagers(String[])
	 * @param classNames an array of Java class names.
	 */
	public void addFontManagers(String[] classNames)
	{
		addStrings(COMPILER_FONTS_MANAGERS, classNames);
	}
	
	/**
	 * Sets the maximum number of embedded font faces that can be cached.
	 * This is equivalent to using <code>mxmlc/compc --compiler.fonts.max-cached-fonts</code>.
	 * By default, it's 20.
	 * 
	 * @param size an integer
	 */
	public void setMaximumCachedFonts(int size)
	{
		if (size > 0)
		{
			args.put(COMPILER_FONTS_MAX_CACHED_FONTS, new Integer(size));
		}
	}
	
	/**
	 * Sets the maximum number of character glyph outlines to cache for each font face.
	 * This is equivalent to using <code>mxmlc/compc --compiler.fonts.max-glyphs-per-face</code>.
	 * By default, it's 1000.
	 *  
	 * @param size an integer
	 */
	public void setMaximumGlyphsPerFace(int size)
	{
		if (size > 0)
		{
			args.put(COMPILER_FONTS_MAX_GLYPHS_PER_FACE, new Integer(size));
		}
	}
	
	/**
	 * Sets the compiler when it runs on a server without a display.
	 * This is equivalent to using <code>mxmlc/compc --compiler.headless-server</code>.
	 * 
	 * @param b boolean value
	 */
	public void useHeadlessServer(boolean b)
	{
		args.put(COMPILER_HEADLESS_SERVER, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
	/**
	 * Sets the AS3 metadata the compiler should keep in the SWF.
	 * This is equivalent to using <code>mxmlc --compiler.keep-as3-metadata</code>.
	 * 
	 * <p>
	 * The default value is <code>{Bindable, Managed, ChangeEvent, NonCommittingChangeEvent, Transient}</code>.
	 * 
	 * @param md an array of AS3 metadata names
	 */
	public void setActionScriptMetadata(String[] md)
	{
		args.put(COMPILER_KEEP_AS3_METADATA, md);
		more.remove(COMPILER_KEEP_AS3_METADATA);
		
		linker_args.put(COMPILER_KEEP_AS3_METADATA, md);
		linker_more.remove(COMPILER_KEEP_AS3_METADATA);
		
		newLinkerOptionsAfterCompile.add(COMPILER_KEEP_AS3_METADATA);
	}
	
	/**
	 * Adds the list of AS3 metadata names to the existing list of AS3 metadata the compiler should
	 * keep in the SWF.
	 * 
	 * @param md an array of AS3 metadata names
	 */
	public void addActionScriptMetadata(String[] md)
	{
		addStrings(COMPILER_KEEP_AS3_METADATA, md);
		addStrings(linker_more, COMPILER_KEEP_AS3_METADATA, md);

		newLinkerOptionsAfterCompile.add(COMPILER_KEEP_AS3_METADATA);
	}

	/**
	 * Disables the pruning of unused type selectors.
	 * This is equivalent to using <code>mxmlc/compc --compiler.keep-all-type-selectors</code>.
	 * By default, it is set to <code>false</code>.
	 * 
	 * @param b boolean value
	 */
	public void keepAllTypeSelectors(boolean b)
	{
		args.put(COMPILER_KEEP_ALL_TYPE_SELECTORS, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
	/**
	 * Saves temporary source files generated during MXML compilation.
	 * This is equivalent to using <code>mxmlc/compc --compiler.keep-generated-actionscript</code>.
	 * By default, it is set to <code>false</code>.
	 * 
	 * @param b boolean value
	 */
	public void keepCompilerGeneratedActionScript(boolean b)
	{
		args.put(COMPILER_KEEP_GENERATED_ACTIONSCRIPT, b ? Boolean.TRUE : Boolean.FALSE);
	}

	/**
	 * Instructs the linker to keep a report of the content that is included in the application.
	 * Callers may use <code>Report.writeLinkReport()</code> to retrieve the linker report.
	 * 
	 * @param b boolean value
	 */
	public void keepLinkReport(boolean b)
	{
		keepLinkReport = b;
		newLinkerOptionsAfterCompile.add(LINK_REPORT);
	}
	
	public boolean keepLinkReport()
	{
		return keepLinkReport;
	}
	
	/**
	 * Instructs the linker to keep a SWF size report.
	 * Callers may use <code>Report.writeSizeReport()</code> to retrieve the size report.
	 * 
	 * @param b boolean value
	 */
	public void keepSizeReport(boolean b)
	{
		keepSizeReport = b;
		newLinkerOptionsAfterCompile.add(SIZE_REPORT);
	}
	
	public boolean keepSizeReport()
	{
		return keepSizeReport;
	}
	
	/**
	 * Instructs the compiler to keep a report of the compiler configuration settings.
	 * Callers may use <code>Report.writeConfigurationReport()</code> to retrieve the configuration report.
	 * 
	 * @param b boolean value
	 */
	public void keepConfigurationReport(boolean b)
	{
		keepConfigurationReport = b;
	}
	
	public boolean keepConfigurationReport()
	{
		return keepConfigurationReport;
	}

	
	/**
	 * Includes a list of libraries (SWCs) to completely include in the application
	 * This is equivalent to using <code>mxmlc/compc --compiler.include-libraries</code>.
	 * 
	 * @param libraries an array of <code>java.io.File</code> (<code>File.isDirectory()</code> should return <code>true</code> or instances must represent SWC files).
	 * @see #setIncludes(String[])
	 * @see #setExterns(File[])
	 * @see #setExterns(String[])
	 * @see #setExternalLibraryPath(File[])
	 */
	public void includeLibraries(File[] libraries)
	{
		args.put(COMPILER_INCLUDE_LIBRARIES, libraries);
	}

    /**
     * Sets a list of resource bundles to include in the swf.
     * This is equivalent to using <code>mxmlc/compc --include-resource-bundle</code>.
     * 
     * @param bundles an array of <code>java.lang.String</code>
    */
    public void setIncludeResourceBundles(String[] bundles)
    {
        args.put(INCLUDE_RESOURCE_BUNDLES, bundles);        
    }   

    /**
     * Adds a list of resource bundles to the existing list.
     * 
     * @see #setIncludeResourceBundles(String[])
     * @param bundles an array of <code>java.lang.String</code>
     */
    public void addIncludeResourceBundles(String[] bundles)
    {
        addStrings(INCLUDE_RESOURCE_BUNDLES, bundles);
    }
    
    /**
	 * Sets a list of SWC files or directories that contain SWC files.
	 * This is equivalent to using <code>mxmlc/compc --compiler.library-path</code>.
	 * 
	 * @param paths an array of <code>File</code>. <code>File.isDirectory()</code> should return <code>true</code> or instances must represent SWC files.
	 */
	public void setLibraryPath(File[] paths)
	{
		args.put(COMPILER_LIBRARY_PATH, paths);
		more.remove(COMPILER_LIBRARY_PATH);
	}

	/**
	 * Adds a list of SWC files or directories to the default library path.
	 * 
	 * @param paths an array of <code>File</code>. <code>File.isDirectory()</code> should return <code>true</code> or instances must represent SWC files.
	 * @see #setLibraryPath(File[])
	 */
	public void addLibraryPath(File[] paths)
	{
		addFiles(COMPILER_LIBRARY_PATH, paths);
	}
	
	/**
	 * Sets the locales that the compiler would use to replace <code>{locale}</code> tokens that appear in some configuration values.
	 * This is equivalent to using <code>mxmlc/compc --compiler.locale</code>.
	 * For example,
	 * 
	 * <pre>
	 * addSourcePath(new File[] { "locale/{locale}" });
	 * addLocale(new String[] { "en_US" });
	 * </pre>
	 * 
	 * The <code>locale/en_US</code> directory will be added to the source path.
	 *
	 * @param locale String
	 * 
	 * @since 3.0
	 */
	public void setLocale(String[] locales)
	{
		args.put(COMPILER_LOCALE, locales);
	}
	
	/**
	 * Sets the locale that the compiler would use to replace <code>{locale}</code> tokens that appear in some configuration values.
	 * This is equivalent to using <code>mxmlc/compc --compiler.locale</code> to set a single locale.
	 * For example,
	 * 
	 * <pre>
	 * addSourcePath(new File[] { "locale/{locale}" });
	 * setLocale(Locale.US);
	 * </pre>
	 * 
	 * The <code>locale/en_US</code> directory will be added to the source path.
	 *
	 * @param locale java.util.Locale
	 * 
	 * @deprecated As of 3.0, use setLocale(String[])
	 */
	public void setLocale(Locale locale)
	{
		setLocale(new String[] { locale.toString() });
	}

    /**
     * Specifies a URI to associate with a manifest of components for use as
     * MXML elements. This is equivalent to using:
     * <code>mxmlc/compc --compiler.namespaces.namespace</code>.
     * 
     * @param namespaceURI a namespace URI
     * @param manifest a component manifest file (XML)
     */
    public void setComponentManifest(String namespaceURI, File manifest)
    {
        List<File> manifests = new ArrayList<File>(2);
        manifests.add(manifest);
        setComponentManifests(namespaceURI, manifests);
    }

    /**
     * Specifies a URI to associate with a list of potentially several manifests
     * which map MXML elements to component implementations. This is equivalent
     * to using: <code>mxmlc/compc --compiler.namespaces.namespace</code>.
     * 
     * @param namespaceURI a namespace URI
     * @param manifests A List of component manifest files (XML)
     */
    public void setComponentManifests(String namespaceURI, List<File> manifests)
    {
        if (!more.containsKey(COMPILER_NAMESPACES_NAMESPACE))
        {
            more.put(COMPILER_NAMESPACES_NAMESPACE, new LinkedHashMap<String, List<File>>());
        }

        // I am ONLY doing this because we set it three lines above
        @SuppressWarnings("unchecked")
        Map<String, List<File>> map = (Map<String, List<File>>) more.get(COMPILER_NAMESPACES_NAMESPACE);
        map.put(namespaceURI, manifests);
    }

	/**
	 * Enables post-link optimization. This is equivalent to using <code>mxmlc/compc --compiler.optimize</code>.
	 * Application sizes are usually smaller with this option enabled.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void optimize(boolean b)
	{
		args.put(COMPILER_OPTIMIZE, b ? Boolean.TRUE : Boolean.FALSE);
		linker_args.put(COMPILER_OPTIMIZE, b ? Boolean.TRUE : Boolean.FALSE);
		newLinkerOptionsAfterCompile.add(COMPILER_OPTIMIZE);
	}
	
	/**
	 * {@inheritDoc}
	 */
	public void compress(boolean b)
	{
        args.put(COMPILER_COMPRESS, b ? Boolean.TRUE : Boolean.FALSE);
        linker_args.put(COMPILER_COMPRESS, b ? Boolean.TRUE : Boolean.FALSE);
        newLinkerOptionsAfterCompile.add(COMPILER_COMPRESS);	    
	}

	/**
	 * Sets the location of the FDS service configuration file.
	 * This is equivalent to using <code>mxmlc/compc --compiler.services</code>
	 * @param file file
	 */
	public void setServiceConfiguration(File file)
	{
		args.put(COMPILER_SERVICES, file);
	}
	
	/**
	 * Runs the ActionScript compiler in a mode that detects legal but potentially incorrect code.
	 * This is equivalent to using <code>mxmlc/compc --compiler.show-actionscript-warnings</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 * @see #checkActionScriptWarning(int, boolean)
	 */
	public void showActionScriptWarnings(boolean b)
	{
		args.put(COMPILER_SHOW_ACTIONSCRIPT_WARNINGS, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
	/**
	 * Toggles whether warnings generated from data binding code are displayed.
	 * This is equivalent to using <code>mxmlc/compc --compiler.show-binding-warnings</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void showBindingWarnings(boolean b)
	{
		args.put(COMPILER_SHOW_BINDING_WARNINGS, b ? Boolean.TRUE : Boolean.FALSE);
	}

	/**
	 * Toggles whether the use of deprecated APIs generates a warning.
	 * This is equivalent to using <code>mxmlc/compc --compiler.show-deprecation-warnings</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void showDeprecationWarnings(boolean b)
	{
		args.put(COMPILER_SHOW_DEPRECATION_WARNINGS, b ? Boolean.TRUE : Boolean.FALSE);
	}

    /**
     * Toggles whether warnings are displayed when an embedded font name shadows
     * a device font name.
     * This is equivalent to using <code>mxmlc/compc --compiler.show-shadowed-device-font-warnings</code>.
     * By default, it is set to <code>true</code>.
     * 
     * @param b boolean value
     */
    public void showShadowedDeviceFontWarnings(boolean b)
    {
        args.put(COMPILER_SHOW_SHADOWED_DEVICE_FONT_WARNINGS, b ? Boolean.TRUE : Boolean.FALSE);
    }

	/**
	 * Toggles whether warnings generated from unused type selectors are displayed.
	 * This is equivalent to using <code>mxmlc/compc --compiler.show-unused-type-selector-warnings</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void showUnusedTypeSelectorWarnings(boolean b)
	{
		args.put(COMPILER_SHOW_UNUSED_TYPE_SELECTOR_WARNINGS, b ? Boolean.TRUE : Boolean.FALSE);
	}

	/**
	 * Sets a list of path elements that form the roots of ActionScript class hierarchies.
	 * This is equivalent to using <code>mxmlc/compc --compiler.source-path</code>.
	 * 
	 * @param paths an array of <code>java.io.File</code> (<code>File.isDirectory()</code> must return <code>true</code>).
	 */
	public void setSourcePath(File[] paths)
	{
		args.put(COMPILER_SOURCE_PATH, paths);
		more.remove(COMPILER_SOURCE_PATH);
	}

	/**
	 * Adds a list of path elements to the existing source path list.
	 * 
	 * @param paths an array of <code>java.io.File</code> (<code>File.isDirectory()</code> must return <code>true</code>).
	 * @see #setSourcePath(File[])
	 */
	public void addSourcePath(File[] paths)
	{
		addFiles(COMPILER_SOURCE_PATH, paths);
	}
	
	/**
	 * Runs the ActionScript compiler in strict error checking mode.
	 * This is equivalent to using <code>mxmlc/compc --compiler.strict</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void enableStrictChecking(boolean b)
	{
		args.put(COMPILER_STRICT, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
	/**
	 * Sets a list of CSS or SWC files to apply as a theme.
	 * This is equivalent to using <code>mxmlc/compc --compiler.theme</code>.
	 * 
	 * @param files an array of <code>java.io.File</code>
	 */
	public void setTheme(File[] files)
	{
		args.put(COMPILER_THEME, files);
		more.remove(COMPILER_THEME);
	}

	/**
	 * Adds a list of CSS or SWC files to the existing list of theme files.
	 * 
	 * @param files an array of <code>java.io.File</code>
	 * @see #setTheme(File[])
	 */
	public void addTheme(File[] files)
	{
		addFiles(COMPILER_THEME, files);
	}
    
	/**
	 * Determines whether resources bundles are included in the application.
	 * This is equivalent to using <code>mxmlc/compc --compiler.use-resource-bundle-metadata</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void useResourceBundleMetaData(boolean b)
	{
		args.put(COMPILER_USE_RESOURCE_BUNDLE_METADATA, b ? Boolean.TRUE : Boolean.FALSE);
	}
	
	/**
	 * Generates bytecodes that include line numbers. When a run-time error occurs,
	 * the stacktrace shows these line numbers. Enabling this option generates larger SWF files.
	 * This is equivalent to using <code>mxmlc/compc --compiler.verbose-stacktraces</code>.
	 * By default, it is set to <code>false</code>.
	 * 
	 * @param b boolean value
	 */
	public void enableVerboseStacktraces(boolean b)
	{
		args.put(COMPILER_VERBOSE_STACKTRACES, b ? Boolean.TRUE : Boolean.FALSE);
		linker_args.put(COMPILER_VERBOSE_STACKTRACES, b ? Boolean.TRUE : Boolean.FALSE);
		newLinkerOptionsAfterCompile.add(COMPILER_VERBOSE_STACKTRACES);
	}
	 
	/**
	 * Enables FlashType for embedded fonts, which provides greater clarity for small fonts.
	 * This is equilvalent to using <code>mxmlc/compc --compiler.fonts.flash-type</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void enableFlashType(boolean b)
	{
		args.put(COMPILER_FONTS_FLASH_TYPE, b ? Boolean.TRUE : Boolean.FALSE);
	}

	/**
	 * Enables advanced anti-aliasing for embedded fonts, which provides greater clarity for small fonts.
	 * This is equilvalent to using <code>mxmlc/compc --compiler.fonts.advanced-anti-aliasing</code>.
	 * By default, it is set to <code>false</code>.
	 * 
	 * @param b boolean value
	 */
	public void enableAdvancedAntiAliasing(boolean b)
	{
		args.put(COMPILER_FONTS_ADVANCED_ANTI_ALIASING, b ? Boolean.TRUE : Boolean.FALSE);
	}

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
    public void removeUnusedRuntimeSharedLibraryPaths(boolean b)
    {
        args.put(REMOVE_UNUSED_RSLS, b ? Boolean.TRUE : Boolean.FALSE);
    }
	
	/**
	 * Enables checking of ActionScript warnings. They are:
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
	 * @param warningCode warning code
	 * @param b boolean value
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
	public void checkActionScriptWarning(int warningCode, boolean b)
	{
		String key = null;
		
		switch (warningCode)
		{
		case WARN_ARRAY_TOSTRING_CHANGES:
			key = COMPILER_WARN_ARRAY_TOSTRING_CHANGES;
			break;
		case WARN_ASSIGNMENT_WITHIN_CONDITIONAL:
			key = COMPILER_WARN_ASSIGNMENT_WITHIN_CONDITIONAL;
			break;
		case WARN_BAD_ARRAY_CAST:
			key = COMPILER_WARN_BAD_ARRAY_CAST;
			break;
		case WARN_BAD_BOOLEAN_ASSIGNMENT:
			key = COMPILER_WARN_BAD_BOOL_ASSIGNMENT;
			break;
		case WARN_BAD_DATE_CAST:
			key = COMPILER_WARN_BAD_DATE_CAST;
			break;
		case WARN_BAD_ES3_TYPE_METHOD:
			key = COMPILER_WARN_BAD_ES3_TYPE_METHOD;
			break;
		case WARN_BAD_ES3_TYPE_PROP:
			key = COMPILER_WARN_BAD_ES3_TYPE_PROP;
			break;
		case WARN_BAD_NAN_COMPARISON:
			key = COMPILER_WARN_BAD_NAN_COMPARISON;
			break;
		case WARN_BAD_NULL_ASSIGNMENT:
			key = COMPILER_WARN_BAD_NULL_ASSIGNMENT;
			break;
		case WARN_BAD_NULL_COMPARISON:
			key = COMPILER_WARN_BAD_NULL_COMPARISON;
			break;
		case WARN_BAD_UNDEFINED_COMPARISON:
			key = COMPILER_WARN_BAD_UNDEFINED_COMPARISON;
			break;
		case WARN_BOOLEAN_CONSTRUCTOR_WITH_NO_ARGS:
			key = COMPILER_WARN_BOOLEAN_CONSTRUCTOR_WITH_NO_ARGS;
			break;
		case WARN_CHANGES_IN_RESOLVE:
			key = COMPILER_WARN_CHANGES_IN_RESOLVE;
			break;
		case WARN_CLASS_IS_SEALED:
			key = COMPILER_WARN_CLASS_IS_SEALED;
			break;
		case WARN_CONST_NOT_INITIALIZED:
			key = COMPILER_WARN_CONST_NOT_INITIALIZED;
			break;
		case WARN_CONSTRUCTOR_RETURNS_VALUE:
			key = COMPILER_WARN_CONSTRUCTOR_RETURNS_VALUE;
			break;
		case WARN_DEPRECATED_EVENT_HANDLER_ERROR:
			key = COMPILER_WARN_DEPRECATED_EVENT_HANDLER_ERROR;
			break;
		case WARN_DEPRECATED_FUNCTION_ERROR:
			key = COMPILER_WARN_DEPRECATED_FUNCTION_ERROR;
			break;
		case WARN_DEPRECATED_PROPERTY_ERROR:
			key = COMPILER_WARN_DEPRECATED_PROPERTY_ERROR;
			break;
		case WARN_DUPLICATE_ARGUMENT_NAMES:
			key = COMPILER_WARN_DUPLICATE_ARGUMENT_NAMES;
			break;
		case WARN_DUPLICATE_VARIABLE_DEF:
			key = COMPILER_WARN_DUPLICATE_VARIABLE_DEF;
			break;
		case WARN_FOR_VAR_IN_CHANGES:
			key = COMPILER_WARN_FOR_VAR_IN_CHANGES;
			break;
		case WARN_IMPORT_HIDES_CLASS:
			key = COMPILER_WARN_IMPORT_HIDES_CLASS;
			break;
		case WARN_INSTANCEOF_CHANGES:
			key = COMPILER_WARN_INSTANCE_OF_CHANGES;
			break;
		case WARN_INTERNAL_ERROR:
			key = COMPILER_WARN_INTERNAL_ERROR;
			break;
		case WARN_LEVEL_NOT_SUPPORTED:
			key = COMPILER_WARN_LEVEL_NOT_SUPPORTED;
			break;
		case WARN_MISSING_NAMESPACE_DECL:
			key = COMPILER_WARN_MISSING_NAMESPACE_DECL;
			break;
		case WARN_NEGATIVE_UINT_LITERAL:
			key = COMPILER_WARN_NEGATIVE_UINT_LITERAL;
			break;
		case WARN_NO_CONSTRUCTOR:
			key = COMPILER_WARN_NO_CONSTRUCTOR;
			break;
		case WARN_NO_EXPLICIT_SUPER_CALL_IN_CONSTRUCTOR:
			key = COMPILER_WARN_NO_EXPLICIT_SUPER_CALL_IN_CONSTRUCTOR;
			break;
		case WARN_NO_TYPE_DECL:
			key = COMPILER_WARN_NO_TYPE_DECL;
			break;
		case WARN_NUMBER_FROM_STRING_CHANGES:
			key = COMPILER_WARN_NUMBER_FROM_STRING_CHANGES;
			break;
		case WARN_SCOPING_CHANGE_IN_THIS:
			key = COMPILER_WARN_SCOPING_CHANGE_IN_THIS;
			break;
		case WARN_SLOW_TEXTFIELD_ADDITION:
			key = COMPILER_WARN_SLOW_TEXT_FIELD_ADDITION;
			break;
		case WARN_UNLIKELY_FUNCTION_VALUE:
			key = COMPILER_WARN_UNLIKELY_FUNCTION_VALUE;
			break;
		case WARN_XML_CLASS_HAS_CHANGED:
			key = COMPILER_WARN_XML_CLASS_HAS_CHANGED;
			break;
		}
		
		if (key != null)
		{
			args.put(key, b ? Boolean.TRUE : Boolean.FALSE);
		}
	}
	
	/**
	 * Sets the default background color (may be overridden by the application code).
	 * This is equivalent to using <code>mxmlc/compc --default-background-color</code>.
	 * The default value is <code>0x869CA7</code>.
	 * 
	 * @param color RGB value
	 */
	public void setDefaultBackgroundColor(int color)
	{
		args.put(DEFAULT_BACKGROUND_COLOR, new Integer(color));
		linker_args.put(DEFAULT_BACKGROUND_COLOR, new Integer(color));
		newLinkerOptionsAfterCompile.add(DEFAULT_BACKGROUND_COLOR);
	}
	
	/**
	 * Sets the default frame rate to be used in the application.
	 * This is equivalent to using <code>mxmlc/compc --default-frame-rate</code>.
	 * The default value is <code>24</code>.
	 * 
	 * @param rate frames per second
	 */
	public void setDefaultFrameRate(int rate)
	{
		args.put(DEFAULT_FRAME_RATE, new Integer(rate));
		linker_args.put(DEFAULT_FRAME_RATE, new Integer(rate));
		newLinkerOptionsAfterCompile.add(DEFAULT_FRAME_RATE);
	}
	
	/**
	 * Sets the default script execution limits (may be overridden by root attributes).
	 * This is equivalent to using <code>mxmlc/compc --default-script-limits</code>.
	 * The default maximum recursion depth is <code>1000</code>.
	 * The default maximum execution time is <code>60</code>.
	 * 
	 * @param maxRecursionDepth recursion depth
	 * @param maxExecutionTime execution time in seconds. 
	 */
	public void setDefaultScriptLimits(int maxRecursionDepth, int maxExecutionTime)
	{
		args.put(DEFAULT_SCRIPT_LIMITS, new int[] { maxRecursionDepth, maxExecutionTime });
		linker_args.put(DEFAULT_SCRIPT_LIMITS, new int[] { maxRecursionDepth, maxExecutionTime });
		newLinkerOptionsAfterCompile.add(DEFAULT_SCRIPT_LIMITS);
	}
	
	/**
	 * Sets the default window size.
	 * This is equivalent to using <code>mxmlc/compc --default-size</code>.
	 * The default width is <code>500</code>.
	 * The default height is <code>375</code>.
	 * 
	 * @param width width in pixels
	 * @param height height in pixels
	 */
	public void setDefaultSize(int width, int height)
	{
		args.put(DEFAULT_SIZE, new int[] { width, height });
		linker_args.put(DEFAULT_SIZE, new int[] { width, height });
		newLinkerOptionsAfterCompile.add(DEFAULT_SIZE);
	}
	
	/**
	 * Sets a list of definitions to omit from linking when building an application.
	 * This is equivalent to using <code>mxmlc/compc --externs</code>.
	 * 
	 * @param definitions An array of definitions (e.g. classes, functions, variables, namespaces, etc.)
	 */
	public void setExterns(String[] definitions)
	{
		args.put(EXTERNS, definitions);
		more.remove(EXTERNS);
		linker_args.put(EXTERNS, definitions);
		linker_more.remove(EXTERNS);
		newLinkerOptionsAfterCompile.add(EXTERNS);
	}
	
	/**
	 * Adds a list of definitions to the existing list of definitions.
	 *
	 * @see #setExterns(File[])
	 * @see #setExterns(String[])
	 * @param definitions an array of definitions (e.g. classes, functions, variables, namespaces, etc.)
	 */
	public void addExterns(String[] definitions)
	{
		addStrings(EXTERNS, definitions);
		addStrings(linker_more, EXTERNS, definitions);
		newLinkerOptionsAfterCompile.add(EXTERNS);
	}

	/**
	 * Loads a file containing configuration options. The file format follows the format of <code>flex-config.xml</code>.
	 * This is equivalent to using <code>mxmlc/compc --load-config</code>.
	 * 
	 * @param file an instance of <code>java.io.File</code>
	 */
	public void setConfiguration(File file)
	{
		args.put(LOAD_CONFIG, new File[] {file});
		more.remove(LOAD_CONFIG);
	}
	
	/**
	 * Adds a file to the existing list of configuration files.
	 * 
	 * @see #setConfiguration(File)
	 * @param file a configuration file
	 */
	public void addConfiguration(File file)
	{
		addFiles(LOAD_CONFIG, new File[] {file});
	}

	/**
	 * Sets the configuration parameters. The input should be valid <code>mxmlc/compc</code> command-line arguments.<p>
	 * 
	 * @param args <code>mxmlc/compc</code> command-line arguments
	 */
	public void setConfiguration(String[] args)
	{
		extras = args;
	}
	
	/**
	 * Sets a list of definitions to omit from linking when building an application.
	 * This is equivalent to using <code>mxmlc/compc --load-externs</code>.
	 * This option is similar to <code>setExterns(String[])</code>. The following is an example of
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
	 * @param files an array of <code>java.io.File</code>
	 */
	public void setExterns(File[] files)
	{
		args.put(LOAD_EXTERNS, files);
		more.remove(LOAD_EXTERNS);
		linker_args.put(LOAD_EXTERNS, files);
		linker_more.remove(LOAD_EXTERNS);
		newLinkerOptionsAfterCompile.add(LOAD_EXTERNS);
	}
	
	/**
	 * Adds a list of files to the existing list of definitions to be omitted from linking.
	 * 
	 * @see #setExterns(File[])
	 * @see #setExterns(String[])
	 * @param files an array of <code>java.io.File</code>.
	 */
	public void addExterns(File[] files)
	{
		addFiles(LOAD_EXTERNS, files);
		addFiles(linker_more, LOAD_EXTERNS, files);
		newLinkerOptionsAfterCompile.add(LOAD_EXTERNS);
	}

	/**
	 * Sets a SWF frame label with a sequence of classnames that will be linked onto the frame.
	 * This is equivalent to using <code>mxmlc/compc --frames.frame</code>.
	 * 
	 * @param label A string
	 * @param classNames an array of class names
	 */
	public void setFrameLabel(String label, String[] classNames)
	{
		if (!args.containsKey(FRAMES_FRAME))
		{
			args.put(FRAMES_FRAME, new TreeMap<String, String[]>());
		}
		
        // I am ONLY doing this because we set it three lines above
        @SuppressWarnings("unchecked")
		Map<String, String[]> map = (Map<String, String[]>) args.get(FRAMES_FRAME);
		map.put(label, classNames);

		if (!linker_args.containsKey(FRAMES_FRAME))
		{
			linker_args.put(FRAMES_FRAME, new TreeMap());
		}
		
        // I am ONLY doing this because we set it three lines above
        @SuppressWarnings("unchecked")
		Map<String, String[]> map2 = (Map<String, String[]>) linker_args.get(FRAMES_FRAME);
		map2.put(label, classNames);
		
		newLinkerOptionsAfterCompile.add(FRAMES_FRAME);
	}
	
	/**
	 * Sets a list of definitions to always link in when building an application.
	 * This is equivalent to using <code>mxmlc/compc --includes</code>.
	 * 
	 * @param definitions an array of definitions (e.g. classes, functions, variables, namespaces, etc).
	 */
	public void setIncludes(String[] definitions)
	{
		args.put(INCLUDES, definitions);
		more.remove(INCLUDES);
		linker_args.put(INCLUDES, definitions);
		linker_more.remove(INCLUDES);
		newLinkerOptionsAfterCompile.add(INCLUDES);
	}
	
	/**
	 * Adds a list of definitions to the existing list of definitions.
	 *
	 * @see #setIncludes(String[])
	 * @param definitions an array of definitions (e.g. classes, functions, variables, namespaces, etc.)
	 */
	public void addIncludes(String[] definitions)
	{
		addStrings(INCLUDES, definitions);
		addStrings(linker_more, INCLUDES, definitions);
		newLinkerOptionsAfterCompile.add(INCLUDES);
	}
	
	/**
	 * Specifies the licenses that the compiler has to validate before compiling.
	 * This is equivalent to using <code>mxmlc/compc --licenses.license</code>
	 * 
	 * @param productName a string
	 * @param serialNumber a serial number
	 */
	public void setLicense(String productName, String serialNumber)
	{
		if (!args.containsKey(LICENSES_LICENSE))
		{
			args.put(LICENSES_LICENSE, new TreeMap<String, String>());
		}
		
        // I am ONLY doing this because we set it three lines above
        @SuppressWarnings("unchecked")
		Map<String, String> map = (Map<String, String>) args.get(LICENSES_LICENSE);
		map.put(productName, serialNumber);		
	}

	/**
	 * Sets the metadata section of the application SWF. This option is equivalent to using the following <code>mxmlc/compc</code>
	 * command-line options:
	 * 
	 * <pre>
	 * --metadata.contributor
	 * --metadata.creator
	 * --metadata.date
	 * --metadata.description
	 * --metadata.language
	 * --metadata.localized-description
	 * --metadata.localized-title
	 * --metadata.publisher
	 * --metadata.title
	 * </pre>
	 * 
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
	 * For example,
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
	 * @param field CONTRIBUTOR, CREATOR, DATE, DESCRIPTION, TITLE, LANGUAGE, PUBLISHER
	 * @param value String, Date or Map
	 * @see #CONTRIBUTOR
	 * @see #CREATOR
	 * @see #DATE
	 * @see #DESCRIPTION
	 * @see #TITLE
	 * @see #LANGUAGE
	 * @see #PUBLISHER
	 */
	public void setSWFMetaData(int field, Object value)
	{
		switch (field)
		{
		case CONTRIBUTOR:
			args.put(METADATA_CONTRIBUTOR, value);
			break;
		case CREATOR:
			args.put(METADATA_CREATOR, value);
			break;
		case DATE:
			args.put(METADATA_DATE, value);
			break;
		case DESCRIPTION:
			args.put(METADATA_LOCALIZED_DESCRIPTION, value);
			break;
		case TITLE:
			args.put(METADATA_LOCALIZED_TITLE, value);
			break;
		case LANGUAGE:
			args.put(METADATA_LANGUAGE, value);
			break;
		case PUBLISHER:
			args.put(METADATA_PUBLISHER, value);
			break;
		}

		switch (field)
		{
		case CONTRIBUTOR:
			linker_args.put(METADATA_CONTRIBUTOR, value);
			break;
		case CREATOR:
			linker_args.put(METADATA_CREATOR, value);
			break;
		case DATE:
			linker_args.put(METADATA_DATE, value);
			break;
		case DESCRIPTION:
			linker_args.put(METADATA_LOCALIZED_DESCRIPTION, value);
			break;
		case TITLE:
			linker_args.put(METADATA_LOCALIZED_TITLE, value);
			break;
		case LANGUAGE:
			linker_args.put(METADATA_LANGUAGE, value);
			break;
		case PUBLISHER:
			linker_args.put(METADATA_PUBLISHER, value);
			break;
		}
		
		newLinkerOptionsAfterCompile.add(METADATA_CONTRIBUTOR);
		newLinkerOptionsAfterCompile.add(METADATA_CREATOR);
		newLinkerOptionsAfterCompile.add(METADATA_DATE);
		newLinkerOptionsAfterCompile.add(METADATA_LOCALIZED_DESCRIPTION);
		newLinkerOptionsAfterCompile.add(METADATA_LOCALIZED_TITLE);
		newLinkerOptionsAfterCompile.add(METADATA_LANGUAGE);
		newLinkerOptionsAfterCompile.add(METADATA_PUBLISHER);
		
		args.remove(RAW_METADATA);
		linker_args.remove(RAW_METADATA);
		newLinkerOptionsAfterCompile.remove(RAW_METADATA);
	}

	/**
	 * Sets the path to the Flash Player executable when building a projector. For example,
	 * 
	 * <pre>
	 * setProjector(new File("C:/.../SAFlashPlayer.exe")) {}
	 * </pre>
	 * 
	 * This is equivalent to using <code>mxmlc/compc --projector</code>.
	 * 
	 * @param file the Flash Player executable.
	 */
	public void setProjector(File file)
	{
		args.put(PROJECTOR, file);
	}
	
	/**
	 * Sets the metadata section of the application SWF.
	 * This is equivalent to using <code>mxmlc/compc --raw-metadata</code>.
	 * This option overrides everything set by the <code>setSWFMetaData</code> method.
	 * 
	 * @see #setSWFMetaData(int, Object)
	 * @param xml a well-formed XML fragment
	 */
	public void setSWFMetaData(String xml)
	{
		args.put(RAW_METADATA, xml);
		linker_args.put(RAW_METADATA, xml);
		
		args.remove(METADATA_CONTRIBUTOR);
		args.remove(METADATA_CREATOR);
		args.remove(METADATA_DATE);
		args.remove(METADATA_LOCALIZED_DESCRIPTION);
		args.remove(METADATA_LOCALIZED_TITLE);
		args.remove(METADATA_LANGUAGE);
		args.remove(METADATA_PUBLISHER);

		linker_args.remove(METADATA_CONTRIBUTOR);
		linker_args.remove(METADATA_CREATOR);
		linker_args.remove(METADATA_DATE);
		linker_args.remove(METADATA_LOCALIZED_DESCRIPTION);
		linker_args.remove(METADATA_LOCALIZED_TITLE);
		linker_args.remove(METADATA_LANGUAGE);
		linker_args.remove(METADATA_PUBLISHER);
		
		newLinkerOptionsAfterCompile.remove(METADATA_CONTRIBUTOR);
		newLinkerOptionsAfterCompile.remove(METADATA_CREATOR);
		newLinkerOptionsAfterCompile.remove(METADATA_DATE);
		newLinkerOptionsAfterCompile.remove(METADATA_LOCALIZED_DESCRIPTION);
		newLinkerOptionsAfterCompile.remove(METADATA_LOCALIZED_TITLE);
		newLinkerOptionsAfterCompile.remove(METADATA_LANGUAGE);
		newLinkerOptionsAfterCompile.remove(METADATA_PUBLISHER);
	}
	
	/**
	 * Sets a list of runtime shared library URLs to be loaded before the application starts.
	 * This is equivalent to using <code>mxmlc/compc --runtime-shared-libraries</code>.
	 * 
	 * @param libraries an array of <code>java.lang.String</code>.
	 */
	public void setRuntimeSharedLibraries(String[] libraries)
	{
		args.put(RUNTIME_SHARED_LIBRARIES, libraries);
		more.remove(RUNTIME_SHARED_LIBRARIES);
	}

	/**
	 * Adds a list of runtime shared library URLs to the existing list.
	 * 
	 * @see #setRuntimeSharedLibraries(String[])
	 * @param libraries an array of <code>java.lang.String</code>
	 */
	public void addRuntimeSharedLibraries(String[] libraries)
	{
		addStrings(RUNTIME_SHARED_LIBRARIES, libraries);
	}

	/**
	 * Toggles whether the application SWF is flagged for access to network resources.
	 * This is equivalent to using <code>mxmlc/compc --use-network</code>.
	 * By default, it is set to <code>true</code>.
	 * 
	 * @param b boolean value
	 */
	public void useNetwork(boolean b)
	{
		args.put(USE_NETWORK, b ? Boolean.TRUE : Boolean.FALSE);
		linker_args.put(USE_NETWORK, b ? Boolean.TRUE : Boolean.FALSE);
		newLinkerOptionsAfterCompile.add(USE_NETWORK);
	}
	
	/**
	 * Defines a token. mxmlc and compc support token substitutions. For example,
	 * 
	 * <pre>
	 * mxmlc +flexlib=path1 +foo=bar --var=${foo}
	 * </pre>
	 * 
	 * <code>var=bar</code> after the substitution of <code>${foo}</code>.
	 * 
	 * @param name
	 * @param value
	 */
	public void setToken(String name, String value)
	{
		tokens.put(name, value);
	}

	/**
	 * 
	 * @param key
	 * @param files
	 */
	private void addFiles(String key, File[] files)
	{
		addFiles(more, key, files);
	}

	/**
	 * 
	 * @param more
	 * @param key
	 * @param files
	 */
	private void addFiles(Map<String, Object> more, String key, File[] files)
	{
		File[] existing = null;
		
		if (more.containsKey(key))
		{
			existing = (File[]) more.get(key);
		}
		
		if (existing != null)
		{
			int length1 = existing.length, length2 = files == null ? 0 : files.length;
			
			File[] newPaths = new File[length1 + length2];
			System.arraycopy(existing, 0, newPaths, 0, length1);
			System.arraycopy(files, 0, newPaths, length1, length2);
			
			files = newPaths;
		}
		
		more.put(key, files);
	}
	
	/**
	 * 
	 * @param a1
	 * @param a2
	 * @return
	 */
	private String[] merge(String[] a1, String[] a2)
	{
		int l1 = a1 == null ? 0 : a1.length;
		int l2 = a2 == null ? 0 : a2.length;
		
		String[] a3 = new String[l1 + l2];
		if (a1 != null)
		{
			System.arraycopy(a1, 0, a3, 0, l1);			
		}
		if (a2 != null)
		{
			System.arraycopy(a2, 0, a3, l1, l2);
		}
		
		return a3;
	}
	
	/**
	 * 
	 * @param a1
	 * @param a2
	 * @return
	 */
	private File[] merge(File[] a1, File[] a2)
	{
		int l1 = a1 == null ? 0 : a1.length;
		int l2 = a2 == null ? 0 : a2.length;
		
		File[] a3 = new File[l1 + l2];
		if (a1 != null)
		{
			System.arraycopy(a1, 0, a3, 0, l1);
		}
		if (a2 != null)
		{
			System.arraycopy(a2, 0, a3, l1, l2);
		}
		
		return a3;
	}

	/**
	 * 
	 * @param a1
	 * @param a2
	 * @return
	 */
	private URL[] merge(URL[] a1, URL[] a2)
	{
		int l1 = a1 == null ? 0 : a1.length;
		int l2 = a2 == null ? 0 : a2.length;
		
		URL[] a3 = new URL[l1 + l2];
		if (a1 != null)
		{
			System.arraycopy(a1, 0, a3, 0, l1);
		}
		if (a2 != null)
		{
			System.arraycopy(a2, 0, a3, l1, l2);
		}
		
		return a3;
	}

	
	/**
	 * 
	 * @param key
	 * @param strings
	 */
	private void addStrings(String key, String[] strings)
	{
		addStrings(more, key, strings);
	}
	
	/**
	 * 
	 * @param more
	 * @param key
	 * @param strings
	 */
	private void addStrings(Map<String, Object> more, String key, String[] strings)
	{
		String[] existing = null;
		
		if (more.containsKey(key))
		{
			existing = (String[]) more.get(key);
		}
		
		if (existing != null)
		{
			int length1 = existing.length, length2 = strings == null ? 0 : strings.length;
			
			String[] newStrings = new String[length1 + length2];
			System.arraycopy(existing, 0, newStrings, 0, length1);
			System.arraycopy(strings, 0, newStrings, length1, length2);
			
			strings = newStrings;
		}
		
		more.put(key, strings);
	}

	/**
	 * 
	 * @param key
	 * @param urls
	 */
	private void addURLs(String key, URL[] urls)
	{
		URL[] existing = null;
		
		if (more.containsKey(key))
		{
			existing = (URL[]) more.get(key);
		}
		
		if (existing != null)
		{
			int length1 = existing.length, length2 = urls == null ? 0 : urls.length;
			
			URL[] newURLs = new URL[length1 + length2];
			System.arraycopy(existing, 0, newURLs, 0, length1);
			System.arraycopy(urls, 0, newURLs, length1, length2);
			
			urls = newURLs;
		}
		
		more.put(key, urls);
	}

	/**
	 * 
	 */
	public String toString()
	{
		String[] args = getCompilerOptions();
		StringBuilder b = new StringBuilder();
		for (int i = 0; i < args.length; i++)
		{
			b.append(args[i]);
			b.append(' ');
		}
		return b.toString();
	}
	
	/**
	 * 
	 * @param f
	 * @return
	 */
	private File toFile(VirtualFile f)
	{
		return (f instanceof LocalFile) ? new File(f.getName()) : null;
	}

	/**
	 * 
	 * @param f
	 * @return
	 */
	private URL toURL(VirtualFile f)
	{
		try
		{
			return (f instanceof LocalFile) ? new File(f.getName()).toURL() : null;
		}
		catch (MalformedURLException ex)
		{
			return null;
		}
	}

	/**
	 * 
	 * @param p
	 * @return
	 */
	private File toFile(String p)
	{
		return (p != null) ? new File(p) : null;
	}
	
	/**
	 * 
	 * @param files
	 * @return
	 */
	private File[] toFiles(VirtualFile[] files)
	{
		File[] newFiles = new File[files == null ? 0 : files.length];
		for (int i = 0, length = newFiles.length; i < length; i++)
		{
			newFiles[i] = toFile(files[i]);
		}
		
		return newFiles;
	}
	
	/**
	 * 
	 * @param list
	 * @return
	 */
	private String[] toStrings(List list)
	{
		String[] strings = new String[list == null ? 0 : list.size()];
		for (int i = 0, length = strings.length; i < length; i++)
		{
			strings[i] = (String) list.get(i);
		}
		return strings;
	}

	/**
	 * 
	 * @param list
	 * @return
	 */
	private URL[] toURLs(List list)
	{
		URL[] urls = new URL[list == null ? 0 : list.size()];
		for (int i = 0, length = urls.length; i < length; i++)
		{
			try
			{
				urls[i] = new URL((String) list.get(i));
			}
			catch (MalformedURLException ex)
			{
				urls[i] = null;
			}
		}
		return urls;
	}

	/**
	 * 
	 * @param set
	 * @return
	 */
	private String[] toStrings(Set set)
	{
		String[] strings = new String[set == null ? 0 : set.size()];
		if (set != null)
		{
			int k = 0;
			for (Iterator i = set.iterator(); i.hasNext(); k++)
			{
				strings[k] = (String) i.next();
			}
		}
		return strings;		
	}
	
	/**
	 * 
	 * @param num
	 * @return
	 */
	private int toInteger(String num)
	{
		try
		{
			return Integer.parseInt(num);
		}
		catch (NumberFormatException ex)
		{
			return -1;
		}
	}

	private String toCommaSeparatedString(String[] strings)
	{
		StringBuilder b = new StringBuilder();
		for (int i = 0, length = strings == null ? 0 : strings.length; i < length; i++)
		{
			b.append(strings[i]);
			if (i < length - 1)
			{
				b.append(',');
			}
		}
		return b.toString();
	}

	private String toCommaSeparatedString(File[] files)
	{
		StringBuilder b = new StringBuilder();
		for (int i = 0, length = files == null ? 0 : files.length; i < length; i++)
		{
			b.append(files[i].getPath());
			if (i < length - 1)
			{
				b.append(',');
			}
		}
		return b.toString();
	}

	private String toCommaSeparatedString(URL[] urls)
	{
		StringBuilder b = new StringBuilder();
		for (int i = 0, length = urls == null ? 0 : urls.length; i < length; i++)
		{
			b.append(urls[i].toExternalForm());
			if (i < length - 1)
			{
				b.append(',');
			}
		}
		return b.toString();
	}

    /**
	 * 
     * @param c
     */
	private void populateDefaults(ToolsConfiguration c)
	{
		setDefaultBackgroundColor(c.backgroundColor());
		setDefaultFrameRate(c.getFrameRate());
		setDefaultScriptLimits(c.getScriptRecursionLimit(), c.getScriptTimeLimit());
		setDefaultSize(c.defaultWidth(), c.defaultHeight());
		setExterns(toStrings(c.getExterns()));
		setIncludes(toStrings(c.getIncludes()));
		setTargetPlayer(c.getTargetPlayerMajorVersion(), c.getTargetPlayerMinorVersion(), 
						c.getTargetPlayerRevision());
		enableDigestVerification(c.getVerifyDigests());
		removeUnusedRuntimeSharedLibraryPaths(c.getRemoveUnusedRsls());
		
		List<RslPathInfo> rslList = c.getRslPathInfo();
		boolean first = true;
		for (Iterator<RslPathInfo> iter = rslList.iterator(); iter.hasNext();) {
			RslPathInfo info = (RslPathInfo)iter.next();
			String[] rslUrls = info.getRslUrls().toArray(new String[0]);
			String[] policyUrls = info.getPolicyFileUrls().toArray(new String[0]);
			if (first) {
				setRuntimeSharedLibraryPath(info.getSwcPath(),
						rslUrls,
						policyUrls);
				first = false;
			}
			else {
				addRuntimeSharedLibraryPath(info.getSwcPath(),
						rslUrls,
						policyUrls);
			}
		}
		
		// TODO
		// setSWFMetaData();
		// setProjector();
		
		setSWFMetaData(c.getMetadata());
		setRuntimeSharedLibraries(toStrings(c.getRuntimeSharedLibraries()));
		useNetwork(c.useNetwork());
		
		// useMobileFramework();
		
		populateDefaults(c.getCompilerConfiguration());
		populateDefaults(c.getFramesConfiguration());
		populateDefaults(c.getLicensesConfiguration());
		populateDefaults(c.getRuntimeSharedLibrarySettingsConfiguration());
	}

	/**
	 * 
	 * @param cc
	 */
	private void populateDefaults(CompilerConfiguration cc)
	{
		enableAccessibility(cc.accessible());
		setActionScriptMetadata(cc.getKeepAs3Metadata());
		setActionScriptFileEncoding(cc.getActionscriptFileEncoding());
		allowSourcePathOverlap(cc.allowSourcePathOverlap());
		useActionScript3(cc.dialect() == CompilerConfiguration.AS3Dialect);
		setContextRoot(cc.getContextRoot());
		enableDebugging(cc.debug(), configuration.debugPassword());
		
		if (cc.getDefaultsCssUrl() != null)
		{
			setDefaultCSS(FileUtil.openFile(cc.getDefaultsCssUrl().getName()));
		}
		
		useECMAScript(cc.dialect() == CompilerConfiguration.ESDialect);
		setExternalLibraryPath(toFiles(cc.getExternalLibraryPath()));
		useHeadlessServer(cc.headlessServer());
		keepAllTypeSelectors(cc.keepAllTypeSelectors());
		keepCompilerGeneratedActionScript(cc.keepGeneratedActionScript());
		includeLibraries(toFiles(cc.getIncludeLibraries()));
		setLibraryPath(toFiles(cc.getLibraryPath()));
		setLocale(cc.getLocales());
		optimize(cc.optimize());
		setServiceConfiguration(toFile(cc.getServices()));
		showActionScriptWarnings(cc.warnings());
		showBindingWarnings(cc.showBindingWarnings());
		showDeprecationWarnings(cc.showDeprecationWarnings());
        showShadowedDeviceFontWarnings(cc.showShadowedDeviceFontWarnings());
		showUnusedTypeSelectorWarnings(cc.showUnusedTypeSelectorWarnings());
		setSourcePath(cc.getUnexpandedSourcePath());
		enableStrictChecking(cc.strict());
		setTheme(toFiles(cc.getThemeFiles()));
		useResourceBundleMetaData(cc.useResourceBundleMetadata());
		enableVerboseStacktraces(cc.debug());
        setDefineDirective(cc.getDefine());
        setCompatibilityVersion(cc.getMxmlConfiguration().getMajorCompatibilityVersion(),
        						cc.getMxmlConfiguration().getMinorCompatibilityVersion(),
        						cc.getMxmlConfiguration().getRevisionCompatibilityVersion());

		checkActionScriptWarning(WARN_ARRAY_TOSTRING_CHANGES, cc.warn_array_tostring_changes());
		checkActionScriptWarning(WARN_ASSIGNMENT_WITHIN_CONDITIONAL, cc.warn_assignment_within_conditional());
		checkActionScriptWarning(WARN_BAD_ARRAY_CAST, cc.warn_bad_array_cast());
		checkActionScriptWarning(WARN_BAD_BOOLEAN_ASSIGNMENT, cc.warn_bad_bool_assignment());
		checkActionScriptWarning(WARN_BAD_DATE_CAST, cc.warn_bad_date_cast());
		checkActionScriptWarning(WARN_BAD_ES3_TYPE_METHOD, cc.warn_bad_es3_type_method());
		checkActionScriptWarning(WARN_BAD_ES3_TYPE_PROP, cc.warn_bad_es3_type_prop());
		checkActionScriptWarning(WARN_BAD_NAN_COMPARISON, cc.warn_bad_nan_comparison());
		checkActionScriptWarning(WARN_BAD_NULL_ASSIGNMENT, cc.warn_bad_null_assignment());
		checkActionScriptWarning(WARN_BAD_NULL_COMPARISON, cc.warn_bad_null_comparison());
		checkActionScriptWarning(WARN_BAD_UNDEFINED_COMPARISON, cc.warn_bad_undefined_comparison());
		checkActionScriptWarning(WARN_BOOLEAN_CONSTRUCTOR_WITH_NO_ARGS, cc.warn_boolean_constructor_with_no_args());
		checkActionScriptWarning(WARN_CHANGES_IN_RESOLVE, cc.warn_changes_in_resolve());
		checkActionScriptWarning(WARN_CLASS_IS_SEALED, cc.warn_class_is_sealed());
		checkActionScriptWarning(WARN_CONST_NOT_INITIALIZED, cc.warn_const_not_initialized());
		checkActionScriptWarning(WARN_CONSTRUCTOR_RETURNS_VALUE, cc.warn_constructor_returns_value());
		checkActionScriptWarning(WARN_DEPRECATED_EVENT_HANDLER_ERROR, cc.warn_deprecated_event_handler_error());
		checkActionScriptWarning(WARN_DEPRECATED_FUNCTION_ERROR, cc.warn_deprecated_function_error());
		checkActionScriptWarning(WARN_DEPRECATED_PROPERTY_ERROR, cc.warn_deprecated_property_error());
		checkActionScriptWarning(WARN_DUPLICATE_ARGUMENT_NAMES, cc.warn_duplicate_argument_names());
		checkActionScriptWarning(WARN_DUPLICATE_VARIABLE_DEF, cc.warn_duplicate_variable_def());
		checkActionScriptWarning(WARN_FOR_VAR_IN_CHANGES, cc.warn_for_var_in_changes());
		checkActionScriptWarning(WARN_IMPORT_HIDES_CLASS, cc.warn_import_hides_class());
		checkActionScriptWarning(WARN_INSTANCEOF_CHANGES, cc.warn_instance_of_changes());
		checkActionScriptWarning(WARN_INTERNAL_ERROR, cc.warn_internal_error());
		checkActionScriptWarning(WARN_LEVEL_NOT_SUPPORTED, cc.warn_level_not_supported());
		checkActionScriptWarning(WARN_MISSING_NAMESPACE_DECL, cc.warn_missing_namespace_decl());
		checkActionScriptWarning(WARN_NEGATIVE_UINT_LITERAL, cc.warn_negative_uint_literal());
		checkActionScriptWarning(WARN_NO_CONSTRUCTOR, cc.warn_no_constructor());
		checkActionScriptWarning(WARN_NO_EXPLICIT_SUPER_CALL_IN_CONSTRUCTOR, cc.warn_no_explicit_super_call_in_constructor());
		checkActionScriptWarning(WARN_NO_TYPE_DECL, cc.warn_no_type_decl());
		checkActionScriptWarning(WARN_NUMBER_FROM_STRING_CHANGES, cc.warn_number_from_string_changes());
		checkActionScriptWarning(WARN_SCOPING_CHANGE_IN_THIS, cc.warn_scoping_change_in_this());
		checkActionScriptWarning(WARN_SLOW_TEXTFIELD_ADDITION, cc.warn_slow_text_field_addition());
		checkActionScriptWarning(WARN_UNLIKELY_FUNCTION_VALUE, cc.warn_unlikely_function_value());
		checkActionScriptWarning(WARN_XML_CLASS_HAS_CHANGED, cc.warn_xml_class_has_changed());

		populateDefaults(cc.getFontsConfiguration());
		populateDefaults(cc.getNamespacesConfiguration());
	}

	/**
	 * 
	 * @param fc
	 */
	private void populateDefaults(FontsConfiguration fc)
	{
		FontsConfiguration.Languages lc = fc.getLanguagesConfiguration();
		
		for (Iterator i = lc.keySet().iterator(); i.hasNext(); )
		{
			String key = (String) i.next();
			setFontLanguageRange(key, lc.getProperty(key));
		}
		setLocalFontSnapshot(toFile(fc.getLocalFontsSnapshot()));
		setLocalFontPaths(toStrings(fc.getLocalFontPaths()));
		setFontManagers(toStrings(fc.getManagers()));
		setMaximumCachedFonts(toInteger(fc.getMaxCachedFonts()));
		setMaximumGlyphsPerFace(toInteger(fc.getMaxGlyphsPerFace()));
		enableAdvancedAntiAliasing(fc.getFlashType());
	}

	/**
	 * 
	 * @param nc
	 */
	private void populateDefaults(NamespacesConfiguration nc)
	{
	    Map<String, List<VirtualFile>> manifestMappings = nc.getManifestMappings();

		if (manifestMappings != null)
		{
		    Iterator<Entry<String, List<VirtualFile>>> iterator = manifestMappings.entrySet().iterator();
			while (iterator.hasNext())
			{
				Entry<String, List<VirtualFile>> entry = iterator.next();
			    String uri = entry.getKey();
			    List<VirtualFile> virtualFiles = entry.getValue();
			    List<File> files = new ArrayList<File>(virtualFiles.size());

			    Iterator<VirtualFile> vi = virtualFiles.iterator();
			    while (vi.hasNext())
			    {
	                files.add(toFile(vi.next()));
			    }
                setComponentManifests(uri, files);
			}
		}
	}
	
	/**
	 * 
	 * @param frc
	 */
	private void populateDefaults(FramesConfiguration frc)
	{
		List frList = frc.getFrameList();

		for (int i = 0, length = frList == null ? 0 : frList.size(); i < length; i++)
		{
			FrameInfo info = (FrameInfo) frList.get(i);
			setFrameLabel(info.label, toStrings(info.frameClasses));
		}
	}
	
	/**
	 * 
	 * @param lic
	 */
	private void populateDefaults(LicensesConfiguration lic)
	{
		Map licenseMap = lic.getLicenseMap();

		if (licenseMap != null)
		{
			for (Iterator i = licenseMap.keySet().iterator(); i.hasNext(); )
			{
				String name = (String) i.next();
				setLicense(name, (String) licenseMap.get(name));
			}
		}
	}
	
    /**
     * 
     * @param configuration - runtime shared library settings.
     */
    private void populateDefaults(RuntimeSharedLibrarySettingsConfiguration configuration)
    {
        setForceRuntimeSharedLibraryPaths(toFiles(configuration.getForceRsls()));
        
        Map<VirtualFile, String>adMap = configuration.getApplicationDomains();
        boolean first = true;
        
        for (Map.Entry<VirtualFile, String>entry : adMap.entrySet())
        {
            File file = toFile(entry.getKey());
            if (first)
            {
                setApplicationDomainForRuntimeSharedLibraryPath(
                        file,
                        entry.getValue());
                first = false;
            }
            else
            {
                addApplicationDomainForRuntimeSharedLibraryPath(
                        file,
                        entry.getValue());
            }
        }
        
    }

    public boolean hasChanged()
	{
		return newLinkerOptionsAfterCompile.size() > 0;
	}
	
	public void reset()
	{
		newLinkerOptionsAfterCompile.clear();
	}
	
	public void setTargetPlayer(int major, int minor, int revision)
	{
		args.put(TARGET_PLAYER, major + "." + minor + "." + revision);
	}

	public void setCompatibilityVersion(int major, int minor, int revision)
	{
		if (!(major == 0 && minor == 0 && revision == 0))
		{
			args.put(COMPILER_MXML_COMPATIBILITY, major + "." + minor + "." + revision);
		}
	}

	private String[] createCrossDomainArray(String swc, String[] rslUrls, String[] policyFileUrls)
	{
		if (swc == null || rslUrls == null || policyFileUrls == null) 
		{
			throw new NullPointerException();
		}
		
		if (rslUrls.length != policyFileUrls.length)
		{
			throw new IllegalArgumentException();
		}
		
		List<String> rslList = new ArrayList<String>();
		
		rslList.add(swc);
		
		int argCount = rslUrls.length;
		for (int i = 0; i < argCount; i++) 
		{
			rslList.add(rslUrls[i]);
			rslList.add(policyFileUrls[i]);
		}
		
		return rslList.toArray(new String[0]);
	}
	
	
	public void enableDigestComputation(boolean compute)
	{
		args.put(COMPILER_COMPUTE_DIGEST, compute ? Boolean.TRUE : Boolean.FALSE);				
	}

	
	public void addRuntimeSharedLibraryPath(String swc, String[] rslUrls, String[] policyFileUrls)
	{
		String[] rslArray = createCrossDomainArray(swc, rslUrls, policyFileUrls);

		RslPathList value = (RslPathList) args.get(RUNTIME_SHARED_LIBRARY_PATH);
		if (value == null)
		{
			value = new RslPathList();
			args.put(RUNTIME_SHARED_LIBRARY_PATH, value);
		}

		value.add(rslArray);			
	}

	public void setRuntimeSharedLibraryPath(String swc, String[] rslUrls, String[] policyFileUrls)
	{
		String[] rslArray = createCrossDomainArray(swc, rslUrls, policyFileUrls);

		RslPathList list = new RslPathList();
		list.add(rslArray);
		
		args.put(RUNTIME_SHARED_LIBRARY_PATH, list);
	}

	public void enableDigestVerification(boolean verify)
	{
		args.put(VERIFY_DIGESTS, verify ? Boolean.TRUE : Boolean.FALSE);	
	}

    public void addDefineDirective(String name, String value)
    {
        // error checking on the values themsevles will be handled later,
        // in CompilerConfiguration.cfgDefine()
        CompilerDefinitionList defs = (CompilerDefinitionList) args.get(COMPILER_DEFINE);
        if (defs == null)
        {
            defs = new CompilerDefinitionList();
            args.put(COMPILER_DEFINE, defs);
        }

        defs.add(name);
        defs.add(value);
    }
    
    public void setDefineDirective(String[] names, String[] values)
    {
        if ((names == null) || (values == null) || (names.length != values.length))
        {
            args.remove(COMPILER_DEFINE);
        }
        else
        {
            final CompilerDefinitionList defs = new CompilerDefinitionList();
            args.put(COMPILER_DEFINE, defs);
            
            for(int i = 0; i < values.length; i++)
            {
                defs.add(names[i]);
                defs.add(values[i]);
            }
        }
    }

    /**
     * hacky non-API helper method for populateDefaults
     */
    private void setDefineDirective(ObjectList<ConfigVar> configVars)
    {
        if (configVars != null)
        {
            final CompilerDefinitionList defs = new CompilerDefinitionList();
            args.put(COMPILER_DEFINE, defs);
            for(ConfigVar var : configVars)
            {
                // by this point, error checking should already have been
                // performed on the ConfigVars
                assert (var       != null &&
                        var.ns    != null &&
                        var.name  != null &&
                        var.value != null &&
                        var.ns.length()    > 0 &&
                        var.name.length()  > 0 &&
                        var.value.length() > 0);
                
                defs.add(var.ns + "::" + var.name);
                defs.add(var.value);
            }
        }
    }
    
    @SuppressWarnings("unchecked")
    public Map<String, List<String>> getExtensions() {
        if( !args.containsKey( COMPILER_EXTENSIONS ) ) {
            args.put( COMPILER_EXTENSIONS, new LinkedHashMap<String, List<String>>() );
        }
        return (Map<String, List<String>>) args.get( COMPILER_EXTENSIONS );
    }

    public void addExtensionLibraries( File extension, List<String> parameter )
    {
        getExtensions().put( extension.getAbsolutePath(), parameter );
    }

    public void setExtensionLibraries( Map<File, List<String>> extensions)
    {
        getExtensions().clear();
        Set<File> keys = extensions.keySet();
        for ( File key : keys )
        {
            addExtensionLibraries( key, extensions.get( key ) );
        }
    }
    
    @Override
    public OEMConfiguration clone()
    {
        OEMConfiguration cloneConfig;
        try
        {
            cloneConfig = (OEMConfiguration) super.clone();
        }
        catch ( CloneNotSupportedException e )
        {
            throw new RuntimeException(e);//wont happen
        }
        cloneConfig.args = new LinkedHashMap<String, Object>(args);
        cloneConfig.defaults = new LinkedHashMap<String, Object>(defaults);
        cloneConfig.more = new LinkedHashMap<String, Object>(more);
        cloneConfig.linker_args = new LinkedHashMap<String, Object>(linker_args);
        cloneConfig.linker_more = new LinkedHashMap<String, Object>(linker_more);
        return cloneConfig;
    }

    public void addForceRuntimeSharedLibraryPaths(File[] paths)
    {
        if (paths == null)
            throw new NullPointerException("paths may not be null");

        addFiles(RUNTIME_SHARED_LIBRARY_SETTINGS_FORCE_RSLS, paths);
    }

    public void setForceRuntimeSharedLibraryPaths(File[] paths)
    {
        if (paths == null)
            throw new NullPointerException("paths may not be null");
        
        args.put(RUNTIME_SHARED_LIBRARY_SETTINGS_FORCE_RSLS, paths);
        more.remove(RUNTIME_SHARED_LIBRARY_SETTINGS_FORCE_RSLS);
    }
    
    public void addApplicationDomainForRuntimeSharedLibraryPath(File path, String applicationDomainTarget)
    {
        validateApplicationDomainArguments(path, applicationDomainTarget);
        
        ApplicationDomainsList value = (ApplicationDomainsList) args.get(RUNTIME_SHARED_LIBRARY_SETTINGS_APPLICATION_DOMAIN);
        if (value == null)
        {
            value = new ApplicationDomainsList();
            args.put(RUNTIME_SHARED_LIBRARY_SETTINGS_APPLICATION_DOMAIN, value);
        }

        value.add(new String[]{path.getPath(), applicationDomainTarget});                        
    }
    
    public void setApplicationDomainForRuntimeSharedLibraryPath(File path, String applicationDomainTarget)
    {
        ApplicationDomainsList list = new ApplicationDomainsList();
        if (path == null)
        {
            args.put(RUNTIME_SHARED_LIBRARY_SETTINGS_APPLICATION_DOMAIN, list);
            return;
        }
        
        validateApplicationDomainArguments(path, applicationDomainTarget);

        list.add(new String[]{path.getPath(), applicationDomainTarget});            

        args.put(RUNTIME_SHARED_LIBRARY_SETTINGS_APPLICATION_DOMAIN, list);
    }

    /**
     *  Validate the arguments to the application domain methods.
     *  Throw exceptions if the arguments do not pass the tests. 
     */
    private void validateApplicationDomainArguments(File path, String applicationDomainTarget)
    {
        if (path == null)
            throw new NullPointerException("paths may not be null");
        
        if (applicationDomainTarget == null)
            throw new NullPointerException("applicationDomains may not be null");
    }

}
