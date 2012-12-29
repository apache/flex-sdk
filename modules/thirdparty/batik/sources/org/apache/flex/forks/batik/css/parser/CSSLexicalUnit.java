/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.css.parser;

import org.w3c.css.sac.LexicalUnit;

/**
 * This class implements the {@link LexicalUnit} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSLexicalUnit.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class CSSLexicalUnit implements LexicalUnit {

         public static final String UNIT_TEXT_CENTIMETER  = "cm";
         public static final String UNIT_TEXT_DEGREE      = "deg";
         public static final String UNIT_TEXT_EM          = "em";
         public static final String UNIT_TEXT_EX          = "ex";
         public static final String UNIT_TEXT_GRADIAN     = "grad";
         public static final String UNIT_TEXT_HERTZ       = "Hz";
         public static final String UNIT_TEXT_INCH        = "in";
         public static final String UNIT_TEXT_KILOHERTZ   = "kHz";
         public static final String UNIT_TEXT_MILLIMETER  = "mm";
         public static final String UNIT_TEXT_MILLISECOND = "ms";
         public static final String UNIT_TEXT_PERCENTAGE  = "%";
         public static final String UNIT_TEXT_PICA        = "pc";
         public static final String UNIT_TEXT_PIXEL       = "px";
         public static final String UNIT_TEXT_POINT       = "pt";
         public static final String UNIT_TEXT_RADIAN      = "rad";
         public static final String UNIT_TEXT_REAL        = "";
         public static final String UNIT_TEXT_SECOND      = "s";
         public static final String UNIT_TEXT_DPI         = "dpi";
         public static final String UNIT_TEXT_DPCM        = "dpcm";
         

    public static final String TEXT_RGBCOLOR          = "rgb";
    public static final String TEXT_RECT_FUNCTION     = "rect";
    public static final String TEXT_COUNTER_FUNCTION  = "counter";
    public static final String TEXT_COUNTERS_FUNCTION = "counters";

    /**
     * The lexical unit type.
     */
    protected short lexicalUnitType;

    /**
     * The next lexical unit.
     */
    protected LexicalUnit nextLexicalUnit;

    /**
     * The previous lexical unit.
     */
    protected LexicalUnit previousLexicalUnit;

    /**
     * The line number..
     */
    protected int lineNumber;

    /**
     * Creates a new LexicalUnit.
     */
    protected CSSLexicalUnit(short t, LexicalUnit prev, int lineNumber) {
        lexicalUnitType = t;
        previousLexicalUnit = prev;
        if (prev != null) {
            ((CSSLexicalUnit)prev).nextLexicalUnit = this;
        }
        this.lineNumber = lineNumber;
    }

    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getLexicalUnitType()}.
     */
    public short getLexicalUnitType() {
        return lexicalUnitType;
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getNextLexicalUnit()}.
     */
    public LexicalUnit getNextLexicalUnit() {
        return nextLexicalUnit;
    }

    /**
     * Sets the next lexical unit.
     */
    public void setNextLexicalUnit(LexicalUnit lu) {
        nextLexicalUnit = lu;
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getPreviousLexicalUnit()}.
     */
    public LexicalUnit getPreviousLexicalUnit() {
        return previousLexicalUnit;
    }
    
    /**
     * Sets the previous lexical unit.
     */
    public void setPreviousLexicalUnit(LexicalUnit lu) {
        previousLexicalUnit = lu;
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getIntegerValue()}.
     */
    public int getIntegerValue() {
        throw new IllegalStateException();
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getFloatValue()}.
     */
    public float getFloatValue() {
        throw new IllegalStateException();
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getDimensionUnitText()}.
     */
    public String getDimensionUnitText() {
        switch (lexicalUnitType) {
        case LexicalUnit.SAC_CENTIMETER:  return UNIT_TEXT_CENTIMETER;
        case LexicalUnit.SAC_DEGREE:      return UNIT_TEXT_DEGREE;
        /* Added by Apache Flex */
        case LexicalUnit.SAC_DPI:         return UNIT_TEXT_DPI;
        /* Added by Apache Flex */
        case LexicalUnit.SAC_DPCM:        return UNIT_TEXT_DPCM;
        case LexicalUnit.SAC_EM:          return UNIT_TEXT_EM;
        case LexicalUnit.SAC_EX:          return UNIT_TEXT_EX;
        case LexicalUnit.SAC_GRADIAN:     return UNIT_TEXT_GRADIAN;
        case LexicalUnit.SAC_HERTZ:       return UNIT_TEXT_HERTZ;
        case LexicalUnit.SAC_INCH:        return UNIT_TEXT_INCH;
        case LexicalUnit.SAC_KILOHERTZ:   return UNIT_TEXT_KILOHERTZ;
        case LexicalUnit.SAC_MILLIMETER:  return UNIT_TEXT_MILLIMETER;
        case LexicalUnit.SAC_MILLISECOND: return UNIT_TEXT_MILLISECOND;
        case LexicalUnit.SAC_PERCENTAGE:  return UNIT_TEXT_PERCENTAGE;
        case LexicalUnit.SAC_PICA:        return UNIT_TEXT_PICA;
        case LexicalUnit.SAC_PIXEL:       return UNIT_TEXT_PIXEL;
        case LexicalUnit.SAC_POINT:       return UNIT_TEXT_POINT;
        case LexicalUnit.SAC_RADIAN:      return UNIT_TEXT_RADIAN;
        case LexicalUnit.SAC_REAL:        return UNIT_TEXT_REAL;
        case LexicalUnit.SAC_SECOND:      return UNIT_TEXT_SECOND;
        default:
            throw new IllegalStateException("No Unit Text for type: " + 
                                            lexicalUnitType);
        }
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getFunctionName()}.
     */
    public String getFunctionName() {
        throw new IllegalStateException();
    }
    
    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getParameters()}.
     */
    public LexicalUnit getParameters() {
        throw new IllegalStateException();
    }

    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getStringValue()}.
     */
    public String getStringValue() {
        throw new IllegalStateException();
    }

    /**
     * <b>SAC</b>: Implements {@link LexicalUnit#getSubValues()}.
     */
    public LexicalUnit getSubValues() {
        throw new IllegalStateException();
    }

    /**
     *   Added by Apache Flex.
     */
    public int getLineNumber() {
        return lineNumber;
    }

    /**
     * Creates a new integer lexical unit.
     */
    public static CSSLexicalUnit createSimple(short t, LexicalUnit prev) {
        return new SimpleLexicalUnit(t, prev, -1);
    }

    /**
     * Creates a new integer lexical unit.
     */
    public static CSSLexicalUnit createSimple(short t, LexicalUnit prev, int lineNumber) {
        return new SimpleLexicalUnit(t, prev, lineNumber);
    }

    /**
     * This class represents a simple unit.
     */
    protected static class SimpleLexicalUnit extends CSSLexicalUnit {

        /**
         * Creates a new LexicalUnit.
         */
        public SimpleLexicalUnit(short t, LexicalUnit prev, int lineNumber) {
            super(t, prev, lineNumber);
            if ((t != LexicalUnit.SAC_OPERATOR_COMMA) && (t != LexicalUnit.SAC_OPERATOR_SLASH) && (t != LexicalUnit.SAC_INHERIT))
            	throw new Error("Internal CSS parser error!");
        }

		public void appendToStringBuffer(StringBuffer buf)
		{
			switch (getLexicalUnitType())
			{
			case SAC_OPERATOR_COMMA:
				buf.append(',');
				break;
			case SAC_OPERATOR_SLASH:
				buf.append('/');
				break;
			case SAC_INHERIT:
				buf.append("inherit");
				if (nextLexicalUnit != null)
					buf.append(" ");
				break;
			}
			if (nextLexicalUnit != null)
				((CSSLexicalUnit)nextLexicalUnit).appendToStringBuffer(buf);
		}
    }

    /**
     * Creates a new integer lexical unit.
     */
    public static CSSLexicalUnit createInteger(int val, LexicalUnit prev) {
        return new IntegerLexicalUnit(val, prev, -1);
    }

    /**
     * Creates a new integer lexical unit.
     */
    public static CSSLexicalUnit createInteger(int val, LexicalUnit prev, int lineNumber) {
        return new IntegerLexicalUnit(val, prev, lineNumber);
    }

    /**
     * This class represents an integer unit.
     */
    protected static class IntegerLexicalUnit extends CSSLexicalUnit {

        /**
         * The integer value.
         */
        protected int value;

        /**
         * Creates a new LexicalUnit.
         */
        public IntegerLexicalUnit(int val, LexicalUnit prev, int lineNumber) {
            super(LexicalUnit.SAC_INTEGER, prev, lineNumber);
            value = val;
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getIntegerValue()}.
         */
        public int getIntegerValue() {
            return value;
        }

		public void appendToStringBuffer(StringBuffer buf) {
			buf.append(value);
			appendNextToStringBuffer(buf);
		}
    }

    /**
     * Creates a new float lexical unit.
     */
    public static CSSLexicalUnit createFloat(short t, float val, LexicalUnit prev) {
        return new FloatLexicalUnit(t, val, prev, -1);
    }

    /**
     * Creates a new float lexical unit.
     */
    public static CSSLexicalUnit createFloat(short t, float val, LexicalUnit prev, int lineNumber) {
        return new FloatLexicalUnit(t, val, prev, lineNumber);
    }

    /**
     * This class represents a float unit.
     */
    protected static class FloatLexicalUnit extends CSSLexicalUnit {

        /**
         * The float value.
         */
        protected float value;

        /**
         * Creates a new LexicalUnit.
         */
        public FloatLexicalUnit(short t, float val, LexicalUnit prev, int lineNumber) {
            super(t, prev, lineNumber);
            value = val;
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getFloatValue()}.
         */
        public float getFloatValue() {
            return value;
        }

		public void appendToStringBuffer(StringBuffer buf) {
			buf.append(value);
			appendNextToStringBuffer(buf);
			buf.append(getDimensionUnitText());
		}
        
        
    }

    /**
     * Creates a new float lexical unit.
     */
    public static CSSLexicalUnit createDimension(float val, String dim,
                                                 LexicalUnit prev) {
        return new DimensionLexicalUnit(val, dim, prev, -1);
    }

    /**
     * Creates a new float lexical unit.
     */
    public static CSSLexicalUnit createDimension(float val, String dim,
                                                 LexicalUnit prev, int lineNumber) {
        return new DimensionLexicalUnit(val, dim, prev, lineNumber);
    }

    /**
     * This class represents a dimension unit.
     */
    protected static class DimensionLexicalUnit extends CSSLexicalUnit {

        /**
         * The float value.
         */
        protected float value;

        /**
         * The dimension.
         */
        protected String dimension;

        /**
         * Creates a new LexicalUnit.
         */
        public DimensionLexicalUnit(float val, String dim, LexicalUnit prev, int lineNumber) {
            super(SAC_DIMENSION, prev, lineNumber);
            value = val;
            dimension = dim;
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getFloatValue()}.
         */
        public float getFloatValue() {
            return value;
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getDimensionUnitText()}.
         */
        public String getDimensionUnitText() {
            return dimension;
        }

		public void appendToStringBuffer(StringBuffer buf) {
			buf.append(value);
			buf.append(dimension);
			appendNextToStringBuffer(buf);
		}
        
        
    }

    /**
     * Creates a new function lexical unit.
     */
    public static CSSLexicalUnit createFunction(String f, LexicalUnit params,
                                                LexicalUnit prev) {
        return new FunctionLexicalUnit(f, params, prev, -1);
    }

    /**
     * Creates a new function lexical unit.
     */
    public static CSSLexicalUnit createFunction(String f, LexicalUnit params,
                                                LexicalUnit prev, int lineNumber) {
        return new FunctionLexicalUnit(f, params, prev, lineNumber);
    }

    /**
     * This class represents a function unit.
     */
    protected static class FunctionLexicalUnit extends CSSLexicalUnit {

        /**
         * The function name.
         */
        protected String name;

        /**
         * The function parameters.
         */
        protected LexicalUnit parameters;

        /**
         * Creates a new LexicalUnit.
         */
        public FunctionLexicalUnit(String f, LexicalUnit params, LexicalUnit prev, int lineNumber) {
            super(SAC_FUNCTION, prev, lineNumber);
            name = f;
            parameters = params;
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getFunctionName()}.
         */
        public String getFunctionName() {
            return name;
        }
    
        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getParameters()}.
         */
        public LexicalUnit getParameters() {
            return parameters;
        }

		public void appendToStringBuffer(StringBuffer buf) {
			buf.append(name);
			buf.append('(');
			((CSSLexicalUnit)parameters).appendToStringBuffer(buf);
			buf.append(')');
			appendNextToStringBuffer(buf);
		}
        
    }

    /**
     * Creates a new function lexical unit.
     */
    public static CSSLexicalUnit createPredefinedFunction(short t, LexicalUnit params,
                                                          LexicalUnit prev) {
        return new PredefinedFunctionLexicalUnit(t, params, prev, -1);
    }

    /**
     * Creates a new function lexical unit.
     */
    public static CSSLexicalUnit createPredefinedFunction(short t, LexicalUnit params,
                                                          LexicalUnit prev, int lineNumber) {
        return new PredefinedFunctionLexicalUnit(t, params, prev, lineNumber);
    }

    /**
     * This class represents a function unit.
     */
    protected static class PredefinedFunctionLexicalUnit extends CSSLexicalUnit {

        /**
         * The function parameters.
         */
        protected LexicalUnit parameters;

        /**
         * Creates a new LexicalUnit.
         */
        public PredefinedFunctionLexicalUnit(short t, LexicalUnit params,
                                             LexicalUnit prev, int lineNumber) {
            super(t, prev, lineNumber);
            parameters = params;
        }
        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getFunctionName()}.
         */
        public String getFunctionName() {
            switch (lexicalUnitType) {
            case SAC_RGBCOLOR:          return TEXT_RGBCOLOR;
            case SAC_RECT_FUNCTION:     return TEXT_RECT_FUNCTION;
            case SAC_COUNTER_FUNCTION:  return TEXT_COUNTER_FUNCTION;
            case SAC_COUNTERS_FUNCTION: return TEXT_COUNTERS_FUNCTION;
            default: break;
            }
            return super.getFunctionName();
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getParameters()}.
         */
        public LexicalUnit getParameters() {
            return parameters;
        }

        private String getName() {
        	switch (getLexicalUnitType())
			{
			case SAC_COUNTER_FUNCTION:
				return "counter";
			case SAC_COUNTERS_FUNCTION:
				return "counters";
			case SAC_RGBCOLOR:
				return "rgb";
			case SAC_RECT_FUNCTION:
				return "rect";
			}
        	throw new Error("Internal CSS parser error!");
        }
        
		public void appendToStringBuffer(StringBuffer buf) {
			buf.append(getName());
			buf.append('(');
			((CSSLexicalUnit)parameters).appendToStringBuffer(buf);
			buf.append(')');
			appendNextToStringBuffer(buf);
		}
    }

    /**
     * Creates a new string lexical unit.
     */
    public static CSSLexicalUnit createString(short t, String val, LexicalUnit prev) {
        return new StringLexicalUnit(t, val, prev, -1);
    }

    /**
     * Creates a new string lexical unit.
     */
    public static CSSLexicalUnit createString(short t, String val, LexicalUnit prev, int lineNumber) {
        return new StringLexicalUnit(t, val, prev, lineNumber);
    }

    /**
     * This class represents a string unit.
     */
    protected static class StringLexicalUnit extends CSSLexicalUnit {

        /**
         * The string value.
         */
        protected String value;

        /**
         * Creates a new LexicalUnit.
         */
        public StringLexicalUnit(short t, String val, LexicalUnit prev, int lineNumber) {
            super(t, prev, lineNumber);
            value = val;
        }

        /**
         * <b>SAC</b>: Implements {@link LexicalUnit#getStringValue()}.
         */
        public String getStringValue() {
            return value;
        }

		public void appendToStringBuffer(StringBuffer buf) {
			buf.append('\"');
			buf.append(value.replace('\"', '\''));
			buf.append('\"');
			appendNextToStringBuffer(buf);
		}
    }
    
    public abstract void appendToStringBuffer(StringBuffer buf);
    
    protected void appendNextToStringBuffer(StringBuffer buf)
    {
    	if (nextLexicalUnit != null) {
    		buf.append(' ');
    		((CSSLexicalUnit)nextLexicalUnit).appendToStringBuffer(buf);
    	}
    }
    
    public String toString()
    {
    	StringBuffer buf = new StringBuffer();
		appendToStringBuffer(buf);
		return buf.toString();
    }
}
