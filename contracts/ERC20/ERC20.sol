// SPDX-License-Identifier: AGPL-3.0-only

// SECUREUM
// The following file contains ERC20/WETH/SafeTransferLib from solmate
// permit-like functions were removed (EIP-2612)

pragma solidity 0.8.19;

/// @notice Modern and gas efficient ERC20 
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @author [Secureum] EIP-2612 implementation was removed
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;


    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        // fuzz_approveCorrectlyChangesAllowancesAndNothingElse
        // allowance[msg.sender][spender] += 1;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        // fuzz_totalSupplyShouldBeConstantForNonMintableNonBurnable
        // _mint(address(0), 1);

        // fuzz_eachBalanceShouldBeAtMostTotalSupply
        // balanceOf[msg.sender] = 2 * totalSupply;

        // fuzz_zeroAddressShouldHaveZeroTokens
        // balanceOf[address(0)] = 1;

        // fuzz_selfTransferShouldNotBreakAccounting
        // if (msg.sender == to) balanceOf[msg.sender] += 1;

        // fuzz_transferForMoreThanBalanceShouldNotBeAllowed
        // Put the below into `unchecked` block like so unchecked { balanceOf[msg.sender] -= amount; }
        balanceOf[msg.sender] -= amount;

        // fuzz_transfer0AmountShouldNotBreakAccounting
        // if (amount == 0) balanceOf[msg.sender] += 1;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            // fuzz_transferToOthersShouldWorkCorrectly
            // balanceOf[to] += 1;
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        // fuzz_selfTransferFromShouldNotBreakAccounting
        // if (from == to) balanceOf[from] += 1; 

        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        // fuzz_transferFromForMoreThanAllowanceShouldNotBeAllowed
        // Put the below into `unchecked` block like so 
        // if (allowed != type(uint256).max) {
        //     unchecked { allowance[from][msg.sender] = allowed - amount;}
        // }

        // fuzz_allowanceDoesntChangeIfMax
        // Remove the if statement below, and leave just `allowance[from][msg.sender] = allowed - amount;`
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        // fuzz_transferFromForMoreThanBalanceShouldNotBeAllowed
        // Put the below into `unchecked` block like so unchecked { balanceOf[from] -= amount; }
        balanceOf[from] -= amount;

        // fuzz_transferFrom0AmountShouldNotBreakAccounting
        // if (amount == 0) balanceOf[to] += 1;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            // fuzz_transferFromToOthersShouldWorkCorrectly
            // balanceOf[to] += 1;
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }



    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

