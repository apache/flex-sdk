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

import java.util.HashSet;
import java.util.Set;

import flex2.compiler.util.QName;

/**
 * Represents a &lt;Private&gt; tag in the FXG or MXML 2009 language
 * namespace.
 * 
 * A container for design-time private data, which is not available at
 * runtime.
 * 
 * @author dloverin
 */
public class PrivateNode extends Node
{
    public static final Set<QName> attributes;

    static
    {
        attributes = new HashSet<QName>();
    }
    
	PrivateNode(String uri, String localName, int size)
	{
		super(uri, localName, size);
	}

	
	public void analyze(Analyzer analyzer) {
		analyzer.prepare(this);
		analyzer.analyze(this);
	}

}
