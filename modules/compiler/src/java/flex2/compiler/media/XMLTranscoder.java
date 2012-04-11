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

import flex2.compiler.common.PathResolver;
import flex2.compiler.SymbolTable;
import flex2.compiler.TranscoderException;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.MimeMappings;

import java.util.Map;
import java.io.BufferedInputStream;
import java.io.Reader;
import java.io.InputStreamReader;

import flash.swf.tags.DefineTag;
import flash.util.FileUtils;

/**
 * Transcodes XML files by wrapping them in an AS3 class which a data
 * variable of type XML.
 *
 * @author Roger Gonzalez
 */
public class XMLTranscoder extends AbstractTranscoder
{
    public final static String ENCODING = "encoding";
    public XMLTranscoder()
    {
        super( new String[] {MimeMappings.XML}, null, false );
    }

    public TranscodingResults doTranscode( PathResolver context, SymbolTable symbolTable,
                                           Map args, String className, boolean generateSource )
        throws TranscoderException
    {
        VirtualFile source = resolveSource( context, args );
        TranscodingResults results = new TranscodingResults(source);

        if (generateSource)
        {
            generateSource( results, className, args );
        }
        else
        {
            throw new EmbedRequiresCodegen( source.getName(), className );
        }

        return results;
    }

    public void generateSource(TranscodingResults asset, String fullClassName, Map embedMap )
            throws TranscoderException
    {
        String encoding = (String) embedMap.get( ENCODING );
        String packageName = "";
        String className = fullClassName;
        int dot = fullClassName.lastIndexOf( '.' );
        if (dot != -1)
        {
            packageName = fullClassName.substring( 0, dot );
            className = fullClassName.substring( dot + 1 );
        }

        StringBuilder source = new StringBuilder( 1024 );
        source.append( "package " );
        source.append( packageName );
        source.append( " { public class " );
        source.append( className );
        source.append( " { public static var data:XML = " );

        BufferedInputStream in = null;

        try
        {
            in = new BufferedInputStream( asset.assetSource.getInputStream() );
            in.mark(3);

			Reader reader = new InputStreamReader(in, FileUtils.consumeBOM(in, encoding));

            char[] line = new char[2000];
            int count = 0;

            while ((count = reader.read(line, 0, line.length)) >= 0)
            {
                source.append(line, 0, count);
            }
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

        source.append( "; } }" );

        asset.generatedCode = source.toString();
    }


    public boolean isSupportedAttribute( String attr )
    {
        return ENCODING.equals( attr );
    }


    public String getAssociatedClass( DefineTag tag )
    {
        return "Object";
    }

    public void clear()
    {
    }

}
