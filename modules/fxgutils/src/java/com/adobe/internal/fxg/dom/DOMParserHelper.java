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

package com.adobe.internal.fxg.dom;

import static com.adobe.fxg.FXGConstants.FXG_FILLMODE_CLIP_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_FILLMODE_REPEAT_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_FILLMODE_SCALE_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_INTERPOLATION_LINEARRGB_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_INTERPOLATION_RGB_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_MASK_ALPHA_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_MASK_CLIP_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_MASK_LUMINOSITY_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_SPREADMETHOD_PAD_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_SPREADMETHOD_REFLECT_VALUE;
import static com.adobe.fxg.FXGConstants.FXG_SPREADMETHOD_REPEAT_VALUE;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGVersion;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGLog;
import com.adobe.fxg.util.FXGLogger;
import com.adobe.internal.fxg.dom.types.FillMode;
import com.adobe.internal.fxg.dom.types.InterpolationMethod;
import com.adobe.internal.fxg.dom.types.MaskType;
import com.adobe.internal.fxg.dom.types.SpreadMethod;

/**
 * Utilities to help parsing FXG.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public class DOMParserHelper
{
    private static Pattern idPattern = Pattern.compile ("[a-zA-Z_][a-zA-Z_0-9]*");
    private static Pattern rgbPattern = Pattern.compile ("#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]");

    /**
     * Convert an FXG String value to a boolean.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @return true for the String 'true' (case insensitive), otherwise false.
     * @throws FXGException if the String did not represent a boolean "true" or 
     * "false" (case sensitive). 
     */
    public static boolean parseBoolean(FXGNode node, String value, String name)
    {
        if (value.equals("true"))
            return true;
        else if (value.equals("false"))
            return false;
        throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidBooleanValue", name, value);
    }
    
    /**
     * Convert an FXG hexadecimal color String to an int. The
     * format must be a '#' character followed by six hexadecimal characters,
     * i.e. '#RRGGBB'.
     * 
     * @param node - the FXG node.
     * @param value - an FXG a hexadecimal color String.
     * @param name - the FXG attribute name.
     * @return an RGB color represented as an int.
     * @throws FXGException if the String did not represent a valid color value. 
     */
    public static int parseRGB(FXGNode node, String value, String name)
    {
        Matcher m;

        m = rgbPattern.matcher(value);
        if (!m.matches ())
        {
            //Exception: Invalid identifier format: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidColorValue", name, value);
        }    

        value = value.substring(1);

        int a = 255;
        int r = Integer.parseInt(value.substring(0, 2), 16) & 0xFF;
        int g = Integer.parseInt(value.substring(2, 4), 16) & 0xFF;
        int b = Integer.parseInt(value.substring(4, 6), 16) & 0xFF;

        return  (a << 24) | (r << 16) | (g << 8) | b;        
    }

    /**
     * Convert an FXG String value to a double.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @return the double precision floating point value represented by the
     * String.
     * @throws FXGException if the String did not represent a double. 
     */
    public static double parseDouble(FXGNode node, String value, String name)
    {
        try
        {
            return Double.parseDouble(value);
        }
        catch(NumberFormatException e)
        {
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidDoubleValue", name, value);
        }        
    }

    /**
     * Convert an FXG String value to a double after taking care of the % sign.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @return the double precision floating point value represented by the
     * String.
     * @throws FXGException if the String did not represent a double.
     */
    public static double parsePercent(FXGNode node, String value, String name)
    {
        if (value.length() != 0 && value.charAt(value.length()-1) == '%')
        {
            String doubleValue = value.substring(0, value.length()-1);
            try
            {
                return parseDouble(node, doubleValue, name);    
            }
            catch(FXGException e)
            {
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidPercentValue", name, value);
            }
        }
        else
        {
            return parseDouble(node, value, name); 
        }
    }
    
    /**
     * Convert an FXG String value to a double after taking care of the % sign.
     * If the value is double, it is checked against the specified range 
     * (inclusive).
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @return the double precision floating point value represented by the
     * String.
     * @throws FXGException if the String did not represent a double 
     * or the value isn't within the specified range (inclusive).
     */
    public static double parseNumberPercent(FXGNode node, String value, String name, double min, double max, double defaultValue)
    {
        if (value.length() != 0 && value.charAt(value.length()-1) == '%')
        {
            String doubleValue = value.substring(0, value.length()-1);
            try
            {
                return parseDouble(node, doubleValue, name, min, max, defaultValue);    
            }
            catch(FXGException e)
            {
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidPercentValue", name, value);
            }
        }
        else
        {
            return parseDouble(node, value, name, min, max, defaultValue); 
        }
    }
    
    /**
     * Convert an FXG String value to a double after taking care of the % sign.
     * If the value is double, it is checked against the specified range
     * (inclusive). There are separate ranges for percent and number.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param defaultValue - the default double value; if the encountered minor
     * version is later than the supported minor version and the attribute value
     * is out-of-range, the default value is returned.
     * @param name the name
     * @param minNumber the min number
     * @param maxNumber the max number
     * @param minPercent the min percent
     * @param maxPercent the max percent
     * 
     * @return the double precision floating point value represented by the
     * String.
     * 
     * @throws FXGException if the String did not represent a double
     * or the value isn't within the specified range (inclusive).
     */
    public static double parseNumberPercentWithSeparateRange(FXGNode node, String value, String name, double minNumber, 
            double maxNumber, double minPercent, double maxPercent, 
            double defaultValue)
    {
        if (value.length() != 0 && value.charAt(value.length()-1) == '%')
        {
            String doubleValue = value.substring(0, value.length()-1);
            try
            {
                return parseDouble(node, doubleValue, name, minPercent, maxPercent, defaultValue);
            }
            catch(FXGException e)
            {
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidPercentValue", name, value);
            }
        }
        else
        {
            return parseDouble(node, value, name, minNumber, maxNumber, defaultValue);
        }
    }
    
    /**
     * Convert an FXG String value to a double and check that the result is
     * within the specified range (inclusive).
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest double value that the result must be greater
     * or equal to.
     * @param max - the largest double value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default double value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @return the double precision floating point value represented by the
     * String.
     * @throws FXGException if the String did not represent a double or the 
     * result did not lie within the specified
     * range.
     */
    public static double parseDouble(FXGNode node, String value, String name, double min, double max, double defaultValue)
    {
        try
        {
            double d = Double.parseDouble(value);
            if (d >= min && d <= max)
            {
                return d;
            }
        }
        catch(NumberFormatException e)
        {
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidDoubleValue", name, value);
        }

        if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
        {
            // Warning: Minor version of this FXG file is greater than minor
            // version supported by this compiler. Use default value if an
            // attribute value is out of range.
            FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
            return defaultValue;
        }
        else
        {
            // Exception:Numeric value {0} must be greater than or equal to {1}
            // and less than or equal to {2}.
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "OutOfRangeValue", name, value, min, max);
        }
    }
    
    /**
     * Convert an FXG String value to a float.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @return the floating point value represented by the String.
     * @throws FXGException if the String did not represent a double.
     */
    public static float parseFloat(FXGNode node, String value)
    {
        try
        {
            return Float.parseFloat(value);            
        }
        catch(NumberFormatException e)
        {
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidFloatValue", value);
        }       
    }
    
    /**
     * Convert an FXG String value to an int and check that the result is
     * within the specified range (inclusive).
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param min - the smallest int value that the result must be greater
     * or equal to.
     * @param max - the largest int value that the result must be smaller
     * than or equal to.
     * @param defaultValue - the default int value; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @return the integer value represented by the String.
     * @throws FXGException if the String did not represent an integer or the 
     * result did not lie within the specified range.
     */
    public static int parseInt(FXGNode node, String value, String name, int min, int max, int defaultValue)
    {
        int i = parseInt(node, value, name);
        if (i >= min && i <= max)
        {
            return i;
        }

        if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
        {
            // Warning: Minor version of this FXG file is greater than minor
            // version supported by this compiler. Use default value if an
            // attribute value is out of range.
            FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
            return defaultValue;
        }
        else
        {
            // Exception:Numeric value {0} must be greater than or equal to {1}
            // and less than or equal to {2}.
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "OutOfRangeValue", value, min, max);
        }
    }
    
    /**
     * Convert an FXG String value to a integer.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @return the integer value represented by the String.
     * @throws FXGException if the String did not represent a integer.
     */
    public static int parseInt(FXGNode node, String value, String name)
    {
        try
        {
            return Integer.parseInt(value);
        }
        catch(NumberFormatException e)
        {
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidIntegerValue", name, value);
        }             
    }

    /**
     * Convert an FXG String value to an InterpolationMethod enumeration.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value
     * @param name - the FXG attribute name.
     * @param defaultValue - the FXG InterpolationMethod default value
     * @return the matching InterpolationMethod; if the encountered minor 
     * version is later than the supported minor version and the attribute value
     *  is out-of-range, the default value is returned.
     * @throws FXGException if the String did not match a known
     * InterpolationMethod.
     */
    public static InterpolationMethod parseInterpolationMethod(FXGNode node, String value, String name, InterpolationMethod defaultValue)
    {
        if (FXG_INTERPOLATION_RGB_VALUE.equals(value))
        {
            return InterpolationMethod.RGB;
        }
        else if (FXG_INTERPOLATION_LINEARRGB_VALUE.equals(value))
        {
            return InterpolationMethod.LINEAR_RGB;
        }
        else
        {
            if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
            {
                // Warning: Minor version of this FXG file is greater than minor
                // version supported by this compiler. Use default value if an
                // attribute value is out of range.
                FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
                return defaultValue;
            }
            else
            {
                // Exception:Unknown interpolation method {0}.
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownInterpolationMethod", value);
            }
        }
    }

    /**
     * Convert an FXG String value to a MaskType enumeration.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value
     * @param name - the FXG attribute name.
     * @param defaultValue - the FXG MaskType default value; if the encountered 
     * minor version is later than the supported minor version and the attribute
     *  value is out-of-range, the default value is returned.
     * @return the matching MaskType
     * @throws FXGException if the String did not match a known
     * MaskType.
     */
    public static MaskType parseMaskType(FXGNode node, String value, String name, MaskType defaultValue)
    {
        if (FXG_MASK_CLIP_VALUE.equals(value))
        {
            return MaskType.CLIP;
        }
        else if (FXG_MASK_ALPHA_VALUE.equals(value))
        {
            return MaskType.ALPHA;
        }
        else if (((AbstractFXGNode)node).getFileVersion().equalTo(FXGVersion.v1_0))
        {
            // FXG 1.0 does not support any more maskTypes
            // Exception:Unknown maskType {0}.
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownMaskType", value);            
        }
        else if (FXG_MASK_LUMINOSITY_VALUE.equals(value))
        {
            return MaskType.LUMINOSITY;
        }
        else
        {
            if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
            {
                // Warning: Minor version of this FXG file is greater than minor
                // version supported by this compiler. Use default value if an
                // attribute value is out of range.
                FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
                return defaultValue;
            }
            else
            {
                // Exception:Unknown maskType {0}.
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownMaskType", value);
            }
        }
    }

    /**
     * Convert an FXG String value to a fillMode enumeration.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value.
     * @param name - the FXG attribute name.
     * @param defaultValue the default value
     * 
     * @return the matching fillMode value.
     * 
     * @throws FXGException if the String did not match a known
     * fillMode value.
     */
    public static FillMode parseFillMode(FXGNode node, String value, String name, FillMode defaultValue)
    {
        if (FXG_FILLMODE_CLIP_VALUE.equals(value))
        {
            return FillMode.CLIP;
        }
        else if (FXG_FILLMODE_REPEAT_VALUE.equals(value))
        {
            return FillMode.REPEAT;
        }
        else if (FXG_FILLMODE_SCALE_VALUE.equals(value))
        {
            return FillMode.SCALE;
        }
        else
        {
            if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
            {
                // Warning: Minor version of this FXG file is greater than minor
                // version supported by this compiler. Use default value if an
                // attribute value is out of range.
                FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
                return defaultValue;
            }
            else
            {
                // Exception:Unknown fill mode: {0}.
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownFillMode", value);
            }
        }
            
    }
    
    /**
     * Convert an FXG String value to a SpreadMethod enumeration.
     * 
     * @param node - the FXG node.
     * @param value - the FXG String value
     * @param name - the FXG attribute name
     * @param defaultValue - the FXG SpreadMethod default value
     * @return the matching SpreadMethod; if the encountered minor version is 
     * later than the supported minor version and the attribute value is 
     * out-of-range, the default value is returned.
     * @throws FXGException if the String did not match a known
     * SpreadMethod.
     */
    public static SpreadMethod parseSpreadMethod(FXGNode node, String value, String name, SpreadMethod defaultValue)
    {
        if (FXG_SPREADMETHOD_PAD_VALUE.equals(value))
        {
            return SpreadMethod.PAD;
        }
        else if (FXG_SPREADMETHOD_REFLECT_VALUE.equals(value))
        {
            return SpreadMethod.REFLECT;
        }
        else if (FXG_SPREADMETHOD_REPEAT_VALUE.equals(value))
        {
            return SpreadMethod.REPEAT;
        }
        else
        {
            if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
            {
                // Warning: Minor version of this FXG file is greater than minor
                // version supported by this compiler. Use default value if an
                // attribute value is out of range.
                FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
                return defaultValue;
            }
            else
            {
                // Exception:Unknown spreadMethod {0}.
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownSpreadMethod", value);
            }
        }
    }
    
    /**
     * Convert an FXG String value to a Identifier matching pattern
     * [a-zA-Z_][a-zA-Z_0-9]*.
     * 
     * @param node - the FXG node
     * @param value - the FXG String value
     * @param name - the FXG attribute name
     * @param defaultValue the default value
     * 
     * @return the string
     * 
     * @throws FXGException if the String did not match the pattern.
     */
    public static String parseIdentifier(FXGNode node, String value, String name, String defaultValue)
    {
        Matcher m;

        m = idPattern.matcher(value);
        if (m.matches ())
        {
            return value; 
        }
        else
        {
            if (((AbstractFXGNode)node).isVersionGreaterThanCompiler())
            {
                // Warning: Minor version of this FXG file is greater than minor
                // version supported by this compiler. Use default value if an
                // attribute value is out of range.
                FXGLog.getLogger().log(FXGLogger.WARN, "DefaultAttributeValue", null, ((AbstractFXGNode)node).getDocumentName(), node.getStartLine(), node.getStartColumn(), defaultValue, name);
                return defaultValue;
            }
            else
            {
                //Exception: Invalid identifier format: {0}
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidIdentifierFormat", value);
            }
        }
    }
}
