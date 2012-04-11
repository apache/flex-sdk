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

package flex2.compiler.mxml.rep;

import flash.util.StringJoiner;
import flash.util.StringUtils;
import flex2.compiler.Source;
import flex2.compiler.Transcoder;
import flex2.compiler.abc.MetaData;
import flex2.compiler.as3.MetaDataParser;
import flex2.compiler.common.PathResolver;
import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.media.AbstractTranscoder.UnableToResolve;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.ThreadLocalToolkit;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import macromedia.asc.util.ContextStatics;

/**
 * This class represents an Mxml @Embed(), a CSS Embed(), or a
 * resource bundle Embed().
 */
public class AtEmbed implements LineNumberMapped
{
	private String propName;
	private int lineNumber;
	private Map<String, Object> attributes;
    private boolean strType;

	public AtEmbed(String propName, int lineNumber, Map<String, Object> attrs, boolean strType)
	{
		this.propName = propName;
		this.lineNumber = lineNumber;
		attributes = attrs;
        this.strType = strType;
	}

    private static void addFileAndLine(Map<String, Object> values, String file, int line)
    {
        if (file.indexOf('\\') > -1)
        {
        	values.put(Transcoder.FILE, file.replace('\\', '/'));
        	values.put(Transcoder.PATHSEP, "true");
        }
        else
        {
        	values.put(Transcoder.FILE, file);        	
        }

        values.put(Transcoder.LINE, Integer.toString(line));
    }

	public String getPropName()
	{
		return propName;
	}

    public boolean equals(Object object)
    {
        boolean result = false;

        if (object instanceof AtEmbed)
        {
            result = propName.equals(((AtEmbed) object).propName);
        }

        return result;
    }

    public int hashCode()
    {
        return propName.hashCode();
    }

    /**
     * Used by Velocity templates, so that we don't have to test for
     * instances of AtEmbed and if so, call getPropName().
     */
    public String toString()
    {
        return propName;
    }

	public Map<String, Object> getAttributes()
	{
		return attributes;
	}

	public int getXmlLineNumber()
	{
		return lineNumber;
	}

    public String getType()
    {
        return strType ? "String" : "Class";
    }

	public void setXmlLineNumber(int xmlLineNumber)
	{
		this.lineNumber = xmlLineNumber;
	}
	
    public String codegenEmbedVar()
    {
        String lineSep = System.getProperty("line.separator");
        StringJoiner.ItemStringer itemStringer = new StringJoiner.MapEntryItemWithEquals();
        return "    [Embed(" + StringJoiner.join(getAttributes().entrySet(), ", ", itemStringer) + ")]" + lineSep +
               "    private static var " + getPropName() + ":" + getType() + ";" + lineSep;
    }

    /**
     *
     */
    private static AtEmbed createResolved(ContextStatics perCompileData, Source source, String value, String path, int line, String prefix, boolean logInvalidEmbedOnMissingFile)
    {
        AtEmbed result = null;

        MetaData metaData = MetaDataParser.parse(perCompileData, source, line, value);
        String sourceValue = null;
        Map<String, Object> values = new HashMap<String, Object>();

        // Embed("foo.swf", "barSymbol", ...) or Embed("foo", "image/png", ...)
        if ((metaData.count() > 1) && (metaData.getKey(0) == null) && (metaData.getKey(1) == null))
        {
            sourceValue = metaData.getValue(0);
            String symbolOrMimeType = metaData.getValue(1);

            if (MimeMappings.getExtension(symbolOrMimeType) != null)
            {
                values.put(Transcoder.MIMETYPE, symbolOrMimeType);
            }
            else
            {
                values.put(Transcoder.SYMBOL, symbolOrMimeType);
            }
        }
        // Embed("foo.png", ...)
        else if ((metaData.count() > 0) && (metaData.getKey(0) == null))
        {
            sourceValue = metaData.getValue(0);
        }
        // Embed(skinClass="foo", source="bar.swc")
        else if ((metaData.getValue(Transcoder.SKINCLASS) != null) &&
                 (metaData.getValue(Transcoder.SOURCE) != null))
        {
            logSkinClassWithSourceNotSupported(value, path, line);                
        }
        // Embed(skinClass="foo")
        else if (metaData.getValue(Transcoder.SKINCLASS) != null)
        {
            String skinClass = metaData.getValue(Transcoder.SKINCLASS);
        }
        // Embed(source="foo.png")
        else
        {
            sourceValue = metaData.getValue(Transcoder.SOURCE);
        }

        // logInvalidEmbedOnMissingFile - if 'true', we will logInvalidEmbed(), however
        // in certain scenarios the caller needs to log a different error, so they pass 'false'.
        if (((sourceValue != null) && 
             tokenizeAndResolveSource(sourceValue, values, source, value, path, line, logInvalidEmbedOnMissingFile)) ||
            (metaData.getValue(Transcoder.SKINCLASS) != null))
        {
            for (Iterator it = metaData.getValueMap().entrySet().iterator(); it.hasNext();)
            {
                Map.Entry e = (Map.Entry) it.next();
                String key = (String) e.getKey();

                if (!values.containsKey(key))
                {
                    String val = ((String) e.getValue()).replace('\\', '/');
                    values.put(key, val);
                }
            }

            // Add a hashcode of the asset's path to the sourceValue. We want 
            // an embedded asset's generated class name to be the same no matter
            // which class the asset is embedded into. 
            // Having the same class name for embedded assets allows generated
            // default factories styles between applications and modules to compare as
            // equal. Default factories that are the same are removed to avoid
            // redundant styles.
            if (prefix.equals("_embed_css_"))
            {
                String transcoderSource = (String)values.get(Transcoder.RESOLVED_SOURCE);
                if (transcoderSource != null)
                {
                    sourceValue += "_" + transcoderSource.hashCode();
                }
            }

            // build name of embed-carrier property            
            String propName = AtEmbed.createMangledName(source, sourceValue, false, values, prefix);
            addFileAndLine(values, path, line);
            result = new AtEmbed(propName, line, values, false);
        }

        return result;
    }
    
    /**
     *
     */
    public static AtEmbed create(ContextStatics perCompileData, Source source, String value, int line)
    {
        AtEmbed result = null;
        String path = source.getName();

        try
        {
            result = createResolved(perCompileData, source, value, path, line, "_embed_mxml_", false);
        }
        catch (Exception exception)
        {
        }

        if (result == null)
            logUnableToResolve(value, path, line);

        return result;
    }
    
    /**
     *
     */
    public static AtEmbed create(ContextStatics perCompileData, Source source, String value, String path, int line, String prefix)
    {
        AtEmbed result = null;
        try
        {
            result = createResolved(perCompileData, source, value, path, line, prefix, true);
        }
        catch (Exception exception)
        {
        }

        if (result == null)
            logInvalidEmbed(value, path, line);

        return result;
    }


	/**
	 *
	 */
	public static AtEmbed create(String baseName, Source source, String path, int beginLine,
                                 Map<String, Object> attrs, boolean strType)
	{
		String embedName = AtEmbed.createMangledName(baseName, attrs.hashCode());
        String sourceValue = (String) attrs.get(Transcoder.SOURCE);

        if ((sourceValue != null) &&
            !tokenizeAndResolveSource(sourceValue, attrs, source, sourceValue, path, beginLine, true))
        {
            logInvalidEmbed(sourceValue, path, beginLine);            
        }

		return new AtEmbed(embedName, beginLine, attrs, strType);
	}

	/**
	 * create new AtEmbed instance
	 */
	public static AtEmbed create(ContextStatics perCompileData, Source sourceFile, int beginLine, String value, boolean strType)
	{
		MetaData metaData = MetaDataParser.parse(perCompileData, sourceFile, beginLine, value.substring(1));

		if (metaData == null)
		{
			return null;
		}
		else if (metaData.count() == 0)
		{
			ThreadLocalToolkit.log(new NoEmbedParams(), sourceFile.getNameForReporting(), beginLine);
			return null;
		}

		String source = metaData.getValue("source");
		if (source == null)
		{
			if ((metaData.getKey( 0 ) == null) && (metaData.count() == 1))
				source = metaData.getValue( 0 );
		}

		Map<String, Object> values = getMetaDataMap( metaData );

        // This allows EmbedUtil to have an idea of where the original @Embed lived, so it
        // can properly resolve the source.

		// C: This is actually preventing EmbedEvaluator from adding line/column numbers to the generated
		//    [Embed] metadata. Let's comment this out...
		// values.put(Transcoder.FILE, sourceFile.getName().replace('\\', '/'));

		String embedName = createMangledName(sourceFile, source, strType, values, "_embed_mxml_");
		return new AtEmbed(embedName, beginLine, values, strType);
	}

	/**
	 *
	 */
	private static Map<String, Object> getMetaDataMap(MetaData metaData)
	{
		int len = metaData.count();
		Map<String, Object> values = new HashMap<String, Object>();
		for (int i = 0; i < len; i++)
		{
			String key = metaData.getKey(i);
			String value = metaData.getValue(i);
			if (key == null)
			{
				values.put(Transcoder.SOURCE, value);
			}
			else
			{
				values.put(key, value);
			}
		}
		return values;
	}

	/**
	 * Given Source, path, symbol?, prefix?, produces identifier = [prefix]path[_symbol]_hash
	 * <p>prefix is added as-is, if non-null
	 * <p>hash = absolute value of java String hash of path (resolved if possible) combined with hash of symbol if non-null
	 * <p>result is guaranteed to contain only legal id chars
	 */
	public static String createMangledName(Source source, String path, boolean strType, Map<String, Object> attrs, String prefix)
	{
		StringBuilder buf = new StringBuilder(128);
		if (prefix != null) buf.append(prefix);

        int hash = attrs.hashCode();

        String mimeType = (String) attrs.get(Transcoder.MIMETYPE);

        VirtualFile f = null;
        if (path != null)
        {
            buf.append(path);

		    f = source.resolve(path);
            if (f != null)
                hash ^= f.hashCode();
        }
        else if (mimeType != null)
        {
            buf.append(mimeType);   // bad chars, gets scrubbed below
        }

		String symbol = (String) attrs.get(Transcoder.SYMBOL);
		if (symbol != null)
		{
			buf.append('_');
			buf.append(symbol);
		}

        if (strType)
        {
            buf.append("_s");
        }

		return createMangledName(buf.toString(), hash);
	}

	/**
	 * Given base name and hash, produces scrubbed version of base + "_" + hash
	 * <p>result is guaranteed to contain only legal id chars
	 */
	public static String createMangledName(String name, int hash)
	{
		return StringUtils.replaceAll(name + '_' + java.lang.Math.abs(hash), "[^A-Za-z0-9]", "_");
	}

    private static void logInvalidEmbed(String value, String path, int line)
    {
        InvalidEmbed invalidEmbed = new InvalidEmbed(value);
        invalidEmbed.path = path;
        invalidEmbed.line = line;
        ThreadLocalToolkit.log(invalidEmbed);
    }
    
    private static void logUnableToResolve(String value, String path, int line)
    {
        UnableToResolve unableToResolve = new UnableToResolve(value);
        unableToResolve.path = path;
        unableToResolve.line = line;
        ThreadLocalToolkit.log(unableToResolve);
    }

    private static void logSkinClassWithSourceNotSupported(String value, String path, int line)
    {
        SkinClassWithSourceNotSupported skinClassWithSourceNotSupported = new SkinClassWithSourceNotSupported(value);
        skinClassWithSourceNotSupported.path = path;
        skinClassWithSourceNotSupported.line = line;
        ThreadLocalToolkit.log(skinClassWithSourceNotSupported);
    }

    /**
     * @param owner A SourceList, SourcePath, or FileSpec.
     * @param source The Source for the stylesheet or properties files.
     * @param file The VirtualFile for the stylesheet or properties files.
     * @param sourcePath The 'source' attribute from the Embed's args.
     */
    private static VirtualFile resolveSource(Object owner, Source source, VirtualFile file, String sourcePath)
	{
		PathResolver context = new PathResolver();

        // paths starting with slash are either relative to a source path root or
        // fully qualified.
        if ((sourcePath != null) && (sourcePath.charAt(0) == '/'))
        {
            VirtualFile pathRoot = source.getPathRoot();

            if (pathRoot != null)
            {
                context.addSinglePathResolver(pathRoot);
            }

            if (owner instanceof SinglePathResolver)
            {
                context.addSinglePathResolver((SinglePathResolver) owner);
            }
        }
        else if (file != null)
        {
            context.addSinglePathResolver(file);
        }

        context.addSinglePathResolver(ThreadLocalToolkit.getPathResolver());

        VirtualFile result = context.resolve(sourcePath);

        if (result == null)
        {
            result = source.resolve(sourcePath);
        }

        return result;
	}

    private static boolean tokenizeAndResolveSource(String sourceValue, Map<String, Object> values, Source source,
                                                    String value, String path, int line, boolean logInvalidEmbedOnMissingFile)
    {
        boolean result = true;
        int octothorpe = sourceValue.indexOf('#');

        if (octothorpe != -1)
        {
            values.put(Transcoder.SYMBOL, sourceValue.substring(octothorpe + 1));
            sourceValue = sourceValue.substring( 0, octothorpe );
        }

        VirtualFile file = ThreadLocalToolkit.getPathResolver().resolve(path);
        VirtualFile resolvedFile = resolveSource(source.getOwner(), source, file, sourceValue);

        if (resolvedFile != null)
        {
            String resolvedName = resolvedFile.getName().replace('\\', '/');
            values.put(Transcoder.ORIGINAL, sourceValue);
            values.put(Transcoder.RESOLVED_SOURCE, resolvedName);
            ThreadLocalToolkit.addResolvedPath(resolvedName, resolvedFile);
            values.put(Transcoder.SOURCE, resolvedName);
        }
        else
        {
            if (logInvalidEmbedOnMissingFile) // Preserve legacy behavior to log errors twice
                logInvalidEmbed(value, path, line);
            result = false;
        }

        return result;
    }

	/**
	 * CompilerMessages
	 */
    public static class InvalidEmbed extends CompilerError
    {
        private static final long serialVersionUID = -9221239474314713618L;
        public String source;

        public InvalidEmbed(String source)
        {
            this.source = source;
        }
    }

    public static class SkinClassWithSourceNotSupported extends CompilerError
    {
        private static final long serialVersionUID = 2013999515517670024L;
        public String source;

        public SkinClassWithSourceNotSupported(String source)
        {
            this.source = source;
        }
    }

	public static class NoEmbedParams extends CompilerMessage.CompilerError {

        private static final long serialVersionUID = -4515392639845938644L;}
}
