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

package org.apache.flex.forks.batik.transcoder.wmf.tosvg;

import java.awt.Paint;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.TexturePaint;
import java.awt.image.BufferedImage;
import java.awt.geom.*;
import java.util.Map;
import java.util.HashMap;

import org.apache.flex.forks.batik.transcoder.wmf.WMFConstants;

/**
 * This class generate Paints from WMF hatch definitions. All generated
 * Paints are cached for future use.
 *
 * @version $Id: TextureFactory.java 498747 2007-01-22 18:56:19Z dvholten $
 */
public class TextureFactory {
    private static TextureFactory fac = null;
    private Map textures = new HashMap(1);
    private static final int SIZE = 10;
    private float scale = 1.0f;

    private TextureFactory(float scale) {
    }

    /** Get the unique instance of the class.
     */
    public static TextureFactory getInstance() {
        if (fac == null) fac = new TextureFactory(1.0f);
        return fac;
    }

    /** Get the unique instance of the class, setting the scale of the pattern.
     *  TODO : scale is not handled for now
     */
    public static TextureFactory getInstance(float scale) {
        if (fac == null) fac = new TextureFactory(scale);
        return fac;
    }

    /** Rest the factory. It empties all the previouly cached Paints are
     * disposed of.
     */
    public void reset() {
        textures.clear();
    }

    /** Get a texture from a WMF hatch definition (in black Color). This
     *  texture will be cached, so the Paint will only be created once.
     */
    public Paint getTexture(int textureId) {
        Integer _itexture = new Integer(textureId);
        if (textures.containsKey( _itexture)) {
            Paint paint = (Paint)(textures.get(_itexture));
            return paint;
        } else {
            Paint paint = createTexture(textureId, null, null);
            if (paint != null) textures.put(_itexture, paint);
            return paint;
        }
    }

    /** Get a texture from a WMF hatch definition, with a foreground color. This
     *  texture will be cached, so the Paint will only be created once.
     */
    public Paint getTexture(int textureId, Color foreground) {
        ColoredTexture _ctexture = new ColoredTexture(textureId, foreground, null);
        if (textures.containsKey(_ctexture)) {
            Paint paint = (Paint)(textures.get(_ctexture));
            return paint;
        } else {
            Paint paint = createTexture(textureId, foreground, null);
            if (paint != null) textures.put(_ctexture, paint);
            return paint;
        }
    }

    /** Get a texture from a WMF hatch definition, with a foreground and a
     *  background color. This texture will be cached, so the Paint will
     * only be created once.
     */
    public Paint getTexture(int textureId, Color foreground, Color background) {
        ColoredTexture _ctexture = new ColoredTexture(textureId, foreground, background);
        if (textures.containsKey(_ctexture)) {
            Paint paint = (Paint)(textures.get(_ctexture));
            return paint;
        } else {
            Paint paint = createTexture(textureId, foreground, background);
            if (paint != null) textures.put(_ctexture, paint);
            return paint;
        }
    }

    /** Called internally if the Paint does not exist in the cache and must
     *  be created.
     */
    private Paint createTexture(int textureId, Color foreground, Color background) {
        BufferedImage img = new BufferedImage(SIZE, SIZE, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2d = img.createGraphics();
        Rectangle2D rec = new Rectangle2D.Float(0, 0, SIZE, SIZE);
        Paint paint = null;
        boolean ok = false;
        if (background != null) {
            g2d.setColor(background);
            g2d.fillRect(0, 0, SIZE, SIZE);
        }
        if (foreground == null) g2d.setColor(Color.black);
        else g2d.setColor(foreground);

        if (textureId == WMFConstants.HS_VERTICAL) {
            for (int i = 0; i < 5; i++) {
                g2d.drawLine(i*10, 0, i*10, SIZE);
            }
            ok = true;
        } else if (textureId == WMFConstants.HS_HORIZONTAL) {
            for (int i = 0; i < 5; i++) {
                g2d.drawLine(0, i*10, SIZE, i*10);
            }
            ok = true;
        } else if (textureId == WMFConstants.HS_BDIAGONAL) {
            for (int i = 0; i < 5; i++) {
                g2d.drawLine(0, i*10, i*10, 0);
            }
            ok = true;
        } else if (textureId == WMFConstants.HS_FDIAGONAL) {
            for (int i = 0; i < 5; i++) {
                g2d.drawLine(0, i*10, SIZE - i*10, SIZE);
            }
            ok = true;
        } else if (textureId == WMFConstants.HS_DIAGCROSS) {
            for (int i = 0; i < 5; i++) {
                g2d.drawLine(0, i*10, i*10, 0);
                g2d.drawLine(0, i*10, SIZE - i*10, SIZE);
            }
            ok = true;
        } else if (textureId == WMFConstants.HS_CROSS) {
            for (int i = 0; i < 5; i++) {
                g2d.drawLine(i*10, 0, i*10, SIZE);
                g2d.drawLine(0, i*10, SIZE, i*10);
            }
            ok = true;
        }
        img.flush();
        if (ok) paint = new TexturePaint(img, rec);
        return paint;
    }

    /** Contain a handle to a Colored texture, with optional foreground and
     * background colors.
     */
    private class ColoredTexture {

        final int textureId;
        final Color foreground;
        final Color background;

        ColoredTexture(int textureId, Color foreground, Color background) {
            this.textureId = textureId;
            this.foreground = foreground;
            this.background = background;
        }
    }
}
