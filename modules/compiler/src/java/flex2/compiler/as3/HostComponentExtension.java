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
import flex2.compiler.CompilerContext;
import flex2.compiler.SymbolTable;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.abc.MetaData;
import flex2.compiler.abc.Method;
import flex2.compiler.abc.Variable;
import flex2.compiler.as3.binding.BindableExtension;
import flex2.compiler.as3.binding.BindableFirstPassEvaluator;
import flex2.compiler.as3.binding.ClassInfo;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.as3.genext.GenerativeFirstPassEvaluator;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;

import java.util.Iterator;
import java.util.List;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.DocCommentNode;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.StatementListNode;
import macromedia.asc.parser.TypeExpressionNode;
import macromedia.asc.parser.VariableDefinitionNode;
import macromedia.asc.util.Context;

/**
 * This class handles processing [HostComponent] metadata.
 *
 * @author Corey Lucier
 */
public final class HostComponentExtension implements Extension
{
    private static final String SKINHOSTCOMPONENT = "hostComponent".intern();
    private static final String BINDABLE = "Bindable".intern();
    private static final String[] PUBLIC_NAMESPACE = new String[] {SymbolTable.publicNamespace};

    private boolean reportMissingRequiredSkinPartsAsWarnings; // true generates a warning,
                                                              // false generates an error

    /**
     * @param reportMissingRequiredSkinPartsAsWarnings If true output a warning if any
     * required skin parts are missing. Otherwise an error is generated.
     */
    public HostComponentExtension(boolean reportMissingRequiredSkinPartsAsWarnings)
    {
        this.reportMissingRequiredSkinPartsAsWarnings = reportMissingRequiredSkinPartsAsWarnings;
    }

    public void parse1(CompilationUnit unit, TypeTable typeTable)
    {
        // Add a dependency on IEventDispatcher in parse1() so that it is
        // transferred in time to parent compilers from sub-compilers.
        // Theoretically, this dependency would be unnecessary if there is an
        // explicit hostComponent member that is not bindable and hence may not
        // need to be an IEventDispatcher, although this is unlikely given the
        // base Skin class from the framework implements IEventDispatcher.
        // We're comfortable with doing this because IEventDispatcher is player
        // runtime interface that isn't linked into a SWF. See SDK-29306
        if (unit.hostComponentMetaData != null)
        {
            unit.inheritance.add(new MultiName(StandardDefs.PACKAGE_FLASH_EVENTS, "IEventDispatcher"));
        }
    }

    public void parse2(CompilationUnit unit, TypeTable typeTable)
    {
        // HostComponentExtension processing should not be done in parse1
        // because getting the classInfo for a class during parse1
        // will pollute the symbol table when an ancestor class is defined in a
        // SWC. The polluted symbol table then causes the
        // BindableSecondPassEvaluator to assume the class does not already
        // implement IEventDispatcher. See SDK-25312
        if (unit.hostComponentMetaData != null)
        {
            CompilerContext context = unit.getContext();
            Context cx = (Context) context.getAscContext();
            TypeAnalyzer typeAnalyzer = typeTable.getSymbolTable().getTypeAnalyzer();
            generateHostComponentVariable(cx, unit, typeAnalyzer);
        }
    }

    public void analyze1(CompilationUnit unit, TypeTable typeTable)
    {
    }

    public void analyze2(CompilationUnit unit, TypeTable typeTable)
    {
    }

    public void analyze3(CompilationUnit unit, TypeTable typeTable)
    {
    }

    public void analyze4(CompilationUnit unit, TypeTable typeTable)
    {
    }

    public void generate(CompilationUnit unit, TypeTable typeTable)
    {
        if (unit.hostComponentMetaData != null)
        {
            CompilerContext context = unit.getContext();
            Context cx = (Context) context.getAscContext();
            validateRequiredSkinPartsAndStates(cx, unit, typeTable);
        }
    }

    /**
     * Generate a strongly typed variable 'hostComponent' on the current
     * class instance with type specified by the HostComponent metadata.
     */
    private void generateHostComponentVariable(Context cx, CompilationUnit unit, TypeAnalyzer typeAnalyzer)
    {
        MetaDataNode node = unit.hostComponentMetaData;

        if (node.count() == 1)
        {
            Node def = node.def;

            if (def instanceof ClassDefinitionNode)
            {
                unit.expressions.add(NameFormatter.toMultiName(node.getValue(0)));
                ClassDefinitionNode classDef = (ClassDefinitionNode) def;

                if (!classDeclaresIdentifier(cx, classDef, typeAnalyzer, SKINHOSTCOMPONENT))
                {
                    NodeFactory nodeFactory = cx.getNodeFactory();
                    MetaDataNode bindingMetaData = AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, BINDABLE);
                    bindingMetaData.setId(BINDABLE);
                    StatementListNode statementList = nodeFactory.statementList(classDef.statements, bindingMetaData);

                    int listSize = node.def.metaData.items.size();
                    // if the HostComponent metadata node has more than one items.
                    // then look for the associated comment and stick it to the variable.
                    if (listSize > 1)
                    {
                        for (int ix = 0; ix < listSize; ix++)
                        {
                            // check if the node is of type MetaDataNode.
                            Node tempMeta = node.def.metaData.items.get(ix);

                            if (tempMeta instanceof MetaDataNode)
                            {
                                MetaDataNode tempMetaData = (MetaDataNode) tempMeta;

                                if ("HostComponent".equals(tempMetaData.getId()) && (ix < listSize - 1))
                                {
                                    // if the node has the comment, it would be the next one.
                                    Node temp = node.def.metaData.items.get(ix + 1);

                                    // if the last one is a DocCommentnode, we can run it through the evaluator.
                                    if (temp instanceof DocCommentNode)
                                    {
                                        DocCommentNode tempDoc = ((DocCommentNode)temp);

                                        // we can not access the metadata node directly because it doesn't
                                        // have public access and it is buried deep into the tree.  this is
                                        // required so that we can access the comment easily.
                                        macromedia.asc.parser.MetaDataEvaluator evaluator =
                                            new macromedia.asc.parser.MetaDataEvaluator();
                                        evaluator.evaluate(cx, tempDoc);

                                        // if evaluator has not null comment.
                                        if (evaluator.doccomments != null && evaluator.doccomments.size() != 0)
                                        {
                                            String comment = evaluator.doccomments.get(0).getId();

                                            // if comment is present then create a DocCommentNode for the hostComponent variable
                                            if (comment != null)
                                            {
                                                DocCommentNode hostComponentComment =
                                                    AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, comment.intern());

                                                if (hostComponentComment != null)
                                                {
                                                    statementList = nodeFactory.statementList(statementList, hostComponentComment);
                                                }
                                            }
                                        }

                                        break; // if we got here we already got the comment. now lets short circuit.
                                    }
                                }
                            }
                        }
                    }

                    TypeExpressionNode typeExpression = AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory, node.getValue(0), true);
                    VariableDefinitionNode variableDefinition = AbstractSyntaxTreeUtil.generatePublicVariable(cx, typeExpression, SKINHOSTCOMPONENT);

                    classDef.statements = nodeFactory.statementList(statementList, variableDefinition);
                    
                    
                    BindableFirstPassEvaluator firstPassEvaluator =
                        (BindableFirstPassEvaluator) unit.getContext().getAttribute(BindableExtension.FIRST_PASS_EVALUATOR_KEY);
                    if (firstPassEvaluator != null)
                    	firstPassEvaluator.registerBindableVariable(cx, classDef, variableDefinition);
                }
            }
        }
    }

    /**
     * Returns true if the class definition has previously declared a symbol (function or variable) with
     * the identifier provided.
     */
    private boolean classDeclaresIdentifier(Context cx, ClassDefinitionNode classDef,
                                            TypeAnalyzer typeAnalyzer, String identifier)
    {
        String className = NodeMagic.getClassName(classDef);

        typeAnalyzer.evaluate(cx, classDef);

        ClassInfo classInfo = typeAnalyzer.getClassInfo(className);
        if (classInfo != null && (
            classInfo.definesVariable(identifier) ||
            classInfo.definesFunction(identifier, true) ||
            classInfo.definesGetter(identifier, true) ||
            classInfo.definesSetter(identifier, true)))
        {
            return true;
        }
        return false;
    }

    private void validateRequiredSkinParts(AbcClass hostComponentClass, AbcClass skinClass,
                                           Context cx, int position, TypeTable typeTable)
    {
        Iterator<Variable> variables = hostComponentClass.getVarIterator();

        while (variables.hasNext())
        {
            Variable variable = variables.next();

            List<MetaData> skinPartsMetaDataList = variable.getMetaData("SkinPart");

            if (skinPartsMetaDataList != null)
            {
                validateRequiredSkinParts(skinPartsMetaDataList, variable.getQName().getLocalPart(),
                                          variable.getTypeName(), skinClass, typeTable, cx, position);
            }
        }

        Iterator<Method> get_iter = hostComponentClass.getGetterIterator();

        while ( get_iter.hasNext() )
        {
            Method getter = get_iter.next();

            List<MetaData> skinPartsMetaDataList = getter.getMetaData("SkinPart");

            if (skinPartsMetaDataList != null)
            {
                validateRequiredSkinParts(skinPartsMetaDataList, getter.getQName().getLocalPart(),
                                          getter.getReturnTypeName(), skinClass, typeTable, cx, position);
            }
        }

        // Validate up the inheritance chain
        String superTypeName = hostComponentClass.getSuperTypeName();

        if (superTypeName != null)
        {
            AbcClass superType = typeTable.getClass(superTypeName);

            if (superType != null)
            {
                validateRequiredSkinParts(superType, skinClass, cx, position, typeTable);
            }
        }
    }

    private void validateRequiredSkinParts(List<MetaData> skinPartsMetaDataList, String hostSkinPartName,
                                           String hostSkinPartTypeName, AbcClass skinClass, TypeTable typeTable,
                                           Context cx, int position)
    {
        for (MetaData skinPartsMetaData : skinPartsMetaDataList)
        {
            String skinPartTypeName = null;

            Variable variable = skinClass.getVariable(PUBLIC_NAMESPACE, hostSkinPartName, true);

            if (variable != null)
            {
                skinPartTypeName = variable.getTypeName();
            }
            else
            {
                Method getter = skinClass.getGetter(PUBLIC_NAMESPACE, hostSkinPartName, true);

                if (getter != null)
                {
                    skinPartTypeName = getter.getReturnTypeName();
                }
            }

            String required = skinPartsMetaData.getValue("required");

            if ("true".equals(required) && skinPartTypeName == null)
            {
                if (reportMissingRequiredSkinPartsAsWarnings)
                {
                    cx.localizedWarning2(cx.input.origin, position, new MissingSkinPartWarning(hostSkinPartName));
                }
                else
                {
                    cx.localizedError2(cx.input.origin, position, new MissingSkinPart(hostSkinPartName));
                }
            }
            else if ((skinPartTypeName != null) &&
                     !typeTable.getClass(NameFormatter.toColon(skinPartTypeName)).isSubclassOf(hostSkinPartTypeName))
            {
                cx.localizedError2(cx.input.origin, position, new WrongSkinPartType(skinPartTypeName, hostSkinPartTypeName));
            }
        }
    }

    private void validateRequiredSkinPartsAndStates(Context cx, CompilationUnit unit, TypeTable typeTable)
    {
    	MetaDataNode metaData = unit.hostComponentMetaData;
        String hostComponentClassName = metaData.getValue(0);
        AbcClass hostComponentClass = typeTable.getClass(NameFormatter.toColon(hostComponentClassName));

        if (hostComponentClass == null)
        {
            cx.localizedError2(cx.input.origin, metaData.pos(),
                               new HostComponentClassNotFound(hostComponentClassName));
        }
        else if (unit.hostComponentOwnerClass != null)
        {
            AbcClass skinClass = typeTable.getClass(unit.hostComponentOwnerClass);
            validateRequiredSkinParts(hostComponentClass, skinClass, cx, metaData.pos(), typeTable);
            validateRequiredSkinStates(hostComponentClass, skinClass, cx, metaData.pos());
        }
    }

    private void validateRequiredSkinStates(AbcClass hostComponentClass, AbcClass skinClass,
                                            Context cx, int position)
    {
        List<MetaData> skinStatesMetaDataList = hostComponentClass.getMetaData("SkinState", true);
        List<MetaData> statesMetaDataList = skinClass.getMetaData("States", true);

        if (skinStatesMetaDataList != null)
        {
            for (MetaData skinStatesMetaData : skinStatesMetaDataList)
            {
                String skinStateName = skinStatesMetaData.getValue(0);
                boolean isFound = false;

                if (statesMetaDataList != null)
                {
                    foundIt:
                    for (MetaData statesMetaData : statesMetaDataList)
                    {
                        for (int i = 0, count = statesMetaData.count(); i < count; i++)
                        {
                            String state = statesMetaData.getValue(i);

                            if (skinStateName.equals(state))
                            {
                                isFound = true;
                                break foundIt;
                            }
                        }
                    }
                }

                if (!isFound)
                {
                    cx.localizedError2(cx.input.origin, position, new MissingSkinState(skinStateName));
                }
            }
        }
    }

    public static class HostComponentClassNotFound extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 5290330001936137678L;

        public String className;

        public HostComponentClassNotFound(String className)
        {
            this.className = className;
        }
    }

    public static class MissingSkinPart extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 5290330001936137667L;

        public String skinPartName;

        public MissingSkinPart(String skinPartName)
        {
            this.skinPartName = skinPartName;
        }
    }

    public static class MissingSkinPartWarning extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 5290330001936137667L;

        public String skinPartName;

        public MissingSkinPartWarning(String skinPartName)
        {
            this.skinPartName = skinPartName;
        }
    }

    public static class MissingSkinState extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 5290330001936137669L;

        public String skinStateName;

        public MissingSkinState(String skinStateName)
        {
            this.skinStateName = skinStateName;
        }
    }

    public static class WrongSkinPartType extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 5290330001936137670L;

        public String skinPartTypeName;
        public String hostSkinPartTypeName;

        public WrongSkinPartType(String skinPartTypeName, String hostSkinPartTypeName)
        {
            this.skinPartTypeName = skinPartTypeName;
            this.hostSkinPartTypeName = hostSkinPartTypeName;
        }
    }
}
