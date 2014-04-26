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

import com.adobe.flash.compiler.internal.tree.as.BinaryOperatorLogicalAndAssignmentNode;
import com.adobe.flash.compiler.internal.tree.as.BinaryOperatorLogicalAndNode;
import com.adobe.flash.compiler.internal.tree.as.BinaryOperatorLogicalOrAssignmentNode;
import com.adobe.flash.compiler.internal.tree.as.BinaryOperatorLogicalOrNode;
import com.adobe.flash.compiler.internal.tree.as.ExpressionNodeBase;
import com.adobe.flash.compiler.tree.as.IASNode;
import com.adobe.flash.compiler.tree.as.IExpressionNode;

/**
 * The logical operator's right hand operands are folded into
 * FoldedExperessionNode, so that they are not evaluated by the burm.
 * 
 * This is required for shortcircuit evaluation
 * 
 * @author ggv
 * 
 */
public class LogicalOperatorsFolder implements IASTFolder {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * flash.tools.debugger.expression.IASTFolder#fold(com.adobe.flash.compiler
	 * .tree.as.IASNode)
	 */
	@Override
	public IASNode fold(IASNode rootNode) {
		foldLazyRHSOperandsForLogicalOperators(rootNode);
		return rootNode;
	}

	/**
	 * @param node
	 */
	private void foldLazyRHSOperandsForLogicalOperators(IASNode node) {

		if (node instanceof BinaryOperatorLogicalAndNode
				|| node instanceof BinaryOperatorLogicalAndAssignmentNode) {

			BinaryOperatorLogicalAndNode opNode = ((BinaryOperatorLogicalAndNode) node);
			opNode.setRightOperandNode(fold(opNode.getRightOperandNode()));
			foldLazyRHSOperandsForLogicalOperators(opNode.getLeftOperandNode());

		} else if (node instanceof BinaryOperatorLogicalOrNode
				|| node instanceof BinaryOperatorLogicalOrAssignmentNode) {

			BinaryOperatorLogicalOrNode opNode = ((BinaryOperatorLogicalOrNode) node);
			opNode.setRightOperandNode(fold(opNode.getRightOperandNode()));
			foldLazyRHSOperandsForLogicalOperators(opNode.getLeftOperandNode());

		} else {
			int chCount = node.getChildCount();
			for (int i = 0; i < chCount; i++) {
				IASNode childNode = node.getChild(i);
				foldLazyRHSOperandsForLogicalOperators(childNode);
			}
		}
	}

	/**
	 * @param rightOperandNode
	 * @return
	 */
	private ExpressionNodeBase fold(IExpressionNode rightOperandNode) {
		return new FoldedExpressionNode(rightOperandNode);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * flash.tools.debugger.expression.IASTFolder#unfoldOneLevel(flash.tools
	 * .debugger.expression.FoldedExpressionNode)
	 */
	@Override
	public IASNode unfoldOneLevel(FoldedExpressionNode foldedExpressionNode) {
		IASNode node = foldedExpressionNode.getUnderLyingNode();
		fold(node);
		return node;
	}

}
