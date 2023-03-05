// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "../contracts/Heap.sol";

contract HeapTest {
    using HeapLib for HeapLib.Heap;

    HeapLib.Heap test;

    function checkHeap() public {
        test.push(5);
        Assert.equal(test.size, uint256(1), "heap size should be 1");
        test.push(1);
        Assert.equal(test.size, uint256(2), "heap size should be 2");
        test.push(2);
        Assert.equal(test.size, uint256(3), "heap size should be 3");
        test.push(4);
        Assert.equal(test.size, uint256(4), "heap size should be 4");
        test.push(3);
        Assert.equal(test.size, uint256(5), "heap size should be 5");

        Assert.equal(test.data[0], uint256(1), "Top element of the heap should be 1");

        Assert.equal(test.pop(), uint256(1), "Heap.pop() should return the top element");
        Assert.equal(test.size, uint256(4), "heap size should be 4");
        Assert.equal(test.pop(), uint256(2), "Heap.pop() should return the top element");
        Assert.equal(test.size, uint256(3), "heap size should be 3");
        Assert.equal(test.pop(), uint256(3), "Heap.pop() should return the top element");
        Assert.equal(test.size, uint256(2), "heap size should be 2");
        Assert.equal(test.pop(), uint256(4), "Heap.pop() should return the top element");
        Assert.equal(test.size, uint256(1), "heap size should be 1");
        Assert.equal(test.pop(), uint256(5), "Heap.pop() should return the top element");
        Assert.equal(test.size, uint256(0), "heap size should be 0");
    }
}