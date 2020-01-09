
	.text
	.globl	insert_node
	.def	insert_node;	.scl	2;	.type	32;	.endef


# This function inserts a new NODE into the binary search
# tree in the appropriate position.

# REGISTERS USED:
# p = %r8, new_n = %rcx


#   if (root == NULL) {
#     root = new_n;
#     return;
#}
insert_node:
	pushq	%rbp
	movq	%rsp, %rbp

	cmpq $0, root(%rip)
	jne not_null
	movq %rcx, root(%rip)
	jmp DONE

not_null:

# NODE *p = root;

  movq root(%rip),%r8

#  while(1) {

#    if (new_n->person.id == p->person.id) {
TOP:
	movq 0(%rcx), %r10
	cmpq %r10, 0(%r8)
  jne cmp_last
	jmp DONE
#     break;
#     }

#Compare the last name in the new node with the
# last name in the current node (i.e. the node
# pointed to by p).

# int res = strcmp(new_n->person.last, p->person.last);
cmp_last:

	pushq %rcx
	pushq %r8

	leaq 116(%rcx), %rcx
	leaq 116(%r8), %rdx

	subq $32, %rsp
	call strcmp
	addq $32, %rsp

	popq %r8
	popq %rcx

# If the two last names are the same, then compare the
# first names.

# if (res == 0)
# res = strcmp(new_n->person.first, p->person.first);
	cmpl $0,%eax
	jne L1

	pushq %rcx
	pushq %r8

	leaq 16(%rcx), %rcx
	leaq 16(%r8), %rdx


	subq $32, %rsp
	call strcmp
	addq $32, %rsp

	popq %r8
	popq %rcx

# At this point, res < 0 indicates that the new node
# comes before (alphabetically) the current node, and
# thus must inserted into the left subtree of p.

#if (res < 0) {

L1:
	cmpl $0, %eax
	jg L2

# If p does not have a left child, then new node
# becomes the left child.
# (p->left == NULL) {
# p->left = new_n;
#	break;
#   }
#    else {

	cmpq $0, 216(%r8)
	jne L3
	movq %rcx, 216(%r8)
	jmp DONE

# otherwise, traverse down the left subtree.
# 	p = p->left;
#      }
#   }

L3:
	movq 216(%r8), %r8
	jmp TOP

# Otherwise, if res >= 0, the new node goes in the
# right subtree.

# else {

# If p does not have a right child, then new node
# becomes the right child.

# if (p->right == NULL) {
# 	p->right = new_n;
#	break;
#      }
#     else {

L2:
	cmpq $0,224(%r8)
	jne L4
	movq %rcx, 224(%r8)
	jmp DONE

# otherwise, traverse down the right subtree.

# 	p = p->right;

L4:
	movq 224(%r8), %r8
	jmp TOP


DONE:
	popq %rbp
	ret



	.text
	.globl	remove_smallest
	.def	remove_smallest;	.scl	2;	.type	32;	.endef

# This function removes the smallest node from the binary
# search tree. That is, it removes the node representing
# the employee whose name comes before (alphabetically) the
# other employees in the tree. The function returns
# a pointer to the node that has been returned.

# REGISTERS USED:
# parent = %r9, p = %r8, root = %rcx (in L5)

# If the tree is already empty, return NULL.
remove_smallest:
	pushq	%rbp
	movq	%rsp, %rbp

#  if (root == NULL) {
	cmpq $0,root(%rip)
	jne L5
	movq $0,%rax # return NULL
	jmp DONE2

# If there is no left child of the root, then the smallest
# node is the root node. Set root to point to its right child
# and return the old root node.
L5:
	movq root(%rip), %rcx
	cmpq $0, 216(%rcx)
	jne L6
	movq root(%rip), %r8
	movq 224(%rcx), %rcx
	movq %rcx, root(%rip)
	movq %r8, %rax
	jmp DONE2
#   if (root->left == NULL) {
#     NODE *p = root;
#     root = root->right;
#     return p;
#   }

# At this point, we know that root has a left child,
# i.e. that root->left is not NULL. We'll need to
# keep track of the parent of the node that we're
# eventually removing, so we use a "parent" pointer
# for that purpose.
L6:
	movq root(%rip), %r9
#   NODE *parent = root;


# Traverse down the left side of the tree until we
# hit a node that doesn't have a left child.  Again,
# our "parent" pointer points to the parent of
# such a node.

#  while (parent->left->left != NULL) {
#     parent = parent->left;
#   }
WHILE:
	movq 216(%r9), %r10 # parent = parent->left
	movq 216(%r10), %r10 # parent = parent->left
	cmpq $0, %r10
	je L7
	movq 216(%r9), %r9
	jmp WHILE

# At this point, parent->left points to the node with
# the smallest value (alphabetically).  So, we are
# going to set parent->left to parent->left->right,
# and return the old parent->left.
# save parent function into r11

L7:
	movq 216(%r9), %r8

	movq 216(%r9), %r11 # parent = parent->left
	movq 224(%r11), %r11 # parent = parent->right
	movq %r11, 216(%r9)
	movq %r8, %rax

#   NODE *p = parent->left;
#   parent->left = parent->left->right;
#   return p;
DONE2:
	popq %rbp
	ret
