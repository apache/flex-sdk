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

import java.util.List;

import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerSwcContext;
import flex2.compiler.FileSpec;
import flex2.compiler.ResourceBundlePath;
import flex2.compiler.ResourceContainer;
import flex2.compiler.Source;
import flex2.compiler.SourceList;
import flex2.compiler.SourcePath;
import flex2.compiler.SymbolTable;
import flex2.compiler.common.Configuration;

/**
 * Defines the API for extensions, which run before each PreLink run.
 * PreLink's run can be executed multiple times.
 *
 * @author Andrew Westberg
 */
public interface IPreLinkExtension
    extends IExtension
{
    void run( List<Source> sources, List<CompilationUnit> units, FileSpec fileSpec, SourceList sourceList,
              SourcePath sourcePath, ResourceBundlePath bundlePath, ResourceContainer resources,
              SymbolTable symbolTable, CompilerSwcContext swcContext, Configuration configuration );
}
