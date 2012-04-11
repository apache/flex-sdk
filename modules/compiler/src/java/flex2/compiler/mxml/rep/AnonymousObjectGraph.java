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

package flex2.compiler.mxml.rep;

import flex2.compiler.mxml.reflect.Type;

/**
 * This class represents a set of name/value pairs defined as Mxml
 * nodes.  For example:
 * <pre>
 * &lt;Object&gt;
 *   &lt;a&gt;b&lt;/a&gt;
 *   &lt;c&gt;d&lt;/c&gt;
 * &lt;/Object&gt;
 * </pre>
 */
public class AnonymousObjectGraph extends Model
{
	public AnonymousObjectGraph(MxmlDocument document, Type objectType, int line)
	{
		super(document, objectType, line);
	}

}
