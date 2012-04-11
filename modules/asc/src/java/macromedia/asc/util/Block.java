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

package macromedia.asc.util;

/**
 * @author Jeff Dyer
 */
public class Block
{
	public Block() { is_terminal = false; }
	
	public BitSet def_bits;
	public BitSet gen_bits;
	public BitSet kill_bits;
	public BitSet in_bits;
	public BitSet out_bits;
	public String stmts;
	public boolean is_terminal; // This block can not have a successor, it represents the block jumped to by "return"

	//public ObjectList<Node> nodes = new ObjectList<Node>();
	//public ObjectList<Node> epilog = new ObjectList<Node>();
	public IntList preds = new IntList(1);
	public IntList succs = new IntList(1);
	//public Blocks preds_blk = new Blocks();
	//public Blocks succs_blk = new Blocks();
}
