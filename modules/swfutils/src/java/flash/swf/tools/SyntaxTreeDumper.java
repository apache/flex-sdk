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

package flash.swf.tools;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import macromedia.asc.parser.*;
import macromedia.asc.semantics.Value;
import macromedia.asc.semantics.QName;
import macromedia.asc.util.Context;

/**
 * Utility for dumping an ASC AST in XML format.
 *
 * @author Paul Reilly
 */
public class SyntaxTreeDumper implements Evaluator
{
    private int indent;
    private PrintWriter out;
    private boolean showPositions = false;

    public SyntaxTreeDumper(PrintWriter out)
    {
        this(out, false);
    }

    public SyntaxTreeDumper(PrintWriter out, boolean showPositions)
    {
        this(out, 0);
        this.showPositions = showPositions;
    }

    public SyntaxTreeDumper(PrintWriter out, int indent)
    {
        this.out = out;
        this.indent = indent;
    }

    public boolean checkFeature(Context cx, Node node)
    {
        return true;
    }

    public static void dump(ProgramNode program, String fileName)
    {
        try
        {
            PrintWriter out = new PrintWriter(new FileWriter(fileName));
            program.evaluate(program.cx, (new SyntaxTreeDumper(out)));
            out.flush();
        }
        catch (IOException ioException)
        {
            ioException.printStackTrace();
        }
    }

    public static void dump(Node node, Context context, String fileName)
    {
        try
        {
            PrintWriter out = new PrintWriter(new FileWriter(fileName));
            node.evaluate(context, (new SyntaxTreeDumper(out)));
            out.flush();
        }
        catch (IOException ioException)
        {
            ioException.printStackTrace();
        }
    }

    public Value evaluate(Context cx, ApplyTypeExprNode node)
    {
        output("<ApplyTypeExprNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        
        output("<expr>");
        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }
        output("</expr>");
        
        output("<typeArgs>");
        if (node.typeArgs != null)
        {
            indent++;
            node.typeArgs.evaluate(cx, this);
            indent--;
        }
        output("</typeArgs>");
        
        indent--;
        output("</ApplyTypeExprNode>");
        return null;
    }

    public Value evaluate(Context cx, BlockNode node)
    {
        output("<BlockNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        indent++;
        if (node.attributes != null)
        {
            node.attributes.evaluate(cx, this);
        }
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        indent--;
        output("</BlockNode>");

        return null;
    }

    public Value evaluate(Context cx, CommentNode node)
    {
        output("<CommentNode type=\"" + node.getType() + "\" comment=\"" + node + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, Node node)
    {
        output("<Node" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, IdentifierNode node)
    {
        output("<IdentifierNode name=\"" + node.name + "\"/>");
        return null;
    }

    public Value evaluate(Context cx, IncrementNode node)
    {
        output("<IncrementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " mode=\"" + modeToString(node.getMode()) + "\">");

        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</IncrementNode>");
        return null;
    }

    public Value evaluate(Context cx, ThisExpressionNode node)
    {
        output("<ThisExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, QualifiedIdentifierNode node)
    {
        if (node.qualifier != null)
        {
            output("<QualifiedIdentifierNode name=\"" + node.name + "\">");
            indent++;
            node.qualifier.evaluate(cx, this);
            indent--;
            output("</QualifiedIdentifierNode>");
        }
        else
        {
            output("<QualifiedIdentifierNode name=\"" + node.name + "\"/>");
        }
        return null;
    }

    public Value evaluate(Context cx, QualifiedExpressionNode node)
    {
        if( node.ref == null)
        {
            evaluate(cx,(QualifiedIdentifierNode)node);
            node.expr.evaluate(cx,this);
        }
        return node.ref;
    }

    public Value evaluate(Context cx, LiteralBooleanNode node)
    {
        output("<LiteralBooleanNode value=\"" + node.value + "\"/>");
        return null;
    }

    public Value evaluate(Context cx, LiteralNumberNode node)
    {
        output("<LiteralNumberNode value=\"" + node.value + "\"/>");
        return null;
    }

    public Value evaluate(Context cx, LiteralStringNode node)
    {
        if (node.value.length() > 0)
        {
            output("<LiteralStringNode value=\"" + node.value + "\"/>");
        }
        return null;
    }

    public Value evaluate(Context cx, LiteralNullNode node)
    {
        output("<LiteralNullNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, LiteralRegExpNode node)
    {
        output("<LiteralRegExpNode value=\"" + node.value + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, LiteralXMLNode node)
    {
        output("<LiteralXMLNode is_xmllist=\"" + node.is_xmllist + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        indent--;
        output("</LiteralXMLNode>");
        return null;
    }

    public Value evaluate(Context cx, FunctionCommonNode node)
    {
        output("<FunctionCommonNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }

        if (node.default_dxns != null)
        {
            node.default_dxns.evaluate(cx, this);
        }

        if (node.signature != null)
        {
            node.signature.evaluate(cx, this);
        }

        if (node.body != null)
        {
            node.body.evaluate(cx, this);
        }

        indent--;
        output("</FunctionCommonNode>");
        return null;
    }

    public Value evaluate(Context cx, ParenExpressionNode node)
    {
        output("<ParenExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, ParenListExpressionNode node)
    {
        output("<ParenListExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        indent--;
        output("</ParenListExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, LiteralObjectNode node)
    {
        output("<LiteralObjectNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.fieldlist != null)
        {
            node.fieldlist.evaluate(cx, this);
        }
        indent--;
        output("</LiteralObjectNode>");
        return null;
    }

    public Value evaluate(Context cx, LiteralFieldNode node)
    {
        output("<LiteralFieldNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.name != null)
        {
            node.name.evaluate(cx, this);
        }
        if (node.value != null)
        {
            node.value.evaluate(cx, this);
        }
        indent--;
        output("</LiteralFieldNode>");
        return null;
    }

    public Value evaluate(Context cx, LiteralArrayNode node)
    {
        output("<LiteralArrayNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.elementlist != null)
        {
            node.elementlist.evaluate(cx, this);
        }
        indent--;
        output("</LiteralArrayNode>");
        return null;
    }

	public Value evaluate(Context cx, LiteralVectorNode node)
    {
        output("<LiteralVectorNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

		node.type.evaluate(cx, this);

        if (node.elementlist != null)
        {
            node.elementlist.evaluate(cx, this);
        }

        indent--;
        output("</LiteralVectorNode>");
        return null;
    }

    public Value evaluate(Context cx, SuperExpressionNode node)
    {
        output("<SuperExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</SuperExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, MemberExpressionNode node)
    {
        output("<MemberExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.base != null)
        {
            output("<base>");
            indent++;
            node.base.evaluate(cx, this);
            indent--;
            output("</base>");
        }

        if (node.selector != null)
        {
            output("<selector>");
            indent++;
            node.selector.evaluate(cx, this);
            indent--;
            output("</selector>");
        }

        indent--;
        output("</MemberExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, InvokeNode node)
    {
        output("<InvokeNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " mode=\"" + modeToString(node.getMode()) + "\">");

        if (node.args != null)
        {
            indent++;
            node.args.evaluate(cx, this);
            indent--;
        }

        output("</InvokeNode>");
        return null;
    }

    public Value evaluate(Context cx, CallExpressionNode node)
    {
        output("<CallExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " is_new=\"" + node.is_new +
               "\" is_package=\"" + node.is_package +
               "\" isRValue=\"" + node.isRValue() +
               "\" isAttr=\"" + node.isAttr() +
               "\" isSuper=\"" + node.isSuper() +
               "\" isThis=\"" + node.isThis() +
               "\" isVoidResult=\"" + node.isVoidResult() +
               "\" mode=\"" + modeToString(node.getMode()) + "\">");

        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }
        indent--;
        output("</CallExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, DeleteExpressionNode node)
    {
        output("<DeleteExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " mode=\"" + modeToString(node.getMode()) + "\">");

        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</DeleteExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, GetExpressionNode node)
    {
        output("<GetExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " is_package=\"" + node.is_package +
               "\" isRValue=\"" + node.isRValue() +
               "\" isAttr=\"" + node.isAttr() +
               "\" isSuper=\"" + node.isSuper() +
               "\" isThis=\"" + node.isThis() +
               "\" isVoidResult=\"" + node.isVoidResult() +
               "\" mode=\"" + modeToString(node.getMode()) + "\">");

        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</GetExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, SetExpressionNode node)
    {
        output("<SetExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " is_constinit=\"" + node.is_constinit +
               "\" is_initializer=\"" + node.is_initializer +
               "\" is_package=\"" + node.is_package +
               "\" isRValue=\"" + node.isRValue() +
               "\" isAttr=\"" + node.isAttr() +
               "\" isSuper=\"" + node.isSuper() +
               "\" isThis=\"" + node.isThis() +
               "\" isVoidResult=\"" + node.isVoidResult() +
               "\" mode=\"" + modeToString(node.getMode()) + "\">");

        indent++;

        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        if (node.args != null)
        {
            node.args.evaluate(cx, this);
        }

        indent--;
        output("</SetExpressionNode>");

        return null;
    }

    public Value evaluate(Context cx, UnaryExpressionNode node)
    {
        output("<UnaryExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        indent--;
        output("</UnaryExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, BinaryExpressionNode node)
    {
        output("<BinaryExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.lhs != null)
        {
            node.lhs.evaluate(cx, this);
        }
        if (node.rhs != null)
        {
            node.rhs.evaluate(cx, this);
        }
        indent--;
        output("</BinaryExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, ConditionalExpressionNode node)
    {
        output("<ConditionalExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.condition != null)
        {
            node.condition.evaluate(cx, this);
        }
        if (node.thenexpr != null)
        {
            node.thenexpr.evaluate(cx, this);
        }
        if (node.elseexpr != null)
        {
            node.elseexpr.evaluate(cx, this);
        }
        indent--;
        output("</ConditionalExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, ArgumentListNode node)
    {
        output("<ArgumentListNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        // for (Node n : node.items)
        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            Node n = node.items.get(i);
            n.evaluate(cx, this);
        }
        indent--;
        output("</ArgumentListNode>");
        return null;
    }

    public Value evaluate(Context cx, ListNode node)
    {
        output("<ListNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        // for (Node n : node.items)
        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            Node n = node.items.get(i);
            n.evaluate(cx, this);
        }
        indent--;
        output("</ListNode>");
        return null;
    }

    // Statements

    public Value evaluate(Context cx, StatementListNode node)
    {
        output("<StatementListNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.config_attrs != null)
        {
            output("<config_attrs>");
            indent++;
            node.config_attrs.evaluate(cx, this);
            indent--;
            output("</config_attrs>");
        }

        output("<items>");
        indent++;
        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            Node n = node.items.get(i);
            if (n != null)
            {
                n.evaluate(cx, this);
            }
        }
        indent--;
        output("</items>");
        indent--;
        output("</StatementListNode>");
        return null;
    }

    public Value evaluate(Context cx, EmptyElementNode node)
    {
        output("<EmptyElementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, EmptyStatementNode node)
    {
        output("<EmptyStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, ExpressionStatementNode node)
    {
        output("<ExpressionStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</ExpressionStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, SuperStatementNode node)
    {
        output("<SuperStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.call != null)
        {
            indent++;
            node.call.evaluate(cx, this);
            indent--;
        }

        output("</SuperStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, LabeledStatementNode node)
    {
        output("<LabeledStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.label != null)
        {
            node.label.evaluate(cx, this);
        }
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        indent--;
        output("</LabeledStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, IfStatementNode node)
    {
        output("<IfStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.condition != null)
        {
            node.condition.evaluate(cx, this);
        }
        if (node.thenactions != null)
        {
            node.thenactions.evaluate(cx, this);
        }
        if (node.elseactions != null)
        {
            node.elseactions.evaluate(cx, this);
        }
        indent--;
        output("</IfStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, SwitchStatementNode node)
    {
        output("<SwitchStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        indent--;
        output("</SwitchStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, CaseLabelNode node)
    {
        output("<CaseLabelNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.label != null)
        {
            node.label.evaluate(cx, this);
        }
        indent--;
        output("</CaseLabelNode>");
        return null;
    }

    public Value evaluate(Context cx, DoStatementNode node)
    {
        output("<DoStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        indent--;
        output("</DoStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, WhileStatementNode node)
    {
        output("<WhileStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        indent--;
        output("</WhileStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, ForStatementNode node)
    {
        output("<ForStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.initialize != null)
        {
            node.initialize.evaluate(cx, this);
        }
        if (node.test != null)
        {
            node.test.evaluate(cx, this);
        }
        if (node.increment != null)
        {
            node.increment.evaluate(cx, this);
        }
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        indent--;
        output("</ForStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, WithStatementNode node)
    {
        output("<WithStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        if (node.statement != null)
        {
            node.statement.evaluate(cx, this);
        }
        indent--;
        output("</WithStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, ContinueStatementNode node)
    {
        output("<ContinueStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.id != null)
        {
            indent++;
            node.id.evaluate(cx, this);
            indent--;
        }

        output("</ContinueStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, BreakStatementNode node)
    {
        output("<BreakStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.id != null)
        {
            indent++;
            node.id.evaluate(cx, this);
            indent--;
        }

        output("</BreakStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, ReturnStatementNode node)
    {
        output("<ReturnStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        if (node.expr != null)

        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</ReturnStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, ThrowStatementNode node)
    {
        output("<ThrowStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.expr != null)
        {
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
        }

        output("</ThrowStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, TryStatementNode node)
    {
        output("<TryStatementNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.tryblock != null)
        {
            node.tryblock.evaluate(cx, this);
        }
        if (node.catchlist != null)
        {
            node.catchlist.evaluate(cx, this);
        }
        if (node.finallyblock != null)
        {
            node.finallyblock.evaluate(cx, this);
        }

        indent--;
        output("</TryStatementNode>");
        return null;
    }

    public Value evaluate(Context cx, CatchClauseNode node)
    {
        output("<CatchClauseNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }
        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }
        indent--;
        output("</CatchClauseNode>");
        return null;
    }

    public Value evaluate(Context cx, FinallyClauseNode node)
    {
        output("<FinallyClauseNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.statements != null)
        {
            indent++;
            node.statements.evaluate(cx, this);
            indent--;
        }

        output("</FinallyClauseNode>");
        return null;
    }

    public Value evaluate(Context cx, UseDirectiveNode node)
    {
        output("<UseDirectiveNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.attrs != null)
        {
            indent++;
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
            indent--;
        }

        if (node.expr != null)
        {
            indent++;
            output("<expr>");
            indent++;
            node.expr.evaluate(cx, this);
            indent--;
            output("</expr>");
            indent--;
        }

        output("</UseDirectiveNode>");

        return null;
    }

    public Value evaluate(Context cx, IncludeDirectiveNode node)
    {
        output("<IncludeDirectiveNode in_this_include=\"" + node.in_this_include + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        
        if (node.filespec != null)
        {
            indent++;
            output("<filespec>");
            indent++;
            node.filespec.evaluate(cx, this);
            indent--;
            output("</filespec>");
            indent--;
        }

        output("</IncludeDirectiveNode>");
        return null;
    }

    // Definitions

    public Value evaluate(Context cx, ImportDirectiveNode node)
    {
        output("<ImportDirectiveNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        indent--;
        output("</ImportDirectiveNode>");
        return null;
    }

    public Value evaluate(Context cx, AttributeListNode node)
    {
        StringBuilder buffer = new StringBuilder("<AttributeListNode");
        if (node.hasIntrinsic)
        {
            buffer.append(" intrinsic='true'");
        }
        if (node.hasStatic)
        {
            buffer.append(" static='true'");
        }
        if (node.hasFinal)
        {
            buffer.append(" final='true'");
        }
        if (node.hasVirtual)
        {
            buffer.append(" virtual='true'");
        }
        if (node.hasOverride)
        {
            buffer.append(" override='true'");
        }
        if (node.hasDynamic)
        {
            buffer.append(" dynamic='true'");
        }
        if (node.hasNative)
        {
            buffer.append(" native='true'");
        }
        if (node.hasPrivate)
        {
            buffer.append(" private='true'");
        }
        if (node.hasProtected)
        {
            buffer.append(" protected='true'");
        }
        if (node.hasPublic)
        {
            buffer.append(" public='true'");
        }
        if (node.hasInternal)
        {
            buffer.append(" internal='true'");
        }
        if (node.hasConst)
        {
            buffer.append(" const='true'");
        }
        if (node.hasFalse)
        {
            buffer.append(" false='true'");
        }
        if (node.hasPrototype)
        {
            buffer.append(" prototype='true'");
        }
        buffer.append("" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        output( buffer.toString() );
        indent++;
        // for (Node n : node.items)
        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            Node n = node.items.get(i);
            n.evaluate(cx, this);
        }
        indent--;
        output("</AttributeListNode>");
        return null;
    }

    public Value evaluate(Context cx, VariableDefinitionNode node)
    {
        output("<VariableDefinitionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.list != null)
        {
            output("<list>");
            indent++;
            node.list.evaluate(cx, this);
            indent--;
            output("</list>");
        }

        indent--;
        output("</VariableDefinitionNode>");
        return null;
    }

    public Value evaluate(Context cx, VariableBindingNode node)
    {
        output("<VariableBindingNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.variable != null)
        {
            node.variable.evaluate(cx, this);
        }
        if (node.initializer != null)
        {
            node.initializer.evaluate(cx, this);
        }
        indent--;
        output("</VariableBindingNode>");
        return null;
    }

    public Value evaluate(Context cx, UntypedVariableBindingNode node)
    {
        output("<UntypedVariableBindingNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        if (node.initializer != null)
        {
            node.initializer.evaluate(cx, this);
        }
        indent--;
        output("</UntypedVariableBindingNode>");
        return null;
    }

    public Value evaluate(Context cx, TypeIdentifierNode node)
    {
        output("<TypeIdentifierNode name=\"" + node.name + "\"" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

        if (node.typeArgs != null)
        {
            indent++;
            node.typeArgs.evaluate(cx, this);
            indent--;
        }

        output("</TypeIdentifierNode>");
        return null;
    }

    public Value evaluate(Context cx, TypedIdentifierNode node)
    {
        output("<TypedIdentifierNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        if (node.type != null)
        {
            node.type.evaluate(cx, this);
        }
        indent--;
        output("</TypedIdentifierNode>");
        return null;
    }

    public Value evaluate(Context cx, BinaryFunctionDefinitionNode node)
    {
        return evaluate(node, cx, "BinaryFunctionDefinitionNode");
    }

    public Value evaluate(Context cx, FunctionDefinitionNode node)
    {
        return evaluate(node, cx, "FunctionDefinitionNode");
    }

    private Value evaluate(FunctionDefinitionNode node, Context cx, String name)
    {
        output("<" + name + ">");

        indent++;

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.fexpr != null)
        {
            output("<fexpr>");
            indent++;
            node.fexpr.evaluate(cx, this);
            indent--;
            output("</fexpr>");
        }

        indent--;

        output("</" + name + ">");

        return null;
    }

    public Value evaluate(Context cx, FunctionNameNode node)
    {
        output("<FunctionNameNode kind=\"" + node.kind + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        indent--;
        output("</FunctionNameNode>");
        return null;
    }

    public Value evaluate(Context cx, FunctionSignatureNode node)
    {
        output("<FunctionSignatureNode no_anno=\"" + node.no_anno +
               "\" void_anno=\"" + node.void_anno + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.inits != null)
        {
            node.inits.evaluate(cx, this);
        }

        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }

        if (node.result != null)
        {
            node.result.evaluate(cx, this);
        }

        indent--;
        output("</FunctionSignatureNode>");
        return null;
    }

    public Value evaluate(Context cx, ParameterNode node)
    {
        if ((0 <= node.kind) && (node.kind < Tokens.tokenClassNames.length))
        {
            output("<ParameterNode kind=\"" + Tokens.tokenClassNames[node.kind] + "\">");
        }
        else
        {
            output("<ParameterNode kind=\"" + node.kind + "\">");
        }
        indent++;
        if (node.identifier != null)
        {
            output("<identifier>");
            indent++;
            node.identifier.evaluate(cx, this);
            indent--;
            output("</identifier>");
        }
        if (node.type != null)
        {
            output("<type>");
            indent++;
            node.type.evaluate(cx, this);
            indent--;
            output("</type>");
        }
        if (node.init != null)
        {
            output("<init>");
            indent++;
            node.init.evaluate(cx, this);
            indent--;
            output("</init>");
        }
        indent--;
        output("</ParameterNode>");
        return null;
    }

    public Value evaluate(Context cx, RestExpressionNode node)
    {
        output("<RestExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        indent--;
        output("</RestExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, RestParameterNode node)
    {
        output("<RestParameterNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.parameter != null)
        {
            node.parameter.evaluate(cx, this);
        }
        indent--;
        output("</RestParameterNode>");
        return null;
    }

    public Value evaluate(Context cx, BinaryClassDefNode node)
    {
        return evaluate(node, cx, "BinaryClassDefNode");
    }

    public Value evaluate(Context cx, BinaryInterfaceDefinitionNode node)
    {
        return evaluate(node, cx, "BinaryInterfaceDefinitionNode");
    }

    public Value evaluate(Context cx, ClassDefinitionNode node)
    {
        return evaluate(node, cx, "ClassDefinitionNode");
    }

    private Value evaluate(ClassDefinitionNode node, Context cx, String name)
    {
        if ((node.name != null) && (node.name.name != null))
        {
            output("<" + name + " name=\"" + node.name.name + "\">");
        }
        else if ((node.cframe != null) && (node.cframe.builder != null))
        {
            output("<" + name + " name=\"" + node.cframe.builder.classname + "\">");
        }

        indent++;

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        if (node.baseclass != null)
        {
            output("<baseclass>");
            indent++;
            node.baseclass.evaluate(cx, this);
            indent--;
            output("</baseclass>");
        }

        if (node.interfaces != null)
        {
            output("<interfaces>");
            indent++;
            node.interfaces.evaluate(cx, this);
            indent--;
            output("</interfaces>");
        }

        if (node.fexprs != null)
        {
            output("<fexprs>");
            indent++;

            for (int i = 0, size = node.fexprs.size(); i < size; i++)
            {
                Node fexpr = node.fexprs.get(i);
                fexpr.evaluate(cx, this);
            }

            indent--;
            output("</fexprs>");
        }

        if (node.clsdefs != null)
        {
            output("<clsdefs>");
            indent++;

            for (int i = 0, size = node.clsdefs.size(); i < size; i++)
            {
                ClassDefinitionNode n = node.clsdefs.get(i);
                n.evaluate(cx, this);
            }

            indent--;
            output("</clsdefs>");
        }

        if (node.instanceinits != null)
        {
            output("<instanceinits>");
            indent++;

            for (int i = 0, size = node.instanceinits.size(); i < size; i++)
            {
                Node instanceinit = node.instanceinits.get(i);
                instanceinit.evaluate(cx, this);
            }

            indent--;
            output("</instanceinits>");
        }

        if (node.staticfexprs != null)
        {
            output("<staticfexprs>");
            indent++;

            for (int i = 0, size = node.staticfexprs.size(); i < size; i++)
            {
                Node staticfexpr = node.staticfexprs.get(i);
                staticfexpr.evaluate(cx, this);
            }

            indent--;
            output("</staticfexprs>");
        }

        if (node.statements != null)
        {
            output("<statements>");
            indent++;
            node.statements.evaluate(cx, this);
            indent--;
            output("</statements>");
        }

        if (node.pkgdef != null)
        {
            output("<pkgdef>");
            indent++;
            node.pkgdef.evaluate(cx, this);
            indent--;
            output("</pkgdef>");
        }

        indent--;
        output("</" + name + ">");
        return null;
    }

    public Value evaluate(Context cx, InterfaceDefinitionNode node)
    {
        if ((node.name != null) && (node.name.name != null))
        {
            output("<InterfaceDefinitionNode name=\"" + node.name.name + "\">");
        }
        else if ((node.cframe != null) && (node.cframe.builder != null))
        {
            output("<InterfaceDefinitionNode name=\"" + node.cframe.builder.classname + "\">");
        }

        indent++;

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        if (node.interfaces != null)
        {
            output("<interfaces>");
            indent++;
            node.interfaces.evaluate(cx, this);
            indent--;
            output("</interfaces>");
        }

        if (node.statements != null)
        {
            output("<statements>");
            indent++;
            node.statements.evaluate(cx, this);
            indent--;
            output("</statements>");
        }

        indent--;
        output("</InterfaceDefinitionNode>");
        return null;
    }

    public Value evaluate(Context cx, ClassNameNode node)
    {
        output("<ClassNameNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.pkgname != null)
        {
            node.pkgname.evaluate(cx, this);
        }
        if (node.ident != null)
        {
            node.ident.evaluate(cx, this);
        }
        indent--;
        output("</ClassNameNode>");
        return null;
    }

    public Value evaluate(Context cx, InheritanceNode node)
    {
        output("<InheritanceNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.baseclass != null)
        {
            node.baseclass.evaluate(cx, this);
        }
        if (node.interfaces != null)
        {
            node.interfaces.evaluate(cx, this);
        }
        indent--;
        output("</InheritanceNode>");
        return null;
    }

    public Value evaluate(Context cx, NamespaceDefinitionNode node)
    {
        output("<NamespaceDefinitionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        if (node.value != null)
        {
            output("<value>");
            indent++;
            node.value.evaluate(cx, this);
            indent--;
            output("</value>");
        }

        indent--;
        output("</NamespaceDefinitionNode>");
        return null;
    }

    public Value evaluate(Context cx, ConfigNamespaceDefinitionNode node)
    {
        output("<ConfigNamespaceDefinitionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.attrs != null)
        {
            output("<attrs>");
            indent++;
            node.attrs.evaluate(cx, this);
            indent--;
            output("</attrs>");
        }

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        if (node.value != null)
        {
            output("<value>");
            indent++;
            node.value.evaluate(cx, this);
            indent--;
            output("</value>");
        }

        indent--;
        output("</ConfigNamespaceDefinitionNode>");
        return null;
    }

    public Value evaluate(Context cx, PackageDefinitionNode node)
    {
        output("<PackageDefinitionNode>");
        indent++;

        if (node.name != null)
        {
            output("<name>");
            indent++;
            node.name.evaluate(cx, this);
            indent--;
            output("</name>");
        }

        if ((node.metaData != null) && !isMetaDataEmpty(node.metaData))
        {
            output("<metaData>");
            indent++;
            node.metaData.evaluate(cx, this);
            indent--;
            output("</metaData>");
        }

        if (node.statements != null)
        {
            // Don't evaluate node.statements, otherwise infinite loop occurs.
            output("<statements/>");
        }

        indent--;
        output("</PackageDefinitionNode>");
        return null;
    }

    public Value evaluate(Context cx, PackageIdentifiersNode node)
    {
        output("<PackageIdentifiersNode pkg_part=\"" + node.pkg_part +
               "\" def_part=\"" + node.def_part +
               "\" isDefinition=\"" + node.isDefinition() + "\"" +
               (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        output("<list>");
        indent++;
        for (int i = 0, size = node.list.size(); i < size; i++)
        {
            IdentifierNode n = node.list.get(i);
            n.evaluate(cx, this);
        }
        indent--;
        output("</list>");
        indent--;
        output("</PackageIdentifiersNode>");
        return null;
    }

    public Value evaluate(Context cx, PackageNameNode node)
    {
        output("<PackageNameNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.url != null)
        {
            output("<url>");
            indent++;
            node.url.evaluate(cx, this);
            indent--;
            output("</url>");
        }

        if (node.id != null)
        {
            output("<id>");
            indent++;
            if (node.id != null)
            {
                node.id.evaluate(cx, this);
            }
            indent--;
            output("<id>");
        }

        indent--;
        output("</PackageNameNode>");
        return null;
    }

    public Value evaluate(Context cx, ProgramNode node)
    {
        output("<ProgramNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.pkgdefs != null)
        {
            output("<pkgdefs>");
            indent++;

            for (int i = 0, size = node.pkgdefs.size(); i < size; i++)
            {
                PackageDefinitionNode n = node.pkgdefs.get(i);
                n.evaluate(cx, this);
            }

            indent--;
            output("</pkgdefs>");
        }

        if (node.statements != null)
        {
            output("<statements>");
            indent++;
            node.statements.evaluate(cx, this);
            indent--;
            output("</statements>");
        }

        if (node.fexprs != null)
        {
            output("<fexprs>");
            indent++;
            // for (FunctionCommonNode n : node.fexprs)
            for (int i = 0, size = node.fexprs.size(); i < size; i++)
            {
                FunctionCommonNode n = node.fexprs.get(i);
                n.evaluate(cx, this);
            }
            indent--;
            output("</fexprs>");
        }

        if (node.clsdefs != null)
        {
            output("<clsdefs>");
            indent++;

            for (int i = 0, size = node.clsdefs.size(); i < size; i++)
            {
                ClassDefinitionNode n = node.clsdefs.get(i);
                n.evaluate(cx, this);
            }

            indent--;
            output("</clsdefs>");
        }

        indent--;
        output("</ProgramNode>");
        return null;
    }

    public Value evaluate(Context cx, ErrorNode node)
    {
        output("<ErrorNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, ToObjectNode node)
    {
        output("<ToObjectNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, LoadRegisterNode node)
    {
        output("<LoadRegisterNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, StoreRegisterNode node)
    {
        output("<StoreRegisterNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        indent--;
        output("</StoreRegisterNode>");
        return null;
    }

    public Value evaluate(Context cx, BoxNode node)
    {
        output("<BoxNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        indent--;
        output("</BoxNode>");
        return null;
    }

    public Value evaluate(Context cx, CoerceNode node)
    {
        output("<CoerceNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.expr != null)
        {
            node.expr.evaluate(cx, this);
        }
        indent--;
        output("</CoerceNode>");
        return null;
    }

    public Value evaluate(Context cx, PragmaNode node)
    {
        output("<PragmaNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.list != null)
        {
            node.list.evaluate(cx, this);
        }
        indent--;
        output("</PragmaNode>");
        return null;
    }

    public Value evaluate(Context cx, PragmaExpressionNode node)
    {
        output("<PragmaExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }
        indent--;
        output("</PragmaExpressionNode>");
        return null;
    }

    public Value evaluate(Context cx, ParameterListNode node)
    {
        output("<ParameterListNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        for (int i = 0, size = node.items.size(); i < size; i++)
        {
            // ParameterNode param = node.items.get(i);
            ParameterNode param = node.items.get(i);
            if (param != null)
            {
                param.evaluate(cx, this);
            }
        }
        indent--;
        output("</ParameterListNode>");
        return null;
    }

    public Value evaluate(Context cx, MetaDataNode node)
    {
        output("<MetaDataNode id=\"" + node.getId() + "\">");

        if (node.data != null)
        {
            indent++;
            node.data.evaluate(cx, this);
            indent--;
        }

        output("</MetaDataNode>");
        return null;
    }

    public Value evaluate(Context context, DefaultXMLNamespaceNode node)
    {
        output("<DefaultXMLNamespaceNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.expr != null)
        {
            node.expr.evaluate(context, this);
        }

        indent--;
        output("</DefaultXMLNamespaceNode>");
        return null;
    }

    public Value evaluate(Context cx, DocCommentNode node)
    {
        if ((node.data != null) && 
            (node.data.elementlist != null) &&
            (node.data.elementlist.size() > 0))
        {
            output("<DocCommentNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");

            if (node.data != null)
            {
                indent++;
                node.data.evaluate(cx, this);
                indent--;
            }

            output("</DocCommentNode>");
        }

        return null;
    }

    public Value evaluate(Context cx, ImportNode node)
    {
        String id = node.filespec.value;
        QName qname = new QName(cx.publicNamespace(), id);
        output("<ImportNode value=" + qname + "/>");
        return null;
    }

    public Value evaluate(Context cx, BinaryProgramNode node)
    {
        output("<BinaryProgramNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;
        if (node.pkgdefs != null)
        {
            // for (PackageDefinitionNode n : node.pkgdefs)
            for (int i = 0, size = node.pkgdefs.size(); i < size; i++)
            {
                PackageDefinitionNode n = node.pkgdefs.get(i);
                n.evaluate(cx, this);
            }
        }

        if (node.statements != null)
        {
            node.statements.evaluate(cx, this);
        }

        if (node.fexprs != null)
        {
            // for (FunctionCommonNode n : node.fexprs)
            for (int i = 0, size = node.fexprs.size(); i < size; i++)
            {
                FunctionCommonNode n = node.fexprs.get(i);
                n.evaluate(cx, this);
            }
        }

        if (node.clsdefs != null)
        {
            // for (FunctionCommonNode n : node.clsdefs)
            for (int i = 0, size = node.clsdefs.size(); i < size; i++)
            {
                ClassDefinitionNode n = node.clsdefs.get(i);
                n.evaluate(cx, this);
            }
        }

        indent--;
        output("</BinaryProgramNode>");
        return null;
    }

    public Value evaluate(Context cx, RegisterNode node)
    {
        output("<RegisterNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, HasNextNode node)
    {
        return null;
    }

    public Value evaluate(Context cx, TypeExpressionNode node)
    {
        output("<TypeExpressionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") +
               " is_nullable=\"" + node.is_nullable +
               "\" nullable_annotation=\"" + node.nullable_annotation +
               "\">");
        indent++;
        node.expr.evaluate(cx, this);
        indent--;
        output("</TypeExpressionNode>");
        return null;
    }
    
    public Value evaluate(Context cx, UseNumericNode node)
    {
        output("<UseNumericNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, UsePragmaNode node)
    {
        output("<UsePragmaNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + ">");
        indent++;

        if (node.identifier != null)
        {
            node.identifier.evaluate(cx, this);
        }

        if (node.argument != null)
        {
            node.argument.evaluate(cx, this);
        }

        indent--;
        output("</UsePragmaNode>");
        return null;
    }

    public Value evaluate(Context cx, UsePrecisionNode node)
    {
        output("<UsePrecisionNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }

    public Value evaluate(Context cx, UseRoundingNode node)
    {
        output("<UseRoundingNode" + (showPositions ? " position=\"" + node.pos() + "\"" : "") + "/>");
        return null;
    }


    private String indent()
    {
        StringBuilder buffer = new StringBuilder();

        for (int i = 0; i < indent; i++)
        {
            buffer.append("  ");
        }

        return buffer.toString();
    }

    private boolean isMetaDataEmpty(StatementListNode metaData)
    {
        boolean result = true;

        if (metaData != null)
        {
            if (metaData.items.size() > 1)
            {
                result = false;                
            }
            else
            {
//                Object item = metaData.items.get(0);
//
//                if (item instanceof DocCommentNode)
//                {
//                    DocCommentNode docComment = (DocCommentNode) item;
//
//                    if ((docComment.data != null) && 
//                        (docComment.data.elementlist != null) &&
//                        (docComment.data.elementlist.size() > 0))
//                    {
//                        result = false;
//                    }
//                }
            }
        }

        return result;
    }

    private String modeToString(int mode)
    {
        String result;

        switch(mode)
        {
            case Tokens.LEFTBRACKET_TOKEN:
            {
                result = "bracket";
                break;
            }
            case Tokens.LEFTPAREN_TOKEN:
            {
                result = "filter";
                break;
            }
            case Tokens.DOUBLEDOT_TOKEN:
            {
                result = "descend";
                break;
            }
            case Tokens.EMPTY_TOKEN:
            {
                result = "lexical";
                break;
            }
            default:
            {
                result = "dot";
                break;
            }
        }

        return result;
    }

    private void output(String tag)
    {
        try
        {
            out.println(indent() + tag);
        }
        catch (Exception exception)
        {
            exception.printStackTrace();
        }
    }
}
