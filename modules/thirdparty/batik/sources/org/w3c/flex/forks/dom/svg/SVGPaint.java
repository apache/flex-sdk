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


public interface SVGPaint extends 
               SVGColor {
  // Paint Types
  public static final short SVG_PAINTTYPE_UNKNOWN               = 0;
  public static final short SVG_PAINTTYPE_RGBCOLOR              = 1;
  public static final short SVG_PAINTTYPE_RGBCOLOR_ICCCOLOR     = 2;
  public static final short SVG_PAINTTYPE_NONE                  = 101;
  public static final short SVG_PAINTTYPE_CURRENTCOLOR          = 102;
  public static final short SVG_PAINTTYPE_URI_NONE              = 103;
  public static final short SVG_PAINTTYPE_URI_CURRENTCOLOR      = 104;
  public static final short SVG_PAINTTYPE_URI_RGBCOLOR          = 105;
  public static final short SVG_PAINTTYPE_URI_RGBCOLOR_ICCCOLOR = 106;
  public static final short SVG_PAINTTYPE_URI                   = 107;

  public short getPaintType( );
  public String      getUri( );

  public void setUri ( String uri );
  public void setPaint ( short paintType, String uri, String rgbColor, String iccColor )
                  throws SVGException;
}
