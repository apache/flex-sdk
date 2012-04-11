/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.parser;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public abstract class DefinitionNode extends Node
{
	public AttributeListNode attrs;

    public StatementListNode metaData;
    public PackageDefinitionNode pkgdef;

	// C: allow Evaluators to skip this definition node and the rest of the branch. e.g. LintEvaluator skips
	//    coaching of VariableDefinitionNode, FunctionDefinition and ClassDefinitionNode. The purpose is
	//    to allow LintEvaluator to coach part of ProgramNode. Other Evaluators can find this boolean value
	//    for different purposes.
	private boolean skip;
	//skip is also now used by uiactionsevaluator to keep from duplicate processing of nodes

	public DefinitionNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, int pos)
	{
		super(pos);
		this.attrs = attrs;
		this.pkgdef = pkgdef;
	}
	
	public boolean isDefinition()
	{
		return true;
	}

	public void skipNode(boolean b)
	{
		skip = b;
	}

	public boolean skip()
	{
		return skip;
	}

    public void addMetaDataNode(Node node)
    {
        if( metaData == null )
        {
            metaData = new StatementListNode(node);
        }
        else
        {
            metaData.items.push_back(node);
        }
    }
}
