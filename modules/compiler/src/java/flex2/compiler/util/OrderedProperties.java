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

package flex2.compiler.util;

import java.io.*;
import java.util.*;

/**
 * Properties extension that reads properties in Unicode and uses a
 * Vector to maintain keys in order.
 */
public class OrderedProperties extends Properties implements Serializable
{
    private static final long serialVersionUID = 8588726273721332377L;
    
    // keys ordered
    private Vector<Object> keys = new Vector<Object>();
    protected Map<String, Integer> lines = new HashMap<String, Integer>();

	// uncomment comment_blocks to maintain comment blocks
    // comment blocks hashed on key+value they appear before
    //private Hashtable comment_blocks = new Hashtable();

    // things we skip in certain places
    private static final String whitespace = " \t\n\r\f";

    // things that terminate a key
    private static String terminators;

    // things that terminate a value
    private static final String valterminators = "\n\r\f";

    // things that need to be escaped in a key or value
    //private static final String escapes = "#!=";

    // does nothing
    public OrderedProperties() {
    }

    // does nothing
    public OrderedProperties(OrderedProperties props) {
    Enumeration<Object> k=props.keys();
    String key;
    // suck in all the properties
    while(k.hasMoreElements()) {
        key = (String) k.nextElement();
        put(key, props.getProperty(key));
    }
    }

    public int size() {
        return keys.size();
    }

    public String getProperty(String property) {
        Object o = super.get(property);
        if ((o != null) && (o instanceof String)) {
            return (String) o;
        }
        return null;
    }

    public String getProperty(String property,String defaultval) {
        Object o = super.get(property);
        String val = null;
        if ((o != null) && (o instanceof String)) {
            val = (String) o;
        }
        return val != null ? val : defaultval;
    }

    /**
     * Replace a property in place, not adjusting the 'keys' vector.
     */
    public void replaceProperty(String property, String value) {
        super.put(property, value);
    }

    public Object putProperty(String property, String value) {
        return putProperty(null, property, value);
    }

    public Object setProperty(String property, String value) {
        return putProperty(null, property, value);
    }

    /**
     * Be careful.. comment must be started with # sign.
     */
    public Object putProperty(String comment, String property, String value) {
        Object old = super.put(property, value);
        //if (comment != null) {
        //    comment_blocks.put(property, comment);
        //}
        // if property did not exist, add it to the keys array
        if (old == null) {
            keys.addElement(property);
        }
        return old;
    }

    public Object get(Object property) {
        return super.get(property);
    }

    public Object put(Object key,Object value) {
        Object old = super.put(key,value);
        if (old == null)
            keys.addElement(key);
        return old;
    }

    public Object remove(Object key) {
        Object old = super.remove(key);
        //comment_blocks.remove(key);
        if (old != null)
            keys.removeElement(key);
        return old;
    }

    public Enumeration<Object> keys() {
        return keys.elements();
    }

    public Enumeration<Object> propertyNames() {
        return keys.elements();
    }

    public void clear() {
        if (super.size() > 0)
            super.clear();
        //if (comment_blocks.size() > 0)
        //    comment_blocks.clear();
        keys.setSize(0);
    }

    public boolean contains(Object value) {
        return super.contains(value);
    }

    public boolean containsKey(String key) {
        // Just call super.containsKey since the hashtable and the
        // keys vector are kept in sync.
        return super.containsKey(key);
    }

    /**
     * Get the set of properties that match a specified pattern.
     * The match pattern accepts a single '*' char anywhere in the
     * pattern. If the '*' is placed somewhere in the middle of the
     * pattern, then then the subset will contain properties that startWith
     * everything before the '*' and end with everything after the '*'.
     *
     *
     * Sample property patterns:
     * <table>
     * <tr><td>*.bar<td>   returns the subset of properties that end with '.bar'
     * <tr><td>bar.*<td>   returns the subset of properties that begin with 'bar.'
     * <tr><td>foo*bar<td> returns the subset of properties that begin with 'foo' and end with 'bar'
     * </table>
     *
     * @param propPattern a pattern with 0 or 1 '*' chars.
     * @return the subset of properties that match the specified pattern. Note that changing the
     * properties in the returned subset will not affect this object.
     *
     */
    public Properties getProperties(String propPattern){
        Properties props = new Properties();
        int index = propPattern.indexOf("*");
        if(index == -1){
            String value = getProperty(propPattern);
            if(value != null){
                props.put(propPattern, value);
            }
        }
        else{
            String startsWith = propPattern.substring(0, index);
            String endsWith;
            if(index == propPattern.length()-1){
                endsWith = null;
            }
            else{
                endsWith = propPattern.substring(index+1);
            }

            Enumeration<Object> names = propertyNames();
            while(names.hasMoreElements()){
                String name = (String)names.nextElement();
                if(name.startsWith(startsWith)){
                    if(endsWith == null){
                        props.put(name, getProperty(name));
                    }
                    else if(name.endsWith(endsWith)){
                        props.put(name, getProperty(name));
                    }
                }
            }
        }
        return props;
    }

    /**
     * Remove the set of properties that match the specified pattern.
     * See getProperties(String) for more info about the pattern.
     *
     * @param propPattern a pattern with 0 or 1 '*' chars.
     */
    public void removeProperties(String propPattern){
        int index = propPattern.indexOf("*");
        if(index == -1){
            String value = getProperty(propPattern);
            if(value != null){
                remove(propPattern);
            }
        }
        else{
            String startsWith = propPattern.substring(0, index);
            String endsWith;
            if(index == propPattern.length()-1){
                endsWith = null;
            }
            else{
                endsWith = propPattern.substring(index+1);
            }

            // unchecked because Vector.clone() is not generic
            @SuppressWarnings("unchecked")
            Vector<Object> cle = (Vector<Object>)keys.clone();
            
			int size = cle.size();
            for (int i = 0;i < size;i += 1) {
                String name = (String)cle.elementAt(i);
            //Enumeration names = propertyNames();
            //while(names.hasMoreElements()){
            //    String name = (String)names.nextElement();
                if(name.startsWith(startsWith)){
                    if(endsWith == null){
                        remove(name);
                    }
                    else if(name.endsWith(endsWith)){
                        remove(name);
                    }
                }
            }
        }
    }

    /**
     * Add set of properties to this object.
     * This method will replace the value of any properties
     * that already existed.
     */
    public void setProperties(Properties props){
        Enumeration names = props.propertyNames();
        while(names.hasMoreElements()){
            String name = (String)names.nextElement();
            setProperty(name, props.getProperty(name));
        }
    }

    public void load(InputStream is) throws IOException {
        load2(new BufferedReader(new InputStreamReader(is)));
    }

    public void load(Reader reader) throws IOException {
        load2(new BufferedReader(reader));
    }

    /*
     * This method attempts to parse a .properties file
     * using the same rules as Java, except that the file
     * is assumed to have UTF-8 encoding.
     * 
     * Let <ow> indicates optional whitespace and <rw> required whitespace.
     * 
     * Comment lines have the form <ow>#<comment> or <ow>!<comment>
     * If # or ! isn't the first non-whitespace character on a line,
     * it doesn't start a comment.
     * 
     * Key/value pairs have the form <ow>key<ow>=<ow>value
     * or <ow>key<ow>:<ow>value or <ow>key<rw>value
     * In other words, you can use an equal sign, a colon,
     * or just whitespace to separate the key from the value.
     * 
     * Trailing whitespace is not stripped from the value.
     * 
     * You can use standard escape sequences
     * like \n, \r, \t, \u1234, and \\.
     * 
     * Backslash-space is an escape sequence for a space;
     * for example, if a value needs to start with a space
     * you must write it as backslash-space or it will be
     * interpreted as optional whitespace preceding the value.
     * However, you don't need to escape spaces within a value.
     *   
     * You can continue a line by ending it with a backslash.
     * Leading whitespace on the next line is stripped.
     *      
     * Backslashes that aren't part of an escape sequence are removed.
     * For example, \A is just A.
     *      
     * You don't need to escape a double-quote or a single-quote
     * (but it doesn't hurt to do so).
     */
    public void load2(BufferedReader br) throws IOException
    {
    	terminators = getTerminators();
    	
        //BufferedReader br = new BufferedReader(new InputStreamReader(is));
        String line;
        StringBuilder buffer = new StringBuilder(100);
    	int lineNumber = 0;
        int comment_length=0;
        String sep = System.getProperty("line.separator");
        int sep_len = sep.length();

        while((line=br.readLine())!=null) {
        	lineNumber++;
            //String comment=null;
            int len = line.length();
            int start=0;
            
            // skip the Unicode BOM; UTF-8 is indicated by the byte sequence
            // EF BB BF, which is the UTF-8 encoding of the character U+FEFF)
            if (lineNumber == 1 && len > 0 && line.charAt(0) == '\uFEFF') {
                line = line.substring(1);
                len = line.length();
            }

            // find first non-whitespace char
            for(;start<len && whitespace.indexOf(line.charAt(start))!=-1;start++);

            if (line.trim().length() == 0) {
                buffer.append(sep);
                comment_length+=sep_len;
                continue;
            }

            // if lines starts with !, # or only contains whitespace
            // add it to the buffer and start over with a new line
            if(len==0 || line.charAt(start)=='!' || line.charAt(start)=='#' ||
               whitespace.indexOf(line.charAt(start))!=-1) {
                buffer.append(line);
	            buffer.append(sep);
                comment_length+=len+sep_len;
                continue;
            }

            // done with comment save it
            if(comment_length!=0) {
                buffer.setLength(comment_length);
            //    comment = buffer.toString();
            }

            buffer.setLength(0);

            // put start of name=value piece into beginning of buffer
            buffer.append(line.substring(start));

            // a line ending with a backslash is continued onto the following line
            while(line != null && line.length() > 1 && line.charAt(line.length()-1)=='\\') {
                buffer.setLength(buffer.length()-1); // remove the backslash
                line=br.readLine();
                if(line!=null) {
                	lineNumber++;
                    int new_start = 0;
                    len = line.length();
                    // find first non-whitespace char

                    for(;new_start < len &&
                            whitespace.indexOf(line.charAt(new_start))!=-1;
                        new_start++);

                    // add to buffer
                    buffer.append(line.substring(new_start));
                }
            }

	        String propLine = buffer.toString();
            String com_key = loadProperty(propLine, lineNumber);

            if(comment_length!=0 && com_key != null) {
                //comment_blocks.put(com_key, comment);
                //comment=null;
                comment_length=0;
            }

            buffer.setLength(0);
        }
    }

    public void store(PrintWriter writer) {
        store2(writer, null);
    }

    public void store(OutputStream os) {
        store2(new PrintWriter(os), null);
    }

    public void store(OutputStream os, String header) {
        store2(new PrintWriter(os), header);
    }

    private void store2(PrintWriter out, String header) {

        // Write out the header, if specified.
        if (header != null) {
            out.println("#" + header);
            out.println("#" + new Date().toString());
        }

        for(Enumeration<Object> ke = keys.elements();
            ke.hasMoreElements();) {
            String key = (String) ke.nextElement();
            String value = (String) super.get(key);
            //String comment = (String) comment_blocks.get(key);
            //if (comment != null) {
            //    out.print(comment);
            //}
            out.print(escape(key));
            out.print('=');
            out.println(escape(value));
        }
        out.flush();
    }

    // parse a property line
    private String loadProperty(String prop, int lineNumber)
    {
        String key;
        String value;
        int prop_len=prop.length();
        int prop_index=0;

        // key
        for(; prop_index<prop_len; prop_index++) {
            char current = prop.charAt(prop_index);
            if(current == '\\')
                 prop_index++;
            else if(terminators.indexOf(current) != -1)
                break;
        }

		key = prop.substring(0, prop_index);
		key = removeBadChars(prop, key, false);
        key = unescape(key);
	    key = key.trim();

        // got key now go to first non-whitespace
        for(; prop_index<prop.length() &&
                whitespace.indexOf(prop.charAt(prop_index))!=-1;
            prop_index++);

	    try {
		    // also skip : or =
		    if(prop.charAt(prop_index)==':' || prop.charAt(prop_index)=='=') {
			    prop_index++;
			    // skip any more whitespace
			    for(; prop_index<prop.length() &&
					    whitespace.indexOf(prop.charAt(prop_index))!=-1;
			        prop_index++);
		    }
	    } catch (StringIndexOutOfBoundsException ex) {
		    return null;
	    }

	    int value_start=prop_index;

        // read value
        for(;prop_index<prop.length(); prop_index++) {
            char current = prop.charAt(prop_index);
            if(current == '\\')
                 prop_index++;
            else if(valterminators.indexOf(current) != -1)
                break;
        }

		value = prop.substring(value_start,prop_index);
		value = removeBadChars(prop, value, true);
		value = unescape(value);

        //System.out.println("|" + key + "|" + value + "|");
		
		if(!super.containsKey(key))
            keys.addElement(key);
        super.put(key, value);
        lines.put(key, new Integer(lineNumber));

        return key;
    }
    
    /*
     * In Java .properties files, an equal sign, a colon,
     * a space, or a tab can be used to separate the key and value.
     * Flex 2 supported only '=', while Flex 3 works like Java.
     * PropertyText overrides this method
     * to implement that compatibility logic.
     */
    protected String getTerminators()
    {
    	return "=: \t";
    }
    
    /*
     * In Java .properties files, no "bad" characters 
     * are removed from the key or value.
     * Flex 2 removed double-quotes, carriage returns, and newlines.
     * This was a bad idea, and Flex 3 works like Java.
     * PropertyTest overrides this method
     * to implement that compatibility logic.
     */
    protected String removeBadChars(String prop, String string, boolean isValue)
    {
    	return string;
    }

    // escape some special keys and expand unicodes to \\uXXXX
    // used when writing out the properties
    private String escape(String string) {

    if(string==null)
        return null;


        StringBuilder buffer = new StringBuilder(string.length()+10);

        for(int i=0; i<string.length(); i++) {
            char current=string.charAt(i);
            switch(current) {
            case '\\':
                buffer.append('\\'); buffer.append('\\');
                break;
            case '\t':
                buffer.append('\\'); buffer.append('t');
                break;
            case '\n':
                buffer.append('\\'); buffer.append('n');
                break;
            case '\r':
                buffer.append('\\'); buffer.append('r');
                break;

            default:
                if((current < 20) || (current > 127)) {
                    buffer.append('\\');
                    buffer.append('u');
                    buffer.append(toHex((current >> 12) & 0xF));
                    buffer.append(toHex((current >> 8) & 0xF));
                    buffer.append(toHex((current >> 4) & 0xF));
                    buffer.append(toHex((current) & 0xF));
//                  } else if(escapes.indexOf(current) != -1) {
//                      buffer.append(current);
                } else
                    buffer.append(current);
            }
        }

        return buffer.toString();
    }

    // do opposite of escape, used when reading properties
    private String unescape(String string)
    {
	    if(string==null)
		    return null;

	    StringBuilder buffer = new StringBuilder(string.length());
	    int string_index=0;

	    while(string_index < string.length()) {
		    char add = string.charAt(string_index++);
		    if(add == '\\') {
			    add = string.charAt(string_index++);
			    // handle unicode chars, else escaped single chars
			    if(add == 'u') {
				    // Read the xxxx
				    int unicode=0;
				    for (int i=0; i<4; i++) {
					    add = string.charAt(string_index++);
					    switch (add) {
						    case '0': case '1': case '2': case '3': case '4':
						    case '5': case '6': case '7': case '8': case '9':
						    unicode = (unicode << 4) + add - '0';
						    break;

						    case 'a': case 'b': case 'c':
						    case 'd': case 'e': case 'f':
						    unicode = (unicode << 4) + 10 + add - 'a';
						    break;

						    case 'A': case 'B': case 'C':
						    case 'D': case 'E': case 'F':
						    unicode = (unicode << 4) + 10 + add - 'A';
						    break;

						    default:
						    {
							    ThreadLocalToolkit.log(new MalformedEncoding(string));
						    }
					    }
				    }
				    add = (char) unicode;
			    } else {
				    // add escaped char to value
				    switch(add) {
					    case 't':
						    add = '\t';
						    break;
					    case 'n':
						    add = '\n';
						    break;
					    case 'r':
						    add = '\r';
						    break;
					    case 'f':
						    add = '\f';
						    break;
				    }
			    }
			    buffer.append(add);
		    } else
			    buffer.append(add);
	    }
	    return buffer.toString();
    }

	/**
     * Convert a nibble to a hex character
     * @param        nibble        the nibble to convert.
     */
    private static char toHex(int nibble) {
        return hexDigit[(nibble & 0xF)];
    }

    /** A table of hex digits */
    private static final char[] hexDigit = {
        '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
    };

    public void save(OutputStream os,String header) {
        store(os);
    }

    public static void main(String[] args) {
        try {
            FileInputStream fis = new FileInputStream(args[0]);
            OrderedProperties p = new OrderedProperties();
            java.util.Properties props = new java.util.Properties();

            p.load(fis);
            fis.close();
            fis = new FileInputStream(args[0]);
            props.load(fis);

            p.store(System.out);
            System.out.println("-------");
            props.store(System.out, null);
        } catch(IOException e) {
            System.out.println(e);
        }
    }

	public static class MalformedEncoding extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 5450764640102723202L;

        public MalformedEncoding(String string)
		{
			this.string = string;
			noPath();
		}

		public String string;
	}

	public static class RemovedFromProperty extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = 4926793211834428616L;

        public RemovedFromProperty(String string, String property)
		{
			this.string = string;
			this.property = property;
		}

		public String string, property;
	}

}
