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
package org.apache.flex.forks.batik.util;

/**
 * Constants for SMIL animation element and attribute names and values.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: SMILConstants.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SMILConstants {

    // Element names
    String SMIL_ANIMATE_TAG = "animate";
    String SMIL_ANIMATE_COLOR_TAG = "animateColor";
    String SMIL_ANIMATE_MOTION_TAG = "animateMotion";
    String SMIL_SET_TAG = "set";

    // Attributes names
    String SMIL_ACCUMULATE_ATTRIBUTE = "accumulate";
    String SMIL_ADDITIVE_ATTRIBUTE = "additive";
    String SMIL_ATTRIBUTE_NAME_ATTRIBUTE = "attributeName";
    String SMIL_ATTRIBUTE_TYPE_ATTRIBUTE = "attributeType";
    String SMIL_BEGIN_ATTRIBUTE = "begin";
    String SMIL_BY_ATTRIBUTE = "by";
    String SMIL_CALC_MODE_ATTRIBUTE = "calcMode";
    String SMIL_DUR_ATTRIBUTE = "dur";
    String SMIL_END_ATTRIBUTE = "end";
    String SMIL_FILL_ATTRIBUTE = "fill";
    String SMIL_KEY_POINTS_ATTRIBUTE = "keyPoints";
    String SMIL_KEY_SPLINES_ATTRIBUTE = "keySplines";
    String SMIL_KEY_TIMES_ATTRIBUTE = "keyTimes";
    String SMIL_FROM_ATTRIBUTE = "from";
    String SMIL_ORIGIN_ATTRIBUTE = "origin";
    String SMIL_MAX_ATTRIBUTE = "max";
    String SMIL_MIN_ATTRIBUTE = "min";
    String SMIL_PATH_ATTRIBUTE = "path";
    String SMIL_REPEAT_COUNT_ATTRIBUTE = "repeatCount";
    String SMIL_REPEAT_DUR_ATTRIBUTE = "repeatDur";
    String SMIL_RESTART_ATTRIBUTE = "restart";
    String SMIL_TO_ATTRIBUTE = "to";
    String SMIL_VALUES_ATTRIBUTE = "values";

    // Attribute values
    String SMIL_ALWAYS_VALUE = "always";
    String SMIL_AUTO_VALUE = "auto";
    String SMIL_CSS_VALUE = "CSS";
    String SMIL_DEFAULT_VALUE = "default";
    String SMIL_DISCRETE_VALUE = "discrete";
    String SMIL_FREEZE_VALUE = "freeze";
    String SMIL_HOLD_VALUE = "hold";
    String SMIL_INDEFINITE_VALUE = "indefinite";
    String SMIL_LINEAR_VALUE = "linear";
    String SMIL_MEDIA_VALUE = "media";
    String SMIL_NEVER_VALUE = "never";
    String SMIL_NONE_VALUE = "none";
    String SMIL_PACED_VALUE = "paced";
    String SMIL_REMOVE_VALUE = "remove";
    String SMIL_REPLACE_VALUE = "replace";
    String SMIL_SPLINE_VALUE = "spline";
    String SMIL_SUM_VALUE = "sum";
    String SMIL_WHEN_NOT_ACTIVE_VALUE = "whenNotActive";
    String SMIL_XML_VALUE = "XML";

    // Default attribute values
    String SMIL_BEGIN_DEFAULT_VALUE = "0";

    // SMIL TimeEvent types
    String SMIL_BEGIN_EVENT_NAME = "beginEvent";
    String SMIL_END_EVENT_NAME = "endEvent";
    String SMIL_REPEAT_EVENT_NAME = "repeatEvent";
    String SMIL_REPEAT_EVENT_ALT_NAME = "repeat";
}
