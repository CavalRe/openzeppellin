// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC1363Receiver} from "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import {Initializable} from "../../proxy/utils/Initializable.sol";

contract ERC1363ReceiverMockUpgradeable is Initializable, IERC1363Receiver {
    enum RevertType {
        None,
        RevertWithoutMessage,
        RevertWithMessage,
        RevertWithCustomError,
        Panic
    }

    bytes4 private _retval;
    RevertType private _error;

    event Received(address operator, address from, uint256 value, bytes data);
    error CustomError(bytes4);

    function __ERC1363ReceiverMock_init() internal onlyInitializing {
        __ERC1363ReceiverMock_init_unchained();
    }

    function __ERC1363ReceiverMock_init_unchained() internal onlyInitializing {
        _retval = IERC1363Receiver.onTransferReceived.selector;
        _error = RevertType.None;
    }

    function setUp(bytes4 retval, RevertType error) public {
        _retval = retval;
        _error = error;
    }

    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        if (_error == RevertType.RevertWithoutMessage) {
            revert();
        } else if (_error == RevertType.RevertWithMessage) {
            revert("ERC1363ReceiverMock: reverting");
        } else if (_error == RevertType.RevertWithCustomError) {
            revert CustomError(_retval);
        } else if (_error == RevertType.Panic) {
            uint256 a = uint256(0) / uint256(0);
            a;
        }

        emit Received(operator, from, value, data);
        return _retval;
    }
}