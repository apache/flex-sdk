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

import flex2.compiler.CompilationUnit;
import flex2.compiler.as3.binding.ClassInfo;
import flex2.compiler.as3.binding.InterfaceInfo;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.as3.genext.GenerativeClassInfo;
import flex2.compiler.as3.genext.GenerativeExtension;
import flex2.compiler.as3.genext.GenerativeSecondPassEvaluator;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.QName;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.FunctionDefinitionNode;
import macromedia.asc.parser.VariableDefinitionNode;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

import java.util.HashMap;
import java.util.Map;

/**
 * This class handles the AST manipulation of wrapping properties and
 * variables, with getter/setter pairs, which logic to enable data
 * services.  See the functions, getProperty() and setProperty(), in
 * the ActionScript class, mx.data.utils.Managed, for more info.
 *
 * @author Paul Reilly
 */
public class ManagedSecondPassEvaluator extends GenerativeSecondPassEvaluator
{
	private static final String CODEGEN_TEMPLATE_PATH = "flex2/compiler/as3/managed/";
    private static final String IMANAGED = "IManaged";

    private ManagedClassInfo currentInfo;
    private boolean inClass = false;

	public ManagedSecondPassEvaluator(CompilationUnit unit, Map<String, ? extends GenerativeClassInfo> classMap,
	                                  TypeAnalyzer typeAnalyzer, String generatedOutputDirectory,
                                      boolean generateAbstractSyntaxTree, boolean processComments)
	{
        super(unit, classMap, typeAnalyzer, generatedOutputDirectory, generateAbstractSyntaxTree, processComments);
    }

	/**
	 *
	 */
	public Value evaluate(Context context, ClassDefinitionNode node)
	{
		if (!evaluatedClasses.contains(node))
		{
			inClass = true;

			String className = NodeMagic.getClassName(node);

			currentInfo = (ManagedClassInfo) classMap.get(className);

			if (currentInfo != null)
			{
				ClassInfo classInfo = currentInfo.getClassInfo();

				if (!classInfo.implementsInterface(StandardDefs.PACKAGE_FLASH_EVENTS,
												   GenerativeExtension.IEVENT_DISPATCHER))
				{
					currentInfo.setNeedsToImplementIEventDispatcher(true);

					MultiName multiName = new MultiName(StandardDefs.PACKAGE_FLASH_EVENTS,
														GenerativeExtension.IEVENT_DISPATCHER);
					InterfaceInfo interfaceInfo = typeAnalyzer.analyzeInterface(context, multiName, classInfo);

					// interfaceInfo will be null if IEventDispatcher was not resolved.
					// This most likely means that playerglobal.swc was not in the
					// external-library-path and other errors will be reported, so punt.
					if ((interfaceInfo == null) || checkForExistingMethods(context, node, classInfo, interfaceInfo))
					{
						return null;
					}

					classInfo.addInterfaceMultiName(StandardDefs.PACKAGE_FLASH_EVENTS,
                                                    GenerativeExtension.IEVENT_DISPATCHER);
				}

				if (!classInfo.implementsInterface(standardDefs.getDataPackage(), IMANAGED))
				{
					currentInfo.setNeedsToImplementIManaged(true);

                    // Don't be tempted to check for mx.core.IUID here, because
                    // analyzeInterface() sets up the inheritance for downstream
                    // consumers and if we only add IUID to the inheritance, then
                    // the check for IManaged in the enclosing if statement will fail.
					MultiName multiName = new MultiName(standardDefs.getDataPackage(), IMANAGED);
					InterfaceInfo interfaceInfo = typeAnalyzer.analyzeInterface(context, multiName, classInfo);

					// interfaceInfo will be null if IManaged was not resolved.
					// This most likely means that fds.swc was not in the
					// library-path and other errors will be reported, so punt.
					if ((interfaceInfo == null) || checkForExistingMethods(context, node, classInfo, interfaceInfo))
					{
						return null;
					}

					classInfo.addInterfaceMultiName(standardDefs.getDataPackage(), IMANAGED);
				}

				postProcessClassInfo(context, currentInfo);

				if (node.statements != null)
				{
					node.statements.evaluate(context, this);

					modifySyntaxTree(context, node, currentInfo);
				}

				currentInfo = null;
			}

			inClass = false;

			// Make sure we don't process this class again.
			evaluatedClasses.add(node);
		}

		return null;
	}

    /**
     *
     */
    public Value evaluate(Context context, FunctionDefinitionNode node)
    {
		if (inClass)
		{
			QName qname = new QName(NodeMagic.getUserNamespace(node), NodeMagic.getFunctionName(node));
			GenerativeClassInfo.AccessorInfo accessorInfo = currentInfo.getAccessor(qname);
			if (accessorInfo != null)
			{
				hideFunction(node, accessorInfo);
				registerRenamedAccessor(accessorInfo);
			}
		}

		return null;
    }

    /**
     * visits all variable definitions that occur inside class definitions (and outside function definitions) and mangles
     * their names
     */
    public Value evaluate(Context context, VariableDefinitionNode node)
    {
        if (inClass)
        {
			QName qname = new QName(NodeMagic.getUserNamespace(node), NodeMagic.getVariableName(node));
			GenerativeClassInfo.AccessorInfo info = currentInfo.getAccessor(qname);
			if (info != null)
			{
				hideVariable(node, info);
				registerRenamedAccessor(info);
			}
        }

        return null;
    }

	/**
	 *
	 */
	protected String getTemplateName()
	{
		return standardDefs.getManagedPropertyTemplate();
	}

	/**
	 *
	 */
	protected Map<String, ManagedClassInfo> getTemplateVars()
	{
		Map<String, ManagedClassInfo> vars = new HashMap<String, ManagedClassInfo>();
		vars.put("managedInfo", currentInfo);

		return vars;
	}

	/**
	 *
	 */
	protected String getTemplatePath()
	{
		return CODEGEN_TEMPLATE_PATH;
	}

	/**
	 *
	 */
	protected String getGeneratedSuffix()
	{
		return "-managed-generated.as";
	}

}
