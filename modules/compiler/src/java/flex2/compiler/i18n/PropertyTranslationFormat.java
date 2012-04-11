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

package flex2.compiler.i18n;

import java.util.HashSet;
import java.util.Set;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.io.InputStreamReader;

import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.io.ResourceFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.rep.AtEmbed;
import flex2.compiler.util.MimeMappings;

/**
 * An implemenation of TranslationFormat, which works with .properties files.
 *
 * @author Brian Deitte
 */
public class PropertyTranslationFormat implements TranslationFormat
{
    private String[] mimeTypes;

    public PropertyTranslationFormat()
    {
        mimeTypes = new String[]{MimeMappings.PROPERTIES};
    }

    public boolean isSupported(String mimeType)
    {
        return mimeTypes[0].equals(mimeType);
    }

    public String[] getSupportedMimeTypes()
    {
        return mimeTypes;
    }

    public TranslationInfo getTranslationSet(CompilerConfiguration configuration,
            SymbolTable symbolTable, Source source, String locale, StandardDefs standardDefs)
            throws TranslationException
    {
        final PropertyText p = new PropertyText(configuration, symbolTable, source, locale, standardDefs);
	    Reader r = null;

        try
        {
        	InputStream in = getInputStream(source, locale);
        	if (in != null)
        	{
        		r = new BufferedReader(new InputStreamReader(in, "UTF-8"));
        		p.load(r);
        	}
        }
        catch (IOException ex)
        {
            throw new TranslationException(ex);
        }
        finally
        {
            if (r != null)
            {
                try
                {
                    r.close();
                }
                catch (IOException ex)
                {
                }
            }
        }
        
        return new TranslationInfo()
        {
			public Set getClassReferences()
			{
				return p.imports;
			}

			public Set getEmeds()
			{
				return new HashSet<AtEmbed>(p.atEmbeds.values());
			}

			public Set getTranslationSet()
			{
				return p.entrySet();
			}	
        };
    }
    
    private InputStream getInputStream(Source source, String locale) throws IOException
	{
		ResourceFile f = (ResourceFile) source.getBackingFile();
		f.setLocale(locale);
		return f.getInputStream();
	}
}
