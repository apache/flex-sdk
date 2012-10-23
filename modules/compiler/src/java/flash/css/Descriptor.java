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

import flash.util.Trace;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.ThreadLocalToolkit;
import org.apache.flex.forks.batik.css.parser.CSSLexicalUnit;
import org.w3c.css.sac.LexicalUnit;

/**
 * This class represents a descriptor/property within a CSS rule
 * declaration.
 *
 * @author Peter Farland
 * @author Paul Reilly
 */
public class Descriptor
{
	private String name;
	private LexicalUnit value;
    private int lineNumber;
    private String path;

	public Descriptor(String name, LexicalUnit lexicalUnit, String path)
	{
		this.name = name;
		this.value = lexicalUnit;
        assert path != null;
        this.path = path;

        if (lexicalUnit instanceof CSSLexicalUnit)
        {
            lineNumber = ((CSSLexicalUnit) lexicalUnit).getLineNumber();
        }
	}

    /**
     * Converts one of the sixteen colors defined in
     * http://www.w3.org/TR/REC-html40/types.html#h-6.5 to the
     * 0x000000 format.
     */
    public static String convertColorName(String color)
    {
        if (color.length() != 0)
        {
            switch (color.charAt(0))
            {
            case 'b': case 'B':
                if (color.equalsIgnoreCase("black"))
                {
                    return "0x000000";
                }
                if (color.equalsIgnoreCase("blue"))
                {
                    return "0x0000FF";
                }
                break;
            case 'g': case 'G':
                if (color.equalsIgnoreCase("green"))
                {
                    return "0x008000";
                }
                if (color.equalsIgnoreCase("gray"))
                {
                    return "0x808080";
                }
                break;
            case 's': case 'S':
                if (color.equalsIgnoreCase("silver"))
                {
                    return "0xC0C0C0";
                }
                break;
            case 'l': case 'L':
                if (color.equalsIgnoreCase("lime"))
                {
                    return "0x00FF00";
                }
                break;
            case 'o': case 'O':
                if (color.equalsIgnoreCase("olive"))
                {
                    return "0x808000";
                }
                break;
            case 'w': case 'W':
                if (color.equalsIgnoreCase("white"))
                {
                    return "0xFFFFFF";
                }
                break;
            case 'y': case 'Y':
                if (color.equalsIgnoreCase("yellow"))
                {
                    return "0xFFFF00";
                }
                break;
            case 'm': case 'M':
                if (color.equalsIgnoreCase("maroon"))
                {
                    return "0x800000";
                }
                if (color.equalsIgnoreCase("magenta"))
                {
                    // nonstandard color used by appmodel.  See mx.styles.StyleManager.colorNames[]
                    return "0xFF00FF";
                }
                break;
            case 'n': case 'N':
                if (color.equalsIgnoreCase("navy"))
                {
                    return "0x000080";
                }
                break;
            case 'r': case 'R':
                if (color.equalsIgnoreCase("red"))
                {
                    return "0xFF0000";
                }
                break;
            case 'p': case 'P':
                if (color.equalsIgnoreCase("purple"))
                {
                    return "0x800080";
                }
                break;
            case 't': case 'T':
                if (color.equalsIgnoreCase("teal"))
                {
                    return "0x008080";
                }
                break;
            case 'f': case 'F':
                if (color.equalsIgnoreCase("fuchsia"))
                {
                    return "0xFF00FF";
                }
                break;
            case 'a': case 'A':
                if (color.equalsIgnoreCase("aqua"))
                {
                    return "0x00FFFF";
                }
                break;
            case 'c': case 'C':
                if (color.equalsIgnoreCase("cyan"))
                {
                    // nonstandard color used by appmodel.  See mx.styles.StyleManager.colorNames[]
                    return "0x00FFFF";
                }
                break;
            case 'h': case 'H':
            	//
				// IMPORTANT: Theme colors must be updated in the following places:
				//  1). In _global.style (near the top of Defaults.as)
				//	2). In function setThemeStyle (near the bottom of Defaults.as)
				//	3). In StyleManager colorNames (in the middle of StyleManager.as)
				//	4). In the Flex compiler CSS parser (in \src\java\macromedia\css\Descriptor.java)
				//
                if (color.equalsIgnoreCase("haloGreen"))
                {
                    // nonstandard color used by appmodel.  See mx.styles.StyleManager.colorNames[]
                    return "0x80FF4D";
                }
                if (color.equalsIgnoreCase("haloBlue"))
                {
                    // nonstandard color used by appmodel.  See mx.styles.StyleManager.colorNames[]
                    return "0x009DFF";
                }
                if (color.equalsIgnoreCase("haloOrange"))
                {
                    // nonstandard color used by appmodel.  See mx.styles.StyleManager.colorNames[]
                    return "0xFFB600";
                }
                if (color.equalsIgnoreCase("haloSilver"))
      			{
                    // nonstandard color used by appmodel.  See mx.styles.StyleManager.colorNames[]
                    return "0xAECAD9";
				}
                break;
            }
        }

        return null;
    }

	public String getName()
	{
		return name;
	}

	public LexicalUnit getValue()
	{
		return value;
	}

	public String getIdentAsString()
	{
		StringBuilder sb = new StringBuilder();
		LexicalUnit lexicalUnit = value;

		while (lexicalUnit != null)
		{
			try
			{
				switch(lexicalUnit.getLexicalUnitType())
				{
					case LexicalUnit.SAC_IDENT:
						sb.append(lexicalUnit.getStringValue());
						break;
					case LexicalUnit.SAC_OPERATOR_COMMA:
						sb.append(',');
						break;
					case LexicalUnit.SAC_INTEGER:
						sb.append(lexicalUnit.getIntegerValue());
						break;
					default:
						sb.append(lexicalUnit.getStringValue());
						break;
				}
			}
			catch(IllegalStateException ise)
			{
				UnparsableCSS unparsableCSS = new UnparsableCSS();
				unparsableCSS.path = path;
				unparsableCSS.line = lineNumber;
				ThreadLocalToolkit.log(unparsableCSS);
			}

			lexicalUnit = lexicalUnit.getNextLexicalUnit();
		}

		return sb.toString();
	}

	public String getColorAsString() throws CompilerError
	{
        return getColorAsString(name, value);
    }

	private static String getColorAsString(String name, LexicalUnit lexicalUnit) throws CompilerError
	{
        String color;

        short type = lexicalUnit.getLexicalUnitType();

        switch(type)
        {
        case LexicalUnit.SAC_IDENT:
            {
                color = convertColorName( lexicalUnit.getStringValue() );

                if (color == null)
                {
                    throw new ColorNotSupported(lexicalUnit.getStringValue());
                }

                break;
            }
        case LexicalUnit.SAC_RGBCOLOR:
            {
                StringBuilder stringBuffer = new StringBuilder("0x");

                LexicalUnit parameter = lexicalUnit.getParameters();

                while (parameter != null)
                {
                    int digit;

                    switch(parameter.getLexicalUnitType())
                    {
                    case LexicalUnit.SAC_INTEGER:
                        {
                            digit = parameter.getIntegerValue();
                            stringBuffer.append(Character.forDigit((digit >> 4) & 15, 16));
                            stringBuffer.append(Character.forDigit(digit & 15, 16));
                            break;
                        }
                    case LexicalUnit.SAC_PERCENTAGE:
                        {
                            digit = ((new Float(parameter.getFloatValue())).intValue() * 255) / 100;
                            stringBuffer.append(Character.forDigit((digit >> 4) & 15, 16));
                            stringBuffer.append(Character.forDigit(digit & 15, 16));
                            break;
                        }
                    }

                    parameter = parameter.getNextLexicalUnit();
                }

                color = stringBuffer.toString();
                break;
            }
        default:
            {
                if (Trace.css)
                {
                    Trace.trace("Descriptor.getColorAsString: type = " + type);
                }
                throw new ValueNotSupported(name);
            }
        }

		return color;
	}

    public String getLengthAsString() throws CompilerError
    {
        return getLengthAsString(name, value);
    }

    private static String getLengthAsString(String name, LexicalUnit lexicalUnit)
        throws CompilerError
    {
        float length;

        short type = lexicalUnit.getLexicalUnitType();

        switch(type)
        {
        case LexicalUnit.SAC_CENTIMETER:
            {
                length = (lexicalUnit.getFloatValue() * 72) / 2.54F;
                break;
            }
        case LexicalUnit.SAC_MILLIMETER:
            {
                length = ((lexicalUnit.getFloatValue() * 72) / 10) / 2.54F;
                break;
            }
        case LexicalUnit.SAC_INCH:
            {
                length = lexicalUnit.getFloatValue() * 72;
                break;
            }
        case LexicalUnit.SAC_PICA:
            {
                length = lexicalUnit.getFloatValue() * 12;
                break;
            }
        case LexicalUnit.SAC_PIXEL:
            {
                length = lexicalUnit.getFloatValue();
                break;
            }
        case LexicalUnit.SAC_POINT:
            {
                length = lexicalUnit.getFloatValue();
                break;
            }
        case LexicalUnit.SAC_IDENT:
            {
                String absoluteSize = lexicalUnit.getStringValue();

                if ( absoluteSize.equalsIgnoreCase("xx-small") )
                {
                    length = 7; // (12 / 1.2 / 1.2 / 1.2)
                }
                else if ( absoluteSize.equalsIgnoreCase("x-small") )
                {
                    length = 8; // (12 / 1.2 / 1.2)
                }
                else if ( absoluteSize.equalsIgnoreCase("small") )
                {
                    length = 10; // (12 / 1.2)
                }
                else if ( absoluteSize.equalsIgnoreCase("medium") )
                {
                    length = 12;
                }
                else if ( absoluteSize.equalsIgnoreCase("large") )
                {
                    length = 14; // (12 * 1.2)
                }
                else if ( absoluteSize.equalsIgnoreCase("x-large") )
                {
                    length = 17; // (12 * 1.2 * 1.2)
                }
                else if ( absoluteSize.equalsIgnoreCase("xx-large") )
                {
                    length = 21; // (12 * 1.2 * 1.2 * 1.2)
                }
                else
                {
                    throw new ValueNotSupported(name);
                }
                break;
            }
        default:
            {
                if (Trace.css)
                {
                    Trace.trace("Descriptor.getLengthAsString: type = " + type);
                }
                throw new ValueNotSupported(name);
            }
        }

		return Integer.toString(((new Float(length)).intValue()));
    }

    public int getLineNumber()
    {
        return lineNumber;
    }

    private static String getListAsString(String name, LexicalUnit value)
        throws CompilerError
    {
        return getListAsString(name, value, true);
    }

    private static String getListAsString(String name, LexicalUnit value, boolean quoteIdentifier)
        throws CompilerError
    {
        StringBuilder stringBuffer = new StringBuilder();

        LexicalUnit current = value;

        while (current != null)
        {
            stringBuffer.append( getLexicalUnitAsString(name, current, quoteIdentifier) );

            LexicalUnit next = current.getNextLexicalUnit();

            if (next != null)
            {
                if (next.getLexicalUnitType() == LexicalUnit.SAC_OPERATOR_COMMA)
                {
                    current = next.getNextLexicalUnit();
                    stringBuffer.append(", ");
                }
                else if (next.getLexicalUnitType() == LexicalUnit.SAC_OPERATOR_SLASH)
                {
                    current = next.getNextLexicalUnit();
                    stringBuffer.append(" = ");
                }
                else
                {
                    throw new InvalidFormat();
                }
            }
            else
            {
                current = null;
            }
        }

        return stringBuffer.toString();
    }

    public String getPath()
    {
        return path;
    }

    public String getTimeAsString() throws CompilerError
    {
        return getTimeAsString(name, value);
    }

    private static String getTimeAsString(String name, LexicalUnit lexicalUnit)
        throws CompilerError
    {
        float time;

        short type = lexicalUnit.getLexicalUnitType();

        switch(type)
        {
        case LexicalUnit.SAC_MILLISECOND:
            {
                time = lexicalUnit.getFloatValue();
                break;
            }
        case LexicalUnit.SAC_SECOND:
            {
                time = lexicalUnit.getFloatValue() * 60;
                break;
            }
        default:
            {
                if (Trace.css)
                {
                    Trace.trace("Descriptor.getTimeAsString: type = " + type);
                }
                throw new ValueNotSupported(name);
            }
        }

		return Integer.toString(((new Float(time)).intValue()));
    }

    /**
     * This method should be used to get the string value of a
     * Descriptor, when the format isn't already known.
     */
    public String getValueAsString() throws CompilerError
    {
        String valueString;

        LexicalUnit next = value.getNextLexicalUnit();

        if ((next != null) && (next.getLexicalUnitType() == LexicalUnit.SAC_OPERATOR_COMMA))
        {
            valueString = ("[" + getListAsString(name, value) + "]");
        }
        else
        {
            valueString = getLexicalUnitAsString(name, value);
        }

        return valueString;
    }

    private static String getLexicalUnitAsString(String name, LexicalUnit lexicalUnit)
        throws CompilerError
    {
        return getLexicalUnitAsString(name, lexicalUnit, true);
    }

    private static String getLexicalUnitAsString(String name,
                                                 LexicalUnit lexicalUnit,
                                                 boolean quoteIdentifier)
        throws CompilerError
    {
        String result;

        short type = lexicalUnit.getLexicalUnitType();

        switch(type)
        {
        case LexicalUnit.SAC_MILLISECOND:
        case LexicalUnit.SAC_SECOND:
            {
                result = getTimeAsString(name, lexicalUnit);
                break;
            }
        case LexicalUnit.SAC_CENTIMETER:
        case LexicalUnit.SAC_MILLIMETER:
        case LexicalUnit.SAC_INCH:
        case LexicalUnit.SAC_PICA:
        case LexicalUnit.SAC_POINT:
        case LexicalUnit.SAC_PIXEL:
            {
                result = getLengthAsString(name, lexicalUnit);
                break;
            }
        case LexicalUnit.SAC_RGBCOLOR:
            {
                result = getColorAsString(name, lexicalUnit);
                break;
            }
        case LexicalUnit.SAC_INTEGER:
            {
                result = Integer.toString( lexicalUnit.getIntegerValue() );
                break;
            }
        case LexicalUnit.SAC_REAL:
            {
                result = Float.toString( lexicalUnit.getFloatValue() );
                break;
            }
        case LexicalUnit.SAC_STRING_VALUE:
        case LexicalUnit.SAC_URI:
            {
                result = "\"" + lexicalUnit.getStringValue().replace('\"', '\'') + "\"";
                break;
            }
        case LexicalUnit.SAC_IDENT:
            {
                // This could be a color, absolute size, or just a
                // plain identifier, so try each in that order.
                try
                {
                    result = getColorAsString(name, lexicalUnit);
                }
                catch (CompilerError compilerError)
                {
                    try
                    {
                        result = getLengthAsString(name, lexicalUnit);
                    }
                    catch (CompilerError compilerError2)
                    {
                        String stringValue = lexicalUnit.getStringValue();

                        if (stringValue.equalsIgnoreCase(Boolean.FALSE.toString()) ||
                            stringValue.equalsIgnoreCase(Boolean.TRUE.toString()))
                        {
                            result = stringValue;
                        }
                        else if (quoteIdentifier)
                        {
                            // preilly: Don't use getIdentAsString() here, see bug 86974.
                            result = "\"" + stringValue.replace('\"', '\'') + "\"";
                        }
                        else
                        {
                            result = stringValue;
                        }
                    }
                }
                break;
            }
        case LexicalUnit.SAC_FUNCTION:
            {
                String functionName = lexicalUnit.getFunctionName();
                if (functionName.equals("Embed") ||
                    functionName.equals("ClassReference") ||
                    functionName.equals("PropertyReference"))
                {
                    result = functionName + "(" + getListAsString(null, lexicalUnit.getParameters(), false) + ")";
                }
                else
                {
                    throw new FunctionNotSupported(functionName);
                }
                break;
            }
        default:
            {
                if (Trace.css)
                {
                    Trace.trace("Descriptor.getLexicalUnitAsString: type = " + type);
                }
                throw new ValueNotSupported(name);
            }
        }

        return result;
    }

    public static class ColorNotSupported extends CompilerError
    {
        private static final long serialVersionUID = -9167022814274170798L;
        public String color;

        public ColorNotSupported(String color)
        {
            this.color = color;
        }
    }

	public static class InvalidFormat extends CompilerError
	{

        private static final long serialVersionUID = 8620593353408269587L;
	}

	public static class UnparsableCSS extends CompilerError
	{

        private static final long serialVersionUID = -8939846058668804295L;
	}

    public static class ValueNotSupported extends CompilerError
    {
        private static final long serialVersionUID = 657854378435002555L;
        public String value;

        public ValueNotSupported(String value)
        {
            this.value = value;
        }
    }

    public static class FunctionNotSupported extends CompilerError
    {
        private static final long serialVersionUID = -7607804535214540281L;
        public String function;

        public FunctionNotSupported(String function)
        {
            this.function = function;
        }
    }
}
