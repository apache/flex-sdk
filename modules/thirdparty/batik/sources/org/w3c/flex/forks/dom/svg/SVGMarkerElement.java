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

public interface SVGMarkerElement extends 
               SVGElement,
               SVGLangSpace,
               SVGExternalResourcesRequired,
               SVGStylable,
               SVGFitToViewBox {
  // Marker Unit Types
  public static final short SVG_MARKERUNITS_UNKNOWN        = 0;
  public static final short SVG_MARKERUNITS_USERSPACEONUSE = 1;
  public static final short SVG_MARKERUNITS_STROKEWIDTH    = 2;
  // Marker Orientation Types
  public static final short SVG_MARKER_ORIENT_UNKNOWN      = 0;
  public static final short SVG_MARKER_ORIENT_AUTO         = 1;
  public static final short SVG_MARKER_ORIENT_ANGLE        = 2;

  public SVGAnimatedLength      getRefX( );
  public SVGAnimatedLength      getRefY( );
  public SVGAnimatedEnumeration getMarkerUnits( );
  public SVGAnimatedLength      getMarkerWidth( );
  public SVGAnimatedLength      getMarkerHeight( );
  public SVGAnimatedEnumeration getOrientType( );
  public SVGAnimatedAngle      getOrientAngle( );

  public void setOrientToAuto (  );
  public void setOrientToAngle ( SVGAngle angle );
}
