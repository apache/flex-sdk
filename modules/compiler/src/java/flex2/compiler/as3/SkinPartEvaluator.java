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

import java.util.Iterator;
import java.util.Map;

import macromedia.asc.parser.ArgumentListNode;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.FunctionCommonNode;
import macromedia.asc.parser.FunctionDefinitionNode;
import macromedia.asc.parser.FunctionNameNode;
import macromedia.asc.parser.FunctionSignatureNode;
import macromedia.asc.parser.GetExpressionNode;
import macromedia.asc.parser.IdentifierNode;
import macromedia.asc.parser.ListNode;
import macromedia.asc.parser.LiteralBooleanNode;
import macromedia.asc.parser.LiteralFieldNode;
import macromedia.asc.parser.LiteralObjectNode;
import macromedia.asc.parser.LiteralStringNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.QualifiedIdentifierNode;
import macromedia.asc.parser.ReturnStatementNode;
import macromedia.asc.parser.StatementListNode;
import macromedia.asc.parser.Tokens;
import macromedia.asc.parser.TypeExpressionNode;
import macromedia.asc.parser.VariableDefinitionNode;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.swf.tools.as3.EvaluatorAdapter;
import flex2.compiler.SymbolTable;
import flex2.compiler.as3.binding.ClassInfo;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.as3.reflect.NodeMagic;
import macromedia.asc.parser.Node;

/**
 * This class handles processing [SkinPart] metadata.
 *
 * @author Greg Burch
 */
class SkinPartEvaluator extends EvaluatorAdapter
{
    private SymbolTable symbolTable;
    private Context currentContext;
    
    //String Defs
    private static final String SKINPARTS = "skinParts".intern();
    private static final String _SKINPARTS = "_skinParts".intern();
    private static final String OVERRIDE = "override".intern();
    private static final String OBJECT = "Object".intern();

    public SkinPartEvaluator(SymbolTable symbolTable)
    {
        this.symbolTable = symbolTable;
    }
    
    /**
     * Evaluates the ClassDefinitionNode instance. The SkinPart metadata
     * is evaluated on a per class basis.
     */
    public Value evaluate(Context context, ClassDefinitionNode node)
    {
        super.evaluate(context, node);
        
        //Used to populate ClassInfo via getClassInfo
        TypeAnalyzer typeAnalyzer = symbolTable.getTypeAnalyzer();
        
        //Needed for getClassInfo
        String className = NodeMagic.getClassName(node);
        
        if(className == null) return null;
        
        currentContext = context;
        
        //This walks the class hiearchy to insure that the tree has been parsed
        //we need to do this before we use getClassInfo() to make sure we get all the
        //baseclasses' info
        typeAnalyzer.evaluate(context, node);
        
        ClassInfo classInfo = typeAnalyzer.getClassInfo(className);
        
        //Returns a hash of all skin parts, including inherited parts
        Map<String, Boolean> parts = classInfo.getSkinParts(true);
        
        
        if(parts != null && parts.size() > 0)
        {
            NodeFactory nodeFactory = context.getNodeFactory();
            
            //Add our generated AST to the statements list
            node.statements = genSkinPartsAST(parts, nodeFactory, node.statements);
        }

        
        
        return null;
    }
    
    /**
     * @private 
     * 
     * Generates the AST for the static backing var
     * which contains the AS representation of the <code>parts</code>
     * Map. Also generates a public getter for accessing the Map. 
     * 
     * @param parts A hashmap of SkinParts
     * @param nodeFactory
     * @param statements A StatementListNode instance to add the AST to
     * @return The modified StatementListNode
     */
    private StatementListNode genSkinPartsAST(Map<String, Boolean> parts, 
    										  NodeFactory nodeFactory, 
    										  StatementListNode statements)
    {
        StatementListNode result = statements;
        
        Iterator<String> iterator = parts.keySet().iterator();
        ArgumentListNode partsList = null;
        
        //Loop through list of SkinParts and generate key/value field
        while( iterator. hasNext() ){
            String key = iterator.next();
            LiteralStringNode partName = nodeFactory.literalString(key);
            LiteralBooleanNode required = nodeFactory.literalBoolean(parts.get(key));
            LiteralFieldNode literalField = nodeFactory.literalField(partName, required);
            partsList = nodeFactory.argumentList(partsList, literalField);

        }
        
        //Create literalObject with key/value pairs
        TypeExpressionNode typeExpression = AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory, OBJECT, true);   
        LiteralObjectNode literalObject = nodeFactory.literalObject(partsList);
        
        //And finally our completed _skinPart AST
        VariableDefinitionNode skinParts = (VariableDefinitionNode)AbstractSyntaxTreeUtil.generatePrivateStaticVariable(currentContext, typeExpression, _SKINPARTS, literalObject);
        
        //Signature for getter that takes no parameters (of course) and returns an Object
        MemberExpressionNode returnTypeExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OBJECT, true);
        TypeExpressionNode returnType = nodeFactory.typeExpression(returnTypeExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);
        
        //generate <ClassName>._skinParts
        IdentifierNode identifier = AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, _SKINPARTS, false);
        GetExpressionNode selector = nodeFactory.getExpression(identifier);
       
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, selector);
        ListNode list = nodeFactory.list(null, memberExpression);

        //return <ClassName>._skinParts
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
        StatementListNode rStatementList = nodeFactory.statementList(null, returnStatement);
        
        //Create final expression 
        FunctionCommonNode propertyGetter = nodeFactory.functionCommon(currentContext, null, functionSignature, rStatementList);
       
        //Create FunctionDefinition that will contain the above expression and set its type to a GETTER
        QualifiedIdentifierNode qFunctionName = AbstractSyntaxTreeUtil.generatePublicQualifiedIdentifier(nodeFactory, SKINPARTS); 
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.GET_TOKEN, qFunctionName);
        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(currentContext, AbstractSyntaxTreeUtil.generateProtectedAttribute(nodeFactory), functionName, propertyGetter);
        functionDefinition.attrs = nodeFactory.attributeList(AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OVERRIDE, false), functionDefinition.attrs);
        
        
        //Add skinPart static var to statement list
        result = nodeFactory.statementList(result, skinParts);
        
        //Add getter to statement list
        result = nodeFactory.statementList(result, functionDefinition);
        
        return result;
    }
}
