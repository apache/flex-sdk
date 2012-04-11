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

package flex2.compiler.as3;

import flash.util.Trace;
import flex2.compiler.AssetInfo;
import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.TranscoderException;
import flex2.compiler.common.LocalFilePathResolver;
import flex2.compiler.common.PathResolver;
import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.List;
import java.util.Map;
import java.util.Iterator;

/**
 * This class contains utility methods used to transcode embedded
 * assets.
 *
 * @author Brian Deitte
 */
public class EmbedUtil
{
    public static Transcoder.TranscodingResults transcode(Transcoder[] transcoders,
                                                          CompilationUnit unit, SymbolTable symbolTable,
                                                          String className, Map<String, Object> args, int line, int col,
                                                          boolean generateCode)
    {
		PathResolver context = new PathResolver();
		Transcoder.TranscodingResults results = null;
        Source source = unit.getSource();

        if (!args.containsKey(Transcoder.RESOLVED_SOURCE))
        {
            String embedSource = (String) args.get(Transcoder.SOURCE);

            // paths starting with slash are either relative to a source path root or
            // fully qualified.
            if (embedSource != null && embedSource.charAt(0) == '/')
            {
                VirtualFile pathRoot = source.getPathRoot();
                if (pathRoot != null)
                {
                    context.addSinglePathResolver(pathRoot);
                }
                Object owner = source.getOwner();
                if (owner instanceof SinglePathResolver)
                {
                    context.addSinglePathResolver((SinglePathResolver) owner);
                }
            }
            else
            {
                if ( args.containsKey(Transcoder.FILE) )
                {
                	String path = (String) args.get(Transcoder.FILE);
                	String pathSep = (String) args.get(Transcoder.PATHSEP);
                	if ("true".equals(pathSep))
                	{
                		path = path.replace('/', '\\');
                	}
                	
                    VirtualFile contextFile = LocalFilePathResolver.getSingleton().resolve(path);

                    // If the contextFile is the same as the Source's file, then don't add
                    // it as a path resolver, because we'll rely on the Source's
                    // delegate/backing file.  If we don't do this, then some relative
                    // paths might incorrectly be resolved relative to the generated .as
                    // file, instead of the original mxml file.
                    if ((contextFile != null) && !contextFile.getName().equals(source.getName()))
                    {
                        context.addSinglePathResolver(contextFile);
                    }
                }

                VirtualFile backingFile = source.getBackingFile();

                if (backingFile != null)
                {
                    context.addSinglePathResolver(backingFile);
                }
            }
            context.addSinglePathResolver( ThreadLocalToolkit.getPathResolver() );
        }
        else
        {
            // This is necessary to handle FlexInit's Embeds, because
            // FlexInit is recompiled any time something changes in an
            // incremental compilation and the original document might
            // not have needed to be recompiled, so the resolved
            // VirtualFile won't be cached in the ThreadLocalToolkit.
            // The LocalFilePathResolver should be sufficient to turn
            // the resolved path into a VirtualFile.
            context.addSinglePathResolver(LocalFilePathResolver.getSingleton());
        }

		if (!unit.hasAssets() || !unit.getAssets().contains(className))
		{
            results = transcode(transcoders, symbolTable, className, args, line, col, generateCode, source, context);
 			if (results != null) // else there was an error
   			{
 			    if (results.defineTag != null) // else its a pure-code asset
 			    {
   				    unit.getAssets().add(className, new AssetInfo(results.defineTag, 
   				           results.assetSource, results.modified, args));
 			    }

   				// Look for additional assets
 			    List<Transcoder.TranscodingResults> additionalAssets = results.additionalAssets;
   				if (additionalAssets != null)
   				{
   				    for (int i = 0; i < additionalAssets.size(); i++)
   				    {
   				        Transcoder.TranscodingResults asset = additionalAssets.get(i);
   				        if (asset.defineTag != null)
   				            unit.getAssets().add(asset.className, new AssetInfo(asset.defineTag, results.assetSource, results.modified, args));
   				    }
   				}
   			}
        }
        else
		{
			assert false : "Asset already added for " + className;
		}

		return results;
	}

    // Flex Builder is using this temporarily.
    public static Transcoder.TranscodingResults transcode(Transcoder[] transcoders, String className,
                                                          Map<String, Object> args, int line, int col,
                                                          boolean generateCode, Source s,
                                                          PathResolver context)
    {
        return transcode(transcoders, null, className, args, line, col, generateCode, s, context);
    }

    private static Transcoder.TranscodingResults transcode(Transcoder[] transcoders, SymbolTable symbolTable,
                                                           String className, Map<String, Object> args, int line, int col,
                                                           boolean generateCode, Source s,
                                                           PathResolver context)
    {
        String request = formatTranscodeRequest( args );
        Transcoder.TranscodingResults results = null;
        // Brian: one thing that we could still try here for performance is to have a switch that allows the className
        // that is passed in to be overriden.  For mxml and var level Embeds this could happen.  When this is allowed,
        // if we have already transcoded the given source location (as found out from a source->defineTag cache),
        // we could just return this location as well as the new className that should be used

        String mimeType = (String) args.get( Transcoder.MIMETYPE );
        String origin = (String) args.get( Transcoder.FILE );
        String pathSep = (String) args.get( Transcoder.PATHSEP );
        if ("true".equals(pathSep))
        {
        	origin = origin.replace('/', '\\');
        }
        String nameForReporting = "";

        long mem = -1;
        if (Trace.embed)
        {
            Trace.trace("Transcoding " + request);
            if (ThreadLocalToolkit.getBenchmark() != null)
            {
	            ThreadLocalToolkit.getBenchmark().startTime("Transcoded " + request);
	            mem = ThreadLocalToolkit.getBenchmark().peakMemoryUsage(false);
            }
        }

        try
        {
            if (s != null)
            {
                if (origin == null)
                    origin = s.getName();

                nameForReporting = s.getNameForReporting();
            }

            if (mimeType == null)
            {
                if (args.containsKey(Transcoder.SOURCE))
                {
                    String source = (String) args.get( Transcoder.SOURCE );

                    // this is wrong for network URLs, but it solves a chicken and egg problem with
                    // moving the source processing down to the child transcoders
                    mimeType = MimeMappings.getMimeType( source );

                    if (mimeType == null)
                    {
                        logTranscoderException(new TranscoderException.UnrecognizedExtension(request), nameForReporting, line, col);
                        return null;
                    }
                }
                else if (args.containsKey(Transcoder.SKINCLASS))
                {
                    mimeType = MimeMappings.SKIN;
                }
            }

            Transcoder t = getTranscoder(transcoders, mimeType);

            if (t == null)
            {
                logTranscoderException(new TranscoderException.NoMatchingTranscoder(mimeType), nameForReporting, line, col);
            }
            else
            {
                if (!args.containsKey( Transcoder.SYMBOL ) &&
                    !args.containsKey( Transcoder.NEWNAME )) // FIXME - this should probably go away, no exports in fp9
                {
                    args.put( Transcoder.NEWNAME, className );
                }

                // put the transcoding output into the compilation unit
                results = t.transcode( context, symbolTable, args, className, generateCode );
            }
        }
        catch(TranscoderException transcoderException)
        {
            logTranscoderException(transcoderException, origin, line, col);
        }

        if (Trace.embed)
        {
	        if (ThreadLocalToolkit.getBenchmark() != null)
	        {
		        ThreadLocalToolkit.getBenchmark().stopTime("Transcoded " + request);
	        }

            if (mem != -1 && ThreadLocalToolkit.getBenchmark() != null)
            {
                long endMem = ThreadLocalToolkit.getBenchmark().peakMemoryUsage(false);
                Trace.trace("Increase in peak memory from transcoding: " + (endMem - mem) + " MB");
            }
        }

        return results;
    }

    public static Transcoder getTranscoder(Transcoder[] transcoders, String mimeType)
    {
        assert transcoders != null;
        for (int i = 0; i < transcoders.length; ++i)
        {
            if (transcoders[i].isSupported(mimeType))
            {
                return transcoders[i];
            }
        }

        return null;
    }

    public static String formatTranscodeRequest( Map<String, Object> args )
    {
        String s = (String) args.get( Transcoder.SOURCE );

        if (s != null)
            return s;

        s = "[";
        for (Iterator it = args.entrySet().iterator(); it.hasNext();)
        {
            Map.Entry e = (Map.Entry) it.next();
            s += (e.getKey() + "='" + e.getValue() + "'");
            if (it.hasNext()) s += ", ";
        }
        s += "]";
        return s;
    }

    public static void logTranscoderException(TranscoderException transcoderException, String path, int line, int column)
    {
        transcoderException.path = path;
        transcoderException.line = line;
        transcoderException.column = column;
        ThreadLocalToolkit.log(transcoderException);
    }
}
