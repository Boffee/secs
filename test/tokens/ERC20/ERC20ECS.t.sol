// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "forge-std/console2.sol";
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {DSInvariantTest} from "solmate/test/utils/DSInvariantTest.sol";
import "secs/tokens/ERC20/ERC20DeployLib.sol";
import "./mocks/MockERC20ECS.sol";

/// @author modified from solmate (https://github.com/transmissions11/solmate/blob/main/src/test/ERC20.t.sol)
contract ERC20Test is DSTestPlus {
    MockERC20ECS token;

    bytes32 constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    function setUp() public {
        IWorld world = ERC20DeployLib.deploy();
        token = new MockERC20ECS(world);
        ERC20DeployLib.configERC20ECS(token, "Token", "TKN");
    }

    function invariantMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
        assertEq(token.decimals(), 18);
    }

    function testMint() public {
        token.mint(address(0xBEEF), 1e18);

        assertEq(token.totalSupply(), 1e18);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testBurn() public {
        token.mint(address(0xBEEF), 1e18);
        hevm.prank(address(0xBEEF));
        token.burn(address(0xBEEF), 0.9e18);

        assertEq(token.totalSupply(), 1e18 - 0.9e18);
        assertEq(token.balanceOf(address(0xBEEF)), 0.1e18);
    }

    function testApprove() public {
        assertTrue(token.approve(address(0xBEEF), 1e18));

        assertEq(token.allowance(address(this), address(0xBEEF)), 1e18);
    }

    function testTransfer() public {
        token.mint(address(this), 1e18);

        assertTrue(token.transfer(address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(address(this)), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        hevm.prank(from);
        token.approve(address(this), 1e18);

        assertTrue(token.transferFrom(from, address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(from, address(this)), 0);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testInfiniteApproveTransferFrom() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        hevm.prank(from);
        token.approve(address(this), type(uint256).max);

        assertTrue(token.transferFrom(from, address(0xBEEF), 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(from, address(this)), type(uint256).max);

        assertEq(token.balanceOf(from), 0);
        assertEq(token.balanceOf(address(0xBEEF)), 1e18);
    }

    function testFailTransferInsufficientBalance() public {
        token.mint(address(this), 0.9e18);
        token.transfer(address(0xBEEF), 1e18);
    }

    function testFailTransferFromInsufficientAllowance() public {
        address from = address(0xABCD);

        token.mint(from, 1e18);

        hevm.prank(from);
        token.approve(address(this), 0.9e18);

        token.transferFrom(from, address(0xBEEF), 1e18);
    }

    function testFailTransferFromInsufficientBalance() public {
        address from = address(0xABCD);

        token.mint(from, 0.9e18);

        hevm.prank(from);
        token.approve(address(this), 1e18);

        token.transferFrom(from, address(0xBEEF), 1e18);
    }

    function testMetadata(string calldata name, string calldata symbol)
        public
    {
        IWorld world = ERC20DeployLib.deploy();
        MockERC20ECS tkn = new MockERC20ECS(world);
        ERC20DeployLib.configERC20ECS(tkn, name, symbol);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
    }

    function testMint(address from, uint256 amount) public {
        hevm.assume(from != address(0));

        token.mint(from, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(from), amount);
    }

    function testBurn(address from, uint256 mintAmount, uint256 burnAmount)
        public
    {
        hevm.assume(from != address(0));

        burnAmount = bound(burnAmount, 0, mintAmount);

        token.mint(from, mintAmount);
        hevm.prank(from);
        token.burn(from, burnAmount);

        assertEq(token.totalSupply(), mintAmount - burnAmount);
        assertEq(token.balanceOf(from), mintAmount - burnAmount);
    }

    function testApprove(address to, uint256 amount) public {
        hevm.assume(to != address(0));

        assertTrue(token.approve(to, amount));

        assertEq(token.allowance(address(this), to), amount);
    }

    function testTransfer(address from, uint256 amount) public {
        hevm.assume(from != address(0));

        token.mint(address(this), amount);

        assertTrue(token.transfer(from, amount));
        assertEq(token.totalSupply(), amount);

        if (address(this) == from) {
            assertEq(token.balanceOf(address(this)), amount);
        } else {
            assertEq(token.balanceOf(address(this)), 0);
            assertEq(token.balanceOf(from), amount);
        }
    }

    function testTransferFrom(address to, uint256 approval, uint256 amount)
        public
    {
        hevm.assume(to != address(0));

        amount = bound(amount, 0, approval);

        address from = address(0xABCD);

        token.mint(from, amount);

        hevm.prank(from);
        token.approve(address(this), approval);

        assertTrue(token.transferFrom(from, to, amount));
        assertEq(token.totalSupply(), amount);

        uint256 app = from == address(this) || approval == type(uint256).max
            ? approval
            : approval - amount;
        assertEq(token.allowance(from, address(this)), app);

        if (from == to) {
            assertEq(token.balanceOf(from), amount);
        } else {
            assertEq(token.balanceOf(from), 0);
            assertEq(token.balanceOf(to), amount);
        }
    }

    function testFailBurnInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        hevm.assume(to != address(0));

        burnAmount = bound(burnAmount, mintAmount + 1, type(uint256).max);

        token.mint(to, mintAmount);
        token.burn(to, burnAmount);
    }

    function testFailBurnInsufficientAllowance(
        address to,
        uint256 mintAmount,
        uint256 allowanceAmount,
        uint256 burnAmount
    ) public {
        hevm.assume(to != address(0));
        hevm.assume(burnAmount <= mintAmount && burnAmount > allowanceAmount);

        address from = address(0xABCD);

        token.mint(from, mintAmount);

        hevm.prank(from);
        token.approve(address(this), allowanceAmount);

        token.burn(from, burnAmount);
    }

    function testFailTransferInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        hevm.assume(to != address(0));

        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        token.mint(address(this), mintAmount);
        token.transfer(to, sendAmount);
    }

    function testFailTransferFromInsufficientAllowance(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        hevm.assume(to != address(0));

        amount = bound(amount, approval + 1, type(uint256).max);

        address from = address(0xABCD);

        token.mint(from, amount);

        hevm.prank(from);
        token.approve(address(this), approval);

        token.transferFrom(from, to, amount);
    }

    function testFailTransferFromInsufficientBalance(
        address to,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        hevm.assume(to != address(0));

        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        address from = address(0xABCD);

        token.mint(from, mintAmount);

        hevm.prank(from);
        token.approve(address(this), sendAmount);

        token.transferFrom(from, to, sendAmount);
    }
}

/// @author solmate (https://github.com/transmissions11/solmate/blob/main/src/test/ERC20.t.sol)
contract ERC20Invariants is DSTestPlus, DSInvariantTest {
    BalanceSum balanceSum;
    MockERC20ECS token;

    function setUp() public {
        IWorld world = ERC20DeployLib.deploy();
        token = new MockERC20ECS(world);
        ERC20DeployLib.configERC20ECS(token, "Token", "TKN");

        balanceSum = new BalanceSum(token);

        addTargetContract(address(balanceSum));
    }

    function invariantBalanceSum() public {
        assertEq(token.totalSupply(), balanceSum.sum());
    }
}

/// @author solmate (https://github.com/transmissions11/solmate/blob/main/src/test/ERC20.t.sol)
contract BalanceSum {
    MockERC20ECS token;
    uint256 public sum;

    constructor(MockERC20ECS _token) {
        token = _token;
    }

    function mint(address from, uint256 amount) public {
        token.mint(from, amount);
        sum += amount;
    }

    function burn(address from, uint256 amount) public {
        token.burn(from, amount);
        sum -= amount;
    }

    function approve(address to, uint256 amount) public {
        token.approve(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public {
        token.transferFrom(from, to, amount);
    }

    function transfer(address to, uint256 amount) public {
        token.transfer(to, amount);
    }
}

/*
ENTITY TESTS*/

/// @author boffee
/// @author modified from solmate (https://github.com/transmissions11/solmate/blob/main/src/test/ERC20.t.sol)
contract ERC20EntityTest is DSTestPlus {
    MockERC20ECS token;
    uint256 ENTITY = tokenToEntity(address(0xBEEF), 69);
    uint256 THIS_ENTITY;

    bytes32 constant PERMIT_TYPEHASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );

    function setUp() public {
        IWorld world = ERC20DeployLib.deploy();
        token = new MockERC20ECS(world);
        ERC20DeployLib.configERC20ECS(token, "Token", "TKN");
        THIS_ENTITY = accountToEntity(address(this));
    }

    function invariantMetadata() public {
        assertEq(token.name(), "Token");
        assertEq(token.symbol(), "TKN");
        assertEq(token.decimals(), 18);
    }

    function testMint() public {
        token.mint(ENTITY, 1e18);

        assertEq(token.totalSupply(), 1e18);
        assertEq(token.balanceOf(ENTITY), 1e18);
    }

    // TODO: fix burn test
    // function testBurn() public {
    //     token.mint(ENTITY, 1e18);
    //     token.burn(ENTITY, 0.9e18);

    //     assertEq(token.totalSupply(), 1e18 - 0.9e18);
    //     assertEq(token.balanceOf(ENTITY), 0.1e18);
    // }

    function testApprove() public {
        assertTrue(token.approve(ENTITY, 1e18));

        assertEq(token.allowance(THIS_ENTITY, ENTITY), 1e18);
    }

    function testTransfer() public {
        token.mint(THIS_ENTITY, 1e18);

        assertTrue(token.transfer(ENTITY, 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.balanceOf(THIS_ENTITY), 0);
        assertEq(token.balanceOf(ENTITY), 1e18);
    }

    function testTransferFrom() public {
        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(fromEntity, 1e18);

        hevm.prank(from);
        token.approve(THIS_ENTITY, 1e18);

        assertTrue(token.transferFrom(fromEntity, ENTITY, 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(fromEntity, THIS_ENTITY), 0);

        assertEq(token.balanceOf(fromEntity), 0);
        assertEq(token.balanceOf(ENTITY), 1e18);
    }

    function testInfiniteApproveTransferFrom() public {
        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(fromEntity, 1e18);

        hevm.prank(from);
        token.approve(THIS_ENTITY, type(uint256).max);

        assertTrue(token.transferFrom(fromEntity, ENTITY, 1e18));
        assertEq(token.totalSupply(), 1e18);

        assertEq(token.allowance(fromEntity, THIS_ENTITY), type(uint256).max);

        assertEq(token.balanceOf(fromEntity), 0);
        assertEq(token.balanceOf(ENTITY), 1e18);
    }

    function testFailTransferInsufficientBalance() public {
        token.mint(THIS_ENTITY, 0.9e18);
        token.transfer(ENTITY, 1e18);
    }

    function testFailTransferFromInsufficientAllowance() public {
        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(fromEntity, 1e18);

        hevm.prank(from);
        token.approve(THIS_ENTITY, 0.9e18);

        token.transferFrom(fromEntity, ENTITY, 1e18);
    }

    function testFailTransferFromInsufficientBalance() public {
        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(fromEntity, 0.9e18);

        hevm.prank(from);
        token.approve(THIS_ENTITY, 1e18);

        token.transferFrom(fromEntity, ENTITY, 1e18);
    }

    function testMetadata(string calldata name, string calldata symbol)
        public
    {
        IWorld world = ERC20DeployLib.deploy();
        MockERC20ECS tkn = new MockERC20ECS(world);
        ERC20DeployLib.configERC20ECS(tkn, name, symbol);
        assertEq(tkn.name(), name);
        assertEq(tkn.symbol(), symbol);
    }

    function testMint(uint256 fromEntity, uint256 amount) public {
        hevm.assume(fromEntity != 0 && fromEntity != THIS_ENTITY);

        token.mint(fromEntity, amount);

        assertEq(token.totalSupply(), amount);
        assertEq(token.balanceOf(fromEntity), amount);
    }

    // TODO: fix burn test
    // function testBurn(
    //     uint256 fromEntity,
    //     uint256 mintAmount,
    //     uint256 burnAmount
    // ) public {
    //     hevm.assume(fromEntity != 0 && fromEntity != THIS_ENTITY);

    //     burnAmount = bound(burnAmount, 0, mintAmount);

    //     token.mint(fromEntity, mintAmount);
    //     token.burn(fromEntity, burnAmount);

    //     assertEq(token.totalSupply(), mintAmount - burnAmount);
    //     assertEq(token.balanceOf(fromEntity), mintAmount - burnAmount);
    // }

    function testApprove(uint256 toEntity, uint256 amount) public {
        hevm.assume(toEntity != 0 && toEntity != THIS_ENTITY);

        assertTrue(token.approve(toEntity, amount));

        assertEq(token.allowance(THIS_ENTITY, toEntity), amount);
    }

    function testTransfer(uint256 fromEntity, uint256 amount) public {
        hevm.assume(fromEntity != 0 && fromEntity != THIS_ENTITY);

        token.mint(THIS_ENTITY, amount);

        assertTrue(token.transfer(fromEntity, amount));
        assertEq(token.totalSupply(), amount);

        if (THIS_ENTITY == fromEntity) {
            assertEq(token.balanceOf(THIS_ENTITY), amount);
        } else {
            assertEq(token.balanceOf(THIS_ENTITY), 0);
            assertEq(token.balanceOf(fromEntity), amount);
        }
    }

    function testTransferFrom(
        uint256 toEntity,
        uint256 approval,
        uint256 amount
    ) public {
        hevm.assume(toEntity != 0 && toEntity != THIS_ENTITY);

        amount = bound(amount, 0, approval);

        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(from, amount);

        hevm.prank(from);
        token.approve(THIS_ENTITY, approval);

        assertTrue(token.transferFrom(fromEntity, toEntity, amount));
        assertEq(token.totalSupply(), amount);

        uint256 app = fromEntity == THIS_ENTITY || approval == type(uint256).max
            ? approval
            : approval - amount;
        assertEq(token.allowance(fromEntity, THIS_ENTITY), app);

        if (fromEntity == toEntity) {
            assertEq(token.balanceOf(fromEntity), amount);
        } else {
            assertEq(token.balanceOf(fromEntity), 0);
            assertEq(token.balanceOf(toEntity), amount);
        }
    }

    function testFailBurnInsufficientBalance(
        uint256 toEntity,
        uint256 mintAmount,
        uint256 burnAmount
    ) public {
        hevm.assume(toEntity != 0 && toEntity != THIS_ENTITY);

        burnAmount = bound(burnAmount, mintAmount + 1, type(uint256).max);

        token.mint(toEntity, mintAmount);
        token.burn(toEntity, burnAmount);
    }

    function testFailTransferInsufficientBalance(
        uint256 toEntity,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        hevm.assume(toEntity != 0 && toEntity != THIS_ENTITY);

        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        token.mint(THIS_ENTITY, mintAmount);
        token.transfer(toEntity, sendAmount);
    }

    function testFailTransferFromInsufficientAllowance(
        uint256 toEntity,
        uint256 approval,
        uint256 amount
    ) public {
        amount = bound(amount, approval + 1, type(uint256).max);

        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(from, amount);

        hevm.prank(from);
        token.approve(THIS_ENTITY, approval);

        token.transferFrom(fromEntity, toEntity, amount);
    }

    function testFailTransferFromInsufficientBalance(
        uint256 toEntity,
        uint256 mintAmount,
        uint256 sendAmount
    ) public {
        sendAmount = bound(sendAmount, mintAmount + 1, type(uint256).max);

        address from = address(0xABCD);
        uint256 fromEntity = accountToEntity(from);

        token.mint(from, mintAmount);

        hevm.prank(from);
        token.approve(THIS_ENTITY, sendAmount);

        token.transferFrom(fromEntity, toEntity, sendAmount);
    }
}

contract BalanceSumEntity {
    MockERC20ECS token;
    uint256 public sum;

    constructor(MockERC20ECS _token) {
        token = _token;
    }

    function mint(uint256 from, uint256 amount) public {
        token.mint(from, amount);
        sum += amount;
    }

    function burn(uint256 from, uint256 amount) public {
        token.burn(from, amount);
        sum -= amount;
    }

    function approve(uint256 to, uint256 amount) public {
        token.approve(to, amount);
    }

    function transferFrom(uint256 from, uint256 to, uint256 amount) public {
        token.transferFrom(from, to, amount);
    }

    function transfer(uint256 to, uint256 amount) public {
        token.transfer(to, amount);
    }
}
