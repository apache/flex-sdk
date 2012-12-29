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
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.OpacityManager;
import org.apache.flex.forks.batik.css.engine.value.svg12.LineHeightManager;
import org.apache.flex.forks.batik.css.engine.value.svg12.MarginLengthManager;
import org.apache.flex.forks.batik.css.engine.value.svg12.MarginShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.svg12.TextAlignManager;
import org.apache.flex.forks.batik.css.parser.ExtendedParser;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVG12CSSConstants;

import org.w3c.dom.Document;

/**
 * This class provides a CSS engine initialized for SVG.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVG12CSSEngine.java 578680 2007-09-24 07:20:03Z cam $
 */
public class SVG12CSSEngine extends SVGCSSEngine {

    /**
     * Creates a new SVG12CSSEngine.
     * @param doc The associated document.
     * @param uri The document URI.
     * @param p The CSS parser to use.
     * @param ctx The CSS context.
     */
    public SVG12CSSEngine(Document doc,
                          ParsedURL uri,
                          ExtendedParser p,
                          CSSContext ctx) {
        super(doc, uri, p,
              SVG_VALUE_MANAGERS,
              SVG_SHORTHAND_MANAGERS,
              ctx);
        lineHeightIndex = LINE_HEIGHT_INDEX;
    }

    /**
     * Creates a new SVG12CSSEngine.
     * @param doc The associated document.
     * @param uri The document URI.
     * @param p The CSS parser to use.
     * @param vms Extension value managers.
     * @param sms Extension shorthand managers.
     * @param ctx The CSS context.
     */
    public SVG12CSSEngine(Document doc,
                          ParsedURL uri,
                          ExtendedParser p,
                          ValueManager[] vms,
                          ShorthandManager[] sms,
                          CSSContext ctx) {
        super(doc, uri, p,
              mergeArrays(SVG_VALUE_MANAGERS, vms),
              mergeArrays(SVG_SHORTHAND_MANAGERS, sms),
              ctx);
        lineHeightIndex = LINE_HEIGHT_INDEX;
    }

    /**
     * The value managers for SVG.
     */
    public static final ValueManager[] SVG_VALUE_MANAGERS = {
        new LineHeightManager  (),
        new MarginLengthManager(SVG12CSSConstants.CSS_INDENT_PROPERTY),
        new MarginLengthManager(SVG12CSSConstants.CSS_MARGIN_BOTTOM_PROPERTY),
        new MarginLengthManager(SVG12CSSConstants.CSS_MARGIN_LEFT_PROPERTY),
        new MarginLengthManager(SVG12CSSConstants.CSS_MARGIN_RIGHT_PROPERTY),
        new MarginLengthManager(SVG12CSSConstants.CSS_MARGIN_TOP_PROPERTY),
        new SVGColorManager    (SVG12CSSConstants.CSS_SOLID_COLOR_PROPERTY),
        new OpacityManager     (SVG12CSSConstants.CSS_SOLID_OPACITY_PROPERTY,
                                true),
        new TextAlignManager   (),
    };

    /**
     * The shorthand managers for SVG.
     */
    public static final ShorthandManager[] SVG_SHORTHAND_MANAGERS = {
        new MarginShorthandManager(),
    };

    //
    // The property indexes.
    //
    public static final int LINE_HEIGHT_INDEX   = SVGCSSEngine.FINAL_INDEX+1;
    public static final int INDENT_INDEX        = LINE_HEIGHT_INDEX+1;
    public static final int MARGIN_BOTTOM_INDEX = INDENT_INDEX+1;
    public static final int MARGIN_LEFT_INDEX   = MARGIN_BOTTOM_INDEX+1;
    public static final int MARGIN_RIGHT_INDEX  = MARGIN_LEFT_INDEX+1;
    public static final int MARGIN_TOP_INDEX    = MARGIN_RIGHT_INDEX+1;
    public static final int SOLID_COLOR_INDEX   = MARGIN_TOP_INDEX+1;
    public static final int SOLID_OPACITY_INDEX = SOLID_COLOR_INDEX+1;
    public static final int TEXT_ALIGN_INDEX    = SOLID_OPACITY_INDEX+1;
    public static final int FINAL_INDEX         = TEXT_ALIGN_INDEX;
}
