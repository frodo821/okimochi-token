// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

library QueueLib {
    struct Queue {
        uint256[] data;
        uint256 front;
        uint256 back;
        uint256 size;
    }

    function enque(Queue storage queue, uint256 data) public {
        require(queue.size < type(uint256).max - 1, "queue is full");

        queue.data[queue.back] = data;
        queue.size++;
        unchecked {
            queue.back++;
        }
    }

    function deque(Queue storage queue) public returns (uint256) {
        require(queue.size > 0, "queue is empty");

        queue.size--;
        unchecked {
            queue.front++;
            return queue.data[queue.front-1];
        }
    }

    function frontValue(Queue storage queue) public view returns (uint256) {
        if (queue.size == 0) {
            return 0;
        }
        return queue.data[queue.front];
    }

    function backValue(Queue storage queue) public view returns (uint256) {
        if (queue.size == 0) {
            return 0;
        }
        return queue.data[queue.back];
    }
}
