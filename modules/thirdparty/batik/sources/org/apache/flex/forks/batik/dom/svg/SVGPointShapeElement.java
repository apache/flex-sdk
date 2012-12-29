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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.svg.SVGAnimatedPoints;
import org.w3c.dom.svg.SVGPointList;

/**
 * This class provides a common superclass for shape elements that are
 * defined with a 'points' attribute (i.e., polygon and polyline).
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SVGPointShapeElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class SVGPointShapeElement
    extends    SVGGraphicsElement
    implements SVGAnimatedPoints {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGGraphicsElement.xmlTraitInformation);
        t.put(null, SVG_POINTS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_POINTS_VALUE));
        xmlTraitInformation = t;
    }

    /**
     * The 'points' attribute value.
     */
    protected SVGOMAnimatedPoints points;

    /**
     * Creates a new SVGPointShapeElement object.
     */
    protected SVGPointShapeElement() {
    }

    /**
     * Creates a new SVGPointShapeElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGPointShapeElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
        initializeLiveAttributes();
    }

    /**
     * Initializes all live attributes for this element.
     */
    protected void initializeAllLiveAttributes() {
        super.initializeAllLiveAttributes();
        initializeLiveAttributes();
    }

    /**
     * Initializes the live attribute values of this element.
     */
    private void initializeLiveAttributes() {
        points = createLiveAnimatedPoints(null, SVG_POINTS_ATTRIBUTE, "");
    }

    /**
     * Gets the {@link SVGOMAnimatedPoints} object that manages the
     * point list for this element.
     */
    public SVGOMAnimatedPoints getSVGOMAnimatedPoints() {
        return points;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimatedPoints#getPoints()}.
     */
    public SVGPointList getPoints() {
        return points.getPoints();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGAnimatedPoints#getAnimatedPoints()}.
     */
    public SVGPointList getAnimatedPoints() {
        return points.getAnimatedPoints();
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
    }
}
