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
