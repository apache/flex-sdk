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

import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Iterator;

/**
 * This class handles namespace specific configuration options.
 *
 * @author Clement Wong
 */
public class NamespacesConfiguration
{
    private ConfigurationPathResolver configResolver;

    public void setConfigPathResolver( ConfigurationPathResolver resolver )
    {
        this.configResolver = resolver;
    }

    private Map<String, List<VirtualFile>> manifestMappings;

    public Map<String, List<VirtualFile>> getManifestMappings()
    {
        return manifestMappings;
    }

    public void setManifestMappings(Map<String, List<VirtualFile>> manifestMappings)
    {
        this.manifestMappings = manifestMappings;
    }

    //
    // 'compiler.namespaces.namespace' option
    //

    public VirtualFile[] getNamespace()
    {
        if (manifestMappings != null)
        {
            List<VirtualFile> fileList = new ArrayList<VirtualFile>();

            Iterator<List<VirtualFile>> iterator = manifestMappings.values().iterator();
            while (iterator.hasNext())
            {
                List<VirtualFile> files = iterator.next();
                if (files != null)
                {
                    Iterator<VirtualFile> f = files.iterator();
                    while ( f.hasNext())
                    {
                        fileList.add(f.next());
                    }
                }
            }

            VirtualFile[] fileArray = new VirtualFile[fileList.size()];
            return fileList.toArray(fileArray);
        }
        else
        {
            return null;
        }
    }

    /**
     * Configures a list of many manifests mapped to a single namespace URI.
     * 
     * <namespace>
     *     <uri>library:adobe/flex/something</uri>
     *     <manifest>something-manifest.xml</manifest>
     *     <manifest>something-else-manifest.xml</manifest>
     *     ...
     * </namespace>
     *  
     * @param cfgval The configuration value context.
     * @param args A List of values for the namespace element, with the first
     * item expected to be the uri and the remaining are manifest paths.
     * @throws ConfigurationException
     */
    public void cfgNamespace(ConfigurationValue cfgval, List<String> args)
        throws ConfigurationException
    {
        if (args == null)
        {
            throw new ConfigurationException.CannotOpen(null, cfgval.getVar(), cfgval.getSource(), cfgval.getLine());
        }

        if (args.size() < 2)
        {
            throw new ConfigurationException.NamespaceMissingManifest("namespace", cfgval.getSource(), cfgval.getLine());
        }

        PathResolver resolver = ThreadLocalToolkit.getPathResolver();
        assert resolver != null && configResolver != null: "Path resolvers must be set before calling this method.";
        if (resolver == null || configResolver == null)
        {
            throw new ConfigurationException.CannotOpen(null, cfgval.getVar(), cfgval.getSource(), cfgval.getLine() );
        }

        String uri = null;

        Iterator<String> iterator = args.iterator();
        while (iterator.hasNext())
        {
            if (uri == null)
            {
                uri = iterator.next();
            }
            else
            {
                String manifest = iterator.next();

                VirtualFile file = ConfigurationPathResolver.getVirtualFile(manifest, configResolver, cfgval);

                if (manifestMappings == null)
                    manifestMappings = new LinkedHashMap<String, List<VirtualFile>>();

                List<VirtualFile> files = manifestMappings.get(uri);
                if (files == null)
                    files = new ArrayList<VirtualFile>();
                files.add(file);

                manifestMappings.put(uri, files);
            }
        }
    }

    public static ConfigurationInfo getNamespaceInfo()
    {
        return new ConfigurationInfo(-1, new String[] {"uri", "manifest"})
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }
}
