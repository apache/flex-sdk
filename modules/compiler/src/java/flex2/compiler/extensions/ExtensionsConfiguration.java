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

package flex2.compiler.extensions;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import flex2.compiler.common.ConfigurationPathResolver;
import flex2.compiler.common.PathResolver;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.util.ThreadLocalToolkit;

/**
 * This class handles extension specific configuration options.
 * Currently, there is only one, -compiler.extensions.extension.
 *
 * @author Andrew Westberg
 */
public class ExtensionsConfiguration
{
    private ConfigurationPathResolver configResolver;

    public void setConfigPathResolver( ConfigurationPathResolver resolver )
    {
        this.configResolver = resolver;
    }

    private Map<String, List<String>> extensionMappings;

    public Map<String, List<String>> getExtensionMappings()
    {
        if ( extensionMappings == null )
        {
            extensionMappings = new LinkedHashMap<String, List<String>>();
        }
        return extensionMappings;
    }

    public void setExtensionMappings( Map<String, List<String>> extensionMappings )
    {
        this.extensionMappings = extensionMappings;
    }

    //
    // 'compiler.extensions.extension' option
    //

    public File[] getExtension()
    {
        if ( extensionMappings != null )
        {
            return extensionMappings.keySet().toArray( new File[0] );
        }
        else
        {
            return null;
        }
    }

    /**
     * Configures a list of many extensions mapped to a single Extension URI. <extension>
     * <extension>something-extension.jar</extension> <parameters>version=1.1,content=1.2</parameters> </extension>
     * 
     * @param cfgval The configuration value context.
     * @param args A List of values for the Extension element, with the first item expected to be the uri and the
     *            remaining are extension paths.
     * @throws ConfigurationException When no arg is provided or when the jar does not exist.
     */
    public void cfgExtension( ConfigurationValue cfgval, List<String> args )
        throws ConfigurationException
    {
        if ( args == null )
        {
            throw new ConfigurationException.CannotOpen( null, cfgval.getVar(), cfgval.getSource(), cfgval.getLine() );
        }

        PathResolver resolver = ThreadLocalToolkit.getPathResolver();

        if ( resolver == null || configResolver == null )
        {
            throw new ConfigurationException.CannotOpen( null, cfgval.getVar(), cfgval.getSource(), cfgval.getLine() );
        }

        Iterator<String> iterator = args.iterator();
        String extension = iterator.next();

        File file = new File( extension );
        if ( !file.exists() )
        {
            throw new ConfigurationException.NotAFile( extension, cfgval.getVar(), cfgval.getSource(), cfgval.getLine() );
        }

        List<String> parameters = new ArrayList<String>();
        while ( iterator.hasNext() )
        {
            parameters.add( iterator.next() );
        }

        getExtensionMappings().put( file.getAbsolutePath(), parameters );
    }

    public static ConfigurationInfo getExtensionInfo()
    {
        return new ConfigurationInfo( -1, new String[] { "extension", "parameters" } )
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }
}
