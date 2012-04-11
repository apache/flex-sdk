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

package flash.swf.types;

/**
 * A value object for bevel filter data.
 *
 * @author Roger Gonzalez
 */
public class BevelFilter extends Filter
{
    public final static int ID = 3;
    public int getID() { return ID; }

    public int shadowColor;
    public int highlightColor;
    public int blurX;
    public int blurY;
    public int angle;
    public int distance;
    public int strength;
    public int flags;
}
