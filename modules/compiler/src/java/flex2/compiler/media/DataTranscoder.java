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

import flex2.compiler.SymbolTable;
import flex2.compiler.TranscoderException;
import flex2.compiler.common.PathResolver;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.ThreadLocalToolkit;
import flash.swf.tags.DefineTag;
import flash.swf.tags.DefineBinaryData;

import java.util.Map;
import java.io.BufferedInputStream;

/**
 * This transcoder supports embedding data using a ByteArray.
 *
 * @author Roger Gonzalez
 */
public class DataTranscoder extends AbstractTranscoder
{
    public DataTranscoder()
    {
        super( new String[] {"application/octet-stream"}, null, false );
    }

    public TranscodingResults doTranscode(PathResolver context, SymbolTable symbolTable,
                                           Map<String, Object> args, String className,
                                           boolean generateSource)
        throws TranscoderException
    {
        TranscodingResults results = new TranscodingResults(resolveSource(context, args));
        loadData(results);
        if (generateSource)
            generateSource(results, className, args);
        return results;
    }

    public static void loadData(TranscodingResults asset)
            throws TranscoderException
    {
        DefineBinaryData defineBinaryData = new DefineBinaryData();
        BufferedInputStream in = null;

        try
        {
            in = new BufferedInputStream( asset.assetSource.getInputStream() );

            int size = (int) asset.assetSource.size();
            defineBinaryData.data = new byte[size];

            int r = 0;
            while (r < size)
            {
                int result = in.read( defineBinaryData.data, r, size - r );
                if (result == -1)
                    break;
            }

            asset.defineTag = defineBinaryData;
        }
        catch (Exception e)
        {
            throw new AbstractTranscoder.UnableToReadSource( asset.assetSource.getName() );
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

    public boolean isSupportedAttribute( String attr )
    {
        return false;
    }

    public String getAssociatedClass(DefineTag tag)
    {
        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
        return standardDefs.getCorePackage() + ".ByteArrayAsset";
    }

    public void clear()
    {
    }
}
