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



/**
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGGraphicObjectConverter.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class SVGGraphicObjectConverter implements SVGSyntax {
    /**
     * Used by converters to create Elements and other DOM objects.
     */
    protected SVGGeneratorContext generatorContext;

    /**
     * @param generatorContext can be used by the SVGGraphicObjectConverter
     * extentions to create Elements and other types of DOM objects.
     */
    public SVGGraphicObjectConverter(SVGGeneratorContext generatorContext) {
        if (generatorContext == null)
            throw new SVGGraphics2DRuntimeException(ErrorConstants.ERR_CONTEXT_NULL);
        this.generatorContext = generatorContext;
    }

    /**
     * Utility method for subclasses.
     */
    public final String doubleString(double value) {
        return generatorContext.doubleString(value);
    }
}
