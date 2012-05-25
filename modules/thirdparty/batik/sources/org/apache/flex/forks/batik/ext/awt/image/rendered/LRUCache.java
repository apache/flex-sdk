/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image.rendered;

import org.apache.flex.forks.batik.util.DoublyLinkedList;

public class LRUCache {

    /**
     * Interface for object participating in the LRU Cache.  These
     * inform the object of key events in the status of the object in
     * the LRU cache.  
     */
	public interface LRUObj {
        /**
         * Called when the object first becomes active in the LRU cache.
         * @param nde The LRU cache node associated with this object.
         *            should be remembered so it can be returned by
         *            <tt>lruGet</tt>.  
         */
		public  void    lruSet(LRUNode nde);
        /**
         * Called to get the LRU node for this object.  Should return the
         * node passed in to lruSet.
         */
		public  LRUNode lruGet();
        /**
         * Called to inform the object that it is no longer in the cache.
         */
		public  void    lruRemove();
	}

    /**
     * Interface for nodes in the LRU cache, basicly nodes in a doubly
     * linked list.
     */
	public class LRUNode extends DoublyLinkedList.Node {
		private   LRUObj  obj  = null;
		public    LRUObj  getObj ()               { return obj; }
		protected void    setObj (LRUObj  newObj) { 
			if (obj != null) obj.lruRemove();

			obj = newObj;
			if (obj != null) obj.lruSet(this);
		}
	}

	private DoublyLinkedList free    = null;
	private DoublyLinkedList used    = null;
	private int     maxSize = 0;
		
	public LRUCache(int size) {
		if (size <= 0) size=1;
		maxSize = size;
		
		free = new DoublyLinkedList();
		used = new DoublyLinkedList();
		
		while (size > 0) {
			free.add(new LRUNode());
			size--;
		}
	}

	public int getUsed() {
		return used.getSize();
	}

	public synchronized void setSize(int newSz) {

		if (maxSize < newSz) {  // list grew...

			for (int i=maxSize; i<newSz; i++)
				free.add(new LRUNode());

		} else if (maxSize > newSz) {

			for (int i=used.getSize(); i>newSz; i--) {
				LRUNode nde = (LRUNode)used.getTail();
				used.remove(nde);
				nde.setObj(null);
			}
		}

		maxSize = newSz;
	}

	public synchronized void flush() {
		while (used.getSize() > 0) {
			LRUNode nde = (LRUNode)used.pop();
			nde.setObj(null);
			free.add(nde);
		}
	}

	public synchronized void remove(LRUObj obj) {
		LRUNode nde = obj.lruGet();
		if (nde == null) return;
		used.remove(nde);
		nde.setObj(null);
		free.add(nde);
	}

	public synchronized void touch(LRUObj obj) {
		LRUNode nde = obj.lruGet();
		if (nde == null) return;
		used.touch(nde);
	}

	public synchronized void add(LRUObj obj) {
		LRUNode nde = obj.lruGet();

		// already linked in...
		if (nde != null) {
			used.touch(nde);
			return;
		}

		if (free.getSize() > 0) {
			nde = (LRUNode)free.pop();
			nde.setObj(obj);
			used.add(nde);
		} else {
			nde = (LRUNode)used.getTail();
			nde.setObj(obj);
			used.touch(nde);
		}
	}

	protected synchronized void print() {
		System.out.println("In Use: " + used.getSize() +
						   " Free: " + free.getSize());
		LRUNode nde = (LRUNode)used.getHead();
        if (nde == null) return;
		do {
			System.out.println(nde.getObj());
			nde = (LRUNode)nde.getNext();
		} while (nde != used.getHead());
	}

}
