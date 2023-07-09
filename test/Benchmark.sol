// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {SSTORE3} from "src/SSTORE3.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {SSTORE2_5} from "./mocks/SSTORE2_5.sol";

/// @author philogy <https://github.com/philogy>
contract Benchmark is Test, SSTORE3 {
    function setUp() public {
        _bufferInitPrimary();
        _bufferInitRange(0, 768);
    }

    function test_SSTORE3_001e() public {
        bytes memory d = randomBytes("001e", 30);
        sstore3(0, d);
    }

    function test_SSTORE2_001e() public {
        bytes memory d = randomBytes("001e", 30);
        SSTORE2.write(d);
    }

    function test_SSTORE25_001e() public {
        bytes memory d = randomBytes("001e", 30);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0020() public {
        bytes memory d = randomBytes("0020", 32);
        sstore3(0, d);
    }

    function test_SSTORE2_0020() public {
        bytes memory d = randomBytes("0020", 32);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0020() public {
        bytes memory d = randomBytes("0020", 32);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0040() public {
        bytes memory d = randomBytes("0040", 64);
        sstore3(0, d);
    }

    function test_SSTORE2_0040() public {
        bytes memory d = randomBytes("0040", 64);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0040() public {
        bytes memory d = randomBytes("0040", 64);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0060() public {
        bytes memory d = randomBytes("0060", 96);
        sstore3(0, d);
    }

    function test_SSTORE2_0060() public {
        bytes memory d = randomBytes("0060", 96);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0060() public {
        bytes memory d = randomBytes("0060", 96);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0080() public {
        bytes memory d = randomBytes("0080", 128);
        sstore3(0, d);
    }

    function test_SSTORE2_0080() public {
        bytes memory d = randomBytes("0080", 128);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0080() public {
        bytes memory d = randomBytes("0080", 128);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_00a0() public {
        bytes memory d = randomBytes("00a0", 160);
        sstore3(0, d);
    }

    function test_SSTORE2_00a0() public {
        bytes memory d = randomBytes("00a0", 160);
        SSTORE2.write(d);
    }

    function test_SSTORE25_00a0() public {
        bytes memory d = randomBytes("00a0", 160);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_00c0() public {
        bytes memory d = randomBytes("00c0", 192);
        sstore3(0, d);
    }

    function test_SSTORE2_00c0() public {
        bytes memory d = randomBytes("00c0", 192);
        SSTORE2.write(d);
    }

    function test_SSTORE25_00c0() public {
        bytes memory d = randomBytes("00c0", 192);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_00e0() public {
        bytes memory d = randomBytes("00e0", 224);
        sstore3(0, d);
    }

    function test_SSTORE2_00e0() public {
        bytes memory d = randomBytes("00e0", 224);
        SSTORE2.write(d);
    }

    function test_SSTORE25_00e0() public {
        bytes memory d = randomBytes("00e0", 224);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0100() public {
        bytes memory d = randomBytes("0100", 256);
        sstore3(0, d);
    }

    function test_SSTORE2_0100() public {
        bytes memory d = randomBytes("0100", 256);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0100() public {
        bytes memory d = randomBytes("0100", 256);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0120() public {
        bytes memory d = randomBytes("0120", 288);
        sstore3(0, d);
    }

    function test_SSTORE2_0120() public {
        bytes memory d = randomBytes("0120", 288);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0120() public {
        bytes memory d = randomBytes("0120", 288);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0140() public {
        bytes memory d = randomBytes("0140", 320);
        sstore3(0, d);
    }

    function test_SSTORE2_0140() public {
        bytes memory d = randomBytes("0140", 320);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0140() public {
        bytes memory d = randomBytes("0140", 320);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_01e0() public {
        bytes memory d = randomBytes("01e0", 480);
        sstore3(0, d);
    }

    function test_SSTORE2_01e0() public {
        bytes memory d = randomBytes("01e0", 480);
        SSTORE2.write(d);
    }

    function test_SSTORE25_01e0() public {
        bytes memory d = randomBytes("01e0", 480);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0320() public {
        bytes memory d = randomBytes("0320", 800);
        sstore3(0, d);
    }

    function test_SSTORE2_0320() public {
        bytes memory d = randomBytes("0320", 800);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0320() public {
        bytes memory d = randomBytes("0320", 800);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0640() public {
        bytes memory d = randomBytes("0640", 1600);
        sstore3(0, d);
    }

    function test_SSTORE2_0640() public {
        bytes memory d = randomBytes("0640", 1600);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0640() public {
        bytes memory d = randomBytes("0640", 1600);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_0c80() public {
        bytes memory d = randomBytes("0c80", 3200);
        sstore3(0, d);
    }

    function test_SSTORE2_0c80() public {
        bytes memory d = randomBytes("0c80", 3200);
        SSTORE2.write(d);
    }

    function test_SSTORE25_0c80() public {
        bytes memory d = randomBytes("0c80", 3200);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_1f40() public {
        bytes memory d = randomBytes("1f40", 8000);
        sstore3(0, d);
    }

    function test_SSTORE2_1f40() public {
        bytes memory d = randomBytes("1f40", 8000);
        SSTORE2.write(d);
    }

    function test_SSTORE25_1f40() public {
        bytes memory d = randomBytes("1f40", 8000);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_3e80() public {
        bytes memory d = randomBytes("3e80", 16000);
        sstore3(0, d);
    }

    function test_SSTORE2_3e80() public {
        bytes memory d = randomBytes("3e80", 16000);
        SSTORE2.write(d);
    }

    function test_SSTORE25_3e80() public {
        bytes memory d = randomBytes("3e80", 16000);
        SSTORE2_5.write(0, d);
    }

    function test_SSTORE3_5fff() public {
        bytes memory d = randomBytes("5fff", 24575);
        sstore3(0, d);
    }

    function test_SSTORE2_5fff() public {
        bytes memory d = randomBytes("5fff", 24575);
        SSTORE2.write(d);
    }

    function test_SSTORE25_5fff() public {
        bytes memory d = randomBytes("5fff", 24575);
        SSTORE2_5.write(0, d);
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
