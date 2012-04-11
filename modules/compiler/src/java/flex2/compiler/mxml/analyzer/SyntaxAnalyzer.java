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

import flash.css.StyleParser;
import flash.css.StyleSheet;
import flash.css.StyleParser.StyleSheetInvalidCharset;
import flash.fonts.FontManager;
import flash.util.FileUtils;
import flex2.compiler.CompilationUnit;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.*;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.mxml.InvalidStateSpecificValue;
import java.io.*;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * This analyzer serves two purposes:
 * a) verify syntax tree, e.g. checking language tag attributes
 * b) register includes and dependencies
 *
 * @author Clement Wong
 */
public class SyntaxAnalyzer extends AnalyzerAdapter
{
    /**
     * The root node of the document for this compilation unit.
     */
    private DocumentNode documentNode;

	public SyntaxAnalyzer(CompilationUnit unit, MxmlConfiguration mxmlConfiguration)
	{
		super(unit, mxmlConfiguration);
	}

	/**
	 * At parse-time, we want to register dependent packages/classes...
	 */
	public void analyze(Node node)
	{
	    if (node instanceof DocumentNode)
	        documentNode = (DocumentNode)node;

		/**
		 * NOTE: since this analyzer runs at parse time, the information that
		 * would allow us to distinguish <mx:SomeComponent/> from
		 * <mx:childPropertyAssignment/> is not yet (guaranteed to be)
		 * available. As a result, both types of nodes will pass through this
		 * method, so we can't yet raise errors when a tag name fails to resolve
		 * to an implementing class.
		 */
		super.analyze(node);
	}

    public void analyze(LayeredNode node)
    {
        analyze((Node) node);
    }
	
	public void analyze(CDATANode node)
	{
		// do nothing
	}
	
	public void analyze(StateNode node)
	{
        String name = (String) node.getAttributeValue("name");

        // Prior to Flex 4, name could be a binding expression.
        if (getDocumentVersion() >= 4 &&
                name != null && TextParser.isBindingExpression(name))
        {
            log(node, node.getLineNumber("name"), new CompileTimeAttributeBindingExpressionUnsupported());
        }

		super.analyze(node);
	}

	public void analyze(StyleNode node)
	{
		checkForExtraAttributes(StyleNode.attributes, node);

		String source = (String) node.getAttributeValue("source");
		CDATANode cdata = (CDATANode) node.getChildAt(0);

		if (source != null && cdata != null)
		{
			log(node, node.getLineNumber("source"), new IgnoreEmbeddedStylesheet());
		}

		if (source != null)
		{
            if (TextParser.isBindingExpression(source))
            {
                log(node, node.getLineNumber("source"), new CompileTimeAttributeBindingExpressionUnsupported());
                return;
            }

			// C: Look at the problem this way, AS3 can have [Embed], MXML can have @embed, CSS can have @embed.
			// AS3 and MXML can "import" each others types. Does it make sense for AS3 or MXML to "import" CSS?
			// Currently, external CSS stylesheets are pulled in and codegen within MXML-generated classes. Can
			// CSS be generated in a separate class/factory and make MXML "import" it?
			//
			// Can CSS embedded within <mx:Style> be generated within the MXML-generated class as an inner class?

			VirtualFile file = unit.getSource().resolve(source);

			if (file == null)
			{
                VirtualFile[] sourcePath = mxmlConfiguration.getSourcePath();

                if (sourcePath != null)
                {
                    for (int i = 0; (i < sourcePath.length) && (file == null); i++)
                    {
                        file = sourcePath[i].resolve(source);
                    }
                }
			}

			if (file == null)
			{
				log(node, node.getLineNumber("source"), new StylesheetNotFound(source));
			}
			else
			{
				unit.getSource().addFileInclude(file);
				cdata = parseExternalFile(node, file);
				if (cdata != null)
				{
					//	parseStyle(node, unit.getSource().getName(), cdata);
					parseStyle(node, file.getName(), file.getLastModified(), cdata);
				}
			}
		}
		else if (cdata != null)
		{
			parseStyle(node, unit.getSource().getName(), unit.getSource().getLastModified(), cdata.beginLine);
		}
	}

	public void analyze(ScriptNode node)
	{
		checkForExtraAttributes(ScriptNode.attributes, node);
		script(node);
	}

	public void analyze(MetaDataNode node)
	{
		checkForExtraAttributes(MetaDataNode.attributes, node);
	}

	public void analyze(ModelNode node)
	{
		checkForExtraAttributes(ModelNode.attributes, node);

		String source = (String) node.getAttributeValue("source");
		int count = node.getChildCount();

		if (source != null && count > 0)
		{
			log(node, node.getLineNumber("source"), new EmptyTagIfSourceSpecified());
		}

		if (source != null)
		{
            if (TextParser.isBindingExpression(source))
            {
                log(node, node.getLineNumber("source"), new CompileTimeAttributeBindingExpressionUnsupported());
                return;
            }

			// parse external XML file...
			VirtualFile f = unit.getSource().resolve(source);
			if (f == null)
			{
				log(node, node.getLineNumber("source"), new ModelNotFound(source));
			}
			else
			{
				unit.getSource().addFileInclude(f);
				Node root = parseExternalXML(node, f);

				// C: 2.0 behavior: don't remove the root tag for <mx:Model>. it should be similar to
				//    <mx:XML> w.r.t. syntactical processing.
				if (root != null)
				{
				    node.setSourceFile(new Node[] {root});
				}

				/* C: 1.x behavior...
				int size = (root == null) ? 0 : root.getChildCount();
				if (size > 0)
				{
					if (size == 1 && root.getChildAt(0) instanceof CDATANode)
					{
						log(node, node.getLineNumber("source"), new ScalarContentOnlyUnsupportedInExternalModel());
					}
					else
					{
						// C: Keep the document structure intact. Add the source-based nodes to ModelNode separately
						// from the children...
						Node[] nodes = new Node[size];
						for (int j = 0; j < size; j++)
						{
							nodes[j] = (Node) root.getChildAt(j);
						}
						node.setSourceFile(nodes);
					}
				}
				*/
			}
		}
	}

	public void analyze(XMLNode node)
	{
		checkForExtraAttributes(XMLNode.attributes, node);

		String source = (String) node.getAttributeValue("source");
		// C: count = 0 or 1 CDATA or multiple child tags
		int count = node.getChildCount();

		if (source != null && count > 0)
		{
			log(node, node.getLineNumber("source"), new IgnoreInlineXML());
		}

		if (source != null)
		{
            if (TextParser.isBindingExpression(source))
            {
                log(node, node.getLineNumber("source"), new CompileTimeAttributeBindingExpressionUnsupported());
                return;
            }

			// parse external XML file...
			VirtualFile f = unit.getSource().resolve(source);
			if (f == null)
			{
				log(node, node.getLineNumber("source"), new XMLNotFound(source));
			}
			else
			{
				unit.getSource().addFileInclude(f);
				Node root = parseExternalXML(node, f);

                if (root != null)
                {
                    node.setSourceFile(new Node[] {root});
                }
			}
		}
	}

    public void analyze(XMLListNode node)
    {
        checkForExtraAttributes(XMLListNode.attributes, node);
    }

	public void analyze(ArrayNode node)
	{
		checkForExtraAttributes(ArrayNode.attributes, node);
		super.analyze(node);
	}

	public void analyze(VectorNode node)
	{
		checkForExtraAttributes(VectorNode.attributes, node);
		super.analyze(node);
	}

	public void analyze(BindingNode node)
	{
		checkForExtraAttributes(BindingNode.attributes, node);

		String source = (String) node.getAttributeValue("source");
		if (source == null || source.trim().length() == 0)
		{
			log(node, new BindingMustHaveSource());
		}

		String destination = (String) node.getAttributeValue("destination");
		if (destination == null || destination.trim().length() == 0)
		{
			log(node, new BindingMustHaveDestination());
		}
		
        // source and destination attributes must be unique (whitespace counts)
		if (source != null && destination != null && source.equals(destination))
		{
            log(node, new BindingMustHaveUniqueSourceDestination());		    
		}
		
        String twoWay = (String) node.getAttributeValue("twoWay");
        if (twoWay != null && TextParser.isBindingExpression(twoWay))
        {
            log(node, node.getLineNumber("twoWay"), new CompileTimeAttributeBindingExpressionUnsupported());
        }		
	}
	
	public void analyze(ReparentNode node)
    {
        checkForExtraAttributes(ReparentNode.attributes, node);

        String target = (String) node.getAttributeValue("target");
        if (target == null || target.trim().length() == 0)
        {
            log(node, new ReparentMustHaveTarget());
        }
        else if (TextParser.isBindingExpression(target))
        {
            log(node, node.getLineNumber("target"), new CompileTimeAttributeBindingExpressionUnsupported());
        }
        
        String includeIn = (String) node.getAttributeValue(StandardDefs.PROP_INCLUDE_STATES);
        String excludeFrom = (String) node.getAttributeValue(StandardDefs.PROP_EXCLUDE_STATES);
        if ((includeIn == null || includeIn.trim().length() == 0) &&
            (excludeFrom == null || excludeFrom.trim().length() == 0))
        {
            log(node, new ReparentMustHaveStates());
        }
    }

    public void analyze(LibraryNode node)
    {
        checkForExtraAttributes(LibraryNode.attributes, node);

        // If present, the Library tag must be the first child of a document
        // (which implies that there can be only one Library tag per
        // document), although an exception to this rule is that a special
        // <mask> element may precede it.
        int i = 0;
        while (i < documentNode.getChildCount())
        {
            Node nextNode = (Node)documentNode.getChildAt(i++);
            if (nextNode.getLocalPart() == StandardDefs.GRAPHICS_MASK)
                continue;

            // If this node is not the particular Library node being analyzed,
            // log an error.
            if (nextNode != node)
            {
                log(node, node.beginLine, new LibraryMustBeFirstChildOfDocumentError());
            }

            break;
        }

        // We call super here to traverse child DefinitionNodes for further
        // validation.
        super.analyze(node);
    }

	public void analyze(DeclarationsNode node)
	{
		checkForExtraAttributes(DeclarationsNode.attributes, node);
		super.analyze(node);
	}

    public void analyze(DefinitionNode node)
    {
        checkForExtraAttributes(DefinitionNode.attributes, node);

        String definitionName = (String) node.getAttributeValue(StandardDefs.GRAPHICS_DEFINITION_NAME);
        if (definitionName == null || definitionName.trim().length() == 0)
        {
            log(node, node.getLineNumber(StandardDefs.GRAPHICS_DEFINITION_NAME), new DefinitionMustHaveNameError());
        }

        if (node.getChildCount() != 1)
        {
            log(node, node.beginLine, new DefinitionMustHaveOneChildError(definitionName));
        }

        super.analyze(node);
    }

    public void analyze(PrivateNode node)
    {
        checkForExtraAttributes(PrivateNode.attributes, node);

        // If present, the Private tag must be the last child of a document
        // (which implies that there can be only one Private tag per
        // document). An exception to this rule is a special mask tag which
        // can appear anywhere in a document.
        int i = documentNode.getChildCount() - 1;
        while (i >= 0)
        {
            Node lastNode = (Node)documentNode.getChildAt(i--);

            if (StandardDefs.GRAPHICS_MASK.equals(lastNode.getLocalPart()))
                continue;

            // If this node is not the particular Private node being analyzed,
            // log an error.
            if (lastNode != node)
            {
                log(node, node.beginLine, new PrivateMustBeLastChildOfDocumentError());
            }

            break;
        }
    }

	public void analyze(StringNode node)
	{
		checkForExtraAttributes(StringNode.attributes, node);
		primitive(node);
	}

	public void analyze(NumberNode node)
	{
		checkForExtraAttributes(NumberNode.attributes, node);
		primitive(node);
	}

    public void analyze(IntNode node)
    {
        checkForExtraAttributes(IntNode.attributes, node);
        primitive(node);
    }

    public void analyze(UIntNode node)
    {
        checkForExtraAttributes(UIntNode.attributes, node);
        primitive(node);
    }

    public void analyze(BooleanNode node)
	{
		checkForExtraAttributes(BooleanNode.attributes, node);
		primitive(node);
	}

	public void analyze(RequestNode node)
	{
		checkForExtraAttributes(RequestNode.attributes, node);
		super.analyze(node);
	}

	public void analyze(ArgumentsNode node)
	{
		checkForExtraAttributes(ArgumentsNode.attributes, node);
		super.analyze(node);
	}

	public void analyze(InlineComponentNode node)
	{
		checkForExtraAttributes(InlineComponentNode.attributes, node);

		if (node.getChildCount() == 0)
		{
			log(node, new InlineComponentMustHaveOneChild());
		}

		super.analyze(node);
	}

    public void analyze(DesignLayerNode node)
    {
        checkForExtraAttributes(DesignLayerNode.attributes, node);
        super.analyze(node);
    }

    protected void traverse(Node node)
    {
        for (int i = 0; i < node.getChildCount(); i++)
        {
            Node child = (Node) node.getChildAt(i);
            child.analyze(this);

            if (child instanceof DesignLayerNode)
            {
                List<Token> designInfoChildren = child.getChildren();

                // Replace the DesignLayerNode with it's children.
                node.replaceNode(i, designInfoChildren);

                // Update 'i' by adding the size of the DesignLayerNode
                // children and subtracting 1 for the DesignLayerNode.
                i += designInfoChildren.size() - 1;
                
                // Here we make sure to take note of any DesignLayer 
                // declarations (those with ids) that aren't directly 
                // associated with layer children. Otherwise we would
                // miss them when later generating our top level
                // declarations.
                if (child.getAttributeValue(StandardDefs.PROP_ID) != null &&
                    designInfoChildren.size() == 0)
                {
                    documentNode.layerDeclarationNodes.add((DesignLayerNode)child);
                }
            }
        }
    }

    protected int getDocumentVersion()
    {
        return documentNode != null ? documentNode.getVersion() : 0;
    }

    protected String getLanguageNamespace()
    {
        return documentNode != null ? documentNode.getLanguageNamespace() : null;
    }

	private void checkForExtraAttributes(Set<QName> validAttributes, Node node)
	{
		for (Iterator<QName> attributes = node.getAttributeNames(); attributes != null && attributes.hasNext();)
		{
			QName qname = attributes.next();
			String namespace = qname.getNamespace();
			String localPart = qname.getLocalPart();
			
			// If this attribute is state-specific we want to only validate against
			// the unqualified attribute identifier.
			Boolean isScoped = TextParser.isScopedName(localPart);
			if (isScoped)
			{
				String[] statefulName = TextParser.analyzeScopedName(localPart);
				qname = (statefulName != null) ? new QName(namespace, statefulName[0]) : qname;
			}

			if (!validAttributes.contains(qname))
			{
				if (localPart.equals(StandardDefs.PROP_INCLUDE_STATES) || localPart.equals(StandardDefs.PROP_EXCLUDE_STATES))
				{
					log(node, node.getLineNumber(qname), new InvalidStateAttributeUsage(node.getLocalPart()));
				}
                else
                {
                    // Prior to Flex 4, qualified attributes were never allowed
                    // so report anything as an unknown attribute.
                    if (getDocumentVersion() < 4)
                    {
                        log(node, node.getLineNumber(qname), new UnknownAttribute(qname, node.image));
                    }
                    else
                    {
                        // In Flex 4 (and later), qualified attributes are
                        // allowed. If they are in the language namespace or
                        // the component node's namespace they must be
                        // understood. Any other namespace is simply ignored
                        // as the attributes may serve as design time metadata 
                        // for tools. However, note that unqualified attributes
                        // must be understood by the compiler.
                        if (namespace == null || namespace.length() == 0
                            || namespace.equals(node.getNamespace())
                            || namespace.equals(documentNode.getLanguageNamespace()))
                        {
                            log(node, node.getLineNumber(qname), new UnknownAttribute(qname, node.image));
                        }
                    }
				}
			}
			else if (isScoped  && !(node instanceof DesignLayerNode) )
			{
				// Language attributes may not be state-specific.
				log(node.getLineNumber(qname), new InvalidStateSpecificValue(qname.getLocalPart()));
			}
		}
	}

	private void script(ScriptNode node)
	{
		String source = (String) node.getAttributeValue("source");
		CDATANode cdata = (CDATANode) node.getChildAt(0);

		if (source != null && cdata != null)
		{
			log(node, node.getLineNumber("source"), new IgnoreInlineScript());
		}

		// C: Again, all source="..." must be registered to unit.includes.

		if (source != null)
		{
            if (TextParser.isBindingExpression(source))
            {
                log(node, node.getLineNumber("source"), new CompileTimeAttributeBindingExpressionUnsupported());
                return;
            }

			VirtualFile f = unit.getSource().resolve(source);
			if (f == null)
			{
				log(node, node.getLineNumber("source"), new ScriptNotFound(source));
			}
			else
			{
				unit.getSource().addFileInclude(f);
				CDATANode n = parseExternalFile(node, f);

				// C: We want to keep the document structure intact and parse the external file up-front. Store
				// the source="..." content in ScriptNode.

				if (n != null)
				{
					cdata = n;
					node.setSourceFile(n);
				}
			}
		}
	}

	private void primitive(PrimitiveNode node)
	{
		String source = (String) node.getAttributeValue("source");
		CDATANode cdata = (CDATANode) node.getChildAt(0);

		if (source != null && cdata != null)
		{
			log(node, node.getLineNumber("source"), new IgnoreEmbeddedString());
		}

		if (source != null)
		{
            if (TextParser.isBindingExpression(source))
            {
                log(node, node.getLineNumber("source"), new CompileTimeAttributeBindingExpressionUnsupported());
                return;
            }

			// parse external plain text...
			VirtualFile f = unit.getSource().resolve(source);
			if (f == null)
			{
				log(node, node.getLineNumber("source"), new PrimitiveFileNotFound(source));
			}
			else
			{
				unit.getSource().addFileInclude(f);
				CDATANode n = parseExternalFile(node, f);

				// C: We want to keep the document structure intact and parse the external file up-front. Store
				// the source="..." content in PrimitiveNode.

				if (n != null)
				{
					cdata = n;
					node.setSourceFile(n);
				}
			}
		}
	}

	private Node parseExternalXML(Node node, VirtualFile f)
	{
		BufferedInputStream in = null;
		Node anonymousObject = null;
		try
		{
			in = new BufferedInputStream(f.getInputStream());
			MxmlScanner s = new MxmlScanner(in, mxmlConfiguration.enableRuntimeDesignLayers());
			Parser p = new Parser(s);
			MxmlVisitor v = new SyntaxTreeBuilder();
			p.setVisitor(v);
			anonymousObject = (Node) p.parseAnonymousObject();
		}
		catch (ScannerError se)
		{
			log(node, new XMLParseProblem1(f.getName(), se.getLineNumber(), se.getReason()));
        }
        catch (ParseException ex)
		{
			log(node, new XMLParseProblem2(f.getName()));
			Token token = ex.currentToken.next;
			logError(node, token.beginLine, ex.getMessage());
		}
		catch (IOException ex)
		{
			log(node, new XMLParseProblem3(f.getName(), ex.getMessage()));
		}
		finally
		{
			if (in != null)
			{
				try
				{
					in.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
		return anonymousObject;
	}

	private CDATANode parseExternalFile(Node node, VirtualFile f)
	{
		BufferedReader reader = null;
		CDATANode cdata = null;
		try
		{
            BufferedInputStream bufferedInputStream = new BufferedInputStream(f.getInputStream());
            String charsetName = null;
            
            // special handling to get the charset for CSS files.
            if (f.getName().toLowerCase().endsWith(".css")) 
            {
                try
                {
                    charsetName = StyleParser.readCSSCharset(bufferedInputStream);
                }
                catch (StyleSheetInvalidCharset e)
                {
                    // add filename to exception and log warning.
                    log(node, new StyleSheetInvalidCharset(f.getName(), e.charsetName));
                    return null;
                }
            }
            String bomCharsetName = FileUtils.consumeBOM(bufferedInputStream, null, true);
            if (charsetName == null) {
                charsetName = bomCharsetName;
            }
			reader = new BufferedReader(new InputStreamReader(bufferedInputStream, 
                                                              charsetName));
			StringWriter buffer = new StringWriter();
			PrintWriter out = new PrintWriter(buffer);
			String str = null;
			while ((str = reader.readLine()) != null)
			{
				out.println(str);
			}
			out.flush();
			cdata = new CDATANode();
			cdata.image = buffer.toString().trim();
		}
		catch (FileNotFoundException ex)
		{
			// f is not null. don't think this will happen.
			log(node, new ExternalFileNotFound(f.getName()));
		}
		catch (IOException ex)
		{
			log(node, new ParseFileProblem(f.getName(), ex.getMessage()));
		}
		finally
		{
			if (reader != null)
			{
				try
				{
					reader.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
		return cdata;
	}

    private void parseStyle(StyleNode node, String stylePath, long lastModified, CDATANode cdata)
	{
		FontManager fontManager = mxmlConfiguration.getFontsConfiguration().getTopLevelManager();

		StyleSheet styleSheet = new StyleSheet();
		styleSheet.checkDeprecation(mxmlConfiguration.showDeprecationWarnings());
		styleSheet.parse(stylePath, new StringReader(cdata.image), ThreadLocalToolkit.getLogger(), fontManager);

		if (styleSheet.errorsExist())
		{
			// Error
			log(node, new StyleSheetParseError(stylePath));
		}

		node.setStyleSheet(styleSheet);
	}

	private void parseStyle(StyleNode node, String enclosingDocumentPath, long lastModified, int startLine)
	{
		FontManager fontManager = mxmlConfiguration.getFontsConfiguration().getTopLevelManager();

		CDATANode cdata = (CDATANode) node.getChildAt(0);
		StyleSheet styleSheet = new StyleSheet();
		styleSheet.checkDeprecation(mxmlConfiguration.showDeprecationWarnings());
		styleSheet.parse(enclosingDocumentPath, startLine, new StringReader(cdata.image), ThreadLocalToolkit.getLogger(), fontManager);
		if (styleSheet.errorsExist())
		{
			// Error
			log(node, new StyleSheetParseError(enclosingDocumentPath));
		}

		node.setStyleSheet(styleSheet);
	}

	// error messages

	public static class IgnoreEmbeddedStylesheet extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = -663088524822264581L;

        public IgnoreEmbeddedStylesheet()
		{
			super();
		}
	}

	public static class CompileTimeAttributeBindingExpressionUnsupported extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -3787694300539037935L;

        public CompileTimeAttributeBindingExpressionUnsupported()
		{
			super();
		}
	}

	public static class StylesheetNotFound extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 6265512596325307132L;

        public StylesheetNotFound(String source)
		{
			super();
			this.source = source;
		}

		public final String source;
	}

	public static class EmptyTagIfSourceSpecified extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = 6683414194026602697L;

        public EmptyTagIfSourceSpecified()
		{
			super();
		}
	}

	public static class ModelNotFound extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 5004903591499990705L;

        public ModelNotFound(String source)
		{
			super();
			this.source = source;
		}

		public final String source;
	}

	public static class ScalarContentOnlyUnsupportedInExternalModel extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 7778134403904275975L;

        public ScalarContentOnlyUnsupportedInExternalModel()
		{
			super();
		}
	}

	public static class IgnoreInlineScript extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = 8940525017916497366L;

        public IgnoreInlineScript()
		{
			super();
		}
	}

	public static class IgnoreInlineXML extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = 4976631970422220456L;

        public IgnoreInlineXML()
		{
			super();
		}
	}

	public static class XMLNotFound extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 632658792662647542L;

        public XMLNotFound(String source)
		{
			super();
			this.source = source;
		}

		public final String source;
	}

	public static class BindingMustHaveSource extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -5367924918244642096L;

        public BindingMustHaveSource()
		{
			super();
		}
	}

	public static class BindingMustHaveDestination extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 2060746809575116784L;

        public BindingMustHaveDestination()
		{
			super();
		}
	}

    public static class BindingMustHaveUniqueSourceDestination extends CompilerError
    {
        private static final long serialVersionUID = -7116545090937761064L;

        public BindingMustHaveUniqueSourceDestination()
        {
            super();
        }
    }
	
	public static class UnknownAttribute extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 6364683156804532037L;
        public UnknownAttribute(QName qname, String tag)
		{
			super();
			this.qname = qname;
			this.tag = tag;
		}

		public final QName qname;
		public final String tag;
	}

	public static class ScriptNotFound extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 1688968001018529008L;

        public ScriptNotFound(String source)
		{
			super();
			this.source = source;
		}

		public final String source;
	}

	public static class IgnoreEmbeddedString extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = -4800647048554425238L;

        public IgnoreEmbeddedString()
		{
			super();
		}
	}

	public static class PrimitiveFileNotFound extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 1097562596712781756L;

        public PrimitiveFileNotFound(String source)
		{
			super();
			this.source = source;
		}

		public final String source;
	}

	public static class XMLParseProblem1 extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 6245404102161978415L;
        public XMLParseProblem1(String name, int line, String reason)
		{
			super();
			this.name = name;
			this.line = line;
			this.reason = reason;
		}

		public final String name;
		public final int line;
		public final String reason;
	}

	public static class XMLParseProblem2 extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -6202816852895893830L;

        public XMLParseProblem2(String name)
		{
			super();
			this.name = name;
		}

		public final String name;
	}

	public static class XMLParseProblem3 extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 8934855322492753302L;
        public XMLParseProblem3(String name, String message)
		{
			super();
			this.name = name;
			this.message = message;
		}

		public final String name;
		public final String message;
	}

	public static class ExternalFileNotFound extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 5308420983986384234L;

        public ExternalFileNotFound(String name)
		{
			super();
			this.name = name;
		}

		public final String name;
	}

	public static class ParseFileProblem extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -2982048188724576242L;
        public ParseFileProblem(String name, String message)
		{
			super();
			this.name = name;
			this.message = message;
		}

		public final String name;
		public final String message;
	}

	public static class StyleSheetParseError extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -7734934094694932051L;

        public StyleSheetParseError(String stylePath)
		{
			super();
			this.stylePath = stylePath;
		}

		public final String stylePath;
	}

    public static class InlineComponentMustHaveOneChild extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -8013015924130843086L;

        public InlineComponentMustHaveOneChild()
		{
			super();
		}
	}

    public static class DefinitionMustHaveNameError extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 2473265116122447983L;

        public DefinitionMustHaveNameError()
        {
            super();
        }
    }

    public static class DefinitionMustHaveOneChildError extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -4954341364049052865L;

        public String name;

        public DefinitionMustHaveOneChildError(String name)
        {
            super();
            this.name = name;
        }
    }

    public static class LibraryMustBeFirstChildOfDocumentError extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -8197039600346556673L;

        public LibraryMustBeFirstChildOfDocumentError()
        {
            super();
        }
    }

    public static class PrivateMustBeLastChildOfDocumentError extends CompilerError
    {
        private static final long serialVersionUID = 2883815035659543585L;

        public PrivateMustBeLastChildOfDocumentError()
        {
            super();
        }
    }

    public static class ReparentMustHaveTarget extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 9187442166720946682L;

        public ReparentMustHaveTarget()
        {
            super();
        }
    }

    public static class ReparentMustHaveStates extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -9048719337863206820L;

        public ReparentMustHaveStates()
        {
            super();
        }
    }
}

