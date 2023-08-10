pragma solidity 0.8.19;
import "../ERC20.sol";
import "../../helper.sol";


// Run with ./medusa fuzz --target contracts/ERC20/test/ERC20BasicPropertiesTest.sol --deployment-order ERC20BasicPropertiesTest

abstract contract ERC20TestBase is ERC20, PropertiesAsserts {
    bool isBurnable;

    constructor() {}
}

