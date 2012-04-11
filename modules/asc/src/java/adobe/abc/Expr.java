/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package adobe.abc;

import static adobe.abc.OptimizerConstants.*;

public class Expr implements Comparable<Expr>
{
	public int op;
	public Expr[] args = noexprs;   // args taken from operand stack
	public Expr[] scopes = noexprs; // args taken from scope stack
	public Expr[] locals = noexprs; // args taken from local variables
	public int[] imm;
	public Edge[] pred=noedges; // phi nodes only
	public Edge[] succ; // branch nodes only
	public int id;
	public int flags;
	public Name ref;
	public Object value; // only if pushconst
	public Type c; // only if OP_newclass
	public Method m; // only if OP_newfunction | callstatic
	boolean is_live_out = false;
	Typeref inferred_type = null;

	public Expr(Method m, int op)
	{
		this.op = op;
		flags = flagTable[op];
		id = m.getNextExprId();
	}

	public Expr(Method m, int op, int imm1)
	{
		this(m,op);
		this.imm = new int[] { imm1 };
	}

	public Expr(Method m, int op, Object value)
	{
		this(m, op);
		this.value = value;
	}
	
	public Expr(Method m, int op, Expr arg)
	{
		this(m, op);
		args = new Expr[] { arg };
	}

	public Expr(Method m, int op, Expr[] frame, int sp, int argc)
	{
		this(m, op);
		args = GlobalOptimizer.capture(frame, sp, argc);
	}

	public Expr(Method m, int op, int imm1, Expr[] frame, int sp, int argc)
	{
		this(m,op,frame,sp,argc);
		this.imm = new int[] { imm1 };
	}

	public Expr(Method m, int op, Name ref, Expr[] frame, int sp, int argc)
	{
		this(m, op,frame,sp,argc);
		this.ref = ref;
	}

	public Expr(Method m, int op, Name ref, Expr arg)
	{
		this(m, op);
		this.ref = ref;
		this.args = new Expr[] { arg };
	}
	
	public int id()
	{
		return id;
	}
	
	void append(Expr a, Edge p)
	{
		args = GlobalOptimizer.copyOf(args, args.length+1);
		args[args.length-1] = a;

		pred = GlobalOptimizer.copyOf(pred, pred.length+1);
		pred[pred.length-1] = p;
	}
	
	/**
	 *  Remove an input expression/edge from a phi node.
	 *  This occurs when the input is copy-propagated, 
	 *  or if the input edge is unreachable.
	 *  @param j -- the input index.
	 */
	void removePhiInput(int j)
	{
		assert(OP_phi == this.op);
		Expr[] a = new Expr[args.length-1];
		System.arraycopy(args, 0, a, 0, j);
		System.arraycopy(args, j+1, a, j, args.length-j-1);
		args = a;
		
		Edge[] ed = new Edge[pred.length-1];
		System.arraycopy(pred, 0, ed, 0, j);
		System.arraycopy(pred, j+1, ed, j, pred.length-j-1);
		pred = ed;
	}
	
	public String toString()
	{
		return (onStack() ? "t": onScope() ? "s" : inLocal() ? "l" : "i")+id;
	}

	void clearEffect()
	{
		flags &= ~EFFECT;
	}
	
	void clearPx()
	{
		flags &= ~PX;
	}
	
	public void setPure()
	{
		clearEffect();
		clearPx();
	}
	
	public boolean hasEffect()
	{
		return (flags & EFFECT) != 0;
	}
	
	public boolean isPx()
	{
		return (flags & PX) != 0;
	}

	public boolean isSynthetic()
	{
		return (flags & SYNTH) != 0;
	}
	
	public boolean onStack()
	{
		return (flagTable[op] & STKVAL) != 0;
	}

	public boolean isOper()
	{
		return (flagTable[op] & OPER) != 0;
	}
	
	public boolean onScope()
	{
		return (flagTable[op] & SCPVAL) != 0;
	}
	
	public boolean inLocal()
	{
		return (flagTable[op] & LOCVAL) != 0;
	}

	public boolean isCoerce()
	{
		return (flagTable[op] & COERCE) != 0;
	}

	public int compareTo(Expr other)
	{
		assert(this.id != other.id || this == other);
		return this.id - other.id;
	}
}
