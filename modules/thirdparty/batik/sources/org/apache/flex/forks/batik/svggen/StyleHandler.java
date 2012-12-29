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
package org.apache.flex.forks.batik.svggen;

import java.util.Map;

import org.w3c.dom.Element;

/**
 * The <code>StyleHandler</code> interface allows you to specialize
 * how the style will be set on an SVG <code>Element</code>.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: StyleHandler.java 478176 2006-11-22 14:50:50Z dvholten $
 */
public interface StyleHandler {
    /**
     * Sets the style described by <code>styleMap</code> on the given
     * <code>element</code>.
     * @param element the SVG <code>Element</code> to be styled.
     * @param styleMap the <code>Map</code> containing pairs of style
     * property names, style values.
     */
    void setStyle(Element element, Map styleMap,
                         SVGGeneratorContext generatorContext);
}
