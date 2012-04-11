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
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.ArgumentsNode;
import flex2.compiler.mxml.dom.CDATANode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.dom.RequestNode;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.AnonymousObjectGraph;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.MxmlDocument;

/*
 * TODO haven't converted the text value parsing here. CDATANode.inCDATA is being ignored; don't know if there are other issues.
 */
/**
 * This builder supports building a AnonymousObjectGraph from a
 * ArgumentsNode or RequestNode and it's children.
 *
 * @author Matt Chotin
 */
public class ServiceRequestBuilder extends AnonymousObjectGraphBuilder
{
    private String requestName;
    public ServiceRequestBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document, String name)
    {
        super(unit, typeTable, mxmlConfiguration, document);
        setAllowTwoWayBind(false);
        requestName = name;
    }

    public void analyze(ArgumentsNode node)
    {
        processRequest(node);
    }

    public void analyze(RequestNode node)
    {
        processRequest(node);
    }

    public void processRequest(Node node)
	{
		graph = new AnonymousObjectGraph(document, typeTable.objectType, node.beginLine);

		if (node.getChildCount() == 1 && node.getChildAt(0) instanceof CDATANode)
		{
			/**
			 * <requestName>{binding_expression}</requestName>
			 * but not
			 * <requestName>@{binding_expression}</requestName>
			 */
			CDATANode cdata = (CDATANode) node.getChildAt(0);
			if (cdata.image.length() > 0)
			{
                BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);
                if (be != null)
                {
                    if (be.isTwoWayPrimary())
                    {
                        log(cdata, new TwoWayBindingNotAllowed());
                    }
                    else
                    {
                        be.setDestination(graph);
                    }
                }
 				else
				{
					log(cdata, new ModelBuilder.OnlyScalarError(requestName));
				}
			}
		}
		else
		{
			/**
			 * <requestName>
			 *     <foo>...</foo>
			 *     <bar>...</bar>
			 *     ...
			 * </requestName>
			 */
			processChildren(node, graph);
		}
	}
}
