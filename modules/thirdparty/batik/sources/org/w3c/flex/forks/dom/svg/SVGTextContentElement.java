/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.w3c.flex.forks.dom.svg;

import org.w3c.dom.DOMException;
import org.w3c.dom.events.EventTarget;

public interface SVGTextContentElement extends 
               SVGElement,
               SVGTests,
               SVGLangSpace,
               SVGExternalResourcesRequired,
               SVGStylable,
               EventTarget {
  // lengthAdjust Types
  public static final short LENGTHADJUST_UNKNOWN   = 0;
  public static final short LENGTHADJUST_SPACING     = 1;
  public static final short LENGTHADJUST_SPACINGANDGLYPHS     = 2;

  public SVGAnimatedLength      getTextLength( );
  public SVGAnimatedEnumeration getLengthAdjust( );

  public int      getNumberOfChars (  );
  public float    getComputedTextLength (  );
  public float    getSubStringLength ( int charnum, int nchars )
                  throws DOMException;
  public SVGPoint getStartPositionOfChar ( int charnum )
                  throws DOMException;
  public SVGPoint getEndPositionOfChar ( int charnum )
                  throws DOMException;
  public SVGRect  getExtentOfChar ( int charnum )
                  throws DOMException;
  public float    getRotationOfChar ( int charnum )
                  throws DOMException;
  public int      getCharNumAtPosition ( SVGPoint point );
  public void     selectSubString ( int charnum, int nchars )
                  throws DOMException;
}
