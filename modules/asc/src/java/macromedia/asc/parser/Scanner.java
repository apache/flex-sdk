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
//import java.util.concurrent.*;
import java.util.HashMap;
import macromedia.asc.util.*;
import macromedia.asc.embedding.ErrorConstants;

import java.io.InputStream;
import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.parser.States.*;
import static macromedia.asc.parser.CharacterClasses.*;
import static macromedia.asc.embedding.avmplus.Features.*;

/**
 * Partitions input character stream into tokens.
 *
 * @author Jeff Dyer
 */
public final class Scanner implements ErrorConstants
{
    private static final boolean debug = false;

    /*
     * Scanner maintains a notion of a single current token
     * The Token.java class is not used anymore. It might get repurposed as a enum of token names.
     * We should also upgrade a Token to contain source seekpos,line,column information, so we can throw away the line table,
     * which would mean we also dont need to buffer source after scanning, since we could reread it if an error/warning/info
     * line print was requested.
     */
    
    private class Tok {
    	int id;
    	int lookback;
    	String text;
    }
    
    private Tok currentToken;
    private boolean isFirstTokenOnLine;
    private boolean save_comments;
    private Context ctx;
    public InputBuffer input;
   
    private static final HashMap<String,Integer> reservedWord;
    
    static {
    	reservedWord = new HashMap<String,Integer>(64);
    	reservedWord.put("as",AS_TOKEN); // ??? predicated on HAS_ASOPERATOR
    	reservedWord.put("break",BREAK_TOKEN);
    	reservedWord.put("case",CASE_TOKEN);
    	reservedWord.put("catch",CATCH_TOKEN);
    	reservedWord.put("class",CLASS_TOKEN);
    	reservedWord.put("const",CONST_TOKEN);
    	reservedWord.put("continue",CONTINUE_TOKEN);
    	reservedWord.put("default",DEFAULT_TOKEN);
    	reservedWord.put("delete",DELETE_TOKEN);
    	reservedWord.put("do",DO_TOKEN);
    	reservedWord.put("else",ELSE_TOKEN);
    	reservedWord.put("extends",EXTENDS_TOKEN);
    	reservedWord.put("false",FALSE_TOKEN);
    	reservedWord.put("finally",FINALLY_TOKEN);
    	reservedWord.put("for",FOR_TOKEN);
    	reservedWord.put("function",FUNCTION_TOKEN);
    	reservedWord.put("get",GET_TOKEN);
    	reservedWord.put("if",IF_TOKEN);
    	reservedWord.put("implements",IMPLEMENTS_TOKEN);
    	reservedWord.put("import",IMPORT_TOKEN);
    	reservedWord.put("in",IN_TOKEN);
    	reservedWord.put("include",INCLUDE_TOKEN);  
    	reservedWord.put("instanceof",INSTANCEOF_TOKEN);
    	reservedWord.put("interface",INTERFACE_TOKEN);
    	reservedWord.put("is",IS_TOKEN); //??? predicated on HAS_ISOPERATOR
    	reservedWord.put("namespace",NAMESPACE_TOKEN);
    	reservedWord.put("new",NEW_TOKEN);
    	reservedWord.put("null",NULL_TOKEN);
    	reservedWord.put("package",PACKAGE_TOKEN);
    	reservedWord.put("private",PRIVATE_TOKEN);
    	reservedWord.put("protected",PROTECTED_TOKEN);
    	reservedWord.put("public",PUBLIC_TOKEN);
    	reservedWord.put("return",RETURN_TOKEN);
    	reservedWord.put("set",SET_TOKEN);
    	reservedWord.put("super",SUPER_TOKEN);
    	reservedWord.put("switch",SWITCH_TOKEN);
    	reservedWord.put("this",THIS_TOKEN);
    	reservedWord.put("throw",THROW_TOKEN);
    	reservedWord.put("true",TRUE_TOKEN);
    	reservedWord.put("try",TRY_TOKEN);
    	reservedWord.put("typeof",TYPEOF_TOKEN);
    	reservedWord.put("use",USE_TOKEN);
    	reservedWord.put("var",VAR_TOKEN);
    	reservedWord.put("void",VOID_TOKEN);
    	reservedWord.put("while",WHILE_TOKEN);
    	reservedWord.put("with",WITH_TOKEN);
    }
    
    /*
     * Scanner constructors.
     */

    private void init(Context cx, boolean save_comments)
    {
        ctx = cx;
        state = start_state;
        level = 0;
        inXML = 0;
        states = new IntList();
        levels = new IntList();
        this.save_comments = save_comments;
        
        currentToken = new Tok();
    }

    
    public Scanner(Context cx, InputStream in, String encoding, String origin){this(cx,in,encoding,origin,true);}
    public Scanner(Context cx, InputStream in, String encoding, String origin, boolean save_comments)
    {
        init(cx,save_comments);
        this.input = new InputBuffer(in, encoding, origin);
        cx.input = this.input;
    }
    
    public Scanner(Context cx, String in, String origin){this(cx,in,origin,true);}
    public Scanner(Context cx, String in, String origin, boolean save_comments)
    {
        init(cx,save_comments);
        this.input = new InputBuffer(in, origin);
        cx.input = this.input; // FIXME: how nicely external state altering.
    }
    
    /**
     * This contructor is used by Flex direct AST generation.  It
     * allows Flex to pass in a specialized InputBuffer.
     */
    
    public Scanner(Context cx, InputBuffer input)
    {
        init(cx,true);
        this.input = input;
        cx.input = input; // so now we get to look around to find out who does this...
    }

    /**
     * nextchar() --just fetch the next char 
     */

    private char nextchar()
    {
        return (char) input.nextchar();
    }
  
    /*
     * retract() --
     * Causes one character of input to be 'put back' onto the
     * queue. [Test whether this works for comments and white space.]
     */

    public void retract()
    {
        input.retract();
    }

    /**
     * @return makeToken( +1 from current char pos in InputBuffer
     */
    
    private int pos()
    {
        return input.textPos();
    }
    
    /**
     * set mark position
     */
    private void mark()
    {
        input.textMark();
    }


    private final int makeCommentToken(int id, String text)
    {
        currentToken.id = id;
        // leave currentToken.lookback alone, comments dont count.
        currentToken.text = text;
        return id;
    }
    
    private final int makeToken(int id, String text)
    {
        currentToken.id = id;
        currentToken.lookback = id;
        currentToken.text = text;
        return id;
    }
    
    private final int makeToken(int id)
    {
        currentToken.id = id;
        currentToken.lookback = id;
        currentToken.text = null;
    	return id;
    }

    /*
     * Get the text of the current token
     */

    public String getCurrentTokenText()
    {
        if (currentToken.text == null)
        {
            error("Scanner internal: current token not a pseudo-terminal");   
        }
        return currentToken.text;
    }

    /*
     * A slightly confusing hack, returns the current token text or the text of the token type (Class)
     * Gets used in generating error messages or strings used in later concatenations.
     */

    public String getCurrentTokenTextOrTypeText(int id)
    {
        if (currentToken.text != null)
        {
        	return currentToken.text;
        }
        return Token.getTokenClassName(id);
    }
    
    /*
     * Strips quotes and returns text of literal string token as well as info about whether it was single quoted or not
     * Makes me wonder if leaving the quotes on strings is ever used...if not we could save what the quoting was and strip these up front.
     */
    
    public String getCurrentStringTokenText(boolean[] is_single_quoted )
    {
    	if (currentToken.id != STRINGLITERAL_TOKEN || currentToken.text==null)
    	{
    		error("internal: string token expected.");
    	}
        String fulltext = currentToken.text;
        is_single_quoted[0] = (fulltext.charAt(0) == '\'' ? true : false);
        String enclosedText = fulltext.substring(1, fulltext.length() - 1);
        
        return enclosedText;
    }

    /*
     * Record an error.
     */

    private void error(int kind, String arg)
    {
        StringBuilder out = new StringBuilder();

        String origin = this.input.origin;
        
        int errPos = input.positionOfMark();    // note use of source adjusted position
        int ln  = input.getLnNum(errPos);
        int col = input.getColPos(errPos);

        String msg = (ContextStatics.useVerboseErrors ? "[Compiler] Error #" + kind + ": " : "") + ctx.errorString(kind);
        
        if(debug) 
        {
            msg = "[Scanner] " + msg;
        }
        
        int nextLoc = Context.replaceStringArg(out, msg, 0, arg);
        if (nextLoc != -1) // append msg remainder after replacement point, if any
            out.append(msg.substring(nextLoc, msg.length()));

        ctx.localizedError(origin,ln,col,out.toString(),input.getLineText(errPos), kind);
        skiperror(kind);
    }

    private void error(String msg)
    {
        ctx.internalError(msg);
        error(kError_Lexical_General, msg);
    }

    private void error(int kind)
    {
        error(kind, "");
    }

    /*
     * skip ahead after an error is detected. this simply goes until the next
     * whitespace or end of input.
     */

    private void skiperror()
    {
        skiperror(kError_Lexical_General);
    }

    private void skiperror(int kind)
    {
        //Debugger::trace("skipping error\n");
    	switch (kind)
    	{
    	case kError_Lexical_General:
    		return;

    	case kError_Lexical_LineTerminatorInSingleQuotedStringLiteral:
    	case kError_Lexical_LineTerminatorInDoubleQuotedStringLiteral:
    		while (true)
    		{
    			char nc = nextchar();
    			if (nc == '\'' || nc == 0)
    			{
    				return;
    			}
    		}

    	case kError_Lexical_SyntaxError:
    	default:
    		while (true)
    		{
    			char nc = nextchar();
    			if (nc == ';' || nc == '\n' || nc == '\r' || nc == 0)
    			{
    				return;
    			}
    		}
    	}
    }

    /*
     *
     *
     */

    public boolean followsLineTerminator()
    {
        if (debug)
        {
            System.out.println("isFirstTokenOnLine = " + isFirstTokenOnLine);
        }
        return isFirstTokenOnLine;
    }

    /*
     *
     *
     */

    public int state;
    
    private int level;
    private int inXML = 0;
    private IntList states;
    private IntList levels;

    public void pushState()
    {
        states.add(state);
        levels.add(level);
        state = start_state;
        level = 0;
        inXML++;
    }

    public void popState()
    {
        state = states.removeLast();
        level = levels.removeLast();
        if ( inXML > 0) inXML--;
    }

    private StringBuilder getDocTextBuffer(String doctagname)
    {
        StringBuilder doctextbuf = new StringBuilder();
        doctextbuf.append("<").append(doctagname).append("><![CDATA[");
        return doctextbuf;
    }

    public void clearUnusedBuffers() 
    {
        input.clearUnusedBuffers();
        input = null;
    }
    
    /*
     * 
     * 
     */

    public int nexttoken(boolean resetState)
    {
        String doctagname = "description";
        StringBuilder doctextbuf = null;
        int startofxml = pos();
        StringBuilder blockcommentbuf = null;
        char regexp_flags = 0; // used to track option flags encountered in a regexp expression.  Initialized in regexp_state
        boolean maybe_reserved = false;
        char c = 0;

        if (resetState)
        {
            isFirstTokenOnLine = false;
        }
        
        while (true)
        {
            if (debug)
            {
                System.out.println("state = " + state + ", next = " + pos());
            }

            switch (state)
            {
                case start_state:
                    {
                        c = nextchar();
                        mark();
                        
                        switch (c)
                        {
                        case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g': case 'h': case 'i': case 'j':
                        case 'k': case 'l': case 'm': case 'n': case 'o': case 'p': case 'q': case 'r': case 's': case 't':
                        case 'u': case 'v': case 'w': case 'x': case 'y': case 'z': 
                            maybe_reserved = true;
                        case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G': case 'H': case 'I': case 'J':
                        case 'K': case 'L': case 'M': case 'N': case 'O': case 'P': case 'Q': case 'R': case 'S': case 'T':
                        case 'U': case 'V': case 'W': case 'X': case 'Y': case 'Z': 
                        case '_': case '$':
                            state = A_state;
                            continue;
                            
                        case 0xffef: // could not have worked...case 0xffffffef: // ??? not in Character type range ???
                            if (nextchar()==0xffffffbb &&
                                nextchar()==0xffffffbf)
                            {
                                // ISSUE: set encoding scheme to utf-8, and implement support for utf8
                                state = start_state;
                            }
                            else 
                            {
                                state = error_state;
                            }
                            continue;
                                
                            case '@':
                                return makeToken( ATSIGN_TOKEN );
                              
                            case '\'':
                            case '\"':
                            {
                                char startquote = (char) c;
                                boolean needs_escape = false;

                                while ( (c=nextchar()) != startquote )
                                {         
                                    if ( c == '\\' )
                                    {
                                        needs_escape = true;
                                        c = nextchar();

                                        // special case: escaped eol strips crlf or lf
                                         
                                        if ( c  == '\r' )
                                            c = nextchar();
                                        if ( c == '\n' )
                                            continue;
                                    }
                                    else if ( c == '\r' || c == '\n' )
                                    {
                                        if ( startquote == '\'' )
                                            error(kError_Lexical_LineTerminatorInSingleQuotedStringLiteral);
                                        else
                                            error(kError_Lexical_LineTerminatorInDoubleQuotedStringLiteral);
                                        break;
                                    }
                                    else if ( c == 0 )
                                    {
                                        error(kError_Lexical_EndOfStreamInStringLiteral);
                                        return makeToken( EOS_TOKEN );
                                    }
                                }
                                return makeToken(STRINGLITERAL_TOKEN, input.copyReplaceStringEscapes(needs_escape));
                            }

                            case '-':   // tokens: -- -= -
                                switch (nextchar())
                                {
                                case '-':
                                    return makeToken( MINUSMINUS_TOKEN );
                                case '=':
                                    return makeToken( MINUSASSIGN_TOKEN );
                                default:
                                    retract();
                                return makeToken( MINUS_TOKEN );
                                }

                            case '!':   // tokens: ! != !===
                                if (nextchar()=='=')
                                {
                                    if (nextchar()=='=')
                                        return makeToken( STRICTNOTEQUALS_TOKEN );
                                    retract();
                                    return makeToken( NOTEQUALS_TOKEN );
                                }   
                                retract();
                                return makeToken( NOT_TOKEN );
                                
                            case '%':   // tokens: % %=
                                switch (nextchar())
                                {
                                case '=':
                                    return makeToken( MODULUSASSIGN_TOKEN );
                                default:
                                    retract();
                                return makeToken( MODULUS_TOKEN );
                                }

                            case '&':   // tokens: & &= && &&=
                                c = nextchar();
                                if (c=='=')
                                    return makeToken( BITWISEANDASSIGN_TOKEN );
                                if (c=='&')
                                {
                                    if (nextchar()=='=')
                                        return makeToken( LOGICALANDASSIGN_TOKEN );
                                    retract();
                                    return makeToken( LOGICALAND_TOKEN );
                                }
                                retract();
                                return makeToken( BITWISEAND_TOKEN );
                        
                            case '#':   // # is short for use
                                if (HAS_HASHPRAGMAS)
                                {
                                    return makeToken( USE_TOKEN );
                                }
                                state = error_state;
                                continue;
                                
                            case '(':
                                return makeToken( LEFTPAREN_TOKEN );
                                
                            case ')':
                                return makeToken( RIGHTPAREN_TOKEN );
                                
                            case '*':   // tokens: *=  *
                                if (nextchar()=='=')
                                    return makeToken( MULTASSIGN_TOKEN );
                                retract();
                                return makeToken( MULT_TOKEN );

                            case ',':
                                return makeToken( COMMA_TOKEN );
                                
                            case '.':
                                state = dot_state;
                                continue;
                                
                            case '/':
                                state = slash_state;
                                continue;

                            case ':':   // tokens: : ::
                                if (nextchar()==':')
                                {
                                    return makeToken( DOUBLECOLON_TOKEN );
                                }
                                retract();
                                return makeToken( COLON_TOKEN );
                             
                            case ';':
                                return makeToken( SEMICOLON_TOKEN );
                                
                            case '?':
                                return makeToken( QUESTIONMARK_TOKEN );
                                
                            case '[':
                                return makeToken( LEFTBRACKET_TOKEN );
                                
                            case ']':
                                return makeToken( RIGHTBRACKET_TOKEN );
                                
                            case '^':   // tokens: ^=  ^
                                if (nextchar()=='=')
                                        return makeToken( BITWISEXORASSIGN_TOKEN );
                                retract();
                                return makeToken( BITWISEXOR_TOKEN );
                                
                            case '{':
                                return makeToken( LEFTBRACE_TOKEN );
                                
                            case '|':   // tokens: | |= || ||=
                                c = nextchar();
                                if (c=='=')
                                    return makeToken( BITWISEORASSIGN_TOKEN );
                                if (c=='|')
                                {
                                    if (nextchar()=='=')
                                        return makeToken( LOGICALORASSIGN_TOKEN );
                                    retract();
                                    return makeToken( LOGICALOR_TOKEN );
                                }
                                retract();
                                return makeToken( BITWISEOR_TOKEN );
                                
                            case '}':
                                return makeToken( RIGHTBRACE_TOKEN );
                                
                            case '~':
                                return makeToken( BITWISENOT_TOKEN );
                                
                            case '+':   // tokens: ++ += +
                                c = nextchar();
                                if (c=='+')
                                    return makeToken( PLUSPLUS_TOKEN );
                                if (c=='=')
                                    return makeToken( PLUSASSIGN_TOKEN );
                                retract();
                                return makeToken( PLUS_TOKEN );
                                
                            case '<':    		
                            	switch (nextchar())
                            	{
                            	case '<':   // tokens: << <<=                                           
                            		if (nextchar()=='=')
                            			return makeToken( LEFTSHIFTASSIGN_TOKEN );
                            		retract();
                            		return makeToken( LEFTSHIFT_TOKEN );

                            	case '=':
                            		return makeToken( LESSTHANOREQUALS_TOKEN );

                            	case '/':  
                            		return makeToken( XMLTAGSTARTEND_TOKEN );
                            	case '!': 
                            		state = xmlcommentorcdatastart_state; 
                            		continue;
                            	case '?': 
                            		state = xmlpi_state; 
                            		continue;                            
                            	}                               
                            	retract();  
                            	return makeToken( LESSTHAN_TOKEN );

                            case '=':   // tokens: === == =
                                if (nextchar()=='=')
                                {
                                    if (nextchar()=='=')
                                        return makeToken( STRICTEQUALS_TOKEN );
                                    retract();
                                    return makeToken( EQUALS_TOKEN );
                                }
                                retract();
                                return makeToken( ASSIGN_TOKEN );
                                
                            case '>':   // tokens: > >= >> >>= >>> >>>=
                                state = start_state;

                                switch ( nextchar() )          
                                {
                                case '>':
                                	switch (nextchar())
                                	{
                                	case '>':
                                		if (nextchar()=='=')
                                			return makeToken( UNSIGNEDRIGHTSHIFTASSIGN_TOKEN );
                                		retract();
                                		return makeToken( UNSIGNEDRIGHTSHIFT_TOKEN );
                                	case '=':
                                		return makeToken( RIGHTSHIFTASSIGN_TOKEN );
                                	default:
                                		retract();
                                		return makeToken( RIGHTSHIFT_TOKEN );
                                	}

                                case '=': 
                                	return makeToken( GREATERTHANOREQUALS_TOKEN );
                                }
                                retract();
                                return makeToken( GREATERTHAN_TOKEN );            
                                
                            case '0':
                                state = zero_state;
                                continue;
                                
                            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                                state = decimalinteger_state;
                                continue;
                                
                            case ' ': // ascii range white space
                            case '\t':
                            case 0x000b:
                            case 0x000c:
                            case 0x0085:    
                            case 0x00a0:
                                continue;

                            case '\n': // ascii line terminators.
                            case '\r':
                                isFirstTokenOnLine = true;
                                continue;
                                
                            case 0:
                                return makeToken( EOS_TOKEN );
                                
                            default:
                                switch (input.nextcharClass((char)c,true))
                                {
                                case Lu: case Ll: case Lt: case Lm: case Lo: case Nl:
                                    maybe_reserved = false;
                                    state = A_state;
                                    continue;

                                case Zs:// unicode whitespace and control-characters
                                case Cc: 
                                case Cf:
                                    continue;

                                case Zl:// unicode line terminators 
                                case Zp:
                                    isFirstTokenOnLine = true;
                                    continue;

                                default:
                                    state = error_state;
                                continue;
                                }
                        }
                    }

                /*
                 * prefix: <letter>
                 */

                case A_state:
                {
                    boolean needs_escape = c == '\\';   // ??? really should only be true if the word started with a backslash
                
                    while ( true ){
                        c = nextchar();
                        if ( c >= 'a' && c <= 'z' )
                        {
                            continue;
                        }
                        if ( (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '$' || c == '_' ){
                            maybe_reserved = false;
                            continue;
                        }
                        if ( c <= 0x7f ) // in ascii range & mostly not a valid char
                        {
                            if ( c == '\\' )
                            {
                                needs_escape = true; // close enough, we just want to minimize rescans for unicode escapes
                            }
                            else {
                                retract();
                                break;
                            }
                        }

                        // else outside ascii range (or an escape sequence )
                        
                        switch (input.nextcharClass(c,false))
                        {
                        case Lu: case Ll: case Lt: case Lm: case Lo: case Nl: case Mn: case Mc: case Nd: case Pc:
                            maybe_reserved = false;
                            input.nextcharClass(c,true); // advance input cursor
                            continue;
                        }
                        
                        retract();
                        break;
                    }
                    
                    state = start_state;   
                    String s = input.copyReplaceUnicodeEscapes(needs_escape); 
                    if ( maybe_reserved )
                    {
                        Integer i = reservedWord.get(s); 
                        if ( i != null )
                            return makeToken( (int) i );
                    }
                    return makeToken(IDENTIFIER_TOKEN,s);
                }
                
                /*
                 * prefix: 0
                 * accepts: 0x... | 0X... | 01... | 0... | 0
                 */

                case zero_state:
                    switch (nextchar())
                    {
                    case 'x':
                    case 'X':
                        switch(nextchar())
                        {
                        case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                        case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'A': case 'B': case 'C': case 'D': 
                        case 'E': case 'F':
                            state = hexinteger_state;
                            break;
                        default:
                            state = start_state;
                        error(kError_Lexical_General); 
                        }
                        continue;

                    case '.':
                        state = decimal_state;
                        continue;
                        
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                        state = decimalinteger_state;
                        continue;
                    case 'E':
                    case 'e':
                        state = exponentstart_state;
                        continue;
                    case 'd':
                    case 'm':
                    case 'i':
                    case 'u':
                        if (!ctx.statics.es4_numerics)
                            retract();
                        state = start_state;
                        return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    default:
                        retract();
                    state = start_state;
                    return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    }

                    /*
                     * prefix: 0x<hex digits>
                     * accepts: 0x123f
                     */

                case hexinteger_state:
                    switch (nextchar())
                    {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                    case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'A': case 'B': case 'C': case 'D': 
                    case 'E': case 'F':
                        state = hexinteger_state;
                        continue;
                    case 'u':
                    case 'i':
                        if (!ctx.statics.es4_numerics)
                            retract();
                        state = start_state; 
                        return makeToken( NUMBERLITERAL_TOKEN, input.copy() );
                    default:  
                        retract();
                    state = start_state; 
                    return makeToken( NUMBERLITERAL_TOKEN, input.copy() );
                    }

                    /*
                     * prefix: .
                     * accepts: .123 | .
                     */

                case dot_state:
                    switch (nextchar())
                    {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                        state = decimal_state;
                        continue;

                    case '.':
                        state = start_state;
                        if (nextchar()=='.')
                            return makeToken( TRIPLEDOT_TOKEN );
                        retract();
                        return makeToken( DOUBLEDOT_TOKEN );

                    case '<':
                        state = start_state;
                        return makeToken( DOTLESSTHAN_TOKEN );

                    default:
                        retract();
                    state = start_state;
                    return makeToken( DOT_TOKEN );
                    }

                    /*
                     * prefix: N
                     * accepts: 0.123 | 1.23 | 123 | 1e23 | 1e-23
                     */

                case decimalinteger_state:
                    switch (nextchar())
                    {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                        state = decimalinteger_state;
                        continue;
                    case '.':
                        state = decimal_state;
                        continue;
                    case 'd':
                    case 'm':
                    case 'u':
                    case 'i':
                        if (!ctx.statics.es4_numerics)
                            retract();
                        state = start_state;
                        return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    case 'E':
                    case 'e':
                        state = exponentstart_state;
                        continue;
                    default:
                        retract();
                    state = start_state;
                    return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    }

                    /*
                     * prefix: N.
                     * accepts: 0.1 | 1e23 | 1e-23
                     */

                case decimal_state:
                    switch (nextchar())
                    {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                        state = decimal_state;
                        continue;
                    case 'd':
                    case 'm':
                        if (!ctx.statics.es4_numerics)
                            retract();
                        state = start_state;
                        return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    case 'E':
                    case 'e':
                        state = exponentstart_state;
                        continue;
                    default:
                        retract();
                    state = start_state;
                    return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    }

                    /*
                     * prefix: ..e
                     * accepts: ..eN | ..e+N | ..e-N
                     */

                case exponentstart_state:
                    switch (nextchar())
                    {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                    case '+':
                    case '-':
                        state = exponent_state;
                        continue;
                    default:
                        error(kError_Lexical_General);
                    state = start_state;
                    continue;
                    // Issue: needs specific error here.
                    }

                    /*
                     * prefix: ..e
                     * accepts: ..eN | ..e+N | ..e-N
                     */

                case exponent_state:
                    switch (nextchar())
                    {
                    case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': 
                        state = exponent_state;
                        continue;
                    case 'd':
                    case 'm':
                        if (!ctx.statics.es4_numerics)
                            retract();
                        state = start_state;
                        return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    default:
                        retract();
                    state = start_state;
                    return makeToken(NUMBERLITERAL_TOKEN, input.copy());
                    }

                    /*
                     * prefix: /
                     */

                case slash_state:
                {
                	c = nextchar();

                	switch (c)
                	{   
                	case '/': // line comment
                		state = start_state;
                		line_comment: 
                			while ( (c=nextchar()) != 0)
                			{
                				if ( c == '\r' || c == '\n' )
                				{
                					isFirstTokenOnLine = true;
                					if (save_comments == false)
                					{
                						break line_comment;
                					}
                					retract(); // don't include newline in line comment. (Sec 7.3)
                					return makeCommentToken( SLASHSLASHCOMMENT_TOKEN, input.copyReplaceUnicodeEscapes() );
                				}
                			}
                		continue;

                	case '*':
                		if (save_comments == false)
                		{
                			block_comment:
                				while ( (c=nextchar()) != 0)
                				{
                					if ( c == '\r' || c == '\n' )
                						isFirstTokenOnLine = true;

                					if (c == '*')
                					{
                						c = nextchar();
                						if (c == '/' )
                						{
                							break block_comment;
                						}
                						retract();
                					}   
                				}
                		state = start_state;
                		}
                		else 
                		{
                			if (blockcommentbuf == null) 
                				blockcommentbuf = new StringBuilder();
                			blockcommentbuf.append("/*");
                			state = blockcommentstart_state;
                		}
                		continue;

                	case '>': 
               			if ( inXML > 0) // ignore this if outside an XML context 
               			{
               				state = start_state;
               				return makeToken( XMLTAGENDEND_TOKEN );
               			}
               			// FALL THROUGH
                	default:
                		// If the last token read is any of these, then the '/' must start a div or div_assign...

                		int lb = currentToken.lookback;
                	
                		if ( lb == IDENTIFIER_TOKEN || lb == NUMBERLITERAL_TOKEN || lb == RIGHTPAREN_TOKEN ||
                		     lb == RIGHTBRACE_TOKEN || lb == RIGHTBRACKET_TOKEN )
                		{
                			/*
                			 * tokens: /= /
                			 */

                			state = start_state; 
                			if (c=='=')
                				return makeToken( DIVASSIGN_TOKEN );
                			retract();
                			return makeToken( DIV_TOKEN );	
                		}
                		state = slashregexp_state;
                		retract();
                		continue;
                	}
                }

                /*
                 * tokens: /<regexpbody>/<regexpflags>
                 */

                case slashregexp_state:
                    switch (nextchar())
                    {
                    case '\\': 
                        nextchar(); 
                        continue;
                    case '/':
                        regexp_flags = 0;
                        state = regexp_state;
                        continue;
                    case 0:
                    case '\n':
                    case '\r':
                        error(kError_Lexical_General);
                        state = start_state;
                        continue;
                    default:
                        state = slashregexp_state;
                    continue;
                    }

                /*
                * tokens: g | i | m | s | x  .  Note that s and x are custom extentions to match perl's functionality
                *   Also note we handle this via an array of boolean flags intead of state change logic.
                *   (5,1) + (5,2) + (5,3) + (5,4) + (5,5) is just too many states to handle this via state logic
                */

                case regexp_state:
                    c = nextchar();
                    switch ( c )
                    {
                    case 'g': 
                        if ((regexp_flags & 0x01) == 0)
                        {
                            regexp_flags |= 0x01;
                            continue;
                        }
                        error(kError_Lexical_General); 
                        state = start_state; 
                        continue;

                    case 'i': 
                        if ((regexp_flags & 0x02) == 0)
                        {
                            regexp_flags |= 0x02;
                            continue;
                        }
                        error(kError_Lexical_General); 
                        state = start_state; 
                        continue;

                    case 'm': 
                        if ((regexp_flags & 0x04) == 0)
                        {
                            regexp_flags |= 0x04;
                            continue;
                        }
                        error(kError_Lexical_General); 
                        state = start_state; 
                        continue;

                    case 's':
                        if ((regexp_flags & 0x08) == 0)
                        {
                            regexp_flags |= 0x08;
                            continue;
                        }
                        error(kError_Lexical_General); 
                        state = start_state; 
                        continue;

                    case 'x':
                        if ((regexp_flags & 0x10) == 0)
                        {
                            regexp_flags |= 0x10;
                            continue;
                        }
                        error(kError_Lexical_General); 
                        state = start_state; 
                        continue;

                    default: 
                        if (Character.isJavaIdentifierPart(c))
                        {
                            error(kError_Lexical_General); 
                            state = start_state; 
                            continue; 
                        }
                    retract(); 
                    state = start_state; 
                    return makeToken( REGEXPLITERAL_TOKEN, input.copyReplaceUnicodeEscapes());
                    }

                /*
                 * prefix: <!
                 */
                    
                case xmlcommentorcdatastart_state:
                    switch ( nextchar() )        
                    {
                    case '[':  
                        if (nextchar()=='C' &&
                            nextchar()=='D' &&
                            nextchar()=='A' &&
                            nextchar()=='T' &&
                            nextchar()=='A' &&
                            nextchar()=='[')
                        {
                            state = xmlcdata_state; 
                            continue;
                        }
                        break; // error

                    case '-':  
                        if (nextchar()=='-')
                        {
                            state = xmlcomment_state; 
                            continue;
                        }
                    }    
                    error(kError_Lexical_General); 
                    state = start_state; 
                    continue;

                case xmlcdata_state:
                    switch ( nextchar() )         
                    {
                    case ']':
                        if (nextchar()==']' && nextchar()=='>')
                        {
                            state = start_state;
                            return makeToken(XMLMARKUP_TOKEN,input.substringReplaceUnicodeEscapes(startofxml,pos()));
                        }
                        continue;

                    case 0:   
                        error(kError_Lexical_General); 
                        state = start_state;
                    }
                    continue;

                case xmlcomment_state:
                    while ( (c=nextchar()) != '-' && c != 0 )
                        ;
                    
                    if (c=='-' && nextchar() != '-')
                    {
                        continue;
                    }
                    
                    // got -- if next is > ok else error
                    
                    if ( nextchar()=='>')
                    {
                        state = start_state;
                        return makeToken(XMLMARKUP_TOKEN,input.substringReplaceUnicodeEscapes(startofxml,pos())); 
                    }
                    
                    error(kError_Lexical_General); 
                    state = start_state;
                    continue;

                case xmlpi_state:
                    while ( (c=nextchar()) != '?' && c != 0 )
                        ;
                    
                    if (c=='?' && nextchar() == '>')
                    {
                        state = start_state;
                        return makeToken(XMLMARKUP_TOKEN,input.substringReplaceUnicodeEscapes(startofxml,pos()));  
                    }

                    if (c==0)
                    {
                        error(kError_Lexical_General); 
                        state = start_state;   
                    }
                    continue;

                case xmltext_state:
                { 
                    switch(nextchar())
                    {
                    case '<': case '{':  
                    {
                        retract();
                        String xmltext = input.substringReplaceUnicodeEscapes(startofxml,pos());
                        if( xmltext != null )
                        {
                            state = start_state;
                            return makeToken(XMLTEXT_TOKEN,xmltext);
                        }
                        else  // if there is no leading text, then just return punctuation token to avoid empty text tokens
                        {
                            switch(nextchar()) 
                            {
                            case '<': 
                                switch( nextchar() )
                                {
                                case '/': state = start_state; return makeToken( XMLTAGSTARTEND_TOKEN );
                                case '!': state = xmlcommentorcdatastart_state; continue;
                                case '?': state = xmlpi_state; continue;
                                default: retract(); state = start_state; return makeToken( LESSTHAN_TOKEN );
                                }
                            case '{': 
                                state = start_state; 
                                return makeToken( LEFTBRACE_TOKEN );
                            }
                        }
                    }
                    case 0:   
                        state = start_state; 
                        return makeToken( EOS_TOKEN );
                    }
                    continue;
                }

                case xmlliteral_state:
                    switch (nextchar())
                    {
                    case '{':  // return makeToken( XMLPART_TOKEN
                        return makeToken(XMLPART_TOKEN, input.substringReplaceUnicodeEscapes(startofxml, pos()-1));

                    case '<':
                    	if (nextchar()=='/')
                    	{
                    		--level;
                    		nextchar();
                    		mark();
                    		retract();
                    		state = endxmlname_state;
                    	}
                    	else 
                    	{
                    		++level;
                    		state = xmlliteral_state;
                    	}
                    	continue;

                    case '/':
                        if (nextchar()=='>')
                        {
                            --level;
                            if (level == 0)
                            {
                                state = start_state;
                                return makeToken(XMLLITERAL_TOKEN, input.substringReplaceUnicodeEscapes(startofxml, pos()+1)); 
                            }
                        }
                        continue;

                    case 0:
                        retract();
                        error(kError_Lexical_NoMatchingTag);
                        state = start_state;
                        continue;

                    default:
                        continue;
                    }

                case endxmlname_state:
                    c = nextchar();
                    if (Character.isJavaIdentifierPart(c)||c==':')
                    {
                        continue;
                    }
                    
                    switch(c)
                    {
                    case '{':  // return makeToken( XMLPART_TOKEN
                    {
                        String xmltext = input.substringReplaceUnicodeEscapes(startofxml, pos()-1);
                        return makeToken(XMLPART_TOKEN, xmltext);
                    }
                    case '>':
                        retract();
                        nextchar();
                        if (level == 0)
                        {
                            String xmltext = input.substringReplaceUnicodeEscapes(startofxml, pos()+1);
                            state = start_state;
                            return makeToken(XMLLITERAL_TOKEN, xmltext);
                        }
                        state = xmlliteral_state;
                        continue;

                    default:
                        state = xmlliteral_state;
                        continue;
                    }

               /*
                * prefix: /*
                */

                case blockcommentstart_state:
                {
                    c = nextchar();
                    blockcommentbuf.append(c);
                    switch ( c )
                    {
                    case '*':
                        if ( nextchar() == '/' ){
                            state = start_state;
                            return makeCommentToken( BLOCKCOMMENT_TOKEN, new String());
                        }
                        retract(); 
                        state = doccomment_state; 
                        continue;
                        
                    case 0:    
                        error(kError_BlockCommentNotTerminated); 
                        state = start_state; 
                        continue;
                        
                    case '\n': 
                    case '\r':
                        isFirstTokenOnLine = true; 
                    default:
                        state = blockcomment_state;
                        continue;
                    }
                }

                /*
                 * prefix: /**
                 */

                case doccomment_state:
                {
                    c = nextchar();
                    blockcommentbuf.append(c);
                    switch ( c )
                    {
                    case '*':  
                        state = doccommentstar_state; 
                        continue;
                    
                    case '@':
                        if (doctextbuf == null) 
                            doctextbuf = getDocTextBuffer(doctagname);
                        if( doctagname.length() > 0 ) 
                        { 
                            doctextbuf.append("]]></").append(doctagname).append(">"); 
                        }
                        doctagname = "";
                        state = doccommenttag_state; 
                        continue;
                        
                    case '\r': 
                    case '\n': 
                        isFirstTokenOnLine = true;
                        if (doctextbuf == null) 
                            doctextbuf = getDocTextBuffer(doctagname);
                        doctextbuf.append('\n');
                        continue;
                    
                    case 0:    
                        error(kError_BlockCommentNotTerminated); 
                        state = start_state; 
                        continue;
                        
                    default:
                        if (doctextbuf == null) 
                            doctextbuf = getDocTextBuffer(doctagname);
                        doctextbuf.append((char)(c));  
                        continue;
                    }
                }

                case doccommentstar_state:
                {
                    c = nextchar();
                    blockcommentbuf.append(c);
                    switch ( c )                    
                    {
                    case '/':
                    {
                        if (doctextbuf == null) 
                            doctextbuf = getDocTextBuffer(doctagname);
                        if( doctagname.length() > 0 ) 
                        { 
                            doctextbuf.append("]]></").append(doctagname).append(">"); 
                        }
                        String doctext = doctextbuf.toString(); // ??? does this needs escape conversion ???
                        state = start_state; 
                        return makeCommentToken(DOCCOMMENT_TOKEN,doctext);
                    }

                    case '*':  
                        continue;
                    
                    case 0:    
                        error(kError_BlockCommentNotTerminated); 
                        state = start_state; 
                        continue;
                    
                    default:   
                        state = doccomment_state; 
                        continue;
                    // if not a slash, then keep looking for an end comment.
                    }
                }

                /*
                * prefix: @
                */

                case doccommenttag_state:
                {
                    c = nextchar();
                    switch ( c )
                    {
                    case '*':  
                        state = doccommentstar_state; 
                        continue;

                    case ' ': case '\t': case '\r': case '\n': 
                    {
                        if (doctextbuf == null) 
                            doctextbuf = getDocTextBuffer(doctagname);

                        // skip extra whitespace --fixes bug on tag text parsing 
                        // --but really, the problem is not here, it's in whatever reads asdoc output..
                        // --So if that gets fixed, feel free to delete the following.

                        while ( (c=nextchar()) == ' ' || c == '\t' )
                            ;
                        retract();

                        if( doctagname.length() > 0 ) 
                        { 
                            doctextbuf.append("\n<").append(doctagname).append("><![CDATA["); 
                        }
                        state = doccomment_state; 
                        continue;
                    }

                    case 0:    
                        error(kError_BlockCommentNotTerminated); 
                        state = start_state; 
                        continue;

                    default:   
                        doctagname += (char)(c); 
                    continue;
                    }
                }

                /*
                 * prefix: /**
                 */

                case doccommentvalue_state:
                    switch ( nextchar() )
                    {
                    case '*':  
                        state = doccommentstar_state; 
                        continue;

                    case '@':  
                        state = doccommenttag_state; 
                        continue;

                    case 0:    
                        error(kError_BlockCommentNotTerminated); 
                        state = start_state; 
                        continue;

                    default:   
                        state = doccomment_state; 
                    continue;
                    }

                /*
                * prefix: /*
                */

                case blockcomment_state:
                {
                    c = nextchar();
                    blockcommentbuf.append(c);
                    switch ( c )                    
                    {
                    case '*': 
                    	c = nextchar();
                    	if (c == '/')
                    	{
                            state = start_state;
                            blockcommentbuf.append(c);
                            String blocktext = blockcommentbuf.toString(); // ??? needs escape conversion
                            return makeCommentToken( BLOCKCOMMENT_TOKEN, blocktext );
                    	}
                    	retract();
                    	break;
                    	
                    case '\r': case '\n': 
                    	isFirstTokenOnLine = true; 
                    	break;
                    
                    case 0:    
                    	error(kError_BlockCommentNotTerminated); 
                    	state = start_state; 
                    	break;
                    }
                    continue;
                }

                /*
                 * skip error
                 */

                case error_state:
                    error(kError_Lexical_General);
                    skiperror();
                    state = start_state;
                    continue;

                default:
                    error("invalid scanner state");
                    state = start_state;
                    return makeToken(EOS_TOKEN);
            }
        }
    }
}
