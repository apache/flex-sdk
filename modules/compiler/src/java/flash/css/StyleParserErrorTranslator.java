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

package flash.css;

import org.apache.flex.forks.batik.css.parser.LexicalUnits;

import java.text.MessageFormat;
import flex2.compiler.util.CompilerMessage.CompilerError;

/**
 * A helper class used to translate some Batik error messages into
 * more friendly messages.
 *
 * @author Paul Reilly
 */
public class StyleParserErrorTranslator
{
    public static String getUserFriendlyErrror(String batikMessage) {

        String userFriendlyMessage = batikMessage;

        try {
            if (batikMessage.startsWith("Unexpected token:")) {
                MessageFormat batikMessageFormat = new MessageFormat("Unexpected token: {0,number,integer} (see LexicalUnits).");
                Object tokens[] = batikMessageFormat.parse(batikMessage);
                int errorCode = ((Long)tokens[0]).intValue();

                switch (errorCode) {
                    case LexicalUnits.ANY:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("*").getLocalizedMessage();
                        break;
                    case LexicalUnits.AT_KEYWORD:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("@ident").getLocalizedMessage();
                        break;
                    case LexicalUnits.CDC:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("-->").getLocalizedMessage();
                        break;
                    case LexicalUnits.CDO:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("'").getLocalizedMessage();
                        break;
                    case LexicalUnits.EOF:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("EOF").getLocalizedMessage();
                        break;
                    case LexicalUnits.LEFT_CURLY_BRACE:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("{").getLocalizedMessage();
                        break;
                    case LexicalUnits.RIGHT_CURLY_BRACE:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("}").getLocalizedMessage();
                        break;
                    case LexicalUnits.EQUAL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("=").getLocalizedMessage();
                        break;
                    case LexicalUnits.PLUS:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("+").getLocalizedMessage();
                        break;
                    case LexicalUnits.MINUS:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("-").getLocalizedMessage();
                        break;
                    case LexicalUnits.COMMA:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken(",").getLocalizedMessage();
                        break;
                    case LexicalUnits.DOT:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken(".").getLocalizedMessage();
                        break;
                    case LexicalUnits.SEMI_COLON:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken(";").getLocalizedMessage();
                        break;
                    case LexicalUnits.PRECEDE:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken(">").getLocalizedMessage();
                        break;
                    case LexicalUnits.DIVIDE:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("/").getLocalizedMessage();
                        break;
                    case LexicalUnits.LEFT_BRACKET:
                    	userFriendlyMessage = new InvalidCSSSyntaxArray("[").getLocalizedMessage();
                        break;
                    case LexicalUnits.RIGHT_BRACKET:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("]").getLocalizedMessage();
                        break;
                    case LexicalUnits.LEFT_BRACE:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("(").getLocalizedMessage();
                        break;
                    case LexicalUnits.RIGHT_BRACE:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken(")").getLocalizedMessage();
                        break;
                    case LexicalUnits.COLON:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken(":").getLocalizedMessage();
                        break;
                    case LexicalUnits.SPACE:
                    	userFriendlyMessage = new InvalidCSSSyntax("space").getLocalizedMessage();
                        break;
                    case LexicalUnits.COMMENT:
                    	userFriendlyMessage = new InvalidCSSSyntax("comment").getLocalizedMessage();
                        break;
                    case LexicalUnits.STRING:
                    	userFriendlyMessage = new InvalidCSSSyntax("string").getLocalizedMessage();
                        break;
                    case LexicalUnits.IDENTIFIER:
                    	userFriendlyMessage = new InvalidCSSSyntax("identifier").getLocalizedMessage();
                        break;
                    case LexicalUnits.IMPORTANT_SYMBOL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("!important").getLocalizedMessage();
                        break;
                    case LexicalUnits.INTEGER:
                    	userFriendlyMessage = new InvalidCSSSyntax("integer").getLocalizedMessage();
                        break;
                    case LexicalUnits.DASHMATCH:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("|=").getLocalizedMessage();
                        break;
                    case LexicalUnits.INCLUDES:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("~=").getLocalizedMessage();
                        break;
                    case LexicalUnits.HASH:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("#").getLocalizedMessage();
                        break;
                    case LexicalUnits.IMPORT_SYMBOL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("@import").getLocalizedMessage();
                        break;
                    case LexicalUnits.CHARSET_SYMBOL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("@charset").getLocalizedMessage();
                        break;
                    case LexicalUnits.FONT_FACE_SYMBOL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("@font-face").getLocalizedMessage();
                        break;
                    case LexicalUnits.MEDIA_SYMBOL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("@media").getLocalizedMessage();
                        break;
                    case LexicalUnits.PAGE_SYMBOL:
                    	userFriendlyMessage = new InvalidCSSSyntaxToken("@page").getLocalizedMessage();
                        break;
                    case LexicalUnits.DIMENSION:
                    	userFriendlyMessage = new InvalidCSSSyntax("dimension").getLocalizedMessage();
                        break;
                    case LexicalUnits.EX:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("ex").getLocalizedMessage();
                        break;
                    case LexicalUnits.EM:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("em").getLocalizedMessage();
                        break;
                    case LexicalUnits.CM:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("cm").getLocalizedMessage();
                        break;
                    case LexicalUnits.MM:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("mm").getLocalizedMessage();
                        break;
                    case LexicalUnits.IN:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("in").getLocalizedMessage();
                        break;
                    case LexicalUnits.MS:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("ms").getLocalizedMessage();
                        break;
                    case LexicalUnits.HZ:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("hz").getLocalizedMessage();
                        break;
                    case LexicalUnits.PERCENTAGE:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("percentage").getLocalizedMessage();
                        break;
                    case LexicalUnits.S:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("S").getLocalizedMessage();
                        break;
                    case LexicalUnits.PC:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("pc").getLocalizedMessage();
                        break;
                    case LexicalUnits.PT:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("pt").getLocalizedMessage();
                        break;
                    case LexicalUnits.PX:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("px").getLocalizedMessage();
                        break;
                    case LexicalUnits.DEG:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("deg").getLocalizedMessage();
                        break;
                    case LexicalUnits.RAD:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("rad").getLocalizedMessage();
                        break;
                    case LexicalUnits.GRAD:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("grad").getLocalizedMessage();
                        break;
                    case LexicalUnits.KHZ:
                    	userFriendlyMessage = new InvalidCSSSyntaxUnits("khz").getLocalizedMessage();
                        break;
                    case LexicalUnits.URI:
                    	userFriendlyMessage = new InvalidCSSSyntax("URI").getLocalizedMessage();
                        break;
                    case LexicalUnits.FUNCTION:
                    	userFriendlyMessage = new InvalidCSSSyntax("identifier").getLocalizedMessage();
                        break;
                    case LexicalUnits.UNICODE_RANGE:
                    	userFriendlyMessage = new InvalidCSSSyntax("unicode range").getLocalizedMessage();
                        break;
                    case LexicalUnits.REAL:
                    	userFriendlyMessage = new InvalidCSSSyntax("real number").getLocalizedMessage();
                        break;
                }
            }
            else if (batikMessage.equals("Invalid identifier start character: _.")) {
            	userFriendlyMessage = new InvalidIdentifierStartChar().getLocalizedMessage();
            }
            else if (batikMessage.equals("character") || batikMessage.equals("identifier.character")) {
            	userFriendlyMessage = new UnableToParse().getLocalizedMessage();
            }
        } catch (Exception e) {
            // just returns the original message
        }

        return userFriendlyMessage;
    }
    
    public static class InvalidIdentifierStartChar extends CompilerError
    {
    	private static final long serialVersionUID = 2254406474080898001L;
    }
    
    public static class UnableToParse extends CompilerError
    {
    	private static final long serialVersionUID = 2254406474080898033L;
    }
    
    public static class InvalidCSSSyntaxToken extends CompilerError
    {
    	private static final long serialVersionUID = 2254406474080898002L;
    	public String token;
        public InvalidCSSSyntaxToken(String token) { this.token = token; }
    }
    
    public static class InvalidCSSSyntax extends CompilerError
    {
    	private static final long serialVersionUID = 2254406474080898003L;
    	public String token;
        public InvalidCSSSyntax(String token) { this.token = token; }
    }
    
    public static class InvalidCSSSyntaxArray extends CompilerError
    {
    	private static final long serialVersionUID = 2254406474080898004L;
    	public String token;
        public InvalidCSSSyntaxArray(String token) { this.token = token; }
    }
    
    public static class InvalidCSSSyntaxUnits extends CompilerError
    {
    	private static final long serialVersionUID = 2254406474080898005L;
    	public String token;
        public InvalidCSSSyntaxUnits(String token) { this.token = token; }
    }
    
}


