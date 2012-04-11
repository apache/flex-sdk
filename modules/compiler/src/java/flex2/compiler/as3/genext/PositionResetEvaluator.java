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

package flex2.compiler.as3.genext;

import macromedia.asc.parser.Node;
import macromedia.asc.util.Context;
import flash.swf.tools.as3.EvaluatorAdapter;

/**
 * An evaluator used by GenerativeSecondPassEvaluator to reset the
 * postition of a subtree of AST nodes.  This is necessary when moving
 * a subtree from one AST to another.
 */
class PositionResetEvaluator extends EvaluatorAdapter
{
    private int position;

	public PositionResetEvaluator(int position)
	{
        this.position = position;
	}

	public boolean checkFeature(Context cx, Node node)
	{
        node.pos(position);
		return true;
	}
}
