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

import com.adobe.flash.compiler.filespecs.IFileSpecification;
import com.adobe.flash.compiler.internal.tree.as.ExpressionNodeBase;
import com.adobe.flash.compiler.tree.ASTNodeID;
import com.adobe.flash.compiler.tree.as.IASNode;
import com.adobe.flash.compiler.tree.as.IExpressionNode;
import com.adobe.flash.compiler.tree.as.IScopedNode;

/**
 * @author ggv
 * 
 */
public class FoldedExpressionNode extends ExpressionNodeBase implements
		IExpressionNode {

	private final IASNode rootNode;

	/**
	 * 
	 */
	public FoldedExpressionNode(IASNode rootNode) {
		this.rootNode = rootNode;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.common.ISourceLocation#getStart()
	 */
	@Override
	public int getStart() {
		return getUnderLyingNode().getStart();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.common.ISourceLocation#getEnd()
	 */
	@Override
	public int getEnd() {
		return getUnderLyingNode().getEnd();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.common.ISourceLocation#getLine()
	 */
	@Override
	public int getLine() {
		return getUnderLyingNode().getLine();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.common.ISourceLocation#getColumn()
	 */
	@Override
	public int getColumn() {
		return 0;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.common.ISourceLocation#getAbsoluteStart()
	 */
	@Override
	public int getAbsoluteStart() {
		return getUnderLyingNode().getAbsoluteStart();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.common.ISourceLocation#getAbsoluteEnd()
	 */
	@Override
	public int getAbsoluteEnd() {
		return getUnderLyingNode().getAbsoluteEnd();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getNodeID()
	 */
	@Override
	public ASTNodeID getNodeID() {
		return ASTNodeID.FoldedExpressionID;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#contains(int)
	 */
	@Override
	public boolean contains(int offset) {
		return getUnderLyingNode().contains(offset);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.adobe.flash.compiler.tree.as.IASNode#getAncestorOfType(java.lang.
	 * Class)
	 */
	@Override
	public IASNode getAncestorOfType(Class<? extends IASNode> nodeType) {
		return getUnderLyingNode().getAncestorOfType(nodeType);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getChild(int)
	 */
	@Override
	public IASNode getChild(int i) {
		return null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getChildCount()
	 */
	@Override
	public int getChildCount() {
		return 0;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getContainingNode(int)
	 */
	@Override
	public IASNode getContainingNode(int offset) {
		return getUnderLyingNode().getContainingNode(offset);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getContainingScope()
	 */
	@Override
	public IScopedNode getContainingScope() {
		return getUnderLyingNode().getContainingScope();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getPackageName()
	 */
	@Override
	public String getPackageName() {
		return getUnderLyingNode().getPackageName();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getParent()
	 */
	@Override
	public IASNode getParent() {
		return getUnderLyingNode().getParent();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getFileSpecification()
	 */
	@Override
	public IFileSpecification getFileSpecification() {
		return getUnderLyingNode().getFileSpecification();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getSpanningStart()
	 */
	@Override
	public int getSpanningStart() {
		return getUnderLyingNode().getSpanningStart();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#getSucceedingNode(int)
	 */
	@Override
	public IASNode getSucceedingNode(int offset) {
		return getUnderLyingNode().getSucceedingNode(offset);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.tree.as.IASNode#isTerminal()
	 */
	@Override
	public boolean isTerminal() {
		return true;
	}

	/**
	 * @return the rootNode
	 */
	public IASNode getUnderLyingNode() {
		return rootNode;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.adobe.flash.compiler.internal.tree.as.ExpressionNodeBase#copy()
	 */
	@Override
	protected ExpressionNodeBase copy() {
		return null;
	}

}
