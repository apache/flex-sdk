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

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.rep.VariableDeclaration;
import flex2.compiler.SymbolTable;

import java.util.*;

/**
 * Constants for framework-specific AS support classes, packages,
 * import sets, etc.
 */
public class FrameworkDefs
{
	/**
	 *
	 */
	public static final Set<String> builtInEffectNames;
	static
	{
		builtInEffectNames = new HashSet<String>();
		builtInEffectNames.add("Dissolve");
		builtInEffectNames.add("Fade");
		builtInEffectNames.add("WipeLeft");
		builtInEffectNames.add("WipeRight");
		builtInEffectNames.add("WipeUp");
		builtInEffectNames.add("WipeDown");
		builtInEffectNames.add("Zoom");
		builtInEffectNames.add("Resize");
		builtInEffectNames.add("Move");
		builtInEffectNames.add("Pause");
		builtInEffectNames.add("Rotate");
		builtInEffectNames.add("Iris");
		builtInEffectNames.add("Blur");
		builtInEffectNames.add("Glow");
	}

	/**
	 *
	 */
	public static final Set<String> requiredTopLevelDescriptorProperties;
	static
	{
		requiredTopLevelDescriptorProperties = new HashSet<String>();
		requiredTopLevelDescriptorProperties.add("height");
		requiredTopLevelDescriptorProperties.add("width");
		requiredTopLevelDescriptorProperties.add("creationPolicy");
	}

	/**
	 *
	 */
	public static boolean isBuiltinEffectName(String name)
	{
		return builtInEffectNames.contains(name);
	}

	/**
	 * (generated) binding management variable sets
	 */
	public static final List<VariableDeclaration> bindingManagementVars = new ArrayList<VariableDeclaration>();
	static
	{
		bindingManagementVars.add(new VariableDeclaration("mx_internal", "_bindings", SymbolTable.ARRAY, "[]"));
		bindingManagementVars.add(new VariableDeclaration("mx_internal", "_watchers", SymbolTable.ARRAY, "[]"));
		bindingManagementVars.add(new VariableDeclaration("mx_internal", "_bindingsByDestination", SymbolTable.OBJECT, "{}"));
		bindingManagementVars.add(new VariableDeclaration("mx_internal", "_bindingsBeginWithWord", SymbolTable.OBJECT, "{}"));
	}
}
