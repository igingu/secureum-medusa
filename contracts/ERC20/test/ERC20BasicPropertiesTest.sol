pragma solidity 0.8.19;

import "./ERC20BasicProperties.sol";

// Run with ./medusa fuzz --target contracts/ERC20/test/ERC20BasicPropertiesTest.sol --deployment-order ERC20BasicPropertiesTest

contract ERC20BasicPropertiesTest is ERC20BasicProperties {
    constructor() ERC20("TOKEN", "TKN", 18) {
        _mint(medusaCaller, TOTAL_SUPPLY);
    }
}