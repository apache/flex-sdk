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

import java.util.Map;
import java.util.Set;

import flex2.compiler.Source;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcComponent;

/**
 * This is a value object used to store data between incremental
 * compilations of a library.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class LibraryData extends ApplicationData
{
	public Set<SwcComponent> nsComponents;
    public Map<String, Source> classes;
    public Set<VirtualFile> fileSet;
	public Map<String, VirtualFile> rbFiles, swcArchiveFiles, cssArchiveFiles, l10nArchiveFiles;
}
