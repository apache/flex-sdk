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

package flex2.compiler;

import flex2.compiler.common.Configuration;
import flex2.compiler.util.NameMappings;
import java.util.List;

/**
 * This interface defines the common methods executed during the
 * prelink phase.
 *
 * @author Clement Wong
 */
public interface PreLink
{
	/**
	 * Runs pre-link to analyze known dependencies and generate mix-ins and 
	 * style initialization code.
	 * 
	 * @return true if additional sources were generated and pre-link should be
	 * run again, otherwise false (and thus postRun() can now be called).
	 */
	boolean run(List<Source> sources,
	         List<CompilationUnit> units,
	         FileSpec fileSpec,
	         SourceList sourceList,
	         SourcePath sourcePath,
	         ResourceBundlePath bundlePath,
	         ResourceContainer resources,
	         SymbolTable symbolTable,
             CompilerSwcContext swcContext,
             NameMappings nameMappings,
	         Configuration configuration);

    void postRun(List<Source> sources,
                 List<CompilationUnit> units,
                 ResourceContainer resources,
                 SymbolTable symbolTable,
                 CompilerSwcContext swcContext,
                 NameMappings nameMappings,
                 Configuration configuration);
}
