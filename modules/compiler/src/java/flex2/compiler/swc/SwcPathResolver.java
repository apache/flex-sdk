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

package flex2.compiler.swc;

import flash.util.Trace;
import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcFile;

import java.util.Map;

/**
 * Resolves files found in a given Map&lt;String, VirtualFile&gt;,
 * where the String is the path.
 *
 * @author Brian Deitte
 */
public class SwcPathResolver implements SinglePathResolver
{
    private SwcGroup swcGroup;

    public SwcPathResolver(SwcGroup swcGroup)
    {
        this.swcGroup = swcGroup;
    }

    public VirtualFile resolve( String pathStr )
    {
        // Handles the case when pathStr is something like "foo.css".
        VirtualFile virt = swcGroup.getFiles().get(pathStr);

	    if (virt == null)
	    {
            // Handles the case when pathStr is something like "foo.swc$bar.css".
            virt = swcGroup.getFile(pathStr);
	    }

        if ((virt != null) && Trace.pathResolver)
        {
            Trace.trace("SwcPathResolver.resolve: resolved " + pathStr + " to " + virt.getName());
        }

        return virt;
    }
}
