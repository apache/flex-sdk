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
import flex2.compiler.mxml.dom.ArgumentsNode;
import flex2.compiler.mxml.dom.MethodNode;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.CompilerMessage;

/**
 * This analyzer is used to check that RemoteObject tags have
 * Arguments child tags without attributes and Method child tags with
 * a "name" attribute.
 *
 * @author Clement Wong
 */
public class RemoteObjectAnalyzer extends AnalyzerAdapter
{
    private MxmlDocument document;

    public RemoteObjectAnalyzer(CompilationUnit unit, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
    {
        super(unit, mxmlConfiguration);
        this.document = document;
	}

	public void analyze(MethodNode node)
	{
		if (node.getAttributeValue("name") == null)
		{
			log(node, new MethodRequiresName());
		}
		super.analyze(node);
	}

    public void analyze(ArgumentsNode node)
    {
        if (node.getAttributeCount() > 0)
        {
	        log(node, new ArgumentsNoAttributes());
        }
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

	public static class MethodRequiresName extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -1993485855814744142L;

        public MethodRequiresName()
		{
			super();
		}
	}

	public static class ArgumentsNoAttributes extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -1790969989441708094L;

        public ArgumentsNoAttributes()
		{
			super();
		}
	}
}
