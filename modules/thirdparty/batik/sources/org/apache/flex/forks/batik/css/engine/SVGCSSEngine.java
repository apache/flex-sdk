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
package org.apache.flex.forks.batik.css.engine;

import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.ValueConstants;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.engine.value.css2.ClipManager;
import org.apache.flex.forks.batik.css.engine.value.css2.CursorManager;
import org.apache.flex.forks.batik.css.engine.value.css2.DirectionManager;
import org.apache.flex.forks.batik.css.engine.value.css2.DisplayManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontFamilyManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontSizeAdjustManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontSizeManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontStretchManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontStyleManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontVariantManager;
import org.apache.flex.forks.batik.css.engine.value.css2.FontWeightManager;
import org.apache.flex.forks.batik.css.engine.value.css2.OverflowManager;
import org.apache.flex.forks.batik.css.engine.value.css2.SrcManager;
import org.apache.flex.forks.batik.css.engine.value.css2.TextDecorationManager;
import org.apache.flex.forks.batik.css.engine.value.css2.UnicodeBidiManager;
import org.apache.flex.forks.batik.css.engine.value.css2.VisibilityManager;
import org.apache.flex.forks.batik.css.engine.value.svg.AlignmentBaselineManager;
import org.apache.flex.forks.batik.css.engine.value.svg.BaselineShiftManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ClipPathManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ClipRuleManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ColorInterpolationFiltersManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ColorInterpolationManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ColorProfileManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ColorRenderingManager;
import org.apache.flex.forks.batik.css.engine.value.svg.DominantBaselineManager;
import org.apache.flex.forks.batik.css.engine.value.svg.EnableBackgroundManager;
import org.apache.flex.forks.batik.css.engine.value.svg.FillRuleManager;
import org.apache.flex.forks.batik.css.engine.value.svg.FilterManager;
import org.apache.flex.forks.batik.css.engine.value.svg.GlyphOrientationHorizontalManager;
import org.apache.flex.forks.batik.css.engine.value.svg.GlyphOrientationVerticalManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ImageRenderingManager;
import org.apache.flex.forks.batik.css.engine.value.svg.KerningManager;
import org.apache.flex.forks.batik.css.engine.value.svg.MarkerManager;
import org.apache.flex.forks.batik.css.engine.value.svg.MarkerShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.svg.MaskManager;
import org.apache.flex.forks.batik.css.engine.value.svg.OpacityManager;
import org.apache.flex.forks.batik.css.engine.value.svg.PointerEventsManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGPaintManager;
import org.apache.flex.forks.batik.css.engine.value.svg.ShapeRenderingManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SpacingManager;
import org.apache.flex.forks.batik.css.engine.value.svg.StrokeDasharrayManager;
import org.apache.flex.forks.batik.css.engine.value.svg.StrokeDashoffsetManager;
import org.apache.flex.forks.batik.css.engine.value.svg.StrokeLinecapManager;
import org.apache.flex.forks.batik.css.engine.value.svg.StrokeLinejoinManager;
import org.apache.flex.forks.batik.css.engine.value.svg.StrokeMiterlimitManager;
import org.apache.flex.forks.batik.css.engine.value.svg.StrokeWidthManager;
import org.apache.flex.forks.batik.css.engine.value.svg.TextAnchorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.TextRenderingManager;
import org.apache.flex.forks.batik.css.engine.value.svg.WritingModeManager;
import org.apache.flex.forks.batik.css.parser.ExtendedParser;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.ParsedURL;

import org.w3c.dom.Document;

/**
 * This class provides a CSS engine initialized for SVG.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGCSSEngine.java 579230 2007-09-25 12:52:48Z cam $
 */
public class SVGCSSEngine extends CSSEngine {

    /**
     * Creates a new SVGCSSEngine.
     * @param doc The associated document.
     * @param uri The document URI.
     * @param p The CSS parser to use.
     * @param ctx The CSS context.
     */
    public SVGCSSEngine(Document doc,
                        ParsedURL uri,
                        ExtendedParser p,
                        CSSContext ctx) {
        super(doc, uri, p,
              SVG_VALUE_MANAGERS,
              SVG_SHORTHAND_MANAGERS,
              null,
              null,
              "style",
              null,
              "class",
              true,
              null,
              ctx);
        // SVG defines line-height to be font-size.
        lineHeightIndex = fontSizeIndex;
    }

    /**
     * Creates a new SVGCSSEngine.
     * @param doc The associated document.
     * @param uri The document URI.
     * @param p The CSS parser to use.
     * @param vms Extension value managers.
     * @param sms Extension shorthand managers.
     * @param ctx The CSS context.
     */
    public SVGCSSEngine(Document doc,
                        ParsedURL uri,
                        ExtendedParser p,
                        ValueManager[] vms,
                        ShorthandManager[] sms,
                        CSSContext ctx) {
        super(doc, uri, p,
              mergeArrays(SVG_VALUE_MANAGERS, vms),
              mergeArrays(SVG_SHORTHAND_MANAGERS, sms),
              null,
              null,
              "style",
              null,
              "class",
              true,
              null,
              ctx);
        // SVG defines line-height to be font-size.
        lineHeightIndex = fontSizeIndex;
    }

    protected SVGCSSEngine(Document doc,
                           ParsedURL uri,
                           ExtendedParser p,
                           ValueManager[] vms,
                           ShorthandManager[] sms,
                           String[] pe,
                           String sns,
                           String sln,
                           String cns,
                           String cln,
                           boolean hints,
                           String hintsNS,
                           CSSContext ctx) {
        super(doc, uri, p,
              mergeArrays(SVG_VALUE_MANAGERS, vms),
              mergeArrays(SVG_SHORTHAND_MANAGERS, sms),
              pe, sns, sln, cns, cln, hints, hintsNS, ctx);
        // SVG defines line-height to be font-size.
        lineHeightIndex = fontSizeIndex;
    }


    /**
     * Merges the given arrays.
     */
    protected static ValueManager[] mergeArrays(ValueManager[] a1,
                                                ValueManager[] a2) {
        ValueManager[] result = new ValueManager[a1.length + a2.length];
        System.arraycopy(a1, 0, result, 0, a1.length);
        System.arraycopy(a2, 0, result, a1.length, a2.length);
        return result;
    }

    /**
     * Merges the given arrays.
     */
    protected static ShorthandManager[] mergeArrays(ShorthandManager[] a1,
                                                    ShorthandManager[] a2) {
        ShorthandManager[] result =
            new ShorthandManager[a1.length + a2.length];
        System.arraycopy(a1, 0, result, 0, a1.length);
        System.arraycopy(a2, 0, result, a1.length, a2.length);
        return result;
    }

    /**
     * The value managers for SVG.
     */
    public static final ValueManager[] SVG_VALUE_MANAGERS = {
        new AlignmentBaselineManager(),
        new BaselineShiftManager(),
        new ClipManager(),
        new ClipPathManager(),
        new ClipRuleManager(),

        new ColorManager(),
        new ColorInterpolationManager(),
        new ColorInterpolationFiltersManager(),
        new ColorProfileManager(),
        new ColorRenderingManager(),

        new CursorManager(),
        new DirectionManager(),
        new DisplayManager(),
        new DominantBaselineManager(),
        new EnableBackgroundManager(),

        new SVGPaintManager(CSSConstants.CSS_FILL_PROPERTY),
        new OpacityManager(CSSConstants.CSS_FILL_OPACITY_PROPERTY, true),
        new FillRuleManager(),
        new FilterManager(),
        new SVGColorManager(CSSConstants.CSS_FLOOD_COLOR_PROPERTY),

        new OpacityManager(CSSConstants.CSS_FLOOD_OPACITY_PROPERTY, false),
        new FontFamilyManager(),
        new FontSizeManager(),
        new FontSizeAdjustManager(),
        new FontStretchManager(),

        new FontStyleManager(),
        new FontVariantManager(),
        new FontWeightManager(),
        new GlyphOrientationHorizontalManager(),
        new GlyphOrientationVerticalManager(),

        new ImageRenderingManager(),
        new KerningManager(),
        new SpacingManager(CSSConstants.CSS_LETTER_SPACING_PROPERTY),
        new SVGColorManager(CSSConstants.CSS_LIGHTING_COLOR_PROPERTY,
                            ValueConstants.WHITE_RGB_VALUE),
        new MarkerManager(CSSConstants.CSS_MARKER_END_PROPERTY),

        new MarkerManager(CSSConstants.CSS_MARKER_MID_PROPERTY),
        new MarkerManager(CSSConstants.CSS_MARKER_START_PROPERTY),
        new MaskManager(),
        new OpacityManager(CSSConstants.CSS_OPACITY_PROPERTY, false),
        new OverflowManager(),

        new PointerEventsManager(),
        new SrcManager(),
        new ShapeRenderingManager(),
        new SVGColorManager(CSSConstants.CSS_STOP_COLOR_PROPERTY),
        new OpacityManager(CSSConstants.CSS_STOP_OPACITY_PROPERTY, false),
        new SVGPaintManager(CSSConstants.CSS_STROKE_PROPERTY,
                            ValueConstants.NONE_VALUE),

        new StrokeDasharrayManager(),
        new StrokeDashoffsetManager(),
        new StrokeLinecapManager(),
        new StrokeLinejoinManager(),
        new StrokeMiterlimitManager(),

        new OpacityManager(CSSConstants.CSS_STROKE_OPACITY_PROPERTY, true),
        new StrokeWidthManager(),
        new TextAnchorManager(),
        new TextDecorationManager(),
        new TextRenderingManager(),

        new UnicodeBidiManager(),
        new VisibilityManager(),
        new SpacingManager(CSSConstants.CSS_WORD_SPACING_PROPERTY),
        new WritingModeManager(),
    };

    /**
     * The shorthand managers for SVG.
     */
    public static final ShorthandManager[] SVG_SHORTHAND_MANAGERS = {
        new FontShorthandManager(),
        new MarkerShorthandManager(),
    };

    //
    // The property indexes.
    //
    public static final int ALIGNMENT_BASELINE_INDEX = 0;
    public static final int BASELINE_SHIFT_INDEX =
        ALIGNMENT_BASELINE_INDEX + 1;
    public static final int CLIP_INDEX = BASELINE_SHIFT_INDEX + 1;
    public static final int CLIP_PATH_INDEX = CLIP_INDEX +1;
    public static final int CLIP_RULE_INDEX = CLIP_PATH_INDEX + 1;


    public static final int COLOR_INDEX = CLIP_RULE_INDEX + 1;
    public static final int COLOR_INTERPOLATION_INDEX = COLOR_INDEX + 1;
    public static final int COLOR_INTERPOLATION_FILTERS_INDEX =
        COLOR_INTERPOLATION_INDEX + 1;
    public static final int COLOR_PROFILE_INDEX =
        COLOR_INTERPOLATION_FILTERS_INDEX + 1;
    public static final int COLOR_RENDERING_INDEX = COLOR_PROFILE_INDEX + 1;


    public static final int CURSOR_INDEX = COLOR_RENDERING_INDEX + 1;
    public static final int DIRECTION_INDEX = CURSOR_INDEX + 1;
    public static final int DISPLAY_INDEX = DIRECTION_INDEX + 1;
    public static final int DOMINANT_BASELINE_INDEX = DISPLAY_INDEX + 1;
    public static final int ENABLE_BACKGROUND_INDEX =
        DOMINANT_BASELINE_INDEX + 1;


    public static final int FILL_INDEX = ENABLE_BACKGROUND_INDEX + 1;
    public static final int FILL_OPACITY_INDEX = FILL_INDEX + 1;
    public static final int FILL_RULE_INDEX = FILL_OPACITY_INDEX + 1;
    public static final int FILTER_INDEX = FILL_RULE_INDEX + 1;
    public static final int FLOOD_COLOR_INDEX = FILTER_INDEX + 1;

    public static final int FLOOD_OPACITY_INDEX = FLOOD_COLOR_INDEX + 1;
    public static final int FONT_FAMILY_INDEX = FLOOD_OPACITY_INDEX + 1;
    public static final int FONT_SIZE_INDEX = FONT_FAMILY_INDEX + 1;
    public static final int FONT_SIZE_ADJUST_INDEX = FONT_SIZE_INDEX + 1;
    public static final int FONT_STRETCH_INDEX = FONT_SIZE_ADJUST_INDEX + 1;

    public static final int FONT_STYLE_INDEX = FONT_STRETCH_INDEX + 1;
    public static final int FONT_VARIANT_INDEX = FONT_STYLE_INDEX + 1;
    public static final int FONT_WEIGHT_INDEX = FONT_VARIANT_INDEX + 1;
    public static final int GLYPH_ORIENTATION_HORIZONTAL_INDEX =
        FONT_WEIGHT_INDEX + 1;
    public static final int GLYPH_ORIENTATION_VERTICAL_INDEX =
        GLYPH_ORIENTATION_HORIZONTAL_INDEX + 1;


    public static final int IMAGE_RENDERING_INDEX =
        GLYPH_ORIENTATION_VERTICAL_INDEX + 1;
    public static final int KERNING_INDEX = IMAGE_RENDERING_INDEX + 1;
    public static final int LETTER_SPACING_INDEX = KERNING_INDEX + 1;
    public static final int LIGHTING_COLOR_INDEX = LETTER_SPACING_INDEX + 1;
    public static final int MARKER_END_INDEX = LIGHTING_COLOR_INDEX + 1;


    public static final int MARKER_MID_INDEX = MARKER_END_INDEX + 1;
    public static final int MARKER_START_INDEX = MARKER_MID_INDEX + 1;
    public static final int MASK_INDEX = MARKER_START_INDEX + 1;
    public static final int OPACITY_INDEX = MASK_INDEX + 1;
    public static final int OVERFLOW_INDEX = OPACITY_INDEX + 1;


    public static final int POINTER_EVENTS_INDEX = OVERFLOW_INDEX + 1;
    public static final int SRC_INDEX = POINTER_EVENTS_INDEX + 1;
    public static final int SHAPE_RENDERING_INDEX = SRC_INDEX + 1;
    public static final int STOP_COLOR_INDEX = SHAPE_RENDERING_INDEX + 1;
    public static final int STOP_OPACITY_INDEX = STOP_COLOR_INDEX + 1;
    public static final int STROKE_INDEX = STOP_OPACITY_INDEX + 1;


    public static final int STROKE_DASHARRAY_INDEX = STROKE_INDEX + 1;
    public static final int STROKE_DASHOFFSET_INDEX =
        STROKE_DASHARRAY_INDEX + 1;
    public static final int STROKE_LINECAP_INDEX = STROKE_DASHOFFSET_INDEX + 1;
    public static final int STROKE_LINEJOIN_INDEX = STROKE_LINECAP_INDEX + 1;
    public static final int STROKE_MITERLIMIT_INDEX =
        STROKE_LINEJOIN_INDEX + 1;


    public static final int STROKE_OPACITY_INDEX = STROKE_MITERLIMIT_INDEX + 1;
    public static final int STROKE_WIDTH_INDEX = STROKE_OPACITY_INDEX + 1;
    public static final int TEXT_ANCHOR_INDEX = STROKE_WIDTH_INDEX + 1;
    public static final int TEXT_DECORATION_INDEX = TEXT_ANCHOR_INDEX + 1;
    public static final int TEXT_RENDERING_INDEX = TEXT_DECORATION_INDEX + 1;


    public static final int UNICODE_BIDI_INDEX = TEXT_RENDERING_INDEX + 1;
    public static final int VISIBILITY_INDEX = UNICODE_BIDI_INDEX + 1;
    public static final int WORD_SPACING_INDEX = VISIBILITY_INDEX + 1;
    public static final int WRITING_MODE_INDEX = WORD_SPACING_INDEX + 1;
    public static final int FINAL_INDEX = WRITING_MODE_INDEX;

}
