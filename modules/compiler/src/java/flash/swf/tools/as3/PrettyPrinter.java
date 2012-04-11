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

package flash.swf.tools.as3;

import java.io.PrintWriter;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

/**
 * A partial pretty printer for generating AS3 from ASC AST's.  It's
 * used by data binding when generating watchers for Array elements
 * and function return values.  We use a PrettyPrinter to recreate the
 * AS3 for the watcher args.
 *
 * @author Paul Reilly
 */
public class PrettyPrinter extends EvaluatorAdapter
    implements Tokens
{
    protected PrintWriter out;
    protected int indent;

    public PrettyPrinter(PrintWriter out)
    {
        this(out, 0);
    }

    public PrettyPrinter(PrintWriter out, int indent)
    {
        this.out = out;
        this.indent = indent;
    }

	public Value evaluate(Context cx, AttributeListNode node)
	{
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node n = node.items.get(i);
			n.evaluate(cx, this);
            out.print(" ");
		}
		return null;
	}

	public Value evaluate(Context cx, ArgumentListNode node)
	{
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node n = node.items.get(i);
			n.evaluate(cx, this);
            if ((i + 1) < size)
            {
                out.print(", ");
            }
		}
		return null;
	}

	public Value evaluate(Context cx, BinaryExpressionNode node)
	{
		if (node.lhs != null)
		{
			node.lhs.evaluate(cx, this);
		}

        op(node.op);

		if (node.rhs != null)
		{
			node.rhs.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, CallExpressionNode node)
	{
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
        out.print("(");
		if (node.args != null)
		{
			node.args.evaluate(cx, this);
		}
        out.print(")");
		return null;
	}

	public Value evaluate(Context cx, ClassDefinitionNode node)
	{
		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
        out.println("");
        out.print("class ");

        if ((node.name != null) && (node.name.name != null))
        {
			node.name.evaluate(cx, this);
        }
        else if ((node.cframe != null) && (node.cframe.builder != null))
        {
            out.print(node.cframe.builder.classname);
        }
        else
        {
            assert false : "No class name found for ClassDefinitionNode";
        }

		if (node.baseclass != null)
		{
            out.print(" extends ");
			node.baseclass.evaluate(cx, this);
		}
        out.println("");
		if (node.interfaces != null)
		{
            out.print("\timplements ");
			node.interfaces.evaluate(cx, this);
            out.println("");
		}
        out.println("{");
        indent++;
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
        indent--;
        out.println("}");
        return null;
    }

	public Value evaluate(Context cx, ForStatementNode node)
	{
        indent();
        out.print("for (");
		if (node.initialize != null)
		{
			node.initialize.evaluate(cx, this);
		}
        out.print("; ");
		if (node.test != null)
		{
			node.test.evaluate(cx, this);
		}
        out.print("; ");
		if (node.increment != null)
		{
			node.increment.evaluate(cx, this);
		}
        out.println(")");
        indent();
        out.println("{");
        indent++;
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
        indent--;
        indent();
        out.println("}");
		return null;
	}

	public Value evaluate(Context cx, FunctionCommonNode node)
	{
        out.print("(");
		if (node.signature != null)
		{
			node.signature.evaluate(cx, this);
		}
        out.println(")");
        indent();
        out.println("{");
        indent++;
		if (node.body != null)
		{
			node.body.evaluate(cx, this);
		}
        indent--;
        indent();
        out.println("}");
        out.println("");
		return null;
	}

	public Value evaluate(Context cx, FunctionDefinitionNode node)
	{
        indent();
		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
        out.print("function ");
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}
		if (node.fexpr != null)
		{
			node.fexpr.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, GetExpressionNode node)
	{
        if (node.expr != null)
        {
            if (node.expr instanceof ArgumentListNode)
            {
                out.print("[");
                node.expr.evaluate(cx, this);
                out.print("]");
            }
            else
            {
                node.expr.evaluate(cx, this);
            }
        }

		return null;
	}

	public Value evaluate(Context cx, IdentifierNode node)
	{
		out.print(node.name);
        return null;
	}

	public Value evaluate(Context cx, IfStatementNode node)
	{
        indent();
        out.print("if (");
		if (node.condition != null)
		{
			node.condition.evaluate(cx, this);
		}
        out.println(")");
        indent();
        out.println("{");
        indent++;
		if (node.thenactions != null)
		{
			node.thenactions.evaluate(cx, this);
		}
        indent--;
        indent();
        out.println("}");
		if (node.elseactions != null)
		{
            indent();
            out.println("else");
            indent();
            out.println("{");
            indent++;
			node.elseactions.evaluate(cx, this);
            indent--;
            indent();
            out.println("}");
		}
		return null;
	}

	public Value evaluate(Context cx, InterfaceDefinitionNode node)
	{
        indent();
        out.print("interface ");

        if ((node.name != null) && (node.name.name != null))
        {
			node.name.evaluate(cx, this);
        }
        else if ((node.cframe != null) && (node.cframe.builder != null))
        {
            out.print(node.cframe.builder.classname);
        }
        else
        {
            assert false : "No class name found for ClassDefinitionNode";
        }

		if (node.baseclass != null)
		{
            out.print(" extends ");
			node.baseclass.evaluate(cx, this);
		}
        out.println("");
        indent();
        out.println("{");
        indent++;
		if (node.statements != null)
		{
			node.statements.evaluate(cx, this);
		}
        indent--;
        indent();
        out.println("}");
        return null;
    }

	public Value evaluate(Context cx, ListNode node)
	{
		for (int i = 0, size = node.items.size(); i < size; i++)
		{
			Node n = node.items.get(i);
			n.evaluate(cx, this);
            if ((i + 1) < size)
            {
                out.print(", ");
            }
		}
		return null;
	}

	public Value evaluate(Context cx, LiteralArrayNode node)
	{
        out.print("[");
        super.evaluate(cx, node);
        out.print("]");
		return null;
	}

	public Value evaluate(Context cx, LiteralVectorNode node)
	{
		out.print("new<");
		
		evaluate(cx, node.type);

		out.print(">");
        out.print("[");
        super.evaluate(cx, node.elementlist);
        out.print("]");
		return null;
	}

	public Value evaluate(Context cx, LiteralBooleanNode node)
	{
        out.print(node.value);
		return null;
	}

	public Value evaluate(Context cx, LiteralFieldNode node)
	{
		if (node.name != null)
		{
			node.name.evaluate(cx, this);
		}

        out.print(": ");

		if (node.value != null)
		{
			node.value.evaluate(cx, this);
		}

		return null;
	}

	public Value evaluate(Context cx, LiteralNumberNode node)
	{
        out.print(node.value);
		return null;
	}

	public Value evaluate(Context cx, LiteralObjectNode node)
	{
        out.print("{");
        super.evaluate(cx, node);
        out.print("}");
		return null;
	}

	public Value evaluate(Context cx, LiteralStringNode node)
	{
        out.print("\"" + node.value + "\"");
		return null;
	}

	public Value evaluate(Context cx, LiteralNullNode node)
	{
        out.print("null");
		return null;
	}

	public Value evaluate(Context cx, LiteralRegExpNode node)
	{
        out.print(node.value);
		return null;
	}

	public Value evaluate(Context cx, LiteralXMLNode node)
	{
        assert false : "Not implemented yet.";
		return null;
	}

	public Value evaluate(Context cx, MemberExpressionNode node)
	{
		if (node.base != null)
		{
			node.base.evaluate(cx, this);
            if ((node.selector != null) && 
                (node.selector instanceof GetExpressionNode) && 
                (!(((GetExpressionNode) node.selector).expr instanceof ArgumentListNode)))
            {
                out.print(".");
            }
		}

        if (node.selector != null)
        {
            node.selector.evaluate(cx, this);
        }
		return null;
	}

	public Value evaluate(Context cx, ProgramNode node)
	{
        for (int i = 0; i < node.imports.size(); i++)
        {
            out.println("import ");
            out.println(node.imports.get(i));
            out.println(";");
        }

        return super.evaluate(cx, node);
	}

	public Value evaluate(Context cx, QualifiedIdentifierNode node)
	{
		if (node.qualifier != null)
		{
			node.qualifier.evaluate(cx, this);
		}
        evaluate(cx, (IdentifierNode) node);
		return null;
	}

	public Value evaluate(Context cx, ReturnStatementNode node)
	{
        indent();
        out.print("return ");
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
        out.println(";");
		return null;
	}

	public Value evaluate(Context cx, ThisExpressionNode node)
    {
        out.print("this");
        return null;
    }

	public Value evaluate(Context cx, TypedIdentifierNode node)
	{
		if (node.identifier != null)
		{
			node.identifier.evaluate(cx, this);
		}
		if (node.type != null)
		{
            out.print(":");
			node.type.evaluate(cx, this);
		}
		return null;
	}

	public Value evaluate(Context cx, VariableDefinitionNode node)
	{
        indent();
		if (node.attrs != null)
		{
			node.attrs.evaluate(cx, this);
		}
        out.print("var ");
		if (node.list != null)
		{
			node.list.evaluate(cx, this);
		}
        out.println(";");
		return null;
	}

	public Value evaluate(Context cx, WhileStatementNode node)
	{
        indent();
        out.print("while (");
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
        out.println(")");
        indent();
        out.println("{");
        indent++;
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
        indent--;
        indent();
        out.println("}");
		return null;
	}

	public Value evaluate(Context cx, WithStatementNode node)
	{
        indent();
        out.print("with (");
		if (node.expr != null)
		{
			node.expr.evaluate(cx, this);
		}
        out.println(")");
        indent();
        out.println("{");
        indent++;
		if (node.statement != null)
		{
			node.statement.evaluate(cx, this);
		}
        indent--;
        indent();
        out.println("}");
		return null;
	}

    private void indent()
    {
        if (indent < 0)
		{
			assert(false);
		}
        for (int i = 0; i < indent; i++)
        {
            out.print("    ");
        }
    }

    private void op(int op)
    {
        switch (op)
        {
        case NOTEQUALS_TOKEN:
            {
                out.print(" != ");
                break;
            }
        case STRICTNOTEQUALS_TOKEN:
            {
                out.print(" !== ");
                break;
            }
        case LESSTHAN_TOKEN:
            {
                out.print(" < ");
                break;
            }
        case LESSTHANOREQUALS_TOKEN:
            {
                out.print(" <= ");
                break;
            }
        case EQUALS_TOKEN:
            {
                out.print(" == ");
                break;
            }
        case STRICTEQUALS_TOKEN:
            {
                out.print(" === ");
                break;
            }
        case GREATERTHAN_TOKEN:
            {
                out.print(" > ");
                break;
            }
        case GREATERTHANOREQUALS_TOKEN:
            {
                out.print(" >= ");
                break;
            }
        case MULTASSIGN_TOKEN:
            {
                out.print(" *= ");
                break;
            }
        case MULT_TOKEN:
            {
                out.print(" * ");
                break;
            }
        case DIVASSIGN_TOKEN:
            {
                out.print(" /= ");
                break;
            }
        case DIV_TOKEN:
            {
                out.print(" / ");
                break;
            }
        case MODULUSASSIGN_TOKEN:
            {
                out.print(" %= ");
                break;
            }
        case MODULUS_TOKEN :
            {
                out.print(" % ");
                break;
            }
        case PLUSASSIGN_TOKEN:
            {
                out.print(" += ");
                break;
            }
        case PLUS_TOKEN :
            {
                out.print(" + ");
                break;
            }
        case MINUSASSIGN_TOKEN:
            {
                out.print(" -= ");
                break;
            }
        case MINUS_TOKEN :
            {
                out.print(" - ");
                break;
            }
        case LEFTSHIFTASSIGN_TOKEN:
            {
                out.print(" <<= ");
                break;
            }
        case LEFTSHIFT_TOKEN :
            {
                out.print(" << ");
                break;
            }
        case RIGHTSHIFTASSIGN_TOKEN:
            {
                out.print(" >>= ");
                break;
            }
        case RIGHTSHIFT_TOKEN :
            {
                out.print(" >> ");
                break;
            }
        case UNSIGNEDRIGHTSHIFTASSIGN_TOKEN:
            {
                out.print(" >>>= ");
                break;
            }
        case UNSIGNEDRIGHTSHIFT_TOKEN :
            {
                out.print(" >>> ");
                break;
            }
        case BITWISEANDASSIGN_TOKEN:
            {
                out.print(" &= ");
                break;
            }
        case BITWISEAND_TOKEN :
            {
                out.print(" & ");
                break;
            }
        case BITWISEXORASSIGN_TOKEN:
            {
                out.print(" |= ");
                break;
            }
        case BITWISEXOR_TOKEN :
            {
                out.print(" ^ ");
                break;
            }
        case BITWISEORASSIGN_TOKEN:
            {
                out.print(" ^= ");
                break;
            }
        case BITWISEOR_TOKEN :
            {
                out.print(" | ");
                break;
            }
        case LOGICALANDASSIGN_TOKEN:
            {
                out.print(" &&= ");
                break;
            }
        case LOGICALAND_TOKEN :
            {
                out.print(" && ");
                break;
            }
        case LOGICALXORASSIGN_TOKEN:
            {
                out.print(" ^^= ");
                break;
            }
        case LOGICALXOR_TOKEN :
            {
                out.print(" ^^ ");
                break;
            }
        case LOGICALORASSIGN_TOKEN:
            {
                out.print(" ||= ");
                break;
            }
        case LOGICALOR_TOKEN:
            {
                out.print(" || ");
                break;
            }
        default:
            {
                assert false : "Unhandled operation, " + op + ".";
            }
        }
    }
}
