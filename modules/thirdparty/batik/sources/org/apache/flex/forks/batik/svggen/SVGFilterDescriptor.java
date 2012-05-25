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
package org.apache.flex.forks.batik.svggen;

import org.w3c.dom.Element;

/**
 * Used to represent an SVG Composite. This can be achieved with
 * to values: an SVG opacity and a filter
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGFilterDescriptor.java,v 1.3 2004/08/18 07:15:00 vhardy Exp $
 */
public class SVGFilterDescriptor {
    private Element def;
    private String filterValue;

    public SVGFilterDescriptor(String filterValue){
        this.filterValue = filterValue;
    }

    public SVGFilterDescriptor(String filterValue,
                               Element def){
        this(filterValue);
        this.def = def;
    }

    public String getFilterValue(){
        return filterValue;
    }

    public Element getDef(){
        return def;
    }
}
