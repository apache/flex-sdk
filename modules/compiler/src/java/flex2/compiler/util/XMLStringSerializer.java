/*
 * Copyright 2001-2004 The Apache Software Foundation.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package flex2.compiler.util;

import java.io.Writer;
import java.io.IOException;
import java.io.Serializable;
import java.util.Stack;
import java.util.HashMap;
import java.util.ArrayList;

import org.xml.sax.Attributes;

/**
 * Layer of abstraction for serialzing XML objects into a string
 * suitable for construction of an ActionScript XML object.  Taken in
 * pieces from SerializationContentImpl in Apache Axis.
 */
public class XMLStringSerializer
{
	private Writer writer;
	private boolean writingStartTag = false;
	private boolean noNamespaceMappings = true;
	private Stack<String> elementStack = new Stack<String>();
	private NSStack nsStack = null;
	private int lastPrefixIndex = 1;
	private UTF8Encoder encoder;

	public static final String NS_PREFIX_SOAP_ENV   = "soapenv";
    public static final String NS_PREFIX_SOAP_ENC   = "soapenc";
    public static final String NS_PREFIX_SCHEMA_XSI = "xsi" ;
    public static final String NS_PREFIX_SCHEMA_XSD = "xsd" ;
    public static final String NS_PREFIX_WSDL       = "wsdl" ;
    public static final String NS_PREFIX_WSDL_SOAP  = "wsdlsoap";
    public static final String NS_PREFIX_XMLSOAP    = "apachesoap";
    public static final String NS_PREFIX_XML        = "xml";
	public static final String NS_URI_XML = "http://www.w3.org/XML/1998/namespace";
	public static final String NS_URI_XMLNS = "http://www.w3.org/2000/xmlns/";
    public static final String URI_SOAP11_ENC = "http://schemas.xmlsoap.org/soap/encoding/" ;
    public static final String URI_1999_SCHEMA_XSD = "http://www.w3.org/1999/XMLSchema";
    public static final String URI_1999_SCHEMA_XSI = "http://www.w3.org/1999/XMLSchema-instance";
    public static final String URI_2000_SCHEMA_XSD = "http://www.w3.org/2000/10/XMLSchema";
    public static final String URI_2000_SCHEMA_XSI = "http://www.w3.org/2000/10/XMLSchema-instance";
    public static final String URI_2001_SCHEMA_XSD = "http://www.w3.org/2001/XMLSchema";
    public static final String URI_2001_SCHEMA_XSI = "http://www.w3.org/2001/XMLSchema-instance";
    public static final String XSI_TYPE_ATTR_NAME = "type";

    public static final String URI_SOAP11_ENV = "http://schemas.xmlsoap.org/soap/envelope/" ;
	/**
	 * A list of particular namespace -> prefix mappings we should prefer.
	 * See getPrefixForURI() below.
	 */
	HashMap<String, String> preferredPrefixes = new HashMap<String, String>();
	
	public XMLStringSerializer(Writer writer)
	{
		this.writer = writer;
		initialize();
	}

	private void initialize() {
	    // These are the preferred prefixes we'll use instead of the "ns1"
	    // style defaults.  MAKE SURE soapConstants IS SET CORRECTLY FIRST!
	    preferredPrefixes.put(URI_SOAP11_ENC, NS_PREFIX_SOAP_ENC);
	    preferredPrefixes.put(NS_URI_XML, NS_PREFIX_XML);
	    preferredPrefixes.put(URI_1999_SCHEMA_XSD, NS_PREFIX_SCHEMA_XSD);
	    preferredPrefixes.put(URI_1999_SCHEMA_XSI, NS_PREFIX_SCHEMA_XSI);
	    preferredPrefixes.put(URI_2000_SCHEMA_XSD, NS_PREFIX_SCHEMA_XSD);
	    preferredPrefixes.put(URI_2000_SCHEMA_XSI, NS_PREFIX_SCHEMA_XSI);
	    preferredPrefixes.put(URI_2001_SCHEMA_XSD, NS_PREFIX_SCHEMA_XSD);
	    preferredPrefixes.put(URI_2001_SCHEMA_XSI, NS_PREFIX_SCHEMA_XSI);
	    preferredPrefixes.put(URI_SOAP11_ENV, NS_PREFIX_SOAP_ENV);

	    nsStack = new NSStack(false);
	}

	/**
	 * Get a prefix for a namespace URI.  This method will ALWAYS
	 * return a valid prefix - if the given URI is already mapped in this
	 * serialization, we return the previous prefix.  If it is not mapped,
	 * we will add a new mapping and return a generated prefix of the form
	 * "ns<num>".
	 * @param uri is the namespace uri
	 * @return prefix
	 */
	public String getPrefixForURI(String uri)
	{
		return getPrefixForURI(uri, null, false);
	}

	/**
	 * Get a prefix for the given namespace URI.  If one has already been
	 * defined in this serialization, use that.  Otherwise, map the passed
	 * default prefix to the URI, and return that.  If a null default prefix
	 * is passed, use one of the form "ns<num>"
	 */
	public String getPrefixForURI(String uri, String defaultPrefix)
	{
		return getPrefixForURI(uri, defaultPrefix, false);
	}

	/**
	 * Get a prefix for the given namespace URI.  If one has already been
	 * defined in this serialization, use that.  Otherwise, map the passed
	 * default prefix to the URI, and return that.  If a null default prefix
	 * is passed, use one of the form "ns<num>"
	 */
	public String getPrefixForURI(String uri, String defaultPrefix, boolean attribute)
	{
		if ((uri == null) || (uri.length() == 0))
		    return null;

		// If we're looking for an attribute prefix, we shouldn't use the
		// "" prefix, but always register/find one.
		String prefix = nsStack.getPrefix(uri, attribute);

		if (prefix == null) {
		    prefix = preferredPrefixes.get(uri);

		    if (prefix == null) {
		        if (defaultPrefix == null) {
		            prefix = "ns" + lastPrefixIndex++;
		            while(nsStack.getNamespaceURI(prefix)!=null) {
		                prefix = "ns" + lastPrefixIndex++;
		            }
		        } else {
		            prefix = defaultPrefix;
		        }
		    }

		    registerPrefixForURI(prefix, uri);
		}

		return prefix;
	}


	/**
	 * Register prefix for the indicated uri
	 * @param prefix
	 * @param uri is the namespace uri
	 */
	public void registerPrefixForURI(String prefix, String uri)
	{
		if ((uri != null) && (prefix != null)) {
		    if (noNamespaceMappings) {
		        nsStack.push();
		        noNamespaceMappings = false;
		    }
		    String activePrefix = nsStack.getPrefix(uri,true);
		    if(activePrefix == null || !activePrefix.equals(prefix)) {
		        nsStack.add(uri, prefix);
		    }
		}
	}

	/**
	 * Writes (using the Writer) the start tag for element QName along with the
	 * indicated attributes and namespace mappings.
	 * @param qName is the name of the element
	 * @param attributes are the attributes to write
	 */
	public void startElement(QName qName, Attributes attributes) throws IOException
	{
		java.util.ArrayList<String> vecQNames = null;

		if (writingStartTag) {
		    writer.write('>');
		}

		String elementQName = qName2String(qName, true);
		writer.write('<');

		writer.write(elementQName);

		if (attributes != null) {
		    for (int i = 0; i < attributes.getLength(); i++) {
		        String qname = attributes.getQName(i);
		        writer.write(' ');

		        String prefix = "";
		        String uri = attributes.getURI(i);
		        if (uri != null && uri.length() > 0) {
		            if (qname.length() == 0) {
		                // If qname isn't set, generate one
		                prefix = getPrefixForURI(uri);
		            } else {
		                // If it is, make sure the prefix looks reasonable.
		                int idx = qname.indexOf(':');
		                if (idx > -1) {
		                    prefix = qname.substring(0, idx);
		                    prefix = getPrefixForURI(uri,
		                                             prefix, true);
		                }
		            }
		            if (prefix.length() > 0) {
		                qname = prefix + ':' + attributes.getLocalName(i);
		            } else {
		                qname = attributes.getLocalName(i);
		            }
		        } else {
		           qname = attributes.getQName(i);
		            if(qname.length() == 0)
		                qname = attributes.getLocalName(i);
		        }

		        if (qname.startsWith("xmlns")) {
		          if (vecQNames == null) vecQNames = new ArrayList<String>();
		          vecQNames.add(qname);
		        }
		        writer.write(qname);
		        writer.write("=\"");

		        getEncoder().writeEncoded(writer, attributes.getValue(i));

		        writer.write('"');
		    }
		}

		if (noNamespaceMappings) {
		    nsStack.push();
		} else {
		    for (Mapping map=nsStack.topOfFrame(); map!=null; map=nsStack.next()) {
		        if (!(map.getNamespaceURI().equals(NS_URI_XMLNS) && map.getPrefix().equals("xmlns")) &&
		            !(map.getNamespaceURI().equals(NS_URI_XML) && map.getPrefix().equals("xml")))
		        {
		            StringBuilder sb = new StringBuilder("xmlns");
		            if (map.getPrefix().length() > 0) {
		                sb.append(':');
		                sb.append(map.getPrefix());
		            }
		            if ((vecQNames==null) || (vecQNames.indexOf(sb.toString())==-1)) {
		                writer.write(' ');
		                sb.append("=\"");
		                sb.append(map.getNamespaceURI());
		                sb.append('"');
		                writer.write(sb.toString());
		            }
		        }
		    }

		    noNamespaceMappings = true;
		}

		writingStartTag = true;

		elementStack.push(elementQName);
	}

	public UTF8Encoder getEncoder() {
		if(encoder == null) {
	        encoder = new UTF8Encoder();
		}
		return encoder;
	}

	/**
	 * Convenience operation to write out (to Writer) the String
	 * @param string is the String to write.
	 */
	public void writeString(String string)
		throws IOException
	{
		if (writingStartTag) {
		    writer.write('>');
		    writingStartTag = false;
		}
		writer.write(string);
	}

	/**
	 * Writes the end element tag for the open element.
	 **/
	public void endElement()
		throws IOException
	{
		String elementQName = elementStack.pop();

		nsStack.pop();

		if (writingStartTag) {
		    writer.write("/>");
		    writingStartTag = false;
		    return;
		}

		writer.write("</");
		writer.write(elementQName);
		writer.write('>');
	}

	public static String getLastLocalPart(String localPart) {
		int anonymousDelimitorIndex = localPart.lastIndexOf('>');
		if (anonymousDelimitorIndex > -1 && anonymousDelimitorIndex < localPart.length()-1) {
		    localPart = localPart.substring(anonymousDelimitorIndex + 1);
		}
		return localPart;

	}

	/**
	 * Convert QName to a string of the form <prefix>:<localpart>
	 * @param qName
	 * @return prefixed qname representation for serialization.
	 */
	public String qName2String(QName qName, boolean writeNS)
	{
		String prefix = null;
		String namespaceURI = qName.getNamespace();
		String localPart = qName.getLocalPart();

		if(localPart != null && localPart.length() > 0) {
		    int index = localPart.indexOf(':');
		    if(index!=-1){
		        prefix = localPart.substring(0,index);
		        if(prefix.length()>0 && !prefix.equals("urn")){
		            registerPrefixForURI(prefix, namespaceURI);
		            localPart = localPart.substring(index+1);
		        } else {
		            prefix = null;
		        }
		    }
		    localPart = getLastLocalPart(localPart);
		}

		if (namespaceURI.length() == 0) {
		    if (writeNS) {
		        // If this is unqualified (i.e. prefix ""), set the default
		        // namespace to ""
		        String defaultNS = nsStack.getNamespaceURI("");
		        if (defaultNS != null && defaultNS.length() > 0) {
		            registerPrefixForURI("", "");
		        }
		    }
		} else {
		    prefix = getPrefixForURI(namespaceURI, qName.getPreferredPrefix());
		}

		if ((prefix == null) || (prefix.length() == 0))
		   return localPart;

		return prefix + ':' + localPart;
	}
}

class UTF8Encoder {

    protected static final String AMP = "&amp;";
    protected static final String QUOTE = "&quot;";
    protected static final String LESS = "&lt;";
    protected static final String GREATER = "&gt;";
    protected static final String LF = "\n";
    protected static final String CR = "\r";
    protected static final String TAB = "\t";
    /**
     * gets the encoding supported by this encoder
     *
     * @return string
     */
    public String getEncoding() {
        return "UTF-8";
    }

    /**
     * write the encoded version of a given string
     *
     * @param writer    writer to write this string to
     * @param xmlString string to be encoded
     */
    public void writeEncoded(Writer writer, String xmlString)
            throws IOException {
        if (xmlString == null) {
            return;
        }
        int length = xmlString.length();
        char character;
        for (int i = 0; i < length; i++) {
            character = xmlString.charAt( i );
            switch (character) {
                // we don't care about single quotes since axis will
                // use double quotes anyway
                case '&':
                    writer.write(AMP);
                    break;
                case '"':
                    writer.write(QUOTE);
                    break;
                case '<':
                    writer.write(LESS);
                    break;
                case '>':
                    writer.write(GREATER);
                    break;
                case '\n':
                    writer.write(LF);
                    break;
                case '\r':
                    writer.write(CR);
                    break;
                case '\t':
                    writer.write(TAB);
                    break;
                default:
                    if (character < 0x20) {
	                    String errString = ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString("flex2.compiler.util.XMLStringSerializer.IllegalXMLChar");
	                    errString += ": " + Integer.toHexString(character);
                        throw new IllegalArgumentException(errString);
                    } else if (character > 0x7F) {
                        writer.write("&#x");
                        writer.write(Integer.toHexString(character).toUpperCase());
                        writer.write(";");
                    } else {
                        writer.write(character);
                    }
                    break;
            }
        }
    }
}

/**
 * The abstraction this class provides is a push down stack of variable
 * length frames of prefix to namespace mappings.  Used for keeping track
 * of what namespaces are active at any given point as an XML document is
 * traversed or produced.
 *
 * From a performance point of view, this data will both be modified frequently
 * (at a minimum, there will be one push and pop per XML element processed),
 * and scanned frequently (many of the "good" mappings will be at the bottom
 * of the stack).  The one saving grace is that the expected maximum
 * cardinalities of the number of frames and the number of total mappings
 * is only in the dozens, representing the nesting depth of an XML document
 * and the number of active namespaces at any point in the processing.
 *
 * Accordingly, this stack is implemented as a single array, will null
 * values used to indicate frame boundaries.
 *
 * @author James Snell
 * @author Glen Daniels (gdaniels@apache.org)
 * @author Sam Ruby (rubys@us.ibm.com)
 */
class NSStack {

    private Mapping[] stack;
    private int top = 0;
    private int iterator = 0;
    private int currentDefaultNS = -1;
    private boolean optimizePrefixes = true;

    public NSStack(boolean optimizePrefixes) {
        this.optimizePrefixes = optimizePrefixes;
        stack = new Mapping[32];
        stack[0] = null;
    }

    public NSStack() {
        stack = new Mapping[32];
        stack[0] = null;
    }

    /**
     * Create a new frame at the top of the stack.
     */
    public void push() {
        top ++;

        if (top >= stack.length) {
           Mapping newstack[] = new Mapping[stack.length*2];
           System.arraycopy (stack, 0, newstack, 0, stack.length);
           stack = newstack;
        }

        stack[top] = null;
    }

    /**
     * Remove the top frame from the stack.
     */
    public void pop() {
        clearFrame();

        top--;

        // If we've moved below the current default NS, figure out the new
        // default (if any)
        if (top < currentDefaultNS) {
            // Reset the currentDefaultNS to ignore the frame just removed.
            currentDefaultNS = top;
            while (currentDefaultNS > 0) {
                if (stack[currentDefaultNS] != null &&
                        stack[currentDefaultNS].getPrefix().length() == 0)
                    break;
                currentDefaultNS--;
            }
        }
    }

    /**
     * Return a copy of the current frame.  Returns null if none are present.
     */
    public ArrayList<Mapping> cloneFrame() {
        if (stack[top] == null) return null;

        ArrayList<Mapping> clone = new ArrayList<Mapping>();

        for (Mapping map=topOfFrame(); map!=null; map=next()) {
            clone.add(map);
        }

        return clone;
    }

    /**
     * Remove all mappings from the current frame.
     */
    private void clearFrame() {
        while (stack[top] != null) top--;
    }

    /**
     * Reset the embedded iterator in this class to the top of the current
     * (i.e., last) frame.  Note that this is not threadsafe, nor does it
     * provide multiple iterators, so don't use this recursively.  Nor
     * should you modify the stack while iterating over it.
     */
    public Mapping topOfFrame() {
        iterator = top;
        while (stack[iterator] != null) iterator--;
        iterator++;
        return next();
    }

    /**
     * Return the next namespace mapping in the top frame.
     */
    public Mapping next() {
        if (iterator > top) {
            return null;
        } else {
            return stack[iterator++];
        }
    }

    /**
     * Add a mapping for a namespaceURI to the specified prefix to the top
     * frame in the stack.  If the prefix is already mapped in that frame,
     * remap it to the (possibly different) namespaceURI.
     */
    public void add(String namespaceURI, String prefix) {
        int idx = top;
        prefix = prefix.intern();
        try {
            // Replace duplicate prefixes (last wins - this could also fault)
            for (int cursor=top; stack[cursor]!=null; cursor--) {
                if (stack[cursor].getPrefix() == prefix) {
                    stack[cursor].setNamespaceURI(namespaceURI);
                    idx = cursor;
                    return;
                }
            }

            push();
            stack[top] = new Mapping(namespaceURI, prefix);
            idx = top;
        } finally {
            // If this is the default namespace, note the new in-scope
            // default is here.
            if (prefix.length() == 0) {
                currentDefaultNS = idx;
            }
        }
    }

    /**
     * Return an active prefix for the given namespaceURI.  NOTE : This
     * may return null even if the namespaceURI was actually mapped further
     * up the stack IF the prefix which was used has been repeated further
     * down the stack.  I.e.:
     *
     * <pre:outer xmlns:pre="namespace">
     *   <pre:inner xmlns:pre="otherNamespace">
     *      *here's where we're looking*
     *   </pre:inner>
     * </pre:outer>
     *
     * If we look for a prefix for "namespace" at the indicated spot, we won't
     * find one because "pre" is actually mapped to "otherNamespace"
     */
    public String getPrefix(String namespaceURI, boolean noDefault) {
        if ((namespaceURI == null) || (namespaceURI.length()==0))
            return null;

        if(optimizePrefixes) {
            // If defaults are OK, and the given NS is the current default,
            // return "" as the prefix to favor defaults where possible.
            if (!noDefault && currentDefaultNS > 0 && stack[currentDefaultNS] != null &&
                    namespaceURI == stack[currentDefaultNS].getNamespaceURI())
                return "";
        }
        namespaceURI = namespaceURI.intern();

        for (int cursor=top; cursor>0; cursor--) {
            Mapping map = stack[cursor];
            if (map == null)
                continue;

            if (map.getNamespaceURI() == namespaceURI) {
                String possiblePrefix = map.getPrefix();
                if (noDefault && possiblePrefix.length() == 0)
                    continue;

                // now make sure that this is the first occurance of this
                // particular prefix
                for (int cursor2 = top; true; cursor2--) {
                    if (cursor2 == cursor)
                        return possiblePrefix;
                    map = stack[cursor2];
                    if (map == null)
                        continue;
                    if (possiblePrefix == map.getPrefix())
                        break;
                }
            }
        }

        return null;
    }

    /**
     * Return an active prefix for the given namespaceURI, including
     * the default prefix ("").
     */
    public String getPrefix(String namespaceURI) {
        return getPrefix(namespaceURI, false);
    }

    /**
     * Given a prefix, return the associated namespace (if any).
     */
    public String getNamespaceURI(String prefix) {
        if (prefix == null)
            prefix = "";

        prefix = prefix.intern();

        for (int cursor=top; cursor>0; cursor--) {
            Mapping map = stack[cursor];
            if (map == null) continue;

            if (map.getPrefix() == prefix)
                return map.getNamespaceURI();
        }

        return null;
    }
}

/**
 * this class represents a mapping from namespace to prefix
 */
class Mapping implements Serializable {
    private static final long serialVersionUID = 6518667923789125175L;
    private String namespaceURI;
    private String prefix;

    public Mapping (String namespaceURI, String prefix) {
        setPrefix(prefix);
        setNamespaceURI(namespaceURI);
    }

    public String getNamespaceURI() {
        return namespaceURI;
    }

    public void setNamespaceURI (String namespaceURI) {
        this.namespaceURI = namespaceURI.intern();
    }

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix (String prefix) {
        this.prefix = prefix.intern();
    }
}

