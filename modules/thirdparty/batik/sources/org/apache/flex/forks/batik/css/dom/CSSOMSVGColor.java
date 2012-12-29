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
package org.apache.flex.forks.batik.css.dom;

import java.util.ArrayList;

import org.apache.flex.forks.batik.css.engine.value.FloatValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.ICCColor;
import org.apache.flex.forks.batik.util.CSSConstants;

import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.css.Counter;
import org.w3c.dom.css.RGBColor;
import org.w3c.dom.css.Rect;
import org.w3c.dom.svg.SVGColor;
import org.w3c.dom.svg.SVGICCColor;
import org.w3c.dom.svg.SVGNumber;
import org.w3c.dom.svg.SVGNumberList;

/**
 * This class implements the {@link SVGColor} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSOMSVGColor.java 489226 2006-12-21 00:05:36Z cam $
 */
public class CSSOMSVGColor
    implements SVGColor,
               RGBColor,
               SVGICCColor,
               SVGNumberList {

    /**
     * The associated value.
     */
    protected ValueProvider valueProvider;

    /**
     * The modifications handler.
     */
    protected ModificationHandler handler;

    /**
     * The red component, if this value is a RGBColor.
     */
    protected RedComponent redComponent;

    /**
     * The green component, if this value is a RGBColor.
     */
    protected GreenComponent greenComponent;

    /**
     * The blue component, if this value is a RGBColor.
     */
    protected BlueComponent blueComponent;

    /**
     * To store the ICC color list.
     */
    protected ArrayList iccColors;

    /**
     * Creates a new CSSOMSVGColor.
     */
    public CSSOMSVGColor(ValueProvider vp) {
        valueProvider = vp;
    }

    /**
     * Sets the modification handler of this value.
     */
    public void setModificationHandler(ModificationHandler h) {
        handler = h;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.css.CSSValue#getCssText()}.
     */
    public String getCssText() {
        return valueProvider.getValue().getCssText();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSValue#setCssText(String)}.
     */
    public void setCssText(String cssText) throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            iccColors = null;
            handler.textChanged(cssText);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.CSSValue#getCssValueType()}.
     */
    public short getCssValueType() {
        return CSS_CUSTOM;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGColor#getColorType()}.
     */
    public short getColorType() {
        Value value = valueProvider.getValue();
        int cssValueType = value.getCssValueType();
        switch ( cssValueType ) {
        case CSSValue.CSS_PRIMITIVE_VALUE:
            int primitiveType = value.getPrimitiveType();
            switch ( primitiveType ) {
            case CSSPrimitiveValue.CSS_IDENT: {
                if (value.getStringValue().equalsIgnoreCase
                    (CSSConstants.CSS_CURRENTCOLOR_VALUE))
                    return SVG_COLORTYPE_CURRENTCOLOR;
                return SVG_COLORTYPE_RGBCOLOR;
            }
            case CSSPrimitiveValue.CSS_RGBCOLOR:
                return SVG_COLORTYPE_RGBCOLOR;
            }
            // there was no case for this primitiveType, prevent throwing the other exception
            throw new IllegalStateException("Found unexpected PrimitiveType:" + primitiveType );

        case CSSValue.CSS_VALUE_LIST:
            return SVG_COLORTYPE_RGBCOLOR_ICCCOLOR;
        }
        // should not happen
        throw new IllegalStateException("Found unexpected CssValueType:" + cssValueType );
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGColor#getRGBColor()}.
     */
    public RGBColor getRGBColor() {
        return this;
    }

    /**
     * Returns the RGBColor value for this SVGColor.
     * For the SVG 1.1 ECMAScript binding.
     */
    public RGBColor getRgbColor() {
        return this;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGColor#setRGBColor(String)}.
     */
    public void setRGBColor(String color) {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            handler.rgbColorChanged(color);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGColor#getICCColor()}.
     */
    public SVGICCColor getICCColor() {
        return this;
    }

    /**
     * Returns the SVGICCColor value of this SVGColor.
     * For the SVG 1.1 ECMAScript binding.
     */
    public SVGICCColor getIccColor() {
        return this;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGColor#setRGBColorICCColor(String,String)}.
     */
    public void setRGBColorICCColor(String rgb, String icc) {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            iccColors = null;
            handler.rgbColorICCColorChanged(rgb, icc);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGColor#setColor(short,String,String)}.
     */
    public void setColor(short type, String rgb, String icc) {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
    } else {
            iccColors = null;
            handler.colorChanged(type, rgb, icc);
        }
    }

    // RGBColor ///////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.css.RGBColor#getRed()}.
     */
    public CSSPrimitiveValue getRed() {
        valueProvider.getValue().getRed();
        if (redComponent == null) {
            redComponent = new RedComponent();
        }
        return redComponent;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.css.RGBColor#getGreen()}.
     */
    public CSSPrimitiveValue getGreen() {
        valueProvider.getValue().getGreen();
        if (greenComponent == null) {
            greenComponent = new GreenComponent();
        }
        return greenComponent;
    }


    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.css.RGBColor#getBlue()}.
     */
    public CSSPrimitiveValue getBlue() {
        valueProvider.getValue().getBlue();
        if (blueComponent == null) {
            blueComponent = new BlueComponent();
        }
        return blueComponent;
    }

    // SVGICCColor //////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGICCColor#getColorProfile()}.
     */
    public String getColorProfile() {
        if (getColorType() != SVG_COLORTYPE_RGBCOLOR_ICCCOLOR) {
            throw new DOMException(DOMException.SYNTAX_ERR, "");
        }
        Value value = valueProvider.getValue();
        return ((ICCColor)value.item(1)).getColorProfile();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGICCColor#setColorProfile(String)}.
     */
    public void setColorProfile(String colorProfile) throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            handler.colorProfileChanged(colorProfile);
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGICCColor#getColors()}.
     */
    public SVGNumberList getColors() {
        return this;
    }

    // SVGNumberList ///////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#getNumberOfItems()}.
     */
    public int getNumberOfItems() {
        if (getColorType() != SVG_COLORTYPE_RGBCOLOR_ICCCOLOR) {
            throw new DOMException(DOMException.SYNTAX_ERR, "");
        }
        Value value = valueProvider.getValue();
        return ((ICCColor)value.item(1)).getNumberOfColors();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#clear()}.
     */
    public void clear() throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            iccColors = null;
            handler.colorsCleared();
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#initialize(SVGNumber)}.
     */
    public SVGNumber initialize(SVGNumber newItem) throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            float f = newItem.getValue();
            iccColors = new ArrayList();
            SVGNumber result = new ColorNumber(f);
            iccColors.add(result);
            handler.colorsInitialized(f);
            return result;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#getItem(int)}.
     */
    public SVGNumber getItem(int index) throws DOMException {
        if (getColorType() != SVG_COLORTYPE_RGBCOLOR_ICCCOLOR) {
            throw new DOMException(DOMException.INDEX_SIZE_ERR, "");
        }
        int n = getNumberOfItems();
        if (index < 0 || index >= n) {
            throw new DOMException(DOMException.INDEX_SIZE_ERR, "");
        }
        if (iccColors == null) {
            iccColors = new ArrayList(n);
            for (int i = iccColors.size(); i < n; i++) {
                iccColors.add(null);
            }
        }
        Value value = valueProvider.getValue().item(1);
        float f = ((ICCColor)value).getColor(index);
        SVGNumber result = new ColorNumber(f);
        iccColors.set(index, result);
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGNumberList#insertItemBefore(SVGNumber,int)}.
     */
    public SVGNumber insertItemBefore(SVGNumber newItem, int index)
        throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            int n = getNumberOfItems();
            if (index < 0 || index > n) {
                throw new DOMException(DOMException.INDEX_SIZE_ERR, "");
            }
            if (iccColors == null) {
                iccColors = new ArrayList(n);
                for (int i = iccColors.size(); i < n; i++) {
                    iccColors.add(null);
                }
            }
            float f = newItem.getValue();
            SVGNumber result = new ColorNumber(f);
            iccColors.add(index, result);
            handler.colorInsertedBefore(f, index);
            return result;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGNumberList#replaceItem(SVGNumber,int)}.
     */
    public SVGNumber replaceItem(SVGNumber newItem, int index)
        throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            int n = getNumberOfItems();
            if (index < 0 || index >= n) {
                throw new DOMException(DOMException.INDEX_SIZE_ERR, "");
            }
            if (iccColors == null) {
                iccColors = new ArrayList(n);
                for (int i = iccColors.size(); i < n; i++) {
                    iccColors.add(null);
                }
            }
            float f = newItem.getValue();
            SVGNumber result = new ColorNumber(f);
            iccColors.set(index, result);
            handler.colorReplaced(f, index);
            return result;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#removeItem(int)}.
     */
    public SVGNumber removeItem(int index) throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            int n = getNumberOfItems();
            if (index < 0 || index >= n) {
                throw new DOMException(DOMException.INDEX_SIZE_ERR, "");
            }
            SVGNumber result = null;
            if (iccColors != null) {
                result = (ColorNumber)iccColors.get(index);
            }
            if (result == null) {
                Value value = valueProvider.getValue().item(1);
                result =
                    new ColorNumber(((ICCColor)value).getColor(index));
            }
            handler.colorRemoved(index);
            return result;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGNumberList#appendItem(SVGNumber)}.
     */
    public SVGNumber appendItem (SVGNumber newItem) throws DOMException {
        if (handler == null) {
            throw new DOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
        } else {
            if (iccColors == null) {
                int n = getNumberOfItems();
                iccColors = new ArrayList(n);
                for (int i = 0; i < n; i++) {
                    iccColors.add(null);
                }
            }
            float f = newItem.getValue();
            SVGNumber result = new ColorNumber(f);
            iccColors.add(result);
            handler.colorAppend(f);
            return result;
        }
    }

    /**
     * To represent a SVGNumber which is part of a color list.
     */
    protected class ColorNumber implements SVGNumber {

        /**
         * The value of this number, when detached.
         */
        protected float value;

        /**
         * Creates a new ColorNumber.
         */
        public ColorNumber(float f) {
            value = f;
        }

        /**
         * Implements {@link SVGNumber#getValue()}.
         */
        public float getValue() {
            if (iccColors == null) {
                return value;
            }
            int idx = iccColors.indexOf(this);
            if (idx == -1) {
                return value;
            }
            Value value = valueProvider.getValue().item(1);
            return ((ICCColor)value).getColor(idx);
        }

        /**
         * Implements {@link SVGNumber#setValue(float)}.
         */
        public void setValue(float f) {
            value = f;
            if (iccColors == null) {
                return;
            }
            int idx = iccColors.indexOf(this);
            if (idx == -1) {
                return;
            }
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                handler.colorReplaced(f, idx);
            }
        }
    }

    /**
     * To provide the actual value.
     */
    public interface ValueProvider {

        /**
         * Returns the current value associated with this object.
         */
        Value getValue();
    }

    /**
     * To manage the modifications on a CSS value.
     */
    public interface ModificationHandler {

        /**
         * Called when the value text has changed.
         */
        void textChanged(String text) throws DOMException;

        /**
         * Called when the red value text has changed.
         */
        void redTextChanged(String text) throws DOMException;

        /**
         * Called when the red float value has changed.
         */
        void redFloatValueChanged(short unit, float value)
            throws DOMException;

        /**
         * Called when the green value text has changed.
         */
        void greenTextChanged(String text) throws DOMException;

        /**
         * Called when the green float value has changed.
         */
        void greenFloatValueChanged(short unit, float value)
            throws DOMException;

        /**
         * Called when the blue value text has changed.
         */
        void blueTextChanged(String text) throws DOMException;

        /**
         * Called when the blue float value has changed.
         */
        void blueFloatValueChanged(short unit, float value)
            throws DOMException;

        /**
         * Called when the RGBColor text has changed.
         */
        void rgbColorChanged(String text) throws DOMException;

        /**
         * Called when the RGBColor and the ICCColor text has changed.
         */
        void rgbColorICCColorChanged(String rgb, String icc)
            throws DOMException;

        /**
         * Called when the SVGColor has changed.
         */
        void colorChanged(short type, String rgb, String icc)
            throws DOMException;

        /**
         * Called when the ICC color profile has changed.
         */
        void colorProfileChanged(String cp) throws DOMException;

        /**
         * Called when the ICC colors has changed.
         */
        void colorsCleared() throws DOMException;

        /**
         * Called when the ICC colors has been initialized.
         */
        void colorsInitialized(float f) throws DOMException;

        /**
         * Called when the ICC color has been inserted.
         */
        void colorInsertedBefore(float f, int idx) throws DOMException;

        /**
         * Called when the ICC color has been replaced.
         */
        void colorReplaced(float f, int idx) throws DOMException;

        /**
         * Called when the ICC color has been removed.
         */
        void colorRemoved(int idx) throws DOMException;

        /**
         * Called when the ICC color has been append.
         */
        void colorAppend(float f) throws DOMException;
    }

    /**
     * Provides an abstract implementation of a ModificationHandler.
     */
    public abstract class AbstractModificationHandler
        implements ModificationHandler {

        /**
         * Returns the associated value.
         */
        protected abstract Value getValue();

        /**
         * Called when the red value text has changed.
         */
        public void redTextChanged(String text) throws DOMException {
            StringBuffer sb = new StringBuffer(40);
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                sb.append("rgb(");
                sb.append(text); sb.append(',');
                sb.append( value.getGreen().getCssText()); sb.append(',');
                sb.append( value.getBlue().getCssText()); sb.append(')');
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                sb.append("rgb(");
                sb.append(text); sb.append(',');
                sb.append(value.item(0).getGreen().getCssText());
                sb.append(',');
                sb.append(value.item(0).getBlue().getCssText());
                sb.append(')');
                sb.append(value.item(1).getCssText());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(sb.toString());
        }

        /**
         * Called when the red float value has changed.
         */
        public void redFloatValueChanged(short unit, float fValue)
            throws DOMException {
            StringBuffer sb = new StringBuffer(40);
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                sb.append("rgb(");
                sb.append(FloatValue.getCssText(unit, fValue)); sb.append(',');
                sb.append(value.getGreen().getCssText()); sb.append(',');
                sb.append(value.getBlue().getCssText()); sb.append(')');
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                sb.append("rgb(");
                sb.append(FloatValue.getCssText(unit, fValue));
                sb.append(',');
                sb.append(value.item(0).getGreen().getCssText());
                sb.append(',');
                sb.append(value.item(0).getBlue().getCssText());
                sb.append(')');
                sb.append(value.item(1).getCssText());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(sb.toString());
        }

        /**
         * Called when the green value text has changed.
         */
        public void greenTextChanged(String text) throws DOMException {
            StringBuffer sb = new StringBuffer(40);
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                sb.append("rgb(");
                sb.append(value.getRed().getCssText()); sb.append(',');
                sb.append(text); sb.append(',');
                sb.append(value.getBlue().getCssText()); sb.append(')');
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                sb.append("rgb(");
                sb.append(value.item(0).getRed().getCssText());
                sb.append(',');
                sb.append(text);
                sb.append(',');
                sb.append(value.item(0).getBlue().getCssText());
                sb.append(')');
                sb.append(value.item(1).getCssText());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(sb.toString());
        }

        /**
         * Called when the green float value has changed.
         */
        public void greenFloatValueChanged(short unit, float fValue)
            throws DOMException {
            StringBuffer sb = new StringBuffer(40);
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                sb.append("rgb(");
                sb.append(value.getRed().getCssText()); sb.append(',');
                sb.append(FloatValue.getCssText(unit, fValue)); sb.append(',');
                sb.append(value.getBlue().getCssText()); sb.append(')');
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                sb.append("rgb(");
                sb.append(value.item(0).getRed().getCssText());
                sb.append(',');
                sb.append(FloatValue.getCssText(unit, fValue));
                sb.append(',');
                sb.append(value.item(0).getBlue().getCssText());
                sb.append(')');
                sb.append(value.item(1).getCssText());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(sb.toString());
        }

        /**
         * Called when the blue value text has changed.
         */
        public void blueTextChanged(String text) throws DOMException {
            StringBuffer sb = new StringBuffer(40);
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                sb.append("rgb(");
                sb.append(value.getRed().getCssText()); sb.append(',');
                sb.append(value.getGreen().getCssText()); sb.append(',');
                sb.append(text); sb.append(')');
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                sb.append("rgb(");
                sb.append(value.item(0).getRed().getCssText());
                sb.append(',');
                sb.append(value.item(0).getGreen().getCssText());
                sb.append(',');
                sb.append(text);
                sb.append(')');
                sb.append(value.item(1).getCssText());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(sb.toString());
        }

        /**
         * Called when the blue float value has changed.
         */
        public void blueFloatValueChanged(short unit, float fValue)
            throws DOMException {
            StringBuffer sb = new StringBuffer(40);
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                sb.append("rgb(");
                sb.append(value.getRed().getCssText()); sb.append(',');
                sb.append(value.getGreen().getCssText()); sb.append(',');
                sb.append(FloatValue.getCssText(unit, fValue)); sb.append(')');
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                sb.append("rgb(");
                sb.append(value.item(0).getRed().getCssText());
                sb.append(',');
                sb.append(value.item(0).getGreen().getCssText());
                sb.append(',');
                sb.append(FloatValue.getCssText(unit, fValue));
                sb.append(')');
                sb.append(value.item(1).getCssText());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(sb.toString());
        }

        /**
         * Called when the RGBColor text has changed.
         */
        public void rgbColorChanged(String text) throws DOMException {
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR:
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                text += getValue().item(1).getCssText();
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
            textChanged(text);
        }

        /**
         * Called when the RGBColor and the ICCColor text has changed.
         */
        public void rgbColorICCColorChanged(String rgb, String icc)
            throws DOMException {
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                textChanged(rgb + ' ' + icc);
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the SVGColor has changed.
         */
        public void colorChanged(short type, String rgb, String icc)
            throws DOMException {
            switch (type) {
            case SVG_COLORTYPE_CURRENTCOLOR:
                textChanged(CSSConstants.CSS_CURRENTCOLOR_VALUE);
                break;

            case SVG_COLORTYPE_RGBCOLOR:
                textChanged(rgb);
                break;

            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                textChanged(rgb + ' ' + icc);
                break;

            default:
                throw new DOMException(DOMException.NOT_SUPPORTED_ERR, "");
            }
        }

        /**
         * Called when the ICC color profile has changed.
         */
        public void colorProfileChanged(String cp) throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                sb.append(cp);
                ICCColor iccc = (ICCColor)value.item(1);
                for (int i = 0; i < iccc.getLength(); i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the ICC colors has changed.
         */
        public void colorsCleared() throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                ICCColor iccc = (ICCColor)value.item(1);
                sb.append(iccc.getColorProfile());
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the ICC colors has been initialized.
         */
        public void colorsInitialized(float f) throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                ICCColor iccc = (ICCColor)value.item(1);
                sb.append(iccc.getColorProfile());
                sb.append(',');
                sb.append(f);
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the ICC color has been inserted.
         */
        public void colorInsertedBefore(float f, int idx) throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                ICCColor iccc = (ICCColor)value.item(1);
                sb.append(iccc.getColorProfile());
                for (int i = 0; i < idx; i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(',');
                sb.append(f);
                for (int i = idx; i < iccc.getLength(); i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the ICC color has been replaced.
         */
        public void colorReplaced(float f, int idx) throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                ICCColor iccc = (ICCColor)value.item(1);
                sb.append(iccc.getColorProfile());
                for (int i = 0; i < idx; i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(',');
                sb.append(f);
                for (int i = idx + 1; i < iccc.getLength(); i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the ICC color has been removed.
         */
        public void colorRemoved(int idx) throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                ICCColor iccc = (ICCColor)value.item(1);
                sb.append(iccc.getColorProfile());
                for (int i = 0; i < idx; i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                for (int i = idx + 1; i < iccc.getLength(); i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }

        /**
         * Called when the ICC color has been append.
         */
        public void colorAppend(float f) throws DOMException {
            Value value = getValue();
            switch (getColorType()) {
            case SVG_COLORTYPE_RGBCOLOR_ICCCOLOR:
                StringBuffer sb =
                    new StringBuffer( value.item(0).getCssText());
                sb.append(" icc-color(");
                ICCColor iccc = (ICCColor)value.item(1);
                sb.append(iccc.getColorProfile());
                for (int i = 0; i < iccc.getLength(); i++) {
                    sb.append(',');
                    sb.append(iccc.getColor(i));
                }
                sb.append(',');
                sb.append(f);
                sb.append(')');
                textChanged(sb.toString());
                break;

            default:
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            }
        }
    }

    /**
     * To store a component.
     */
    protected abstract class AbstractComponent implements CSSPrimitiveValue {

        /**
         * The returns the actual value of this component.
         */
        protected abstract Value getValue();

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValue#getCssText()}.
         */
        public String getCssText() {
            return getValue().getCssText();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValue#getCssValueType()}.
         */
        public short getCssValueType() {
            return getValue().getCssValueType();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#getPrimitiveType()}.
         */
        public short getPrimitiveType() {
            return getValue().getPrimitiveType();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#getFloatValue(short)}.
         */
        public float getFloatValue(short unitType) throws DOMException {
            return CSSOMValue.convertFloatValue(unitType, getValue());
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#getStringValue()}.
         */
        public String getStringValue() throws DOMException {
            return valueProvider.getValue().getStringValue();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#getCounterValue()}.
         */
        public Counter getCounterValue() throws DOMException {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR, "");
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#getRectValue()}.
         */
        public Rect getRectValue() throws DOMException {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR, "");
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#getRGBColorValue()}.
         */
        public RGBColor getRGBColorValue() throws DOMException {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR, "");
        }

        // CSSValueList ///////////////////////////////////////////////////////

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValueList#getLength()}.
         */
        public int getLength() {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR, "");
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValueList#item(int)}.
         */
        public CSSValue item(int index) {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR, "");
        }
    }

    /**
     * To store a Float component.
     */
    protected abstract class FloatComponent extends AbstractComponent {

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#setStringValue(short,String)}.
         */
        public void setStringValue(short stringType, String stringValue)
            throws DOMException {
            throw new DOMException(DOMException.INVALID_ACCESS_ERR, "");
        }
    }

    /**
     * To represents a red component.
     */
    protected class RedComponent extends FloatComponent {

        /**
         * The returns the actual value of this component.
         */
        protected Value getValue() {
            return valueProvider.getValue().getRed();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValue#setCssText(String)}.
         */
        public void setCssText(String cssText) throws DOMException {
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                getValue();
                handler.redTextChanged(cssText);
            }
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#setFloatValue(short,float)}.
         */
        public void setFloatValue(short unitType, float floatValue)
            throws DOMException {
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                getValue();
                handler.redFloatValueChanged(unitType, floatValue);
            }
        }

    }


    /**
     * To represents a green component.
     */
    protected class GreenComponent extends FloatComponent {

        /**
         * The returns the actual value of this component.
         */
        protected Value getValue() {
            return valueProvider.getValue().getGreen();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValue#setCssText(String)}.
         */
        public void setCssText(String cssText) throws DOMException {
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                getValue();
                handler.greenTextChanged(cssText);
            }
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#setFloatValue(short,float)}.
         */
        public void setFloatValue(short unitType, float floatValue)
            throws DOMException {
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                getValue();
                handler.greenFloatValueChanged(unitType, floatValue);
            }
        }

    }

    /**
     * To represents a blue component.
     */
    protected class BlueComponent extends FloatComponent {

        /**
         * The returns the actual value of this component.
         */
        protected Value getValue() {
            return valueProvider.getValue().getBlue();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSValue#setCssText(String)}.
         */
        public void setCssText(String cssText) throws DOMException {
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                getValue();
                handler.blueTextChanged(cssText);
            }
        }

        /**
         * <b>DOM</b>: Implements {@link
         * org.w3c.dom.css.CSSPrimitiveValue#setFloatValue(short,float)}.
         */
        public void setFloatValue(short unitType, float floatValue)
            throws DOMException {
            if (handler == null) {
                throw new DOMException
                    (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
            } else {
                getValue();
                handler.blueFloatValueChanged(unitType, floatValue);
            }
        }

    }

}
