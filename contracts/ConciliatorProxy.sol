// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/OwnableUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./lib/Heap.sol";

struct Proposal {
    uint256 _startBlockHeight;
    uint256 _endBlockHeight;
    uint256 _value;
    uint256 _minimumVote;
    address _contract;
    address _from;
    string _name;
    string _description;
    bytes _calldata;
}

struct ProposalResult {
    bool executed;
    bool succeeded;
    uint256 proposalId;
}

contract ConciliatorProxy is OwnableUpgradeable, UUPSUpgradeable {
    using HeapLib for HeapLib.Heap;
    event NewProposal(address indexed _from, uint256 _proposalId);
    event ProposalSettled(uint256 indexed _proposalId, ProposalResult result);
    event ProposalAbandoned(uint256 indexed _proposalId);

    mapping(uint256 => Proposal) private _proposals;
    mapping(uint256 => mapping(bool => uint256)) private _votes;
    mapping(uint256 => mapping(address => bool)) private _hasVoted;
    mapping(uint256 => uint256[]) private _waitlist;
    HeapLib.Heap private _awaitingBlockHeights;
    address private _accessToken;
    uint256 private _nextProposalId;
    uint256 private _lastSettledAt;
    ProposalResult[] private _lastResult;

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function initialize() external initializer {
        __Ownable_init();
    }

    function accessControlToken() external view returns(address) {
        return _accessToken;
    }

    function isEligibleToVote(address _voter) public view returns(bool) {
        return IERC721(_accessToken).balanceOf(_voter) > 0;
    }

    modifier onlyVoter() {
        require(isEligibleToVote(msg.sender), "Not a voter.");
        _;
    }

    function setAccessTokenContract(address _newContract) external onlyOwner {
        _accessToken = _newContract;
    }

    function propose(
        string calldata _name,
        string calldata _description,
        address _contract,
        uint256 _value,
        bytes calldata _calldata,
        uint256 _startBlockHeight,
        uint256 _endBlockHeight,
        uint256 _minimumVote
    ) external onlyVoter {
        Proposal memory prop;
        prop._name = _name;
        prop._description = _description;
        prop._contract = _contract;
        prop._calldata = _calldata;
        prop._value = _value;
        prop._startBlockHeight = _startBlockHeight;
        prop._endBlockHeight = _endBlockHeight;
        prop._minimumVote = _minimumVote;
        prop._from = msg.sender;

        _proposals[_nextProposalId] = prop;
        _waitlist[_endBlockHeight].push(_nextProposalId);

        _awaitingBlockHeights.push(_endBlockHeight);

        emit NewProposal(msg.sender, _nextProposalId);

        _nextProposalId++;
    }

    function abandonProposal(uint256 _proposalId) external {
        Proposal storage prop = _proposals[_proposalId];
        require(msg.sender == prop._from || msg.sender == owner(), "Not a proposer");

        prop._endBlockHeight = 0;

        emit ProposalAbandoned(_proposalId);
    }

    function execute() external returns (ProposalResult[] memory) {
        _lastSettledAt = block.number;

        if (_awaitingBlockHeights.size == 0) {
            return new ProposalResult[](0);
        }

        while(_awaitingBlockHeights.size > 0 && _awaitingBlockHeights.data[0] <= block.number) {
            uint256 waited = _awaitingBlockHeights.pop();
            for (uint256 i = 0; i < _waitlist[waited].length; i++) {
                uint256 proposalId = _waitlist[waited][i];
                Proposal storage prop = _proposals[proposalId];

                if (prop._endBlockHeight == 0) {
                    continue;
                }

                ProposalResult memory result;
                result.proposalId = proposalId;

                uint256 upvote = _votes[proposalId][true];
                uint256 downvote = _votes[proposalId][false];

                if (upvote + downvote < prop._minimumVote || upvote <= downvote) {
                    result.executed = false;
                    result.succeeded = true;
                    _lastResult.push(result);
                    emit ProposalSettled(proposalId, result);
                    continue;
                }

                (bool ok, ) = prop._contract.call{value: prop._value}(prop._calldata);

                result.executed = true;
                result.succeeded = ok;
                _lastResult.push(result);
                emit ProposalSettled(proposalId, result);
            }
        }

        ProposalResult[] memory results = new ProposalResult[](_lastResult.length);

        for (uint256 i = 0; i < _lastResult.length; i++) {
            results[i] = _lastResult[i];
        }

        delete _lastResult;

        return results;
    }

    function proposalData(uint256 _proposalId) external view returns (Proposal memory prop) {
        prop = _proposals[_proposalId];
    }

    function hasVoted(uint256 _proposalId, address voter) public view returns (bool voted) {
        voted = _hasVoted[_proposalId][voter];
    }

    function isSettled(uint256 _proposalId) external view returns (bool settled) {
        settled = _proposals[_proposalId]._endBlockHeight <= _lastSettledAt;
    }

    function isAbandoned(uint256 _proposalId) external view returns (bool abandoned) {
        abandoned = _proposals[_proposalId]._endBlockHeight == 0;
    }

    function proposalsCount() external view returns (uint256 proposals) {
        proposals = _nextProposalId;
    }

    function lastSettledBlockHeight() external view returns (uint256 blockheight) {
        blockheight = _lastSettledAt;
    }

    function vote(uint256 _proposalId, bool upvote) external onlyVoter {
        require(_proposals[_proposalId]._endBlockHeight == 0, "Invalid proposal to be voted.");
        require(_proposals[_proposalId]._endBlockHeight > block.number, "This proposal is already expired to vote to.");
        require(_proposals[_proposalId]._startBlockHeight <= block.number, "This proposal is not yet accepted to vote to.");
        require(!hasVoted(_proposalId, msg.sender), "You're already voted to this proposal.");

        _votes[_proposalId][upvote] += 1;
        _hasVoted[_proposalId][msg.sender] = true;
    }
}
