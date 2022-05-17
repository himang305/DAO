// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./GovernanceToken.sol";
import "./CloneFactory.sol";

contract TokenClone is CloneFactory {

  address[] public clones;
  address public baseAddress;

  event CloneCreated(address newClone);

  constructor(address _baseAddress) {
    baseAddress = _baseAddress;
  }

  function setBaseAddress(address _baseAddress) public {
    baseAddress = _baseAddress;
  }

  function createContract(address tresuryAddress, string calldata name, string calldata symbol,
                        uint fee, uint minDep, uint maxDep, bool _feeUSDC) public {
    address clone = createClone(baseAddress);
    GovernanceToken(clone).initialize( tresuryAddress, msg.sender , name, symbol, fee, minDep, maxDep, _feeUSDC);
    clones.push(clone);
    emit CloneCreated(clone);
    }

    function getCloness() external view returns (address[] memory) {
        return clones;
    }
  
}
