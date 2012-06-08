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

public interface SVGPathSeg {
  // Path Segment Types
  public static final short PATHSEG_UNKNOWN                      = 0;
  public static final short PATHSEG_CLOSEPATH                    = 1;
  public static final short PATHSEG_MOVETO_ABS                   = 2;
  public static final short PATHSEG_MOVETO_REL                   = 3;
  public static final short PATHSEG_LINETO_ABS                   = 4;
  public static final short PATHSEG_LINETO_REL                   = 5;
  public static final short PATHSEG_CURVETO_CUBIC_ABS            = 6;
  public static final short PATHSEG_CURVETO_CUBIC_REL            = 7;
  public static final short PATHSEG_CURVETO_QUADRATIC_ABS        = 8;
  public static final short PATHSEG_CURVETO_QUADRATIC_REL        = 9;
  public static final short PATHSEG_ARC_ABS                      = 10;
  public static final short PATHSEG_ARC_REL                      = 11;
  public static final short PATHSEG_LINETO_HORIZONTAL_ABS        = 12;
  public static final short PATHSEG_LINETO_HORIZONTAL_REL        = 13;
  public static final short PATHSEG_LINETO_VERTICAL_ABS          = 14;
  public static final short PATHSEG_LINETO_VERTICAL_REL          = 15;
  public static final short PATHSEG_CURVETO_CUBIC_SMOOTH_ABS     = 16;
  public static final short PATHSEG_CURVETO_CUBIC_SMOOTH_REL     = 17;
  public static final short PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS = 18;
  public static final short PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL = 19;

  public short getPathSegType( );
  public String      getPathSegTypeAsLetter( );
}
