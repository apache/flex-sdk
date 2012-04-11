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

package flex2.compiler.util;

import flash.util.Trace;
import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.NetworkFile;
import flex2.compiler.io.VirtualFile;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * A resolver with tries to resolve paths using the URL class.
 */
public class URLPathResolver implements SinglePathResolver
{
    private static final URLPathResolver singleton = new URLPathResolver();

    private URLPathResolver()
    {
    }

    public static final URLPathResolver getSingleton()
    {
        return singleton;
    }

    public VirtualFile resolve(String uri)
    {
        VirtualFile location = null;

		try
		{
			URL url = new URL(uri);
            if (url != null)
            {
                location = new NetworkFile(url);
            }            
		}
		catch (SecurityException securityException)
		{
	    }
	    catch (MalformedURLException malformedURLException)
		{
		}
        catch (IOException ioException)
        {
        }

        if ((location != null) && Trace.pathResolver)
        {
            Trace.trace("URLPathResolver.resolve: resolved " + uri + " to " + location.getName());
        }

        return location;
    }
}
