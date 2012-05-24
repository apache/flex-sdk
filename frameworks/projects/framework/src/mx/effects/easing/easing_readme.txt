////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

============================================================================================
 Easing Equations v2.0
 September 1, 2003
 (c) 2003 Robert Penner, all rights reserved. 
 This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.
============================================================================================

These tweening functions provide different flavors of 
math-based motion under a consistent API. 

Types of easing:

      Linear
      Quadratic
      Cubic
      Quartic
      Quintic
      Sinusoidal
      Exponential
      Circular
      Elastic
      Back
      Bounce

Changes:
3.0 - ported to ActionScript 3.0; Added ASDoc comments
2.0 - ported to ActionScript 2.0; functions now in packages and use strong typing
1.5 - added bounce easing
1.4 - added elastic and back easing
1.3 - tweaked the exponential easing functions to make endpoints exact
1.2 - inline optimizations (changing t and multiplying in one step)--thanks to Tatsuo Kato for the idea

Discussed in Chapter 7 of 
Robert Penner's Programming Macromedia Flash MX
(including graphs of the easing equations)

http://www.robertpenner.com/profmx
http://www.amazon.com/exec/obidos/ASIN/0072223561/robertpennerc-20
