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

package flex2.compiler.mxml.gen;

import flash.util.StringUtils;
import flex2.compiler.mxml.SourceCodeBuffer;
import flex2.compiler.util.DualModeLineNumberMap;
import flex2.compiler.util.VelocityManager;

/**
 * This class augments the generic utils with:
 * - debug flag taken from config
 * - template path
 */
public class VelocityUtil extends VelocityManager.Util
{
	private final String path;
	private final boolean debug;
	private final SourceCodeBuffer sourceCodeBuffer;
	private final DualModeLineNumberMap lineNumberMap;

	public VelocityUtil(String path, boolean debug, SourceCodeBuffer sourceCodeBuffer, DualModeLineNumberMap lineNumberMap)
	{
		this.path = path;
		this.debug = debug;
		this.sourceCodeBuffer = sourceCodeBuffer;
		this.lineNumberMap = lineNumberMap;
	}

	/**
	 * $util.templatePath returns the path of the currently executing template
	 */
	public final String getTemplatePath()
	{
		return path;
	}

	/**
	 * $util.debug returns true if config has debug turned on
	 */
	public final boolean getDebug()
	{
		return debug;
	}

	/**
	 *
	 */
	public final boolean getLineMappingEnabled()
	{
		return lineNumberMap != null && sourceCodeBuffer != null;
	}

    public final void mapLines(int origLine, String text)
    {
        mapLines(origLine, text, false);
    }

    public final void mapCompileErrorLines(int origLine, String text)
    {
        mapLines(origLine, text, true);
    }

    /**
	 * @param compileOnly true iff mapping should *not* be encoded into bytecode
	 */
	public final void mapLines(int origLine, String text, boolean compileOnly)
	{
		if (getLineMappingEnabled() && origLine > 0)
			lineNumberMap.put(origLine, sourceCodeBuffer.getLineNumber(), StringUtils.countLines(text) + 1, compileOnly);
	}
}
