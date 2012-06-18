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

import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import macromedia.asc.util.NumberUsage;

import java.io.PrintWriter;

import static macromedia.asc.parser.Tokens.*;

/**
 * NodePrinter.h
 *
 * This visitor prints the parse tree
 *
 * @author Jeff Dyer
 */
public class NodePrinter implements Evaluator
{
    private PrintWriter out;
    private int level;
    private int mode;

    private void separate()
    {
        if (mode == machine_mode)
        {
            out.print("|");
        }
    }

    private void push_in()
    {
        ++level;
        if (mode == machine_mode)
        {
            out.print("[");
        }
        else
        {
            out.print(" ");
        }
    }

    private void pop_out()
    {
        if (mode == machine_mode)
        {
            out.print("]");
        }
        --level;
    }

    private void indent()
    {
        if (mode == man_mode)
        {
            out.println();
            for (int i = level; i != 0; --i)
            {
                out.print("  ");
            }
        }
    }

// public:

    public static final int man_mode = 0;
    public static final int machine_mode = 1;

    public boolean checkFeature(Context cx, Node node)
    {
        return true; // return true;
    }

    public NodePrinter()
    {
        this(man_mode, new PrintWriter(System.out, true));
    }

    public NodePrinter(PrintWriter out)
    {
        this(man_mode, out);
    }

    public NodePrinter(int mode, PrintWriter out)
    {
        this.out = out;
        this.level = 0;
        this.mode = mode;
    }

    // Base node

    public Value evaluate(Context cx, Node node)
    {
        indent();
        out.print("error:undefined printer method");
        return null;
    }

    // Expression evaluators

    public Value evaluate(Context cx, IdentifierNode node)
    {
        indent();

        if(node instanceof TypeIdentifierNode)
        {
            out.print("typeidentifier ");
        }
        else if (node.isAttr())
        {
            out.print("attributeidentifier ");
        }
        else
        {
            out.print("identifier ");
        }
        out.print(node.name);
        if(node instanceof TypeIdentifierNode)
        {
            out.print("types ");
            push_in();
            ((TypeIdentifierNode)node).typeArgs.evaluate(cx, this);
            pop_out();
        }
        return null;
    }

    // Expression evaluators

    public Value evaluate(Context cx, IncrementNode node)
    {
        indent();
        out.print("increment");
        out.print((node.getMode() == LEFTBRACKET_TOKEN ? " bracket" :
            node.getMode() == LEFTPAREN_TOKEN ? " filter" :
            node.getMode() == DOUBLEDOT_TOKEN ? " descend" :
            node.getMode() == DOT_TOKEN ? " dot" :
            node.getMode() == EMPTY_TOKEN ? " lexical" : " error"));
        out.print((node.isPostfix ? " postfix " : " prefix ") + Token.getTokenClassName(node.op));
        push_in();
        pop_out();
        separate();
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ThisExpressionNode node)
    {
        indent();
        out.print("this");
        return null;
    }

    public Value evaluate(Context cx, QualifiedIdentifierNode node)
    {
        indent();
        if (node.isAttr())
        {
            out.print("qualifiedattributeidentifier ");
        }
        else
        {
            out.print("qualifiedidentifier ");
        }
        out.print(node.name);
        if (node.qualifier != null)
        {
            push_in();
            indent();
            out.print("qualifier");
            push_in();
            node.qualifier.evaluate(cx, this);
            pop_out();
            pop_out();
        }
        return null;
    }

    public Value evaluate(Context cx, QualifiedExpressionNode node)
    {
        indent();
        if (node.isAttr())
        {
            out.print("qualifiedattributeexpression ");
        }
        else
        {
            out.print("qualifiedexpression ");
        }
        out.print(node.name);
        if (node.qualifier != null)
        {
            push_in();
            indent();
            out.print("qualifier");
            push_in();
            node.qualifier.evaluate(cx, this);
            pop_out();
            pop_out();
        }
        if (node.expr != null)
        {
            push_in();
            indent();
            out.print("expr");
            push_in();
            node.expr.evaluate(cx, this);
            pop_out();
            pop_out();
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralBooleanNode node)
    {
        indent();
        out.print("literalboolean ");
        out.print(node.value ? 1 : 0);
        return null;
    }

    public Value evaluate(Context cx, LiteralNumberNode node)
    {
        indent();
        out.print("literalnumber:");
        out.print(node.value);
        return null;
    }

    public Value evaluate(Context cx, LiteralStringNode node)
    {
        indent();
        out.print("literalstring:");
        out.print(node.value);
        return null;
    }

    public Value evaluate(Context cx, LiteralNullNode node)
    {
        indent();
        out.print("literalnull");
        return null;
    }

    public Value evaluate(Context cx, LiteralRegExpNode node)
    {
        indent();
        out.print("literalregexp:");
        out.print(node.value);
        return null;
    }

    public Value evaluate(Context cx, LiteralXMLNode node)
    {
        indent();
        out.print("literalxml");
        push_in();
        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, FunctionCommonNode node)
    {
        indent();
        out.print("functioncommon");
        push_in();
        if (node.signature != null)
        {
            node.signature.evaluate(cx, this);
        }
        separate();
        if (node.body != null)
        {
            node.body.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ParenExpressionNode node)
    {
        indent();
        out.print("paren");
        return null;
    }

    public Value evaluate(Context cx, ParenListExpressionNode node)
    {
        indent();
        out.print("parenlist");
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralObjectNode node)
    {
        indent();
        out.print("literalobject");
        push_in();
        if (node.fieldlist != null)
        {
            node.fieldlist.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, LiteralFieldNode node)
    {
        indent();
        out.print("literalfield");
        push_in();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        separate();
        if (node.value != null)
        {
            node.value.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, LiteralArrayNode node)
    {
        indent();
        out.print("literalarray");
        push_in();
        if (node.elementlist != null)
        {
            node.elementlist.evaluate(cx, this);
        }
        pop_out();
        return null;
    }
    
    public Value evaluate(Context cx, LiteralVectorNode node)
    {
        indent();
        out.print("new<");
        node.type.evaluate(cx, this);
        out.print(">");
        
        push_in();
        if (node.elementlist != null)
        {
            node.elementlist.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, SuperExpressionNode node)
    {
        indent();
        out.print("superexpression");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, MemberExpressionNode node)
    {
        indent();
        out.print("member");
        push_in();
        if (node.base != null)
        {
            node.base.evaluate(cx, this);
        }
        separate();
        if (node.selector != null)
        {
            node.selector.evaluate(cx, this);
        }
        pop_out();

        return null;
    }

    public Value evaluate(Context cx, InvokeNode node)
    {
        indent();
        out.print("invoke");
        out.print((node.getMode() == LEFTBRACKET_TOKEN ? " bracket" :
            node.getMode() == LEFTPAREN_TOKEN ? " filter" :
            node.getMode() == DOUBLEDOT_TOKEN ? " descend" :
            node.getMode() == EMPTY_TOKEN ? " lexical" : " dot"));
        push_in();
        out.print(node.name);
        separate();
        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, CallExpressionNode node)
    {
        indent();
        out.print((node.is_new ? "construct" : "call"));
        out.print((node.getMode() == LEFTBRACKET_TOKEN ? " bracket" :
            node.getMode() == LEFTPAREN_TOKEN ? " filter" :
            node.getMode() == DOUBLEDOT_TOKEN ? " descend" :
            node.getMode() == EMPTY_TOKEN ? " lexical" : " dot"));
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        separate();

        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, DeleteExpressionNode node)
    {
        indent();
        out.print("delete");
        out.print((node.getMode() == LEFTBRACKET_TOKEN ? " bracket" :
            node.getMode() == LEFTPAREN_TOKEN ? " filter" :
            node.getMode() == DOUBLEDOT_TOKEN ? " descend" :
            node.getMode() == EMPTY_TOKEN ? " lexical" : " dot"));
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        indent();
        out.print("applytype");
        push_in();
        node.typeArgs.evaluate(cx, this);
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, GetExpressionNode node)
    {
        indent();
        out.print("get");
        out.print((node.getMode() == LEFTBRACKET_TOKEN ? " bracket" :
            node.getMode() == LEFTPAREN_TOKEN ? " filter" :
            node.getMode() == DOUBLEDOT_TOKEN ? " descend" :
            node.getMode() == EMPTY_TOKEN ? " lexical" : " dot"));
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, SetExpressionNode node)
    {
        indent();
        out.print("set");
        out.print((node.getMode() == LEFTBRACKET_TOKEN ? " bracket" :
            node.getMode() == LEFTPAREN_TOKEN ? " filter" :
            node.getMode() == DOUBLEDOT_TOKEN ? " descend" :
            node.getMode() == EMPTY_TOKEN ? " lexical" : " dot"));
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        separate();
        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, UnaryExpressionNode node)
    {
        indent();
        out.print("unary");
        push_in();
        out.print(Token.getTokenClassName(node.op));
        pop_out();
        separate();
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, BinaryExpressionNode node)
    {
        indent();
        out.print("binary");
        push_in();
        out.print(Token.getTokenClassName(node.op));
        pop_out();
        separate();
        push_in();
        if (node.lhs != null)
        {
            node.lhs.evaluate(cx, this);
        }
        separate();
        if (node.rhs != null)
        {
            node.rhs.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ConditionalExpressionNode node)
    {
        indent();
        out.print("cond");
        push_in();
        if (node.condition != null)
        {
            node.condition.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.thenexpr != null)
        {
            node.thenexpr.evaluate(cx, this);
        }
        separate();
        if (node.elseexpr != null)
        {
            node.elseexpr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ArgumentListNode node)
    {
        indent();
        out.print("argumentlist");

        push_in();

        for (Node n : node.items)
        {
            n.evaluate(cx, this);
            separate();
        }

        pop_out();

        return null;
    }

    public Value evaluate(Context cx, ListNode node)
    {
        indent();
        out.print("list");

        push_in();

        for (Node n : node.items)
        {
            n.evaluate(cx, this);
            separate();
        }

        pop_out();

        return null;
    }

    // Statements

    public Value evaluate(Context cx, StatementListNode node)
    {
        indent();
        out.print("statementlist");
        push_in();

        for (Node n : node.items)
        {
            if (n != null)
            {
                n.evaluate(cx, this);
            }
        }

        pop_out();

        return null;
    }

    public Value evaluate(Context cx, EmptyElementNode node)
    {
        indent();
        out.print("empty");
        return null;
    }

    public Value evaluate(Context cx, EmptyStatementNode node)
    {
        indent();
        out.print("empty");
        return null;
    }

    public Value evaluate(Context cx, ExpressionStatementNode node)
    {
        indent();
        out.print("expression");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, SuperStatementNode node)
    {
        indent();
        out.print("super");
        push_in();
        if (node.call.args != null)
        {
            node.call.args.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, LabeledStatementNode node)
    {
        indent();
        out.print("labeled");
        push_in();
        if (node.label != null)
        {
            node.label.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, IfStatementNode node)
    {
        indent();
        out.print("if");
        push_in();
        if (node.condition != null)
        {
            node.condition.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.thenactions != null)
        {
            node.thenactions.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.elseactions != null)
        {
            node.elseactions.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, SwitchStatementNode node)
    {
        indent();
        out.print("switch");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, CaseLabelNode node)
    {
        indent();
        out.print("case");
        push_in();
        if (node.label != null)
        {
            node.label.evaluate(cx, this);
        }
        else
        {
            out.print("default");
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, DoStatementNode node)
    {
        indent();
        out.print("do");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, WhileStatementNode node)
    {
        indent();
        out.print("while");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ForStatementNode node)
    {
        indent();
        out.print("for");
        push_in();
        if (node.initialize != null)
        {
            node.initialize.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.test != null)
        {
            node.test.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.increment != null)
        {
            node.increment.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, WithStatementNode node)
    {
        indent();
        out.print("with");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ContinueStatementNode node)
    {
        indent();
        out.print("continue");
        push_in();
        if (node.id != null)
        {
            node.id.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, BreakStatementNode node)
    {
        indent();
        out.print("break");
        push_in();
        if (node.id != null)
        {
            node.id.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ReturnStatementNode node)
    {
        indent();
        out.print("return");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ThrowStatementNode node)
    {
        indent();
        out.print("throw");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, TryStatementNode node)
    {
        indent();
        out.print("try");
        push_in();
        if (node.tryblock != null)
        {
            node.tryblock.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.catchlist != null)
        {
            node.catchlist.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.finallyblock != null)
        {
            node.finallyblock.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, CatchClauseNode node)
    {
        indent();
        out.print("catch");
        push_in();
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, FinallyClauseNode node)
    {
        indent();
        out.print("finally");
        push_in();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, UseDirectiveNode node)
    {
        indent();
        out.print("use");
        if( node.expr != null )
        {
            node.expr.evaluate(cx,this);
        }
        return null;
    }

    public Value evaluate(Context cx, IncludeDirectiveNode node)
    {
        indent();
        out.print("include");
        push_in();
        if (node.filespec != null)
        {
            node.filespec.evaluate(cx, this);
        }
        separate();
        if (node.program != null)
        {
            // node.program.evaluate(cx, this);
        }
        pop_out();

        return null;
    }

    // Definitions

    public Value evaluate(Context cx, ImportDirectiveNode node)
    {
        indent();
        out.print("import");
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        pop_out();

        return null;
    }

    public Value evaluate(Context cx, AttributeListNode node)
    {
        indent();
        out.print("attributelist");

        push_in();

        for (Node n : node.items)
        {
            n.evaluate(cx, this);
            separate();
        }

        pop_out();

        return null;
    }

    public Value evaluate(Context cx, VariableDefinitionNode node)
    {
        indent();
        if (node.kind == CONST_TOKEN)
        {
            out.print("const");
        }
        else
        {
            out.print("var");
        }
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, VariableBindingNode node)
    {
        indent();
        out.print("variablebinding");
        push_in();
        if (node.variable != null)
        {
            node.variable.evaluate(cx, this);
        }
        separate();
        if (node.initializer != null)
        {
            node.initializer.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, UntypedVariableBindingNode node)
    {
        indent();
        out.print("untypedvariablebinding");
        push_in();
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        separate();
        if (node.initializer != null)
        {
            node.initializer.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, TypedIdentifierNode node)
    {
        indent();
        out.print("typedidentifier");
        push_in();
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        separate();
        if (node.type != null)
        {
            node.type.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, FunctionDefinitionNode node)
    {
        indent();
        out.print("function");
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        separate();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        separate();
        if (node.fexpr != null)
        {
            node.fexpr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
    {
        indent();
        out.print("functionname");
        out.print((node.kind == GET_TOKEN ? " get" :
            node.kind == SET_TOKEN ? " set" : ""));
        push_in();
        if (node.identifier != null)
        {

            node.identifier.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, FunctionSignatureNode node)
    {
        indent();
        out.print(node.inits != null ? "constructorsignature" : "functionsignature" );
        push_in();
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }
        separate();
        if (node.result != null)
        {
            node.result.evaluate(cx, this);
        }
        if (node.inits != null)
        {
        	node.inits.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ParameterNode node)
    {
        indent();
        out.print("parameter");
        if (node.kind == CONST_TOKEN)
        {
            out.print(" const");
        }
        push_in();
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        separate();
        if (node.init != null)
        {
            node.init.evaluate(cx, this);
        }
        separate();
        if (node.type != null)
        {
            node.type.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, RestExpressionNode node)
    {
        indent();
        out.print("restexpression");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, RestParameterNode node)
    {
        indent();
        out.print("restparameter");
        push_in();
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ClassDefinitionNode node)
    {
        indent();
        out.print("class");
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        separate();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        separate();
        if (node.baseclass != null)
        {
            node.baseclass.evaluate(cx, this);
        }
        separate();
        if (node.interfaces != null)
        {
            node.interfaces.evaluate(cx, this);
        }
        separate();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, InterfaceDefinitionNode node)
    {
        indent();
        out.print("interface");
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        separate();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        separate();
        if (node.interfaces != null)
        {
            node.interfaces.evaluate(cx, this);
        }
        separate();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ClassNameNode node)
    {
        indent();
        out.print("classname");
        push_in();
        if (node.pkgname != null)
        {
            node.pkgname.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.ident != null)
        {
            node.ident.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, InheritanceNode node)
    {
        if (node.baseclass != null)
        {
            indent();
            out.print("extends");
            push_in();
            node.baseclass.evaluate(cx, this);
            pop_out();
        }
        separate();
        if (node.interfaces != null)
        {
            indent();
            out.print("implements");
            push_in();
            node.interfaces.evaluate(cx, this);
            pop_out();
        }
        return null;
    }

    public Value evaluate(Context cx, NamespaceDefinitionNode node)
    {
        indent();
        out.print("namespace");
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.value != null)
        {
            node.value.evaluate(cx, this);
        }
        pop_out();
        return null;
    }
    public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node)
    {
        indent();
        out.print("config namespace");
        push_in();
        if (node.attrs != null)
        {
            node.attrs.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        pop_out();
        separate();
        push_in();
        if (node.value != null)
        {
            node.value.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, PackageDefinitionNode node)
    {
        indent();
        out.print("package");
        push_in();
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, PackageIdentifiersNode node)
    {
        indent();
        out.print("packageidentifiers");
        push_in();

        for (IdentifierNode n : node.list)
        {
            n.evaluate(cx, this);
            separate();
        }

        pop_out();
        return null;
    }

    public Value evaluate(Context cx, PackageNameNode node)
    {
        indent();
        out.print("packagename");
        push_in();
        if (node.id != null)
        {
            node.id.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, ProgramNode node)
    {
        indent();
        out.print("program");
        push_in();
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        pop_out();
        out.println();
        return null;
    }

    public Value evaluate(Context cx, ErrorNode node)
    {
        indent();
        out.print("error");
        out.print(node.errorCode);
        return null;
    }

    public Value evaluate(Context cx, ToObjectNode node)
    {
        indent();
        out.print("toobject");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        out.println();
        return null;
    }

    public Value evaluate(Context cx, LoadRegisterNode node)
    {
        indent();
        out.print("loadregister");
        push_in();
        if (node.reg != null)
        {
            node.reg.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, StoreRegisterNode node)
    {
        indent();
        out.print("storeregister");
        push_in();
        if (node.reg != null)
        {
            node.reg.evaluate(cx, this);
        }
        pop_out();
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        out.println();
        return null;
    }

    public Value evaluate(Context cx, RegisterNode node)
    {
        indent();
        out.print("register");

        push_in();
        out.print(node.index);
        return null;
    }

    public Value evaluate(Context cx, HasNextNode node)
    {
        indent();
        out.print("hasNext");

        push_in();
        if (node.objectRegister != null)
        {
            node.objectRegister.evaluate(cx, this);
        }
        pop_out();
        push_in();
        if (node.indexRegister != null)
        {
            node.indexRegister.evaluate(cx, this);
        }
        pop_out();
        out.println();
        return null;
    }
    
    public Value evaluate(Context cx, BoxNode node)
    {
        indent();
        out.print("box");
        out.print(node.actual);
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, CoerceNode node)
    {
        indent();
        out.print("coerce");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, PragmaNode node)
    {
        indent();
        out.print("pragma");
        push_in();
        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate(Context cx, UsePrecisionNode node)
    {
        indent();
        out.print("usePrecision(" + node.precision + ")");
        return null;
    }

    private static String[] usageName = {"Number", "decimal", "double", "int", "uint"};
    public Value evaluate(Context cx, UseNumericNode node)
    {
        indent();
        out.print("useNumeric(" + usageName[node.numeric_mode] + ")");
        return null;
    }

    public Value evaluate(Context cx, UseRoundingNode node)
    {
        indent();
        out.print("useRounding(" + NumberUsage.roundingModeName[node.mode] + ")");
        return null;
    }

    public Value evaluate(Context cx, PragmaExpressionNode node)
    {
        indent();
        out.print("pragmaitem");
        push_in();
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate( Context cx, ParameterListNode node )
    {
        indent();
        out.print("parameterlist");

        push_in();

        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            ParameterNode param = node.items.get(i);

            if (param != null)
            {
                param.evaluate(cx, this);
            }

            if (i < size - 1)
            {
                separate();
            }
        }

        pop_out();

        return null;
    }

    public Value evaluate(Context cx, MetaDataNode node)
    {
        if (node.data != null)
        {
            MetaDataEvaluator mde = new MetaDataEvaluator();
            mde.evaluate(cx, node);
        }

        indent();
        out.print("metadata:");
        out.print(node.getId() !=null? node.getId() :"");
        out.print(" ");
        for (int i = 0, length = (node.getValues() == null) ? 0 : node.getValues().length; i < length; i++)
        {
            Value v = node.getValues()[i];
            if (v instanceof MetaDataEvaluator.KeyValuePair)
            {
                MetaDataEvaluator.KeyValuePair pair = (MetaDataEvaluator.KeyValuePair) v;
                out.print("[" + pair.key + "," + pair.obj + "]");
            }

            if (v instanceof MetaDataEvaluator.KeylessValue)
            {
                MetaDataEvaluator.KeylessValue val = (MetaDataEvaluator.KeylessValue) v;
                out.print("[" + val.obj + "]");
            }
        }
        return null;
    }

    public Value evaluate(Context cx, DefaultXMLNamespaceNode node)
    {
        indent();
        out.print("dxns");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }

    public Value evaluate( Context cx, DocCommentNode node )   
    { 
        evaluate(cx,(MetaDataNode)node);
        return null;
    }

    public Value evaluate( Context cx, ImportNode node )
    {
        return null;
    }

    public Value evaluate( Context cx, BinaryProgramNode node )
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        indent();
        out.print("typeexpr");
        push_in();
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        pop_out();
        return null;
    }
}

