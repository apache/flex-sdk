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

import java.awt.Composite;

import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;
import org.w3c.dom.Element;

/**
 * Utility class that converts an custom Composite object into
 * a set of SVG properties and definitions.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGCustomComposite.java 475477 2006-11-15 22:44:28Z cam $
 * @see                org.apache.flex.forks.batik.svggen.SVGComposite
 */
public class SVGCustomComposite extends AbstractSVGConverter {
    /**
     * @param generatorContext for use by SVGCustomComposite to build Elements
     */
    public SVGCustomComposite(SVGGeneratorContext generatorContext) {
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
        return toSVG(gc.getComposite());
    }

    /**
     * @param composite the Composite object to convert to SVG
     * @return an SVGCompositeDescriptor mapping the SVG
     *         composite equivalent to the input Composite.
     */
    public SVGCompositeDescriptor toSVG(Composite composite) {
        if (composite == null)
            throw new NullPointerException();
        SVGCompositeDescriptor compositeDesc =
            (SVGCompositeDescriptor)descMap.get(composite);

        if (compositeDesc == null) {
            // First time this composite is used. Request handler
            // to do the convertion
            SVGCompositeDescriptor desc =
                generatorContext.
                extensionHandler.handleComposite(composite,
                                                 generatorContext);

            if (desc != null) {
                Element def = desc.getDef();
                if(def != null)
                    defSet.add(def);
                descMap.put(composite, desc);
            }
        }

        return compositeDesc;
    }
}
