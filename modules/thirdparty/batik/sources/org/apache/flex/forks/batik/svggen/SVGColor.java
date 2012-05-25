/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.svggen;

import java.awt.Color;
import java.awt.Paint;
import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;

/**
 * Utility class that converts a Color object into a set of
 * corresponding SVG attributes.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGColor.java,v 1.14 2004/08/18 07:14:59 vhardy Exp $
 * @see                 org.apache.flex.forks.batik.svggen.DOMTreeManager
 */
public class SVGColor extends AbstractSVGConverter{
    /**
     * Predefined CSS colors
     */
    public static final Color aqua = new Color(0x00, 0xff, 0xff);
    public static final Color black = Color.black;
    public static final Color blue = Color.blue;
    public static final Color fuchsia = new Color(0xff, 0x00, 0xff);
    public static final Color gray = new Color(0x80, 0x80, 0x80);
    public static final Color green = new Color(0x00, 0x80, 0x00);
    public static final Color lime = new Color(0x00, 0xff, 0x00);
    public static final Color maroon = new Color(0x80, 0x00, 0x00);
    public static final Color navy = new Color(0x00, 0x00, 0x80);
    public static final Color olive = new Color(0x80, 0x80, 00);
    public static final Color purple = new Color(0x80, 0x00, 0x80);
    public static final Color red = new Color(0xff, 0x00, 0x00);
    public static final Color silver = new Color(0xc0, 0xc0, 0xc0);
    public static final Color teal = new Color(0x00, 0x80, 0x80);
    public static final Color white = Color.white;
    public static final Color yellow = Color.yellow;

    /**
     * Color map maps Color values to HTML 4.0 color names
     */
    private static Map colorMap = new HashMap();

    static {
        colorMap.put(black, "black");
        colorMap.put(silver, "silver");
        colorMap.put(gray, "gray");
        colorMap.put(white, "white");
        colorMap.put(maroon, "maroon");
        colorMap.put(red, "red");
        colorMap.put(purple, "purple");
        colorMap.put(fuchsia, "fuchsia");
        colorMap.put(green, "green");
        colorMap.put(lime, "lime");
        colorMap.put(olive, "olive");
        colorMap.put(yellow, "yellow");
        colorMap.put(navy, "navy");
        colorMap.put(blue, "blue");
        colorMap.put(teal, "teal");
        colorMap.put(aqua, "aqua");
    }

    /**
     * @param generatorContext used by converter to handle precision
     *        or to create elements.
     */
    public SVGColor(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * Converts part or all of the input GraphicContext into
     * a set of attribute/value pairs and related definitions
     *
     * @param gc GraphicContext to be converted
     * @return descriptor of the attributes required to represent
     *         some or all of the GraphicContext state, along
     *         with the related definitions
     * @see org.apache.flex.forks.batik.svggen.SVGDescriptor
     */
    public SVGDescriptor toSVG(GraphicContext gc) {
        Paint paint = gc.getPaint();
        return toSVG((Color)paint, generatorContext);
    }

    /**
     * Converts a Color object to a set of two corresponding
     * values: a CSS color string and an opacity value.
     */
    public static SVGPaintDescriptor toSVG(Color color, SVGGeneratorContext gc) {
        //
        // First, convert the color value
        //
        String cssColor = (String)colorMap.get(color);
        if (cssColor==null) {
            // color is not one of the predefined colors
            StringBuffer cssColorBuffer = new StringBuffer(RGB_PREFIX);
            cssColorBuffer.append(color.getRed());
            cssColorBuffer.append(COMMA);
            cssColorBuffer.append(color.getGreen());
            cssColorBuffer.append(COMMA);
            cssColorBuffer.append(color.getBlue());
            cssColorBuffer.append(RGB_SUFFIX);
            cssColor = cssColorBuffer.toString();
        }

        //
        // Now, convert the alpha value, if needed
        //
        float alpha = color.getAlpha()/255f;

        String alphaString = gc.doubleString(alpha);

        return new SVGPaintDescriptor(cssColor, alphaString);
    }
}
