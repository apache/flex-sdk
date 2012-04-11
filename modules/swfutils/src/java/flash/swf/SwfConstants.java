/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf;

/**
 * SWF related constants.
 *
 * @author Peter Farland
 */
public interface SwfConstants
{
    /**
     * Assumes a resolution of 72 dpi, at which the Macromedia Flash Player
     * renders 20 twips to a pixel.
     */
    int TWIPS_PER_PIXEL = 20;

    int WIDE_OFFSET_THRESHOLD = 65535;

    float FIXED_POINT_MULTIPLE = 65536.0F;
    float FIXED_POINT_MULTIPLE_8 = 256.0F;
    float MORPH_MAX_RATIO = 65535.0F;

    int GRADIENT_SQUARE = 32768;

    int LANGCODE_DEFAULT = 0;
    int LANGCODE_LATIN = 1;
    int LANGCODE_JAPANESE = 2;
    int LANGCODE_KOREAN = 3;
    int LANGCODE_SIMPLIFIED_CHINESE = 4;
    int LANGCODE_TRADIIONAL_CHINESE = 5;

    int TEXT_ALIGN_LEFT = 0;
    int TEXT_ALIGN_RIGHT = 1;
    int TEXT_ALIGN_CENTER = 2;
    int TEXT_ALIGN_JUSTIFY = 3;
}
