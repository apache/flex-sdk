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
package org.apache.flex.forks.batik.svggen.font.table;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Glyph description for composite glyphs.  Composite glyphs are made up of one
 * or more simple glyphs, usually with some sort of transformation applied to
 * each.
 *
 * @version $Id: GlyfCompositeDescript.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class GlyfCompositeDescript extends GlyfDescript {

    private List components = new ArrayList();

    protected boolean beingResolved = false;
    protected boolean resolved      = false;

    public GlyfCompositeDescript(GlyfTable parentTable, 
                                 ByteArrayInputStream bais) {
        super(parentTable, (short) -1, bais);
        
        // Get all of the composite components
        GlyfCompositeComp comp;
        do {
            comp = new GlyfCompositeComp(bais);
            components.add(comp);
        } while ((comp.getFlags() & GlyfCompositeComp.MORE_COMPONENTS) != 0);

        // Are there hinting intructions to read?
        if ((comp.getFlags() & GlyfCompositeComp.WE_HAVE_INSTRUCTIONS) != 0) {
            readInstructions(bais, (bais.read()<<8 | bais.read()));
        }
    }

    public void resolve() {
        if (resolved) return;
        if (beingResolved) {
            System.err.println("Circular reference in GlyfCompositeDesc");
            return;
        }
        beingResolved = true;

        int firstIndex = 0;
        int firstContour = 0;

        Iterator i = components.iterator();
        while (i.hasNext()) {
            GlyfCompositeComp comp = (GlyfCompositeComp)i.next();
            comp.setFirstIndex(firstIndex);
            comp.setFirstContour(firstContour);

            GlyfDescript desc;
            desc = parentTable.getDescription(comp.getGlyphIndex());
            if (desc != null) {
                desc.resolve();
                firstIndex   += desc.getPointCount();
                firstContour += desc.getContourCount();
            }
        }
        resolved = true;
        beingResolved = false;
    }

    public int getEndPtOfContours(int i) {
        GlyfCompositeComp c = getCompositeCompEndPt(i);
        if (c != null) {
            GlyphDescription gd = parentTable.getDescription(c.getGlyphIndex());
            return gd.getEndPtOfContours(i - c.getFirstContour()) + c.getFirstIndex();
        }
        return 0;
    }

    public byte getFlags(int i) {
        GlyfCompositeComp c = getCompositeComp(i);
        if (c != null) {
            GlyphDescription gd = parentTable.getDescription(c.getGlyphIndex());
            return gd.getFlags(i - c.getFirstIndex());
        }
        return 0;
    }

    public short getXCoordinate(int i) {
        GlyfCompositeComp c = getCompositeComp(i);
        if (c != null) {
            GlyphDescription gd = parentTable.getDescription(c.getGlyphIndex());
            int n = i - c.getFirstIndex();
            int x = gd.getXCoordinate(n);
            int y = gd.getYCoordinate(n);
            short x1 = (short) c.scaleX(x, y);
            x1 += c.getXTranslate();
            return x1;
        }
        return 0;
    }

    public short getYCoordinate(int i) {
        GlyfCompositeComp c = getCompositeComp(i);
        if (c != null) {
            GlyphDescription gd = parentTable.getDescription(c.getGlyphIndex());
            int n = i - c.getFirstIndex();
            int x = gd.getXCoordinate(n);
            int y = gd.getYCoordinate(n);
            short y1 = (short) c.scaleY(x, y);
            y1 += c.getYTranslate();
            return y1;
        }
        return 0;
    }

    public boolean isComposite() {
        return true;
    }

    public int getPointCount() {
        if (!resolved)
            System.err.println("getPointCount called on unresolved GlyfCompositeDescript");

        GlyfCompositeComp c = (GlyfCompositeComp) components.get(components.size()-1);
        // System.err.println("C: " + c + " Idx: " + c.getGlyphIndex());
        // System.err.println("Ptbl: " + parentTable);
        return c.getFirstIndex() + parentTable.getDescription(c.getGlyphIndex()).getPointCount();
    }

    public int getContourCount() {
        if (!resolved)
            System.err.println("getContourCount called on unresolved GlyfCompositeDescript");

        GlyfCompositeComp c = (GlyfCompositeComp) components.get(components.size()-1);
        return c.getFirstContour() + parentTable.getDescription(c.getGlyphIndex()).getContourCount();
    }

    public int getComponentIndex(int i) {
        return ((GlyfCompositeComp)components.get(i)).getFirstIndex();
    }

    public int getComponentCount() {
        return components.size();
    }

    protected GlyfCompositeComp getCompositeComp(int i) {
        GlyfCompositeComp c;
        for (int n = 0; n < components.size(); n++) {
            c = (GlyfCompositeComp) components.get(n);
            GlyphDescription gd = parentTable.getDescription(c.getGlyphIndex());
            if (c.getFirstIndex() <= i && i < (c.getFirstIndex() + gd.getPointCount())) {
                return c;
            }
        }
        return null;
    }

    protected GlyfCompositeComp getCompositeCompEndPt(int i) {
        GlyfCompositeComp c;
        for (int j = 0; j < components.size(); j++) {
            c = (GlyfCompositeComp) components.get(j);
            GlyphDescription gd = parentTable.getDescription(c.getGlyphIndex());
            if (c.getFirstContour() <= i && i < (c.getFirstContour() + gd.getContourCount())) {
                return c;
            }
        }
        return null;
    }
}
