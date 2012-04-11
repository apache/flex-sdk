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
 * Represents a generic tag, which is a child of a &lt;DesignLayer&gt;
 * tag.  The MxmlScanner creates these instead of generic Node
 * instances when inside the scope of a DesignLayer tag.
 *
 * @author Corey Lucier
 */
public class LayeredNode extends Node
{
	LayeredNode(String uri, String localName, int size, DesignLayerNode parent)
	{
		super(uri, localName, size);
		layerParent = parent;
	}
	
	private DesignLayerNode layerParent;
	
	public void setLayerParent(DesignLayerNode node)
	{
		layerParent = node;
	}

	public DesignLayerNode getLayerParent()
	{
		return layerParent;
	}
	
	public void analyze(Analyzer analyzer)
	{
		analyzer.prepare(this);
		analyzer.analyze(this);
	}
}
