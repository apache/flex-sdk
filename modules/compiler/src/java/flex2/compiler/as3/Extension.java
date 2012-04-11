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

package flex2.compiler.as3;

import flex2.compiler.CompilationUnit;
import flex2.compiler.as3.reflect.TypeTable;

/**
 * SubCompiler extension interface.
 *
 * @author Clement Wong
 */
public interface Extension
{
	/**
	 * Called at the end of SubCompiler.parse()
	 */
	void parse1(CompilationUnit unit, TypeTable typeTable);
	void parse2(CompilationUnit unit, TypeTable typeTable);

	/**
	 * Called at the end of SubCompiler.analyze1()
	 */
	void analyze1(CompilationUnit unit, TypeTable typeTable);

	/**
	 * Called at the end of SubCompiler.analyze2()
	 */
	void analyze2(CompilationUnit unit, TypeTable typeTable);

	/**
	 * Called at the end of SubCompiler.analyze3()
	 */
	void analyze3(CompilationUnit unit, TypeTable typeTable);

	/**
	 * Called at the end of SubCompiler.analyze4()
	 */
	void analyze4(CompilationUnit unit, TypeTable typeTable);

	/**
	 * Called at the end of SubCompiler.generate()
	 */
	void generate(CompilationUnit unit, TypeTable typeTable);
}
