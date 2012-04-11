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

package flash.tools.debugger.expression;

import java.io.IOException;
import java.io.Reader;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import macromedia.asc.embedding.CompilerHandler;
import macromedia.asc.parser.Parser;
import macromedia.asc.parser.ProgramNode;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import flash.localization.LocalizationManager;
import flash.tools.debugger.DebuggerLocalizer;

/**
 * ASTBuilder.java
 * 
 *    This class creates an abstract syntax tree representation
 *    of an expression given a sequence of tokens.
 * 
 *    The tree is built by calling the ActionScript compiler and
 *    having it parse the expression, then converting the result
 *    to a form we prefer.
 *
 *    No compression is performed on the tree, thus expressions
 *    such as (3*4) will result in 3 nodes.
 * 
 */
public class ASTBuilder implements IASTBuilder
{
	private static LocalizationManager s_localizationManager;

	/**
	 * whether the fdb indirection operators are allowed, e.g. asterisk (*x) or
	 * trailing dot (x.)
	 */
	private boolean m_isIndirectionOperatorAllowed = true;

	static
	{
        // set up for localizing messages
        s_localizationManager = new LocalizationManager();
        s_localizationManager.addLocalizer( new DebuggerLocalizer("flash.tools.debugger.expression.expression.") ); //$NON-NLS-1$
	}

	/**
	 * @param isIndirectionOperatorAllowed
	 *            whether the fdb indirection operators are allowed, e.g.
	 *            asterisk (*x) or trailing dot (x.)
	 */
	public ASTBuilder(boolean isIndirectionOperatorAllowed)
	{
		m_isIndirectionOperatorAllowed = isIndirectionOperatorAllowed;
	}

	/**
	 * @return whether the fdb indirection operators are allowed, e.g. asterisk
	 *         (*x) or trailing dot (x.)
	 */
	public boolean isIndirectionOperatorAllowed()
	{
		return m_isIndirectionOperatorAllowed;
	}

	private static class ErrorInfo
	{
		public String filename;
		public int ln;
		public int col;
		public String msg;
		public String source;
	}

	/*
	 * @see flash.tools.debugger.expression.IASTBuilder#parse(java.io.Reader)
	 */
	public ValueExp parse(Reader in) throws IOException, ParseException
	{
		DebuggerExpression retval = new DebuggerExpression();

		StringBuilder sb = new StringBuilder();
		int ch;
		while ( (ch=in.read()) != -1 )
			sb.append((char)ch);

		String s = sb.toString();

		// FB-16879: If expression begins with "#N" where N is a number,
		// replace that with "$obj(N)".  For example, "#3" would become
		// "$obj(3)".  Later, in PlayerSession.callFunction(), we will
		// detect the $obj() function and handle it.
		s = s.replaceFirst("^#([0-9]+)", "\\$obj($1)"); //$NON-NLS-1$ //$NON-NLS-2$

		if (isIndirectionOperatorAllowed()) {
			if (s.endsWith(".")) { //$NON-NLS-1$
				retval.setLookupMembers(true);
				s = s.substring(0, s.length() - 1);
			} else if (s.startsWith("*")) { //$NON-NLS-1$
				retval.setLookupMembers(true);
				s = s.substring(1);
			}
		}

		// Enclose the expression in parentheses, in order to ensure that the
		// parser considers it to be an expression.  For example, "{x:3}" would
		// be considered to be a block with label "x" and value "3", but,
		// "({x:3})" is considered to be an inline object with field "x" that
		// has value 3.
		s = "(" + s + ")"; //$NON-NLS-1$ //$NON-NLS-2$

		ContextStatics statics = new ContextStatics();
		Context cx = new Context(statics);
		final List<ErrorInfo> errors = new ArrayList<ErrorInfo>();
		CompilerHandler newHandler = new CompilerHandler() {
			public void error(final String filename, int ln, int col, String msg, String source) {
				ErrorInfo ei = new ErrorInfo();
				ei.filename = filename;
				ei.ln = ln;
				ei.col = col;
				ei.msg = msg;
				ei.source = source;
				errors.add(ei);
			}
		};
		cx.setHandler(newHandler);
		cx.scriptAssistParsing = true;
		Parser parser = new Parser(cx, s, "Expression"); //$NON-NLS-1$
		ProgramNode programNode = parser.parseProgram();

		if (errors.size() > 0) {
			ErrorInfo firstError = errors.get(0);
			throw new ParseException(firstError.msg, firstError.col);
		}

		retval.setProgramNode(programNode);
		retval.setContext(cx);
		return retval;
	}

	static LocalizationManager getLocalizationManager()
	{
		return s_localizationManager;
	}
}
