// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TransientBuffer} from "./TransientBuffer.sol";

/// @author philogy <https://github.com/philogy>
abstract contract SSTORE3 {
    TransientBuffer private buffer;

    uint256 internal constant STORE_PUSH0_BYTECODE = 0x63a817a4955f525f5f6004601c335afa3d5f5f3e3d5ff3;
    bytes32 internal constant STORE_PUSH0_INITHASH = 0x54080da2e9f831629c76fde0969a0f951b00eda6294edacf01d88e05290514ab;
    uint256 internal constant STORE_OLD_BYTECODE = 0x63a817a495345234346004601c335afa3d34343e3d34f3;
    bytes32 internal constant STORE_OLD_INITHASH = 0x3e52686b22fac4e84e74622e5414b24f9508bb3ecc52f7afdb4b8564f6da4082;

    error FailedToInitializeStore();
    error DataRangeInvalid(uint256 start, uint256 end);

    function getStoreContents() external view {
        buffer.directReturn();
    }

    modifier withBuffer(bytes memory data) {
        buffer.write(data);
        _;
        buffer.reset(data.length);
    }

    function _bufferInitPrimary() internal {
        buffer.initPrimary();
    }

    function _bufferInitRange(uint256 start, uint256 end) internal {
        buffer.initRange(start, end);
    }

    function sstore3(uint256 pointer, bytes memory data) internal returns (address) {
        return _sstore3(pointer, data, STORE_PUSH0_BYTECODE);
    }

    function preShanghai_sstore3(uint256 pointer, bytes memory data) internal returns (address) {
        return _sstore3(pointer, data, STORE_OLD_BYTECODE);
    }

    function sload3(uint256 pointer) internal view returns (bytes memory data) {
        data = _sload3(pointer, STORE_PUSH0_INITHASH);
    }

    function sload3(uint256 pointer, uint256 start, uint256 end) internal view returns (bytes memory data) {
        data = _sload3(pointer, STORE_PUSH0_INITHASH, start, end);
    }

    function preShanghai_sload3(uint256 pointer) internal view returns (bytes memory data) {
        data = _sload3(pointer, STORE_OLD_INITHASH);
    }

    function preShanghai_sload3(uint256 pointer, uint256 start, uint256 end)
        internal
        view
        returns (bytes memory data)
    {
        data = _sload3(pointer, STORE_OLD_INITHASH, start, end);
    }

    function _sstore3(uint256 pointer, bytes memory data, uint256 bytecode)
        private
        withBuffer(data)
        returns (address store)
    {
        assembly {
            mstore(0x00, bytecode)
            store := create2(0, 9, 23, pointer)
            if iszero(store) {
                mstore(0x00, 0x8767addc)
                revert(0x1c, 0x04)
            }
        }
    }

    function _sload3(uint256 pointer, bytes32 initHash) private view returns (bytes memory data) {
        assembly {
            // Allocate memory.
            data := mload(0x40)

            // Compute store location.
            mstore(0x00, address())
            mstore8(0xb, 0xff)
            mstore(0x20, pointer)
            mstore(0x40, initHash)
            let store := keccak256(0xb, 0x55)

            // Get size.
            let size := extcodesize(store)

            // Restore free pointer.
            let dataOffset := add(data, 0x20)
            mstore(0x40, add(dataOffset, size))
            mstore(data, size)

            // Retrieve data.
            extcodecopy(store, dataOffset, 0, size)
        }
    }

    function _sload3(uint256 pointer, bytes32 initHash, uint256 start, uint256 end)
        private
        view
        returns (bytes memory data)
    {
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
            mstore(0x40, initHash)
            let store := keccak256(0xb, 0x55)

            // Get size.
            let size := sub(end, start)

            // Restore free pointer.
            let dataOffset := add(data, 0x20)
            mstore(0x40, add(dataOffset, size))
            mstore(data, size)

            // Retrieve data.
            extcodecopy(store, dataOffset, start, size)
        }
    }
}
