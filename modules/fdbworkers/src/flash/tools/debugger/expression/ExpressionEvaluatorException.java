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

/**
 * An exception raised while evaluating an expression.  This is a bit
 * of a hack -- we need this to extend <code>RuntimeException</code>
 * because the functions in the <code>Evaluator</code> interface don't
 * throw anything, but our <code>DebuggerEvaluator</code> has many
 * places where it needs to bail out.
 * 
 * @author Mike Morearty
 */
public class ExpressionEvaluatorException extends RuntimeException {
	private static final long serialVersionUID = -7005526599250035578L;

	public ExpressionEvaluatorException(String message) {
		super(message);
	}

	public ExpressionEvaluatorException(Throwable cause) {
		super(cause);
	}
}
