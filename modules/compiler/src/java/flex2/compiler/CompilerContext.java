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

package flex2.compiler;

import java.util.HashMap;
import java.util.Map;
import macromedia.asc.util.Context;

/**
 * This class provides a mechanism for passing objects from one
 * subsystem to another and for reusing objects in multiple phases.
 * Each CompilationUnit is paired with it's own CompilerContext.  This
 * class also facilitates passing around and reusing ASC's context.
 *
 * @author Clement Wong
 * @author Cathy Murphy
 * @see flex2.compiler.CompilationUnit
 * @see macromedia.asc.util.Context
 */
public final class CompilerContext
{
	public static final String BINDING_EXPRESSIONS = "BindingExpressions";
	public static final String RENAMED_VARIABLE_MAP = "RenamedVariableMap";
	public static final String CSS_ARCHIVE_FILES = "CSSArchiveFiles";
	public static final String L10N_ARCHIVE_FILES = "L10NArchiveFiles";

	public CompilerContext()
	{
		attributes = new HashMap<String, Object>();
	}

	private Map<String, Object> attributes;
    private Context ascContext;

    public Context getAscContext()
    {
        return ascContext;
    }

    public Context removeAscContext()
    {
        Context result = ascContext;
        ascContext = null;
        return result;
    }

    public void setAscContext(Context ascContext)
    {
        this.ascContext = ascContext;
    }

	// C: check to see if some of this usage can be replaced by removeAttribute.
	public Object getAttribute(String name)
	{
		return attributes.get(name);
	}

	public void setAttribute(String name, Object value)
	{
		attributes.put(name, value);
	}

	public Object removeAttribute(String name)
	{
		return attributes.remove(name);
	}

	public void clear()
	{
		attributes.clear();
        ascContext = null;
	}

	public void setAttributes(CompilerContext context)
	{
		attributes.putAll(context.attributes);
        ascContext = context.ascContext;
	}
}
