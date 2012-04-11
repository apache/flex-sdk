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

package flex2.compiler.mxml.analyzer;

import flex2.compiler.CompilationUnit;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.AnalyzerAdapter;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.dom.OperationNode;
import flex2.compiler.mxml.dom.RequestNode;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.CompilerMessage;

/**
 * This analyzer is used to check that WebService tags have Request
 * child tags with no attributes or only a "format" attribute and
 * Operation child tags with a "name" attribute.
 *
 * @author Clement Wong
 */
public class WebServiceAnalyzer extends AnalyzerAdapter
{
    private MxmlDocument document;

	public WebServiceAnalyzer(CompilationUnit unit, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
	{
		super(unit, mxmlConfiguration);
		this.document = document;
	}

	public void analyze(OperationNode node)
	{
		if (node.getAttributeValue("name") == null)
		{
			log(node, new OperationRequiresName());
		}
		super.analyze(node);
	}

    public void analyze(RequestNode node)
    {
		int attrCount = node.getAttributeCount();
		if (attrCount > 1 ||
            (attrCount == 1 && !((node.getAttributeNames().next())).getLocalPart().equals("format")))
        {
	        log(node, new RequestRequiresFormat());
        }
        super.analyze(node);
    }

    public void analyze(Node node)
    {
        super.analyze(node);
    }

    protected int getDocumentVersion()
    {
        return document.getVersion();
    }

    protected String getLanguageNamespace()
    {
        return document.getLanguageNamespace();
    }

	// error messages

	public static class OperationRequiresName extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -2365576843611189649L;

        public OperationRequiresName()
		{
			super();
		}
	}

	public static class RequestRequiresFormat extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 2836590913630566556L;

        public RequestRequiresFormat()
		{
			super();
		}
	}
}
