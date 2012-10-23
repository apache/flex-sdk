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

/**
 * Interface for SVG DOM classes to expose information about the traits
 * (XML attributes and CSS properties) their elements support.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: ExtendedTraitAccess.java 479349 2006-11-26 11:54:23Z cam $
 */
public interface ExtendedTraitAccess extends TraitAccess {

    /**
     * Returns whether the given CSS property is available on this element.
     */
    boolean hasProperty(String pn);

    /**
     * Returns whether the given trait is available on this element.
     */
    boolean hasTrait(String ns, String ln);

    /**
     * Returns whether the given CSS property is animatable.
     */
    boolean isPropertyAnimatable(String pn);

    /**
     * Returns whether the given XML attribute is animatable.
     */
    boolean isAttributeAnimatable(String ns, String ln);

    /**
     * Returns whether the given CSS property is additive.
     */
    boolean isPropertyAdditive(String pn);

    /**
     * Returns whether the given XML attribute is additive.
     */
    boolean isAttributeAdditive(String ns, String ln);

    /**
     * Returns whether the given trait is animatable.
     */
    boolean isTraitAnimatable(String ns, String tn);

    /**
     * Returns whether the given trait is additive.
     */
    boolean isTraitAdditive(String ns, String tn);

    /**
     * Returns the SVG type of the given CSS property.  Must return one of
     * the TYPE_* constants defined in {@link org.apache.flex.forks.batik.util.SVGTypes}.
     */
    int getPropertyType(String pn);

    /**
     * Returns the SVG type of the given XML attribute.  Must return one of
     * the TYPE_* constants defined in {@link org.apache.flex.forks.batik.util.SVGTypes}.
     */
    int getAttributeType(String ns, String ln);
}
