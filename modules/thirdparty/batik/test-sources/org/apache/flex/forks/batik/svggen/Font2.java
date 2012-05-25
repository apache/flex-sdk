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
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.font.FontRenderContext;

/**
 * This test validates the convertion of Java 2D text into
 * SVG Shapes, one of the options of the SVGGraphics2D constructor.
 * This is the same test as Font testing with regards to the
 * Java 2D API code, except that it validates text to shapes
 * convertion.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Font2.java,v 1.7 2004/08/18 07:16:44 vhardy Exp $
 */
public class Font2 implements Painter {
    public void paint(Graphics2D g) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                           RenderingHints.VALUE_ANTIALIAS_ON);

        // Set default font
        g.setFont(new Font("Arial", Font.BOLD, 12));

        // Colors used for labels and test output
        Color labelColor = new Color(0x666699);
        Color fontColor = Color.black;

        //
        // First, font size
        //
        java.awt.geom.AffineTransform defaultTransform = g.getTransform();
        Font defaultFont = new Font("Arial", Font.BOLD, 16);
        g.setFont(defaultFont);
        FontRenderContext frc = g.getFontRenderContext();
        g.setPaint(labelColor);

        g.drawString("Font size", 10, 30);
        g.setPaint(fontColor);
        g.translate(0, 20);
        int fontSizes[] = { 6, 8, 10, 12, 18, 36, 48 };
        for(int i=0; i<fontSizes.length; i++){
            Font font = new Font(defaultFont.getFamily(),
                                 Font.PLAIN,
                                 fontSizes[i]);
            g.setFont(font);
            g.drawString("aA", 10, 40);
            double width = font.createGlyphVector(frc, "aA").getVisualBounds().getWidth();
            g.translate(width*1.2, 0);
        }

        g.setTransform(defaultTransform);
        g.translate(0, 60);

        //
        // Font style
        //
        int fontStyles[] = { Font.PLAIN,
                             Font.BOLD,
                             Font.ITALIC,
                             Font.BOLD | Font.ITALIC };
        String fontStyleStrings[] = { "Plain", "Bold", "Italic", "Bold Italic" };

        g.setFont(defaultFont);
        g.setPaint(labelColor);
        g.drawString("Font Styles", 10, 30);
        g.translate(0, 20);
        g.setPaint(fontColor);

        for(int i=0; i<fontStyles.length; i++){
            Font font = new Font(defaultFont.getFamily(),
                                 fontStyles[i], 20);
            g.setFont(font);
            g.drawString(fontStyleStrings[i], 10, 40);
            double width = font.createGlyphVector(frc, fontStyleStrings[i]).getVisualBounds().getWidth();
            g.translate(width*1.2, 0);
        }

        g.setTransform(defaultTransform);
        g.translate(0, 120);

        //
        // Font families
        //
        String fontFamilies[] = { "Arial",
                                  "Times New Roman",
                                  "Courier New",
                                  "Verdana" };

        g.setFont(defaultFont);
        g.setPaint(labelColor);
        g.drawString("Font Families", 10, 30);
        g.setPaint(fontColor);

        for(int i=0; i<fontFamilies.length; i++){
            Font font = new Font(fontFamilies[i], Font.PLAIN, 18);
            g.setFont(font);
            double height = font.createGlyphVector(frc, fontFamilies[i]).getVisualBounds().getHeight();
            g.translate(0, height*1.4);
            g.drawString(fontFamilies[i], 10, 40);
        }

        //
        // Logical fonts
        //
          Font logicalFonts[] = { new Font("dialog", Font.PLAIN, 14),
                                  new Font("dialoginput", Font.BOLD, 14),
                                  new Font("monospaced", Font.ITALIC, 14),
                                  new Font("serif", Font.PLAIN, 14),
                                  new Font("sansserif", Font.BOLD, 14)};

          g.translate(0, 70);
          g.setFont(defaultFont);
          g.setPaint(labelColor);
          g.drawString("Logical Fonts", 10, 0);
          g.setPaint(fontColor);

          for(int i=0; i<logicalFonts.length; i++){
              Font font = logicalFonts[i];
              g.setFont(font);
              double height = font.createGlyphVector(frc, font.getName()).getVisualBounds().getHeight();
              g.translate(0, height*1.4);
              g.drawString(font.getName(), 10, 0);
          }
    }
}
