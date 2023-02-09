// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "secs/libraries/ComponentGetter.sol";
import "secs/libraries/DelegateCall.sol";
import "secs/systems/System.sol";
import "secs/utils/entity.sol";
import "./libraries/SystemGetter.sol";
import "./ECS20Lib.sol";
import "./IECS20.sol";

contract ECS20 is System, IECS20 {
    using ComponentGetter for IUint256Component;
    using SystemGetter for IUint256Component;
    using ECS20Lib for IUint256Component;
    using DelegateCall for address;

    IUint256Component public immutable SYSTEMS;

    constructor(IWorld world, uint256 id) System(world, id) {
        SYSTEMS = world.systems();
    }

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 account, uint256 amount) = abi.decode(args, (uint256, uint256));

        executeTyped(account, amount);
    }

    function executeTyped(uint256 account, uint256 amount)
        public
        virtual
        returns (bytes memory)
    {
        _mint(account, amount);
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
        return COMPONENTS.balanceOf(thisEntity(), addressToEntity(account));
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
        return transferFrom(_msgSender(), to, amount);
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
        return COMPONENTS.allowance(
            thisEntity(), addressToEntity(owner), addressToEntity(spender)
        );
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
        address(SYSTEMS.approveSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR,
                abi.encode(thisEntity(), addressToEntity(spender), amount)
            )
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
        address(SYSTEMS.transferFromSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR,
                abi.encode(thisEntity(), from, addressToEntity(to), amount)
            )
        );
        return true;
    }

    function burn(address account, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address(SYSTEMS.burnFromSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR, abi.encode(thisEntity(), account, amount)
            )
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
        address owner = _msgSender();
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
        address owner = _msgSender();
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
        virtual
        onlyOperator
    {}

    function afterTokenTransfer(uint256 from, uint256 to, uint256 amount)
        public
        virtual
        onlyOperator
    {
        emit Transfer(
            entityToAddress(from), entityToAddress(to), getEntityId(amount)
            );
    }

    function afterApproval(uint256 owner, uint256 spender, uint256 amount)
        public
        virtual
        onlyOperator
    {
        emit Approval(
            entityToAddress(owner),
            entityToAddress(spender),
            getEntityId(amount)
            );
    }

    function setName(string memory name_) public virtual onlyOwner {
        COMPONENTS._setName(name_);
    }

    function setSymbol(string memory symbol_) public virtual onlyOwner {
        COMPONENTS._setSymbol(symbol_);
    }

    function approveOperator(address operator) public virtual onlyOwner {
        COMPONENTS.operatorApprovalComponent().set(
            hashEntities(
                addressToEntity(address(this)), addressToEntity(operator)
            )
        );
    }

    function _mint(address account, uint256 amount) internal virtual {
        _mint(addressToEntity(account), amount);
    }

    function _mint(uint256 account, uint256 amount) internal virtual {
        COMPONENTS._mint(thisEntity(), account, amount);
    }

    /**
     * @dev convert tokenId to entity
     * @param tokenId tokenId
     * @return entity
     */
    function toEntity(uint256 tokenId) public view returns (uint256) {
        return tokenToEntity(address(this), tokenId);
    }

    /**
     * @dev return this contract entity
     * @return entity
     */
    function thisEntity() public view returns (uint256) {
        return addressToEntity(address(this));
    }

    /**
     * @dev check if the caller is an operator
     */
    modifier onlyOperator() {
        address sender = _msgSender();
        require(
            sender == (address(this))
                || COMPONENTS.operatorApprovalComponent().getValue(
                    hashEntities(
                        addressToEntity(address(this)), addressToEntity(sender)
                    )
                ),
            "ERC20: caller is not an operator"
        );
        _;
    }
}
