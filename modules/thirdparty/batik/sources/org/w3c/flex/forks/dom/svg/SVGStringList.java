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

public interface SVGStringList {
  public int getNumberOfItems( );

  public void   clear (  )
                  throws DOMException;
  public String initialize ( String newItem )
                  throws DOMException, SVGException;
  public String getItem ( int index )
                  throws DOMException;
  public String insertItemBefore ( String newItem, int index )
                  throws DOMException, SVGException;
  public String replaceItem ( String newItem, int index )
                  throws DOMException, SVGException;
  public String removeItem ( int index )
                  throws DOMException;
  public String appendItem ( String newItem )
                  throws DOMException, SVGException;
}
