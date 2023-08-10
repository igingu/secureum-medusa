pragma solidity 0.8.19;

import "./ERC20TestBase.sol";

abstract contract ERC20BasicProperties is ERC20TestBase {
    uint256 internal constant TOTAL_SUPPLY = 10 ** 18;

    address internal immutable medusaCaller;

    constructor () {
        medusaCaller = msg.sender;
    }

    function fuzz_totalSupplyShouldBeConstantForNonMintableNonBurnable() public view returns (bool){
        require(!isBurnable, "Token is burnable.");
        return totalSupply == TOTAL_SUPPLY;
    }

    function fuzz_eachBalanceShouldBeAtMostTotalSupply(address tokenHolder) public {
        assertLte(balanceOf[tokenHolder], totalSupply, "Balance of tokenHolder is bigger than total supply.");
    }

    // TODO: the sum of all balances should be equal to total supply

    // Not applicable for Solmate's ERC20
    // function fuzz_zeroAddressShouldHaveZeroTokens() public view returns (bool) {
    //     return balanceOf[address(0)] == 0;
    // }

    // Not applicable for Solmate's ERC20
    // function fuzz_cantTransferToZeroAddress() public {
    //     uint256 balance = balanceOf[address(this)];
    //     require(balance > 0);
    
    //     bool r = transfer(address(0), balance);
    //     assertWithMsg(r == false, "Successful transfer to address zero");
    // }

    // Not applicable for Solmate's ERC20
    // function fuzz_cantTransferFromToZeroAddress() public {
    //     uint256 balanceOfMsgSender = balanceOf[msg.sender];
    //     uint256 allowanceFromMsgSender = allowance[msg.sender][address(this)];
    //     uint256 maxTransfer = balanceOfMsgSender > allowanceFromMsgSender ? allowanceFromMsgSender : balanceOfMsgSender;
    //     require(maxTransfer > 0, "Can't transfer 0 amount.");

    //     bool r = transferFrom(msg.sender, address(0), maxTransfer);
    //     assertWithMsg(r == false, "Successful transferFrom to address zero");
    // }

    function fuzz_selfTransferShouldNotBreakAccounting(uint256 amount) public {
        uint256 balanceOfAddressThis = balanceOf[address(this)];
        require(balanceOfAddressThis > 0, "Can't transfer 0 amount.");

        bool r = this.transfer(address(this), amount % (balanceOfAddressThis + 1));
        assertWithMsg(r == true, "Failed self transfer.");
        assertEq(balanceOf[address(this)], balanceOfAddressThis, "Self transfer breaks accounting.");
    }

    function fuzz_selfTransferFromShouldNotBreakAccounting(uint256 amount) public {
        uint256 balanceOfAddressThis = balanceOf[address(this)];
        require(balanceOfAddressThis > 0, "Can't transfer 0 amount.");
        require(this.approve(address(this), amount % (balanceOfAddressThis + 1)), "Approve failed.");

        bool r = this.transferFrom(address(this), address(this), amount % (balanceOfAddressThis + 1));
        assertWithMsg(r == true, "Failed self transfer.");
        assertEq(balanceOf[address(this)], balanceOfAddressThis, "Self transfer breaks accounting.");
    }


    function fuzz_transferForMoreThanBalanceShouldNotBeAllowed(address to) public {
        uint256 balanceOfAddressThis = balanceOf[address(this)];
        uint256 balanceOfTo = balanceOf[to];

        bool r = this.transfer(to, balanceOfAddressThis + 1);
        assertWithMsg(r == true, "Transfer reverted.");
        assertWithMsg(balanceOfAddressThis == balanceOf[address(this)], "Balance of address(this) changed for invalid tranfer.");
        assertWithMsg(balanceOfTo == balanceOf[to], "Balance of to changed for invalid tranfer.");
    }

    function fuzz_transferFromForMoreThanBalanceShouldNotBeAllowed(address to) public {
        uint256 balanceOfMsgSender = balanceOf[msg.sender];
        uint256 balanceOfTo = balanceOf[to];
        uint256 allowanceBefore = allowance[msg.sender][address(this)];
        require(balanceOfMsgSender < allowanceBefore, "Allowance not bigger than balance.");

        bool r = this.transferFrom(msg.sender, to, balanceOfMsgSender + 1);
        assertWithMsg(r == true, "TransferFrom reverted.");
        assertWithMsg(balanceOfMsgSender == balanceOf[msg.sender], "Balance of address(this) changed for invalid transferFrom.");
        assertWithMsg(balanceOfTo == balanceOf[to], "Balance of to changed for invalid transferFrom.");
        assertWithMsg(allowanceBefore == allowance[msg.sender][address(this)], "Allowance of msg.sender to address(this) changed for invalid transferFrom.");
    }

    function fuzz_transfer0AmountShouldNotBreakAccounting(address to) public {
        uint256 balanceOfAddressThis = balanceOf[address(this)];
        uint256 balanceOfTo = balanceOf[to];

        bool r = this.transfer(to, 0);
        assertWithMsg(r == true, "Transfer reverted.");
        assertWithMsg(balanceOfAddressThis == balanceOf[address(this)], "Balance of address(this) changed for invalid tranfer.");
        assertWithMsg(balanceOfTo == balanceOf[to], "Balance of to changed for invalid tranfer.");
    }

    function fuzz_transferFrom0AmountShouldNotBreakAccounting(address to) public {
        uint256 balanceOfMsgSender = balanceOf[msg.sender];
        uint256 balanceOfTo = balanceOf[to];
        uint256 allowanceBefore = allowance[msg.sender][address(this)];

        bool r = this.transferFrom(msg.sender, to, 0);
        assertWithMsg(r == true, "TransferFrom reverted.");
        assertWithMsg(balanceOfMsgSender == balanceOf[msg.sender], "Balance of address(this) changed for invalid transferFrom.");
        assertWithMsg(balanceOfTo == balanceOf[to], "Balance of to changed for invalid transferFrom.");
        assertWithMsg(allowanceBefore == allowance[msg.sender][address(this)], "Allowance of msg.sender to address(this) changed for invalid transferFrom.");
    }

    function fuzz_transferFromForMoreThanAllowanceShouldNotBeAllowed(address to) public {
        uint256 balanceOfMsgSender = balanceOf[msg.sender];
        uint256 balanceOfTo = balanceOf[to];
        uint256 allowanceBefore = allowance[msg.sender][address(this)];
        require(balanceOfMsgSender > allowanceBefore, "Allowance not bigger than balance.");

        bool r = this.transferFrom(msg.sender, to, balanceOfMsgSender);
        assertWithMsg(r == true, "TransferFrom reverted.");
        assertWithMsg(balanceOfMsgSender == balanceOf[msg.sender], "Balance of address(this) changed for invalid transferFrom.");
        assertWithMsg(balanceOfTo == balanceOf[to], "Balance of to changed for invalid transferFrom.");
        if (allowanceBefore != type(uint256).max) {
            assertWithMsg(allowanceBefore == allowance[msg.sender][address(this)], "Allowance of msg.sender to address(this) changed for invalid transferFrom.");
        }
    }

    function fuzz_transferToOthersShouldWorkCorrectly(address to, uint256 amount) public {
        uint256 balanceOfAddressThis = balanceOf[address(this)];
        require(amount <= balanceOfAddressThis, "Can't transfer more than balanceOf.");
        require(to != address(this), "To can't be address(this).");

        uint256 balanceOfTo = balanceOf[to];

        bool r = this.transfer(to, amount);
        assertWithMsg(r == true, "Transfer reverted.");
        assertWithMsg(balanceOf[address(this)] == balanceOfAddressThis - amount , "Balance of address(this) changed incorrectly for transfer.");
        assertWithMsg(balanceOf[to] == balanceOfTo + amount, "Balance of to changed incorrectly for transfer.");
    }

    function fuzz_transferFromToOthersShouldWorkCorrectly(address from, address to, uint256 amount) public {
        uint256 balanceOfFrom = balanceOf[from];
        uint256 allowanceFromFrom = allowance[from][address(this)];
        require(amount <= balanceOfFrom, "Can't transfer more than balanceOf.");
        require(amount <= allowanceFromFrom, "Can't transferFrom more than balanceOf.");
        require(to != from, "To can't be from.");

        uint256 balanceOfTo = balanceOf[to];

        bool r = this.transferFrom(from, to, amount);
        assertWithMsg(r == true, "TransferFrom reverted.");
        if (allowanceFromFrom != type(uint256).max) {
            assertWithMsg(allowance[from][address(this)] == allowanceFromFrom - amount, "Alowance did not change correctly.");
        }
        assertWithMsg(balanceOf[from] == balanceOfFrom - amount , "Balance of from changed incorrectly for transfer.");
        assertWithMsg(balanceOf[to] == balanceOfTo + amount, "Balance of to changed incorrectly for transfer.");
    }

    function fuzz_approveCorrectlyChangesAllowancesAndNothingElse(address to, uint256 amount) public {
        uint256 balanceOfThis = balanceOf[address(this)];
        uint256 balanceOfTo = balanceOf[to];

        bool r = this.approve(to, amount);
        assertWithMsg(r == true, "TransferFrom reverted.");
        assertWithMsg(allowance[address(this)][to] == amount , "Allowance incorrect.");
        assertWithMsg(balanceOfThis == balanceOf[address(this)], "Balances changed.");
        assertWithMsg(balanceOfTo == balanceOf[to], "Balances changed.");
    }

    function fuzz_allowanceDoesntChangeIfMax(address to, uint256 amount) public {
        require(allowance[msg.sender][address(this)] == type(uint256).max, "Allowance is not max.");
        require(amount <= balanceOf[msg.sender], "BalanceOf too small.");

        bool r = this.transferFrom(msg.sender, address(this), amount);
        assertWithMsg(r == true, "TransferFrom reverted.");
        assertWithMsg(allowance[msg.sender][address(this)] == type(uint256).max, "Allowance changed.");
    }
    
    // function fuzz_
    // transfer Should revert for amount > balance
    // transferFrom should revert for amont > balance and amount > allowance
// Burning should correctly update balances and no allowances
// https://github.com/crytic/properties/blob/main/PROPERTIES.md#erc20
}