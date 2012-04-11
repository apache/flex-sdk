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

import flex2.compiler.util.PerformanceData;

/**
 * Each subcompiler must implement this interface.
 *
 * @author Clement Wong
 */
public interface SubCompiler
{
    /**
     * The name of this compiler as a simple String identifier.
     */
    String getName();

	/**
	 * If this compiler can process the specified file, return true.
	 */
	boolean isSupported(String mimeType);

	/**
	 * Return supported mime types.
	 */
	String[] getSupportedMimeTypes();

	/**
	 * Pre-process source file.
	 */
	Source preprocess(Source source);

	/**
	 * Parse... The implementation must:
	 *
	 * 1. create a compilation unit
	 * 2. put the Source object and the syntax tree in the compilation unit
	 * 3. register unit.includes, unit.dependencies, unit.topLevelDefinitions and unit.metadata
	 */
	CompilationUnit parse1(Source source, SymbolTable symbolTable);
	void parse2(CompilationUnit unit, SymbolTable symbolTable);

	/**
	 * Analyze... The implementation must:
	 *
	 * 1. register type info to SymbolTable
	 */
	void analyze1(CompilationUnit unit, SymbolTable symbolTable);
	void analyze2(CompilationUnit unit, SymbolTable symbolTable);
	void analyze3(CompilationUnit unit, SymbolTable symbolTable);
	void analyze4(CompilationUnit unit, SymbolTable symbolTable);

	/**
	 * Code Generate
	 */
	void generate(CompilationUnit unit, SymbolTable symbolTable);

	/**
	 * Postprocess... could be invoked multiple times...
	 */
	void postprocess(CompilationUnit unit, SymbolTable symbolTable);

    void initBenchmarks();
    PerformanceData[] getBenchmarks();
    
    /**
     * gets benchmark times for embedded compilers, if any.
     * For example, the mxmlc compiler has embedded asc compilers.
     * @return benchmark data, or null if no embedded compilers
     */
    PerformanceData[] getEmbeddedBenchmarks();
    void logBenchmarks(Logger logger);
}
