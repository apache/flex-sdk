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

public interface SVGTextPathElement extends 
               SVGTextContentElement,
               SVGURIReference {
  // textPath Method Types
  public static final short TEXTPATH_METHODTYPE_UNKNOWN   = 0;
  public static final short TEXTPATH_METHODTYPE_ALIGN     = 1;
  public static final short TEXTPATH_METHODTYPE_STRETCH     = 2;
  // textPath Spacing Types
  public static final short TEXTPATH_SPACINGTYPE_UNKNOWN   = 0;
  public static final short TEXTPATH_SPACINGTYPE_AUTO     = 1;
  public static final short TEXTPATH_SPACINGTYPE_EXACT     = 2;

  public SVGAnimatedLength              getStartOffset( );
  public SVGAnimatedEnumeration getMethod( );
  public SVGAnimatedEnumeration getSpacing( );
}
