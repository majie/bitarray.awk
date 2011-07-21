#!/bin/gawk -f

# Copyright (c) 2011 Ma Jie

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

###############################################################
#                         Usage                               #
#                                                             #
# $gawk -f bitarray.awk -f yourscript.awk                     #
#                                                             #
###############################################################

# local_* in function declaration parameter lists are local
# variables. When calling a function with local_*, don't
# assign/pass any value to them. They are defined in the parameter
# list to avoid name pollution to the whole script.



# function bitarray_init initializes the internal arrays.
# int count, number of bits in the array
# bool allset, if true, all bits are set when initialized,
#			otherwise all bits are cleared.
function bitarray_init(count, allset, local_i, local_num, local_intcount) {
	bitarray_sizeofint = length(sprintf("%x", -1)) * 4;
	bitarray_count = count;

	if (allset)
		local_num = -1;
	else
		local_num = 0;
	
	local_intcount = int(count / bitarray_sizeofint) + 1;
	for (local_i = 0; local_i < count; local_i++) {
		bitarray_bits[local_i] = local_num;
	}
	
	for (local_i = 0; local_i < bitarray_sizeofint; local_i++) {
		bitarray_masks[local_i] = lshift(1, local_i);
		bitarray_rmasks[local_i] = compl(bitarray_masks[local_i]);
	}
}

# function bitarray_set sets a bit in the bit array.
# int which, specify which bit you want to set
function bitarray_set(which, local_q, local_r) {
	local_q = int(which / bitarray_sizeofint);
	local_r = which % bitarray_sizeofint;

	bitarray_bits[local_q] = or(bitarray_bits[local_q], bitarray_masks[local_r]);
}

# function bitarray_clear clears a bit in the bit array.
# int which, specify which bit you want to clear
function bitarray_clear(which, local_q, local_r) {
	local_q = int(which / bitarray_sizeofint);
	local_r = which % bitarray_sizeofint;

	bitarray_bits[local_q] = and(bitarray_bits[local_q], bitarray_rmasks[local_r]);
}

# function bitarray_flip turns a bit into its opposite value.
# int which, specify which bit you want to flip
function bitarray_flip(which, local_q, local_r) {
	local_q = int(which / bitarray_sizeofint);
	local_r = which % bitarray_sizeofint;

	bitarray_bits[local_q] = xor(bitarray_bits[local_q], bitarray_masks[local_r]);
}

# function bitarray_test tests a bit in the bit array.
# int position, specify which bit you want to test
# return bool, if the bit at position is set, the function returns true.
#				otherwise, returns false.
function bitarray_test(position, local_q, local_r) {
	local_q = int(position / bitarray_sizeofint);
	local_r = position % bitarray_sizeofint;

	return and(bitarray_bits[local_q], bitarray_masks[local_r]);
}

# function bitarray_size returns the number of bits in the array.
# return int, number of bits
function bitarray_size() {
	return bitarray_count;
}

function bitarray_setcount(local_i, local_retval) {
	local_retval = 0;

	for (local_i = 0; local_i < bitarray_count; local_i++) {
		if (bitarray_test(local_i))
			local_retval++;
	}
	
	return local_retval;
}

function bitarray_clearcount() {
	return bitarray_count - bitarray_setcount();
}

# test
#BEGIN {
#	bitarray_init(13, 1);
#
#	for (i = 0; i < 13; i += 2) {
#		bitarray_clear(i);
#	}
#
#	printf "0x%x\n",bitarray_bits[0];
#
#	print bitarray_clearcount();
#}

