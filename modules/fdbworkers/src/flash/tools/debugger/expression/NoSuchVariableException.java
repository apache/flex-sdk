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

import java.util.HashMap;
import java.util.Map;

/**
 * Thrown when a variable name cannot be resolved in the current scope
 */
public class NoSuchVariableException extends Exception
{
	private static final long serialVersionUID = -400396588945206074L;

    public NoSuchVariableException(String s)	{ super(s); }
	public NoSuchVariableException(Object o)	{ super(o.toString()); }

	@Override
	public String getLocalizedMessage()
	{
		Map<String, String> args = new HashMap<String, String>();
		args.put("arg2", getMessage() ); //$NON-NLS-1$
		return ASTBuilder.getLocalizationManager().getLocalizedTextString("noSuchVariable", args); //$NON-NLS-1$
	}
}
