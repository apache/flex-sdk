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
package org.apache.flex.forks.batik.util;

/**
 * A simple Doubly Linked list class, designed to avoid
 * O(n) behaviour on insert and delete.
 */
public class DoublyLinkedList {

    /**
     * Basic doubly linked list node interface.
     */
	public static class Node {
		private Node next = null;
		private Node prev = null;
			
		public final Node getNext() { return next; }
		public final Node getPrev() { return prev; }
						
		protected final void setNext(Node newNext) { next = newNext; }
		protected final void setPrev(Node newPrev) { prev = newPrev; }

        /**
         * Unlink this node from it's current list...
         */
		protected final void unlink() {
			if (getNext() != null)
				getNext().setPrev(getPrev());
			if (getPrev() != null)
				getPrev().setNext(getNext());
			
			setNext(null);
			setPrev(null);
		}
						
        /**
         * Link this node in, infront of nde (unlinks it's self
         * before hand if needed).
         * @param nde the node to link in before.
         */
		protected final void insertBefore(Node nde) {
			// Already here...
			if (this == nde) return;

			if (getPrev() != null)
                unlink();
			
			// Actually insert this node...
			if (nde == null) {
				// empty lst...
				setNext(this);
				setPrev(this);
			} else {
				setNext(nde);
				setPrev(nde.getPrev());
				nde.setPrev(this);
                if (getPrev() != null)
                    getPrev().setNext(this);
			}
		}
	}


    private Node head = null;
    private int  size = 0;
			
    public DoublyLinkedList() {}
			
    /**
     * Returns the number of elements currently in the list.
     */
    public synchronized int getSize() { return size; }

    /**
     * Removes all elements from the list.
     */
    public synchronized void empty() {
        while(size > 0) pop();
    }
			
    /**
     * Get the current head element
     * @return The current 'first' element in list.
     */
    public Node getHead() { return head; }
    /**
     * Get the current tail element
     * @return The current 'last' element in list.
     */
    public Node getTail() { return head.getPrev(); }

    /**
     * Moves <tt>nde</tt> to the head of the list (equivilent to
     * remove(nde); add(nde); but faster.
     */
    public void touch(Node nde) {
        if (nde == null) return;
        nde.insertBefore(head);
        head = nde;
    }

    public void add(int index, Node nde) {
        if (nde == null) return;
        if (index == 0) {
              // This makes it the first element in the list.
            nde.insertBefore(head);
            head = nde;
        } else if (index == size) {
              // Because the list is circular this
              // makes it the last element in the list.
            nde.insertBefore(head);
        } else {
            Node after = head;
            while (index != 0) {
                after = after.getNext();
                index--;
            }
            nde.insertBefore(after);
        }
        size++;
    }

    /**
     * Adds <tt>nde</tt> to the head of the list.
     * In perl this is called an 'unpop'.  <tt>nde</tt> should
     * not currently be part of any list.
     * @param nde the node to add to the list.
     */
    public void add(Node nde) {
        if (nde == null) return;
        nde.insertBefore(head);
        head = nde;
        size++;
    }
		
	/**
     * Removes nde from the list it is part of (should be this
     * one, otherwise results are undefined).  If nde is the
     * current head element, then the next element becomes head,
     * if there are no more elements the list becomes empty.
     * @param nde node to remove.
     */
    public void remove(Node nde) {
        if (nde == null) return;
        if (nde == head) {
            if (head.getNext() == head) 
                head = null;  // Last node...
            else
                head = head.getNext();
        }
        nde.unlink();
        size--;
    }

    /**
     * Removes 'head' from list and returns it. Returns null if list is empty.
     * @return current head element, next element becomes head.
     */
    public Node pop() {
        if (head == null) return null;
			
        Node nde = head;
        remove(nde);
        return nde;
    }

    /**
     * Removes 'tail' from list and returns it. Returns null if list is empty.
     * @return current tail element.
     */
    public Node unpush() {
        if (head == null) return null;
			
        Node nde = getTail();
        remove(nde);
        return nde;
    }



    /**
     * Adds <tt>nde</tt> to tail of list
     */
    public void push(Node nde) {
        nde.insertBefore(head);
        if (head == null) head = nde;
        size++;
    }

    /**
     * Adds <tt>nde</tt> to head of list
     */
    public void unpop(Node nde) {
        nde.insertBefore(head);
        head = nde;
        size++;
    }
}

