pragma solidity 0.8.19;
import {SignedWadMath} from "./SignedWadMath.sol";
import "./helper.sol";

// Run with medusa fuzz --target contracts/SignedWadMathTest.sol --deployment-order SignedWadMathTest

contract SignedWadMathTest is PropertiesAsserts{
    uint256 private constant WAD = 10 ** 18;
    uint256 private constant SECONDS_IN_DAY = 86400;

    function testToWadUnsafe(uint256 x) public {
        // Ensure that toWadUnsafe will not overflow
        x = clampLte(x, type(uint256).max / WAD);

        // Compute y
        int256 y = SignedWadMath.toWadUnsafe(x);

        // Ensure that x <= uint(y)
        assertLte(x, uint256(y), "X should be less or equal to Y");

        // Ensure that y / WAD == x
        assertEq(uint256(y) / WAD, x, "Y back from WADs is not equal to X");
    }

    // function testToDaysWadUnsafeNoOverflow(uint256 x) public {
    //     // Ensure that toDaysWadUnsafe will not overflow
    //     x = clampLte(x, type(uint256).max / WAD);

    //     // Compute y
    //     int256 y = SignedWadMath.toDaysWadUnsafe(x);

    //     // Ensure that x <= y
    //     assertLte(x, uint256(y), "X should be less or equal to Y");

    //     // Ensure that x * WAD / SECONDS_IN_DAY == y
    //     assertEq(x * WAD / SECONDS_IN_DAY, uint256(y), "X to days it not equal Y");

    // }

    // function testFromDaysWadUnsafe(int256 numberOfDays) public {
    //     // There can be at most type(uint256).max days in wads
    //     numberOfDays = clampLte(numberOfDays, type(uint256).max / WAD / SECONDS_IN_DAY);
    //     int256 daysInWad = SignedWadMath.toWadUnsafe(numberOfDays);
    //     // Ensure that fromDaysWadUnsafe will not overflow
    //     // The below also checks x > 0

    //     x = clampLte(x, type(int256).max / int256(SECONDS_IN_DAY));

    //     // Compute y
    //     uint256 y = SignedWadMath.fromDaysWadUnsafe(x);

    //     // Ensure that the two functions are equivalent
    //     assertEq(SignedWadMath.toDaysWadUnsafe(y), x, "days functions are not equivalent");
    // }

    // TODO: test to make sure that as long as seconds are between an interval, they result in the same day

}