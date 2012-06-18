/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.parser;

//import macromedia.asc.util.*;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.*;
import java.nio.*;

import static macromedia.asc.parser.CharacterClasses.*;
import static macromedia.asc.embedding.avmplus.Features.*;

/**
 * InputBuffer.h
 *
 * @author Jeff Dyer
 * 
 * Notes on current restructuring:
 *  This is taking a lot of time. The existing use of this module is complex and fragile,
 *  a lot of the work will be eliminating unnecessary and cumbersome code.
 *  
 *  1. Since the full source text is saved, why not block load in the first place?                  DONE
 *  2. The line map is only used if an error/warning message is done, so why do it unless needed?   DONE
 *  
 *  
 *  3. The strip of special formatting characters, defined in ecma3, should be optional.
 *  4. All the things like line buffers etc. don't seem necessary.                                  GONE
 *  5. Line scan seems unnecessary                                                                  GONE
 *  6. utf-8, utf-16 etc. decode should be clearly done.                                            DONE
 *  7. bom read should be simple                                                                    DONE
 *      But not really simple, needs to be recognized and modify pos correctly.
 *  
 *  8. The scanner should just index the source buffer directly. no read() method needed.
 *      --Cant be done really, not while supporting the stripping of control-chars and keeping pos correct...
 *      
 *  9. Rather than blocking the file in memory, use NIO (mmap)
 */
public class InputBuffer
{
    /**
     * input text, if a fragment, startSourcePos is non-zero
     */
    
    private final String text;
    private int textPos = 0;    // Scanner input cursor, current char + 1
    private int textMarkPos = 0;
    
    /**
     * 0..n array of newline positions found in text.
     */
    private int lineMap[]; 
    
    /**
     * Map to starting source line number for this InputBuffer 
     */
    private int startLineNumber;
    
    /*
     * Map to starting source position for this InputBuffer
     * --Not an offset on the text input buffer.
     */
    private int startSourcePos;
    
    public String origin; // sourcefilename
    public boolean report_pos = true;
    
	public InputBuffer(InputStream in, String encoding, String origin)
	{   
        text = createBuffer(in, encoding);
		init(origin,0,0);
	}

	public InputBuffer(String in, String origin)
	{  
	    // assumes any encoding required is already done.
        text = in;
		init(origin,0,0);
	}
    
    public InputBuffer(String in, String origin, int startPos, int startLine)
    {  
        // assumes any encoding required is already done.
        text = in;
        init(origin,startPos,startLine);
        startSourcePos = startPos;
        startLineNumber = startLine;
    }
    
	/**
	 * No arg constructor for subclasses that aren't InputStream or String based.
	 */
	protected InputBuffer()
	{   
        text = null;
        init(null,0,0);
	}

	private void init(String origin, int startPos, int startLine)
	{
		this.origin = origin;
        startSourcePos = startPos;
        startLineNumber = startLine;
	}

	//private CharBuffer createBuffer(InputStream in, String encoding)
    private String createBuffer(InputStream in, String encoding)
	{
        
        // load the input stream into a String

        int i, len;
        byte [] b;
        ByteBuffer bb;
        
        try {
            i = in.available(); // assumes we can eat the whole file...
            
            if ( i == 0 )
            {
                return "";
            }

            b = new byte[i];
            
            // Read the whole file...is there a faster read primitive?
            
            len = in.read(b,0,i);
            
            // ??? Check: is length read as expected?
            if ( len != i )
            {
                assert true:"file read error:"+origin;
            }
            
            // ??? Check: are we at the EOF?
            if ( in.read() != -1 )
            {
                assert true:"file EOF error:"+origin;              
            }
        }
        catch (IOException ex)
        {
            ex.printStackTrace();
            return null;
        }
          
        // select the charset decoder
        // According to old code, presence of a byte order mark defines encoding
        // no matter what the user passed in. 
        // ??? Note that a FileInputStream has the bom already marked out...maybe we dont need to do this.
        // ??? I also thought the decoder would strip the bom...it does not.
        
        if (b.length > 3 && b[0] == (byte)0xef && b[1] == (byte)0xbb && b[2] == (byte)0xbf)
        {
            encoding = "UTF8";
            bb = ByteBuffer.wrap(b,3,b.length-3);
        }
        else if (b.length > 3 && b[0] == (byte)0xff && b[1] == (byte)0xfe || b[0] == (byte)0xfe && b[1] == (byte)0xff)
        {
            encoding = "UTF16"; // which seems to ignore the endian mark....
            bb = ByteBuffer.wrap(b,3,b.length-3);
        }
        else 
        {
            if ( encoding == null )
            {
                encoding = "UTF8";              
            }
            bb = ByteBuffer.wrap(b);
        }
        
        Charset cs = null;
        
        try
        {
            cs = Charset.forName(encoding);
        }
        catch (IllegalCharsetNameException ex)
        {
            cs = Charset.defaultCharset(); // ok, try with a default Charset...
        }
        
        // Convert/decode to CharBuffer
        
        CharBuffer cb = cs.decode(bb);

        return cb.toString();
	}
    
     private void buildLineMap(String src, int max) 
     {
         int line = 0;
         int pos = 0;
         int[] lb = new int[max+1]; // ???fixme: use a dynamic array, max can be a lot bigger than needed.
         
         while (pos < max) {
             lb[line++] = pos;
             do {
                 char ch = src.charAt(pos);
                 if (ch == '\r' || ch == '\n') {
                     if (ch == '\r' && (pos+1) < max && src.charAt(pos+1) == '\n')
                         pos += 2;
                     else
                         ++pos;
                     break;
                 }
             } while (++pos < max);
         }
         
         lb[line++] = pos; // fake line at EOF
         
         lineMap = new int[line];
         System.arraycopy(lb, 0, lineMap, 0, line);
     }
 
     private int cachedLastLineMapPos = 0;
     private int cachedLastLineMapIndex = 0;

     /**
      * Binary search for nearest newline, given a position in text, note that lines start at 1
      * Returns 0 if pos is low, max if high
      * @param sourcePos -- file based source position, converted to text[pos]
      * @return line map index
      */
     private int getLineMapIndex(int srcPos) 
     {
         int pos = srcPos - startSourcePos;  // Adjust for file offset (get textPos)
         
         if ( pos < 0 )
             return 0;
         
         if (lineMap == null)
             buildLineMap(text,text.length());
         
         if (pos == cachedLastLineMapPos)    
             return cachedLastLineMapIndex;

         cachedLastLineMapPos = pos;

         int low = 0;
         int high = lineMap.length-1;
         
         while (low <= high) 
         {
             int mid = (low + high) >> 1;
             int midPos = lineMap[mid];

             if ( midPos < pos )
                 low = mid + 1;
             else if ( midPos > pos )
                 high = mid - 1;
             else {
                 cachedLastLineMapIndex = mid+1;                                                                                                                 
                 return cachedLastLineMapIndex;
             }
         }
         cachedLastLineMapIndex = low;
         return cachedLastLineMapIndex;                                                                                                                                         
     }

     public int getLnNum(int srcPos)
     {   
         int l = getLineMapIndex(srcPos);
         if ( l == 0 )
             l = 1;
         return l + startLineNumber;  
     }
     
     public final int getLineStartPos(int srcPos)
     {
         int l = getLineMapIndex(srcPos);
         
         assert l <= lineMap.length : "line number out of range";
         
         if ( l == 0 )
             l = 1;
         
         return lineMap[l-1];
     }
     
    /*
     * text
     *
     * Provide the caller with a reference to the full text of the program.
     */

    public String source()
    {
        return text;
    }

    /**
     * Scanner position mark
     * Scanner only.
     */

    public int textMark()
    {
         textMarkPos = textPos-1;
         return textMarkPos;
    }
    
    /**
     * Scanner text pos
     * Scanner only
     */
    
    public int textPos()
    {
        return textPos;
    }
    
	/**
	 * nextchar, advance pos
	 */

	public int nextchar()
	{
		int c;
        
        if ( textPos >= text.length()){
            textPos = text.length() + 1;
            return 0;
        }
        
		c = text.charAt(textPos++);
		return c;
	}
	
	/**
	 * Backup one character position in the input. 
	 */

	public void retract()
	{
        if ( textPos > 0 )
            textPos--;
	}

	// utility for java branch only to convert a Character.getType() unicode type specifier to one of the enums
	//  defined in CharacterClasses.java.  In the c++ branch, we use the character as an index to a table defined
	//  in CharacterClasses.h
	final private char javaTypeOfToCharacterClass(int javaClassOf)
	{
		switch(javaClassOf)
		{
			case Character.UPPERCASE_LETTER:		    return Lu;	// = 0x01 Letter, Uppercase
			case Character.LOWERCASE_LETTER:		    return Ll;	// = 0x02 Letter, Lowercase
			case Character.TITLECASE_LETTER:		    return Lt;	// = 0x03 Letter, Titlecase
			case Character.NON_SPACING_MARK:		    return Mn;	// = 0x04 Mark, Non-Spacing
			case Character.COMBINING_SPACING_MARK:	    return Mc;	// = 0x05 Mark, Spacing Combining
			case Character.ENCLOSING_MARK:			    return Me;	// = 0x06 Mark, Enclosing
			case Character.DECIMAL_DIGIT_NUMBER:	    return Nd;	// = 0x07 Number, Decimal Digit
			case Character.LETTER_NUMBER:			    return Nl;	// = 0x08 Number, Letter
			case Character.OTHER_NUMBER:			    return No;	// = 0x09 Number, Other
			case Character.SPACE_SEPARATOR:			    return Zs;	// = 0x0a Separator, Space
			case Character.LINE_SEPARATOR:			    return Zl;	// = 0x0b Separator, Line
			case Character.PARAGRAPH_SEPARATOR:		    return Zp;	// = 0x0c Separator, Paragraph
			case Character.CONTROL:                     return Cc;	// = 0x0d Other, Control
			case Character.FORMAT:                      return Cf;	// = 0x0e Other, Format
			case Character.SURROGATE:                   return Cs;	// = 0x0f Other, Surrogate
			case Character.PRIVATE_USE:                 return Co;	// = 0x10 Other, Private Use
			case Character.UNASSIGNED:                  return Cn;	// = 0x11 Other, Not Assigned (no characters in the file have this property)

				// Non-normative classes.
			case Character.MODIFIER_LETTER:			    return Lm;	// = 0x12 Letter, Modifier
			case Character.OTHER_LETTER:			    return Lo;	// = 0x13 Letter, Other
			case Character.CONNECTOR_PUNCTUATION:       return Pc;	// = 0x14 Punctuation, Connector
			case Character.DASH_PUNCTUATION:		    return Pd;	// = 0x15 Punctuation, Dash
			case Character.START_PUNCTUATION:		    return Ps;	// = 0x16 Punctuation, Open
			case Character.END_PUNCTUATION:			    return Pe;	// = 0x17 Punctuation, Close
			case Character.INITIAL_QUOTE_PUNCTUATION:	return Pi;	// = 0x18 Punctuation, Initial quote (may behave like Ps or Pe depending on usage)
			case Character.FINAL_QUOTE_PUNCTUATION:		return Pf;	// = 0x19 Punctuation, Final quote (may behave like Ps or Pe depending on usage)
			case Character.OTHER_PUNCTUATION:           return Po;	// = 0x1a Punctuation, Other
			case Character.MATH_SYMBOL:                 return Sm;	// = 0x1b Symbol, Math
			case Character.CURRENCY_SYMBOL:             return Sc;	// = 0x1c Symbol, Currency
			case Character.MODIFIER_SYMBOL:             return Sk;	// = 0x1d Symbol, Modifier
			case Character.OTHER_SYMBOL:                return So;	// = 0x1e Symbol, Other
			
			default: // DIRECTIONALITY_LEFT_TO_RIGHT, DIRECTIONALITY_RIGHT_TO_LEFT, DIRECTIONALITY_RIGHT_TO_LEFT_ARABIC, etc.
				// DIRECTIONALITY_EUROPEAN_NUMBER, etc.
				return Cn; // or So ?
		}
	}

    /**
     * Advance the input cursor if advance is true.
     * @return the Unicode character class of the current
     * character
     */
    
	public char nextcharClass(char c, boolean advance)
	{
        int distance = 0;

        if( c == '\\' && text.charAt(textPos) == 'u' )
        {
            int y, digit, thisChar=0;
                
            for( y = textPos+1; y < textPos + 5 && y < text.length(); y++ )
            {
                digit = Character.digit( text.charAt(y),16 );
                if (digit == -1)
                    break;
                thisChar = (thisChar << 4) + digit;
            }
            
            if ( y == textPos+5 && Character.isDefined((char)thisChar) ) 
            {
                c = (char) thisChar;
                distance = 5;
            }
            else {
                    
                /*
                 * eat one on error --just to be consistent with asc-test expected error print!
                 * FIXME: Update the Scanner to produce an unknown escape error message.
                 */
                
                distance = 1;
            }
        }
        if ( advance )
            textPos += distance;
        
        return javaTypeOfToCharacterClass(Character.getType(c));
	}

	/**
	 * positionOfNext: returns *source* relative character position
     * NOT for scanner use, used by node/token position mapping
	 */

	public int positionOfNext()
	{
		return textPos + startSourcePos;
	}

	/** 
     * positionOfMark: returns *source* relative mark position
     * NOT for scanner use, used by node/token position mapping
     * @return mark
	 */

	public int positionOfMark()
	{
        if( !report_pos )
            return -1;

		// This may happen with abc imports
        
        if ( textMarkPos == -1 )
            return textMarkPos + startSourcePos;
        
        return textMarkPos + startSourcePos;
	}

	/*
	 * copy
	 */

    private boolean has_escape( String src, int from, int to)
    {
        for (int i = from; i < to; i++)
        {
            if (src.charAt(i) == '\\')
            {
                return true;
            }
        }
        return false;
    }
    
    private boolean has_u_escape( String src, int from, int to)
    {
        for (int i = from; i < to; i++)
        {
            if (src.charAt(i) == '\\' && i < to && src.charAt(i+1) == 'u' )
            {
                return true;
            }
        }
        return false;
    }
    
    private String escapeUnicode(String src, int from, int to)
    {
        
        if (has_u_escape(src,from,to)==false)
        {
            return src.substring(from,to);
        }
   
       final int len = to-from;
       final StringBuilder buf = new StringBuilder(len);
        
        for (int i = from; i < to; i++)
        {
            char c = src.charAt(i);
            if (c == '\\' && i < to)
            {   
                if ( src.charAt(i+1) == 'u' )
                { 
                    int thisChar = 0;
                    int y, digit;
                    // calculate numeric value, bail if invalid
                    for( y=i+2; y<i+6 && y < to+1; y++ )
                    {
                        digit = Character.digit( src.charAt(y),16 );
                        if (digit == -1)
                            break;
                        thisChar = (thisChar << 4) + digit;
                    }
                    if ( y != i+6 || Character.isDefined((char)thisChar) == false )  // if there was a problem or the char is invalid just escape the '\''u' with 'u'
                    {
                        c = src.charAt(++i);
                    }
                    else // use Character class to convert unicode codePoint into a char ( note, this will handle a wider set of unicode codepoints than the c++ impl does).
                    {
                        // jdk 1.5.2 only, but handles extended chars:  char[] ca = Character.toChars(thisChar);
                        c = (char)thisChar;
                        i += 5;
                    }
                }
            }
            buf.append(c);
        }
        return buf.toString();
    }
    
    /**
     * Copies a string from index <from> to <to>, interpreting escape characters
  	 */
    
	private String escapeString(String src, int from, int to)
	{
		// C: only 1 string in 1000 needs escaping and the lengths of these strings are usually small,
		//    so we can cut StringBuilder usage if we check '\\' up front.

		if (has_escape(src,from,to)==false)
		{
            return src.substring(from,to);
		}

        int len = to-from;
        final StringBuilder buf = new StringBuilder(len);
        
		for (int i = from; i < to; i++)
		{
			char c = src.charAt(i);
			if (c == '\\')
			{
				int c2 = src.charAt(i + 1);
                
				switch (c2)
				{
					case '\'':
					case '\"':
						continue;
                        
                    // strip escaped newlines    
                    case '\r':
                        if ( src.charAt(i+2) == '\n' )
                        {
                            i++;
                        }
                    case '\n':
                        i++;
                        continue;
						
					case '\\': // escaped escape char
						c = '\\';
                        ++i;
                        break;

					case 'u': // Token constructor will handle all embedded backslash u characters, within a string or not
                    {
                        int thisChar = 0;
                        int y, digit;
                        // calculate numeric value, bail if invalid
                        for( y=i+2; y<i+6 && y < to+1; y++ )
                        {
                            digit = Character.digit( src.charAt(y),16 );
                            if (digit == -1)
                                break;
                            thisChar = (thisChar << 4) + digit;
                        }
                        if ( y != i+6 || Character.isDefined((char)thisChar) == false )  // if there was a problem or the char is invalid just escape the '\''u' with 'u'
                        {
                            c = src.charAt(++i);
                        }
                        else // use Character class to convert unicode codePoint into a char ( note, this will handle a wider set of unicode codepoints than the c++ impl does).
                        {
                            // jdk 1.5.2 only, but handles extended chars:  char[] ca = Character.toChars(thisChar);
                            c = (char)thisChar;
                            i += 5;
                        }
                        break;
                    }
					default:
				    {
						if (PASS_ESCAPES_TO_BACKEND)
						{
							c = src.charAt(++i);
							break; // else, unescape the unrecognized escape char
						}
	                    
						switch (c2)
						{
							case 'b':
								c = '\b';
								++i;
								break;
							case 'f':
								c = '\f';
								++i;
								break;
							case 'n':
								c = '\n';
								++i;
								break;
							case 'r':
								c = '\r';
								++i;
								break;
							case 't':
								c = '\t';
								++i;
								break;
							case 'v':
								// C: There is no \v in Java...
								c = 0xb;
								++i;
								break;
                                
							case 'x':
							{  
                                int d1,d2;
                                
                                if ( i+4 > to || 
                                     (d1 = Character.digit(src.charAt(i+2),16)) == -1 || 
                                     (d2 = Character.digit(src.charAt(i+3),16)) == -1 )
                                {
                                    ++i;
                                    c = 'x';
                                }
                                else
                                {
                                    i += 3;
                                    c = (char) ((d1 << 4) + d2);
                                }
                                break;
                            }

							default:
								c = src.charAt(++i);
								break; // else, unescape the unrecognized escape char

						} // end switch
					}
				} // end switch
			}
			buf.append(c);
		}
		return buf.toString();
	}

 
    /** 
     * A variety of copy methods...could this be simpler?
     * @return String
     */
    
    public String copy()
    {
        assert textMarkPos >= 0 && textPos > textMarkPos : "copy(): negative length copy textMarkPos =" + textMarkPos + " textPos = "+textPos + "text.length = " + text.length();
        
        return text.substring(textMarkPos,textPos);
    }
    
    public String copyReplaceStringEscapes(boolean needs_escape)
    {
        assert textMarkPos >= 0 && textPos > textMarkPos : "copyReplaceStringEscapes(boolean): negative length copy textMarkPos =" + textMarkPos + " textPos = "+textPos;
        
        if ( needs_escape )
            return escapeString(text, textMarkPos, textPos);
        
        return text.substring(textMarkPos,textPos);
    }
    
    public String substringReplaceUnicodeEscapes(int begin, int end)
    {
        final int len = (end-begin);
        
        if ( len <= 0 )
            return null;  // this is on purpose. xml cons doesn't always check.
        
        return escapeUnicode(text,begin,end);
    }
    
    public String copyReplaceUnicodeEscapes()
    {
        assert textMarkPos >= 0 && textPos > textMarkPos : "copyReplaceUnicodeEscapes(): negative length copy textMarkPos =" + textMarkPos + " textPos = "+textPos;
        
        return escapeUnicode(text, textMarkPos, textPos);
    }
    
    public String copyReplaceUnicodeEscapes(boolean needs_escape)
    {
        assert textMarkPos >= 0 && textPos > textMarkPos : "copyReplaceUnicodeEscapes(boolean): negative length copy textMarkPos =" + textMarkPos + " textPos = "+textPos;
        
        if ( needs_escape )
            return escapeUnicode(text, textMarkPos, textPos);
        
        return text.substring(textMarkPos,textPos);
    }
    
    // ??? the following two methods are for temporary experimentation with reserved word lookup in Scanner
    
    public char markCharAt(int offset)
    {
        return text.charAt(textMarkPos-offset); //???looks wrong...markPos+offset 
    }
    
    public int markLength()
    {
        return textPos - textMarkPos; // assumes pos is +1
    }
    
    /**
     * 
     * @param srcPos
     * @return column position (from 1..n)
     */
    
    public int getColPos(int srcPos)
	{
        int start = getLineStartPos(srcPos);
		return (srcPos-start)+1; // 0..n + 1 because columns start at 1, unlike array indexes....
	}

    /*
     * The text gathered here can has tabs stripped so error pointer lines up?
     */
    
    public String getLineText(int srcPos)
    {
        int i, start;
        //final StringBuilder buf = new StringBuilder(128);
        
        start = getLineStartPos(srcPos);

        for (i = start; i < text.length(); i++ )
        {
            char c = text.charAt(i);
            
            if ( c == '\n' || c == '\r' || c == 0x00 || c == 0x2028 || c == 0x2029 )
                break;
            
            // Turn the following on to get linepointer ....^ to line up
            //if ( c == '\t' )
            //    c = ' ';
          //  buf.append(c); 
        }
        return text.substring(start,i);
    }
    
    /**
     * This method returns an error pointer string drawing ...^ at the proper column.
     * Since it's static, we can't assume we have any source text to work with.
     * This implies that source text display (in get LineText) must be massaged to replace all tabs
     * with spaces.
     * If you scan thru the source text (and dont have to emit ....) you could use the original formatting characters
     * to line up the error pointer.
     */
    
	public static String getLinePointer(int col)
	{
 
		final StringBuilder padding = new StringBuilder(1+col);
		for (int i = 0; i < col-1; i++)
		{
			padding.append(".");
		}
		padding.append("^");
		return padding.toString();
	}

	public void clearUnusedBuffers() 
	{
	}
}

