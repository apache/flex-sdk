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
public interface SVGLength {
  // Length Unit Types
  public static final short SVG_LENGTHTYPE_UNKNOWN    = 0;
  public static final short SVG_LENGTHTYPE_NUMBER     = 1;
  public static final short SVG_LENGTHTYPE_PERCENTAGE = 2;
  public static final short SVG_LENGTHTYPE_EMS        = 3;
  public static final short SVG_LENGTHTYPE_EXS        = 4;
  public static final short SVG_LENGTHTYPE_PX         = 5;
  public static final short SVG_LENGTHTYPE_CM         = 6;
  public static final short SVG_LENGTHTYPE_MM         = 7;
  public static final short SVG_LENGTHTYPE_IN         = 8;
  public static final short SVG_LENGTHTYPE_PT         = 9;
  public static final short SVG_LENGTHTYPE_PC         = 10;

  public short getUnitType( );
  public float          getValue( );
  public void           setValue( float value )
                       throws DOMException;
  public float          getValueInSpecifiedUnits( );
  public void           setValueInSpecifiedUnits( float valueInSpecifiedUnits )
                       throws DOMException;
  public String      getValueAsString( );
  public void           setValueAsString( String valueAsString )
                       throws DOMException;

  public void newValueSpecifiedUnits ( short unitType, float valueInSpecifiedUnits );
  public void convertToSpecifiedUnits ( short unitType );
}
