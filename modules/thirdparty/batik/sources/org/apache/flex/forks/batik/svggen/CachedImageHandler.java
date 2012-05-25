/*

   Copyright 2001,2003  The Apache Software Foundation 

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


/**
 * Extends the default ImageHandler interface with calls to
 * allow caching of raster images in generated SVG content.
 *
 * @author <a href="mailto:paul_evenblij@compuware.com">Paul Evenblij</a>
 * @version $Id: CachedImageHandler.java,v 1.5 2004/08/18 07:14:58 vhardy Exp $
 */
public interface CachedImageHandler extends GenericImageHandler {
    /**
     * Returns the image cache instance in use by this handler
     *
     * @return the image cache
     */ 
   public ImageCacher getImageCacher();
    
}
