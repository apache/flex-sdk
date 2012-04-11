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

package flex2.tools.oem.internal;

import java.io.File;

import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;
import flex2.tools.oem.PathResolver;

/**
 * A SinglePathResolver which delegates to an OEM API path resolver.
 * This is used by FB to resolve using Eclipse's API's.
 * 
 * @version 3.0
 * @author Clement Wong
 */
public class OEMPathResolver implements SinglePathResolver
{
	public OEMPathResolver(PathResolver r)
	{
		resolver = r;
	}
	
	private PathResolver resolver;
	
	public VirtualFile resolve(String relative)
	{
		File f = resolver != null ? resolver.resolve(relative) : null;
		return f != null ? new LocalFile(f) : null;
	}
}
