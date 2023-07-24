// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TransientBuffer} from "./TransientBuffer.sol";

/// @author philogy <https://github.com/philogy>
abstract contract SSTORE3_S {
    TransientBuffer private buffer;

    uint256 internal constant MAX_DATA_SIZE = 24575;

    /**
     * -------------------------------------------------------------------------------------+
     *                                                                                      |
     * CREATION (32 bytes)                                                                  |
     *                                                                                      |
     * -----+-------------+---------------------------+--------------+----------------------+
     * PC   | Opcode      | Mnemonic                  | Stack        | Memory               |
     * -----+-------------+---------------------------+--------------+----------------------+
     *                                                                                      |
     * ::::::::::: Put `__getStore()` selector in memory. ::::::::::::::::::::::::::::::::: |
     * 0x00 | 63 a817a495 | PUSH4 sel("__getStore()") | s            | -                    |
     * 0x05 | 34          | CALLVALUE                 | 0 s          | [28..32): selector   |
     * 0x06 | 52          | MSTORE                    |              | [28..32): selector   |
     *                                                                                      |
     * ::::::::::: Retrieve store data by calling `__getStore()`. ::::::::::::::::::::::::: |
     * 0x07 | 34          | CALLVALUE                 | 0            | [28..32): selector   |
     * 0x08 | 34          | CALLVALUE                 | 0 0          | [28..32): selector   |
     * 0x09 | 60 04       | PUSH1 0x04                | 4 0 0        | [28..32): selector   |
     * 0x0b | 60 1c       | PUSH1 0x1c                | 28 4 0 0     | [28..32): selector   |
     * 0x0d | 33          | CALLER                    | c 28 4 0 0   | [28..32): selector   |
     * 0x0e | 5a          | GAS                       | g c 28 4 0 0 | [28..32): selector   |
     * 0x0f | fa          | STATICCALL                | suc          | [28..32): selector   |
     * 0x10 | 80          | DUP1                      | suc suc      | [28..32): selector   |
     *                                                                                      |
     * ::::::::::: Verify call success. ::::::::::::::::::::::::::::::::::::::::::::::::::: |
     * 0x10 | 61 0017     | PUSH2 0x0017              | dest suc suc | [28..32): selector   |
     * 0x13 | 57          | JUMPI                     | 0            | [28..32): selector   |
     * 0x14 | 34          | CALLVALUE                 | 0 0          | [28..32): selector   |
     * 0x16 | fd          | REVERT                    |              | [28..32): selector   |
     *                                                                                      |
     * ::::::::::: Copy data into memory, offset by 1 for padding. :::::::::::::::::::::::: |
     * 0x17 | 5b          | JUMPDEST                  | 1            | [28..32): selector   |
     * 0x18 | 3d          | RETURNDATASIZE            | rds 1        | [28..32): selector   |
     * 0x19 | 34          | CALLVALUE                 | 0 rds        | [28..32): selector   |
     * 0x1a | 82          | DUP3                      | 1 0 rds 1    | [28..32): selector   |
     * 0x1b | 3e          | RETURNDATACOPY            | 1            | [1..rds): store data |
     *                                                                                      |
     * ::::::::::: Return data + a leading 00 padding byte. ::::::::::::::::::::::::::::::: |
     * 0x1c | 3d          | RETURNDATASIZE            | rds 1        | [1..rds): store data |
     * 0x1d | 01          | ADD                       | size         | [1..rds): store data |
     * 0x1e | 34          | CALLVALUE                 | 0 size       | [1..rds): store data |
     * 0x1f | f3          | RETURN                    |              | [1..rds): store data |
     * -----+-------------+---------------------------+--------------+----------------------+
     *
     * @dev Generated from `./StoreInitializer.huff`. Uses `CALLVALUE` as backwards compatible
     * PUSH0 (`CREATE2` is always done without any ETH).
     */
    uint256 internal constant STORE_BYTECODE = 0x6362436ce9345234346004601c335afa806100175734fd5b3d34823e3d0134f3;
    uint256 internal constant STORE_INITHASH = 0x815ddba28e20f113623bbd204d952f2b655d38fc4e9f29af2499e3ded26f472d;

    error DataRangeInvalid(uint256 start, uint256 end);
    error FailedToInitializeStore();
    error DataTooLarge();
    error InvalidPointer();

    function __getStore() external view {
        buffer.directReturn();
    }

    function _bufferInitPrimary() internal {
        buffer.initPrimary();
    }

    function _bufferInitRange(uint256 start, uint256 end) internal {
        buffer.initRange(start, end);
    }

    function sstore3(uint256 pointer, bytes memory data) internal returns (address store) {
        uint256 length = data.length;
        if (length > MAX_DATA_SIZE) revert DataTooLarge();
        buffer.write(data);

        assembly {
            mstore(0x00, STORE_BYTECODE)
            store := create2(0, 0, 32, pointer)
            if iszero(store) {
                // `revert FailedToInitializeStore()`.
                mstore(0x00, 0x8767addc)
                revert(0x1c, 0x04)
            }
        }
        buffer.reset(length);
    }

    function sload3(uint256 pointer) internal view returns (bytes memory data) {
        assembly {
            // Allocate memory.
            data := mload(0x40)

            // Compute store location.
            mstore(0x00, address())
            mstore8(0xb, 0xff)
            mstore(0x20, pointer)
            mstore(0x40, STORE_INITHASH)
            let store := keccak256(0xb, 0x55)

            // Get size.
            let ptrCodesize := extcodesize(store)

            if iszero(ptrCodesize) {
                // `revert InvalidPointer()`
                mstore(0x00, 0x11052bb4)
                revert(0x1c, 0x04)
            }

            let size := sub(ptrCodesize, 1)

            // Restore free pointer.
            let dataOffset := add(data, 0x20)
            mstore(0x40, add(dataOffset, size))
            mstore(data, size)

            // Retrieve data.
            extcodecopy(store, dataOffset, 1, size)
        }
    }

    function sload3(uint256 pointer, uint256 start, uint256 end) internal view returns (bytes memory data) {
        assembly {
            // Validate range.
            if gt(start, end) {
                // Revert `DataRangeInvalid`.
                mstore(0x00, 0x1998fa2b)
                mstore(0x20, start)
                mstore(0x40, end)
            }

            // Allocate memory.
            data := mload(0x40)

            // Compute store location.
            mstore(0x00, address())
            mstore8(0xb, 0xff)
            mstore(0x20, pointer)
            mstore(0x40, STORE_INITHASH)
            let store := keccak256(0xb, 0x55)

            // Get size.
            let size := sub(end, start)

            // Restore free pointer.
            let dataOffset := add(data, 0x20)
            mstore(0x40, add(dataOffset, size))
            mstore(data, size)

            // Retrieve data.
            extcodecopy(store, dataOffset, add(start, 1), size)
        }
    }
}
