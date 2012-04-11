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

package flex2.compiler.mxml.dom;

/**
 * Defines the API for DOM analyzers.
 *
 * @author Clement Wong
 */
public interface Analyzer
{
	void analyze(CDATANode node);

	void analyze(StyleNode node);

	void analyze(ScriptNode node);

	void analyze(MetaDataNode node);

	void analyze(ModelNode node);

	void analyze(XMLNode node);
    
    void analyze(XMLListNode node);

	void analyze(ArrayNode node);

	void analyze(VectorNode node);

	void analyze(BindingNode node);

	void analyze(StringNode node);

	void analyze(NumberNode node);

    void analyze(IntNode node);

    void analyze(UIntNode node);

    void analyze(BooleanNode node);

	void analyze(ClassNode node);

	void analyze(FunctionNode node);

	void analyze(WebServiceNode node);

	void analyze(HTTPServiceNode node);

	void analyze(RemoteObjectNode node);

	void analyze(OperationNode node);

	void analyze(RequestNode node);

	void analyze(MethodNode node);

	void analyze(ArgumentsNode node);

	void analyze(InlineComponentNode node);

	void analyze(DeclarationsNode node);

	void analyze(LibraryNode node);

	void analyze(DefinitionNode node);
	
	void analyze(ReparentNode node);
	
	void analyze(PrivateNode node);

	void analyze(StateNode node);
	
	void analyze(DesignLayerNode node);

	void analyze(Node node);
	
	void analyze(LayeredNode node);

	void prepare(Node node);
}

