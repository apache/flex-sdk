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
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.w3c.dom.css.DocumentCSS;
import org.w3c.dom.css.ViewCSS;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.EventTarget;

public interface SVGSVGElement extends 
               SVGElement,
               SVGTests,
               SVGLangSpace,
               SVGExternalResourcesRequired,
               SVGStylable,
               SVGLocatable,
               SVGFitToViewBox,
               SVGZoomAndPan,
               EventTarget,
               DocumentEvent,
               ViewCSS,
               DocumentCSS {
  public SVGAnimatedLength getX( );
  public SVGAnimatedLength getY( );
  public SVGAnimatedLength getWidth( );
  public SVGAnimatedLength getHeight( );
  public String         getContentScriptType( );
  public void      setContentScriptType( String contentScriptType )
                       throws DOMException;
  public String         getContentStyleType( );
  public void      setContentStyleType( String contentStyleType )
                       throws DOMException;
  public SVGRect           getViewport( );
  public float getPixelUnitToMillimeterX( );
  public float getPixelUnitToMillimeterY( );
  public float getScreenPixelToMillimeterX( );
  public float getScreenPixelToMillimeterY( );
  public boolean getUseCurrentView( );
  public void      setUseCurrentView( boolean useCurrentView )
                       throws DOMException;
  public SVGViewSpec getCurrentView( );
  public float getCurrentScale( );
  public void      setCurrentScale( float currentScale )
                       throws DOMException;
  public SVGPoint getCurrentTranslate( );

  public int          suspendRedraw ( int max_wait_milliseconds );
  public void          unsuspendRedraw ( int suspend_handle_id )
                  throws DOMException;
  public void          unsuspendRedrawAll (  );
  public void          forceRedraw (  );
  public void          pauseAnimations (  );
  public void          unpauseAnimations (  );
  public boolean       animationsPaused (  );
  public float         getCurrentTime (  );
  public void          setCurrentTime ( float seconds );
  public NodeList      getIntersectionList ( SVGRect rect, SVGElement referenceElement );
  public NodeList      getEnclosureList ( SVGRect rect, SVGElement referenceElement );
  public boolean       checkIntersection ( SVGElement element, SVGRect rect );
  public boolean       checkEnclosure ( SVGElement element, SVGRect rect );
  public void          deselectAll (  );
  public SVGNumber              createSVGNumber (  );
  public SVGLength              createSVGLength (  );
  public SVGAngle               createSVGAngle (  );
  public SVGPoint               createSVGPoint (  );
  public SVGMatrix              createSVGMatrix (  );
  public SVGRect                createSVGRect (  );
  public SVGTransform           createSVGTransform (  );
  public SVGTransform     createSVGTransformFromMatrix ( SVGMatrix matrix );
  public Element         getElementById ( String elementId );
}
