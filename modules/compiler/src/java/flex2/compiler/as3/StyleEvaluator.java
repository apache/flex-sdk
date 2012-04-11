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

package flex2.compiler.as3;

import flex2.compiler.CompilationUnit;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.css.StyleConflictException;
import flex2.compiler.as3.reflect.MetaData;
import flex2.compiler.as3.reflect.NodeMagic;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.swf.tools.as3.EvaluatorAdapter;
import flash.util.Trace;

/**
 * This class handles processing [Style] metadata.
 *
 * @author Paul Reilly
 */
class StyleEvaluator extends EvaluatorAdapter
{
	private CompilationUnit unit;

	StyleEvaluator(CompilationUnit unit)
	{
		this.unit = unit;
	}

	public Value evaluate(Context context, MetaDataNode node)
	{
		if ("Style".equals(node.getId()))
		{
			if (NodeMagic.isClassDefinition(node))
			{
				processStyle(context, node);
			}
			else
			{
				context.localizedError2(node.pos(), new StyleMustAnnotateAClass());
			}
		}

		return null;
	}

    private void processStyle(Context context, MetaDataNode metaDataNode)
    {
        MetaData metaData = new MetaData(metaDataNode);
        String styleName = metaData.getValue("name");
	    String typeName = metaData.getValue("type");

        if (styleName == null)
        {
            // preilly: we should report this earlier in the process.
	        context.localizedError2(metaDataNode.pos(), new StyleHasMissingName());
        }

	    if (typeName != null)
	    {
		    unit.expressions.add(NameFormatter.toMultiName(typeName));
	    }

		registerStyle(context, metaDataNode, styleName, metaData);
    }

	/**
	 * add style into unit-wide list
	 */
	private void registerStyle(Context context, MetaDataNode metaDataNode, String name, MetaData md)
	{
		try
		{
			unit.styles.addStyle(name, md, unit.getSource());
		}
		catch (StyleConflictException e)
		{
			context.localizedWarning2(metaDataNode.pos(), e);

			if (Trace.error)
				e.printStackTrace();
		}

	}

	// error messages

	public static class StyleMustAnnotateAClass extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 3387534813786226571L;

        public StyleMustAnnotateAClass()
		{
			super();
		}
	}

	public static class StyleHasMissingName extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -1027238030094127129L;

        public StyleHasMissingName()
		{
			super();
		}
	}
}
