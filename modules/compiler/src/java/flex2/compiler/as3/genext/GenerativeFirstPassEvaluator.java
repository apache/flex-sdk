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

package flex2.compiler.as3.genext;

import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.ThreadLocalToolkit;
import flash.swf.tools.as3.EvaluatorAdapter;

import java.util.Map;

/**
 * A common base class for Bindable and Managed metadata first pass
 * evaluators.
 *
 * @author Basil Hosmer
 * @author Paul Reilly
 */
public abstract class GenerativeFirstPassEvaluator extends EvaluatorAdapter
{
	protected final TypeTable typeTable;
    protected final StandardDefs standardDefs;

	public GenerativeFirstPassEvaluator(TypeTable typeTable, StandardDefs defs)
	{
		this.typeTable = typeTable;
		this.standardDefs = defs;
		setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());
	}

	public abstract boolean makeSecondPass();

	public abstract Map<String, ? extends GenerativeClassInfo> getClassMap();

}
