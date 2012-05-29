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

import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineButton;
import flash.swf.tags.DefineFont;
import flash.swf.tags.DefineSound;
import flash.swf.tags.DefineSprite;
import flash.swf.tags.DefineTag;
import flash.swf.tags.DefineText;
import flash.util.Trace;
import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.TranscoderException;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.NetworkFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.VelocityManager;

import java.io.StringWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeMap;

import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;

/**
 * This is the default transcoder implementation.  The only thing that
 * a subclass needs to do to override is to give the right information
 * in the constructor and provide an implementation of doTranscode().
 *
 * @author Brian Deitte
 */
public abstract class AbstractTranscoder implements Transcoder
{
    private static final String CODEGEN_TEMPLATE_PATH = "flex2/compiler/as3/";

    // TODO - move these once ImageTranscoder gets refactored
    public static final String SCALE9TOP = "scaleGridTop";
    public static final String SCALE9LEFT = "scaleGridLeft";
    public static final String SCALE9BOTTOM = "scaleGridBottom";
    public static final String SCALE9RIGHT = "scaleGridRight";

    public static final String FONTSTYLE = "fontStyle";
    public static final String FONTWEIGHT = "fontWeight";
    public static final String FONTNAME = "fontName";
    public static final String FONTFAMILY = "fontFamily";

    protected String[] mimeTypes;
    protected Class defineTag;
    protected boolean cacheTags;

    protected Map<String, TranscodingResults> transcodingCache = new HashMap<String, TranscodingResults>();

    public static final String ASSET_TYPE = StandardDefs.PACKAGE_FLASH_DISPLAY + ".DisplayObject";
    
    public AbstractTranscoder(String[] mimeTypes, Class defineTag, boolean cacheTags)
    {
        this.mimeTypes = mimeTypes;
        this.defineTag = defineTag;
        this.cacheTags = cacheTags;
    }

    public boolean isSupported(String mimeType)
    {
        for (int i = 0; i < mimeTypes.length; i++)
        {
            if (mimeTypes[i].equalsIgnoreCase(mimeType))
            {
                return true;
            }
        }
        return false;
    }

    public TranscodingResults transcode(PathResolver context, SymbolTable symbolTable,
                                         Map<String, Object> args, String className,
                                         boolean generateSource)
            throws TranscoderException
    {
        for (Iterator<String> it = args.keySet().iterator(); it.hasNext();)
        {
            String attr = it.next();
            if (attr.startsWith( "_") || Transcoder.SOURCE.equalsIgnoreCase( attr ) || Transcoder.MIMETYPE.equalsIgnoreCase( attr ) || Transcoder.NEWNAME.equalsIgnoreCase( attr ))
            {
                continue;
            }
            if (!Transcoder.ORIGINAL.equals(attr) && !isSupportedAttribute( attr ))
            {
                throw new UnsupportedAttribute( attr, getClass().getName() );
            }
        }

        String cacheKey = null;

        TranscodingResults results = null;

        if (cacheTags)
        {
            cacheKey = getCacheKey( args );
            results = transcodingCache.get( cacheKey );
        }

        if (results == null)
        {
            results = doTranscode(context, symbolTable, args, className, generateSource);

            if (cacheTags)
            {
	            // reget the cacheKey, since RESOLVED_SOURCE could have been added to the args
	            cacheKey = getCacheKey( args );
                transcodingCache.put(cacheKey, results);
            }
        }
        else if (Trace.embed)
        {
            Trace.trace("Found cached DefineTag for " + cacheKey);
        }

        return results;
    }

    private String getCacheKey(Map<String, Object> args)
    {
        TreeMap<String, Object> m = new TreeMap<String, Object>( args );
        String key = "" + m.hashCode();

        if (Trace.embed)
        {
            key += "_" + m.toString();  // TODO: don't hard-code key
        }

        return key;
    }

    public VirtualFile resolve( PathResolver context, String path ) throws TranscoderException
    {
        String p = path;
        if (path.startsWith( "file:"))
            p = p.substring( "file:".length() );    // hate hate hate hate

        VirtualFile f = context.resolve( p );
        if (f == null)
        {
            throw new UnableToResolve( path );
        }
        if (f instanceof NetworkFile)
        {
            throw new NetworkTranscodingSource( path );
        }
        return f;
    }

    public VirtualFile resolveSource( PathResolver context, Map args ) throws TranscoderException
    {
        VirtualFile result = null;
        String resolvedSource = (String) args.get( Transcoder.RESOLVED_SOURCE );

        if (resolvedSource != null)
        {
            result = ThreadLocalToolkit.getResolvedPath(resolvedSource);
        }

        if (result == null)
        {
            String source = (String) args.get( Transcoder.SOURCE );

            if (source == null)
            {
                throw new MissingSource();
            }

            result = resolve( context, source );
        }

        return result;
    }

    public abstract TranscodingResults doTranscode(PathResolver context, SymbolTable symbolTable,
                                                    Map<String, Object> args, String className,
                                                    boolean generateSource)
        throws TranscoderException;

    public abstract boolean isSupportedAttribute(String attr);

    public String getAssociatedClass(DefineTag tag)
    {
        if (tag == null)
        {
            return null;
        }

        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();

        String cls = null;
        String SKIN_SPRITE = standardDefs.getCorePackage() + ".SpriteAsset";

        if (tag instanceof DefineButton)
            cls = standardDefs.getCorePackage() + ".ButtonAsset";
        else if (tag instanceof DefineFont)
            cls = standardDefs.getCorePackage() + ".FontAsset";
        else if (tag instanceof DefineText)
            cls = standardDefs.getCorePackage() + ".TextFieldAsset";
        else if (tag instanceof DefineSound)
            cls = standardDefs.getCorePackage() + ".SoundAsset";
        else if (tag instanceof DefineBits)
            cls = standardDefs.getCorePackage() + ".BitmapAsset";
        else if (tag instanceof DefineSprite)
            cls = standardDefs.getCorePackage() + ".SpriteAsset";

        if (cls != null && (defineTag == null || defineTag.isAssignableFrom(tag.getClass())))
        {
            if (((tag instanceof DefineSprite) && ((DefineSprite)tag).framecount > 1) && (cls.equals( SKIN_SPRITE )))
            {
                cls = standardDefs.getCorePackage() + ".MovieClipAsset";
            }
            return cls;
        }

        if (defineTag == null)
        {
            if (Trace.embed)
            {
                Trace.trace("Couldn't find a matching class, so associating " + tag + " with " + SKIN_SPRITE);
            }
            return SKIN_SPRITE;
        }
        else
        {
            return null;
        }
    }

    public void clear()
    {
        if (transcodingCache.size() != 0)
        {
            transcodingCache = new HashMap<String, TranscodingResults>();
        }
    }
    
    public void generateSource(TranscodingResults asset, String fullClassName, Map<String, Object> embedMap)
    		throws TranscoderException
    {
    	generateSource(asset, fullClassName, embedMap, new HashMap());
    }

    public void generateSource(TranscodingResults asset, String fullClassName, Map<String, Object> embedMap, Map embedProps)
            throws TranscoderException
    {
        String baseClassName = getAssociatedClass(asset.defineTag);
        String packageName = "";
        String className = fullClassName;
        int dot = fullClassName.lastIndexOf( '.' );
        if (dot != -1)
        {
            packageName = fullClassName.substring( 0, dot );
            className = fullClassName.substring( dot + 1 );
        }

	    if (asset.assetSource != null)
	    {
            String path = asset.assetSource.getName().replace('\\', '/');
            embedMap.put(Transcoder.RESOLVED_SOURCE, path);
            ThreadLocalToolkit.addResolvedPath(path, asset.assetSource);
	    }

        try
        {
            StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();

            String templateName = standardDefs.getEmbedClassTemplate();
            Template template = VelocityManager.getTemplate(CODEGEN_TEMPLATE_PATH + templateName);
            if (template == null)
            {
                throw new TemplateException( templateName );
            }

            VelocityContext velocityContext = VelocityManager.getCodeGenContext();
            velocityContext.put( "packageName", packageName );
            velocityContext.put( "baseClass", baseClassName );
            if (embedProps.size() != 0)
            {
            	velocityContext.put("assetType", ASSET_TYPE );
            }
            velocityContext.put( "embedClass", className );
            velocityContext.put( "embedMap", embedMap );
        	velocityContext.put( "embedProps", embedProps );

            StringWriter stringWriter = new StringWriter();

            template.merge(velocityContext, stringWriter);
            // once we figure out a non-AS2 way to call stop, add this and put the generated code in EmbedClass.vm
            //velocityContext.put("needsStop", "" + (data.defineTag instanceof DefineSprite && ((DefineSprite)data.defineTag).needsStop));

            //long t2 = System.currentTimeMillis();
            //VelocityManager.parseTime += t2 - start;
            //VelocityManager.mergeTime += System.currentTimeMillis() - t2;

            asset.generatedCode = stringWriter.toString();

        }
        catch (Exception e)
        {
            if (Trace.error)
            {
                e.printStackTrace();
            }
            throw new UnableToGenerateSource( fullClassName );
        }
    }

    public static class TemplateException extends TranscoderException
    {
        private static final long serialVersionUID = 5180630712564309116L;
        
        public TemplateException( String templateName )
        {
            this.templateName = templateName;
        }
        public String templateName;
    }
    public static class SourceException extends TranscoderException
    {
        private static final long serialVersionUID = -6720698044756027846L;
        
        public SourceException( String className )
        {
            this.className = className;
        }
        public String className;
    }

    public static class UnsupportedAttribute extends TranscoderException
    {
        private static final long serialVersionUID = -5367245871779383272L;
        
        public UnsupportedAttribute( String attribute, String className )
        {
            this.attribute = attribute;
            this.className = className;
        }
        public String attribute;
        public String mimeType;
        public String className;
    }

    public static class UnableToResolve extends TranscoderException
    {
        private static final long serialVersionUID = 3955870312641262226L;
        
        public UnableToResolve( String source )
        {
            this.source = source;
        }
        public String source;
    }
    public static class NetworkTranscodingSource extends TranscoderException
    {
        private static final long serialVersionUID = 1258842409489634129L;
        
        public NetworkTranscodingSource( String url )
        {
            this.url = url;
        }
        public String url;
    }

    public static class MissingSource extends TranscoderException
    {
        private static final long serialVersionUID = -3672019858278058644L;
    }

    public static class UnableToGenerateSource extends TranscoderException
    {
        private static final long serialVersionUID = 5252588163882319246L;

        public UnableToGenerateSource( String className )
        {
            this.className = className;
        }
        public String className;
    }

    public static class UnableToReadSource extends TranscoderException
    {
        private static final long serialVersionUID = 157159356418747799L;
        
        public UnableToReadSource( String source )
        {
            this.source = source;
        }
        public String source;
    }

    public static class ExceptionWhileTranscoding extends TranscoderException
    {
        private static final long serialVersionUID = 3747245123304883388L;
        
        public ExceptionWhileTranscoding( Exception exception )
        {
            this.exception = exception.getMessage();
        }
        public String exception;
    }

    public static class EmbedRequiresCodegen extends TranscoderException
    {
        private static final long serialVersionUID = -1154861048587818696L;
        
        public EmbedRequiresCodegen( String source, String className )
        {
            this.source = source;
            this.className = className;
        }
        public String source;
        public String className;
    }

    public static final class IncompatibleTranscoderParameters extends TranscoderException
    {
        private static final long serialVersionUID = 5674351726161323512L;
        
        public IncompatibleTranscoderParameters( String param1, String param2 )
        {
            this.param1 = param1;
            this.param2 = param2;
        }
        public String param1;
        public String param2;
    }
}
