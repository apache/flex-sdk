/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class LabeledStatementNode extends Node
{
    public Node label;
    public Node statement;
    public int loop_index;
    public boolean is_loop_label;

    public LabeledStatementNode(Node label, boolean is_loop_label, Node statement)
    {
        this.label = label;
        this.statement = statement;
        this.loop_index = 0;
        this.is_loop_label = is_loop_label;
    }

    public Value evaluate(Context cx, Evaluator evaluator)
    {
        if (evaluator.checkFeature(cx, this))
        {
            return evaluator.evaluate(cx, this);
        }
        else
        {
            return null;
        }
    }

    public int countVars()
    {
        return statement.countVars();
    }

    public boolean isBranch()
    {
        return true;
    }

    public boolean isLabeledStatement()
    {
        return true;
    }

    public String toString()
    {
        return "LabeledStatement";
    }
}
