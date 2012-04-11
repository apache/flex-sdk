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

import flex2.compiler.Logger;
import flex2.compiler.Source;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.Set;
import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.NamespaceValue;
import macromedia.asc.semantics.ReferenceValue;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.Namespaces;
import macromedia.asc.util.ObjectList;

/**
 * This class contains a collection of utility methods used during
 * direct AST generation, which allows the compiler to go from MXML
 * straight to an ASC AST, skipping the .as intermediate state.
 *
 * @author Paul Reilly
 * @see flex2.copmiler.as3.binding.BindableSecondPassEvaluator
 * @see flex2.copmiler.as3.binding.DataBindingExtension
 * @see flex2.compiler.mxml.ImplementationGenerator
 * @see flex2.compiler.mxml.InterfaceGenerator
 * @see flex2.compiler.mxml.gen/StatesGenerator
 * @see flex2.compiler.mxml.rep.init.EventInitializer
 * @see flex2.compiler.mxml.rep.init.VisualChildInitializer
 * @see flex2.compiler.mxml.rep.init.VisualInitializer
 */

public class AbstractSyntaxTreeUtil
{
    private static final String DOT = ".";
    private static final String DOUBLE_COLON = "::";
    private static final String LESS_THAN = "<";
    private static final String GREATER_THAN = ">";

    // intern all identifier constants
    private static final String __AS3__ = "__AS3__".intern();
    private static final String CONFIG = "CONFIG".intern();
    private static final String MX_INTERNAL = "mx_internal".intern();
    private static final String OVERRIDE = "override".intern();
    private static final String PRIVATE = "private".intern();
    private static final String PROTECTED = "protected".intern();
    private static final String PRIVATE_DOC_COMMENT = "<description><![CDATA[\n ]]></description>\n<private><![CDATA[ ]]></private>";
    private static final String INHERIT_DOC_COMMENT = "<description><![CDATA[\n ]]></description>\n<inheritDoc><![CDATA[ ]]></inheritDoc>";
    private static final String PUBLIC = "public".intern();
    private static final String STATIC = "static".intern();
    private static final String VEC = "vec".intern();
    private static final String VECTOR = "Vector".intern();

    public static ApplyTypeExprNode generateApplyTypeExpr(NodeFactory nodeFactory, String type)
    {
        IdentifierNode identifier = generateIdentifier(nodeFactory, VECTOR, false);
        TypeExpressionNode typeExpression = generateTypeExpression(nodeFactory, type, true, true);
        ListNode typeArgs = nodeFactory.list(null, typeExpression);
        return (ApplyTypeExprNode) nodeFactory.applyTypeExpr(identifier, typeArgs, -1);
    }

    public static ApplyTypeExprNode generateApplyTypeExpr(NodeFactory nodeFactory, String type,
                                                          int lessThanIndex)
    {
        String vectorType = type.substring(0, lessThanIndex - 1);
        int dotIndex = vectorType.lastIndexOf(DOT);
        IdentifierNode identifier;

        if (dotIndex > 0)
        {
            identifier = generateQualifiedIdentifier(nodeFactory, vectorType.substring(0, dotIndex),
                                                     vectorType.substring(dotIndex + 1), true);
        }
        else
        {
            identifier = generateIdentifier(nodeFactory, vectorType, true);
        }

        int greaterThanIndex = type.lastIndexOf(GREATER_THAN);
        String elementType = type.substring(lessThanIndex + 1, greaterThanIndex);
        TypeExpressionNode typeExpression =
            generateTypeExpression(nodeFactory, elementType, true, true);
        ListNode typeArgs = nodeFactory.list(null, typeExpression);
        return (ApplyTypeExprNode) nodeFactory.applyTypeExpr(identifier, typeArgs, -1);
    }

    public static ExpressionStatementNode generateAssignment(NodeFactory nodeFactory, String lvalue,
                                                             String rvalue)
    {
        IdentifierNode lvalueIdentifier = nodeFactory.identifier(lvalue);
        IdentifierNode rvalueIdentifier = nodeFactory.identifier(rvalue);
        GetExpressionNode getExpression = nodeFactory.getExpression(rvalueIdentifier);
        MemberExpressionNode rvalueMemberExpression = nodeFactory.memberExpression(null, getExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, rvalueMemberExpression);
        // Set the position to a non-zero value, so that LintEvaluator doesn't skip reporting warnings.
        SetExpressionNode setExpression = nodeFactory.setExpression(lvalueIdentifier, argumentList, false, 1);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    public static ExpressionStatementNode generateAssignment(NodeFactory nodeFactory, Node base,
                                                             String lvalue, Node rvalue)
    {
        IdentifierNode lvalueIdentifier = nodeFactory.identifier(lvalue);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, rvalue);
        // Set the position to a non-zero value, so that LintEvaluator doesn't skip reporting warnings.
        SetExpressionNode setExpression = nodeFactory.setExpression(lvalueIdentifier, argumentList, false, 1);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    public static ClassDefinitionNode generateClassDefinition(Context context, String className,
                                                              String baseClassName, Set<String> interfaceNames,
                                                              StatementListNode statementList)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        nodeFactory.StartClassDefs();
        ListNode interfaces = null;
        Iterator<String> iterator = interfaceNames.iterator();

        while (iterator.hasNext())
        {
            String interfaceName = iterator.next();
            int index = interfaceName.lastIndexOf(DOT);

            if (index > 0)
            {
                interfaces = nodeFactory.list(interfaces,
                                              generateGetterSelector(nodeFactory,
                                                                     interfaceName.substring(0, index),
                                                                     interfaceName.substring(index + 1),
                                                                     true));
            }
            else
            {
                interfaces = nodeFactory.list(interfaces, generateGetterSelector(nodeFactory,
                                                                                 interfaceName,
                                                                                 true));
            }
        }

        InheritanceNode inheritance;
        int index = baseClassName.lastIndexOf(DOT);

        if (index > 0)
        {
            inheritance = nodeFactory.inheritance(generateGetterSelector(nodeFactory,
                                                                         baseClassName.substring(0, index),
                                                                         baseClassName.substring(index + 1),
                                                                         true),
                                                  interfaces);
        }
        else
        {
            inheritance = nodeFactory.inheritance(generateGetterSelector(nodeFactory,
                                                                         baseClassName,
                                                                         true),
                                                  interfaces);
        }

        ClassDefinitionNode classDefinition = nodeFactory.classDefinition(context,
                                                                          generatePublicAttribute(nodeFactory),
                                                                          generatePublicQualifiedIdentifier(nodeFactory,
                                                                                                            className),
                                                                          inheritance,
                                                                          statementList);

        return classDefinition;
    }

    public static FunctionDefinitionNode generateConstructor(Context context, String className,
    														 ParameterListNode parameterList,
                                                             boolean generateSuperCall,
                                                             StatementListNode statementList,
                                                             int position)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        AttributeListNode attributeList = generatePublicAttribute(nodeFactory);
        IdentifierNode identifier = nodeFactory.identifier(className);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, identifier);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.no_anno = true;

        if (generateSuperCall)
        {
            SuperExpressionNode superExpression = nodeFactory.superExpression(null, -1);
            CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(superExpression, null);
            SuperStatementNode superStatement = nodeFactory.superStatement(callExpression);

            if (statementList != null)
            {
                statementList.items.add(0, superStatement);
            }
            else
            {
                statementList = nodeFactory.statementList(null, superStatement);
            }
        }

        FunctionCommonNode functionCommon =
            nodeFactory.functionCommon(context, identifier, functionSignature,
                                       statementList, position);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    public static Context generateContext(ContextStatics contextStatics, Source source, BytecodeEmitter emitter,
                                          ObjectList<ConfigVar> defines)
    {
        Context result = new Context(contextStatics);
        result.setOrigin(source.getBackingFile().getName());
        result.setScriptName(source.getBackingFile().getName());
        result.setPath(source.getBackingFile().getParent());
        result.setEmitter(emitter);
        result.setHandler(new As3Compiler.CompilerHandler(source));
        result.input = new CodeFragmentsInputBuffer(source.getBackingFile().getName());

        if (defines != null)
        {
            result.config_vars.addAll(defines);
        }

        return result;
    }

    /**
     * @param comment This is assumed to be interned.
     */
    public static DocCommentNode generateDocComment(NodeFactory nodeFactory, String comment)
    {
        LiteralStringNode literalString = nodeFactory.literalString(comment, false);
        ListNode list = nodeFactory.list(null, literalString);
        LiteralXMLNode literalXML = nodeFactory.literalXML(list, false, -1);
        GetExpressionNode getExpression = nodeFactory.getExpression(literalXML);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, getExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        return nodeFactory.docComment(literalArray, -1);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static MemberExpressionNode generateGetterSelector(NodeFactory nodeFactory,
                                                              String name,
                                                              boolean intern)
    {
        return generateGetterSelector(nodeFactory, name, intern, -1);
    }

    public static MemberExpressionNode generateGetterSelector(NodeFactory nodeFactory,
            String name, boolean intern, int position)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, intern, position);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
        return nodeFactory.memberExpression(null, getExpression);
    }
    
    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static MemberExpressionNode generateGetterSelector(NodeFactory nodeFactory,
                                                              String qualifier,
                                                              String name,
                                                              boolean intern)
    {
        QualifiedIdentifierNode qualifiedIdentifier =
            generateQualifiedIdentifier(nodeFactory, qualifier, name, intern);
        GetExpressionNode getExpression = nodeFactory.getExpression(qualifiedIdentifier);
        return nodeFactory.memberExpression(null, getExpression);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static MemberExpressionNode generateGetterSelector(NodeFactory nodeFactory,
                                                              MemberExpressionNode qualifier,
                                                              String name,
                                                              boolean intern)
    {
        QualifiedIdentifierNode qualifiedIdentifier =
            generateQualifiedIdentifier(nodeFactory, qualifier, name, intern);
        GetExpressionNode getExpression = nodeFactory.getExpression(qualifiedIdentifier);
        return nodeFactory.memberExpression(null, getExpression);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.  If <code>name</name> is
     *               qualified, the <code>intern</code> flag is ignored and set to
     *               true.
     */
    public static IdentifierNode generateIdentifier(NodeFactory nodeFactory, String name,
                                                    boolean intern)
    {
        IdentifierNode result;
        int index = name.lastIndexOf(DOT);

        if (index > -1)
        {
            result = generateQualifiedIdentifier(nodeFactory, name.substring(0, index),
                                                 name.substring(index + 1), true);
        }
        else
        {
            index = name.indexOf(DOUBLE_COLON);

            if (index > -1)
            {
                MemberExpressionNode memberExpression =
                    generateGetterSelector(nodeFactory, name.substring(0, index), true);
                result = generateQualifiedIdentifier(nodeFactory, memberExpression,
                                                     name.substring(index + 2), true);
            }
            else
            {
                result = nodeFactory.identifier(name, intern);
            }
        }

        return result;
    }

    public static IdentifierNode generateIdentifier(NodeFactory nodeFactory, QName qName,
                                                    boolean intern)
    {
        IdentifierNode result;

        if (qName.getNamespace().length() > 0)
        {
            MemberExpressionNode memberExpression =
                generateGetterSelector(nodeFactory, qName.getNamespace(), intern);
            result = generateQualifiedIdentifier(nodeFactory, memberExpression,
                                                 qName.getLocalPart(), intern);
        }
        else
        {
            result = nodeFactory.identifier(qName.getLocalPart(), intern);
        }

        return result;
    }

    private static StatementListNode generateImplicitNamespaces(Context context, StatementListNode statementList)
    {
        StatementListNode result = statementList;
        NodeFactory nodeFactory = context.getNodeFactory();

        if (context.statics.es4_vectors)
        {
            IdentifierNode as3Identifier = nodeFactory.identifier(__AS3__, false);
            PackageIdentifiersNode packageIdentifiers = nodeFactory.packageIdentifiers(null, as3Identifier, true);
            IdentifierNode vecIdentifier = nodeFactory.identifier(VEC, false);
            packageIdentifiers = nodeFactory.packageIdentifiers(packageIdentifiers, vecIdentifier, true);
            IdentifierNode vectorIdentifier = nodeFactory.identifier(VECTOR, false);
            packageIdentifiers = nodeFactory.packageIdentifiers(packageIdentifiers, vectorIdentifier, true);
            PackageNameNode packageName = nodeFactory.packageName(packageIdentifiers);
            ImportDirectiveNode importDirective = nodeFactory.importDirective(null, packageName, null, context);
            result = nodeFactory.statementList(result, importDirective);
        }

        if (!context.statics.use_namespaces.isEmpty())
        {
            for (String useName : context.statics.use_namespaces)
            {
                IdentifierNode identifier = nodeFactory.identifier(useName);
                GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, getExpression);
                result = nodeFactory.statementList(result, nodeFactory.useDirective(null, memberExpression));
            }
        }

        result = nodeFactory.statementList(result, Parser.generateAs3UseDirective(context));

        return result;
    }

    public static ImportDirectiveNode generateImport(Context context, String name)
    {
        return generateImport(context, name, -1);
    }

    public static ImportDirectiveNode generateImport(Context context, String[] splitName)
    {
    	return generateImport(context, splitName, -1);
    }

    public static ImportDirectiveNode generateImport(Context context, String name, int position)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        PackageNameNode packageName = generatePackageName(nodeFactory, name, true, position);
        return nodeFactory.importDirective(null, packageName, null, context);
    }

    public static ImportDirectiveNode generateImport(Context context, String[] splitName, int position)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        PackageNameNode packageName = generatePackageName(nodeFactory, splitName, true, position);
        return nodeFactory.importDirective(null, packageName, null, context);
    }
        
    public static MemberExpressionNode generateMemberExpression(NodeFactory nodeFactory,
                                                                String expression, int position)
    {
        MemberExpressionNode result;
        int lessThanIndex = expression.indexOf(LESS_THAN);

        if (lessThanIndex != -1)
        {
            // Handle Vector.<foo.Bar>
            String vectorString = expression.substring(0, lessThanIndex - 1);
            MemberExpressionNode base = generateGetterSelector(nodeFactory, vectorString, true);
            String elementString = expression.substring(lessThanIndex + 1, expression.length() - 1);
            ApplyTypeExprNode selector = generateApplyTypeExpr(nodeFactory, elementString);
            selector.setRValue(false);
            result = nodeFactory.memberExpression(base, selector, position);
        }
        else
        {
            int lastDotIndex = expression.lastIndexOf(DOT);

            if (lastDotIndex != -1)
            {
                // Handle a.b.C
                String baseString = expression.substring(0, lastDotIndex);
                MemberExpressionNode base = generateGetterSelector(nodeFactory, baseString, true, position);
                String selectorString = expression.substring(lastDotIndex + 1);
                IdentifierNode identifier = nodeFactory.identifier(selectorString, position);
                GetExpressionNode selector = nodeFactory.getExpression(identifier, position);
                selector.setRValue(false);
                result = nodeFactory.memberExpression(base, selector, position);
                result.setPositionTerminal(position);
            }
            else
            {
                result = generateGetterSelector(nodeFactory, expression, true, position);
            }
        }

        return result;
    }

    public static MemberExpressionNode generateMemberExpression(NodeFactory nodeFactory,
            String expression)
    {
    	return generateMemberExpression(nodeFactory, expression, -1);
    }
    
    /**
     * @param name This is assumed to be interned.
     */
    public static MetaDataNode generateMetaData(NodeFactory nodeFactory, String name)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, getExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        return nodeFactory.metaData(literalArray, -1);
    }

    /**
     * @param name This is assumed to be interned.
     * @param value This is assumed to be interned.
     */
    public static MetaDataNode generateMetaData(NodeFactory nodeFactory, String name,
                                                String value)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        LiteralStringNode literalString = nodeFactory.literalString(value, false);
        ArgumentListNode callExpressionArgumentList = nodeFactory.argumentList(null, literalString);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, callExpressionArgumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        return nodeFactory.metaData(literalArray, -1);
    }

    /**
     * @param name This is assumed to be interned.
     * @param key This is assumed to be interned.
     */
    public static MetaDataNode generateMetaData(NodeFactory nodeFactory, String name,
                                                String key, String value)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);

        IdentifierNode attributeIdentifier = nodeFactory.identifier(key, false);
        LiteralStringNode literalString = nodeFactory.literalString(value);
        ArgumentListNode attributeArgumentList = nodeFactory.argumentList(null, literalString);
        SetExpressionNode setExpression = nodeFactory.setExpression(attributeIdentifier,
                                                                    attributeArgumentList, false);
        MemberExpressionNode keyValueMemberExpression = nodeFactory.memberExpression(null, setExpression);
        ArgumentListNode callExpressionArgumentList = nodeFactory.argumentList(null, keyValueMemberExpression);

        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, callExpressionArgumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        return nodeFactory.metaData(literalArray, -1);
    }

    /**
     * @param name This is assumed to be interned.
     */
    public static MetaDataNode generateMetaData(NodeFactory nodeFactory, String name,
                                                Map<String, Object> attributes)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        ArgumentListNode callExpressionArgumentList = null;

        Iterator<Map.Entry<String, Object>> iterator = attributes.entrySet().iterator();

        while (iterator.hasNext())
        {
            Map.Entry<String, Object> entry = iterator.next();
            IdentifierNode attributeIdentifier = nodeFactory.identifier(entry.getKey());
            LiteralStringNode literalString = nodeFactory.literalString(entry.getValue().toString());
            ArgumentListNode attributeArgumentList = nodeFactory.argumentList(null, literalString);
            SetExpressionNode setExpression = nodeFactory.setExpression(attributeIdentifier,
                                                                        attributeArgumentList, false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
            callExpressionArgumentList = nodeFactory.argumentList(callExpressionArgumentList,
                                                                  memberExpression);
        }

        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, callExpressionArgumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, memberExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);
        return nodeFactory.metaData(literalArray, -1);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static QualifiedIdentifierNode generateMxInternalQualifiedIdentifier(NodeFactory nodeFactory,
                                                                                String name,
                                                                                boolean intern)
    {
        if (intern)
        {
            name = name.intern();
        }

        StandardDefs standardDefs = ThreadLocalToolkit.getStandardDefs();
        MemberExpressionNode mxInternalGetterSelector =
            generateResolvedGetterSelector(nodeFactory, standardDefs.getCorePackage(), MX_INTERNAL);
        return nodeFactory.qualifiedIdentifier(mxInternalGetterSelector, name);
    }

    public static AttributeListNode generateOverridePublicAttribute(NodeFactory nodeFactory)
    {
        IdentifierNode identifier = nodeFactory.identifier(PUBLIC, false);
        AttributeListNode attributeList = nodeFactory.attributeList(identifier, null);
        MemberExpressionNode memberExpression =
            generateGetterSelector(nodeFactory, OVERRIDE, false);
        ListNode list = nodeFactory.list(null, memberExpression);
        attributeList = nodeFactory.attributeList(list, attributeList);
        return attributeList;
    }

    public static PackageNameNode generatePackageName(NodeFactory nodeFactory, String name,
                                                      boolean isDefinition, int position)
    {
        Scanner scanner = new Scanner(name).useDelimiter("\\.");
        PackageIdentifiersNode packageIdentifiers = null;

        if (scanner.hasNext())
        {
            while (scanner.hasNext())
            {
                IdentifierNode identifier = nodeFactory.identifier(scanner.next());
                packageIdentifiers = nodeFactory.packageIdentifiers(packageIdentifiers, identifier,
                                                                    isDefinition);
            }
        }
        else
        {
            IdentifierNode identifier = nodeFactory.identifier(name);
            packageIdentifiers = nodeFactory.packageIdentifiers(packageIdentifiers, identifier,
                                                                isDefinition);
        }

        return nodeFactory.packageName(packageIdentifiers, position);
    }

    /**
     * @param splitName Each element assumed to be interned.
     */
    public static PackageNameNode generatePackageName(NodeFactory nodeFactory, String[] splitName,
                                                      boolean isDefinition, int position)
    {
        PackageIdentifiersNode packageIdentifiers = null;

        for (int i = 0; i < splitName.length; i++)
        {
            assert splitName[i].intern() == splitName[i];
            IdentifierNode identifier = nodeFactory.identifier(splitName[i], false);
            packageIdentifiers = nodeFactory.packageIdentifiers(packageIdentifiers, identifier,
                                                                isDefinition);
        }

        return nodeFactory.packageName(packageIdentifiers, position);
    }

    /**
     * @param name This is assumed to be interned.
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static ParameterNode generateParameter(NodeFactory nodeFactory, String name,
                                                  String type, boolean internType)
    {
        return generateParameter(nodeFactory, name, type, internType, -1);
    }

    /**
     * @param name This is assumed to be interned.
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static ParameterNode generateParameter(NodeFactory nodeFactory, String name,
                                                  String type, boolean internType, int position)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        TypeExpressionNode typeExpression = generateTypeExpression(nodeFactory, type, internType);
        return nodeFactory.parameter(Tokens.VAR_TOKEN, identifier, typeExpression);
    }

    /**
     * @param name This is assumed to be interned.
     * @param internType Hint to ASC for controlling if <code>type</code>
     *                   is interned.  If <code>type</code> is a constant,
     *                   <code>internType</code> should be false.
     */
    public static ParameterNode generateParameter(NodeFactory nodeFactory, String name,
                                                  String type, boolean internType,
                                                  Node init)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        TypeExpressionNode typeExpression = generateTypeExpression(nodeFactory, type, internType);
        return nodeFactory.parameter(Tokens.VAR_TOKEN, identifier, typeExpression, init);
    }

    public static ParameterNode generateParameter(NodeFactory nodeFactory, String name,
                                                  String typeNamespace, String typeName,
                                                  boolean internType)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        TypeExpressionNode typeExpression =
            generateTypeExpression(nodeFactory, typeNamespace, typeName, internType);
        return nodeFactory.parameter(Tokens.VAR_TOKEN, identifier, typeExpression);
    }

    public static DocCommentNode generatePrivateDocComment(NodeFactory nodeFactory)
    {
        return generateDocComment(nodeFactory, PRIVATE_DOC_COMMENT);
    }
    
    public static DocCommentNode generateInheritDocComment(NodeFactory nodeFactory)
    {
        return generateDocComment(nodeFactory, INHERIT_DOC_COMMENT);
    }

    public static Node generatePrivateVariable(NodeFactory nodeFactory,
                                               TypeExpressionNode typeExpression,
                                               String name)
    {
        return generatePrivateVariable(nodeFactory, typeExpression, name, null);
    }

    public static Node generatePrivateVariable(NodeFactory nodeFactory,
                                               TypeExpressionNode typeExpression,
                                               String name,
                                               Node initializer)
    {
        AttributeListNode attributeList = generatePrivateAttribute(nodeFactory);
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier =
            generatePrivateQualifiedIdentifier(nodeFactory, name);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier,
                                                                          typeExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(attributeList, kind,
                                                                          typedIdentifier, initializer);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(attributeList, kind, list);
    }

    public static AttributeListNode generatePrivateAttribute(NodeFactory nodeFactory)
    {
        ListNode list = nodeFactory.list(null, generateGetterSelector(nodeFactory, PRIVATE, false));
        AttributeListNode attributeList = nodeFactory.attributeList(list, null);
        return attributeList;
    }

    public static QualifiedIdentifierNode generatePrivateQualifiedIdentifier(NodeFactory nodeFactory, String name)
    {
        return nodeFactory.qualifiedIdentifier(generatePrivateAttribute(nodeFactory), name.intern());
    }

    public static AttributeListNode generatePrivateStaticAttribute(NodeFactory nodeFactory)
    {
        MemberExpressionNode memberExpression = generateGetterSelector(nodeFactory, STATIC, false);
        AttributeListNode attributeList = nodeFactory.attributeList(memberExpression, null);
        ListNode list = nodeFactory.list(null, generateGetterSelector(nodeFactory, PRIVATE, false));
        attributeList = nodeFactory.attributeList(list, attributeList);
        return attributeList;
    }

    public static ProgramNode generateProgram(Context context, StatementListNode configVars, String packageNameString)
    {
        return generateProgram(context, configVars, packageNameString, null, -1);
    }

    public static ProgramNode generateProgram(Context context, StatementListNode configVars, String packageNameString,
                                              DocCommentNode packageDocComment, int lineNumber)
    {
        NodeFactory nodeFactory = context.getNodeFactory();

        IdentifierNode configIdentifier = nodeFactory.identifier(CONFIG, false);
        NamespaceDefinitionNode configNamespaceDefinition = nodeFactory.configNamespaceDefinition(null, configIdentifier, -1);
        StatementListNode statementList = nodeFactory.statementList(null, configNamespaceDefinition);

        if ((context.config_vars != null) && (context.config_vars.size() > 0))
        {
            statementList.items.addAll(0, configVars.items);
        }

        statementList = generateImplicitNamespaces(context, statementList);

        if (packageDocComment != null)
        {
            statementList = nodeFactory.statementList(statementList, packageDocComment);
        }

        PackageNameNode packageName = generatePackageName(nodeFactory, packageNameString, false, -1);
        PackageDefinitionNode packageDefinition = nodeFactory.startPackage(context, null, packageName);
        statementList = nodeFactory.statementList(statementList, packageDefinition);
        statementList = generateImplicitNamespaces(context, statementList);
        
        int position = -1;

        if (lineNumber != -1)
            position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, lineNumber);

        return nodeFactory.program(context, statementList, position);
    }

    public static AttributeListNode generatePublicAttribute(NodeFactory nodeFactory)
    {
        ListNode list = nodeFactory.list(null, generateGetterSelector(nodeFactory, PUBLIC, false));
        AttributeListNode attributeList = nodeFactory.attributeList(list, null);
        return attributeList;
    }
    
    public static AttributeListNode generateProtectedAttribute(NodeFactory nodeFactory)
    {
        ListNode list = nodeFactory.list(null, generateGetterSelector(nodeFactory, PROTECTED, false));
        AttributeListNode attributeList = nodeFactory.attributeList(list, null);
        return attributeList;
    }

    public static QualifiedIdentifierNode generatePublicQualifiedIdentifier(NodeFactory nodeFactory,
                                                                            String name)
    {
        return nodeFactory.qualifiedIdentifier(generatePublicAttribute(nodeFactory), name.intern());
    }
    
    public static QualifiedIdentifierNode generateProtectedQualifiedIdentifier(NodeFactory nodeFactory,
            String name)
    {
    	return nodeFactory.qualifiedIdentifier(generateProtectedAttribute(nodeFactory), name.intern());
	}

    public static AttributeListNode generatePublicStaticAttribute(NodeFactory nodeFactory)
    {
        MemberExpressionNode memberExpression = generateGetterSelector(nodeFactory, STATIC, false);
        AttributeListNode attributeList = nodeFactory.attributeList(memberExpression, null);
        ListNode list = nodeFactory.list(null, generateGetterSelector(nodeFactory, PUBLIC, false));
        attributeList = nodeFactory.attributeList(list, attributeList);
        return attributeList;
    }

    public static VariableDefinitionNode generatePublicVariable(Context context, TypeExpressionNode typeExpression, String name)
    {
        return generatePublicVariable(context, typeExpression, name, null);
    }

    public static VariableDefinitionNode generatePublicVariable(Context context, TypeExpressionNode typeExpression,
                                              String name, MemberExpressionNode initializer)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        AttributeListNode attributeList = generatePublicAttribute(nodeFactory);
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = generatePublicQualifiedIdentifier(nodeFactory, name);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(attributeList, kind, typedIdentifier, initializer);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(attributeList, kind, list);
    }
    
    public static Node generatePrivateStaticVariable(Context context, TypeExpressionNode typeExpression, String name, Node initializer)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        AttributeListNode attributeList = generatePrivateStaticAttribute(nodeFactory);
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = generatePublicQualifiedIdentifier(nodeFactory, name);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(attributeList, kind, typedIdentifier, initializer);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(attributeList, kind, list);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static QualifiedIdentifierNode generateQualifiedIdentifier(NodeFactory nodeFactory,
                                                                      String qualifier,
                                                                      String name,
                                                                      boolean intern)
    {
        if (intern)
        {
            name = name.intern();
        }

        LiteralStringNode literalString = nodeFactory.literalString(qualifier, intern);
        return nodeFactory.qualifiedIdentifier(literalString, name);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static QualifiedIdentifierNode generateQualifiedIdentifier(NodeFactory nodeFactory,
                                                                      MemberExpressionNode qualifier,
                                                                      String name,
                                                                      boolean intern)
    {
        if (intern)
        {
            name = name.intern();
        }

        return nodeFactory.qualifiedIdentifier(qualifier, name);
    }

    /**
     * Generates a MemberExpressionNode with an IdentifierNode name
     * with a prefilled ReferenceValue with a namespace of size 1.
     * This allows ReferenceValue.findUnqualified() to run much faster
     * on the IdentifierNode.
     *
     * @param name Assumed to be interned
     */
    public static MemberExpressionNode generateResolvedGetterSelector(NodeFactory nodeFactory,
                                                                      String namespace,
                                                                      String name)
    {
        assert name.intern() == name;
        IdentifierNode identifier = generateResolvedIdentifier(nodeFactory, namespace, name);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
        return nodeFactory.memberExpression(null, getExpression);
    }

    /**
     * Generates an IdentifierNode with prefilled ReferenceValue with
     * a namespace of size 1.  This allows
     * ReferenceValue.findUnqualified() to run much faster.
     *
     * @param name Assumed to be interned
     */
    public static IdentifierNode generateResolvedIdentifier(NodeFactory nodeFactory,
                                                            String namespace,
                                                            String name)
    {
        assert name.intern() == name;
        IdentifierNode result = nodeFactory.identifier(name, false);
        Namespaces namespaces = new Namespaces();
        NamespaceValue namespaceValue = new NamespaceValue();
        namespaceValue.name = namespace;
        namespaces.add(namespaceValue);
        ReferenceValue referenceValue = new ReferenceValue(nodeFactory.getContext(), null, name, namespaces);
        referenceValue.setIsAttributeIdentifier(false);
        result.ref = referenceValue;
        return result;
    }

    /**
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static TypeExpressionNode generateTypeExpression(NodeFactory nodeFactory, 
                                                            String typeNamespace,
                                                            String typeName,
                                                            boolean intern)
    {
        MemberExpressionNode memberExpression = generateGetterSelector(nodeFactory, typeNamespace,
                                                                       typeName, intern);
        return nodeFactory.typeExpression(memberExpression, true, false, -1);
    }

    public static TypeExpressionNode generateTypeExpression(NodeFactory nodeFactory, String type,
                                                            boolean intern)
    {
        return generateTypeExpression(nodeFactory, type, intern, false, -1);
    }

    public static TypeExpressionNode generateTypeExpression(NodeFactory nodeFactory, String type,
                                                            boolean intern, int position)
    {
        return generateTypeExpression(nodeFactory, type, intern, false, position);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static TypeExpressionNode generateTypeExpression(NodeFactory nodeFactory, String type,
                                                            boolean intern, boolean includeAnyType)
    {
        return generateTypeExpression(nodeFactory, type, intern, includeAnyType, -1);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static TypeExpressionNode generateTypeExpression(NodeFactory nodeFactory, String type,
                                                            boolean intern, boolean includeAnyType,
                                                            int position)
    {
        TypeExpressionNode result = null;

        if (includeAnyType || !type.equals("*"))
        {
            MemberExpressionNode memberExpression;

            if (intern)
            {
                int lessThanIndex = type.indexOf(LESS_THAN);

                if (lessThanIndex > 0)
                {
                    ApplyTypeExprNode applyTypeExpr = generateApplyTypeExpr(nodeFactory, type, lessThanIndex);
                    memberExpression = nodeFactory.memberExpression(null, applyTypeExpr);
                }
                else
                {
                    int dotIndex = type.lastIndexOf(DOT);

                    if (dotIndex > 0)
                    {
                        memberExpression = generateGetterSelector(nodeFactory, type.substring(0, dotIndex),
                                                                  type.substring(dotIndex + 1), intern);
                    }
                    else
                    {
                        memberExpression = generateGetterSelector(nodeFactory, type, intern);
                    }
                }
            }
            else
            {
                assert type.lastIndexOf(DOT) < 0 : "It's likely that the type, " + type + ", needs to be interned.";
                memberExpression = generateGetterSelector(nodeFactory, type, intern);
            }

            result = nodeFactory.typeExpression(memberExpression, true, false, position);
        }

        return result;
    }

    private static UseDirectiveNode generateUseDirective(Context context, String name)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifier);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, getExpression);
        UseDirectiveNode useDirective = nodeFactory.useDirective(null, memberExpression);
        return useDirective;
    }

    /**
     * @param name This is assumed to be interned.
     * @param intern Hint to ASC for controlling if <code>name</code>
     *               is interned.  If <code>name</code> is a constant,
     *               <code>intern</code> should be false.
     */
    public static VariableDefinitionNode generateVariable(NodeFactory nodeFactory, String name,
                                                          boolean intern)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, intern);
        int kind = Tokens.VAR_TOKEN;
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(identifier, null);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind,
                                                                          typedIdentifier,
                                                                          null);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);
    }

    /**
     * @param name This is assumed to be interned.
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static VariableDefinitionNode generateVariable(NodeFactory nodeFactory, String name,
                                                          String type, boolean internType,
                                                          Node rvalue)
    {
        return generateVariable(nodeFactory, name, type, internType, rvalue, -1);
    }

    /**
     * @param name This is assumed to be interned.
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static VariableDefinitionNode generateVariable(NodeFactory nodeFactory, String name,
                                                          String type, boolean internType,
                                                          Node rvalue, int position)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        int kind = Tokens.VAR_TOKEN;
        TypeExpressionNode typeExpression = generateTypeExpression(nodeFactory, type,
                                                                   internType, position);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(identifier,
                                                                          typeExpression);

        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind,
                                                                          typedIdentifier,
                                                                          rvalue);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);
    }

    /**
     * @param name This is assumed to be interned.
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static VariableDefinitionNode generateVariable(NodeFactory nodeFactory, String name,
                                                          String typeNamespace, String typeName,
                                                          boolean internType, Node rvalue)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        int kind = Tokens.VAR_TOKEN;
        TypeExpressionNode typeExpression =
            generateTypeExpression(nodeFactory, typeNamespace, typeName, internType);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(identifier,
                                                                          typeExpression);

        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind,
                                                                          typedIdentifier,
                                                                          rvalue);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static VariableDefinitionNode generateVariable(NodeFactory nodeFactory,
                                                          AttributeListNode attributeList,
                                                          IdentifierNode identifier,
                                                          String type, boolean internType, Node rvalue)
    {
        int kind = Tokens.VAR_TOKEN;
        TypeExpressionNode typeExpression = generateTypeExpression(nodeFactory, type, internType);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(identifier,
                                                                          typeExpression);

        VariableBindingNode variableBinding = nodeFactory.variableBinding(attributeList, kind,
                                                                          typedIdentifier,
                                                                          rvalue);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(attributeList, kind, list);
    }

    /**
     * @param intern Hint to ASC for controlling if <code>type</code>
     *               is interned.  If <code>type</code> is a constant,
     *               <code>internType</code> should be false.
     */
    public static VariableDefinitionNode generateVariable(NodeFactory nodeFactory,
                                                          AttributeListNode attributeList,
                                                          IdentifierNode identifier,
                                                          String typeNamespace, String typeName,
                                                          boolean internType, Node rvalue)
    {
        int kind = Tokens.VAR_TOKEN;
        TypeExpressionNode typeExpression =
            generateTypeExpression(nodeFactory, typeNamespace, typeName, internType);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(identifier,
                                                                          typeExpression);

        VariableBindingNode variableBinding = nodeFactory.variableBinding(attributeList, kind,
                                                                          typedIdentifier,
                                                                          rvalue);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(attributeList, kind, list);
    }

    /**
     * @param name This is assumed to be interned.
     * @param type This is assumed not to be interned.
     */
    public static VariableDefinitionNode generateVariableNew(NodeFactory nodeFactory, String name,
                                                             String type, int position)
    {
        return generateVariableNew(nodeFactory, name, type, null, position);
    }

    /**
     * @param name This is assumed to be interned.
     * @param type This is assumed not to be interned.
     */
    public static VariableDefinitionNode generateVariableNew(NodeFactory nodeFactory, String name,
                                                             String type, ArgumentListNode argumentList,
                                                             int position)
    {
        IdentifierNode identifier = nodeFactory.identifier(name, false);
        TypeExpressionNode typeExpression = generateTypeExpression(nodeFactory, type, true, position);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(identifier,
                                                                          typeExpression);
        int lessThanIndex = type.indexOf(LESS_THAN);
        Node initializer;

        if (lessThanIndex > 0)
        {
            ApplyTypeExprNode applyTypeExpr = generateApplyTypeExpr(nodeFactory, type, lessThanIndex);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, applyTypeExpr);
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(memberExpression, argumentList);
            callExpression.is_new = true;
            initializer = callExpression;
        }
        else
        {
            IdentifierNode typeIdentifier = generateIdentifier(nodeFactory, type, true);
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(typeIdentifier, argumentList);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            initializer = nodeFactory.memberExpression(null, callExpression);
        }

        int kind = Tokens.VAR_TOKEN;
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind,
                                                                          typedIdentifier,
                                                                          initializer);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);
    }

    /**
     * This method should be used to parse blocks of code, like MXML
     * script blocks.  It differs from the parseExpression() methods
     * in it's handling of expressions like "[a, b]", which are parsed
     * as metadata instead of array literals.
     */
    public static List<Node> parse(Context context, HashSet<String> configNamespaces, String text,
                                   int lineNumberOffset, boolean emitDocInfo)
    {
        return parse(context, configNamespaces, text, lineNumberOffset, emitDocInfo, false);
    }

    private static List<Node> parse(Context context, HashSet<String> configNamespaces, String text,
                                   int lineNumberOffset, boolean emitDocInfo, boolean isExpression)
    {
        List<Node> result = Collections.<Node>emptyList();

        CodeFragmentsInputBuffer codeFragmentsInputBuffer =
            (CodeFragmentsInputBuffer) context.input;
        String origin = context.input.origin;
        
        // Create a new input buffer populated with our code fragment.
        InputBuffer offsetInputBuffer =
            new InputBuffer(text, origin, codeFragmentsInputBuffer.getLength(), 0);

        Parser parser = new Parser(context, offsetInputBuffer, origin, emitDocInfo);
        parser.block_kind_stack.add(Tokens.PACKAGE_TOKEN);
        parser.block_kind_stack.add(Tokens.CLASS_TOKEN);
        parser.config_namespaces.push_back(configNamespaces);

        Logger original = ThreadLocalToolkit.getLogger();

        CodeFragmentLogAdapter codeFragmentLogAdapter =
            new CodeFragmentLogAdapter(original, lineNumberOffset);
        ThreadLocalToolkit.setLogger(codeFragmentLogAdapter);

        StatementListNode statementList = parser.parseDirectives(null, null);
        parser.match(Tokens.EOS_TOKEN);

        if ((statementList != null) && (statementList.items != null))
        {
            result = new ArrayList<Node>(1);

            for (Node node : statementList.items)
            {
                // For cases like SDK-26448, we don't want "[foo]"
                // parsed as a MetaDataNode.  We want it parsed as a
                // LiteralArrayNode.  Different Parser entrypoints
                // like parseLabeledOrExpressionStatement() were
                // tried, but an entry point was not found that worked
                // for all cases, so we ended up with this hack.
                if (isExpression && (node instanceof MetaDataNode))
                {
                    result.add(new ExpressionStatementNode(new ListNode(null, ((MetaDataNode) node).data, -1)));
                }
                else
                {
                    result.add(node);
                }
            }
        }

        ThreadLocalToolkit.setLogger(original);
        codeFragmentsInputBuffer.addCodeFragment(text.length(), offsetInputBuffer, lineNumberOffset);
        context.input = codeFragmentsInputBuffer;

        return result;
    }

    /**
     * This method should be used to parse an expression, like "a =
     * b".  It differs from the parse() methods in it's handling of
     * expressions like "[a, b]", which are parsed as array literals,
     * instead of metadata.
     */
    public static List<Node> parseExpression(Context context, HashSet<String> configNamespaces,
                                             String text)
    {
        return parseExpression(context, configNamespaces, text, 0, false);
    }

    /**
     * This method should be used to parse an expression, like "a =
     * b".  It differs from the parse() methods in it's handling of
     * expressions like "[a, b]", which are parsed as array literals,
     * instead of metadata.
     */
    public static List<Node> parseExpression(Context context, HashSet<String> configNamespaces,
                                             String text, int lineNumberOffset, boolean emitDocInfo)
    {
        return parse(context, configNamespaces, text, lineNumberOffset, emitDocInfo, true);
    }

    /**
     * @param configNamespaces This HashSet is populated by
     *   parseConfigVars().  If parseConfigVars() didn't already have a
     *   return value, configNamespaces would be returned.
     */
    public static StatementListNode parseConfigVars(Context context, HashSet<String> configNamespaces)
    {
        InputBuffer originalInputBuffer = context.input;
        Parser parser = new Parser(context, "", context.input.origin);
        parser.config_namespaces.push_back(configNamespaces);
        parser.config_namespaces.last().add(CONFIG);
        StatementListNode result = parser.parseConfigValues();
        context.input = originalInputBuffer;
        return result;
    }
    
    /**
     * Helper method which adds a new line number to the nodeFactory's 
     * input buffer. Returns the corresponding position to use when later
     * associating individual nodes with the specified line number.
     */
    public static int lineNumberToPosition(NodeFactory nodeFactory, int lineNumber)
    {
    	CodeFragmentsInputBuffer codeFragmentsInputBuffer =
            (CodeFragmentsInputBuffer) nodeFactory.getContext().input;
        int position = codeFragmentsInputBuffer.getLength();
        codeFragmentsInputBuffer.addLineNumber(lineNumber);
        return position;
    }
}
