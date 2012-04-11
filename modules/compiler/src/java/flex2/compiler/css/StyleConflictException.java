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

package flex2.compiler.css;

import flex2.compiler.util.CompilerMessage;
import flex2.compiler.Source;

/**
 * Error used to report when the same style is defined in two places
 * with conflicting "inheriting" values.  Until the Flex framework
 * supports scoped styling, a style can't be inheriting and
 * non-inheriting in the same application.
 *
 * @author Paul Reilly
 */
public class StyleConflictException extends CompilerMessage.CompilerError
{
	private static final long serialVersionUID = -8399014354067794602L;
    public String style;
	public String source;

	public StyleConflictException(String style, Source source)
	{
		this.style = style;
		this.source = source != null ? source.getNameForReporting() : "";
	}

}
