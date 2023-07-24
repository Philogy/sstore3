// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {SSTORE3_S} from "src/SSTORE3_S.sol";
import {SSTORE3_L} from "src/SSTORE3_L.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {console2 as console} from "forge-std/console2.sol";

/// @author philogy <https://github.com/philogy>
contract Benchmark is Test, SSTORE3_S {
    address internal immutable examplePointer2 = SSTORE2.write(randomBytes("example", 1024));

    uint256 internal constant EXAMPLE_PTR = 1;

    function setUp() public {
        _bufferInitPrimary();
        _bufferInitRange(0, 768);

        bytes memory exampleData = randomBytes("example", 1024);
        sstore3(EXAMPLE_PTR, exampleData);
        SSTORE3_L.store(EXAMPLE_PTR, exampleData);
    }

    function test_SSTORE3_S() public {
        // Warm all storage slots, cost of warming will be added back in later.
        sstore3(0, randomBytes("warming data", 24575));
        assembly {
            mstore(0x40, 0x80)
        }
        uint256 pointer = 2;
        for (uint256 size = 1; size < 100;) {
            bytes memory d = randomBytes("sstore_bench", size);
            uint256 before = gasleft();
            sstore3(pointer, d);
            unchecked {
                uint256 delta = before - gasleft();
                console.log("%s: %s,", size, delta);
                assembly {
                    mstore(0x40, 0x80)
                }
                pointer++;
                size++;
            }
        }
    }

    function test_SSTORE2() public {
        for (uint256 size = 1; size < 24576;) {
            bytes memory d = randomBytes("sstore_bench", size);
            uint256 before = gasleft();
            SSTORE2.write(d);
            unchecked {
                uint256 delta = before - gasleft();
                console.log("%s: %s,", size, delta);
                assembly {
                    mstore(0x40, 0x80)
                }
                size++;
            }
        }
    }

    function test_SSTORE3_L() public {
        uint256 pointer = 2;
        for (uint256 size = 1; size < 24576;) {
            bytes memory d = randomBytes("sstore_bench", size);
            uint256 before = gasleft();
            SSTORE3_L.store(pointer, d);
            unchecked {
                uint256 delta = before - gasleft();
                console.log("%s: %s,", size, delta);
                assembly {
                    mstore(0x40, 0x80)
                }
                pointer++;
                size++;
            }
        }
    }

    function test_read_SSTORE2() public view {
        SSTORE2.read(examplePointer2);
    }

    function test_read_SSTORE3_L() public view {
        SSTORE3_L.load(EXAMPLE_PTR);
    }

    function test_read_SSTORE3_S() public view {
        sload3(EXAMPLE_PTR);
    }

    function randomBytes(string memory seed, uint256 length) internal returns (bytes memory d) {
        vm.pauseGasMetering();
        bytes32 prngCore = keccak256(bytes(seed));
        assembly {
            d := mload(0x40)
            mstore(d, length)
            let offset := add(d, 0x20)
            let endOffset := add(offset, length)
            for {} lt(offset, endOffset) { offset := add(offset, 0x20) } {
                mstore(offset, prngCore)
                prngCore := keccak256(offset, 0x20)
            }
            mstore(0x40, endOffset)
        }
        vm.resumeGasMetering();
    }
}
