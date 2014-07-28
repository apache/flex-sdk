package mx.collections {
import mx.collections.ArrayCollection;

public class DataNode {
    private var _label:String;
    private var _children:ArrayCollection;
    private var _isSelected:Boolean = false;
    private var _isPreviousSiblingRemoved:Boolean = false;

    public function DataNode(label:String)
    {
        _label = label;
    }

    public function get children():ArrayCollection {
        return _children;
    }

    public function set children(value:ArrayCollection):void {
        _children = value;
    }

    public function get label():String {
        return _label + (_isSelected ? " [SEL]" : "") + (_isPreviousSiblingRemoved ? " [PREV ITEM REMOVED]" : "");
    }

    public function toString():String
    {
        return label;
    }

    public function addChild(node:DataNode):void {
        if(!_children)
            _children = new ArrayCollection();

        _children.addItem(node);
    }

    public function set isSelected(value:Boolean):void {
        _isSelected = value;
    }

    public function get isSelected():Boolean {
        return _isSelected;
    }

    public function clone():DataNode
    {
        var newNode:DataNode = new DataNode(_label);
        for each(var childNode:DataNode in children)
        {
            newNode.addChild(childNode.clone());
        }

        return newNode;
    }

    public function set isPreviousSiblingRemoved(value:Boolean):void {
        _isPreviousSiblingRemoved = value;
    }
}
}
