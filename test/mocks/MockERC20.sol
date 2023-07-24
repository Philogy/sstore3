// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "solady/tokens/ERC20.sol";

/// @author philogy <https://github.com/philogy>
contract MockERC20 is ERC20 {
    function name() public pure override returns (string memory) {
        return "Mock ERC20";
    }

    function symbol() public pure override returns (string memory) {
        return "MCK";
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) external {
        _burn(to, amount);
    }
}
