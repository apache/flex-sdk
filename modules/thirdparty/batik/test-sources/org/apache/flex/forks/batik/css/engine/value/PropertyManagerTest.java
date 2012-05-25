/*
 * Copyright 1999-2004 The Apache Software Foundation.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.flex.forks.batik.css.engine.value;

import java.util.StringTokenizer;

import org.w3c.flex.forks.css.sac.LexicalUnit;

import org.apache.flex.forks.batik.css.engine.value.svg.MarkerManager;
import org.apache.flex.forks.batik.css.engine.value.svg.OpacityManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGPaintManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SpacingManager;
import org.apache.flex.forks.batik.css.parser.Parser;
import org.apache.flex.forks.batik.test.AbstractTest;
import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.TestReport;
import org.apache.flex.forks.batik.util.CSSConstants;

/**
 * The class to test the CSS properties's manager.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: PropertyManagerTest.java,v 1.4 2005/04/01 02:28:16 deweese Exp $
 */
public class PropertyManagerTest extends AbstractTest {

    /**
     * The error code for the 'is inherited' test.
     */
    public static final String ERROR_IS_INHERITED =
        "PropertyManagerTest.error.inherited";

    /**
     * The error code if the property does not support the 'inherit' value.
     */
    public static final String ERROR_INHERIT_VALUE =
        "PropertyManagerTest.error.inherit.value";

    /**
     * The error code for the 'default value' test.
     */
    public static final String ERROR_INVALID_DEFAULT_VALUE =
        "PropertyManagerTest.error.invalid.default.value";

    /**
     * The error code for an invalid property value.
     */
    public static final String ERROR_INVALID_VALUE =
        "PropertyManagerTest.error.invalid.value";

    /**
     * The error code if an exception occured while creating the manager.
     */
    public static final String ERROR_INSTANTIATION =
        "PropertyManagerTest.error.instantiation";

    /**
     * The class of the manager.
     */
    protected String managerClassName;

    /**
     * This flag bit indicates whether or not the property is inherited.
     */
    protected Boolean isInherited;

    /**
     * The candidate values of the property.
     */
    protected String [] identValues;

    /**
     * The candidate default value of the property.
     */
    protected String defaultValue;

    /**
     * Constructs a new test for the specified manager classname.
     *
     * @param managerClassName the classname of the manager to test
     * @param isInherited the expected flag to see if the property is inherited
     * @param defaultValue the default value
     * @param identValueList the list of possible identifiers
     */
    public PropertyManagerTest(String managerClassName,
                               Boolean isInherited,
                               String defaultValue,
                               String identValueList) {
        this.managerClassName = managerClassName;
        this.isInherited = isInherited;
        this.defaultValue = defaultValue;
        StringTokenizer tokens = new StringTokenizer(identValueList, "|");
        int nbIdentValue = tokens.countTokens();
        if (nbIdentValue > 0) {
            identValues = new String[nbIdentValue];
            for (int i=0; tokens.hasMoreTokens(); ++i) {
                identValues[i] = tokens.nextToken().trim();
            }
        }
    }

    /**
     * Creates the value manager.
     */
    protected ValueManager createValueManager() throws Exception {
        return (ValueManager)Class.forName(managerClassName).newInstance();
    }

    /**
     * Runs this test. This method will only throw exceptions if some aspect of
     * the test's internal operation fails.
     */
    public TestReport runImpl() throws Exception {
        DefaultTestReport report = new DefaultTestReport(this);

        ValueManager manager;
        try {
            manager = createValueManager();
        } catch (Exception ex) {
            report.setErrorCode(ERROR_INSTANTIATION);
            report.setPassed(false);
            report.addDescriptionEntry(ERROR_INSTANTIATION, ex.getMessage());
            return report;
        }

        // test default value if any
        if (!defaultValue.equals("__USER_AGENT__")) {
            String s = manager.getDefaultValue().getCssText();
            if (!defaultValue.equalsIgnoreCase(s)) {
                report.setErrorCode(ERROR_INVALID_DEFAULT_VALUE);
                report.setPassed(false);
                report.addDescriptionEntry(ERROR_INVALID_DEFAULT_VALUE,
                                           "should be: "+defaultValue);
            }
        }

        // test if the property is inherited or not
        if (isInherited.booleanValue() != manager.isInheritedProperty()) {
            report.setErrorCode(ERROR_IS_INHERITED);
            report.setPassed(false);
            report.addDescriptionEntry(ERROR_IS_INHERITED, "");
        }

        Parser cssParser = new Parser();
        // see if the property supports the value 'inherit'
        try {
            LexicalUnit lu = cssParser.parsePropertyValue("inherit");
            Value v = manager.createValue(lu, null);
            String s = v.getCssText();
            if (!"inherit".equalsIgnoreCase(s)) {
                report.setErrorCode(ERROR_INHERIT_VALUE);
                report.setPassed(false);
                report.addDescriptionEntry(ERROR_INHERIT_VALUE, "inherit");
            }
        } catch (Exception ex) {
            report.setErrorCode(ERROR_INHERIT_VALUE);
            report.setPassed(false);
            report.addDescriptionEntry(ERROR_INHERIT_VALUE, ex.getMessage());
        }

        // test all possible identifiers
        if (identValues != null) {
            try {
                for (int i=0; i < identValues.length; ++i) {
                    LexicalUnit lu = cssParser.parsePropertyValue(identValues[i]);
                    Value v = manager.createValue(lu, null);
                    String s = v.getCssText();
                    if (!identValues[i].equalsIgnoreCase(s)) {
                        report.setErrorCode(ERROR_INVALID_VALUE);
                        report.setPassed(false);
                        report.addDescriptionEntry(ERROR_INVALID_VALUE,
                                                   identValues[i]+"/"+s);
                    }
                }
            } catch (Exception ex) {
                report.setErrorCode(ERROR_INVALID_VALUE);
                report.setPassed(false);
                report.addDescriptionEntry(ERROR_INVALID_VALUE,
                                           ex.getMessage());
            }
        }
        return report;
    }

    /**
     * Manager for 'fill'.
     */
    public static class FillManager extends SVGPaintManager {
        public FillManager() {
            super(CSSConstants.CSS_FILL_PROPERTY);
        }
    }

    /**
     * Manager for 'fill-opacity'.
     */
    public static class FillOpacityManager extends OpacityManager {
        public FillOpacityManager() {
            super(CSSConstants.CSS_FILL_OPACITY_PROPERTY, true);
        }
    }

    /**
     * Manager for 'flood-color'.
     */
    public static class FloodColorManager extends SVGColorManager {
        public FloodColorManager() {
            super(CSSConstants.CSS_FLOOD_COLOR_PROPERTY);
        }
    }

    /**
     * Manager for 'flood-opacity'.
     */
    public static class FloodOpacityManager extends OpacityManager {
        public FloodOpacityManager() {
            super(CSSConstants.CSS_FLOOD_OPACITY_PROPERTY, false);
        }
    }

    /**
     * Manager for 'letter-spacing'.
     */
    public static class LetterSpacingManager extends SpacingManager {
        public LetterSpacingManager() {
            super(CSSConstants.CSS_LETTER_SPACING_PROPERTY);
        }
    }

    /**
     * Manager for 'lighting-color'.
     */
    public static class LightingColorManager extends SVGColorManager {
        public LightingColorManager() {
            super(CSSConstants.CSS_LIGHTING_COLOR_PROPERTY, ValueConstants.WHITE_RGB_VALUE);
        }
    }

    /**
     * Manager for 'marker-end'.
     */
    public static class MarkerEndManager extends MarkerManager {
        public MarkerEndManager() {
            super(CSSConstants.CSS_MARKER_END_PROPERTY);
        }
    }

    /**
     * Manager for 'marker-mid'.
     */
    public static class MarkerMidManager extends MarkerManager {
        public MarkerMidManager() {
            super(CSSConstants.CSS_MARKER_MID_PROPERTY);
        }
    }

    /**
     * Manager for 'marker-start'.
     */
    public static class MarkerStartManager extends MarkerManager {
        public MarkerStartManager() {
            super(CSSConstants.CSS_MARKER_START_PROPERTY);
        }
    }

    /**
     * Manager for 'opacity'.
     */
    public static class DefaultOpacityManager extends OpacityManager {
        public DefaultOpacityManager() {
            super(CSSConstants.CSS_OPACITY_PROPERTY, false);
        }
    }

    /**
     * Manager for 'stop-color'.
     */
    public static class StopColorManager extends SVGColorManager {
        public StopColorManager() {
            super(CSSConstants.CSS_STOP_COLOR_PROPERTY);
        }
    }

    /**
     * Manager for 'stop-opacity'.
     */
    public static class StopOpacityManager extends OpacityManager {
        public StopOpacityManager() {
            super(CSSConstants.CSS_STOP_OPACITY_PROPERTY, false);
        }
    }

    /**
     * Manager for 'stroke'.
     */
    public static class StrokeManager extends SVGPaintManager {
        public StrokeManager() {
            super(CSSConstants.CSS_STROKE_PROPERTY, ValueConstants.NONE_VALUE);
        }
    }

    /**
     * Manager for 'stroke-opacity'.
     */
    public static class StrokeOpacityManager extends OpacityManager {
        public StrokeOpacityManager() {
            super(CSSConstants.CSS_STROKE_OPACITY_PROPERTY, true);
        }
    }

    /**
     * Manager for 'word-spacing'.
     */
    public static class WordSpacingManager extends SpacingManager {
        public WordSpacingManager() {
            super(CSSConstants.CSS_WORD_SPACING_PROPERTY);
        }
    }
}
