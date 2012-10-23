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

import org.apache.flex.forks.batik.css.engine.value.Value;

/**
 * This class represents objects which contains property/value mappings.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StyleMap.java 498515 2007-01-22 03:19:02Z cam $
 */
public class StyleMap {

    //
    // The masks, still have 2 free bits: 0x0800, & 0x1000, could also
    // go to int if needed.
    //
    public static final short IMPORTANT_MASK             = 0x0001;
    public static final short COMPUTED_MASK              = 0x0002;
    public static final short NULL_CASCADED_MASK         = 0x0004;
    public static final short INHERITED_MASK             = 0x0008;

    public static final short LINE_HEIGHT_RELATIVE_MASK  = 0x0010;
    public static final short FONT_SIZE_RELATIVE_MASK    = 0x0020;
    public static final short COLOR_RELATIVE_MASK        = 0x0040;
    public static final short PARENT_RELATIVE_MASK       = 0x0080;
    public static final short BLOCK_WIDTH_RELATIVE_MASK  = 0x0100;
    public static final short BLOCK_HEIGHT_RELATIVE_MASK = 0x0200;
    public static final short BOX_RELATIVE_MASK          = 0x0400;

    public static final short ORIGIN_MASK = (short)0xE000; // 3 last bits

    //
    // The origin values.
    //
    public static final short USER_AGENT_ORIGIN    = 0;
    public static final short USER_ORIGIN          = 0x2000; // 0010
    public static final short NON_CSS_ORIGIN       = 0x4000; // 0100
    public static final short AUTHOR_ORIGIN        = 0x6000; // 0110
    public static final short INLINE_AUTHOR_ORIGIN = (short)0x8000; // 1000
    public static final short OVERRIDE_ORIGIN      = (short)0xA000; // 1010

    /**
     * The values.
     */
    protected Value[] values;

    /**
     * To store the value masks.
     */
    protected short[] masks;

    /**
     * Whether the values of this map cannot be re-cascaded.
     */
    protected boolean fixedCascadedValues;

    /**
     * Creates a new StyleMap.
     */
    public StyleMap(int size) {
        values = new Value[size];
        masks = new short[size];
    }

    /**
     * Whether this map has fixed cascaded value.
     */
    public boolean hasFixedCascadedValues() {
        return fixedCascadedValues;
    }

    /**
     * Sets the fixedCascadedValues property.
     */
    public void setFixedCascadedStyle(boolean b) {
        fixedCascadedValues = b;
    }

    /**
     * Returns the value at the given index, null if unspecified.
     */
    public Value getValue(int i) {
        return values[i];
    }

    /**
     * Returns the mask of the given property value.
     */
    public short getMask(int i) {
        return masks[i];
    }

    /**
     * Tells whether the given property value is important.
     */
    public boolean isImportant(int i) {
        return (masks[i] & IMPORTANT_MASK) != 0;
    }

    /**
     * Tells whether the given property value is computed.
     */
    public boolean isComputed(int i) {
        return (masks[i] & COMPUTED_MASK) != 0;
    }

    /**
     * Tells whether the given cascaded property value is null.
     */
    public boolean isNullCascaded(int i) {
        return (masks[i] & NULL_CASCADED_MASK) != 0;
    }

    /**
     * Tells whether the given cascaded property value was
     * inherited from it's parent or set locally.
     */
    public boolean isInherited(int i) {
        return (masks[i] & INHERITED_MASK) != 0;
    }

    /**
     * Returns the origin value.
     */
    public short getOrigin(int i) {
        return (short)(masks[i] & ORIGIN_MASK);
    }

    /**
     * Tells whether the given property value is relative to 'color'.
     */
    public boolean isColorRelative(int i) {
        return (masks[i] & COLOR_RELATIVE_MASK) != 0;
    }

    /**
     * Tells whether the given property value is relative to the parent's
     * property value.
     */
    public boolean isParentRelative(int i) {
        return (masks[i] & PARENT_RELATIVE_MASK) != 0;
    }

    /**
     * Tells whether the given property value is relative to 'line-height'.
     */
    public boolean isLineHeightRelative(int i) {
        return (masks[i] & LINE_HEIGHT_RELATIVE_MASK) != 0;
    }

    /**
     * Tells whether the given property value is relative to 'font-size'.
     */
    public boolean isFontSizeRelative(int i) {
        return (masks[i] & FONT_SIZE_RELATIVE_MASK) != 0;
    }

    /**
     * Tells whether the given property value is relative to the
     * width of the containing block.
     */
    public boolean isBlockWidthRelative(int i) {
        return (masks[i] & BLOCK_WIDTH_RELATIVE_MASK) != 0;
    }

    /**
     * Tells whether the given property value is relative to the
     * height of the containing block.
     */
    public boolean isBlockHeightRelative(int i) {
        return (masks[i] & BLOCK_HEIGHT_RELATIVE_MASK) != 0;
    }

    /**
     * Puts a property value, given the property index.
     * @param i The property index.
     * @param v The property value.
     */
    public void putValue(int i, Value v) {
        values[i] = v;
    }

    /**
     * Puts a property mask, given the property index.
     * @param i The property index.
     * @param m The property mask.
     */
    public void putMask(int i, short m) {
        masks[i] = m;
    }

    /**
     * Sets the priority of a property value.
     */
    public void putImportant(int i, boolean b) {
        if (b) masks[i] |=  IMPORTANT_MASK;
        else   masks[i] &= ~IMPORTANT_MASK;
    }

    /**
     * Sets the origin of the given value.
     */
    public void putOrigin(int i, short val) {
        masks[i] &= ~ORIGIN_MASK;
        masks[i] |= (short)(val & ORIGIN_MASK);
    }

    /**
     * Sets the computed flag of a property value.
     */
    public void putComputed(int i, boolean b) {
        if (b) masks[i] |=  COMPUTED_MASK;
        else   masks[i] &= ~COMPUTED_MASK;
    }

    /**
     * Sets the null-cascaded flag of a property value.
     */
    public void putNullCascaded(int i, boolean b) {
        if (b) masks[i] |=  NULL_CASCADED_MASK;
        else   masks[i] &= ~NULL_CASCADED_MASK;
    }

    /**
     * Sets the inherited flag of a property value.
     * If true this computed value was inherited from it's parent.
     */
    public void putInherited(int i, boolean b) {
        if (b) masks[i] |=  INHERITED_MASK;
        else   masks[i] &= ~INHERITED_MASK;
    }

    /**
     * Sets the color-relative flag of a property value.
     */
    public void putColorRelative(int i, boolean b) {
        if (b) masks[i] |=  COLOR_RELATIVE_MASK;
        else   masks[i] &= ~COLOR_RELATIVE_MASK;
    }

    /**
     * Sets the parent-relative flag of a property value.
     */
    public void putParentRelative(int i, boolean b) {
        if (b) masks[i] |=  PARENT_RELATIVE_MASK;
        else   masks[i] &= ~PARENT_RELATIVE_MASK;
    }

    /**
     * Sets the line-height-relative flag of a property value.
     */
    public void putLineHeightRelative(int i, boolean b) {
        if (b) masks[i] |=  LINE_HEIGHT_RELATIVE_MASK;
        else   masks[i] &= ~LINE_HEIGHT_RELATIVE_MASK;
    }

    /**
     * Sets the font-size-relative flag of a property value.
     */
    public void putFontSizeRelative(int i, boolean b) {
        if (b) masks[i] |=  FONT_SIZE_RELATIVE_MASK;
        else   masks[i] &= ~FONT_SIZE_RELATIVE_MASK;
    }

    /**
     * Sets the block-width-relative flag of a property value.
     */
    public void putBlockWidthRelative(int i, boolean b) {
        if (b) masks[i] |=  BLOCK_WIDTH_RELATIVE_MASK;
        else   masks[i] &= ~BLOCK_WIDTH_RELATIVE_MASK;
    }

    /**
     * Sets the block-height-relative flag of a property value.
     */
    public void putBlockHeightRelative(int i, boolean b) {
        if (b) masks[i] |=  BLOCK_HEIGHT_RELATIVE_MASK;
        else   masks[i] &= ~BLOCK_HEIGHT_RELATIVE_MASK;
    }

    /**
     * Returns a printable representation of this style map.
     */
    public String toString(CSSEngine eng) {
        // Note that values.length should always be equal to
        // eng.getNumberOfProperties() for StyleMaps that were created
        // by that CSSEngine.
        int nSlots = values.length;
        StringBuffer sb = new StringBuffer(nSlots * 8);
        for (int i = 0; i < nSlots; i++) {
            Value v = values[i];
            if (v == null) continue;

            sb.append(eng.getPropertyName(i));
            sb.append(": ");
            sb.append(v);
            if (isImportant(i)) sb.append(" !important");
            sb.append(";\n");
        }
        return sb.toString();
    }
}
