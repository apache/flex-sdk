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

/**
 * The error code.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: ErrorConstants.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public interface ErrorConstants {

    /**
     * The error code when a required attribute is missing.
     * <pre>
     * {0} = the name of the attribute
     * </pre>
     */
    String ERR_ATTRIBUTE_MISSING
        = "attribute.missing";

    /**
     * The error code when an attribute has a syntax error.
     * <pre>
     * {0} = the name of the attribute
     * {1} = the wrong value
     * </pre>
     */
    String ERR_ATTRIBUTE_VALUE_MALFORMED
        = "attribute.malformed";

    /**
     * The error code when a length, which must be positive, is negative.
     * <pre>
     * {0} = the name of the attribute
     * </pre>
     */
    String ERR_LENGTH_NEGATIVE
        = "length.negative";

    /**
     * The error code when a CSS length is negative.
     * <pre>
     * {0} = property
     * </pre>
     */
    String ERR_CSS_LENGTH_NEGATIVE
        = "css.length.negative";

    /**
     * The error code when a URI specified in a CSS property
     * referenced a bad element.
     * <pre>
     * {0} = the uri
     * </pre>
     */
    String ERR_CSS_URI_BAD_TARGET
        = "css.uri.badTarget";

    /**
     * The error code when a specified URI references a bad element.
     * <pre>
     * {0} = the uri
     * </pre>
     */
    String ERR_URI_BAD_TARGET
        = "uri.badTarget";

    /**
     * The error code when the bridge detected circular dependencies
     * while resolving a list of URI.
     * <pre>
     * {0} = the uri
     * </pre>
     */
    String ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES
        = "xlink.href.circularDependencies";

    /**
     * The error code when the bridge try to load a URI
     * {0} = the uri
     */
    String ERR_URI_MALFORMED
        = "uri.malformed";

    /**
     * The error code when the bridge encoutered an I/O error while
     * loading a URI.
     * <pre>
     * {0} = the uri
     * </pre>
     */
    String ERR_URI_IO
        = "uri.io";

    /**
     * The error code when the bridge encountered a SecurityException
     * while loading a URI
     * {0} = the uri
     */
    String ERR_URI_UNSECURE
        = "uri.unsecure";

    /**
     * The error code when the bridge tries to referenced an invalid
     * node inside a document.
     * <pre>
     * {0} = the uri
     * </pre>
     */
    String ERR_URI_REFERENCE_A_DOCUMENT
        = "uri.referenceDocument";

    /**
     * The error code when the bridge tries to an image and the image
     * format is not supported.
     * <pre>
     * {0} = the uri
     * </pre>
     */
    String ERR_URI_IMAGE_INVALID = "uri.image.invalid";

    /**
     * The error code when the bridge tries to read an image and the image
     * url can't be opened or the contents aren't usable.
     * <pre>
     * {0} = the uri
     * {1} = the reason it can't be opened.
     * </pre>
     */
    String ERR_URI_IMAGE_BROKEN = "uri.image.broken";

    /**
     * The error code when the bridge tries to read an image and the image
     * url can't be opened:
     * <pre>
     * {0} = the reason it can't be opened.
     * </pre>
     */
    String URI_IMAGE_ERROR = "uri.image.error";

}
