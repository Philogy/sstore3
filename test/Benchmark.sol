// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {SSTORE3_S} from "src/SSTORE3_S.sol";
import {SSTORE3_L} from "src/SSTORE3_L.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";

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

    function test_SSTORE3_S_001e() public {
        bytes memory d = randomBytes("001e", 30);
        sstore3(0, d);
    }

    function test_SSTORE2_001e() public {
        bytes memory d = randomBytes("001e", 30);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_001e() public {
        bytes memory d = randomBytes("001e", 30);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0020() public {
        bytes memory d = randomBytes("0020", 32);
        sstore3(0, d);
    }

    function test_SSTORE2_0020() public {
        bytes memory d = randomBytes("0020", 32);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0020() public {
        bytes memory d = randomBytes("0020", 32);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0040() public {
        bytes memory d = randomBytes("0040", 64);
        sstore3(0, d);
    }

    function test_SSTORE2_0040() public {
        bytes memory d = randomBytes("0040", 64);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0040() public {
        bytes memory d = randomBytes("0040", 64);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0060() public {
        bytes memory d = randomBytes("0060", 96);
        sstore3(0, d);
    }

    function test_SSTORE2_0060() public {
        bytes memory d = randomBytes("0060", 96);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0060() public {
        bytes memory d = randomBytes("0060", 96);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0080() public {
        bytes memory d = randomBytes("0080", 128);
        sstore3(0, d);
    }

    function test_SSTORE2_0080() public {
        bytes memory d = randomBytes("0080", 128);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0080() public {
        bytes memory d = randomBytes("0080", 128);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_00a0() public {
        bytes memory d = randomBytes("00a0", 160);
        sstore3(0, d);
    }

    function test_SSTORE2_00a0() public {
        bytes memory d = randomBytes("00a0", 160);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_00a0() public {
        bytes memory d = randomBytes("00a0", 160);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_00c0() public {
        bytes memory d = randomBytes("00c0", 192);
        sstore3(0, d);
    }

    function test_SSTORE2_00c0() public {
        bytes memory d = randomBytes("00c0", 192);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_00c0() public {
        bytes memory d = randomBytes("00c0", 192);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_00e0() public {
        bytes memory d = randomBytes("00e0", 224);
        sstore3(0, d);
    }

    function test_SSTORE2_00e0() public {
        bytes memory d = randomBytes("00e0", 224);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_00e0() public {
        bytes memory d = randomBytes("00e0", 224);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0100() public {
        bytes memory d = randomBytes("0100", 256);
        sstore3(0, d);
    }

    function test_SSTORE2_0100() public {
        bytes memory d = randomBytes("0100", 256);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0100() public {
        bytes memory d = randomBytes("0100", 256);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0120() public {
        bytes memory d = randomBytes("0120", 288);
        sstore3(0, d);
    }

    function test_SSTORE2_0120() public {
        bytes memory d = randomBytes("0120", 288);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0120() public {
        bytes memory d = randomBytes("0120", 288);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0140() public {
        bytes memory d = randomBytes("0140", 320);
        sstore3(0, d);
    }

    function test_SSTORE2_0140() public {
        bytes memory d = randomBytes("0140", 320);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0140() public {
        bytes memory d = randomBytes("0140", 320);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_01e0() public {
        bytes memory d = randomBytes("01e0", 480);
        sstore3(0, d);
    }

    function test_SSTORE2_01e0() public {
        bytes memory d = randomBytes("01e0", 480);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_01e0() public {
        bytes memory d = randomBytes("01e0", 480);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0320() public {
        bytes memory d = randomBytes("0320", 800);
        sstore3(0, d);
    }

    function test_SSTORE2_0320() public {
        bytes memory d = randomBytes("0320", 800);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0320() public {
        bytes memory d = randomBytes("0320", 800);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0640() public {
        bytes memory d = randomBytes("0640", 1600);
        sstore3(0, d);
    }

    function test_SSTORE2_0640() public {
        bytes memory d = randomBytes("0640", 1600);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0640() public {
        bytes memory d = randomBytes("0640", 1600);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_0c80() public {
        bytes memory d = randomBytes("0c80", 3200);
        sstore3(0, d);
    }

    function test_SSTORE2_0c80() public {
        bytes memory d = randomBytes("0c80", 3200);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_0c80() public {
        bytes memory d = randomBytes("0c80", 3200);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_1f40() public {
        bytes memory d = randomBytes("1f40", 8000);
        sstore3(0, d);
    }

    function test_SSTORE2_1f40() public {
        bytes memory d = randomBytes("1f40", 8000);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_1f40() public {
        bytes memory d = randomBytes("1f40", 8000);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_3e80() public {
        bytes memory d = randomBytes("3e80", 16000);
        sstore3(0, d);
    }

    function test_SSTORE2_3e80() public {
        bytes memory d = randomBytes("3e80", 16000);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_3e80() public {
        bytes memory d = randomBytes("3e80", 16000);
        SSTORE3_L.store(0, d);
    }

    function test_SSTORE3_S_5fff() public {
        bytes memory d = randomBytes("5fff", 24575);
        sstore3(0, d);
    }

    function test_SSTORE2_5fff() public {
        bytes memory d = randomBytes("5fff", 24575);
        SSTORE2.write(d);
    }

    function test_SSTORE3_L_5fff() public {
        bytes memory d = randomBytes("5fff", 24575);
        SSTORE3_L.store(0, d);
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
