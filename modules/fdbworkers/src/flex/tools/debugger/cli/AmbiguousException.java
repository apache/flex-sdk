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

package flex.tools.debugger.cli;

/**
 * An exception that is thrown when some ambiguous condition or state
 * was encountered.  It is usually not fatal, and normally caused
 * by some user interaction which can be overcome. 
 */
public class AmbiguousException extends Exception
{
    private static final long serialVersionUID = -1627900831637441719L;
    
    public AmbiguousException() {}
    public AmbiguousException(String s) { super(s); }
}
