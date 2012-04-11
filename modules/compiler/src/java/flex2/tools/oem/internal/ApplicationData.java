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

import java.util.List;
import java.util.Map;
import java.util.Set;

import macromedia.asc.util.ContextStatics;

import flash.fonts.FontManager;
import flex2.compiler.CompilationUnit;
import flex2.compiler.FileSpec;
import flex2.compiler.ResourceBundlePath;
import flex2.compiler.ResourceContainer;
import flex2.compiler.Source;
import flex2.compiler.SourceList;
import flex2.compiler.SourcePath;
import flex2.compiler.common.Configuration;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.util.QName;
import flex2.linker.ConsoleApplication;
import flex2.linker.SimpleMovie;

/**
 * This is a value object used to store data between incremental
 * compilations of an application.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class ApplicationData
{
	/**
	 * for incremental compilation
	 */
	public int checksum;
	
	/**
	 * command-line checksum
	 */
	public int cmdChecksum;
	
	/**
	 * command-line linker-based checksum
	 */
	public int linkChecksum;
	
	/**
	 * SWC context checksum
	 */
	public int swcChecksum;
	
	/**
	 * some containers for CompilationUnits
	 */
	public FileSpec fileSpec;
	public SourceList sourceList;
	public SourcePath sourcePath;
	public ResourceContainer resources;
	public ResourceBundlePath bundlePath;
	
	/**
	 * sources and compilation units
	 */
	public List<Source> sources;
	public List<CompilationUnit> units;
	
	public String cacheName;
	// public String outputName;
	
	public Configuration configuration;
	public ContextStatics perCompileData;
	public SwcCache swcCache;
	
	public SimpleMovie movie;
	public ConsoleApplication app;
    public FontManager fontManager;

	/**
	 * SWC context includes and excludes
	 */
	public Set<String> includes, excludes;
	
	/**
	 * Map definition to signature checksum.
	 */
	public Map<QName, Long> swcDefSignatureChecksums;
	
	/**
	 * Map swc file to checksum (modification timestamp).
	 */
	public Map<String, Long> swcFileChecksums;
}
