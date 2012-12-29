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
package org.apache.flex.forks.batik.bridge;

import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.spi.DefaultBrokenLinkProvider;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.filter.GraphicsNodeRable8Bit;

/**
 * This interface is to be used to provide alternate ways of 
 * generating a placeholder image when the ImageTagRegistry
 * fails to handle a given reference.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: SVGBrokenLinkProvider.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGBrokenLinkProvider 
    extends    DefaultBrokenLinkProvider 
    implements ErrorConstants {

    public SVGBrokenLinkProvider() {
    }

    /**
     * This method is responsible for constructing an image that will
     * represent the missing image in the document.  This method
     * recives information about the reason a broken link image is
     * being requested in the <tt>code</tt> and <tt>params</tt>
     * parameters. These parameters may be used to generate nicely
     * localized messages for insertion into the broken link image, or
     * for selecting the broken link image returned.
     *
     * @param code This is the reason the image is unavailable should
     *             be taken from ErrorConstants.
     * @param params This is more detailed information about
     *        the circumstances of the failure.  */
    public Filter getBrokenLinkImage(Object base, String code, 
                                     Object[] params) {
        String message = formatMessage(base, code, params);
        Map props = new HashMap();
        props.put(BROKEN_LINK_PROPERTY, message);

        CompositeGraphicsNode cgn = new CompositeGraphicsNode();
        return new GraphicsNodeRable8Bit(cgn, props);
    }
}
