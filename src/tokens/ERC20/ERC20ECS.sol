// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "solecs/interfaces/IWorld.sol";
import "solecs/Ownable.sol";
import "solecs/utils.sol";
import "secs/libraries/SystemDelegateCall.sol";
import "secs/systems/System.sol";
import "secs/utils/entity.sol";
import "./systems/ERC20ApproveSystem.sol";
import "./systems/ERC20BurnFromSystem.sol";
import "./systems/ERC20TransferFromSystem.sol";
import "./ERC20ECSLib.sol";
import "./IERC20ECS.sol";

contract ERC20ECS is IERC20ECS, Ownable, Context {
    using ERC20ECSLib for IUint256Component;
    using SystemDelegateCall for address;

    IUint256Component public immutable SYSTEMS;
    IUint256Component public immutable COMPONENTS;

    constructor(IWorld world) {
        SYSTEMS = world.systems();
        COMPONENTS = world.components();
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC20).interfaceId
            || interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev See {IERC20-name}.
     */
    function name() public view virtual returns (string memory) {
        return COMPONENTS.name();
    }

    /**
     * @dev See {IERC20-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return COMPONENTS.symbol();
    }

    /**
     * @dev See {IERC20-decimals}.
     */
    function decimals() public view virtual returns (uint8) {
        return COMPONENTS.decimals();
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return COMPONENTS.totalSupply();
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return balanceOf(addressToEntity(account));
    }

    function balanceOf(uint256 account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return COMPONENTS.balanceOf(thisEntity(), account);
    }

    /**
     * @dev See {IERC20-transfer}.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return transfer(addressToEntity(to), amount);
    }

    function transfer(uint256 to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return transferFrom(addressToEntity(_msgSender()), to, amount);
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return allowance(addressToEntity(owner), addressToEntity(spender));
    }

    function allowance(uint256 owner, uint256 spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return COMPONENTS.allowance(thisEntity(), owner, spender);
    }

    /**
     * @dev See {IERC20-approve}.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return approve(addressToEntity(spender), amount);
    }

    function approve(uint256 spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address(getERC20ApproveSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(thisEntity(), spender, amount)
        );
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return transferFrom(addressToEntity(from), addressToEntity(to), amount);
    }

    function transferFrom(uint256 from, uint256 to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address(getERC20TransferFromSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(thisEntity(), from, to, amount)
        );
        return true;
    }

    function burn(address account, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        return burn(addressToEntity(account), amount);
    }

    function burn(uint256 account, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address(getERC20BurnFromSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(thisEntity(), account, amount)
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        return increaseAllowance(addressToEntity(spender), addedValue);
    }

    function increaseAllowance(uint256 spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        uint256 owner = addressToEntity(_msgSender());
        approve(spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        return decreaseAllowance(addressToEntity(spender), subtractedValue);
    }

    function decreaseAllowance(uint256 spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 owner = addressToEntity(_msgSender());
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            approve(spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function beforeTokenTransfer(uint256 from, uint256 to, uint256 amount)
        public
        onlyBalanceWriter
    {
        _beforeTokenTransfer(from, to, amount);
    }

    function afterTokenTransfer(uint256 from, uint256 to, uint256 amount)
        public
        onlyBalanceWriter
    {
        _afterTokenTransfer(from, to, amount);
        emit Transfer(
            entityToAddress(from), entityToAddress(to), getEntityId(amount)
            );
    }

    function afterApproval(uint256 owner, uint256 spender, uint256 amount)
        public
        onlyAllowanceWriter
    {
        _afterApproval(owner, spender, amount);
        emit Approval(
            entityToAddress(owner),
            entityToAddress(spender),
            getEntityId(amount)
            );
    }

    function _beforeTokenTransfer(uint256 from, uint256 to, uint256 amount)
        internal
        virtual
    {}

    function _afterTokenTransfer(uint256 from, uint256 to, uint256 amount)
        internal
        virtual
    {}

    function _afterApproval(uint256 owner, uint256 spender, uint256 amount)
        internal
        virtual
    {}

    function setName(string memory name_) public virtual onlyOwner {
        COMPONENTS._setName(name_);
    }

    function setSymbol(string memory symbol_) public virtual onlyOwner {
        COMPONENTS._setSymbol(symbol_);
    }

    /**
     * @dev return this contract entity
     * @return entity
     */
    function thisEntity() public view returns (uint256) {
        return addressToEntity(address(this));
    }

    modifier onlyBalanceWriter() {
        require(
            getBalanceComponent(COMPONENTS).writeAccess(_msgSender()),
            "ERC20: only balance writer"
        );
        _;
    }

    modifier onlyAllowanceWriter() {
        require(
            getAllowanceComponent(COMPONENTS).writeAccess(_msgSender()),
            "ERC20: only allowance writer"
        );
        _;
    }
}

function configERC20ECS(
    ERC20ECS erc20,
    string memory name,
    string memory symbol
) {
    IUint256Component components = erc20.COMPONENTS();
    getAllowanceComponent(components).authorizeWriter(address(erc20));
    getBalanceComponent(components).authorizeWriter(address(erc20));
    getNameComponent(components).authorizeWriter(address(erc20));
    getSymbolComponent(components).authorizeWriter(address(erc20));
    getTotalSupplyComponent(components).authorizeWriter(address(erc20));

    erc20.setName(name);
    erc20.setSymbol(symbol);
}
