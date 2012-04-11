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

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Node
 *
 * @author Dick Sweet
 */


public class UseRoundingNode extends UsePragmaNode {

	public int mode;

	public UseRoundingNode(Node id, Node argument)
	{
		super(id, argument);
		this.mode = NumberUsage.round_HALF_EVEN; // until proven otherwise
		if (argument instanceof IdentifierNode) {
			String arg = ((IdentifierNode)argument).toIdentifierString();
			if (arg.equals("HALF_EVEN")) {
				mode = NumberUsage.round_HALF_EVEN;
			}
			else if (arg.equals("DOWN")) {
				mode = NumberUsage.round_DOWN;
			}
			else if (arg.equals("FLOOR")) {
				mode = NumberUsage.round_FLOOR;
			}
			else if (arg.equals("UP")) {
				mode = NumberUsage.round_UP;
			}
			else if (arg.equals("CEILING")) {
				mode = NumberUsage.round_CEILING;
			}
			else if (arg.equals("HALF_UP")) {
				mode = NumberUsage.round_HALF_UP;
			}
			else if (arg.equals("HALF_DOWN")) {
				mode = NumberUsage.round_HALF_DOWN;
			}
			// should report error if something else
		}
		// should report error if not identifier
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

	public String toString()
	{
		return "UseRounding " + NumberUsage.roundingModeName[mode];
	}
}
