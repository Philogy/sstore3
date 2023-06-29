// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

using TransientBufferLib for TransientBuffer global;

struct TransientBuffer {
    uint256 ___placeholder;
}

/// @author philogy <https://github.com/philogy>
/// TODO: Replace `SSTORE` with `TSTORE` once EIP-1153 is live and remove `reset`.
library TransientBufferLib {
    uint256 internal constant MAX_DATA_SIZE = 24576;

    error DataTooLarge();

    function write(TransientBuffer storage self, bytes memory data) internal {
        assembly {
            let dataLen := mload(data)
            if gt(dataLen, MAX_DATA_SIZE) {
                mstore(0x00, 0x54ef47ee)
                revert(0x1c, 0x04)
            }

            // Stores first 30 bytes packed with the 2-byte data length (data[:20] ++ len).
            sstore(self.slot, or(dataLen, shl(16, mload(add(data, 0x1e)))))

            // Compute first data slot, solidity-style. (`keccak256(var.slot)`)
            mstore(0x00, self.slot)
            let dataSlot := keccak256(0x00, 0x20)

            // Copy data from memory => storage.
            for {
                let offset := add(data, 0x3e)
                let endOffset := add(add(data, 0x20), dataLen)
            } lt(offset, endOffset) {
                offset := add(offset, 0x20)
                dataSlot := add(dataSlot, 1)
            } { sstore(dataSlot, mload(offset)) }
        }
    }

    function directReturn(TransientBuffer storage self) internal view {
        assembly {
            // Compute first data slot, solidity-style. (`keccak256(var.slot)`)
            mstore(0x00, self.slot)
            let dataSlot := keccak256(0x00, 0x20)

            // Get length + up to first 30 bytes, prepare in memory.
            let primaryData := sload(self.slot)
            mstore(0x00, primaryData)
            // Length stored in last 2 bytes.
            let dataLen := and(primaryData, 0xffff)

            // Don't have to worry about memory safety because will by `RETURN`ing directly.
            // Copy buffer data from storage => memory.
            for { let offset := 0x1e } lt(offset, dataLen) {
                offset := add(offset, 0x20)
                dataSlot := add(dataSlot, 1)
            } { mstore(offset, sload(dataSlot)) }

            return(0, dataLen)
        }
    }

    function reset(TransientBuffer storage self, uint256 size) internal {
        assembly {
            sstore(self.slot, 0)

            // Compute first data slot, solidity-style. (`keccak256(var.slot)`)
            mstore(0x00, self.slot)
            let dataSlot := keccak256(0x00, 0x20)

            for { let lastDataSlot := add(dataSlot, shr(5, add(size, 1))) } lt(dataSlot, lastDataSlot) {
                dataSlot := add(dataSlot, 1)
            } { sstore(dataSlot, 0) }
        }
    }
}
