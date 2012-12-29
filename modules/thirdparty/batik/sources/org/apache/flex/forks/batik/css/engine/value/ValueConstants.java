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
package org.apache.flex.forks.batik.css.engine.value;

import org.apache.flex.forks.batik.util.CSSConstants;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This interface defines constants for CSS values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ValueConstants.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface ValueConstants {
    
    /**
     * 0
     */
    Value NUMBER_0 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 0);

    /**
     * 100
     */
    Value NUMBER_100 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 100);

    /**
     * 128
     */
    Value NUMBER_128 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 128);

    /**
     * 192
     */
    Value NUMBER_192 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 192);

    /**
     * 200
     */
    Value NUMBER_200 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 200);

    /**
     * 255
     */
    Value NUMBER_255 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 255);

    /**
     * 300
     */
    Value NUMBER_300 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 300);

    /**
     * 400
     */
    Value NUMBER_400 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 400);

    /**
     * 500
     */
    Value NUMBER_500 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 500);

    /**
     * 600
     */
    Value NUMBER_600 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 600);

    /**
     * 700
     */
    Value NUMBER_700 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 700);

    /**
     * 800
     */
    Value NUMBER_800 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 800);

    /**
     * 900
     */
    Value NUMBER_900 = new FloatValue(CSSPrimitiveValue.CSS_NUMBER, 900);

    /**
     * The 'inherit' value.
     */
    Value INHERIT_VALUE = InheritValue.INSTANCE;

    /**
     * The 'all' keyword.
     */
    Value ALL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_ALL_VALUE);
    
    /**
     * The 'auto' keyword.
     */
    Value AUTO_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_AUTO_VALUE);
    
    /**
     * The 'bidi-override' keyword.
     */
    Value BIDI_OVERRIDE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BIDI_OVERRIDE_VALUE);

    /**
     * The 'blink' keyword.
     */
    Value BLINK_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BLINK_VALUE);
    
    /**
     * The 'block' keyword.
     */
    Value BLOCK_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BLOCK_VALUE);
    
    /**
     * The 'bold' keyword.
     */
    Value BOLD_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BOLD_VALUE);
    
    /**
     * The 'bolder' keyword.
     */
    Value BOLDER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BOLDER_VALUE);
    
    /**
     * The 'bottom' keyword.
     */
    Value BOTTOM_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BOTTOM_VALUE);
    
    /**
     * The 'collapse' keyword.
     */
    Value COLLAPSE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_COLLAPSE_VALUE);
    
    /**
     * The 'compact' keyword.
     */
    Value COMPACT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_COMPACT_VALUE);
    
    /**
     * The 'condensed' keyword.
     */
    Value CONDENSED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_CONDENSED_VALUE);

    /**
     * The 'crispedges' keyword.
     */
    Value CRISPEDGES_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_CRISPEDGES_VALUE);

    /**
     * The 'crosshair' keyword.
     */
    Value CROSSHAIR_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_CROSSHAIR_VALUE);
    
    /**
     * The 'cursive' keyword.
     */
    Value CURSIVE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_CURSIVE_VALUE);
    
    /**
     * The 'default' keyword.
     */
    Value DEFAULT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_DEFAULT_VALUE);
    
    /**
     * The 'e-resize' keyword.
     */
    Value E_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_E_RESIZE_VALUE);
    
    /**
     * The 'embed' keyword.
     */
    Value EMBED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_EMBED_VALUE);
    
    /**
     * The 'expanded' keyword.
     */
    Value EXPANDED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_EXPANDED_VALUE);

    /**
     * The 'extra-condensed' keyword.
     */
    Value EXTRA_CONDENSED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_EXTRA_CONDENSED_VALUE);

    /**
     * The 'extra-expanded' keyword.
     */
    Value EXTRA_EXPANDED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_EXTRA_EXPANDED_VALUE);

    /**
     * The 'fantasy' keyword.
     */
    Value FANTASY_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_FANTASY_VALUE);
    
    /**
     * The 'help' keyword.
     */
    Value HELP_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_HELP_VALUE);
    
    /**
     * The 'hidden' keyword.
     */
    Value HIDDEN_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_HIDDEN_VALUE);
    
    /**
     * The 'inline' keyword.
     */
    Value INLINE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INLINE_VALUE);
    
    /**
     * The 'inline-table' keyword.
     */
    Value INLINE_TABLE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INLINE_TABLE_VALUE);
    
    /**
     * The 'italic' keyword.
     */
    Value ITALIC_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_ITALIC_VALUE);
    
    /**
     * The 'large' keyword.
     */
    Value LARGE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LARGE_VALUE);
    
    /**
     * The 'larger' keyword.
     */
    Value LARGER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LARGER_VALUE);
    
    /**
     * The 'lighter' keyword.
     */
    Value LIGHTER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LIGHTER_VALUE);
    
    /**
     * The 'line_through' keyword.
     */
    Value LINE_THROUGH_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LINE_THROUGH_VALUE);
    
    /**
     * The 'list-item' keyword.
     */
    Value LIST_ITEM_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LIST_ITEM_VALUE);
    
    /**
     * The 'ltr' keyword.
     */
    Value LTR_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LTR_VALUE);
    
    /**
     * The 'marker' keyword.
     */
    Value MARKER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MARKER_VALUE);
    
    /**
     * The 'medium' keyword.
     */
    Value MEDIUM_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MEDIUM_VALUE);
    
    /**
     * The 'monospaced' keyword.
     */
    Value MONOSPACE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MONOSPACE_VALUE);
    
    /**
     * The 'move' keyword.
     */
    Value MOVE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MOVE_VALUE);
    
    /**
     * The 'n-resize' keyword.
     */
    Value N_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_N_RESIZE_VALUE);
    
    /**
     * The 'narrower' keyword.
     */
    Value NARROWER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_NARROWER_VALUE);

    /**
     * The 'ne-resize' keyword.
     */
    Value NE_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_NE_RESIZE_VALUE);
    
    /**
     * The 'nw-resize' keyword.
     */
    Value NW_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_NW_RESIZE_VALUE);
    
    /**
     * The 'none' keyword.
     */
    Value NONE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_NONE_VALUE);

    /**
     * The 'normal' keyword.
     */
    Value NORMAL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_NORMAL_VALUE);

    /**
     * The 'oblique' keyword.
     */
    Value OBLIQUE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_OBLIQUE_VALUE);
    
    /**
     * The 'overline' keyword.
     */
    Value OVERLINE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_OVERLINE_VALUE);
    
    /**
     * The 'pointer' keyword.
     */
    Value POINTER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_POINTER_VALUE);

    /**
     * The 'painted' keyword.
     */
    Value PAINTED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_PAINTED_VALUE);
    
    /**
     * The 'rtl' keyword.
     */
    Value RTL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_RTL_VALUE);

    /**
     * The 'run-in' keyword.
     */
    Value RUN_IN_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_RUN_IN_VALUE);

    /**
     * The 's-resize' keyword.
     */
    Value S_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_S_RESIZE_VALUE);
    
    /**
     * The 'sans-serif' keyword.
     */
    Value SANS_SERIF_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SANS_SERIF_VALUE);
    
    /**
     * The 'scroll' keyword.
     */
    Value SCROLL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SCROLL_VALUE);

    /**
     * The 'se-resize' keyword.
     */
    Value SE_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SE_RESIZE_VALUE);
    
    /**
     * The 'semi-condensed' keyword.
     */
    Value SEMI_CONDENSED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SEMI_CONDENSED_VALUE);

    /**
     * The 'semi-expanded' keyword.
     */
    Value SEMI_EXPANDED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SEMI_EXPANDED_VALUE);

    /**
     * The 'serif' keyword.
     */
    Value SERIF_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SERIF_VALUE);
    
    /**
     * The 'small' keyword.
     */
    Value SMALL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SMALL_VALUE);
    
    /**
     * The 'small-caps' keyword.
     */
    Value SMALL_CAPS_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SMALL_CAPS_VALUE);
    
    /**
     * The 'smaller' keyword.
     */
    Value SMALLER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SMALLER_VALUE);
    
    /**
     * The 'stroke' keyword.
     */
    Value STROKE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_STROKE_VALUE);
    
    /**
     * The 'sw-resize' keyword.
     */
    Value SW_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SW_RESIZE_VALUE);
    
    /**
     * The 'table' keyword.
     */
    Value TABLE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_VALUE);
    
    /**
     * The 'table-caption' keyword.
     */
    Value TABLE_CAPTION_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_CAPTION_VALUE);
    
    /**
     * The 'table-cell' keyword.
     */
    Value TABLE_CELL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_CELL_VALUE);
    
    /**
     * The 'table-column' keyword.
     */
    Value TABLE_COLUMN_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_COLUMN_VALUE);
    
    /**
     * The 'table-column-group' keyword.
     */
    Value TABLE_COLUMN_GROUP_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_COLUMN_GROUP_VALUE);
    
    /**
     * The 'table-footer-group' keyword.
     */
    Value TABLE_FOOTER_GROUP_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_FOOTER_GROUP_VALUE);
    
    /**
     * The 'table-header-group' keyword.
     */
    Value TABLE_HEADER_GROUP_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_HEADER_GROUP_VALUE);
    
    /**
     * The 'table-row' keyword.
     */
    Value TABLE_ROW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_ROW_VALUE);
    
    /**
     * The 'table-row-group' keyword.
     */
    Value TABLE_ROW_GROUP_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TABLE_ROW_GROUP_VALUE);
    
    /**
     * The 'text' keyword.
     */
    Value TEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TEXT_VALUE);
     
    /**
     * The 'ultra-condensed' keyword.
     */
    Value ULTRA_CONDENSED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_ULTRA_CONDENSED_VALUE);

    /**
     * The 'ultra-expanded' keyword.
     */
    Value ULTRA_EXPANDED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_ULTRA_EXPANDED_VALUE);

    /**
     * The 'top' keyword.
     */
    Value TOP_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TOP_VALUE);
   
    /**
     * The 'underline' keyword.
     */
    Value UNDERLINE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_UNDERLINE_VALUE);
   
    /**
     * The 'visible' keyword.
     */
    Value VISIBLE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_VISIBLE_VALUE);
   
    /**
     * The 'w-resize' keyword.
     */
    Value W_RESIZE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_W_RESIZE_VALUE);
    
    /**
     * The 'wait' keyword.
     */
    Value WAIT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_WAIT_VALUE);
    
    /**
     * The 'wider' keyword.
     */
    Value WIDER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_WIDER_VALUE);
    
    /**
     * The 'x-large' keyword.
     */
    Value X_LARGE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_X_LARGE_VALUE);
    
    /**
     * The 'x-small' keyword.
     */
    Value X_SMALL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_X_SMALL_VALUE);
    
    /**
     * The 'xx-large' keyword.
     */
    Value XX_LARGE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_XX_LARGE_VALUE);

    /**
     * The 'xx-small' keyword.
     */
    Value XX_SMALL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_XX_SMALL_VALUE);

    /**
     * The 'aqua' color name.
     */
    Value AQUA_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_AQUA_VALUE);

    /**
     * The 'black' color name.
     */
    Value BLACK_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BLACK_VALUE);

    /**
     * The 'blue' color name.
     */
    Value BLUE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BLUE_VALUE);

    /**
     * The 'fuchsia' color name.
     */
    Value FUCHSIA_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_FUCHSIA_VALUE);

    /**
     * The 'gray' color name.
     */
    Value GRAY_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_GRAY_VALUE);

    /**
     * The 'green' color name.
     */
    Value GREEN_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_GREEN_VALUE);

    /**
     * The 'lime' color name.
     */
    Value LIME_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_LIME_VALUE);

    /**
     * The 'maroon' color name.
     */
    Value MAROON_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MAROON_VALUE);

    /**
     * The 'navy' color name.
     */
    Value NAVY_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_NAVY_VALUE);

    /**
     * The 'olive' color name.
     */
    Value OLIVE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_OLIVE_VALUE);

    /**
     * The 'purple' color name.
     */
    Value PURPLE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_PURPLE_VALUE);

    /**
     * The 'red' color name.
     */
    Value RED_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_RED_VALUE);

    /**
     * The 'silver' color name.
     */
    Value SILVER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SILVER_VALUE);

    /**
     * The 'teal' color name.
     */
    Value TEAL_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_TEAL_VALUE);

    /**
     * The 'white' color name.
     */
    Value WHITE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_WHITE_VALUE);

    /**
     * The 'yellow' color name.
     */
    Value YELLOW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_YELLOW_VALUE);

    /**
     * The 'ACTIVEBORDER' color name.
     */
    Value ACTIVEBORDER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_ACTIVEBORDER_VALUE);

    /**
     * The 'ACTIVECAPTION' color name.
     */
    Value ACTIVECAPTION_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_ACTIVECAPTION_VALUE);

    /**
     * The 'APPWORKSPACE' color name.
     */
    Value APPWORKSPACE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_APPWORKSPACE_VALUE);

    /**
     * The 'BACKGROUND' color name.
     */
    Value BACKGROUND_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BACKGROUND_VALUE);

    /**
     * The 'BUTTONFACE' color name.
     */
    Value BUTTONFACE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BUTTONFACE_VALUE);

    /**
     * The 'BUTTONHIGHLIGHT' color name.
     */
    Value BUTTONHIGHLIGHT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BUTTONHIGHLIGHT_VALUE);

    /**
     * The 'BUTTONSHADOW' color name.
     */
    Value BUTTONSHADOW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BUTTONSHADOW_VALUE);

    /**
     * The 'BUTTONTEXT' color name.
     */
    Value BUTTONTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_BUTTONTEXT_VALUE);

    /**
     * The 'CAPTIONTEXT' color name.
     */
    Value CAPTIONTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_CAPTIONTEXT_VALUE);

    /**
     * The 'GRAYTEXT' color name.
     */
    Value GRAYTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_GRAYTEXT_VALUE);

    /**
     * The 'HIGHLIGHT' color name.
     */
    Value HIGHLIGHT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_HIGHLIGHT_VALUE);

    /**
     * The 'HIGHLIGHTTEXT' color name.
     */
    Value HIGHLIGHTTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_HIGHLIGHTTEXT_VALUE);

    /**
     * The 'INACTIVEBORDER' color name.
     */
    Value INACTIVEBORDER_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INACTIVEBORDER_VALUE);

    /**
     * The 'INACTIVECAPTION' color name.
     */
    Value INACTIVECAPTION_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INACTIVECAPTION_VALUE);

    /**
     * The 'INACTIVECAPTIONTEXT' color name.
     */
    Value INACTIVECAPTIONTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INACTIVECAPTIONTEXT_VALUE);

    /**
     * The 'INFOBACKGROUND' color name.
     */
    Value INFOBACKGROUND_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INFOBACKGROUND_VALUE);

    /**
     * The 'INFOTEXT' color name.
     */
    Value INFOTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_INFOTEXT_VALUE);

    /**
     * The 'MENU' color name.
     */
    Value MENU_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MENU_VALUE);

    /**
     * The 'MENUTEXT' color name.
     */
    Value MENUTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_MENUTEXT_VALUE);

    /**
     * The 'SCROLLBAR' color name.
     */
    Value SCROLLBAR_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_SCROLLBAR_VALUE);

    /**
     * The 'THREEDDARKSHADOW' color name.
     */
    Value THREEDDARKSHADOW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_THREEDDARKSHADOW_VALUE);

    /**
     * The 'THREEDFACE' color name.
     */
    Value THREEDFACE_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_THREEDFACE_VALUE);

    /**
     * The 'THREEDHIGHLIGHT' color name.
     */
    Value THREEDHIGHLIGHT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_THREEDHIGHLIGHT_VALUE);

    /**
     * The 'THREEDLIGHTSHADOW' color name.
     */
    Value THREEDLIGHTSHADOW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_THREEDLIGHTSHADOW_VALUE);

    /**
     * The 'THREEDSHADOW' color name.
     */
    Value THREEDSHADOW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_THREEDSHADOW_VALUE);

    /**
     * The 'WINDOW' color name.
     */
    Value WINDOW_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_WINDOW_VALUE);

    /**
     * The 'WINDOWFRAME' color name.
     */
    Value WINDOWFRAME_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_WINDOWFRAME_VALUE);

    /**
     * The 'WINDOWTEXT' color name.
     */
    Value WINDOWTEXT_VALUE =
        new StringValue(CSSPrimitiveValue.CSS_IDENT,
                        CSSConstants.CSS_WINDOWTEXT_VALUE);


    /**
     * The 'black' RGB color.
     */
    Value BLACK_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_0, NUMBER_0);

    /**
     * The 'silver' RGB color.
     */
    Value SILVER_RGB_VALUE =
        new RGBColorValue(NUMBER_192, NUMBER_192, NUMBER_192);

    /**
     * The 'gray' RGB color.
     */
    Value GRAY_RGB_VALUE =
        new RGBColorValue(NUMBER_128, NUMBER_128, NUMBER_128);

    /**
     * The 'white' RGB color.
     */
    Value WHITE_RGB_VALUE =
        new RGBColorValue(NUMBER_255, NUMBER_255, NUMBER_255);

    /**
     * The 'maroon' RGB color.
     */
    Value MAROON_RGB_VALUE =
        new RGBColorValue(NUMBER_128, NUMBER_0, NUMBER_0);

    /**
     * The 'red' RGB color.
     */
    Value RED_RGB_VALUE =
        new RGBColorValue(NUMBER_255, NUMBER_0, NUMBER_0);

    /**
     * The 'purple' RGB color.
     */
    Value PURPLE_RGB_VALUE =
        new RGBColorValue(NUMBER_128, NUMBER_0, NUMBER_128);

    /**
     * The 'fuchsia' RGB color.
     */
    Value FUCHSIA_RGB_VALUE =
        new RGBColorValue(NUMBER_255, NUMBER_0, NUMBER_255);

    /**
     * The 'green' RGB color.
     */
    Value GREEN_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_128, NUMBER_0);

    /**
     * The 'lime' RGB color.
     */
    Value LIME_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_255, NUMBER_0);

    /**
     * The 'olive' RGB color.
     */
    Value OLIVE_RGB_VALUE =
        new RGBColorValue(NUMBER_128, NUMBER_128, NUMBER_0);

    /**
     * The 'yellow' RGB color.
     */
    Value YELLOW_RGB_VALUE =
        new RGBColorValue(NUMBER_255, NUMBER_255, NUMBER_0);

    /**
     * The 'navy' RGB color.
     */
    Value NAVY_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_0, NUMBER_128);

    /**
     * The 'blue' RGB color.
     */
    Value BLUE_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_0, NUMBER_255);

    /**
     * The 'teal' RGB color.
     */
    Value TEAL_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_128, NUMBER_128);

    /**
     * The 'aqua' RGB color.
     */
    Value AQUA_RGB_VALUE =
        new RGBColorValue(NUMBER_0, NUMBER_255, NUMBER_255);

}
