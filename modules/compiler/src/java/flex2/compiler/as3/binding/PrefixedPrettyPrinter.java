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

import java.io.PrintWriter;
import macromedia.asc.parser.CallExpressionNode;
import macromedia.asc.parser.GetExpressionNode;
import macromedia.asc.parser.SelectorNode;
import macromedia.asc.parser.SetExpressionNode;
import macromedia.asc.parser.ThisExpressionNode;
import macromedia.asc.semantics.ReferenceValue;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.swf.tools.as3.PrettyPrinter;

/**
 * This utility class is used to recreate the AS3 source code for
 * Array elements and Function args when creating generating the code
 * for runtime Watchers.  It's only used by
 * EvaluationWatcher.getEvaluationPart().
 *
 * @author Paul Reilly
 * @see flex2.compiler.as3.binding.EvaluationWatcher
 */
public class PrefixedPrettyPrinter extends PrettyPrinter
{
    private String prefix;

    public PrefixedPrettyPrinter(String prefix, PrintWriter out)
    {
        super(out);
        this.prefix = prefix;
    }

    public Value evaluate(Context cx, CallExpressionNode node)
    {
        if (!node.is_new)
        {
            out.print(prefix + ".");
        }

        super.evaluate(cx, node);

        return null;
    }

	public Value evaluate(Context cx, GetExpressionNode node)
	{
        if ((node.base == null) && !isStatic(cx, node))
        {
            out.print(prefix + ".");
        }

        super.evaluate(cx, node);

		return null;
	}

	public Value evaluate(Context cx, SetExpressionNode node)
	{
        if ((node.base == null) && !isStatic(cx, node))
        {
            out.print(prefix + ".");
        }

        super.evaluate(cx, node);

		return null;
	}

    private boolean isStatic(Context cx, SelectorNode node)
    {
        boolean result = false;
        ReferenceValue ref = node.ref;

        if (ref != null)
        {
            if (ref.getType(cx).getName().toString().equals("Class") &&
                (ref.slot != null) && (ref.slot.getObjectValue() != null))
            {
                result = true;
            }
        }

        return result;
    }

	public Value evaluate(Context cx, ThisExpressionNode node)
    {
        out.print(prefix);
        return null;
    }
}
