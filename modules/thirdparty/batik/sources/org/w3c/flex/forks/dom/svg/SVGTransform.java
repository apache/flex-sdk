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

public interface SVGTransform {
  // Transform Types
  public static final short SVG_TRANSFORM_UNKNOWN   = 0;
  public static final short SVG_TRANSFORM_MATRIX    = 1;
  public static final short SVG_TRANSFORM_TRANSLATE = 2;
  public static final short SVG_TRANSFORM_SCALE     = 3;
  public static final short SVG_TRANSFORM_ROTATE    = 4;
  public static final short SVG_TRANSFORM_SKEWX     = 5;
  public static final short SVG_TRANSFORM_SKEWY     = 6;

  public short getType( );
  public SVGMatrix getMatrix( );
  public float getAngle( );

  public void setMatrix ( SVGMatrix matrix );
  public void setTranslate ( float tx, float ty );
  public void setScale ( float sx, float sy );
  public void setRotate ( float angle, float cx, float cy );
  public void setSkewX ( float angle );
  public void setSkewY ( float angle );
}
