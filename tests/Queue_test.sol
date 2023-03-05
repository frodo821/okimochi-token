// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 
import "../contracts/Queue.sol";

contract QueueTest {
    using QueueLib for QueueLib.Queue;

    QueueLib.Queue test;

    function checkQueue() public {
        test.enque(1);
        Assert.equal(test.size, 1, "queue size should be 1");
        test.enque(3);
        Assert.equal(test.size, 2, "queue size should be 2");
        test.enque(4);
        Assert.equal(test.size, 3, "queue size should be 3");
        test.enque(2);
        Assert.equal(test.size, 4, "queue size should be 4");

        Assert.equal(test.deque(), 1, "1 should be dequed");
        Assert.equal(test.size, 3, "queue size should be 3");
        Assert.equal(test.deque(), 3, "1 should be dequed");
        Assert.equal(test.size, 2, "queue size should be 2");
        Assert.equal(test.deque(), 4, "1 should be dequed");
        Assert.equal(test.size, 1, "queue size should be 1");
        Assert.equal(test.deque(), 2, "1 should be dequed");
        Assert.equal(test.size, 0, "queue size should be 0");
    }
}
    