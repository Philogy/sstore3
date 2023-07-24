// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CREATE3} from "solady/utils/CREATE3.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

/// @author philogy <https://github.com/philogy>
/// @author Modified from Solady (https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol)
library SSTORE3_L {
    error DataTooLarge();

    error FailedToInitializeStore();

    /// @dev `bytes4(keccak256(bytes("DataTooLarge()")))`.
    uint256 internal constant _DATA_TOO_LARGE_ERROR_SELECTOR = 0x54ef47ee;

    /// @dev `bytes4(keccak256(bytes("FailedToInitializeStore()")))`.
    uint256 internal constant _FAILED_TO_INITIALIZE_ERROR_SELECTOR = 0x8767addc;

    uint256 internal constant _STORE_DEPLOY_HEAD_LENGTH = 11;
    /**
     * ------------------------------------------------------------------------+
     *                                                                         |
     * STORE DEPLOY START (11 bytes)                                           |
     *                                                                         |
     * ----+------------+------------------+--------------+--------------------+
     * PC  | Opcode     | Mnemonic         | Stack        | Memory             |
     * ----+------------+------------------+--------------+--------------------+
     *                                                                         |
     * ::::::::::: Deploy code (10 bytes). ::::::::::::::::::::::::::::::::::: |
     * 0x0 | 61 ????    | PUSH2 length     | len          | -                  |
     * 0x3 | 80         | DUP1             | len len      | -                  |
     * 0x4 | 60 0a      | PUSH1 0x0a       | 10 len len   | -                  |
     * 0x6 | 3d         | RETURNDATASIZE   | 0 10 len len | [0..len): runtime  |
     * 0x7 | 39         | CODECOPY         | len          | [24..32): runtime  |
     * 0x8 | 3d         | RETURNDATASIZE   | 0 len        | [24..32): runtime  |
     * 0x9 | f3         | RETURN           |              | [24..32): runtime  |
     *                                                                         |
     * ::::::::::: Padding (1 byte). ::::::::::::::::::::::::::::::::::::::::: |
     * 0x0 | 00         | STOP             |              | [24..32): runtime  |
     * ----+------------+------------------+--------------+--------------------+
     */
    uint256 internal constant _STORE_DEPLOY_CODE_START = 0x61000080600a3d393df300;
    uint256 internal constant _STORE_DEPLOY_CODE_LENGTH_BIT_OFFSET = 64;

    uint256 internal constant _MAX_STORE_SIZE = 24575;

    /**
     * ---------------------------------------------------------------------------------+
     *                                                                                  |
     * PROXY DEPLOY CODE (16 bytes)                                                     |
     *                                                                                  |
     * ----+---------------------+------------------+--------------+--------------------+
     * PC  | Opcode              | Mnemonic         | Stack        | Memory             |
     * ----+---------------------+------------------+--------------+--------------------+
     *                                                                                  |
     * ::::::::::: Full proxy deploy code. :::::::::::::::::::::::::::::::::::::::::::: |
     * 0x0 | 67 363d3d37363d34f0 | PUSH8 runtime    | runtime      | -                  |
     * 0x9 | 3d                  | RETURNDATASIZE   | 0 runtime    | -                  |
     * 0xa | 52                  | MSTORE           |              | [24..32): runtime  |
     * 0xb | 60 08               | PUSH1 0x08       | 8            | [24..32): runtime  |
     * 0xd | 60 18               | PUSH1 0x18       | 24 8         | [24..32): runtime  |
     * 0xf | f3                  | RETURN           |              | [24..32): runtime  |
     * ----+---------------------+------------------+--------------+--------------------+
     *                                                                                  |
     * ::::::::::: Proxy runtime code. :::::::::::::::::::::::::::::::::::::::::::::::: |
     * 0x0 | 36                  | CALLDATASIZE     | cds          |                    |
     * 0x1 | 3d                  | RETURNDATASIZE   | 0 cds        |                    |
     * 0x2 | 3d                  | RETURNDATASIZE   | 0 0 cds      |                    |
     * 0x3 | 37                  | CALLDATACOPY     |              | [0..cds): calldata |
     * 0x4 | 36                  | CALLDATASIZE     | cds          | [0..cds): calldata |
     * 0x5 | 3d                  | RETURNDATASIZE   | 0 cds        | [0..cds): calldata |
     * 0x6 | 34                  | CALLVALUE        | value 0 cds  | [0..cds): calldata |
     * 0x7 | f0                  | CREATE           | newContract  | [0..cds): calldata |
     * ----+---------------------+------------------+--------------+--------------------|
     * @dev The proxy bytecode.
     */
    uint256 private constant _PROXY_BYTECODE = 0x67363d3d37363d34f03d5260086018f3;

    /// @dev Hash of the `_PROXY_BYTECODE`.
    /// Equivalent to `keccak256(abi.encodePacked(hex"67363d3d37363d34f03d5260086018f3"))`.
    bytes32 private constant _PROXY_BYTECODE_HASH = 0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    function store(uint256 pointer, bytes memory data) internal returns (address newStore) {
        /// @solidity memory-safe-assembly
        assembly {
            // --- 1. Deploy CREATE3 Proxy. ---

            // Store the `_PROXY_BYTECODE` into scratch space.
            mstore(0x00, _PROXY_BYTECODE)
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            let proxy := create2(0, 0x10, 0x10, pointer)

            // --- 2. Check Store Data Length ---
            let length := mload(data)
            // Check data length.
            if gt(length, _MAX_STORE_SIZE) {
                mstore(0x00, _DATA_TOO_LARGE_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }

            // --- 3. Create Store Via Proxy ---

            // Insert length into store deploy code (+1 to inlude the `00` padding byte).
            let storeDeployCode :=
                or(_STORE_DEPLOY_CODE_START, shl(_STORE_DEPLOY_CODE_LENGTH_BIT_OFFSET, add(length, 1)))
            // Concatenate store deploy code to store data by temporarily overwriting length.
            mstore(data, storeDeployCode)

            pop(
                call(
                    gas(),
                    proxy,
                    0,
                    sub(add(data, 0x20), _STORE_DEPLOY_HEAD_LENGTH),
                    add(length, _STORE_DEPLOY_HEAD_LENGTH),
                    0,
                    0
                )
            )

            // --- 4. Restore `bytes data` Original Length ---
            mstore(data, length)

            // --- 5. Derive Store Address ---

            // Store the proxy's address.
            mstore(0x14, proxy)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            // Nonce of the proxy contract (1).
            mstore8(0x34, 0x01)

            newStore := keccak256(0x1e, 0x17)

            if iszero(extcodesize(newStore)) {
                mstore(0x00, _FAILED_TO_INITIALIZE_ERROR_SELECTOR)
                revert(0x1c, 0x04)
            }
        }
    }

    function load(uint256 pointer) internal view returns (bytes memory) {
        address storeAddr = CREATE3.getDeployed(bytes32(pointer));
        return SSTORE2.read(storeAddr);
    }
}
