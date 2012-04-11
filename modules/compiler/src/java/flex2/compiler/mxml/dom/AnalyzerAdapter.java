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

package flex2.compiler.mxml.dom;

import flex2.compiler.CompilationUnit;
import flex2.compiler.mxml.Attribute;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.Collection;
import java.util.Iterator;

/**
 * A default analyzer adapter, which calls traverse() for most Nodes
 * and provides a number of convenient logging methods.
 *
 * @author Clement Wong
 */
public abstract class AnalyzerAdapter implements Analyzer
{
	public AnalyzerAdapter(CompilationUnit unit, MxmlConfiguration mxmlConfiguration)
	{
		this.unit = unit;
		this.standardDefs = unit.getStandardDefs();
		this.mxmlConfiguration = mxmlConfiguration;
	}

	protected CompilationUnit unit;
	protected StandardDefs standardDefs;
	protected MxmlConfiguration mxmlConfiguration;
	private Node currentNode;

	public void prepare(Node node)
	{
		currentNode = node;
	}

	public void analyze(CDATANode node)
	{
		traverse(node);
	}

	public void analyze(StyleNode node)
	{
		traverse(node);
	}

	public void analyze(ScriptNode node)
	{
		traverse(node);
	}

	public void analyze(MetaDataNode node)
	{
		traverse(node);
	}

	public void analyze(ModelNode node)
	{
		traverse(node);
	}

	public void analyze(XMLNode node)
	{
		traverse(node);
	}
    
    public void analyze(XMLListNode node)
    {
        traverse(node);
    }

	public void analyze(ArrayNode node)
	{
		traverse(node);
	}

	public void analyze(VectorNode node)
	{
		traverse(node);
	}

	public void analyze(BindingNode node)
	{
		traverse(node);
	}

	public void analyze(StringNode node)
	{
		traverse(node);
	}

	public void analyze(NumberNode node)
	{
		traverse(node);
	}

    public void analyze(IntNode node)
    {
        traverse(node);
    }

    public void analyze(UIntNode node)
    {
        traverse(node);
    }

    public void analyze(BooleanNode node)
	{
		traverse(node);
	}

	public void analyze(ClassNode node)
	{
		traverse(node);
	}

	public void analyze(FunctionNode node)
	{
		traverse(node);
	}

	public void analyze(WebServiceNode node)
	{
		traverse(node);
	}

	public void analyze(HTTPServiceNode node)
	{
		traverse(node);
	}

	public void analyze(RemoteObjectNode node)
	{
		traverse(node);
	}

	public void analyze(OperationNode node)
	{
		traverse(node);
	}

	public void analyze(RequestNode node)
	{
		traverse(node);
	}

	public void analyze(MethodNode node)
	{
		traverse(node);
	}

	public void analyze(ArgumentsNode node)
	{
		traverse(node);
	}

 	public void analyze(InlineComponentNode node)
 	{
 		traverse(node);
 	}

 	public void analyze(DeclarationsNode node)
 	{
 		traverse(node);
 	}

	public void analyze(LibraryNode node)
	{
		traverse(node);
	}

	public void analyze(DefinitionNode node)
	{
		traverse(node);
	}
	
	public void analyze(ReparentNode node)
    {
        traverse(node);
    }
	
	public void analyze(StateNode node)
    {
        traverse(node);
    }
	
	public void analyze(PrivateNode node)
    {
    }

	public void analyze(DesignLayerNode node)
	{
		traverse(node);
	}

	public void analyze(Node node)
	{
		traverse(node);
	}
	
	public void analyze(LayeredNode node)
	{
		traverse(node);
	}

	protected void traverse(Node node)
	{
		for (int i = 0, count = node.getChildCount(); i < count; i++)
		{
			Node n = (Node) node.getChildAt(i);
			n.analyze(this);
		}
	}


	protected int getLineNumber()
	{
		return currentNode.beginLine;
	}

	protected void logInfo(String message)
	{
		logInfo(currentNode, message);
	}

	protected void log(CompilerMessage msg)
	{
		log(currentNode, msg);
	}

	protected void logInfo(int line, String message)
	{
		logInfo(currentNode, line, message);
	}

	protected void log(int line, CompilerMessage msg)
	{
		log(currentNode, line, msg);
	}

	protected void logDebug(String message)
	{
		logDebug(currentNode, message);
	}

	protected void logDebug(int line, String message)
	{
		logDebug(currentNode, line, message);
	}

	protected void logWarning(String message)
	{
		logWarning(currentNode, message);
	}

	protected void logWarning(int line, String message)
	{
		logWarning(currentNode, line, message);
	}

	protected void logError(String message)
	{
		logError(currentNode, message);
	}

	protected void logError(int line, String message)
	{
		logError(currentNode, line, message);
	}

	protected void logInfo(Node node, String message)
	{
		ThreadLocalToolkit.logInfo(unit.getSource().getNameForReporting(), node.beginLine, message);
	}

	protected void log(Node node, CompilerMessage msg)
	{
		msg.path = unit.getSource().getNameForReporting();
		msg.line = node.beginLine;
		ThreadLocalToolkit.log(msg);
	}

	protected void logInfo(Node node, int line, String message)
	{
		ThreadLocalToolkit.logInfo(unit.getSource().getNameForReporting(), (line == 0) ? node.beginLine : line, message);
	}

	protected void log(Node node, int line, CompilerMessage msg)
	{
		msg.path = unit.getSource().getNameForReporting();
		msg.line = (line == 0) ? node.beginLine : line;
		ThreadLocalToolkit.log(msg);
	}

	protected void logDebug(Node node, String message)
	{
		ThreadLocalToolkit.logDebug(unit.getSource().getNameForReporting(), node.beginLine, message);
	}

	protected void logDebug(Node node, int line, String message)
	{
		ThreadLocalToolkit.logDebug(unit.getSource().getNameForReporting(), (line == 0) ? node.beginLine : line, message);
	}

	protected void logWarning(Node node, String message)
	{
		ThreadLocalToolkit.logWarning(unit.getSource().getNameForReporting(), node.beginLine, message);
	}

	protected void logWarning(Node node, int line, String message)
	{
		ThreadLocalToolkit.logWarning(unit.getSource().getNameForReporting(), (line == 0) ? node.beginLine : line, message);
	}

	protected void logError(Node node, String message)
	{
		ThreadLocalToolkit.logError(unit.getSource().getNameForReporting(), node.beginLine, message);
	}

	protected void logError(Node node, int line, String message)
	{
		ThreadLocalToolkit.logError(unit.getSource().getNameForReporting(), (line == 0) ? node.beginLine : line, message);
	}

	protected String getLocalizedMessage(CompilerMessage msg)
	{
		return ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(msg);
	}

	/**
	 * If a node's content is text, return the single CDATANode containing it.
	 * If nodes contains something other than a single CDATANode, return null.
	 * If allowNonText is false and nodes contains non-CDATA nodes, raise an
	 * error.
	 * If the node's content is mixed, we generate an error if the document
	 * version is before 4 (such as Flex 3 documents, or earlier) as mixed
	 * content was not allowed. In Flex 4 this rule changed to allow for
	 * advanced text DOM construction for components making use of the Flash
	 * Text Engine introduced in Flash Player 10.
	 */
	protected CDATANode getTextContent(Collection nodes, boolean allowNonText)
	{
		if (!nodes.isEmpty())
		{
			Iterator iter = nodes.iterator();
			Node first = (Node)iter.next();

			if (first instanceof CDATANode)
			{
				if (!iter.hasNext())
				{
					return (CDATANode)first;
				}
				// Mixed content is not allowed before version 4
				else if (getDocumentVersion() < 4)
				{
					Node second = (Node)iter.next();
					assert !(second instanceof CDATANode) : "internal error: multiple CDATA children";

					log(second, new MixedContentNotAllowed());
				}
			}
			else if (!allowNonText)
			{
				log(first.beginLine, new ChildElementsNotAllowed());
			}
		}

		return null;
	}

    /**
     * The documentation version implies which language rules are in effect
     * during compilation. Implementations of this interface should report
     * the document version to ensure the correct rules are enforced. 
     * 
     * @return int the document version
     */
    protected abstract int getDocumentVersion();

    /**
     * The namespace representing the language for a document.
     * 
     * @return String the language namespace.
     */
    protected abstract String getLanguageNamespace();

    /**
     * Searches for a language attribute on a given node. Language attributes
     * are typically unqualified as special cases. However, from Flex 4 onwards,
     * language attributes may be also qualified in the language namespace.
     * 
     * @param node The node to search for attributes.
     * @param name The name of the language attribute to search for.
     * @return Attribute if found, otherwise null.
     */
    protected Attribute getLanguageAttribute(Node node, String name)
    {
        Attribute attr = node.getAttribute(QName.DEFAULT_NAMESPACE, name);

        if (attr == null && getDocumentVersion() >= 4)
            attr = node.getAttribute(getLanguageNamespace(), name);

        return attr;
    }

    /**
     * Returns the value of a language attribute if present on a given node.
     * Language attributes are typically unqualified as special cases. However,
     * from Flex 4 onwards, language attributes may be also qualified in the
     * language namespace.
     * 
     * @param node The node to search for attributes.
     * @param name The name of the language attribute to search for.
     * @return the attribute value, if found, otherwise null.
     */
    protected Object getLanguageAttributeValue(Node node, String name)
    {
        Object value = node.getAttributeValue(QName.DEFAULT_NAMESPACE, name);

        if (value == null && getDocumentVersion() >= 4)
            value = node.getAttributeValue(getLanguageNamespace(), name);

        return value;
    }

	// error messages

	public static class CouldNotResolveToComponent extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -849410820122435032L;

        public CouldNotResolveToComponent(String tag)
		{
			super();
			this.tag = tag;
		}

		public final String tag;
	}

	public static class MixedContentNotAllowed extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 4808210126110444180L;

        public MixedContentNotAllowed()
		{
			super();
		}
	}

	public static class ChildElementsNotAllowed extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -6601075371133291487L;

        public ChildElementsNotAllowed()
		{
			super();
		}
	}
}
