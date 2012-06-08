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

import org.w3c.dom.events.EventTarget;

public interface SVGPathElement extends 
               SVGElement,
               SVGTests,
               SVGLangSpace,
               SVGExternalResourcesRequired,
               SVGStylable,
               SVGTransformable,
               EventTarget,
               SVGAnimatedPathData {
  public SVGAnimatedNumber getPathLength( );

  public float         getTotalLength (  );
  public SVGPoint      getPointAtLength ( float distance );
  public int          getPathSegAtLength ( float distance );
  public SVGPathSegClosePath    createSVGPathSegClosePath (  );
  public SVGPathSegMovetoAbs    createSVGPathSegMovetoAbs ( float x, float y );
  public SVGPathSegMovetoRel    createSVGPathSegMovetoRel ( float x, float y );
  public SVGPathSegLinetoAbs    createSVGPathSegLinetoAbs ( float x, float y );
  public SVGPathSegLinetoRel    createSVGPathSegLinetoRel ( float x, float y );
  public SVGPathSegCurvetoCubicAbs    createSVGPathSegCurvetoCubicAbs ( float x, float y, float x1, float y1, float x2, float y2 );
  public SVGPathSegCurvetoCubicRel    createSVGPathSegCurvetoCubicRel ( float x, float y, float x1, float y1, float x2, float y2 );
  public SVGPathSegCurvetoQuadraticAbs    createSVGPathSegCurvetoQuadraticAbs ( float x, float y, float x1, float y1 );
  public SVGPathSegCurvetoQuadraticRel    createSVGPathSegCurvetoQuadraticRel ( float x, float y, float x1, float y1 );
  public SVGPathSegArcAbs    createSVGPathSegArcAbs ( float x, float y, float r1, float r2, float angle, boolean largeArcFlag, boolean sweepFlag );
  public SVGPathSegArcRel    createSVGPathSegArcRel ( float x, float y, float r1, float r2, float angle, boolean largeArcFlag, boolean sweepFlag );
  public SVGPathSegLinetoHorizontalAbs    createSVGPathSegLinetoHorizontalAbs ( float x );
  public SVGPathSegLinetoHorizontalRel    createSVGPathSegLinetoHorizontalRel ( float x );
  public SVGPathSegLinetoVerticalAbs    createSVGPathSegLinetoVerticalAbs ( float y );
  public SVGPathSegLinetoVerticalRel    createSVGPathSegLinetoVerticalRel ( float y );
  public SVGPathSegCurvetoCubicSmoothAbs    createSVGPathSegCurvetoCubicSmoothAbs ( float x, float y, float x2, float y2 );
  public SVGPathSegCurvetoCubicSmoothRel    createSVGPathSegCurvetoCubicSmoothRel ( float x, float y, float x2, float y2 );
  public SVGPathSegCurvetoQuadraticSmoothAbs    createSVGPathSegCurvetoQuadraticSmoothAbs ( float x, float y );
  public SVGPathSegCurvetoQuadraticSmoothRel    createSVGPathSegCurvetoQuadraticSmoothRel ( float x, float y );
}
