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

package flex2.compiler.common;

import flex2.compiler.config.AdvancedConfigurationInfo;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.io.VirtualFile;
import flash.fonts.CachedFontManager;
import flash.fonts.FontManager;
import flash.fonts.JREFontManager;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;
import java.util.Map;
import java.util.HashMap;

/**
 * This class defines the fonts related configuration options.  These
 * options are typically set via flex-config.xml.
 *
 * @author Kyle Quevillon
 * @author Peter Farland
 */
@SuppressWarnings("unchecked")
public class FontsConfiguration
{
 	private CompilerConfiguration compilerConfig;

	public void setCompilerConfiguration(CompilerConfiguration compilerConfig)
	{
		this.compilerConfig = compilerConfig;
	}
	
    private ConfigurationPathResolver configResolver;

    public void setConfigPathResolver( ConfigurationPathResolver resolver )
    {
        this.configResolver = resolver;
    }

    private FontManager topLevelManager;

    /**
     * Must be called <i>after</i> configuration is committed.
     *
     * @return the last of potentially several FontManagers in the manager list
     */
    public FontManager getTopLevelManager()
    {
        if (topLevelManager == null)
        {
            Map map = new HashMap();
            map.put(CachedFontManager.MAX_CACHED_FONTS_KEY, max_cached_fonts);
            map.put(CachedFontManager.MAX_GLYPHS_PER_FACE_KEY, max_glyphs_per_face);
            map.put(CachedFontManager.COMPATIBILITY_VERSION, compilerConfig.getCompatibilityVersionString());

            if (localFontsSnapshot != null)
		        map.put(JREFontManager.LOCAL_FONTS_SNAPSHOT, localFontsSnapshot.getName());

            if (resolvedLocalFontPaths != null)
                map.put(FontManager.LOCAL_FONT_PATHS, resolvedLocalFontPaths);

            topLevelManager = FontManager.create(managers, map, languages);
        }

        return topLevelManager;
    }

    public void setTopLevelManager(FontManager manager)
    {
        topLevelManager = manager;
    }

    //
    // 'compiler.fonts.flash-type' option
    //

	private boolean flashType = true;

	public boolean getFlashType()
	{
		return flashType;
	}

	public void cfgFlashType(ConfigurationValue cv, boolean val)
	{
	    this.flashType = val;
	}

	public static ConfigurationInfo getFlashTypeInfo()
	{
	    return new ConfigurationInfo()
	    {
	        public boolean isDeprecated()
	        {
	        	return true;
	        }
	        
	        public String getDeprecatedReplacement()
	        {
	        	return "compiler.fonts.advanced-anti-aliasing";
	        }
	        
	        public String getDeprecatedSince()
	        {
	        	//C: Don't change this to VersionInfo.getFlexVersion().
	        	return "3.0";
	        }
	    };
	}

	public void cfgAdvancedAntiAliasing(ConfigurationValue cv, boolean val)
	{
	    cfgFlashType(cv, val);
	}

    //
    // 'compiler.fonts.languages.language-range' option
    //

    private Languages languages = new Languages();

    public Languages getLanguagesConfiguration()
    {
        return languages;
    }

    /**
     * Defines a subconfiguration for font languages.  It contains
     * only a single option, -compiler.fonts.languages.language-range.
     */
    public static class Languages extends Properties
    {
        private static final long serialVersionUID = 7123498355710868760L;

        public void cfgLanguageRange(ConfigurationValue cv, String lang, String range)
        {
            setProperty(lang, range);
        }

        public static ConfigurationInfo getLanguageRangeInfo()
        {
            return new ConfigurationInfo(new String[]{"lang", "range"})
            {
                public boolean allowMultiple()
                {
                    return true;
                }

                public boolean isAdvanced()
                {
                    return true;
                }
            };
        }
    }

    //
    // 'compiler.fonts.local-fonts-snapshot' option
    //

    private VirtualFile localFontsSnapshot = null;
    
    public VirtualFile getLocalFontsSnapshot()
    {
    	return localFontsSnapshot;
    }

    public void cfgLocalFontsSnapshot(ConfigurationValue cv, String localFontsSnapshotPath)
            throws ConfigurationException
    {
        localFontsSnapshot = ConfigurationPathResolver.getVirtualFile(localFontsSnapshotPath, configResolver, cv);
    }
    public static ConfigurationInfo getLocalFontsSnapshotInfo()
    {
        return new AdvancedConfigurationInfo();
    }


    //
    // 'compiler.fonts.local-font-paths' option
    //

    private List<String> resolvedLocalFontPaths;

    public List getLocalFontPaths()
    {
        return resolvedLocalFontPaths;
    }

    public void cfgLocalFontPaths(ConfigurationValue cv, List list)
    {
        resolvedLocalFontPaths = new ArrayList<String>();
        if (list != null)
        {
            Iterator iterator = list.iterator();
            while (iterator.hasNext())
            {
                String path = (String)iterator.next();
                try
                {
                    VirtualFile file = ConfigurationPathResolver.getVirtualFile(path, configResolver, cv);
                    resolvedLocalFontPaths.add(file.getName());
                }
                catch (ConfigurationException ex)
                {
                    // Invalid local font paths are ignored
                }
            }
        }
    }

    public static ConfigurationInfo getLocalFontPathsInfo()
    {
        return new ConfigurationInfo(-1, "path-element")
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    
    //
    // 'compiler.fonts.managers' option
    //
    
    private List managers;

    public List getManagers()
    {
        return managers;
    }

    public void cfgManagers(ConfigurationValue cv, List l)
    {
        managers = l;
    }

    public static ConfigurationInfo getManagersInfo()
    {
        return new ConfigurationInfo(-1, "manager-class")
        {
            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    //
    // 'compiler.fonts.max-cached-fonts' option
    //

    private String max_cached_fonts;

    public String getMaxCachedFonts()
    {
        return max_cached_fonts;
    }

    public void cfgMaxCachedFonts(ConfigurationValue cv, String val)
    {
        this.max_cached_fonts = val;
    }

    public static ConfigurationInfo getMaxCachedFontsInfo()
    {
        return new AdvancedConfigurationInfo();
    }

    //
    // 'compiler.fonts.max-glyphs-per-face' option
    //

    private String max_glyphs_per_face;

    public String getMaxGlyphsPerFace()
    {
        return max_glyphs_per_face;
    }

    public void cfgMaxGlyphsPerFace(ConfigurationValue cv, String val)
    {
        this.max_glyphs_per_face = val;
    }
}
