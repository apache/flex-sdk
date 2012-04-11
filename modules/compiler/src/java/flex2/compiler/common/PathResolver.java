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

import flex2.compiler.io.VirtualFile;

import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

/**
 * This class acts as a SinglePathResolver, but delegates to a list of
 * SinglePathResolver bases.  For example, ThreadLocalToolkit's global
 * PathResolver wraps a collection of SinglePathResolver's like
 * LocalFilePathResolver, SourcePath, SwcPathResolver, and
 * URLPathResolver.
 *
 * @author Brian Deitte
 */
public class PathResolver implements SinglePathResolver
{
    private List<SinglePathResolver> bases;

    /**
     * Resolve the current file used the registered SinglePathResolvers
     */
    public VirtualFile resolve( String pathStr )
    {
        return resolve((SinglePathResolver)null, pathStr);
    }

    /**
     * Resolve the current file, checking the passed in resolver first
     */
    public VirtualFile resolve( SinglePathResolver resolver, String pathStr )
    {
        if (pathStr == null)
        {
            return null;
        }

        VirtualFile virt = null;
        if (resolver != null)
        {
            virt = resolver.resolve(pathStr);
        }
        if (virt == null)
        {
            virt = checkSinglePathResolvers(virt, pathStr);
        }

        return virt;
    }

    /**
     * Resolve the current file, checking the passed in resolvers first
     */
    public VirtualFile resolve( SinglePathResolver[] resolvers, String pathStr )
    {
        if (pathStr == null)
        {
            return null;
        }

        VirtualFile virt = null;
        if (resolvers != null)
        {
            for (int i = 0; i < resolvers.length; i++)
            {
                SinglePathResolver resolver = resolvers[i];
                virt = resolver.resolve(pathStr);
                if (virt != null)
                    break;
            }
        }
        if (virt == null)
        {
            virt = checkSinglePathResolvers(virt, pathStr);
        }

        return virt;
    }

    /**
     * Add a resolver that will be used in all resolves
     */
    public void addSinglePathResolver( SinglePathResolver resolver )
    {
        int index = 0;

        if (bases != null)
        {
            index = bases.size();
        }

        addSinglePathResolver(index, resolver);
    }

    /**
     * Add a resolver that will be used in all resolves
     */
    public void addSinglePathResolver( int index, SinglePathResolver resolver )
    {
        assert resolver != null;

        if (bases == null)
        {
            bases = new ArrayList<SinglePathResolver>();
        }

        bases.add(index, resolver);
    }

    private VirtualFile checkSinglePathResolvers(VirtualFile virt, String pathStr)
    {
        if (bases != null)
        {
            // fixme: should we just grab the first one or check mod times?
            for (Iterator<SinglePathResolver> iterator = bases.iterator(); iterator.hasNext();)
            {
                SinglePathResolver baseResolver = iterator.next();
                virt = baseResolver.resolve(pathStr);
                if (virt != null)
                {
                    break;
                }
            }
        }
        return virt;
    }

    public void removeSinglePathResolver( SinglePathResolver resolver )
    {
        for (Iterator<SinglePathResolver> iterator = bases.iterator(); iterator.hasNext();)
        {
            // Intentionally using == here.
            if (iterator.next() == resolver)
            {
                iterator.remove();
                return;
            }
        }
    }
}
