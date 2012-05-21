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

package flex2.compiler.as3.managed;

import flex2.compiler.config.ServicesDependenciesWrapper;
import flex2.compiler.CompilationUnit;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.as3.genext.GenerativeExtension;
import flex2.compiler.as3.genext.GenerativeFirstPassEvaluator;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.MultiName;
import macromedia.asc.parser.Evaluator;

/**
 * A compiler extension used to process Managed metadata.
 *
 * @author Paul Reilly
 */
public final class ManagedExtension extends GenerativeExtension
{
    public static final String IMANAGED = "IManaged";

	private ServicesDependenciesWrapper servicesDependencies;
    
	public ManagedExtension(String generatedOutputDirectory, boolean generateAbstractSyntaxTree, boolean processComments)
	{
		this(generatedOutputDirectory, generateAbstractSyntaxTree, null, processComments);
	}

    public ManagedExtension(String generatedOutputDirectory, boolean generateAbstractSyntaxTree,
                            ServicesDependenciesWrapper services, boolean processComments)
    {
        super(generatedOutputDirectory, generateAbstractSyntaxTree, processComments );
        servicesDependencies = services;
    }

	/**
	 * Add the MultiNames for the definitions that the BindableSecondPassEvaluator
	 * requires.
	 */
    protected void addInheritance(CompilationUnit unit)
    {
        unit.inheritance.add(new MultiName(StandardDefs.PACKAGE_FLASH_EVENTS, IEVENT_DISPATCHER));
        unit.inheritance.add(new MultiName(unit.getStandardDefs().getDataPackage(), IMANAGED));
    }

	/**
	 *
	 */
	protected GenerativeFirstPassEvaluator getFirstPassEvaluator(CompilationUnit unit,
                                                                 TypeTable typeTable)
	{
		return new ManagedFirstPassEvaluator(typeTable, unit.getStandardDefs(), unit.metadata, servicesDependencies);
	}

	/**
	 *
	 */
	protected String getFirstPassEvaluatorKey()
    {
        return "ManagedFirstPassEvaluator";
    }

	/**
	 *
	 */
	protected Evaluator getSecondPassEvaluator(CompilationUnit unit,
                                               TypeAnalyzer typeAnalyzer,
                                               GenerativeFirstPassEvaluator firstPassEvaluator)
	{
		return new ManagedSecondPassEvaluator(unit, firstPassEvaluator.getClassMap(),
                                              typeAnalyzer, generatedOutputDirectory,
                                              generateAbstractSyntaxTree, processComments);
	}

}
