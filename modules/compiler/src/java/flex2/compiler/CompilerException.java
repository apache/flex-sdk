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

/**
 * This class provides a common base class for all exceptions thrown
 * by the compiler.  It can be used in catch statements, but it
 * shouldn't be constructed directly.  A subclass of CompilerMessage
 * should be used when reporting an error or warning.
 * @see flex2.compiler.util.CompilerMessage
 */
public class CompilerException extends Exception
{
    private static final long serialVersionUID = 1587688606009074835L;

    public CompilerException()
    {
    }

	public CompilerException(String message)
	{
		super(message);
	}

    public CompilerException(String message, Throwable cause)
    {
        super(message, cause);
    }

    public CompilerException(Throwable cause)
    {
        super(cause);
    }
}
