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

package flex2.compiler.mxml.rep;

/**
 * Simple structure for holding a variable declaration to generate.
 * This is much more lightweight than decl.PropertyDeclaration, which
 * represents things induced by the MXML document.  These are for
 * e.g. behind-the-scenes management variables, etc., e.g. see
 * FrameworkDefs.documentManagementVariables
 */
/*
 * TODO break out quals, if they need to be introspected
 */
public class VariableDeclaration
{
	private String namespace, name, type, initializer;

	public VariableDeclaration(String namespace, String name, String type, String initializer)
	{
		this.namespace = namespace;
		this.name = name;
		this.type = type;
        this.initializer = initializer;
	}

	public final String getNamespace() { return namespace; }
	public final String getName() { return name; }
	public final String getType() { return type; }
    public final String getInitializer() { return initializer; }
}
