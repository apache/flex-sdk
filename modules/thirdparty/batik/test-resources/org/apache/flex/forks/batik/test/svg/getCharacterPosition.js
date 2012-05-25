//    <defs>
//      <path id="arrow" d="M-5 0 L 5 0 M 0 -5 L 0 5z" />
//    </defs>

    var svgns = "http://www.w3.org/2000/svg";

    function show(evt,parent,pos){

       var doc = evt.target.getOwnerDocument();

       var parent = doc.getElementById(parent);

       var bboxgroup = doc.getElementById("bboxGroup");

       if ( bboxgroup == null ){
        
         bboxgroup = doc.createElementNS(svgns,"g");
         bboxgroup.setAttributeNS(null,"id","bboxGroup");
         bboxgroup.setAttributeNS(null,"style","fill:none;stroke-opacity:0.5;stroke-width:0.2%");
         doc.getDocumentElement().appendChild(bboxgroup);
       }
       //create the arrow
      var defs = doc.createElementNS(svgns,"defs");
      var path = doc.createElementNS(svgns,"path");
      path.setAttributeNS(null,"id","arrow");
      path.setAttributeNS(null,"d","M-5 0 L 5 0 M 0 -5 L 0 5z");
      defs.appendChild(path);
      doc.getDocumentElement().insertBefore(defs,doc.getDocumentElement().getFirstChild());

      processChildren(parent,pos);

    }

    function processChildren(parent,pos){
        
        var child = parent.getFirstChild();
        
        while ( child != null ){

          if ( child.getNodeType() == child.ELEMENT_NODE ){
              
              if ( child.getLocalName() == "text" ){
                 addAllCharactersPosition(child,pos)
              }
              else{
                 if ( child.getLocalName() != "defs" ){
                    processChildren(child,pos);
                 }
              }
          }
          child = child.getNextSibling();
        }
    }

        function addAllCharactersPosition(textElement,pos){

              count = textElement.getNumberOfChars();

              for( i = 0 ; i < count ; i++ ){
                if ( pos == "start" ){
                    showCharactersStartPosition(textElement,i);
                }
                else{
                    showCharactersEndPosition(textElement,i);
                }
              }

        }

        function showCharactersStartPosition(elt, index)
        {
                var doc = elt.getOwnerDocument();

                var group = doc.getElementById('bboxGroup');

                //while (group.hasChildNodes() ){
                //   group.removeChild(group.getFirstChild());
                //}

                var u = doc.createElementNS("http://www.w3.org/2000/svg","use");

                var point = elt.getStartPositionOfChar(index);

                u.setAttributeNS(null,"transform","translate("+point.getX()+","+point.getY()+")");
                u.setAttributeNS("http://www.w3.org/1999/xlink","href","#arrow");
                u.setAttributeNS(null,"stroke","green");
                group.appendChild(u);
                        
        }

        function showCharactersEndPosition(elt, index)
        {
                var doc = elt.getOwnerDocument();

                var group = doc.getElementById('bboxGroup');

                //while (group.hasChildNodes() ){
                //   group.removeChild(group.getFirstChild());
                //}

                var u = doc.createElementNS("http://www.w3.org/2000/svg","use");

                var point = elt.getEndPositionOfChar(index);

                u.setAttributeNS(null,"transform","translate("+point.getX()+","+point.getY()+")");
                u.setAttributeNS("http://www.w3.org/1999/xlink","href","#arrow");
                u.setAttributeNS(null,"stroke","blue");
                group.appendChild(u);
                        
        }
