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

package flash.tools.debugger.expression;

import com.adobe.flash.compiler.internal.projects.ASCProject;
import com.adobe.flash.compiler.internal.workspaces.Workspace;
import com.adobe.flash.compiler.projects.ICompilerProject;
import com.adobe.flash.compiler.tree.as.IASNode;

/**
 * @author ggv
 * 
 */
public class DebuggerExpressionEvaluator implements IExpressionEvaluator {

	private final ICompilerProject project;
	private final IASTFolder logicalOperatorFolder;

	/**
	 * 
	 */
	public DebuggerExpressionEvaluator() {
		project = new ASCProject(new Workspace(), true);
		logicalOperatorFolder = new LogicalOperatorsFolder();

	}

	/**
	 * @param project2
	 */
	public DebuggerExpressionEvaluator(ICompilerProject project2) {
		logicalOperatorFolder = new LogicalOperatorsFolder();
		this.project = project2;
	}

	@Override
	public DebuggerValue evaluate(Context context, IASNode node)
			throws Exception {

		if (node instanceof FoldedExpressionNode) {
			/*
			 * Unfold the folded node, and if the unfolded subtree has a logical
			 * operator, fold the RHS of that
			 */
			node = logicalOperatorFolder
					.unfoldOneLevel((FoldedExpressionNode) node);
		} else {
			/*
			 * Where ever it finds a logical operator, fold the rhs of that.
			 */
			node = logicalOperatorFolder.fold(node);
		}
		AS3DebuggerBURM burm = new AS3DebuggerBURM();
		burm.reducer = new AS3DebuggerReducer(context, project);

		burm.burm(node, AS3DebuggerBURM.__expression_NT);
		DebuggerValue value = (DebuggerValue) burm.getResult();
		return value;
	}

}
