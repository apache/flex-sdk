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

package flash.localization;

import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.ext.LexicalHandler;

import javax.xml.parsers.SAXParserFactory;
import javax.xml.parsers.SAXParser;
import java.util.Map;
import java.util.Locale;
import java.util.Stack;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Iterator;
import java.io.File;
import java.io.InputStream;
import java.io.BufferedInputStream;
import java.net.URL;

/**
 * ILocalizer implementation, which supports looking up text in XLR
 * files..
 *
 * @author Roger Gonzalez
 */
public class XLRLocalizer implements ILocalizer
{
    public XLRLocalizer()
    {
        // only resources
    }
    public XLRLocalizer( String path )
    {
        findFiles( new File( path ), null );
    }

    public XLRTargetNode loadNode( Locale fileLocale, String fileId, Locale locale, String id )
    {
        String key = getKey( fileLocale, fileId );
        XLRFile f = filedict.get( key );

        if (f == null)
        {
            String resource = key.replaceAll( "\\.", "/" ) + ".xlr";
            URL url = getClass().getClassLoader().getResource( resource );

            if (url != null)
            {
                f = new XLRFile( fileId, url );
                filedict.put( key, f );
            }
        }
        if (f != null)
        {
            f.load();
            XLRMessageNode messageNode = (XLRMessageNode) nodedict.get( id );
            if (messageNode != null)
            {
                XLRTargetNode targetNode = messageNode.getTarget( locale.toString() );
                return targetNode;
            }
        }

        return null;
    }

    public XLRTargetNode checkPrefix( Locale fileLocale, String fileId, Locale locale, String id )
    {
        XLRTargetNode t = loadNode( fileLocale, fileId, locale, id );
        if (t == null)
        {
            int sep = fileId.lastIndexOf( '$' );

            if (sep == -1)
                sep = fileId.lastIndexOf( '.' );

            if (sep != -1)
                t = checkPrefix( fileLocale, fileId.substring( 0, sep ), locale, id );
        }
        return t;
    }

    public XLRTargetNode checkLocales( Locale locale, String id )
    {
        XLRTargetNode t = checkPrefix( locale, id, locale, id );

        if ((t == null) && (locale.getCountry().length() > 0) && (locale.getVariant().length() > 0))
            t = checkPrefix( new Locale( locale.getLanguage(), locale.getCountry() ), id, locale, id );

        if ((t == null) && (locale.getCountry().length() > 0))
            t = checkPrefix( new Locale( locale.getLanguage() ), id, locale, id );

        if ((t == null))
            t = checkPrefix( null, id, locale, id );

        return t;
    }


    public ILocalizedText getLocalizedText( Locale locale, String id )
    {
        XLRMessageNode messageNode = (XLRMessageNode) nodedict.get( id );
        XLRTargetNode targetNode = null;
        if (messageNode != null)
        {
            targetNode = messageNode.getTarget( locale.toString() );
        }

        if (targetNode == null)
        {
            targetNode = checkLocales( locale, id );
        }

        if (targetNode == null)
        {
            return null;
        }

        return new XLRLocalizedText( targetNode );
    }

    private String getKey( Locale locale, String id )
    {
        String key = id;
        if (locale != null)
        {
            if (locale.getLanguage().length() > 0)
            {
                key += "_" + locale.getLanguage();
                if (locale.getCountry().length() > 0)
                {
                    key += "_" + locale.getCountry();

                    if (locale.getVariant().length() > 0)
                    {
                        key += "_" + locale.getVariant();
                    }
                }
            }
        }
        return key;
    }

    private Map<String, XLRFile> filedict = new HashMap<String, XLRFile>();
    private Map<String, XLRNode> nodedict = new HashMap<String, XLRNode>();

    private class XLRFile
    {
        public XLRFile( String prefix, URL url )
        {
            this.prefix = prefix;
            this.url = url;
        }

        public void load()
        {
            if (loaded)
            {
                return;
            }
            try
            {
                InputStream in = new BufferedInputStream( this.url.openStream() );
                SAXParserFactory factory = SAXParserFactory.newInstance();
                factory.setNamespaceAware( false ); // FIXME

                XLRHandler xmlHandler = new XLRHandler( nodedict, prefix );
                CDATAHandler cdataHandler = new CDATAHandler( xmlHandler );

                SAXParser parser = factory.newSAXParser();
                parser.setProperty("http://xml.org/sax/properties/lexical-handler", cdataHandler);
                parser.parse( in, xmlHandler );
            }
            catch (Exception e)
            {
                e.printStackTrace( );
            }
            loaded = true;
        }

        private boolean loaded = false;
        private final URL url;
        private final String prefix;
    }

    private void findFiles( File f, String relative )
    {
        try
        {
            if (!f.exists())
                return;

            if (f.isDirectory())
            {
                File[] files = f.listFiles();

                for (int i = 0; i < files.length; ++i)
                {
                    findFiles( files[i].getAbsoluteFile(), ((relative == null)? "":(relative + ".")) + files[i].getName() );
                }
            }
            else
            {
                if (!f.getName().endsWith( ".xlr" ))
                    return;
                else
                {
                    String id = relative.substring( 0, relative.length() - ".xlr".length() );

                    String prefix = id;
                    int dot = id.lastIndexOf( '.' );
                    int underscore = -1;
                    if (dot != -1)
                    {
                        underscore = id.indexOf( '_', dot );
                    }
                    else
                    {
                        underscore = id.indexOf( '_' );
                    }
                    if (underscore != -1)
                    {
                        prefix = id.substring( 0, underscore );
                    }

                    filedict.put( id, new XLRFile( prefix, f.toURL() ) );
                }
            }
        }
        catch (Exception e)
        {
            e.printStackTrace( );
        }
    }

    private class XLRLocalizedText implements ILocalizedText
    {
        public XLRLocalizedText( XLRTargetNode node )
        {
            this.node = node;
        }
        public String format( Map parameters )
        {
            StringBuilder buffer = new StringBuilder();
            String s = node.execute( buffer, node.locale, parameters )? buffer.toString() : null;
            if (s != null)
            {
                s = LocalizationManager.replaceInlineReferences( s, parameters );
            }
            return s;
        }
        private XLRTargetNode node;
    }

    private abstract class XLRNode
    {
        public LinkedList<XLRNode> children = new LinkedList<XLRNode>();
        public boolean execute( StringBuilder buffer, String locale, Map parameters )
        {
            boolean success = false;
            for (Iterator<XLRNode> it = children.iterator(); it.hasNext(); )
            {
                XLRNode child = it.next();

                if (child.execute( buffer, locale, parameters ))
                {
                    success = true;
                }
            }
            return success;
        }
    }

    private class XLRChoiceNode extends XLRNode
    {
        public boolean execute( StringBuilder buffer, String locale, Map parameters )
        {
            for (Iterator<XLRNode> it = children.iterator(); it.hasNext(); )
            {
                XLRNode child = it.next();

                if (child.execute( buffer, locale, parameters ))
                {
                    return true;
                }
            }
            return false;
        }
    }

    private class XLRMessageNode extends XLRChoiceNode
    {
        public XLRMessageNode( String id )
        {
            this.id = id;
        }
        public XLRTargetNode getTarget( String locale )
        {
            for (Iterator<XLRNode> it = children.iterator(); it.hasNext();)
            {
                XLRNode node = it.next();

                if ((node instanceof XLRTargetNode) && ((XLRTargetNode) node).matchesLocale( locale ))
                {
                    return (XLRTargetNode) node;
                }
            }
            return null;
        }
        public final String id;
    }

    private class XLRTargetNode extends XLRNode
    {
        public XLRTargetNode( String locale )
        {
            this.locale = locale;
        }
        public boolean matchesLocale( String locale )
        {
            return (((this.locale == null) && (locale == null)) || locale.equalsIgnoreCase( this.locale ));

        }
        public boolean execute( StringBuilder buffer, String locale, Map parameters )
        {
            if (matchesLocale( locale ))
            {
                return super.execute( buffer, locale, parameters );
            }
            return false;
        }
        public final String locale;
    }

    private class XLRTextNode extends XLRNode
    {
        public XLRTextNode( String text )
        {
            this.text = text;
        }
        public boolean execute( StringBuilder buffer, String locale, Map parameters )
        {
            boolean success = false;
            if (text != null)
            {
                success = true;
                buffer.append( text );
            }
            boolean result = super.execute( buffer, locale, parameters );
            return success || result;
        }
        public final String text;
    }

    private class XLRVariableNode extends XLRNode
    {
        public XLRVariableNode( String name )
        {
            this.varname = name;
        }
        public boolean execute( StringBuilder buffer, String locale, Map parameters )
        {
            boolean success = false;
            if (varname != null)
            {
                success = parameters.containsKey( varname ) && (parameters.get( varname ) != null);
                if (success)
                {
                    buffer.append( parameters.get( varname ).toString());
                }
            }
            success |= super.execute( buffer, locale, parameters );
            return success;
        }
        public String varname;
    }

    private class XLRMatchNode extends XLRNode
    {
        public String varname;
        public String text = null;
        public String pattern = null;
        public XLRMatchNode( String varname, String pattern )
        {
            this.varname = varname;
            this.pattern = pattern;
        }
        public boolean execute( StringBuilder buffer, String locale, Map parameters )
        {
            String value = null;

            if ((varname != null) && parameters.containsKey( varname ) && parameters.get( varname ) != null)
            {
                value = parameters.get( varname ).toString();
            }
            if (value == null)
            {
                value = "";
            }
            // match based on the value being non-zero length, non-zero, or not "false" if pattern isn't set

            boolean matched = false;
            if (pattern == null)
            {
                if ((value != null) && (value.length() > 0))
                {
                    matched = !(value.equalsIgnoreCase( "false" ) || value.equals( "0" ));
                }
                else
                {
                    matched = false;    // null string
                }
            }
            else
            {
                // to match an empty string, try pattern of "^$"
                matched = value.matches( pattern );
            }

            if (matched)
            {
                super.execute( buffer, locale, parameters );
                return true;
            }
            else
            {
                return false;
            }
        }
    }

    private class XLRHandler extends DefaultHandler
    {
        public XLRHandler( Map<String, XLRNode> nodedict, String base )
        {
            this.nodedict = nodedict;   // id -> messagenode
            this.base = base;
        }
        public Stack<XLRNode> context = new Stack<XLRNode>();
        private String fileLocale = null;
        private String base = null;
        private Map<String, XLRNode> nodedict;
        StringBuilder textBuffer = new StringBuilder(128);
        protected boolean inCDATA = false;
        public void startElement (String uri, String localName,
                                  String qName, Attributes attributes)
        throws SAXException
        {
            XLRNode current = null;
            if (context.size() > 0)
                current = context.peek();

            // common shortcuts...
            String locale = attributes.getValue( "locale" );
            if (locale == null)
                locale = fileLocale;
            String text = attributes.getValue( "text" );

            XLRNode node = null;
            if ("messages".equals( qName ))
            {
                fileLocale = attributes.getValue( "locale" );
                if (attributes.getValue( "idbase" ) != null)
                    base = attributes.getValue( "idbase" );
            }
            else if ("message".equals( qName ))
            {
                String id = attributes.getValue( "id" );

                if (base != null)
                    id = base + "." + id;

                node = nodedict.get( id );
                if (node == null)
                {
                    node = new XLRMessageNode( id );
                    nodedict.put( id, node );
                }
                if ((text != null) && (locale != null)) // check errors
                {
                    XLRTargetNode targetNode = new XLRTargetNode( locale );
                    node.children.add( targetNode );
                    XLRTextNode textNode = new XLRTextNode( text );
                    targetNode.children.add( textNode );
                }


                context.push( node );
            }
            else if ("target".equals( qName ))
            {
                node = new XLRTargetNode( locale );
                if (text != null)
                    node.children.add( new XLRTextNode( text ));

                current.children.add( node );
                context.push( node );
            }
            else if ("text".equals( qName ))
            {
                String value = attributes.getValue( "value" );

                node = new XLRTextNode( value );

                current.children.add( node );
                context.push( node );
            }
            else if ("variable".equals( qName ))
            {
                String name = attributes.getValue( "name" );

                node = new XLRVariableNode( name );
                current.children.add( node );
                context.push( node );

            }
            else if ("match".equals( qName ))
            {
                node = new XLRMatchNode( attributes.getValue( "variable" ), attributes.getValue( "pattern" ) );
                if (text != null)
                    node.children.add( new XLRTextNode( text ));

                current.children.add( node );
                context.push( node );
            }
            else if ("select".equals( qName ))
            {
                node = new XLRChoiceNode();
                current.children.add( node );
                context.push( node );
            }
            else
            {
                throw new SAXParseException( "blorp", null );  // fixme
            }

        }

        public void endElement (String uri, String localName, String qName)
        throws SAXException
        {
            XLRNode current = null;
            if (context.size() > 0)
                current = context.pop();

            if ("messages".equals( qName ))
            {
                // done
            }
            else if ("text".equals( qName ))
            {
                if (textBuffer.length() > 0)
                {
                    current.children.add( new XLRTextNode( textBuffer.toString() ) );
                }
            }
            else if ("variable".equals( qName ))
            {
                if (textBuffer.length() > 0)
                {
                    ((XLRVariableNode) current).varname = textBuffer.toString();
                }
            }
            textBuffer.setLength( 0 );
        }
        public void characters (char ch[], int start, int length)
        throws SAXException
        {
            if (inCDATA)
            {
                textBuffer.append(ch, start, length);
            }
            else
            {
                String s = new String( ch, start, length ).trim();

                if (s.length() > 0)
                    textBuffer.append( s );
            }

        }


        public void ignorableWhitespace (char ch[], int start, int length)
        throws SAXException
        {
        // no op
        }
        public void warning ( SAXParseException e)
        throws SAXException
        {
        // no op
        }


        public void error (SAXParseException e)
        throws SAXException
        {
        // no op
        }


        public void fatalError (SAXParseException e)
        throws SAXException
        {
        throw e;
        }



    }
    private class CDATAHandler implements LexicalHandler
    {
        private XLRHandler parentHandler;
        public CDATAHandler( XLRHandler h )
        {
            parentHandler = h;
        }
        public void startCDATA() throws SAXException
        {
            parentHandler.inCDATA = true;
        }

        public void endCDATA() throws SAXException
        {
            parentHandler.inCDATA = false;
        }

        public void startDTD(String s, String s1, String s2) throws SAXException
        {
        }

        public void endDTD() throws SAXException
        {
        }

        public void startEntity(String s) throws SAXException
        {
        }

        public void endEntity(String s) throws SAXException
        {
        }

        public void comment(char[] chars, int i, int i1) throws SAXException
        {
        }
    }


}
