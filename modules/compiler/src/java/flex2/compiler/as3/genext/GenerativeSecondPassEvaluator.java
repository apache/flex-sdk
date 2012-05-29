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

import flex2.compiler.CompilationUnit;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.binding.ClassInfo;
import flex2.compiler.as3.binding.InterfaceInfo;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.*;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.ObjectList;
import flash.swf.tools.as3.EvaluatorAdapter;
import flash.util.FileUtils;
import flash.util.Trace;
import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;

import java.io.*;
import java.util.*;

/**
 * A common base class for Bindable and Managed metadata second pass
 * evaluators.
 *
 * @author Basil Hosmer
 * @author Paul Reilly
 */
public abstract class GenerativeSecondPassEvaluator extends EvaluatorAdapter
{
	protected final CompilationUnit unit;
	protected final StandardDefs standardDefs;
	protected final String generatedOutputDirectory;
	protected final Map<String, ? extends GenerativeClassInfo> classMap;
	protected final Set<ClassDefinitionNode> evaluatedClasses;
	protected final TypeAnalyzer typeAnalyzer;
	protected final MetaDataEvaluator metaDataEvaluator;
    protected final boolean generateAbstractSyntaxTree;
    protected final boolean processComments;

	/**
	 *
	 */
	public GenerativeSecondPassEvaluator(CompilationUnit unit,
										 Map<String, ? extends GenerativeClassInfo> classMap,
										 TypeAnalyzer typeAnalyzer,
										 String generatedOutputDirectory,
                                         boolean generateAbstractSyntaxTree, boolean processComments)
	{
		this.unit = unit;
		this.standardDefs = unit.getStandardDefs();
		this.classMap = classMap;
		this.typeAnalyzer = typeAnalyzer;
		this.generatedOutputDirectory = generatedOutputDirectory;
        this.generateAbstractSyntaxTree = generateAbstractSyntaxTree;
        this.processComments = processComments;
        
		evaluatedClasses = new HashSet<ClassDefinitionNode>();
		setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());

		metaDataEvaluator = new MetaDataEvaluator();
	}

	protected boolean checkForExistingMethods(Context context, ClassDefinitionNode node,
                                              ClassInfo classInfo, InterfaceInfo interfaceInfo)
	{
		// NOTE: here we want to log as many errors as possible before returning
		// this is why we don't bail after finding the first error
		boolean result = false;

        List functionNames = interfaceInfo.getFunctionNames();

        if (functionNames != null)
        {
            Iterator iterator = functionNames.iterator();
        
            while ( iterator.hasNext() )
            {
                QName qName = (QName) iterator.next();
                String functionName = qName.getLocalPart();

                if (!functionName.equals("$construct") && 
                    classInfo.definesFunction(functionName, true))
                {
                    context.localizedError2(node.pos(),
                                            new ExistingMethodError(interfaceInfo.getInterfaceName(),
                                                                    node.name.name,
                                                                    functionName));
                    result = true;
                }
            }
        }

		return result;
	}

	/**
	 * register a renamed variable into our unit's context
	 */
    protected void registerRenamedAccessor(GenerativeClassInfo.AccessorInfo info)
	{
        @SuppressWarnings("unchecked")
		Map<String, String> renamedVariableMap = (Map<String, String>) unit.getContext().getAttribute(flex2.compiler.CompilerContext.RENAMED_VARIABLE_MAP);
        
		if (renamedVariableMap == null)
		{
			renamedVariableMap = new HashMap<String, String>();
			unit.getContext().setAttribute(flex2.compiler.CompilerContext.RENAMED_VARIABLE_MAP, renamedVariableMap);
		}
		renamedVariableMap.put(info.getBackingPropertyName(), info.getPropertyName());
	}

	/**
	 * Mangle a variable's name and make it private.
	 */
	protected static void hideVariable(VariableDefinitionNode variableDefinition, GenerativeClassInfo.AccessorInfo info)
	{
		VariableBindingNode variableBindingNode = NodeMagic.getVariableBinding(variableDefinition);

		NodeMagic.setVariableBindingName(variableBindingNode, info.getBackingPropertyName());

		makeAttrListPrivate(variableDefinition);
	}

	/**
	 * Mangle a function's name and make it private.
	 */
	protected static void hideFunction(FunctionDefinitionNode functionDefinition, GenerativeClassInfo.AccessorInfo info)
	{
		NodeMagic.prefixFunctionName(functionDefinition, info.getBackingPrefix());

		makeAttrListPrivate(functionDefinition);
	}

	protected static boolean isIdentifier(IdentifierNode identifier, String attribute)
	{
		boolean result = false;
		if (identifier != null)
			result = identifier.name.equals(attribute);

		return result;
	}

	private static void makeAttrListPrivate(DefinitionNode def)
	{
		// we have to remove the override should it exist as it isn't legal to
		// override private members.
		if (def.attrs != null)
		{
			Iterator iterator = def.attrs.items.iterator();

			while ( iterator.hasNext() )
			{
				Object node = iterator.next();
				IdentifierNode identifier = null;
				if (node instanceof MemberExpressionNode)
				{
					// if this identifier is an override we need to remove it
					// other wise we can go ahead and mark it private.
					identifier = NodeMagic.getIdentifier((MemberExpressionNode) node);
					if (isIdentifier(identifier, NodeMagic.OVERRIDE))
					{
						iterator.remove();
					}
					else
					{
						ensureNonPublic(identifier);
					}
				}
				else if (node instanceof ListNode)
				{
					ListNode list = (ListNode) node;

					Iterator listIterator = list.items.iterator();

					while ( listIterator.hasNext() )
					{
						Object listNode = listIterator.next();

						if (listNode instanceof MemberExpressionNode)
						{
							// if this identifier is an override we need to remove it
							// other wise we can go ahead and mark it private.
							// NOTE: it appears that override _always_ lives in this
							// portion of the node tree, i.e. the ListNode part
							identifier = NodeMagic.getIdentifier((MemberExpressionNode) listNode);
							if (isIdentifier(identifier, NodeMagic.OVERRIDE))
							{
								iterator.remove();
							}
							else
							{
								ensureNonPublic(identifier);
							}
						}
					}
				}
			}
		}
	}

	/**
	 * NOTE: used to be called 'makePrivate'; changed name to something closer to what it actually does.
	 * If what it really needs to do is make everything private, it needs a rewrite. Old comment follows:
	 * TODO what about internals, don't we want to make them private also?
	 */
	protected static void ensureNonPublic(IdentifierNode identifier)
	{
		if (isIdentifier(identifier, NodeMagic.PUBLIC))
		{
			identifier.name = NodeMagic.PRIVATE;
		}
	}

	/**
	 *
	 */
	protected abstract String getTemplateName();

	/**
	 * Used to allow subclasses with different template locations to specify 
	 * where those locations are.
	 * @return template path
	 */
	protected abstract String getTemplatePath();

	/**
	 *
	 */
	protected abstract Map getTemplateVars();

	/**
	 *
	 */
	protected abstract String getGeneratedSuffix();

	/**
	 * Produces a parsed ProgramNode containing a single ClassDefinitionNode containing generated wrappers for
	 * [Bindable] properties.
	 *
	 * This codegen happens after the original properties have been prepped (i.e., made private, name-mangled, etc.),
	 * and is based on information exposed to the template as a collection of info structures (see implementations of
	 * getTemplateVars()).
	 */
	protected ProgramNode generateSupportCode(Context context, String className)
	{
		ProgramNode programNode = null;

		String templateName = getTemplateName();
		Map templateVars = getTemplateVars();
		String suffix = getGeneratedSuffix();

		Template template = null;
		try
		{
			template = VelocityManager.getTemplate(getTemplatePath() + templateName);
		}
		catch(Exception e) {}


		if (template != null)
		{
			try
			{
				StringWriter stringWriter = new StringWriter();

				VelocityContext velocityContext = new VelocityContext();

				for (Iterator iter = templateVars.entrySet().iterator(); iter.hasNext(); )
				{
					Map.Entry entry = (Map.Entry)iter.next();
					velocityContext.put((String)entry.getKey(), entry.getValue());
				}

				template.merge(velocityContext, stringWriter);

				String sourceName = unit.getSource().getName();
				String prefix = sourceName.substring(0, sourceName.lastIndexOf(File.separatorChar) + 1);
				String generatedName = prefix + className + suffix;

				// convention: prepend underscore to fake code snippets that are written out just for debugging?
				if (generatedOutputDirectory != null)
				{
					generatedName = FileUtils.addPathComponents( generatedOutputDirectory, "_" + className + suffix, File.separatorChar );
				}

				if (generatedOutputDirectory != null)
				{
					BufferedWriter fileWriter = null;

					try
					{
						fileWriter = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(generatedName), "UTF-8"));
						fileWriter.write( stringWriter.toString() );
						fileWriter.flush();
					}
					catch (IOException ioException)
					{
						ioException.printStackTrace();
					}
					finally
					{
						if (fileWriter != null)
						{
							try
							{
								fileWriter.close();
							}
							catch (IOException ex)
							{
							}
						}
					}
				}

				context = new Context(context.statics);
				context.setPath("");
				context.setScriptName(generatedName);
				context.setHandler(new flex2.compiler.as3.As3Compiler.CompilerHandler());
				context.statics.handler = context.getHandler();

				Parser parser = new Parser(context, stringWriter.toString(), generatedName, processComments, false);

				programNode = parser.parseProgram();

                As3Compiler.cleanNodeFactory(context.getNodeFactory());
			}
			catch (Exception e)
			{
				ThreadLocalToolkit.log(new TemplateRunException(templateName, className, e.getLocalizedMessage()));

				if (Trace.error)
				{
					e.printStackTrace();
				}
			}
		}
		else
		{
			ThreadLocalToolkit.log(new TemplateLoadError(templateName));
		}

		return programNode;
	}

	/**
	 * Modifies a ClassDefinitionNode by a) generating a temp class full of property wrappers etc., as directed by info
	 * structure, and b) splicing these generated wrappers into the original classdef.
	 */
	protected void modifySyntaxTree(Context context, ClassDefinitionNode classDef, GenerativeClassInfo classInfo)
	{
        ProgramNode genProgramNode = generateSupportCode(context, classDef.name.name);

        if (genProgramNode.statements.items != null)
        {
            applyGeneratedSupportCode(context, classDef, classInfo, genProgramNode);
        }
	}

	/**
	 * Apply contents of generated class to our original classdef.
	 */
	private void applyGeneratedSupportCode(Context context,
										   ClassDefinitionNode classDef,
										   GenerativeClassInfo classInfo,
										   ProgramNode genProgramNode)
	{
		for (Iterator genIter = genProgramNode.statements.items.iterator(); genIter.hasNext(); )
		{
			Object genItem = genIter.next();
			if (genItem instanceof ClassDefinitionNode)
			{
				ClassDefinitionNode genClassDef = (ClassDefinitionNode) genItem;
				if (genClassDef.statements != null)
				{
					for (Iterator genClassStmtIter = genClassDef.statements.items.iterator(); genClassStmtIter.hasNext(); )
					{
						Node genClassStmt = (Node) genClassStmtIter.next();

						/**
						 * type-specific node prep
						 */
						if (genClassStmt instanceof MetaDataNode)
						{
							prepMetaDataNode(context, (MetaDataNode) genClassStmt);
						}
						else if (genClassStmt instanceof FunctionDefinitionNode)
						{
							prepFunctionDefinitionNode(context, classDef, classInfo, (FunctionDefinitionNode) genClassStmt);
						}
						else if (genClassStmt instanceof VariableDefinitionNode)
						{
							VariableDefinitionNode variableDefinition = (VariableDefinitionNode) genClassStmt;
							prepVariableDefinitionNode(classDef, variableDefinition);
                            // If we get here, the genClassStmt is assumed to be the
                            // _bindingEventDispatcher variable or one of the variables
                            // from ManagedProperty.vm.  Set the position to -1, so it
                            // won't interfere with debugging.
							resetPositions(context, variableDefinition, -1);
						}

						addGeneratedMember(classDef, genClassStmt);
					}

					applyGeneratedInterfaces(classInfo, classDef, genClassDef);
				}
			}
		}
	}

	/**
	 * add generated statement to original class
	 */
	private void addGeneratedMember(ClassDefinitionNode classDef, Node genClassStmt)
	{
		if (!(genClassStmt instanceof NamespaceDefinitionNode))
		{
			classDef.statements.items.add(genClassStmt);
		}
	}

	/**
	 * prepare MetaDataNode for transfer from generated class to original class.
	 * Generated metadata will be e.g. [Bindable("propertyChange")]
	 */
	protected void prepMetaDataNode(Context context, MetaDataNode metaData)
	{
		//	transfer generated (in-class) metadata to unit's all-the-metadata list
		metaData.evaluate(context, metaDataEvaluator);
		unit.metadata.add(metaData);
	}

	/**
	 * prepare FunctionDefinitionNode for transfer from generated class to original class.
	 * Generated functions that are getter/setter wrappers corresponding to original variables or getter/setters, as
	 * indicated in classInfo, need position info and metadata to be patched over from original properties.
	 */
	private void prepFunctionDefinitionNode(Context context,
											ClassDefinitionNode classDef,
											GenerativeClassInfo classInfo,
											FunctionDefinitionNode genFuncDef)
	{
		String functionName = NodeMagic.getFunctionName(genFuncDef);

		//	patch original classdef's node stuff into generated function def node
		genFuncDef.cx = classDef.cx;
		genFuncDef.fexpr.cx = classDef.cx;
		genFuncDef.pkgdef = classDef.pkgdef;
		genFuncDef.skipNode(true);

		//	TODO why would either of these be null?
		if ((functionName != null) && (classInfo.getAccessors() != null))
		{
			GenerativeClassInfo.AccessorInfo accessorInfo = classInfo.getAccessor(functionName);

			if (accessorInfo != null)
			{
				if (accessorInfo instanceof GenerativeClassInfo.VariableInfo)
				{
					//	original property was a variable
					GenerativeClassInfo.VariableInfo variableInfo = (GenerativeClassInfo.VariableInfo)accessorInfo;

					//	patch original position info into generated node
					resetPositions(context, genFuncDef, variableInfo.getPosition());

					//	patch (only) generated getter with original metadata from var
					if (NodeMagic.functionIsGetter(genFuncDef))
					{
						patchMetaData(genFuncDef, variableInfo.getMetaData());
					}
				}
				else if (accessorInfo instanceof GenerativeClassInfo.GetterSetterInfo)
				{
					//	original property was a getter/setter pair
					GenerativeClassInfo.GetterSetterInfo getterSetterInfo = (GenerativeClassInfo.GetterSetterInfo)accessorInfo;

					//	patch original position info and metadata into generated node
					if (NodeMagic.functionIsGetter(genFuncDef))
					{
						resetPositions(context, genFuncDef, getterSetterInfo.getGetterPosition());
						patchMetaData(genFuncDef, getterSetterInfo.getGetterMetaData());
					}
					else if (NodeMagic.functionIsSetter(genFuncDef))
					{
						resetPositions(context, genFuncDef, getterSetterInfo.getSetterPosition());
						patchMetaData(genFuncDef, getterSetterInfo.getSetterMetaData());
					}
				}

				classInfo.removeOriginalMetaData( accessorInfo.getDefinitionNode() );
			}
			else
			{
                // If we get here, the genFuncDef is assumed to be one of the the
                // IEventDispatcher implementation functions (addEventListener(),
                // dispatchEvent(), hasEventListener(), removeEventListener(), or
                // willTrigger()) or one of the functions defined in ManagedProperty.vm.
                // Set the position to -1, so they won't interfere with debugging.
				resetPositions(context, genFuncDef, -1);
			}
		}
	}

	/**
	 * 
	 */
	private void patchMetaData(DefinitionNode def, List metadata)
	{
		for (Iterator it = metadata.iterator(); it.hasNext();)
		{
			MetaDataNode md = (MetaDataNode) it.next();
			if (md.getId() != null && md.getId().equals( StandardDefs.MD_BINDABLE ) && ((md.getValues() == null) || (md.getValues().length == 0)))
				continue;
			
			if (md instanceof DocCommentNode)
			{
				md.def = def;
			}

			def.addMetaDataNode( md );
		}
	}

	/**
	 *
	 */
	private void resetPositions(Context context, Node node, int position)
	{
		PositionResetEvaluator positionResetEvaluator = new PositionResetEvaluator(position);
		node.evaluate(context, positionResetEvaluator);
	}

	/**
	 * prepare VariableDefinitionNode for transfer from generated class to original class.
	 * Generated variables will be miscellaneous, e.g. EventDispatcher delegate
	 */
	private void prepVariableDefinitionNode(ClassDefinitionNode classDef, VariableDefinitionNode variableDefinition)
	{
		//	patch original classdef's node stuff into generated variable def node
		variableDefinition.cx = classDef.cx;
		variableDefinition.pkgdef = classDef.pkgdef;
		variableDefinition.skipNode(true);
	}

	/**
	 * generated class may have interfaces that may be missing from original
	 */
	private void applyGeneratedInterfaces(GenerativeClassInfo classInfo, ClassDefinitionNode origClassDef, ClassDefinitionNode genClassDef)
	{
		if (classInfo.needsAdditionalInterfaces())
		{
			if (origClassDef.interfaces == null)
			{
				origClassDef.interfaces = genClassDef.interfaces;
			}
			else
			{
				if (genClassDef.interfaces != null)
				{
					ObjectList interfaces = genClassDef.interfaces.items;
					for (int i = 0; i < interfaces.size(); i++)
					{
						origClassDef.interfaces.items.add(genClassDef.interfaces.items.get(i));
					}
				}
			}
		}
	}

	/**
	 * This is called *after* TypeAnalyzer has collected reflection info on our class, but *before* the second pass
	 * over the syntax tree and subsequent code generation. It gives us a chance to do grooming/verification of
	 * generative stuff collected in the first pass, using reflection info. Currently that includes the following:
	 *
	 * <li>- strip non-read-write getter/setters from generative info
	 */
	protected void postProcessClassInfo(Context context, GenerativeClassInfo classInfo)
	{
		// [Bindable]/[Managed] getter/setters must be read-write, i.e. both getter and setter must be defined on the
		// class. It's overly complicated to verify this inline on the first pass, so here we simply verify that both
		// are present in the class sig.
		// If not, we remove them from the GenerativeClassInfo structure, so code won't be generated for them.
		// Also, if a non-read-write accessor has been defined explicitly (i.e. at property level), emit a warning.
		if (classInfo.getAccessors() != null)
		{
			for (Iterator iter = classInfo.getAccessors().entrySet().iterator(); iter.hasNext(); )
			{
				Map.Entry entry = (Map.Entry)iter.next();
				GenerativeClassInfo.AccessorInfo info = (GenerativeClassInfo.AccessorInfo)entry.getValue();

				if (info.getIsFunction())
				{
					String propName = info.getPropertyName();
					ClassInfo reflectionInfo = classInfo.getClassInfo();

					if (!reflectionInfo.definesGetter(propName, true))
					{
						if (info.getIsExplicit())
						{
							context.localizedWarning2(((GenerativeClassInfo.GetterSetterInfo)info).getSetterPosition(), new BindableOnWriteOnlySetter());
						}
						iter.remove();
					}
					else if (!reflectionInfo.definesSetter(propName, true))
					{
						if (info.getIsExplicit())
						{
							context.localizedWarning2(((GenerativeClassInfo.GetterSetterInfo)info).getGetterPosition(), new BindableOnReadOnlyGetter());
						}
						iter.remove();
					}
				}
			}
		}
	}

	/**
	 * CompilerMessages
	 */
	public static class BindableOnReadOnlyGetter extends CompilerMessage.CompilerWarning {

        private static final long serialVersionUID = -7879513353111728085L;}
	public static class BindableOnWriteOnlySetter extends CompilerMessage.CompilerWarning {

        private static final long serialVersionUID = 5285045188791977806L;}

	/**
	 * CompilerMessages
	 */
	public static class ExistingMethodError extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 3591535632396036477L;
        public String interfaceName, className, methodName;
		public ExistingMethodError(String interfaceName, String className, String methodName)
		{
			this.interfaceName = interfaceName;
			this.className = className;
			this.methodName = methodName;
		}
	}

	public static class TemplateLoadError extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -4500622167729742558L;
        public String templateName;
		public TemplateLoadError(String templateName) { this.templateName = templateName; }
	}

	public static class TemplateRunException extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -6388819951389806673L;
        public String templateName, className, exceptionText;
		public TemplateRunException(String templateName, String className, String exceptionText)
		{
			this.templateName = templateName;
			this.className = className;
			this.exceptionText = exceptionText;
			noPath();
		}
	}
}
