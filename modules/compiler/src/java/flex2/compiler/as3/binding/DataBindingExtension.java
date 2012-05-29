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

package flex2.compiler.as3.binding;

import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerContext;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.Extension;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.TextFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.SourceCodeBuffer;
import flex2.compiler.mxml.gen.VelocityUtil;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.util.*;
import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.ObjectList;
import org.apache.flex.forks.velocity.Template;
import org.apache.flex.forks.velocity.VelocityContext;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * This compiler extension handles running the
 * DataBindingFirstPassEvaluator during the generate phase and
 * generating watchers if the original MXML document contained one or more data
 * binding expressions.
 *
 * @author Paul Reilly
 */
public final class DataBindingExtension implements Extension
{
    private static final String TEMPLATE_PATH = "flex2/compiler/as3/binding/";
    private static final String DATA_BINDING_INFO_KEY = "dataBindingInfo";

    private static final String DOT = ".";
    private static final String DOT_AS = ".as";
    private static final String EMPTY_STRING = "";

    // intern all identifier constants
    private static final String ADD_CHILD = "addChild".intern();
    private static final String APPLY = "apply".intern();
    private static final String ARRAY = "Array".intern();
    private static final String ARRAY_ELEMENT_WATCHER = "ArrayElementWatcher".intern();
    private static final String ARRAY_WATCHER = "arrayWatcher".intern();
    private static final String BINDINGS = "bindings".intern();
    private static final String EXCLUDE_CLASS = "ExcludeClass".intern();
    private static final String FBS = "fbs".intern();
    private static final String FUNCTION = "Function".intern();
    private static final String FUNCTION_RETURN_WATCHER = "FunctionReturnWatcher".intern();
    private static final String IFLEX_MODULE_FACTORY = "IFlexModuleFactory".intern();
    private static final String INIT = "init".intern();
    private static final String IWATCHER_SETUP_UTIL2 = "IWatcherSetupUtil2".intern();
    private static final String OBJECT = "Object".intern();
    private static final String PARENT_WATCHER = "parentWatcher".intern();
    private static final String PROPERTY_GETTER = "propertyGetter".intern();
    private static final String PROPERTY_WATCHER = "PropertyWatcher".intern();
    private static final String REPEATER_COMPONENT_WATCHER = "RepeaterComponentWatcher".intern();
    private static final String REPEATER_ITEM_WATCHER = "RepeaterItemWatcher".intern();
    private static final String SETUP = "setup".intern();
    private static final String STATIC_PROPERTY_GETTER = "staticPropertyGetter".intern();
    private static final String STATIC_PROPERTY_WATCHER = "StaticPropertyWatcher".intern();
    private static final String TARGET = "target".intern();
    private static final String UPDATE_PARENT = "updateParent".intern();
    private static final String WATCHERS = "watchers".intern();
    private static final String WATCHER_SETUP_UTIL = "watcherSetupUtil".intern();
    private static final String XML_WATCHER = "XMLWatcher".intern();

    private String generatedOutputDirectory;
    private boolean showBindingWarnings;
    private boolean generateAbstractSyntaxTree;
    private ObjectList<ConfigVar> defines;

    public DataBindingExtension(String generatedOutputDirectory, boolean showBindingWarnings,
                                boolean generateAbstractSyntaxTree, ObjectList<ConfigVar> defines)
    {
        this.generatedOutputDirectory = generatedOutputDirectory;
        this.showBindingWarnings = showBindingWarnings;
        this.generateAbstractSyntaxTree = generateAbstractSyntaxTree;
        this.defines = defines;
    }

    public void parse1(CompilationUnit compilationUnit, TypeTable typeTable)
    {
    }

    public void parse2(CompilationUnit compilationUnit, TypeTable typeTable)
    {
    }

    public void analyze1(CompilationUnit compilationUnit, TypeTable typeTable)
    {
    }

    public void analyze2(CompilationUnit compilationUnit, TypeTable typeTable)
    {
    }

    public void analyze3(CompilationUnit compilationUnit, TypeTable typeTable)
    {
    }

    public void analyze4(CompilationUnit compilationUnit, TypeTable typeTable)
    {
    }

    public void generate(CompilationUnit compilationUnit, TypeTable typeTable)
    {
        CompilerContext context = compilationUnit.getContext();
        Context cx = context.getAscContext();
        Node node = (Node) compilationUnit.getSyntaxTree();
        DataBindingFirstPassEvaluator dataBindingFirstPassEvaluator =
            new DataBindingFirstPassEvaluator(compilationUnit, typeTable, showBindingWarnings);

        node.evaluate(cx, dataBindingFirstPassEvaluator);

        List dataBindingInfoList = dataBindingFirstPassEvaluator.getDataBindingInfoList();

        if (dataBindingInfoList.size() > 1)
        {
            assert false : compilationUnit.getSource().getName();
        }

        if (dataBindingInfoList.size() > 0)
        {
	        // watcher setup classes should match the originating source timestamp.
            Map<QName, Source> generatedSources = generateWatcherSetupUtilClasses(compilationUnit,
                                                                   typeTable.getSymbolTable(),
                                                                   dataBindingInfoList);
            compilationUnit.addGeneratedSources(generatedSources);
        }
    }

    /**
     *
     */
    private Source createSource(String fileName, String shortName, long lastModified,
    							PathResolver resolver, SourceCodeBuffer sourceCodeBuffer)
    {
        Source result = null;

        if (sourceCodeBuffer.getBuffer() != null)
        {
            String sourceCode = sourceCodeBuffer.toString();

            if (generatedOutputDirectory != null)
            {
                try
                {
                    FileUtil.writeFile(generatedOutputDirectory + File.separatorChar + fileName, sourceCode);
                }
                catch (IOException e)
                {
                    ThreadLocalToolkit.log(new VelocityException.UnableToWriteGeneratedFile(fileName, e.getMessage()));
                }
            }

			VirtualFile generatedFile = new TextFile(sourceCode, fileName, null, MimeMappings.AS, lastModified);

            result = new Source(generatedFile,
                                "",
                                shortName,
                                null,
                                false,
                                false,
                                false);
            result.setPathResolver(resolver);
        }

        return result;
    }

    private FunctionCommonNode generateAccessorFunction(NodeFactory nodeFactory, Context cx,
                                                        HashSet<String> configNamespaces,
                                                        ArrayElementWatcher arrayElementWatcher)
    {
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);

        List<Node> nodeList = AbstractSyntaxTreeUtil.parseExpression(cx, configNamespaces,
                                                                     arrayElementWatcher.getEvaluationPart());
        ListNode list = null;

        assert (nodeList.size() == 0) || (nodeList.size() == 1) : nodeList.size();

        if (!nodeList.isEmpty())
        {
            ExpressionStatementNode expressionStatement = (ExpressionStatementNode) nodeList.get(0);
            list = (ListNode) expressionStatement.expr;
        }

        ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
        StatementListNode statementList = nodeFactory.statementList(null, returnStatement);

        return nodeFactory.functionCommon(cx, null, functionSignature, statementList);
    }

    private FunctionCommonNode generateAccessorFunction(NodeFactory nodeFactory, Context cx,
                                                        HashSet<String> configNamespaces,
                                                        FunctionReturnWatcher functionReturnWatcher)
    {
        MemberExpressionNode memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ARRAY, false);
        TypeExpressionNode returnType = nodeFactory.typeExpression(memberExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);

        List<Node> nodeList = AbstractSyntaxTreeUtil.parseExpression(cx, configNamespaces,
                                                                     functionReturnWatcher.getEvaluationPart());
        ArgumentListNode argumentList = null;

        assert (nodeList.size() == 0) || (nodeList.size() == 1) : nodeList.size();

        if (!nodeList.isEmpty())
        {
            ExpressionStatementNode expressionStatement = (ExpressionStatementNode) nodeList.get(0);
            ListNode list = (ListNode) expressionStatement.expr;
            Iterator<Node> iterator = list.items.iterator();

            while (iterator.hasNext())
            {
                argumentList = nodeFactory.argumentList(argumentList, iterator.next());
            }
        }

        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        ListNode outerList = nodeFactory.list(null, literalArray);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(outerList);
        StatementListNode statementList = nodeFactory.statementList(null, returnStatement);

        return nodeFactory.functionCommon(cx, null, functionSignature, statementList);
    }

    private ExpressionStatementNode generateAddChild(NodeFactory nodeFactory, Watcher watcher)
    {
        MemberExpressionNode watchersMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);

        GetExpressionNode getExpression = generateArrayIndex(nodeFactory, watcher.getParent().getId());
        getExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode base = nodeFactory.memberExpression(watchersMemberExpression, getExpression);

        IdentifierNode identifier = nodeFactory.identifier(ADD_CHILD, false);
        MemberExpressionNode childBase = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode childSelector = generateArrayIndex(nodeFactory, watcher.getId());
        childSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode childMemberExpression = nodeFactory.memberExpression(childBase, childSelector);

        ArgumentListNode args = nodeFactory.argumentList(null, childMemberExpression);
        CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(identifier, args);
        selector.setRValue(false);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private GetExpressionNode generateArrayIndex(NodeFactory nodeFactory, int index)
    {
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(index);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalNumber);
        return nodeFactory.getExpression(argumentList);
    }

    private Node generateChangeEvents(NodeFactory nodeFactory, Watcher watcher)
    {
        Node result;
        Iterator<ChangeEvent> iterator = watcher.getChangeEvents().iterator();

        if (iterator.hasNext())
        {
            ArgumentListNode argumentList = null;

            while (iterator.hasNext())
            {
                ChangeEvent changeEvent = iterator.next();
                IdentifierNode identifierNode = nodeFactory.identifier(changeEvent.getName());
                LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(changeEvent.getCommitting());
                LiteralFieldNode literalField = nodeFactory.literalField(identifierNode, literalBoolean);
                argumentList = nodeFactory.argumentList(argumentList, literalField);
            }

            result = nodeFactory.literalObject(argumentList);
        }
        else
        {
            result = nodeFactory.literalNull();
        }

        return result;
    }

    private ClassDefinitionNode generateClassDefinition(Context cx, HashSet<String> configNamespaces,
                                                        String name, DataBindingInfo dataBindingInfo,
                                                        StandardDefs standardDefs)
    {
        NodeFactory nodeFactory = cx.getNodeFactory();
        nodeFactory.StartClassDefs();
        MemberExpressionNode iWatcherSetupUtilMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, standardDefs.getBindingPackage(), IWATCHER_SETUP_UTIL2, false);
        ListNode interfaces = nodeFactory.list(null, iWatcherSetupUtilMemberExpression);
        InheritanceNode inheritance = nodeFactory.inheritance(null, interfaces);

        FunctionDefinitionNode constructorFunctionDefinition =
            AbstractSyntaxTreeUtil.generateConstructor(cx, name, null, true, null, -1);
        StatementListNode statementList = nodeFactory.statementList(null, constructorFunctionDefinition);

        FunctionCommonNode initFunctionCommon = generateInitFunctionCommon(nodeFactory, cx, dataBindingInfo);
        initFunctionCommon.setUserDefinedBody(true);
        FunctionDefinitionNode initFunctionDefinition = generateInitFunctionDefinition(nodeFactory, cx, initFunctionCommon);
        statementList = nodeFactory.statementList(statementList, initFunctionDefinition);

        FunctionCommonNode setupFunctionCommon = generateSetupFunctionCommon(nodeFactory, cx, configNamespaces,
                                                                             dataBindingInfo, standardDefs);
        setupFunctionCommon.setUserDefinedBody(true);
        FunctionDefinitionNode setupFunctionDefinition = generateSetupFunctionDefinition(nodeFactory, cx, setupFunctionCommon);
        statementList = nodeFactory.statementList(statementList, setupFunctionDefinition);

        ClassDefinitionNode classDefinition =
            nodeFactory.classDefinition(cx,
                                        AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory),
                                        AbstractSyntaxTreeUtil.generatePublicQualifiedIdentifier(nodeFactory, name),
                                        inheritance,
                                        statementList);

        return classDefinition;
    }

    private ExpressionStatementNode generateEvaluationWatcherPart(NodeFactory nodeFactory,
                                                                  EvaluationWatcher evaluationWatcher)
    {
        MemberExpressionNode watchersBase = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode watchersSelector = generateArrayIndex(nodeFactory, evaluationWatcher.getId());
        MemberExpressionNode watcherBase = nodeFactory.memberExpression(watchersBase, watchersSelector);
        watchersSelector.setMode(Tokens.LEFTBRACKET_TOKEN);

        IdentifierNode parentVariableIdentifier = null;

        if (evaluationWatcher instanceof ArrayElementWatcher)
        {
            parentVariableIdentifier = nodeFactory.identifier(ARRAY_WATCHER, false);
        }
        else if (evaluationWatcher instanceof FunctionReturnWatcher)
        {
            parentVariableIdentifier = nodeFactory.identifier(PARENT_WATCHER, false);
        }
        else
        {
            assert false : "Unhandled EvaluationWatcher type: " + evaluationWatcher.getClass().getName();
        }

        MemberExpressionNode parentWatchersBase =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode parentWatchersSelector = generateArrayIndex(nodeFactory, evaluationWatcher.getParent().getId());
        parentWatchersSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode parentWatcherBase = nodeFactory.memberExpression(parentWatchersBase, parentWatchersSelector);

        ArgumentListNode argumentList = nodeFactory.argumentList(null, parentWatcherBase);
        SetExpressionNode setExpression = nodeFactory.setExpression(parentVariableIdentifier, argumentList, false);
        setExpression.setMode(Tokens.DOT_TOKEN);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(watcherBase, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private FunctionCommonNode generateInitFunctionCommon(NodeFactory nodeFactory, Context cx,
                                                          DataBindingInfo dataBindingInfo)
    {
        ParameterNode parameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, FBS, IFLEX_MODULE_FACTORY, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        String className = dataBindingInfo.getClassName();

        ImportDirectiveNode importDirective = AbstractSyntaxTreeUtil.generateImport(cx, className);
        StatementListNode statementList = nodeFactory.statementList(null, importDirective);

        int index = className.lastIndexOf(DOT);
        ListNode base;

        if (index > 0)
        {
            base = nodeFactory.list(null, AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className.substring(0, index),
                                                                                        className.substring(index + 1), true));
        }
        else
        {
            base = nodeFactory.list(null, AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, true));
        }

        IdentifierNode watcherSetupUtilIdentifier = nodeFactory.identifier(WATCHER_SETUP_UTIL, false);
        IdentifierNode watcherSetupUtilClassIdentifier = nodeFactory.identifier(dataBindingInfo.getWatcherSetupUtilClassName());
        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(watcherSetupUtilClassIdentifier, null);
        callExpression.setRValue(false);
        callExpression.is_new = true;

        MemberExpressionNode newMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, newMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(watcherSetupUtilIdentifier, argumentList, false);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        statementList = nodeFactory.statementList(statementList, expressionStatement);

        return nodeFactory.functionCommon(cx, null, functionSignature, statementList);
    }

    private FunctionDefinitionNode generateInitFunctionDefinition(NodeFactory nodeFactory, Context cx,
                                                                  FunctionCommonNode functionCommon)
    {
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicStaticAttribute(nodeFactory);
        IdentifierNode identifier = nodeFactory.identifier(INIT, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, identifier);
        return nodeFactory.functionDefinition(cx, attributeList, functionName, functionCommon);
    }

    private LiteralArrayNode generateListener(NodeFactory nodeFactory, int id)
    {
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BINDINGS, false);
        GetExpressionNode selector = generateArrayIndex(nodeFactory, id);
        selector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);

        return nodeFactory.literalArray(argumentList);
    }

    private LiteralArrayNode generateListeners(NodeFactory nodeFactory, PropertyWatcher propertyWatcher)
    {
        ArgumentListNode argumentList = null;
        Iterator<BindingExpression> iterator = propertyWatcher.getBindingExpressions().iterator();

        while (iterator.hasNext())
        {
            BindingExpression bindingExpression = iterator.next();
            MemberExpressionNode base =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BINDINGS, false);
            GetExpressionNode selector = generateArrayIndex(nodeFactory, bindingExpression.getId());
            selector.setMode(Tokens.LEFTBRACKET_TOKEN);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            argumentList = nodeFactory.argumentList(argumentList, memberExpression);
        }

        return nodeFactory.literalArray(argumentList);
    }

    private MemberExpressionNode generatePath(NodeFactory nodeFactory, String path)
    {
        int index = path.lastIndexOf(DOT);
        String string;
        Node base;

        if (index > 0)
        {
            string = path.substring(index + 1);
            base = generatePath(nodeFactory, path.substring(0, index));
        }
        else
        {
            string = path;
            base = null;
        }

        IdentifierNode identifier = nodeFactory.identifier(string);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
        getExpression.setMode(Tokens.DOT_TOKEN);

        return nodeFactory.memberExpression(base, getExpression);
    }

    private StatementListNode generateRootWatcherBottom(NodeFactory nodeFactory, Context cx,
                                                        StatementListNode statementList, Watcher watcher)
    {
        StatementListNode result = statementList;
        MemberExpressionNode watchersMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode getExpression = generateArrayIndex(nodeFactory, watcher.getId());
        getExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode base = nodeFactory.memberExpression(watchersMemberExpression, getExpression);

        IdentifierNode identifier = nodeFactory.identifier(UPDATE_PARENT, false);
        MemberExpressionNode parentMemberExpression;
        String className = watcher.getClassName();

        if (className != null)
        {
            result = nodeFactory.statementList(result, AbstractSyntaxTreeUtil.generateImport(cx, className));

            int index = className.lastIndexOf(DOT);

            if (index > 0)
            {
                parentMemberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                                  className.substring(0, index),
                                                                  className.substring(index + 1),
                                                                  true);
            }
            else
            {
                parentMemberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, true);
            }
        }
        else
        {
            parentMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TARGET, false);
        }

        ArgumentListNode args = nodeFactory.argumentList(null, parentMemberExpression);
        CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(identifier, args);
        selector.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        result = nodeFactory.statementList(result, expressionStatement);
        return result;
    }

    private FunctionCommonNode generateSetupFunctionCommon(NodeFactory nodeFactory, Context cx,
                                                           HashSet<String> configNamespaces,
                                                           DataBindingInfo dataBindingInfo,
                                                           StandardDefs standardDefs)
    {
        ParameterListNode parameterList = null;

        ParameterNode targetParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, TARGET, OBJECT, false);
        parameterList = nodeFactory.parameterList(parameterList, targetParameter);
        ParameterNode propertyGetterParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, PROPERTY_GETTER, FUNCTION, false);
        parameterList = nodeFactory.parameterList(parameterList, propertyGetterParameter);
        ParameterNode staticPropertyGetterParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, STATIC_PROPERTY_GETTER, FUNCTION, false);
        parameterList = nodeFactory.parameterList(parameterList, staticPropertyGetterParameter);
        ParameterNode bindingsParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, BINDINGS, ARRAY, false);
        parameterList = nodeFactory.parameterList(parameterList, bindingsParameter);
        ParameterNode watchersParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, WATCHERS, ARRAY, false);
        parameterList = nodeFactory.parameterList(parameterList, watchersParameter);

        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        StatementListNode statementList = null;

        Iterator<String> importIterator = dataBindingInfo.getImports().iterator();

        while (importIterator.hasNext())
        {
            ImportDirectiveNode importDirective = AbstractSyntaxTreeUtil.generateImport(cx, importIterator.next());
            statementList = nodeFactory.statementList(statementList, importDirective);
        }

        Iterator<Watcher> iterator = dataBindingInfo.getRootWatchers().values().iterator();

        while (iterator.hasNext())
        {
            Watcher watcher = iterator.next();

            if (watcher.shouldWriteSelf())
            {
                if (watcher instanceof ArrayElementWatcher)
                {
                    ArrayElementWatcher arrayElementWatcher = (ArrayElementWatcher) watcher;
                    statementList = generateWatcher(nodeFactory, cx, configNamespaces, statementList,
                                                    arrayElementWatcher, standardDefs);
                }
                else if (watcher instanceof FunctionReturnWatcher)
                {
                    FunctionReturnWatcher functionReturnWatcher = (FunctionReturnWatcher) watcher;
                    statementList = generateWatcher(nodeFactory, cx, configNamespaces, statementList,
                                                    functionReturnWatcher, standardDefs);
                }
                else if (watcher instanceof RepeaterComponentWatcher)
                {
                    RepeaterComponentWatcher repeaterComponentWatcher = (RepeaterComponentWatcher) watcher;
                    statementList = generateWatcher(nodeFactory, statementList, repeaterComponentWatcher, standardDefs);
                }
                else if (watcher instanceof RepeaterItemWatcher)
                {
                    RepeaterItemWatcher repeaterItemWatcher = (RepeaterItemWatcher) watcher;
                    statementList = generateWatcher(nodeFactory, cx, statementList, repeaterItemWatcher, standardDefs);
                }
                else if (watcher instanceof XMLWatcher)
                {
                    XMLWatcher xmlWatcher = (XMLWatcher) watcher;
                    statementList = generateWatcher(nodeFactory, statementList, xmlWatcher, standardDefs);
                }
                else if (watcher instanceof PropertyWatcher)
                {
                    PropertyWatcher propertyWatcher = (PropertyWatcher) watcher;
                    statementList = generateWatcher(nodeFactory, cx, statementList, propertyWatcher, standardDefs,
                                                    dataBindingInfo.getClassName());
                }
                else
                {
                    assert false : "Unhandled Watcher type: " + watcher.getClass().getName();
                }
            }

            if (watcher.shouldWriteChildren())
            {
                statementList = generateWatcherChildren(nodeFactory, cx, configNamespaces,
                                                        statementList, watcher, standardDefs,
                                                        dataBindingInfo.getClassName());
            }
        }

        iterator = dataBindingInfo.getRootWatchers().values().iterator();

        while (iterator.hasNext())
        {
            Watcher watcher = iterator.next();
            statementList = generateWatcherBottom(nodeFactory, cx, statementList, watcher);
        }

        return nodeFactory.functionCommon(cx, null, functionSignature, statementList);
    }

    private FunctionDefinitionNode generateSetupFunctionDefinition(NodeFactory nodeFactory, Context cx,
                                                                   FunctionCommonNode functionCommon)
    {
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);
        IdentifierNode identifier = nodeFactory.identifier(SETUP, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, identifier);
        return nodeFactory.functionDefinition(cx, attributeList, functionName, functionCommon);
    }

    private ExpressionStatementNode generateUpdateParentProperty(NodeFactory nodeFactory, int watcherId, PropertyWatcher parent)
    {
        MemberExpressionNode watchersBase = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode idSelector = generateArrayIndex(nodeFactory, watcherId);
        idSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode watcherBase = nodeFactory.memberExpression(watchersBase, idSelector);

        IdentifierNode updateParentIdentifier = nodeFactory.identifier(UPDATE_PARENT, false);
        MemberExpressionNode parentMemberExpression = generatePath(nodeFactory, TARGET + DOT + parent.getPathToProperty());
        ArgumentListNode args = nodeFactory.argumentList(null, parentMemberExpression);
        CallExpressionNode updateParentSelector = (CallExpressionNode) nodeFactory.callExpression(updateParentIdentifier, args);
        updateParentSelector.setRValue(false);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(watcherBase, updateParentSelector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private ExpressionStatementNode generateUpdateParentPrivateProperty(NodeFactory nodeFactory, int watcherId,
                                                                        PropertyWatcher parent)
    {
        MemberExpressionNode watchersBase =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode idSelector = generateArrayIndex(nodeFactory, watcherId);
        idSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode watcherBase = nodeFactory.memberExpression(watchersBase, idSelector);

        IdentifierNode updateParentIdentifier = nodeFactory.identifier(UPDATE_PARENT, false);

        MemberExpressionNode propertyGetterBase =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PROPERTY_GETTER, false);
        IdentifierNode applyIdentifier = nodeFactory.identifier(APPLY, false);
        IdentifierNode targetIdentifier = nodeFactory.identifier(TARGET, false);
        ArgumentListNode applyArgs = nodeFactory.argumentList(null, targetIdentifier);
        LiteralStringNode literalString = nodeFactory.literalString(parent.getProperty());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        applyArgs = nodeFactory.argumentList(applyArgs, literalArray);
        CallExpressionNode propertyGetterSelector = (CallExpressionNode) nodeFactory.callExpression(applyIdentifier, applyArgs);
        propertyGetterSelector.setRValue(false);
        MemberExpressionNode propertyGetterMemberExpression = nodeFactory.memberExpression(propertyGetterBase, propertyGetterSelector);

        ArgumentListNode updateParentArgs = nodeFactory.argumentList(null, propertyGetterMemberExpression);
        CallExpressionNode updateParentSelector = (CallExpressionNode) nodeFactory.callExpression(updateParentIdentifier, updateParentArgs);
        updateParentSelector.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(watcherBase, updateParentSelector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private ExpressionStatementNode generateUpdateParentStaticProperty(NodeFactory nodeFactory, int watcherId,
                                                                       PropertyWatcher parent)
    {
        MemberExpressionNode watchersBase =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        GetExpressionNode idSelector = generateArrayIndex(nodeFactory, watcherId);
        idSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode watcherBase = nodeFactory.memberExpression(watchersBase, idSelector);

        IdentifierNode updateParentIdentifier = nodeFactory.identifier(UPDATE_PARENT, false);
        MemberExpressionNode parentMemberExpression = generatePath(nodeFactory, parent.getClassName() + DOT + parent.getPathToProperty());
        ArgumentListNode args = nodeFactory.argumentList(null, parentMemberExpression);
        CallExpressionNode updateParentSelector = (CallExpressionNode) nodeFactory.callExpression(updateParentIdentifier, args);
        updateParentSelector.setRValue(false);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(watcherBase, updateParentSelector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private StatementListNode generateWatcher(NodeFactory nodeFactory, Context cx,
                                              HashSet<String> configNamespaces,
                                              StatementListNode statementList,
                                              ArrayElementWatcher arrayElementWatcher,
                                              StandardDefs standardDefs)
    {
        StatementListNode result = statementList;

        // Only generate a watcher for the Array element if it will
        // have children, because an Array element watcher will not
        // ever receive a change event.  This is due to our inability
        // to add data binding support to Array.
        if (arrayElementWatcher.shouldWriteChildren())
        {
            MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);

            QualifiedIdentifierNode qualifiedIdentifier =
                AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), ARRAY_ELEMENT_WATCHER, false);

            LiteralNumberNode literalNumber = nodeFactory.literalNumber(arrayElementWatcher.getId());
            ArgumentListNode expression = nodeFactory.argumentList(null, literalNumber);

            MemberExpressionNode targetMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TARGET, false);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, targetMemberExpression);
            argumentList = nodeFactory.argumentList(argumentList, generateAccessorFunction(nodeFactory, cx, configNamespaces,
                                                                                           arrayElementWatcher));
            int listenerId = arrayElementWatcher.getBindingExpression().getId();
            argumentList = nodeFactory.argumentList(argumentList, generateListener(nodeFactory, listenerId));

            CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, argumentList);
            callExpression.setRValue(false);
            callExpression.is_new = true;
            MemberExpressionNode callMemberExpression = nodeFactory.memberExpression(null, callExpression);
            ArgumentListNode args = nodeFactory.argumentList(null, callMemberExpression);
            SetExpressionNode selector = nodeFactory.setExpression(expression, args, false);
            selector.setMode(Tokens.LEFTBRACKET_TOKEN);

            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);
        }

        return result;
    }

    private StatementListNode generateWatcher(NodeFactory nodeFactory, Context cx,
                                              HashSet<String> configNamespaces,
                                              StatementListNode statementList,
                                              FunctionReturnWatcher functionReturnWatcher,
                                              StandardDefs standardDefs)
    {
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);

        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), FUNCTION_RETURN_WATCHER, false);

        LiteralNumberNode literalNumber = nodeFactory.literalNumber(functionReturnWatcher.getId());
        ArgumentListNode expression = nodeFactory.argumentList(null, literalNumber);

        LiteralStringNode literalString = nodeFactory.literalString(functionReturnWatcher.getFunctionName());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        MemberExpressionNode targetMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TARGET, false);
        argumentList = nodeFactory.argumentList(argumentList, targetMemberExpression);
        argumentList = nodeFactory.argumentList(argumentList, generateAccessorFunction(nodeFactory, cx, configNamespaces,
                                                                                       functionReturnWatcher));
        argumentList = nodeFactory.argumentList(argumentList, generateChangeEvents(nodeFactory, functionReturnWatcher));

        int listenerId = functionReturnWatcher.getBindingExpression().getId();
        argumentList = nodeFactory.argumentList(argumentList, generateListener(nodeFactory, listenerId));

        if ((functionReturnWatcher.getParent() != null) || (functionReturnWatcher.getClassName() != null))
        {
            argumentList = nodeFactory.argumentList(argumentList, nodeFactory.literalNull());
        }
        else
        {
            MemberExpressionNode propertyGetterMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PROPERTY_GETTER, false);
            argumentList = nodeFactory.argumentList(argumentList, propertyGetterMemberExpression);
        }

        if (functionReturnWatcher.isStyleWatcher())
        {
            argumentList = nodeFactory.argumentList(argumentList, nodeFactory.literalBoolean(true));
        }

        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, argumentList);
        callExpression.setRValue(false);
        callExpression.is_new = true;
        MemberExpressionNode callMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode args = nodeFactory.argumentList(null, callMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(expression, args, false);
        selector.setMode(Tokens.LEFTBRACKET_TOKEN);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode result = nodeFactory.statementList(statementList, expressionStatement);

        return result;
    }

    private StatementListNode generateWatcher(NodeFactory nodeFactory, Context cx,
                                              StatementListNode statementList,
                                              PropertyWatcher propertyWatcher,
                                              StandardDefs standardDefs,
                                              String documentClassName)
    {
        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);

        String type;

        if (propertyWatcher.getStaticProperty())
        {
            type = STATIC_PROPERTY_WATCHER;
        }
        else
        {
            type = PROPERTY_WATCHER;
        }

        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), type, false);
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(propertyWatcher.getId());
        ArgumentListNode expression = nodeFactory.argumentList(null, literalNumber);

        LiteralStringNode literalString = nodeFactory.literalString(propertyWatcher.getProperty());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        argumentList = nodeFactory.argumentList(argumentList, generateChangeEvents(nodeFactory, propertyWatcher));
        argumentList = nodeFactory.argumentList(argumentList, generateListeners(nodeFactory, propertyWatcher));

        if ((propertyWatcher.getParent() != null) || 
            (propertyWatcher.getClassName() != null) &&
            !propertyWatcher.getClassName().equals(documentClassName))
        {
            argumentList = nodeFactory.argumentList(argumentList, nodeFactory.literalNull());
        }
        else if (propertyWatcher.getStaticProperty())
        {
            MemberExpressionNode staticPropertyGetterMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STATIC_PROPERTY_GETTER, false);
            argumentList = nodeFactory.argumentList(argumentList, staticPropertyGetterMemberExpression);
        }
        else
        {
            MemberExpressionNode propertyGetterMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PROPERTY_GETTER, false);
            argumentList = nodeFactory.argumentList(argumentList, propertyGetterMemberExpression);
        }

        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, argumentList);
        callExpression.setRValue(false);
        callExpression.is_new = true;
        MemberExpressionNode callMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode args = nodeFactory.argumentList(null, callMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(expression, args, false);
		selector.setMode(Tokens.LEFTBRACKET_TOKEN);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode result = nodeFactory.statementList(statementList, expressionStatement);

        return result;
    }

    private StatementListNode generateWatcherChildren(NodeFactory nodeFactory, Context cx,
                                                      HashSet<String> configNamespaces,
                                                      StatementListNode statementList, Watcher watcher,
                                                      StandardDefs standardDefs, String documentClassName)
    {
        StatementListNode result = statementList;

        Iterator<Watcher> iterator = watcher.getChildren().iterator();

        while (iterator.hasNext())
        {
            Watcher childWatcher = iterator.next();

            if (childWatcher.shouldWriteSelf())
            {
                if (childWatcher instanceof ArrayElementWatcher)
                {
                    ArrayElementWatcher childArrayElementWatcher = (ArrayElementWatcher) childWatcher;
                    result = generateWatcher(nodeFactory, cx, configNamespaces, result,
                                             childArrayElementWatcher, standardDefs);
                }
                else if (childWatcher instanceof FunctionReturnWatcher)
                {
                    FunctionReturnWatcher childFunctionReturnWatcher = (FunctionReturnWatcher) childWatcher;
                    result = generateWatcher(nodeFactory, cx, configNamespaces, result,
                                             childFunctionReturnWatcher, standardDefs);
                }
                else if (childWatcher instanceof RepeaterComponentWatcher)
                {
                    RepeaterComponentWatcher childRepeaterComponentWatcher = (RepeaterComponentWatcher) childWatcher;
                    result = generateWatcher(nodeFactory, result, childRepeaterComponentWatcher, standardDefs);
                }
                else if (childWatcher instanceof RepeaterItemWatcher)
                {
                    RepeaterItemWatcher childRepeaterItemWatcher = (RepeaterItemWatcher) childWatcher;
                    result = generateWatcher(nodeFactory, cx, result, childRepeaterItemWatcher, standardDefs);
                }
                else if (childWatcher instanceof XMLWatcher)
                {
                    XMLWatcher childXMLWatcher = (XMLWatcher) childWatcher;
                    result = generateWatcher(nodeFactory, result, childXMLWatcher, standardDefs);
                }
                else if (childWatcher instanceof PropertyWatcher)
                {
                    PropertyWatcher childPropertyWatcher = (PropertyWatcher) childWatcher;
                    result = generateWatcher(nodeFactory, cx, result, childPropertyWatcher, standardDefs,
                                             documentClassName);
                }
                else
                {
                    assert false : "Unhandled Watcher type: " + childWatcher.getClass().getName();
                }
            }

            if (childWatcher.shouldWriteChildren())
            {
                result = generateWatcherChildren(nodeFactory, cx, configNamespaces, result, childWatcher,
                                                 standardDefs, documentClassName);
            }
        }

        return result;
    }

    private Map<QName, Source> generateWatcherSetupUtilClasses(CompilationUnit compilationUnit, SymbolTable symbolTable,
                                                List dataBindingInfoList)
    {
        Map<QName, Source> extraSources = new HashMap<QName, Source>();
        Iterator iterator = dataBindingInfoList.iterator();

        while ( iterator.hasNext() )
        {
            DataBindingInfo dataBindingInfo = (DataBindingInfo) iterator.next();
            QName classQName = new QName(dataBindingInfo.getWatcherSetupUtilClassName());

            if (generateAbstractSyntaxTree)
            {
                extraSources.put(classQName, generateWatcherSetupUtilAST(compilationUnit, symbolTable,
                                                                         dataBindingInfo));
            }
            else
            {
                extraSources.put(classQName, generateWatcherSetupUtil(compilationUnit, dataBindingInfo));
            }
        }

        return extraSources;
    }

    private StatementListNode generateWatcher(NodeFactory nodeFactory, StatementListNode statementList,
                                              RepeaterComponentWatcher repeaterComponentWatcher,
                                              StandardDefs standardDefs)
    {
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), REPEATER_COMPONENT_WATCHER, false);
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(repeaterComponentWatcher.getId());
        ArgumentListNode expression = nodeFactory.argumentList(null, literalNumber);

        LiteralStringNode literalString = nodeFactory.literalString(repeaterComponentWatcher.getProperty());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        argumentList = nodeFactory.argumentList(argumentList, generateChangeEvents(nodeFactory, repeaterComponentWatcher));
        argumentList = nodeFactory.argumentList(argumentList, generateListeners(nodeFactory, repeaterComponentWatcher));
        MemberExpressionNode propertyGetterMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PROPERTY_GETTER, false);
        argumentList = nodeFactory.argumentList(argumentList, propertyGetterMemberExpression);

        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, argumentList);
        callExpression.setRValue(false);
        callExpression.is_new = true;
        MemberExpressionNode callMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode args = nodeFactory.argumentList(null, callMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(expression, args, false);
		selector.setMode(Tokens.LEFTBRACKET_TOKEN);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode result = nodeFactory.statementList(statementList, expressionStatement);

        return result;
    }

    private StatementListNode generateWatcher(NodeFactory nodeFactory, Context cx,
                                              StatementListNode statementList, RepeaterItemWatcher repeaterItemWatcher,
                                              StandardDefs standardDefs)
    {
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);

        QualifiedIdentifierNode qualifiedIdentifier = AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory,
                standardDefs.getBindingPackage(), REPEATER_ITEM_WATCHER, false);

        LiteralNumberNode id = nodeFactory.literalNumber(repeaterItemWatcher.getId());
        ArgumentListNode expression = nodeFactory.argumentList(null, id);

        MemberExpressionNode parentWatchersBase = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);

        LiteralNumberNode parentId = nodeFactory.literalNumber(repeaterItemWatcher.getParent().getId());
        ArgumentListNode parentExpression = nodeFactory.argumentList(null, parentId);
        GetExpressionNode parentSelector = nodeFactory.getExpression(parentExpression);
		parentSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode parentMemberExpression= nodeFactory.memberExpression(parentWatchersBase, parentSelector);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, parentMemberExpression);

        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, argumentList);
        callExpression.setRValue(false);
        callExpression.is_new = true;
        MemberExpressionNode callMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode args = nodeFactory.argumentList(null, callMemberExpression);

        SetExpressionNode selector = nodeFactory.setExpression(expression, args, false);
		selector.setMode(Tokens.LEFTBRACKET_TOKEN);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode result = nodeFactory.statementList(statementList, expressionStatement);

        return result;
    }

    private StatementListNode generateWatcher(NodeFactory nodeFactory, StatementListNode statementList,
                                              XMLWatcher xmlWatcher, StandardDefs standardDefs)
    {
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), XML_WATCHER, false);
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(xmlWatcher.getId());
        ArgumentListNode expression = nodeFactory.argumentList(null, literalNumber);

        LiteralStringNode literalString = nodeFactory.literalString(xmlWatcher.getProperty());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        argumentList = nodeFactory.argumentList(argumentList, generateListeners(nodeFactory, xmlWatcher));

        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, argumentList);
        callExpression.setRValue(false);
        callExpression.is_new = true;
        MemberExpressionNode callMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode args = nodeFactory.argumentList(null, callMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(expression, args, false);
		selector.setMode(Tokens.LEFTBRACKET_TOKEN);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode result = nodeFactory.statementList(statementList, expressionStatement);

        return result;
    }

    private StatementListNode generateWatcherBottom(NodeFactory nodeFactory, Context cx,
                                                    StatementListNode statementList, Watcher watcher)
    {
        StatementListNode result = statementList;

        if (watcher.shouldWriteSelf())
        {
            if (((watcher instanceof ArrayElementWatcher) &&
                 watcher.shouldWriteSelf() &&
                 watcher.shouldWriteChildren()) ||
                (watcher instanceof FunctionReturnWatcher))
            {
                EvaluationWatcher evaluationWatcher = (EvaluationWatcher) watcher;

                if ((watcher.getParent() != null) && watcher.getParent().shouldWriteSelf())
                {
                    result = nodeFactory.statementList(result, generateEvaluationWatcherPart(nodeFactory,
                                                                                             evaluationWatcher));
                }
            }

            if (watcher.getParent() != null)
            {
                if (watcher.getParent().shouldWriteSelf())
                {
                    result = nodeFactory.statementList(result, generateAddChild(nodeFactory, watcher));
                }
                else
                {
                    Watcher parent = watcher.getParent();

                    if (parent instanceof PropertyWatcher)
                    {
                        PropertyWatcher propertyWatcher = (PropertyWatcher) parent;

                        if (propertyWatcher.getStaticProperty())
                        {
                            result = nodeFactory.statementList(result,
                                                               generateUpdateParentStaticProperty(nodeFactory,
                                                                                                  watcher.getId(),
                                                                                                  propertyWatcher));
                        }
                        else
                        {
                            if (parent.getParent() != null)
                            {
                                result = nodeFactory.statementList(result,
                                                                   generateUpdateParentProperty(nodeFactory,
                                                                                                watcher.getId(),
                                                                                                propertyWatcher));
                            }
                            else
                            {
                                result = nodeFactory.statementList(result,
                                                                   generateUpdateParentPrivateProperty(nodeFactory,
                                                                                                       watcher.getId(),
                                                                                                       propertyWatcher));
                            }
                        }
                    }
                }
            }
            else
            {
                result = generateRootWatcherBottom(nodeFactory, cx, result, watcher);
            }
        }

        if (watcher.shouldWriteChildren())
        {
            Iterator<Watcher> iterator = watcher.getChildren().iterator();

            while (iterator.hasNext())
            {
                Watcher childWatcher = iterator.next();
                result = generateWatcherBottom(nodeFactory, cx, result, childWatcher);
            }
        }

        return result;
    }

    /**
     *
     */
    private Source generateWatcherSetupUtil(CompilationUnit compilationUnit, DataBindingInfo dataBindingInfo)
    {
        Template template;

        StandardDefs standardDefs = compilationUnit.getStandardDefs();
        String templatePath = TEMPLATE_PATH + standardDefs.getWatcherSetupUtilTemplate();

        try
        {
            template = VelocityManager.getTemplate(templatePath);
        }
        catch (Exception exception)
        {
            ThreadLocalToolkit.log(new VelocityException.TemplateNotFound(templatePath));
            return null;
        }

        String className = dataBindingInfo.getWatcherSetupUtilClassName();
        String shortName = className.substring(className.lastIndexOf(DOT) + 1);

        String generatedName = className.replace('.', File.separatorChar) + DOT_AS;

        SourceCodeBuffer out = new SourceCodeBuffer();

        try
        {
            VelocityUtil util = new VelocityUtil(TEMPLATE_PATH, false, out, null);
            VelocityContext velocityContext = VelocityManager.getCodeGenContext(util);
            velocityContext.put(DATA_BINDING_INFO_KEY, dataBindingInfo);
            template.merge(velocityContext, out);
        }
        catch (Exception e)
        {
            ThreadLocalToolkit.log(new VelocityException.GenerateException(compilationUnit.getSource().getRelativePath(),
                                                                           e.getLocalizedMessage()));
            return null;
        }

        return createSource(generatedName, shortName, compilationUnit.getSource().getLastModified(),
        					compilationUnit.getSource().getPathResolver(), out);
    }

    private Source generateWatcherSetupUtilAST(CompilationUnit compilationUnit, SymbolTable symbolTable,
                                               DataBindingInfo dataBindingInfo)
    {
        String className = dataBindingInfo.getWatcherSetupUtilClassName();
        String shortName = className.substring(className.lastIndexOf(DOT) + 1);
        String fileName = className.replace('.', File.separatorChar) + DOT_AS;
        VirtualFile emptyFile = new TextFile(EMPTY_STRING, fileName, null, MimeMappings.AS,
                                             compilationUnit.getSource().getLastModified());
        Source result = new Source(emptyFile, EMPTY_STRING, shortName, null, false, false, false);

        Context cx = AbstractSyntaxTreeUtil.generateContext(symbolTable.perCompileData, result,
                                                            symbolTable.emitter, defines);
        NodeFactory nodeFactory = cx.getNodeFactory();

        HashSet<String> configNamespaces = new HashSet<String>();
        StatementListNode configVars = AbstractSyntaxTreeUtil.parseConfigVars(cx, configNamespaces);
        ProgramNode program = AbstractSyntaxTreeUtil.generateProgram(cx, configVars, EMPTY_STRING);
        StatementListNode programStatementList = program.statements;

        String[] watcherImports = compilationUnit.getStandardDefs().getImports();
        for (int i = 0; i < watcherImports.length; i++)
        {
            ImportDirectiveNode importDirective = AbstractSyntaxTreeUtil.generateImport(cx, watcherImports[i]);
            programStatementList = nodeFactory.statementList(programStatementList, importDirective);
        }

        MetaDataNode metaDataNode = AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, EXCLUDE_CLASS);
        programStatementList = nodeFactory.statementList(programStatementList, metaDataNode);

        ClassDefinitionNode classDefinition = generateClassDefinition(cx, configNamespaces, shortName,
                                                                      dataBindingInfo, compilationUnit.getStandardDefs());
        programStatementList = nodeFactory.statementList(programStatementList, classDefinition);
        program.statements = programStatementList;

        PackageDefinitionNode packageDefinition = nodeFactory.finishPackage(cx, null);
        nodeFactory.statementList(programStatementList, packageDefinition);

		CompilerContext context = new CompilerContext();
		context.setAscContext(cx);
		result.newCompilationUnit(program, context).setSyntaxTree(program);

        // Useful when comparing abstract syntax trees
        //flash.swf.tools.SyntaxTreeDumper.dump(program, "/tmp/" + className + "New.xml");

        As3Compiler.cleanNodeFactory(nodeFactory);

        return result;
    }


}
