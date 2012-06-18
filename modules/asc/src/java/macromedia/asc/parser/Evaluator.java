/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * The base visitor object extended by semantic evaluators.
 * <p/>
 * This is a visitor that is used by the compiler for various forms for
 * evaluation of a parse tree (e.g. a type evaluator might compute the
 * static type of an expression.)
 *
 * @author Jeff Dyer
 */
public interface Evaluator
{

    static final int global_this = 0;
    static final int instance_this = 1;
    static final int error_this = 2;
    static final int cinit_this = 3;
    static final int package_this = 4;
    static final int init_this = 5; // We're in a property initializer so we can't use this

    static final int super_statement = 0;
    static final int super_expression = 1;
    static final int super_error = 2;
    static final int super_error2 = 3;  // means we have already hit a this/super/return/throw
    static final int super_error_es4 = 4;  // means super can not occurr in the ctor body, it must be in the initializer list 

    boolean checkFeature(Context cx, Node node); // return true;

	// Base node

	Value evaluate(Context cx, Node node);

	// Expression evaluators

	Value evaluate(Context cx, IncrementNode node);

	Value evaluate(Context cx, DeleteExpressionNode node);

	Value evaluate(Context cx, IdentifierNode node);

	Value evaluate(Context cx, InvokeNode node);

	Value evaluate(Context cx, ThisExpressionNode node);

    Value evaluate(Context cx, QualifiedIdentifierNode node);

    Value evaluate(Context cx, QualifiedExpressionNode node);

    Value evaluate(Context cx, LiteralBooleanNode node);

	Value evaluate(Context cx, LiteralNumberNode node);

	Value evaluate(Context cx, LiteralStringNode node);

	Value evaluate(Context cx, LiteralNullNode node);

	Value evaluate(Context cx, LiteralRegExpNode node);

	Value evaluate(Context cx, LiteralXMLNode node);

	Value evaluate(Context cx, FunctionCommonNode node);

	Value evaluate(Context cx, ParenExpressionNode node);

	Value evaluate(Context cx, ParenListExpressionNode node);

	Value evaluate(Context cx, LiteralObjectNode node);

	Value evaluate(Context cx, LiteralFieldNode node);

	Value evaluate(Context cx, LiteralArrayNode node);
	
	Value evaluate(Context cx, LiteralVectorNode node);

	Value evaluate(Context cx, SuperExpressionNode node);

	Value evaluate(Context cx, SuperStatementNode node);

	Value evaluate(Context cx, MemberExpressionNode node);

	Value evaluate(Context cx, CallExpressionNode node);

	Value evaluate(Context cx, GetExpressionNode node);

	Value evaluate(Context cx, SetExpressionNode node);

    Value evaluate(Context cx, ApplyTypeExprNode node);

	Value evaluate(Context cx, UnaryExpressionNode node);

	Value evaluate(Context cx, BinaryExpressionNode node);

	Value evaluate(Context cx, ConditionalExpressionNode node);

	Value evaluate(Context cx, ArgumentListNode node);

	Value evaluate(Context cx, ListNode node);

	// Statements

	Value evaluate(Context cx, StatementListNode node);

	Value evaluate(Context cx, EmptyElementNode node);

	Value evaluate(Context cx, EmptyStatementNode node);

	Value evaluate(Context cx, ExpressionStatementNode node);

	Value evaluate(Context cx, LabeledStatementNode node);

	Value evaluate(Context cx, IfStatementNode node);

	Value evaluate(Context cx, SwitchStatementNode node);

	Value evaluate(Context cx, CaseLabelNode node);

	Value evaluate(Context cx, DoStatementNode node);

	Value evaluate(Context cx, WhileStatementNode node);

	Value evaluate(Context cx, ForStatementNode node);

	Value evaluate(Context cx, WithStatementNode node);

	Value evaluate(Context cx, ContinueStatementNode node);

	Value evaluate(Context cx, BreakStatementNode node);

	Value evaluate(Context cx, ReturnStatementNode node);

	Value evaluate(Context cx, ThrowStatementNode node);

	Value evaluate(Context cx, TryStatementNode node);

	Value evaluate(Context cx, CatchClauseNode node);

	Value evaluate(Context cx, FinallyClauseNode node);

	Value evaluate(Context cx, UseDirectiveNode node);

	Value evaluate(Context cx, IncludeDirectiveNode node);

	Value evaluate(Context cx, ImportNode node);

	Value evaluate(Context cx, MetaDataNode node);
	
	Value evaluate(Context cx, DocCommentNode node);

	// Definitions

	Value evaluate(Context cx, ImportDirectiveNode node);

	Value evaluate(Context cx, AttributeListNode node);

	Value evaluate(Context cx, VariableDefinitionNode node);

	Value evaluate(Context cx, VariableBindingNode node);

	Value evaluate(Context cx, UntypedVariableBindingNode node);

	Value evaluate(Context cx, TypedIdentifierNode node);

    Value evaluate(Context cx, TypeExpressionNode node);

	Value evaluate(Context cx, FunctionDefinitionNode node);

    Value evaluate(Context cx, BinaryFunctionDefinitionNode node);

	Value evaluate(Context cx, FunctionNameNode node);

	Value evaluate(Context cx, FunctionSignatureNode node);

	Value evaluate(Context cx, ParameterNode node);

	Value evaluate(Context cx, ParameterListNode node);

	Value evaluate(Context cx, RestExpressionNode node);

	Value evaluate(Context cx, RestParameterNode node);

	Value evaluate(Context cx, InterfaceDefinitionNode node);

	Value evaluate(Context cx, ClassDefinitionNode node);

    Value evaluate(Context cx, BinaryClassDefNode node);

    Value evaluate(Context cx, BinaryInterfaceDefinitionNode node);

	Value evaluate(Context cx, ClassNameNode node);

	Value evaluate(Context cx, InheritanceNode node);

	Value evaluate(Context cx, NamespaceDefinitionNode node);

	Value evaluate(Context cx, ConfigNamespaceDefinitionNode node);

	Value evaluate(Context cx, PackageDefinitionNode node);

	Value evaluate(Context cx, PackageIdentifiersNode node);

	Value evaluate(Context cx, PackageNameNode node);

	Value evaluate(Context cx, ProgramNode node);

    Value evaluate(Context cx, BinaryProgramNode node);

	Value evaluate(Context cx, ErrorNode node);

	Value evaluate(Context cx, ToObjectNode node);

	Value evaluate(Context cx, LoadRegisterNode node);

	Value evaluate(Context cx, StoreRegisterNode node);

    Value evaluate(Context cx, RegisterNode node);

	Value evaluate(Context cx, HasNextNode node);

    Value evaluate(Context cx, BoxNode node);

	Value evaluate(Context cx, CoerceNode node);

	Value evaluate(Context cx, PragmaNode node);

    Value evaluate(Context cx, UsePrecisionNode node);

	Value evaluate(Context cx, UseNumericNode node);

	Value evaluate(Context cx, UseRoundingNode node); 

    Value evaluate(Context cx, PragmaExpressionNode node);

    Value evaluate(Context cx, DefaultXMLNamespaceNode node);
}
