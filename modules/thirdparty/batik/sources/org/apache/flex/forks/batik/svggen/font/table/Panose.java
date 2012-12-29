/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.svggen.font.table;

/**
 * @version $Id: Panose.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class Panose {

  byte bFamilyType = 0;
  byte bSerifStyle = 0;
  byte bWeight = 0;
  byte bProportion = 0;
  byte bContrast = 0;
  byte bStrokeVariation = 0;
  byte bArmStyle = 0;
  byte bLetterform = 0;
  byte bMidline = 0;
  byte bXHeight = 0;

  /** Creates new Panose */
  public Panose(byte[] panose) {
    bFamilyType = panose[0];
    bSerifStyle = panose[1];
    bWeight = panose[2];
    bProportion = panose[3];
    bContrast = panose[4];
    bStrokeVariation = panose[5];
    bArmStyle = panose[6];
    bLetterform = panose[7];
    bMidline = panose[8];
    bXHeight = panose[9];
  }

  public byte getFamilyType() {
    return bFamilyType;
  }
  
  public byte getSerifStyle() {
    return bSerifStyle;
  }
  
  public byte getWeight() {
    return bWeight;
  }

  public byte getProportion() {
    return bProportion;
  }
  
  public byte getContrast() {
    return bContrast;
  }
  
  public byte getStrokeVariation() {
    return bStrokeVariation;
  }
  
  public byte getArmStyle() {
    return bArmStyle;
  }
  
  public byte getLetterForm() {
    return bLetterform;
  }
  
  public byte getMidline() {
    return bMidline;
  }
  
  public byte getXHeight() {
    return bXHeight;
  }
  
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(String.valueOf(bFamilyType)).append(" ")
      .append(String.valueOf(bSerifStyle)).append(" ")
      .append(String.valueOf(bWeight)).append(" ")
      .append(String.valueOf(bProportion)).append(" ")
      .append(String.valueOf(bContrast)).append(" ")
      .append(String.valueOf(bStrokeVariation)).append(" ")
      .append(String.valueOf(bArmStyle)).append(" ")
      .append(String.valueOf(bLetterform)).append(" ")
      .append(String.valueOf(bMidline)).append(" ")
      .append(String.valueOf(bXHeight));
    return sb.toString();
  }
}
