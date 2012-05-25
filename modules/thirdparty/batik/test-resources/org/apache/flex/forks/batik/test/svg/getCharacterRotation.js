//    <defs>
//      <path id="arrow" d="M-5 0 L 5 0 M 0 -5 L 0 5z" />
//    </defs>

    var svgns = "http://www.w3.org/2000/svg";

    function show(evt,parent){

       var doc = evt.target.getOwnerDocument();

       var parent = doc.getElementById(parent);

       var bboxgroup = doc.getElementById("bboxGroup");

       if ( bboxgroup == null ){
        
         bboxgroup = doc.createElementNS(svgns,"g");
         bboxgroup.setAttributeNS(null,"id","bboxGroup");
         bboxgroup.setAttributeNS(null,"style","fill:none;stroke-opacity:0.5;stroke-width:0.6%");
         doc.getDocumentElement().appendChild(bboxgroup);
       }
       //create the arrow
      var defs = doc.createElementNS(svgns,"defs");
      var line = doc.createElementNS(svgns,"line");
        //line stroke-width="3" id="line" x1="-5" y1="0" x2="5" y2="0"
      line.setAttributeNS(null,"id","line");
      line.setAttributeNS(null,"x1","-1%");
      line.setAttributeNS(null,"x2","1%");
      line.setAttributeNS(null,"y1","0");
      line.setAttributeNS(null,"y2","0");
      defs.appendChild(line);
      doc.getDocumentElement().insertBefore(defs,doc.getDocumentElement().getFirstChild());

      processChildren(parent);

    }

    function processChildren(parent){
        
        var child = parent.getFirstChild();
        
        while ( child != null ){

          if ( child.getNodeType() == child.ELEMENT_NODE ){
              
              if ( child.getLocalName() == "text" ){
                 addAllCharactersPosition(child)
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

        function addAllCharactersPosition(textElement){

              count = textElement.getNumberOfChars();

              for( i = 0 ; i < count ; i++ ){
                showRotationAngle(textElement,i);
              }

        }

        function showRotationAngle(elt, index)
        {
                var doc = elt.getOwnerDocument();

                var angle = elt.getRotationOfChar(index);

                var group = doc.getElementById('bboxGroup');

                var u = doc.createElementNS("http://www.w3.org/2000/svg","use");

                var point1 = elt.getStartPositionOfChar(index);
                var point2 = elt.getEndPositionOfChar(index);

                x = ( point1.getX() + point2.getX() )/2;
                y = ( point1.getY() + point2.getY() )/2;

                u.setAttributeNS(null,"transform","translate("+x+","+y+") rotate("+angle+") ");
                u.setAttributeNS("http://www.w3.org/1999/xlink","href","#line");
                u.setAttributeNS(null,"stroke","green");
                group.appendChild(u);

        }