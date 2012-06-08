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

public interface SVGMatrix {
  public float getA( );
  public void      setA( float a )
                       throws DOMException;
  public float getB( );
  public void      setB( float b )
                       throws DOMException;
  public float getC( );
  public void      setC( float c )
                       throws DOMException;
  public float getD( );
  public void      setD( float d )
                       throws DOMException;
  public float getE( );
  public void      setE( float e )
                       throws DOMException;
  public float getF( );
  public void      setF( float f )
                       throws DOMException;

  public SVGMatrix multiply ( SVGMatrix secondMatrix );
  public SVGMatrix inverse (  )
                  throws SVGException;
  public SVGMatrix translate ( float x, float y );
  public SVGMatrix scale ( float scaleFactor );
  public SVGMatrix scaleNonUniform ( float scaleFactorX, float scaleFactorY );
  public SVGMatrix rotate ( float angle );
  public SVGMatrix rotateFromVector ( float x, float y )
                  throws SVGException;
  public SVGMatrix flipX (  );
  public SVGMatrix flipY (  );
  public SVGMatrix skewX ( float angle );
  public SVGMatrix skewY ( float angle );
}
