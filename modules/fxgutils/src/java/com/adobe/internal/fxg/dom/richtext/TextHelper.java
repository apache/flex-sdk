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

package com.adobe.internal.fxg.dom.richtext;

import static com.adobe.fxg.FXGConstants.*;

import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.internal.fxg.dom.types.AlignmentBaseline;
import com.adobe.internal.fxg.dom.types.BlockProgression;
import com.adobe.internal.fxg.dom.types.BreakOpportunity;
import com.adobe.internal.fxg.dom.types.DigitCase;
import com.adobe.internal.fxg.dom.types.DigitWidth;
import com.adobe.internal.fxg.dom.types.Direction;
import com.adobe.internal.fxg.dom.types.DominantBaseline;
import com.adobe.internal.fxg.dom.types.FontStyle;
import com.adobe.internal.fxg.dom.types.FontWeight;
import com.adobe.internal.fxg.dom.types.JustificationRule;
import com.adobe.internal.fxg.dom.types.JustificationStyle;
import com.adobe.internal.fxg.dom.types.Kerning;
import com.adobe.internal.fxg.dom.types.LeadingModel;
import com.adobe.internal.fxg.dom.types.LigatureLevel;
import com.adobe.internal.fxg.dom.types.LineBreak;
import com.adobe.internal.fxg.dom.types.TextAlign;
import com.adobe.internal.fxg.dom.types.TextDecoration;
import com.adobe.internal.fxg.dom.types.TextJustify;
import com.adobe.internal.fxg.dom.types.TextRotation;
import com.adobe.internal.fxg.dom.types.TypographicCase;
import com.adobe.internal.fxg.dom.types.VerticalAlign;
import com.adobe.internal.fxg.dom.types.WhiteSpaceCollapse;

/**
 * Utilities to help create Text.
 * 
 * @since 2.0
 * @author Min Plunkett
 */
public class TextHelper
{
    protected static final double ALPHA_MIN_INCLUSIVE = 0.0;
    protected static final double ALPHA_MAX_INCLUSIVE = 1.0;

    protected static Pattern whitespacePattern = Pattern.compile ("(\\s+)");
    protected static Pattern tabstopsExceptDNumericPattern = Pattern.compile ("([S s E e C c]?[0-9]*[.]?[0-9]*\\s*)");
    protected static Pattern tabstopsExceptDScientificPattern = Pattern.compile ("([S s E e C c]?[+ -]?[0-9]*[.][0-9]*[E e][+ -]?[0-9]+\\s*)");
    protected static Pattern tabstopsDNumericPattern = Pattern.compile ("([D d][0-9]*[.]?[0-9]*([|].+)?\\s*)");
    protected static Pattern tabstopsDScientificPattern = Pattern.compile ("([D d][-]?[0-9]*[.][0-9]*[E e][+][0-9]*([|].+)?\\s*)");    
    protected static Pattern tabstopsNumberPattern = Pattern.compile ("([+ -]?[0-9]*[.]?[0-9]*[E e]?[+ -]?[0-9]*)");
    
	/**
	 * Determine if a string contains only ignorable white spaces.
	 * 
	 * @param value - value to be checked.
	 * 
	 * @return true if value contains only ignorable white spaces, else, 
	 * return false.
	 */
	public static boolean ignorableWhitespace(String value)
    {
        Matcher m;

        m = whitespacePattern.matcher(value);
        if (m.matches ())
            return true; 
        else
            return false;
    }
	
    //--------------------------------------------------------------------------
    //
    // Text Leaf Attribute Helper Methods
    //
    //--------------------------------------------------------------------------
	
    /**
     * Convert an FXG String value to a FontStyle enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching FontStyle value.
     * 
     * @throws FXGException if the String did not match a known
     * FontStyle value.
     */
    public static FontStyle getFontStyle(FXGNode node, String value)
    {
        if (FXG_FONTSTYLE_NORMAL_VALUE.equals(value))
            return FontStyle.NORMAL;
        else if (FXG_FONTSTYLE_ITALIC_VALUE.equals(value))
            return FontStyle.ITALIC;
        else
            //Exception: Unknown font style: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownFontStyle", value);
    }
    
    /**
     * Convert an FXG String value to a FontWeight enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching FontWeight value.
     * 
     * @throws FXGException if the String did not match a known
     * FontWeight value.
     */
    public static FontWeight getFontWeight(FXGNode node, String value)
    {
        if (FXG_FONTWEIGHT_NORMAL_VALUE.equals(value))
            return FontWeight.NORMAL;
        else if (FXG_FONTWEIGHT_BOLD_VALUE.equals(value))
            return FontWeight.BOLD;
        else
            //Exception: Unknown font weight: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownFontWeight", value);
    }
    
    /**
     * Convert an FXG String value to a TextDecoration enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching TextDecoration value.
     * 
     * @throws FXGException if the String did not match a known
     * TextDecoration value.
     */
    public static TextDecoration getTextDecoration(FXGNode node, String value)
    {
        if (FXG_TEXTDECORATION_NONE_VALUE.equals(value))
            return TextDecoration.NONE;
        else if (FXG_TEXTDECORATION_UNDERLINE_VALUE.equals(value))
            return TextDecoration.UNDERLINE;
        else
            //Exception: Unknown text decoration: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownTextDecoration", value);
    }
    
    /**
     * Convert an FXG String value to a Kerning enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching Kerning value.
     * 
     * @throws FXGException if the String did not match a known
     * Kerning value.
     */
    public static Kerning getKerning(FXGNode node, String value)
    {
        if (FXG_KERNING_AUTO_VALUE.equals(value))
            return Kerning.AUTO;
        else if (FXG_KERNING_ON_VALUE.equals(value))
            return Kerning.ON;
        else if (FXG_KERNING_OFF_VALUE.equals(value))
            return Kerning.OFF;
        else
            //Exception: Unknown kerning: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownKerning", value);
    }

     /**
      * Convert an FXG String value to a WhiteSpaceCollapse enumeration.
      * 
      * @param value - the FXG String value.
      * @param node the FXG node
      * 
      * @return the matching WhiteSpaceCollapse rule.
      * 
      * @throws FXGException if the String did not match a known
      * WhiteSpaceCollapse rule.
      */
    public static WhiteSpaceCollapse getWhiteSpaceCollapse(FXGNode node, String value)
    {
        if (FXG_WHITESPACE_PRESERVE_VALUE.equals(value))
            return WhiteSpaceCollapse.PRESERVE;
        else if (FXG_WHITESPACE_COLLAPSE_VALUE.equals(value))
            return WhiteSpaceCollapse.COLLAPSE;
        else
            //Exception: Unknown white space collapse: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownWhiteSpaceCollapse", value);
    }

    /**
     * Convert an FXG String value to a BreakOpportunity enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching BreakOpportunity rule.
     * 
     * @throws FXGException if the String did not match a known
     * BreakOpportunity rule.
     */
    public static BreakOpportunity getBreakOpportunity(FXGNode node, String value)
    {
        if (FXG_BREAKOPPORTUNITY_AUTO_VALUE.equals(value))
            return BreakOpportunity.AUTO;
        else if (FXG_BREAKOPPORTUNITY_ANY_VALUE.equals(value))
            return BreakOpportunity.ANY;
        else if (FXG_BREAKOPPORTUNITY_NONE_VALUE.equals(value))
            return BreakOpportunity.NONE;
        else if (FXG_BREAKOPPORTUNITY_ALL_VALUE.equals(value))
            return BreakOpportunity.ALL;
        else
            //Exception: Unknown break opportunity: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownBreakOpportunity", value);
    }
    
    /**
     * Convert an FXG String value to a DigitCase enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching DigitCase rule.
     * 
     * @throws FXGException if the String did not match a known
     * DigitCase rule.
     */
    public static DigitCase getDigitCase(FXGNode node, String value)
    {
        if (FXG_DIGITCASE_DEFAULT_VALUE.equals(value))
            return DigitCase.DEFAULT;
        else if (FXG_DIGITCASE_LINING_VALUE.equals(value))
            return DigitCase.LINING;
        else if (FXG_DIGITCASE_OLDSTYLE_VALUE.equals(value))
            return DigitCase.OLDSTYLE;
        else
            //Exception: Unknown digit case: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownDigitCase", value);
    }
    
    /**
     * Convert an FXG String value to a DigitWidth enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching DigitWidth rule.
     * 
     * @throws FXGException if the String did not match a known
     * DigitWidth rule.
     */
    public static DigitWidth getDigitWidth(FXGNode node, String value)
    {
        if (FXG_DIGITWIDTH_DEFAULT_VALUE.equals(value))
            return DigitWidth.DEFAULT;
        else if (FXG_DIGITWIDTH_PROPORTIONAL_VALUE.equals(value))
            return DigitWidth.PROPORTIONAL;
        else if (FXG_DIGITWIDTH_TABULAR_VALUE.equals(value))
            return DigitWidth.TABULAR;
        else
            //Exception: Unknown digit width: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownDigitWidth", value);
    }

    /**
     * Convert an FXG String value to a DominantBaseline enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching DominantBaseline rule.
     * 
     * @throws FXGException if the String did not match a known
     * DominantBaseline rule.
     */
    public static DominantBaseline getDominantBaseline(FXGNode node, String value)
    {
        if (FXG_DOMINANTBASELINE_AUTO_VALUE.equals(value))
            return DominantBaseline.AUTO;
        else if (FXG_DOMINANTBASELINE_ROMAN_VALUE.equals(value))
            return DominantBaseline.ROMAN;
        else if (FXG_DOMINANTBASELINE_ASCENT_VALUE.equals(value))
            return DominantBaseline.ASCENT;
        else if (FXG_DOMINANTBASELINE_DESCENT_VALUE.equals(value))
            return DominantBaseline.DESCENT;
        else if (FXG_DOMINANTBASELINE_IDEOGRAPHICTOP_VALUE.equals(value))
            return DominantBaseline.IDEOGRAPHICTOP;
        else if (FXG_DOMINANTBASELINE_IDEOGRAPHICCENTER_VALUE.equals(value))
            return DominantBaseline.IDEOGRAPHICCENTER;
        else if (FXG_DOMINANTBASELINE_IDEOGRAPHICBOTTOM_VALUE.equals(value))
            return DominantBaseline.IDEOGRAPHICBOTTOM;
        else
            //Exception: Unknown dominant baseline: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownDominantBaseline", value);
    }
    
    /**
     * Convert an FXG String value to a AlignmentBaseline enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching AlignmentBaseline rule.
     * 
     * @throws FXGException if the String did not match a known
     * AlignmentBaseline rule.
     */
    public static AlignmentBaseline getAlignmentBaseline(FXGNode node, String value)
    {
        if (FXG_ALIGNMENTBASELINE_USEDOMINANTBASELINE_VALUE.equals(value))
            return AlignmentBaseline.USEDOMINANTBASELINE;
        else if (FXG_ALIGNMENTBASELINE_ROMAN_VALUE.equals(value))
            return AlignmentBaseline.ROMAN;
        else if (FXG_ALIGNMENTBASELINE_ASCENT_VALUE.equals(value))
            return AlignmentBaseline.ASCENT;
        else if (FXG_ALIGNMENTBASELINE_DESCENT_VALUE.equals(value))
            return AlignmentBaseline.DESCENT;
        else if (FXG_ALIGNMENTBASELINE_IDEOGRAPHICTOP_VALUE.equals(value))
            return AlignmentBaseline.IDEOGRAPHICTOP;
        else if (FXG_ALIGNMENTBASELINE_IDEOGRAPHICCENTER_VALUE.equals(value))
            return AlignmentBaseline.IDEOGRAPHICCENTER;
        else if (FXG_ALIGNMENTBASELINE_IDEOGRAPHICBOTTOM_VALUE.equals(value))
            return AlignmentBaseline.IDEOGRAPHICBOTTOM;
        else
            //Exception: Unknown alignment baseline: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownAlignmentBaseline", value);
    }
    
    /**
     * Convert an FXG String value to a LigatureLevel enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching LigatureLevel rule.
     * 
     * @throws FXGException if the String did not match a known
     * LigatureLevel rule.
     */
    public static LigatureLevel getLigatureLevel(FXGNode node, String value)
    {
        if (FXG_LIGATURELEVEL_MINIMUM_VALUE.equals(value))
            return LigatureLevel.MINIMUM;
        else if (FXG_LIGATURELEVEL_COMMON_VALUE.equals(value))
            return LigatureLevel.COMMON;
        else if (FXG_LIGATURELEVEL_UNCOMMON_VALUE.equals(value))
            return LigatureLevel.UNCOMMON;
        else if (FXG_LIGATURELEVEL_EXOTIC_VALUE.equals(value))
            return LigatureLevel.EXOTIC;
        else
            //Exception: Unknown ligature level: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownLigatureLevel", value);
    }
    
    
    /**
     * Convert an FXG String value to a TypographicCase enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching TypographicCase rule.
     * 
     * @throws FXGException if the String did not match a known
     * TypographicCase rule.
     */
    public static TypographicCase getTypographicCase(FXGNode node, String value)
    {
        if (FXG_TYPOGRAPHICCASE_DEFAULT_VALUE.equals(value))
            return TypographicCase.DEFAULT;
        else if (FXG_TYPOGRAPHICCASE_CAPSTOSMALLCAPS_VALUE.equals(value))
            return TypographicCase.CAPSTOSMALLCAPS;
        else if (FXG_TYPOGRAPHICCASE_UPPERCASE_VALUE.equals(value))
            return TypographicCase.UPPERCASE;
        else if (FXG_TYPOGRAPHICCASE_LOWERCASE_VALUE.equals(value))
            return TypographicCase.LOWERCASE;
        else if (FXG_TYPOGRAPHICCASE_LOWERCASETOSMALLCAPS_VALUE.equals(value))
            return TypographicCase.LOWERCASETOSMALLCAPS;
        else
            //Exception: Unknown typographic case: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownTypographicCase", value);
    }
           
    /**
     * Convert an FXG String value to a TextRotation enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching TextRotation rule.
     * 
     * @throws FXGException if the String did not match a known
     * TextRotation rule.
     */
    public static TextRotation getTextRotation(FXGNode node, String value)
    {
        if (FXG_TEXTROTATION_AUTO_VALUE.equals(value))
            return TextRotation.AUTO;
        else if (FXG_TEXTROTATION_ROTATE_0_VALUE.equals(value))
            return TextRotation.ROTATE_0;
        else if (FXG_TEXTROTATION_ROTATE_90_VALUE.equals(value))
            return TextRotation.ROTATE_90;
        else if (FXG_TEXTROTATION_ROTATE_180_VALUE.equals(value))
            return TextRotation.ROTATE_180;
        else if (FXG_TEXTROTATION_ROTATE_270_VALUE.equals(value))
            return TextRotation.ROTATE_270;
        else
            //Exception: Unknown text rotation: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownTextRotation", value);
    }
    
    //--------------------------------------------------------------------------
    //
    // Text Paragraph Attribute Helper Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Convert an FXG String value to a TextAlign enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching TextAlign rule.
     * 
     * @throws FXGException if the String did not match a known
     * TextAlign rule.
     */
    public static TextAlign getTextAlign(FXGNode node, String value)
    {
        if (FXG_TEXTALIGN_START_VALUE.equals(value))
            return TextAlign.START;
        else if (FXG_TEXTALIGN_END_VALUE.equals(value))
            return TextAlign.END;
        else if (FXG_TEXTALIGN_LEFT_VALUE.equals(value))
            return TextAlign.LEFT;
        else if (FXG_TEXTALIGN_CENTER_VALUE.equals(value))
            return TextAlign.CENTER;
        else if (FXG_TEXTALIGN_RIGHT_VALUE.equals(value))
            return TextAlign.RIGHT;
        else if (FXG_TEXTALIGN_JUSTIFY_VALUE.equals(value))
            return TextAlign.JUSTIFY;
        else
            //Exception: Unknown text align: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownTextAlign", value);
    }
    
    /**
     * Convert an FXG String value to a Direction enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching Direction rule.
     * 
     * @throws FXGException if the String did not match a known
     * Direction rule.
     */
    public static Direction getDirection(FXGNode node, String value)
    {
        if (FXG_DIRECTION_LTR_VALUE.equals(value))
            return Direction.LTR;
        else if (FXG_DIRECTION_RTL_VALUE.equals(value))
            return Direction.RTL;
        else
            //Exception: Unknown direction: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownDirection", value);
    }

    /**
     * Convert an FXG String value to a JustificationRule enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching JustificationRule rule.
     * 
     * @throws FXGException if the String did not match a known
     * JustificationRule rule.
     */
    public static JustificationRule getJustificationRule(FXGNode node, String value)
    {
        if (FXG_JUSTIFICATIONRULE_AUTO_VALUE.equals(value))
            return JustificationRule.AUTO;
        else if (FXG_JUSTIFICATIONRULE_SPACE_VALUE.equals(value))
            return JustificationRule.SPACE;
        else if (FXG_JUSTIFICATIONRULE_EASTASIAN_VALUE.equals(value))
            return JustificationRule.EASTASIAN;
        else
            //Exception: Unknown justification rule: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownJustificationRule", value);
    }
    
    /**
     * Convert an FXG String value to a JustificationStyle enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching JustificationStyle rule.
     * 
     * @throws FXGException if the String did not match a known
     * JustificationStyle rule.
     */
    public static JustificationStyle getJustificationStyle(FXGNode node, String value)
    {
        if (FXG_JUSTIFICATIONSTYLE_AUTO_VALUE.equals(value))
            return JustificationStyle.AUTO;
        else if (FXG_JUSTIFICATIONSTYLE_PRIORITIZELEASTADJUSTMENT_VALUE.equals(value))
            return JustificationStyle.PRIORITIZELEASTADJUSTMENT;
        else if (FXG_JUSTIFICATIONSTYLE_PUSHINKINSOKU_VALUE.equals(value))
            return JustificationStyle.PUSHINKINSOKU;
        else if (FXG_JUSTIFICATIONSTYLE_PUSHOUTONLY_VALUE.equals(value))
            return JustificationStyle.PUSHOUTONLY;
        else
            //Exception: Unknown justification style: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownJustificationStyle", value);
    }
    
    /**
     * Convert an FXG String value to a TextJustify enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching TextJustify rule.
     * 
     * @throws FXGException if the String did not match a known
     * TextJustify rule.
     */
    public static TextJustify getTextJustify(FXGNode node, String value)
    {
        if (FXG_TEXTJUSTIFY_INTERWORD_VALUE.equals(value))
            return TextJustify.INTERWORD;
        else if (FXG_TEXTJUSTIFY_DISTRIBUTE_VALUE.equals(value))
            return TextJustify.DISTRIBUTE;
        else
            //Exception: Unknown text justify: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownTextJustify", value);
    }    
    
    /**
     * Convert an FXG String value to a LeadingModel enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching LeadingModel rule.
     * 
     * @throws FXGException if the String did not match a known
     * LeadingModel rule.
     */
    public static LeadingModel getLeadingModel(FXGNode node, String value)
    {
        if (FXG_LEADINGMODEL_AUTO_VALUE.equals(value))
            return LeadingModel.AUTO;
        else if (FXG_LEADINGMODEL_ROMANUP_VALUE.equals(value))
            return LeadingModel.ROMANUP;
        else if (FXG_LEADINGMODEL_IDEOGRAPHICTOPUP_VALUE.equals(value))
            return LeadingModel.IDEOGRAPHICTOPUP;
        else if (FXG_LEADINGMODEL_IDEOGRAPHICCENTERUP_VALUE.equals(value))
            return LeadingModel.IDEOGRAPHICCENTERUP;
        else if (FXG_LEADINGMODEL_ASCENTDESCENTUP_VALUE.equals(value))
            return LeadingModel.ASCENTDESCENTUP;
        else if (FXG_LEADINGMODEL_IDEOGRAPHICTOPDOWN_VALUE.equals(value))
            return LeadingModel.IDEOGRAPHICTOPDOWN;
        else if (FXG_LEADINGMODEL_IDEOGRAPHICCENTERDOWN_VALUE.equals(value))
            return LeadingModel.IDEOGRAPHICCENTERDOWN;
        else if (FXG_LEADINGMODEL_APPROXIMATETEXTFIELD_VALUE.equals(value))
            return LeadingModel.APPROXIMATETEXTFIELD;
        else
            //Exception: Unknown leading model: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownLeadingModel", value);
    }   
    
    //--------------------------------------------------------------------------
    //
    // Text Flow Attribute Helper Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * Convert an FXG String value to a BlockProgression enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching BlockProgression enum.
     * 
     * @throws FXGException if the String did not match a known
     * BlockProgression enum.
     */
    public static BlockProgression getBlockProgression(FXGNode node, String value)
    {
        if (FXG_BLOCKPROGRESSION_TB_VALUE.equals(value))
            return BlockProgression.TB;
        else if (FXG_BLOCKPROGRESSION_RL_VALUE.equals(value))
            return BlockProgression.RL;
        else
            //Exception: Unknown block progression: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownBlockProgression", value);
    }     
    
    /**
     * Convert an FXG String value to a LineBreak enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching LineBreak enum.
     * 
     * @throws FXGException if the String did not match a known
     * LineBreak enum.
     */
    public static LineBreak getLineBreak(FXGNode node, String value)
    {
        if (FXG_LINEBREAK_TOFIT_VALUE.equals(value))
        {
            return LineBreak.TOFIT;
        }
        else if (FXG_LINEBREAK_EXPLICIT_VALUE.equals(value))
        {
            return LineBreak.EXPLICIT;
        }
        else if (FXG_INHERIT_VALUE.equals(value))
        {
            return LineBreak.INHERIT;
        }
        else
        {
            //Exception: Unknown line break: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownLineBreak", value);
        }
    }
    
    /**
     * Convert an FXG String value to a VerticalAlign enumeration.
     * 
     * @param value - the FXG String value.
     * @param node the FXG node
     * 
     * @return the matching VerticalAlign rule.
     * 
     * @throws FXGException if the String did not match a known
     * VerticalAlign rule.
     */
    public static VerticalAlign getVerticalAlign(FXGNode node, String value)
    {
        if (FXG_VERTICALALIGN_TOP_VALUE.equals(value))
            return VerticalAlign.TOP;
        else if (FXG_VERTICALALIGN_BOTTOM_VALUE.equals(value))
            return VerticalAlign.BOTTOM;
        else if (FXG_VERTICALALIGN_MIDDLE_VALUE.equals(value))
            return VerticalAlign.MIDDLE;
        else if (FXG_VERTICALALIGN_JUSTIFY_VALUE.equals(value))
            return VerticalAlign.JUSTIFY;
        else if (FXG_INHERIT_VALUE.equals(value))
            return VerticalAlign.INHERIT;
        else
            //Exception: Unknown vertical align: {0}
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "UnknownVerticalAlign", value);
    }
    
    /**
     * Parses the tab stops using pattern match according to rules described 
     * in the FXG Specification.
     * 
     * @param node the FXG node
     * @param value the value
     * 
     * @return the string
     */
    public static String parseTabStops(FXGNode node, String value)
    {
        String[] tabStops = value.trim().split("\\s+");
        
        // A space may be part of the alignment token is it escaped with a 
        // backslash. We need to combine those backslash escaped space to
        // the string element in front of it.
        ArrayList<String> finalTabStops = new ArrayList<String>(tabStops.length);
        int iFinal = -1;
        boolean escaped = false;
        for (int i=0; i<tabStops.length; i++)
        {
            if (escaped)
            {
                finalTabStops.add(iFinal, finalTabStops.get(iFinal)+tabStops[i]);
            }
            else
            {
                finalTabStops.add(tabStops[i]);
                iFinal++;
            }
            escaped = tabStops[i].endsWith("\\")? true: false;
        }
        
        String tabStopsVal = null;
        for (int i=0; i<finalTabStops.size(); i++)
        {
            tabStopsVal = finalTabStops.get(i);
            if (!matchPattern(tabStopsVal, tabstopsExceptDNumericPattern))
            {
                if (!matchPattern(tabStopsVal, tabstopsExceptDScientificPattern))
                {
                    if (!matchPattern(tabStopsVal, tabstopsDNumericPattern))
                    {
                        if (!matchPattern(tabStopsVal, tabstopsDScientificPattern))
                        {
                            //Exception: Malformed tab stops ''{0}'' - must be 
                            // an array of tab stops where each tab stop is 
                            // delimited by one or more spaces. A tab stop 
                            // takes the following string-based form: 
                            // [alignment type][alignment position]|[alignment token]. 
                            throw new FXGException(node.getStartLine(), node.getStartColumn(), "InvalidTabStops", value);                            
                        }
                    }
                }
            }
        }
        return value;
    }
    
    private static boolean matchPattern(String value, Pattern pattern)
    {
        Matcher m = pattern.matcher(value);
        return m.matches();
    }
}
