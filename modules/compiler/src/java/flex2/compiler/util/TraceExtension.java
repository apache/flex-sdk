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

import flex2.compiler.CompilationUnit;
import flex2.compiler.as3.Extension;
import flex2.compiler.as3.reflect.TypeTable;

/**
 * A handy utility useful for visualizing how compilation progresses
 * through each of the phases for each CompilationUnit.  The
 * differences between the batch algorithms can be seen using this
 * class.
 *
 * @author Clement Wong
 */
public class TraceExtension implements Extension
{
	public void parse1(CompilationUnit unit, TypeTable typeTable)
	{
		ThreadLocalToolkit.logInfo("parse1: " + unit.getSource().getName());
	}

    public void parse2(CompilationUnit unit, TypeTable typeTable)
    {
		ThreadLocalToolkit.logInfo("parse2: " + unit.getSource().getName());
    }

	public void analyze1(CompilationUnit unit, TypeTable typeTable)
	{
		ThreadLocalToolkit.logInfo("analyze1: " + unit.getSource().getName());		
	}

	public void analyze2(CompilationUnit unit, TypeTable typeTable)
	{
		ThreadLocalToolkit.logInfo("analyze2: " + unit.getSource().getName());		
	}

	public void analyze3(CompilationUnit unit, TypeTable typeTable)
	{
		ThreadLocalToolkit.logInfo("analyze3: " + unit.getSource().getName());		
	}

	public void analyze4(CompilationUnit unit, TypeTable typeTable)
	{
		ThreadLocalToolkit.logInfo("analyze4: " + unit.getSource().getName());		
	}

	public void generate(CompilationUnit unit, TypeTable typeTable)
	{
		ThreadLocalToolkit.logInfo("generate: " + unit.getSource().getName());		
	}
}
