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

package flash.swf.builder.types;

/**
 * Defines the API for iterating over a Shape.
 *
 * @author Peter Farland
 */
public interface ShapeIterator
{
	public boolean isDone();
	public short currentSegment(double[] coords);
	public void next();

	public static final short MOVE_TO = 0;
	public static final short LINE_TO = 1;
	public static final short QUAD_TO = 2;
	public static final short CUBIC_TO = 3;
	public static final short CLOSE = 4;
}
