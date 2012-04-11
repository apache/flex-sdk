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

package flex2.tools;

import flash.swf.Movie;
import flex2.compiler.CompilationUnit;
import flex2.compiler.FileSpec;
import flex2.compiler.ResourceContainer;
import flex2.compiler.SourceList;
import flex2.compiler.SourcePath;
import flex2.compiler.ResourceBundlePath;
import flex2.compiler.common.Configuration;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcCache;
import flex2.linker.ConsoleApplication;

import java.util.List;
import java.util.Map;

import macromedia.asc.util.ContextStatics;

/**
 * Fcsh helper class.
 *
 * @author Clement Wong
 */
public class Target
{
	public int id;
	public String[] args;
	public int checksum;
	public FileSpec fileSpec;
	public SourceList sourceList;
	public SourcePath sourcePath;
	public ResourceContainer resources;
	public ResourceBundlePath bundlePath;
	public List<CompilationUnit> units;
	public Map<String, VirtualFile> rbFiles;
	public String cacheName;
	public String outputName;
	public Configuration configuration;
	public ContextStatics perCompileData;
	public SwcCache swcCache;
	public Movie movie;
	public ConsoleApplication app;
}
