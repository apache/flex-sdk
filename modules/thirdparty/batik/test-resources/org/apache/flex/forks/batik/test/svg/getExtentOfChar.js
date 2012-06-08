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
    var svgns = "http://www.w3.org/2000/svg";

    function show(evt,parent){

       var doc = evt.target.getOwnerDocument();

       var parent = doc.getElementById(parent);

       processChildren(parent);

    }

    function processChildren(parent){
        
        var child = parent.getFirstChild();
        
        while ( child != null ){

          if ( child.getNodeType() == child.ELEMENT_NODE ){
              
              if ( child.getLocalName() == "text" ){
                 addAllCharactersBBox(child)
              }
              else{
                 if ( child.getLocalName() != "defs" ){
                    processChildren(child);
                 }
              }
          }
          child = child.getNextSibling();
        }
    }

    function addAllCharactersBBox(textElement){

      var doc = textElement.getOwnerDocument();

      var bboxgroup = doc.getElementById("bboxes");

      if ( bboxgroup == null ){
        
        bboxgroup = doc.createElementNS(svgns,"g");
        bboxgroup.setAttributeNS(null,"id","bboxes");
        bboxgroup.setAttributeNS(null,"style","fill:none;stroke:red;stroke-width:0.2%");
        doc.getDocumentElement().appendChild(bboxgroup);
      }

      count = textElement.getNumberOfChars();

      for( i = 0 ; i < count ; i++ ){
        var newRect =
            doc.createElementNS(textElement.SVG_NAMESPACE_URI,textElement.SVG_RECT_TAG);

        var characterRect = textElement.getExtentOfChar(i);

        newRect.setAttributeNS(null,newRect.SVG_X_ATTRIBUTE,characterRect.getX());
        newRect.setAttributeNS(null,newRect.SVG_Y_ATTRIBUTE,characterRect.getY());
        newRect.setAttributeNS(null,newRect.SVG_WIDTH_ATTRIBUTE,characterRect.getWidth());
        newRect.setAttributeNS(null,newRect.SVG_HEIGHT_ATTRIBUTE,characterRect.getHeight());

        bboxgroup.appendChild(newRect);
      }      
    }
