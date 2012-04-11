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

package flex2.compiler.mxml.builder;

import flex2.compiler.CompilationUnit;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.CDATANode;
import flex2.compiler.mxml.dom.ModelNode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.AnonymousObjectGraph;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;

/*
 * TODO haven't converted the text value parsing here. CDATANode.inCDATA is being ignored; don't know if there are other issues.
 */
/**
 * This builder supports building a AnonymousObjectGraph from a
 * ModelNode and it's children.
 *
 * @author Clement Wong
 */
class ModelBuilder extends AnonymousObjectGraphBuilder
{
	private Model parent;

	ModelBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document, Model parent)
	{
		super(unit, typeTable, mxmlConfiguration, document);
		this.parent = parent;
		setAllowTwoWayBind(true);
	}

    public void analyze(ModelNode node)
	{
        String classObjectProxy = NameFormatter.toDot(standardDefs.CLASS_OBJECTPROXY);
        document.addImport(classObjectProxy, node.beginLine);
		Type bindingClass = typeTable.getType(standardDefs.CLASS_OBJECTPROXY);
		if (bindingClass == null)
		{
			log(node, new ClassNotFound(classObjectProxy));
		}

		graph = new AnonymousObjectGraph(document, bindingClass, node.beginLine);

		registerModel(node, graph, parent == null);

		if (node.getChildCount() == 1 && node.getChildAt(0) instanceof CDATANode)
		{
			CDATANode cdata = (CDATANode) node.getChildAt(0);
			if (cdata.image.length() > 0)
			{
			    BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);
			    if (be != null)
			    {
                    /**
                     * <mx:Model>{binding_expression}</mx:Model>
                     * or
                     * <mx:Model>@{binding_expression}</mx:Model>
                     */
                    be.setDestination(graph);
                    be.setDestinationObjectProxy(true);
			    }
                else
                {
                    /**
                     * <mx:Model>some string</mx:Model>
                     */
                    log(cdata, new OnlyScalarError((String)getLanguageAttributeValue(node, StandardDefs.PROP_ID)));
                }
			}
		}
		else if (node.getChildCount() == 1)
		{
			/**
			 * <mx:Model>
			 * <com>
			 *     <foo>...</foo>
			 *     <bar>...</bar>
			 *     ...
			 * </com>
			 * </mx:Model>
			 */
			processChildren((Node) node.getChildAt(0), graph);
		}
		else if (node.getChildCount() > 1)
		{
			log(node, new OnlyOneRootTag());
		}
	}

    public static class ClassNotFound extends CompilerError
    {
        private static final long serialVersionUID = 1805035532862926349L;
        public String className;

        public ClassNotFound(String className)
        {
            this.className = className;
        }
    }

    public static class OnlyScalarError extends CompilerError
    {
        private static final long serialVersionUID = -97448183610558564L;
        public String id;

        public OnlyScalarError(String id)
        {
            this.id = id;
        }
    }
    
	public static class OnlyOneRootTag extends CompilerError
	{
		private static final long serialVersionUID = -8929223631634187913L;

        public OnlyOneRootTag()
		{
			super();
		}
	}
}
