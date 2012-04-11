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

package flex2.compiler.media;

import flash.css.LocalSource;
import flash.css.URLSource;
import flash.fonts.FontDescription;
import flash.fonts.FontFace;
import flash.fonts.FontManager;
import flash.swf.TagValues;
import flash.swf.tags.DefineFont;
import flash.util.Trace;
import flex2.compiler.ILocalizableMessage;
import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.TranscoderException;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.FontsConfiguration;
import flex2.compiler.common.MxmlConfiguration;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.ThreadLocalToolkit;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.net.URL;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Transcodes fonts into DefineFont SWF tags for embedding.
 *
 * @author Roger Gonzalez
 */
public class FontTranscoder extends AbstractTranscoder
{
    private FontsConfiguration fontsConfig;
    private int compatibilityVersion;
    private boolean showShadowedDeviceFontWarnings;

    public FontTranscoder( Configuration config )
    {
        super(new String[]{MimeMappings.TTF, MimeMappings.OTF, MimeMappings.FONT, MimeMappings.TTC, MimeMappings.DFONT}, DefineFont.class, true);
        CompilerConfiguration compilerConfig = config.getCompilerConfiguration();
        fontsConfig = compilerConfig.getFontsConfiguration();
        compatibilityVersion = compilerConfig.getCompatibilityVersion();
        showShadowedDeviceFontWarnings = compilerConfig.showShadowedDeviceFontWarnings();
    }

    public static final String UNICODERANGE = "unicodeRange";
    public static final String SYSTEMFONT = "systemFont";
    public static final String SOURCELIST = "sourceList";
	public static final String FLASHTYPE = "flashType";
	public static final String ADVANTIALIASING = "advancedAntiAliasing";
	public static final String EMBEDASCFF = "embedAsCFF";

    public boolean isSupportedAttribute( String attr )
    {
        return FONTNAME.equals( attr )
               || FONTSTYLE.equals( attr )
               || FONTWEIGHT.equals( attr )
               || FONTFAMILY.equals( attr )
               || UNICODERANGE.equals( attr )
		       || FLASHTYPE.equals( attr )		        
		       || ADVANTIALIASING.equals( attr )		        
               || SYSTEMFONT.equals( attr )
               || SOURCELIST.equals( attr )
               || EMBEDASCFF.equals( attr );
    }

    public TranscodingResults doTranscode( PathResolver context, SymbolTable symbolTable,
                                           Map<String, Object> args, String className, boolean generateSource )
            throws TranscoderException
    {
        TranscodingResults results = new TranscodingResults();
        String systemFont = null;
        List<Serializable> locations;

        if (args.containsKey( SOURCE ))
        {
            if (args.containsKey( SYSTEMFONT ) || args.containsKey( SOURCELIST ))
                throw new BadParameters();

            results.assetSource = resolveSource( context, args );
            results.modified = results.assetSource.getLastModified();
            locations = new LinkedList<Serializable>();
            locations.add( getURL(results.assetSource) );
        }
        else if (args.containsKey( SYSTEMFONT ))
        {
            if (args.containsKey( SOURCE ) || args.containsKey( SOURCELIST ))
                throw new BadParameters();

            systemFont = (String) args.get( SYSTEMFONT );
            locations = new LinkedList<Serializable>();
            locations.add(systemFont);
        }
        else if (args.containsKey( SOURCELIST ))
        {
            locations = resolveSourceList(context, args);
        }
        else
        {
            throw new BadParameters();
        }

        String family = (String) args.get( FONTFAMILY );
        String alias = (String) args.get( FONTNAME );
        if (alias == null)
        {
            alias = systemFont;
        }
        if (alias == null)
        {
            alias = family;     // FIXME, just either name it name or family, not both!
        }
        if (alias == null)
        {
            throw new BadParameters();
        }

        if (systemFont != null && systemFont.equals(alias) && showShadowedDeviceFontWarnings)
        {
            EmbeddedFontShadowsDeviceFont embeddedFontShadowsDeviceFont = new EmbeddedFontShadowsDeviceFont(alias);
            String path = (String) args.get(Transcoder.FILE);
            String pathSep = (String) args.get(Transcoder.PATHSEP);
            if ("true".equals(pathSep))
            {
                path = path.replace('/', '\\');
            }
            embeddedFontShadowsDeviceFont.path = path;
            if (args.containsKey(Transcoder.LINE))
            {
                int line = Integer.parseInt( (String) args.get(Transcoder.LINE) );
                embeddedFontShadowsDeviceFont.line = line;
            }
            ThreadLocalToolkit.log(embeddedFontShadowsDeviceFont);
        }

        //String newName = (String) args.get( NEWNAME );          // fixme - export name is always font name?

        FontDescription fontDesc = new FontDescription();
        fontDesc.alias = alias;
        fontDesc.style = getFontStyle(args);
        fontDesc.unicodeRanges = (String)args.get(UNICODERANGE);
        fontDesc.advancedAntiAliasing = useAdvancedAntiAliasing(args);
        fontDesc.compactFontFormat = useCompactFontFormat(args, compatibilityVersion);

        DefineFont defineFont = getDefineFont(fontDesc, locations, args);

        try
        {
            results.defineTag = defineFont;
            if (generateSource)
                generateSource(results, className, args);
        }
        catch (TranscoderException te)
        {
	        throw te;
        }
        catch (Exception e)
        {
	        if (Trace.error)
		        e.printStackTrace();

            throw new ExceptionWhileTranscoding( e );
        }
        return results;
    }

    private URL getURL(VirtualFile virtualFile) throws TranscoderException
    {
        URL result;

        if (!(virtualFile instanceof LocalFile))
        {
            InputStream in = null;
            
            try
            {
                String name = virtualFile.getName();
                String path = name.substring(name.indexOf("$") + 1);
                // The path might look like "assets/fonts/Arial.ttf"
                // and slash isn't allowed in temp file names, so
                // convert them to underscore.
                File file = File.createTempFile(path.replace('/', '_'), null);
                in = virtualFile.getInputStream();
                FileUtil.writeBinaryFile(file, in);
                result = file.toURL();
            }
            catch (IOException ioException)
            {
                if (Trace.error)
                {
                    ioException.printStackTrace();
                }

                throw new UnableToExtract( virtualFile.getName() );
            }
            finally
            {
                try
                {
                    if (in != null)
                        in.close();
                }
                catch (Throwable t)
                {
                }
            }
        }
        else
        {
            try
            {
                result = new URL(virtualFile.getURL());
            }
            catch (java.net.MalformedURLException e)
            {
                throw new AbstractTranscoder.UnableToReadSource( virtualFile.getName() );
            }
        }

        return result;
    }

    private DefineFont getDefineFont(FontDescription fontDesc,
            List<Serializable> locations, Map<String, Object> args) throws TranscoderException
    {
        FontManager fontManager = fontsConfig.getTopLevelManager();
        int defineFontTag = TagValues.stagDefineFont3;

        DefineFont defineFont = null;
        for (Iterator<Serializable> it = locations.iterator(); it.hasNext();)
        {
            Object fontSource = it.next();

            try
            {
                // For now, keep the Flex 3 behavior of throwing errors for each 
                // location when no FontManager exists.
                if (fontManager == null)
                    throw new NoFontManagerException();

                fontDesc.source = fontSource;
                defineFont = fontManager.createDefineFont(defineFontTag, fontDesc);
            }
            catch (FontManager.InvalidUnicodeRangeException e)
            {
                // For now, keep the Flex 3 error message for invalid unicode
                // ranges...
                throw new InvalidUnicodeRangeException(e.range);
            }
            catch (Exception e)
            {
	            if (Trace.error)
	            {
		            e.printStackTrace();
	            }

                ExceptionWhileTranscoding exceptionWhileTranscoding = new ExceptionWhileTranscoding(e);
                String path = (String) args.get(Transcoder.FILE);
                String pathSep = (String) args.get(Transcoder.PATHSEP);
                if ("true".equals(pathSep))
                {
                    path = path.replace('/', '\\');
                }
                exceptionWhileTranscoding.path = path;
                if (args.containsKey(Transcoder.LINE))
                {
                    int line = Integer.parseInt( (String) args.get(Transcoder.LINE) );
                    exceptionWhileTranscoding.line = line;
                }
                ThreadLocalToolkit.log(exceptionWhileTranscoding);
            }

            if (defineFont != null)
            {
                return defineFont;
            }
        }

        throw new UnableToBuildFont(fontDesc.alias);
    }

    private List<Serializable> resolveSourceList(PathResolver context,
            Map<String, Object> args) throws TranscoderException
    {
        List<Serializable> result = new LinkedList<Serializable>();

        Iterator iterator = ((List) args.get( SOURCELIST )).iterator();

        while ( iterator.hasNext() )
        {
            Object source = iterator.next();

            if (source instanceof URLSource)
            {
                URLSource urlSource = (URLSource) source;
                VirtualFile virtualFile = resolve(context, urlSource.getValue());
                result.add( getURL(virtualFile) );
            }
            else // if (source instanceof LocalSource)
            {
                LocalSource localSource = (LocalSource) source;
                result.add( localSource.getValue() );
            }
        }

        return result;
    }

    /**
     * Determines whether advanced anti-aliasing information should be included
     * in the font definition. The term 'Flash Type' is obsolete.
     */
    private boolean useAdvancedAntiAliasing(Map<String, Object> args)
        throws TranscoderException
    {
        boolean useAdvanced = true;
        boolean flashTypeAsName = true;
        String advancedStr = (String)args.get(ADVANTIALIASING);
        if (advancedStr == null)
        {
            advancedStr = (String)args.get(FLASHTYPE);
        }
        else
        {
            flashTypeAsName = false;
        }

        if (advancedStr != null)
        {
            if (advancedStr.equalsIgnoreCase("true"))
            {
                useAdvanced = true;
            }
            else if (advancedStr.equalsIgnoreCase("false"))
            {
                useAdvanced = false;
            }
            else if (flashTypeAsName)
            {
                throw new BadFlashType();
            }
            else
            {
                throw new BadAdvancedAntiAliasing();
            }
        }
        else
        {
            useAdvanced = fontsConfig.getFlashType();
        }

        return useAdvanced;
    }

    /**
     * The CFF flag determines whether font information should be embedded in
     * the Compact Font Format using SWF tag DefineFont4. 
     */
    private static boolean useCompactFontFormat(Map<String, Object> args, 
        int compatibilityVersion)
    {
        String value = (String)args.get(EMBEDASCFF);
        
        boolean useCFF = true;
        if (compatibilityVersion < MxmlConfiguration.VERSION_4_0)
            useCFF = false;
        
        if (value != null)
        {
            useCFF  = Boolean.parseBoolean(value.trim());
        }

        return useCFF;
    }

    public static int getFontStyle(Map<String, Object> args)
    {
        int s = FontFace.PLAIN;

        String style = (String) args.get( FONTSTYLE );
        if (style == null)
            style = "normal";

        String weight = (String) args.get( FONTWEIGHT );
        if (weight == null)
            weight = "normal";

        if (isBold( weight ))
            s += FontFace.BOLD;

        if (isItalic( style ))
            s += FontFace.ITALIC;

        return s;
    }

    public static boolean isBold(String value)
    {
        boolean bold = false;

        if (value != null)
        {
            String b = value.trim().toLowerCase();
            if (b.startsWith("bold"))
            {
                bold = true;
            }
            else
            {
                try
                {
                    int w = Integer.parseInt(b);
                    if (w >= 700)
                        bold = true;
                }
                catch (Throwable t)
                {
                }
            }
        }

        return bold;
    }

    public static boolean isItalic(String value)
    {
        boolean italic = false;

        if (value != null)
        {
            String ital = value.trim().toLowerCase();
            if (ital.equals("italic") || ital.equals("oblique"))
                italic = true;
        }

        return italic;
    }


    public static final class NoFontManagerException extends RuntimeException
    {
        private static final long serialVersionUID = 755054716704678420L;

        public NoFontManagerException()
        {
            super("No FontManager provided. Cannot build font.");
        }
    }

    public static final class InvalidUnicodeRangeException extends TranscoderException
    {
        private static final long serialVersionUID = 3173208110428813980L;
        public InvalidUnicodeRangeException(String range)
        {
            this.range = range;
        }
        public String range;
    }

    public static final class BadParameters extends TranscoderException
    {
        private static final long serialVersionUID = -2390481014380505531L;
    }

	public static final class BadFlashType extends TranscoderException
	{
        private static final long serialVersionUID = 3971519462447951564L;
	}

	public static final class BadAdvancedAntiAliasing extends TranscoderException
	{
        private static final long serialVersionUID = 8425867739365188050L;
	}

    public static final class UnableToBuildFont extends TranscoderException
    {
        private static final long serialVersionUID = 1520596054636875393L;
        public UnableToBuildFont( String fontName )
        {
            this.fontName = fontName;
        }
        public String fontName;
    }

    public static final class UnableToExtract extends TranscoderException
    {
        private static final long serialVersionUID = -4585845590777360978L;
        public UnableToExtract( String fileName )
        {
            this.fileName = fileName;
        }
        public String fileName;
    }

    public static final class EmbeddedFontShadowsDeviceFont extends CompilerMessage.CompilerWarning implements ILocalizableMessage
    {
        private static final long serialVersionUID = -1125821048682931471L;
        public EmbeddedFontShadowsDeviceFont( String alias )
        {
            this.alias = alias;
        }
        public final String alias;
    }
}

