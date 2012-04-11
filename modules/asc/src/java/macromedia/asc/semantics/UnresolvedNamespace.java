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

package macromedia.asc.semantics;

import macromedia.asc.parser.Node;
import macromedia.asc.util.Context;

/**
 * @author Clement Wong
 */
public class UnresolvedNamespace extends NamespaceValue
{
	public UnresolvedNamespace(Context cx, Node node, ReferenceValue ref)
	{
		super();
		this.node = node;
		this.ref = ref;
		resolved = false;
        this.cx = cx.makeCopyOf();  // must make a copy of the current context, the actual context will have
                                    //  its guts swapped out when we go into or out of an included file.
	}

	public Node node;
	public ReferenceValue ref;
	public boolean resolved;
    public Context cx;              // We must report errors relative to this context.  node could come from an included file.
}
