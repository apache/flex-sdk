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
package org.apache.flex.forks.batik.extension.svg;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FilterColorInterpolation;

/**
 *
 * @version $Id: BatikHistogramNormalizationFilter.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public interface BatikHistogramNormalizationFilter
    extends FilterColorInterpolation {

    /**
     * Returns the source to be offset.
     */
    Filter getSource();

    /**
     * Sets the source to be offset.
     * @param src image to offset.
     */
    void setSource(Filter src);

    /**
     * Returns the trim percent for this normalization.
     */
    float getTrim();


    /**
     * Sets the trim percent for this normalization.
     */
    void setTrim(float trim);
}
