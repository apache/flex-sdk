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
import static macromedia.asc.util.BitSet.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class StatementListNode extends Node
{
	public ObjectList<Node> items = new ObjectList<Node>(5);
	public boolean dominates_program_endpoint;
    public boolean was_empty;
    public boolean is_loop;
    public boolean is_block;
    public boolean has_pragma;
    
    public NumberUsage numberUsage; // use if is_block
    public ObjectValue default_namespace;
    public AttributeListNode config_attrs;

	public StatementListNode(Node item)
	{
		dominates_program_endpoint = false;
        was_empty = false;
        is_loop = false;
        is_block = false;
        has_pragma = false;
        numberUsage = null;
		if( item != null )
		{
            items.add(item);
        }
	}

	public Value evaluate(Context cx, Evaluator evaluator)
	{
		if (evaluator.checkFeature(cx, this))
		{
			return evaluator.evaluate(cx, this);
		}
		else
		{
			return null;
		}
	}

	public Node first()
	{
		//StatementListNode* node = this;
		//while(node->list!=NULL)
		//{
		//    node = node->list;
		//}
		return items.isEmpty() ? null : items.first();
	}

	public int countVars()
	{
		int count = 0;

		for (Node n : items)
		{
			if (n != null)
			{
				count += n.countVars();
			}
		}

		return count;
	}


	public Node last()
	{
		return items.isEmpty() ? null : items.last();
	}

	public BitSet getGenBits()
	{
		BitSet genbits = null;

		for (Node n : items)
		{
			genbits = reset_set(genbits, n.getKillBits(), n.getGenBits());
			// ISSUE: this has changed, test!
		}
		return genbits;
	}

	public BitSet getKillBits()
	{
		BitSet killbits = null;

		for (Node n : items)
		{
			killbits = reset_set(killbits, n.getGenBits(), n.getKillBits());
		}
		return killbits;
	}

	public boolean isStatementList()
	{
		return true;
	}

	public String toString()
	{
		if(Node.useDebugToStrings)
         return "StatementListNode@" + pos();
      else
         return items.last().toString();
	}

    public boolean definesCV()
    {
        for (Node n : items)
        {
            if( n.isExpressionStatement() )
            {
                ExpressionStatementNode expr = (ExpressionStatementNode) n;
                if( !expr.isVarStatement() )
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    public void voidResult()
    {
        for (Node n : items)
        {
            n.voidResult();
        }
        if( items.last() instanceof LoadRegisterNode )
        {
            // voidResult on LoadRegister does nothing, which is usually correct
            // since it appears in the middle of statement lists, and its result is used by the other nodes in the StatementList
            // but when it's the last item in the statement list, and the statement list should be a void result
            // we really want the LoadRegisterNode to have a void result so it won't screw up the stack.
            ((LoadRegisterNode)items.last()).void_result = true;
        }
    }
}
