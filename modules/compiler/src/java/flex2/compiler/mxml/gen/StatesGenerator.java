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

package flex2.compiler.mxml.gen;

import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.rep.StatesModel;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import flex2.compiler.mxml.rep.StatesModel.SharedObject;
import flex2.compiler.mxml.rep.StatesModel.State;
import flex2.compiler.mxml.rep.init.EventInitializer;
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.util.NameFormatter;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;

/**
 * This class is a helper used to generate the code that implements a
 * stateful model, when state-specific nodes or attributes were
 * declared within a component/document instance.
 * 
 * @author Corey Lucier
 */
public class StatesGenerator {

    public final static String INDENT = "  ".intern();
    private List<StatesModel.Override> bindingsQueue;
    private final StandardDefs standardDefs;
    
    // Interned constants used for AST generation.
    private static final String _C = "_c".intern();
    private static final String _I = "_i".intern();
    private static final String _FACTORY = "_factory".intern();
    private static final String _R = "_r".intern();
    private static final String ADDEVENTLISTENER = "addEventListener".intern();
    private static final String BINDINGMANAGER = "BindingManager".intern();
    private static final String DEFERREDINSTANCEFROMFUNCTION = "DeferredInstanceFromFunction".intern();
    private static final String EXECUTEBINDINGS = "executeBindings".intern();
    private static final String GETINSTANCE = "getInstance".intern();
    private static final String STATES = "states".intern();
    
    /*
     * 
     */
    public StatesGenerator(StandardDefs defs)
    {
        this.standardDefs = defs;
        bindingsQueue = new ArrayList<StatesModel.Override>();
    }
    
    /*
     * Generates the code to initialize all states and overrides for our
     * component instance.
     */
    public CodeFragmentList getStatesInitializerFragments(StatesModel model)
    {
        CodeFragmentList list = new CodeFragmentList();
         
        String indent = "\t\t";
        genSharedFactories(model, list, indent);
        list.add("\n",0);
        genStates(model, list, indent);  
        list.add("\n",0);
        genBindingInitializers(list, indent);
        list.add("\n",0);
        genStateInitializers(model, list, indent);
        list.add("\n",0);
        genImmediateInits(model, list, indent);
        return list;
    }
    
    /*
     * Generates the code (AST) to initialize all states and overrides for our
     * component instance.
     */
    public StatementListNode getStatesASTInitializers(StatesModel model, NodeFactory nodeFactory,
                                                      HashSet<String> configNamespaces,
                                                      boolean generateDocComments,
                                                      StatementListNode statementList)
    {
        StatementListNode results = statementList;
        results = genSharedFactoriesAST(model, nodeFactory, statementList);
        results = genStatesAST(model, nodeFactory, configNamespaces,
                               generateDocComments, results);
        results = genBindingInitializersAST(nodeFactory, results);
        results = genStateInitializersAST(model, nodeFactory, configNamespaces,
                                          generateDocComments, results);
        results = genImmediateInitsAST(model, nodeFactory, results);
        return results;
    }
    
    /*
     * Generates the initializers for all values that are shared between states (e.g. all instance factories
     * shared by AddItems overrides).
     */
    private void genSharedFactories(StatesModel model, CodeFragmentList list, String indent)
    {
        Map<String, SharedObject> shared = model.sharedObjects;

        for (Iterator<String> iter = shared.keySet().iterator(); iter.hasNext(); )
        {
            SharedObject symbol = shared.get(iter.next());
            String lval = indent + "var " + symbol.name + "_factory:" + NameFormatter.retrieveClassName(standardDefs.CLASS_DEFERREDINSTANCEFROMFUNCTION ) + " = \n";
            indent += StatesGenerator.INDENT;
            String suffix = symbol.model.isDeclared() ? "_i" : "_c";
            Boolean isTransient = symbol.model.getIsTransient();
            String rval = indent + "new " + NameFormatter.toDot(standardDefs.CLASS_DEFERREDINSTANCEFROMFUNCTION) + "(" + symbol.name + suffix +
                (isTransient ? ", " + symbol.name + "_r" : "") + ");";
            indent = indent.substring(0, indent.length() - INDENT.length());
            list.add(lval, rval, 0 );
        }
    }
    
    /*
     * Generates the initializers (AST) for all values that are shared between states (e.g. all instance factories
     * shared by AddItems overrides).
     */
    private StatementListNode genSharedFactoriesAST(StatesModel model, NodeFactory nodeFactory, StatementListNode statementList)
    {
        Map<String, SharedObject> shared = model.sharedObjects;

        StatementListNode result = statementList;
        
        for (Iterator<String> iter = shared.keySet().iterator(); iter.hasNext(); )
        {
            SharedObject symbol = shared.get(iter.next());
            
            String varName = ((String)symbol.name + _FACTORY).intern();
            String typeName = NameFormatter.retrieveClassName( DEFERREDINSTANCEFROMFUNCTION );
            String factory = symbol.name + (symbol.model.isDeclared() ? _I : _C);
            String resetFunc = symbol.name + _R;
            
            MemberExpressionNode memberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, factory, true);
            
            ArgumentListNode callExpressionArgumentList = nodeFactory.argumentList(null, memberExpression);
            
            if (symbol.model.getIsTransient())
            {
            	memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, resetFunc, true);
            	callExpressionArgumentList = nodeFactory.argumentList(callExpressionArgumentList, memberExpression);
            }
            
            QualifiedIdentifierNode qualifiedIdentifier =
                AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getCorePackage(), typeName, false);
                
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, callExpressionArgumentList);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            
            MemberExpressionNode ad = nodeFactory.memberExpression(null, callExpression);
            
            VariableDefinitionNode variableDefinition =
                AbstractSyntaxTreeUtil.generateVariable(nodeFactory, varName, typeName, false, ad);
            result = nodeFactory.statementList(result, variableDefinition);
        }
        return result;
    }
    
    /*
     * Generate all necessary binding instance initializers for any data bound overrides.
     */
    private void genBindingInitializers(CodeFragmentList list, String indent)
    {
        for (Iterator<StatesModel.Override> iter = bindingsQueue.iterator(); iter.hasNext(); )
        {
            StatesModel.Override symbol = (StatesModel.Override)iter.next();            
            list.add(indent, NameFormatter.toDot(standardDefs.CLASS_BINDINGMANAGER),
                    ".executeBindings(this, \"" + symbol.declaration + "\", " + symbol.declaration + ");", 0);
        }
    }
    
    /*
     * Generate all necessary binding instance AST for any data bound overrides.
     */
    private StatementListNode genBindingInitializersAST(NodeFactory nodeFactory, StatementListNode statementList)
    {
        StatementListNode result = statementList;
        
        for (Iterator<StatesModel.Override> iter = bindingsQueue.iterator(); iter.hasNext(); )
        {
            StatesModel.Override symbol = (StatesModel.Override)iter.next();
            
            QualifiedIdentifierNode qualifiedIdentifier =
                AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, 
                        standardDefs.getBindingPackage(), BINDINGMANAGER, false);
            
            GetExpressionNode bindExpression = nodeFactory.getExpression(qualifiedIdentifier);
            
            MemberExpressionNode lvalue = nodeFactory.memberExpression(null, bindExpression);
            
            ArgumentListNode execArgs = nodeFactory.argumentList(null, nodeFactory.thisExpression(0)); 
            String decl = symbol.declaration.intern();
            execArgs = nodeFactory.argumentList(execArgs, nodeFactory.literalString(decl, false));
            IdentifierNode rvalIdentifier = nodeFactory.identifier(decl, false);
            GetExpressionNode getExpression = nodeFactory.getExpression(rvalIdentifier);
            MemberExpressionNode rvalue = nodeFactory.memberExpression(null, getExpression);
            execArgs = nodeFactory.argumentList(execArgs, rvalue);
            
            IdentifierNode bindIdentifier = nodeFactory.identifier(EXECUTEBINDINGS, false);

            CallExpressionNode selector =
                (CallExpressionNode) nodeFactory.callExpression(bindIdentifier, execArgs);
            selector.setRValue(false);
            
            MemberExpressionNode base = nodeFactory.memberExpression(lvalue, selector); 
            ListNode list = nodeFactory.list(null, base);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);
        }
        return result;
    }
    
    
    /*
     * Generate all calls to instantiate itemCreationPolicy='immediate' nodes.
     */
    private void genImmediateInits(StatesModel model, CodeFragmentList list, String indent)
    {
        List<String> objects = model.earlyInitObjects;

        for (Iterator<String> iter = objects.iterator(); iter.hasNext(); )
        {
            String symbol = iter.next();
            String lval = indent + symbol + "_factory.getInstance();\n";
            indent += StatesGenerator.INDENT;
            list.add(lval, 0 );
        }
    }
    
    /*
     * Generate all AST calls to instantiate itemCreationPolicy='immediate' nodes.
     */
    private StatementListNode genImmediateInitsAST(StatesModel model, NodeFactory nodeFactory, StatementListNode statementList)
    {
        StatementListNode result = statementList;
        List<String> objects = model.earlyInitObjects;

        for (Iterator<String> iter = objects.iterator(); iter.hasNext(); )
        {
            String symbol = iter.next();
            String identifier = ((String)symbol + "_factory").intern();
            IdentifierNode idNode = nodeFactory.identifier(identifier, false);
            GetExpressionNode getIndexExpression = nodeFactory.getExpression(idNode);
            MemberExpressionNode base = nodeFactory.memberExpression(null, getIndexExpression);
            
            IdentifierNode getNode = nodeFactory.identifier(GETINSTANCE, false);
            
            CallExpressionNode selector =
                (CallExpressionNode) nodeFactory.callExpression(getNode,  null);
            selector.setRValue(false);
            
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);
            
        }
        return result;
    }
    
    
    /*
     * Generate the states array.
     */
    private void genStates(StatesModel model, CodeFragmentList list, String indent)
    {
        Set<String> states = model.info.getStateNames();
        
        if (!states.isEmpty())
        {
            list.add(indent, "states = [", 0);
        
            indent += StatesGenerator.INDENT;
            for (Iterator<String> iter = states.iterator(); iter.hasNext();  )
            {
                State state = (State) model.stateByName((String)iter.next());
                if (state != null)
                {
                    state.getDefinitionBody(list, indent, bindingsQueue);
                    if (iter.hasNext()) list.add(indent, ",", 0);
                }
            }
            indent = indent.substring(0, indent.length() - INDENT.length());
            list.add(indent, "];", 0);
        }
    }
    
    /*
     * Generate the states array initializer (AST).
     */
    private StatementListNode genStatesAST(StatesModel model, NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                           boolean generateDocComments, StatementListNode statementList)
    {
        StatementListNode result = statementList;
        
        Set<String> states = model.info.getStateNames();
        if (!states.isEmpty())
        {
            ArgumentListNode statesArgumentList = null;
            
            for (Iterator<String> iter = states.iterator(); iter.hasNext();  )
            {
                State state = (State) model.stateByName((String)iter.next());
                if (state != null)
                {
                    MemberExpressionNode stateExpression = state.generateDefinitionBody(nodeFactory, configNamespaces,
                                                                                        generateDocComments, bindingsQueue);
                    statesArgumentList = nodeFactory.argumentList(statesArgumentList, stateExpression);
                }
            }
            
            LiteralArrayNode literalArray = nodeFactory.literalArray(statesArgumentList);
            ArgumentListNode argList = nodeFactory.argumentList(null, literalArray);
            IdentifierNode statesIdentifier = nodeFactory.identifier(STATES, false);
            SetExpressionNode selector = nodeFactory.setExpression(statesIdentifier, argList, false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);    
        }
        return result;
    }

    /*
     * Generate initializers for any declared states, as well as any event
     * initializers for states.
     */
    private void genStateInitializers(StatesModel model, CodeFragmentList list, String indent)
    {        
        Set<String> states = model.info.getStateNames();
        int count = 0;
        for (Iterator<String> iter = states.iterator(); iter.hasNext();  )
        {
            State state = (State) model.stateByName((String)iter.next());
            if (state != null)
            {
                // Declaration initializer
                if (state.isDeclared())
                {
                    list.add(indent, state.getId() + "= states[" + count + "];", 0 );
                }
                
                // Event handlers
                for (Iterator<Initializer> initializers = state.getEvents(); initializers.hasNext(); )
                {
                    EventInitializer ei = (EventInitializer) initializers.next();                   
                    list.add(indent, "states[" + count + "].addEventListener(\"" + ei.getName() + "\", " + ei.getValueExpr() + " );" , 0 );             
                }       
            }
            count++;
        }
    }
    
    /*
     * Generate AST initializers for any declared states, as well as any event
     * initializers for states.
     */
    private StatementListNode genStateInitializersAST(StatesModel model, NodeFactory nodeFactory, 
                                                      HashSet<String> configNamespaces,
                                                      boolean generateDocComments,
                                                      StatementListNode statementList)
    {
        StatementListNode result = statementList;
        Set<String> states = model.info.getStateNames();
        int count = 0;
        for (Iterator<String> iter = states.iterator(); iter.hasNext();  )
        {
            State state = (State) model.stateByName((String)iter.next());
            if (state != null)
            {
                String identifier = state.getId().intern();
                IdentifierNode stateIdentifier = nodeFactory.identifier(identifier, false);
                IdentifierNode statesIdentifier = nodeFactory.identifier(STATES, false);
                
                LiteralNumberNode numberNode = nodeFactory.literalNumber(count);
                ArgumentListNode getIndexArgList = nodeFactory.argumentList(null, numberNode);
                GetExpressionNode getIndexExpression = nodeFactory.getExpression(getIndexArgList);
                getIndexExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
                
                GetExpressionNode getStatesExpression = nodeFactory.getExpression(statesIdentifier);
                MemberExpressionNode base = nodeFactory.memberExpression(null, getStatesExpression);
   
                MemberExpressionNode getExpr = nodeFactory.memberExpression(base, getIndexExpression);
                
                // Declaration initializer
                if (state.isDeclared())
                {
                    ArgumentListNode argList = nodeFactory.argumentList(null, getExpr);
                    SetExpressionNode selector = nodeFactory.setExpression(stateIdentifier, argList, false); 
                    MemberExpressionNode outer = nodeFactory.memberExpression(null, selector);
                    ListNode list = nodeFactory.list(null, outer);
                    ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
                    result = nodeFactory.statementList(result, expressionStatement);
                }
                
                // Event handlers
                for (Iterator<Initializer> initializers = state.getEvents(); initializers.hasNext(); )
                {
                    EventInitializer ei = (EventInitializer) initializers.next();    
                    IdentifierNode addEventIdentifier = nodeFactory.identifier(ADDEVENTLISTENER, false);
                    LiteralStringNode eventName = nodeFactory.literalString(ei.getName());
                    macromedia.asc.parser.Node valueNode = ei.generateValueExpr(nodeFactory, configNamespaces,
                                                                                generateDocComments);
                    ArgumentListNode addEventArgs = nodeFactory.argumentList(null, eventName);
                    addEventArgs = nodeFactory.argumentList(addEventArgs, valueNode);
                    
                    
                    CallExpressionNode addListener =
                        (CallExpressionNode) nodeFactory.callExpression(addEventIdentifier, addEventArgs);
                    addListener.setRValue(false);
                    MemberExpressionNode outer = nodeFactory.memberExpression(getExpr, addListener );
                    ListNode list = nodeFactory.list(null, outer);
                    ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
                    result = nodeFactory.statementList(result, expressionStatement);
                }
            }
            count++;
        }
        return result;
    }
        
}
