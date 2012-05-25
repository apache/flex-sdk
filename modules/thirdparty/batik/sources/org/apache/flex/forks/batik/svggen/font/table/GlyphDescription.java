/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen.font.table;

/**
 * Specifies access to glyph description classes, simple and composite.
 * @version $Id: GlyphDescription.java,v 1.3 2004/08/18 07:15:21 vhardy Exp $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public interface GlyphDescription {
    public int getEndPtOfContours(int i);
    public byte getFlags(int i);
    public short getXCoordinate(int i);
    public short getYCoordinate(int i);
    public short getXMaximum();
    public short getXMinimum();
    public short getYMaximum();
    public short getYMinimum();
    public boolean isComposite();
    public int getPointCount();
    public int getContourCount();
    //  public int getComponentIndex(int c);
    //  public int getComponentCount();
}
