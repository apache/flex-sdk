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

package macromedia.asc.semantics;

import macromedia.asc.util.*;
import macromedia.asc.parser.*;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

import static macromedia.asc.parser.Tokens.*;
import static macromedia.asc.util.BitSet.*;

/**
 * FlowGraphEmitter
 *
 * @author Jeff Dyer
 */
public final class FlowGraphEmitter extends Emitter
{
	private boolean hasLeader;
	private ObjectList<Block> blocks = new ObjectList<Block>();
	private ObjectList<Node> defs = new ObjectList<Node>();
	private int cur_block;
	// unsigned int  def_count;
	private int def_count;
	private boolean show_blocks;
	private int within_try_block;
	private Context cx;

	public void EnterBlock()
	{
		if (hasLeader)
		{
			hasLeader = false;
			if (cur_block != blocks.size() - 1)
			{
				assert(false); // throw "Internal error";
			}
			blocks.add(cx.newBlock());
			++cur_block;
		}
	}

	public BitSet NewDef(Node node)
	{

		BitSet def_mask = null;

		// ISSUE: make it so if this limit is exceeded, the
		// flow analysis still works, by using a bit vector.

		if (def_count >= Node.MAX_DEF_BITS)
		{
			//cx.internalError("error: internal limit Node.MAX_DEF_BITS exceeded");
			for (Block block : blocks)
			{
				block.def_bits = null;
			}
		}
		else 
		{
			def_mask = set(null, def_count, true);
			if (defs.size() <= def_count)
			{
				defs.resize(def_count + 1);
			}
			defs.set(def_count, node);
			Block block = blocks.get(cur_block);
			block.def_bits = set(block.def_bits, def_count, true);
		}
		++def_count;

		return def_mask;
	}

	public ObjectList<Node> GetDefs(BitSet def_bits)
	{
		ObjectList<Node> defs = new ObjectList<Node>();
		
		// Iterate only over set bits
		for(int i=BitSet.nextSetBit(def_bits,0); i>=0; i=BitSet.nextSetBit(def_bits,i+1))
		{
			defs.add(this.defs.get(i));
		}
		return defs;
	}

	public int GetBlock()
	{
		if (!hasLeader)
		{
			hasLeader = true;
		}
		return cur_block;
	}

	public Block getBlock()
	{
		return blocks.get(cur_block);
	}

	public void AddStmtToBlock(String stmt)
	{
		if (!hasLeader)
		{
			hasLeader = true;
            if( show_blocks )
            {
			    blocks.get(cur_block).stmts = "\n    " + stmt; // only show leader
            }
		}
	}

	public void EnterTerminalBlock()
	{
		EnterBlock();
		blocks.get(cur_block).is_terminal = true;
		AddStmtToBlock("terminal block for return"); // make sure no other statements end up in this block
		EnterBlock();
	}

	public boolean blockIsTerminal(int b)
	{
		return blocks.get(b).is_terminal;
	}

	public void AddEdge(int b1, int b2)
	{
		// don't draw edges from blocks which can't be reached
		if (blocks.get(b1).is_terminal)
			return;

		//System.out.println("AddEdge " + b1 + " -> " + b2);
		IntList succs = blocks.get(b1).succs;
		int i = 0, n = succs.size();
		for (; i < n && succs.get(i) != b2; i++)
		{
			;
		}
		if (i == n)
		{
			succs.add(b2);
			//blocks.get(b1).succs_blk.add(blocks.get(b2));
		}

		IntList preds = blocks.get(b2).preds;
		i = 0;
		n = preds.size();
		for (; i < n && preds.get(i) != b1; i++)
		{
			;
		}
		if (i == n)
		{
			preds.add(b1);
			//blocks.get(b2).preds_blk.add(blocks.get(b1));
		}
	}

	// This creates a copy of the current block set. The caller
	// is responsible for deleting individual block before deleting
	// this (unique) copy.

	public ObjectList<Block> GetBlocks()
	{
		return blocks;
	}

	public void InitGraph()
	{
		blocks.clear();
		cur_block = 0;
		hasLeader = true;
		blocks.add(cx.newBlock());
	}

	public void calcGenAndKill(Context cx)
	{
		BitSet gen_bits = null;
		BitSet kill_bits = null;

		for (int i = 0, size = blocks.size(); i < size; i++)
		{
			Block block = blocks.get(i);

			final BitSet defbits = block.def_bits;
		
			// Iterate only over set bits
			for(int n=nextSetBit(defbits,0); n>=0; n=nextSetBit(defbits,n+1))
			{
				Node node = defs.get(n);
				if (node != null)
				{
					Slot slot = node.getRef(cx).getSlot(cx, GET_TOKEN);
					if (slot != null)
					{
						gen_bits = set(null, n, true);
						if (slot.getDefBits() != null)
						{
							kill_bits = xor(slot.getDefBits(), gen_bits);
						}
						else
						{
							kill_bits = gen_bits;
						}
					}
				}
				block.gen_bits = reset_set(block.gen_bits, kill_bits, gen_bits);
				block.kill_bits = reset_set(block.kill_bits, gen_bits, kill_bits);
			}
		}
	}

	public void calcInAndOut(Context cx)
	{
		for (int i = 0, size = blocks.size(); i < size; i++)
		{
			Block block = blocks.get(i);
			block.in_bits = null;
			block.out_bits = copy(block.gen_bits);
		}

		boolean change;

		do
		{
			change = false;

			for (int i = 0, size = blocks.size(); i < size; ++i)
			{
				Block block = blocks.get(i);

				// For each pred
				int terminalPreds = 0;
				for (int n = 0; n < block.preds.size(); ++n)
				{
					Block pred = blocks.get(block.preds.get(n));
					block.in_bits = set(block.in_bits, pred.out_bits);
					if (block.preds.get(n) != 0 && pred.preds.size() == 0)
						++terminalPreds;
				}
				if (terminalPreds == block.preds.size() && block.is_terminal == false)
				{
					block.is_terminal = true;
					block.preds.clear();
					change = true;
				}

				BitSet out_bits = copy(block.in_bits);
				out_bits = reset_set(out_bits, block.kill_bits, block.gen_bits);
				if (!BitSet.equals(block.out_bits, out_bits))
				{
					change = true;
					block.out_bits = out_bits;
				}
			}
		}
		while (change);
	}

	public void printBlocks(Context cx)
	{

		for (int i = 0, size = blocks.size(); i < size; ++i)
		{
			BitSet bits;
			int n;

			Block block = blocks.get(i);

			// Pred

			int j;
			System.out.print("\nB" + i + ": Pred {");
			for (j = 0; j < block.preds.size(); ++j)
			{
				System.out.print(" B" + block.preds.get(j));
			}

			// Succ

			System.out.print(" } Succ {");
			for (j = 0; j < block.succs.size(); ++j)
			{
				System.out.print(" B" + block.succs.get(j));
			}

			// Def

			System.out.print(" } Def {");
		
			// Iterate only over set bits
			bits = block.def_bits;
			for(n=nextSetBit(bits,0); n>=0; n=nextSetBit(bits,n+1))
			{
				System.out.print(" d" + n);
			}

			// Gen

			System.out.print(" } Gen {");
			bits = block.gen_bits;
			for(n=nextSetBit(bits,0); n>=0; n=nextSetBit(bits,n+1))
			{
				System.out.print(" d" + n);
			}

			// Kill

			System.out.print(" } Kill {");
			bits = block.kill_bits;
			for(n=nextSetBit(bits,0); n>=0; n=nextSetBit(bits,n+1))
			{
				System.out.print(" d" + n);
			}

			// In

			System.out.print(" } In {");
			bits = block.in_bits;
			for(n=nextSetBit(bits,0); n>=0; n=nextSetBit(bits,n+1))
			{
				System.out.print(" d" + n);
			}

			// Out

			System.out.print(" } Out {");
			bits = block.out_bits;
			for(n=nextSetBit(bits,0); n>=0; n=nextSetBit(bits,n+1))
			{
				System.out.print(" d" + n);
			}
			System.out.print(" }");

			System.out.print(block.stmts);
			/*for (Node node : block.nodes)
			{
				System.out.print("\n" + node.toString());
			}*/
		}
	}

	public void printFlowGraph(Context cx, String scriptname, String methname)
	{
/*
digraph test {
ratio=fill
ranksep=.1
nodesep=.2
rankdir=LR
edge [arrowsize=.7,labeldistance=1.0,labelangle=-45,labelfontsize=9]
node [fontsize=9,shape=box,width=.2,height=.2]
B0[label="B0"]
B0 . B1 [weight=2]
B1[label="B1"]
B1 . B2 [weight=2]
B1 . B3 [weight=2]
B2[label="B2"]
B2 . B4 [weight=2]
B3[label="B3"]
B3 . B4 [weight=2]
B4[label="B4"]
}
*/
		BufferedWriter out = null;
		try
		{
			out = new BufferedWriter(new FileWriter(scriptname + "." + methname + ".dot"));
			out.write("\ndigraph cfg {");
			out.write("\nratio=fill");
			out.write("\nranksep=.25");
			out.write("\nnodesep=.2");
			out.write("\nrankdir=LR");
			out.write("\nedge [arrowsize=.7,labeldistance=1.0,labelangle=-45,labelfontsize=9]");
			out.write("\nnode [fontsize=9,shape=box,width=.2,height=.2]");

			for (int i = 0; i < blocks.size(); ++i)
			{
				out.write("\nB" + i + "[label=\"B" + i + "\"]");

				// Succ

				int j;
				for (j = 0; j < blocks.get(i).succs.size(); ++j)
				{
					out.write("\nB" + i + " . B" + blocks.get(i).succs.get(j) + "[weight=2]");
				}
			}
			out.write("\n}");
		}
		catch (IOException ex)
		{
			ex.printStackTrace();
		}
		finally
		{
			if (out != null)
			{
				try
				{
					out.close();
				}
				catch (IOException ex)
				{
				}
			}
		}
	}

	protected int max_temp_count;   // use to allocate temp variables
	protected int cur_temp_count;   // use to allocate temp variables
	protected int max_stack;   // use to allocate local variables
	protected int cur_stack;   // use to allocate local variables
	protected char max_params;   //
	protected String scriptname;

	protected IntList if_addrs = new IntList();
	protected IntList else_addrs = new IntList();
	protected IntList loopbegin_addrs = new IntList();
	protected ObjectList<IntList> break_addrs = new ObjectList<IntList>();
	protected ObjectList<IntList> continue_addrs = new ObjectList<IntList>();
	protected IntList switchbegin_addrs = new IntList();
	protected ObjectList<IntList> case_addrs = new ObjectList<IntList>();
	protected IntList default_addrs = new IntList();
	protected IntList seen_default_case = new IntList();
	protected int current_with_count;
    protected IntList with_count = new IntList();
    
    protected IntList try_addrs = new IntList();
	protected ObjectList<IntList> catch_addrs = new ObjectList<IntList>();

	static final int scopes_register = 0;
	static final int obj_register = 1;
	static final int args_register = 2;

	public void StartClass(String scriptname)
	{
	}

	public void FinishClass(Context cx, QName name, QName basename, boolean is_dynamic)
	{
	}

	public void StartProgram(String scriptname)
	{
	}

	public void FinishProgram(Context cx, final String name, int unused)
	{
	}


	public void StartMethod(String name, int param_count, int local_count, int temp_count, boolean needs_activation, int needs_arguments)
	{
		if (show_instructions)
		{
			System.out.print("\n// ++StartMethod " + name + ", " + param_count + ", " + local_count);
		}
		InitGraph();
		EnterBlock();
		AddEdge(cur_block - 1, cur_block);
		cur_temp_count = max_temp_count = 0; // to start
	}

	public int FinishMethod(Context cx, final String name, TypeInfo type, ObjectList<TypeInfo> types, ObjectValue activation, int needs_arguments, int scope_depth, final String debug_name,boolean is_native,boolean is_interface, String[] arg_names)
	{
		if (show_instructions)
		{
			System.out.print("\n// --FinishMethod " + name);
		}

		// If the current (last) block does not have a leader, undo it.

		if (!hasLeader)
		{
			blocks.removeLast();
			--cur_block;
		}

		calcGenAndKill(cx);
		calcInAndOut(cx);
		if (show_blocks)
		{
			if (true) // print text form, or graph form
			{
				System.out.print("\n" + name + ":");
				printBlocks(cx);
			}
			else
			{
				printFlowGraph(cx, scriptname, name);
			}
		}
		return 0;
	}

	public void MakeDispatchMethod(Context cx)
	{
	}


	// Temps are allocated from max_locals down to the fixed
	// locals

	public int allocateTemp()
	{
		int temp = cur_temp_count++;
		if (cur_temp_count > max_temp_count)
		{
			max_temp_count = cur_temp_count;
		}
		return temp-1;
	}

	public void freeTemp(int t)
	{
		--cur_temp_count;
	}

	public int getTempCount()
	{
		return max_temp_count;
	}

	public void stack(int size)
	{
		cur_stack += size;
		if (cur_stack > max_stack)
		{
			max_stack = cur_stack;
		}
	}

	public IntList stackDepthStack = new IntList();

	public void saveStackDepth()
	{
		stackDepthStack.add(cur_stack);
	}

	public void restoreStackDepth()
	{
		cur_stack = stackDepthStack.removeLast();
	}

	public int getIP()
	{
		return 0;
	}


	/* Abstract Machine Language instructions
	 */

	/*
    public void Break(int loop_index);
    public void CaseLabel(boolean is_default);
    public void Continue(int loop_index);
    public void Else();
    public void If();
    public void LoopBegin();
    public void LoopEnd();
    public void PatchIf(int addr);
    public void PatchElse(int addr);
    public void PatchLoopBegin(int addr);
    public void PatchBreak(int loop_index);
    public void PatchContinue(int loop_index);
    public void PatchSwitchBegin(int addr);
    public void Return(int type_id);
    public void SwitchBegin();
    public void SwitchTable();
    */

	/*
	 * Break(loop_index)
	 */

	public void Break(int loop_index)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" Break target " + loop_index);
		}

		if (loop_index >= 0 && loop_index < break_addrs.size())
		{
			AddStmtToBlock("Break");
			break_addrs.get(loop_index).add(cur_block);
		} // otherwise, it is a label without a loop

		EnterBlock();
	}

	/*
	 * Continue(loop_index)
	 */

	public void Continue(int loop_index)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" Continue " + loop_index);
		}

		if (loop_index >= 0 && loop_index < continue_addrs.size())
		{
			AddStmtToBlock("Continue");
			continue_addrs.get(loop_index).add(cur_block);
		} // a label without a loop

		EnterBlock();
	}

	public void CaseLabel(boolean is_default)
	{
		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			if (is_default)
			{
				System.out.print(" CaseLabel default");
			}
			else
			{
				System.out.print(" CaseLabel");
			}
		}

		EnterBlock();

		// Add an edge from the previous case to this one.
		// More often than not, this is only imaginary, since
		// the use of break statements at the end of a case
		// is common. However, we need to make this conservative
		// approximation to avoid introducing lies into the
		// flow graph. Further analysis can be used to determine
		// if there is a dominant break in the previous block.

		if (case_addrs.last().size() != 0)
		{
			AddEdge(cur_block - 1, cur_block);
		}

		if (is_default)
		{
			if (seen_default_case.last() == 0)
			{
				default_addrs.add(cur_block);
				case_addrs.last().add(cur_block);
				seen_default_case.set(seen_default_case.size() - 1, 1);
			}
		}
		else
		{
			case_addrs.last().add(cur_block);
		}
	}
	/*
	 * Try
	 *
	 *  Throw statements outside of a try block exit the current block.
	 *   We know we are within a Try block between this call and
	 *   FinallyClauseEnd()
	 */
	public void Try(boolean hasFinally)
	{
		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" Try");
		}

		within_try_block++;
		
		EnterBlock();
		AddEdge(cur_block - 1, cur_block);
		
		try_addrs.add(cur_block);
		catch_addrs.add(new IntList());
	}

    /*
     * CatchClauseBegin
     *
     */
    public void CatchClausesBegin()
    {
        if (show_linenums)
        {
            int[] ln = new int[1], col = new int[1];
            String[] name = new String[1];
            getOriginAndPosition(name, ln, col);
            System.out.print("\n[Ln " + ln[0] + "]");
        }
        if (show_instructions)
        {
            System.out.print(" CatchClausesBegin");
        }
    }
    
    /*
     * Catch
     */
    public void Catch(TypeValue type, final QName name)
    {
    	// Start a new block for this catch clause
    	EnterBlock();
    	
    	// Add the catch clause to the list
    	catch_addrs.last().add(cur_block);
    }
    
    /*
     * CatchClauseBegin
     *
     */
    public void CatchClausesEnd()
    {
        if (show_linenums)
        {
            int[] ln = new int[1], col = new int[1];
            String[] name = new String[1];
            getOriginAndPosition(name, ln, col);
            System.out.print("\n[Ln " + ln[0] + "]");
        }
        if (show_instructions)
        {
            System.out.print(" CatchClausesEnd");
        }

        if (within_try_block > 0)
        {
            within_try_block--; 
        }
        
        // Start a new block for the finally clause
        EnterBlock();

        // Add an edge from every block in the try section
        // to the beginning of every catch block.
        IntList catch_list = catch_addrs.last();
        int try_start = try_addrs.last();
        int try_end   = catch_list.at(0);
        for (int i=try_start; i<try_end; i++)
        {
        	for (int j=0, n=catch_list.size(); j<n; j++)
        	{
        		AddEdge(i, catch_list.at(j));
        	}
        }
        
        // Add an edge from every block in the try and
        // from every block in every catch
        // to the start of the finally clause.
        for (int i=try_start; i<cur_block; i++)
        {
        	AddEdge(i, cur_block);
        }
    }
    
    /*
	 * FinallyClauseEnd
	 *
	 *  Throw statements outside of a try block exit the current block.
	 *   We know we are within a Try block between Try() and this FinallyClauseEnd
	 *   Note that a throw in a Catch clause will still execute the finally block 
	 *
	 */
	public void FinallyClauseEnd()
	{
		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" FinallyClauseEnd");
		}
		
		try_addrs.pop_back();
		catch_addrs.pop_back();
	}

	/*
	 * Throw
	 *
	 *  If not within a Try block, treat just like a return: exit the current block.
	 *
	 */
	public void Throw()
	{
		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" Throw");
		}

		if (within_try_block == 0)
		{
			AddStmtToBlock("Throw");
			EnterTerminalBlock();
		}
	}
	/*
	 * SwitchTable
	 *
	 * Generate code to jump to the case corresponding to
	 * the index on the stack.
	 */

	public void SwitchTable()
	{
		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" SwitchTable");
		}

		AddStmtToBlock("SwitchTable");

		int default_addr = default_addrs.last();
		default_addrs.removeLast();
		AddEdge(cur_block, default_addr); // default_addr is default_block

		IntList case_addr = case_addrs.removeLast();
		for (int case_index = 0; case_index < case_addr.size(); ++case_index)
		{
			AddEdge(cur_block, case_addr.get(case_index)); // addr is block
		}

		EnterBlock();

	}

	/*
	 * If
	 *
	 */

	public void If(int kind)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" If");
		}
		AddStmtToBlock("If");

		if_addrs.add(GetBlock());

		saveStackDepth();

		EnterBlock();
		AddEdge(cur_block - 1, cur_block);
	}

	/*
	 * PatchIf
	 *
	 * Patches the bytes pointed to by the index on
	 * the top of the if_addrs stack, with the specified
	 * target address.
	 */

	public void PatchIf(int target)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" PatchIf");
		}

		restoreStackDepth();

		int if_index = if_addrs.last();
		if_addrs.removeLast();

		EnterBlock();
		AddEdge(if_index, cur_block); // from jump to else
	}

	/*
	 * Else
	 *
	 */

	public void Else()
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" Else");
		}

		else_addrs.add(GetBlock());

		EnterBlock();
	}

	/*
	 * PatchBreak
	 */

	public void PatchBreak(int loop_index)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" PatchBreak " + loop_index);
		}

		// ASSERT(loop_index==break_addrs.size()-1);

		IntList break_addr = break_addrs.removeLast();
		while (break_addr.size() != 0)
		{
			int break_index = break_addr.last();
			AddEdge(break_index, cur_block);
			break_addr.removeLast();
//            EnterBlock();
		}
	}

	/*
	 * PatchContinue
	 */

	public void PatchContinue(int loop_index)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" PatchContinue " + loop_index);
		}

		// ASSERT(loop_index==continue_addrs.size()-1);

		IntList continue_addr = continue_addrs.removeLast();
		while (continue_addr.size() != 0)
		{
			int continue_index = continue_addr.last();
//            EnterBlock();
			AddEdge(continue_index, cur_block);
			continue_addr.removeLast();
		}

	}

	/*
	 * PatchElse
	 */

	public void PatchElse(int target)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" PatchElse");
		}

		int else_index = else_addrs.last();
		else_addrs.removeLast();

		EnterBlock();
		AddEdge(else_index, cur_block);  // from then to end
		AddEdge(cur_block - 1, cur_block); // from else to end
	}

	/*
	 * Return
	 *
	 */

	public void Return(int type_id)
	{
		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" Return");
		}

		AddStmtToBlock("Return");
		// return from within a try block will send execution
		//  to the catch or finally blocks if an error is thrown
		//  while evaluating its expr
		if (within_try_block == 0)
			EnterTerminalBlock();

	}

	/*
	 * LabelStatement handling (to handle breaks within a labelStatement's statement block)
	 *
	 */
	public void LabelStatementBegin()
	{
		break_addrs.add(new IntList());
	}

	public void LabelStatementEnd(int loop_index)
	{
		PatchBreak(loop_index);
	}

	/*
	 * LoopBegin
	 *
	 */

	public void LoopBegin()
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" LoopBegin");
		}

		AddStmtToBlock("LoopBegin");

		break_addrs.add(new IntList());
		continue_addrs.add(new IntList());
		loopbegin_addrs.add(cur_block + 1);
		with_count.add(current_with_count);

		EnterBlock();
	}

	/*
	 * LoopEnd
	 *
	 */

	public void LoopEnd(int kind)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" LoopEnd");
		}

		AddEdge(cur_block, loopbegin_addrs.last());     // Jump to start of loop
		EnterBlock();
		AddEdge(cur_block - 1, cur_block);
		loopbegin_addrs.removeLast();
		with_count.pop_back();
	}

	/*
	 * PatchLoopBegin
	 */

	public void PatchLoopBegin(int target)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" PatchLoopBegin " + target);
		}

		EnterBlock();
		AddEdge(cur_block - 1, cur_block);              // incr . test block
		AddEdge(loopbegin_addrs.last() - 1, cur_block); // First time through
/*
#if 0
	    if( loopbegin_addrs.last() != cur_block )
	    {
	        AddEdge(loopbegin_addrs.last(),cur_block);
	    }
#endif
*/
	}

	/*
	 * PatchSwitchBegin
	 */

	public void PatchSwitchBegin(int addr)
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" PatchSwitchBegin " + addr);
		}

		int switchbegin_index = switchbegin_addrs.last();
		seen_default_case.removeLast();
		switchbegin_addrs.removeLast();

		EnterBlock();
		AddEdge(switchbegin_index, cur_block); // Jump past statements
	}

	/*
	 * SwitchBegin
	 *
	 */

	public void SwitchBegin()
	{

		if (show_linenums)
		{
			int[] ln = new int[1], col = new int[1];
			String[] name = new String[1];
			getOriginAndPosition(name, ln, col);
			System.out.print("\n[Ln " + ln[0] + "]");
		}
		if (show_instructions)
		{
			System.out.print(" SwitchBegin");
		}

		AddStmtToBlock("SwitchBegin");

		seen_default_case.add(0);
		case_addrs.add(new IntList());
		break_addrs.add(new IntList());
		continue_addrs.add(new IntList());
		// Even though switches do not have continues, this is
		// to keep the loop index of nested loops synchronized
		// with this vector.

		switchbegin_addrs.add(GetBlock());
		EnterBlock();
	}


	public boolean show_instructions;
	public boolean show_linenums;
	public boolean show_stacknames;

	/*
	 */

	public FlowGraphEmitter(Context cx, String scriptname, boolean show_blocks)
	{
		this.cx = cx;
		this.scriptname = scriptname;
		def_count = 0;
		cur_block = 0;
		hasLeader = true;
		show_instructions = false;
		show_linenums = false;
		this.show_blocks = show_blocks;
		within_try_block = 0;
		InitGraph();
		EnterBlock();
	}

	public ByteList emit(ByteList bytes)
	{
		return bytes;
	}

}
