// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "solecs/interfaces/IWorld.sol";
import "solecs/Ownable.sol";
import "solecs/utils.sol";
import "secs/libraries/SystemDelegateCall.sol";
import "secs/utils/entity.sol";
import "./systems/ApproveSystem.sol";
import "./systems/BurnSystem.sol";
import "./systems/SafeTransferFromSystem.sol";
import "./systems/SetApprovalForAllSystem.sol";
import "./systems/TransferFromSystem.sol";
import "./ERC721ECSLib.sol";
import "./IERC721ECS.sol";

contract ERC721ECS is IERC721ECS, Ownable, Context {
    using ERC721ECSLib for IUint256Component;
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
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return balanceOf(addressToEntity(owner));
    }

    function balanceOf(uint256 owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return COMPONENTS.balanceOf(owner);
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        return entityToAddress(COMPONENTS.ownerOf(toEntity(tokenId)));
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return COMPONENTS.name();
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return COMPONENTS.symbol();
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        // return
        //     COMPONENTS.tokenURIComponent().getValue(
        //         thisEntity()
        //     );
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        approve(addressToEntity(to), tokenId);
    }

    function approve(uint256 to, uint256 tokenId) public virtual override {
        address(getApproveSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(to, toEntity(tokenId))
        );
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        return entityToAddress(COMPONENTS.getApproved(toEntity(tokenId)));
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        setApprovalForAll(addressToEntity(operator), approved);
    }

    function setApprovalForAll(uint256 operator, bool approved)
        public
        virtual
        override
    {
        address(getSetApprovalForAllSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(thisEntity(), operator, approved)
        );
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            isApprovedForAll(addressToEntity(owner), addressToEntity(operator));
    }

    function isApprovedForAll(uint256 owner, uint256 operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return COMPONENTS.isApprovedForAll(thisEntity(), owner, operator);
    }

    function burn(uint256 tokenId) public virtual override {
        address(getBurnSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(toEntity(tokenId))
        );
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId)
        public
        virtual
        override
    {
        transferFrom(addressToEntity(from), addressToEntity(to), tokenId);
    }

    function transferFrom(uint256 from, uint256 to, uint256 tokenId)
        public
        virtual
        override
    {
        address(getTransferFromSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(from, to, toEntity(tokenId))
        );
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId)
        public
        virtual
        override
    {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(uint256 from, uint256 to, uint256 tokenId)
        public
        virtual
        override
    {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        safeTransferFrom(
            addressToEntity(from), addressToEntity(to), tokenId, data
        );
    }

    function safeTransferFrom(
        uint256 from,
        uint256 to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        address(getSafeTransferFromSystem(SYSTEMS)).systemDelegateCall(
            abi.encode(from, to, toEntity(tokenId), data)
        );
    }

    /**
     * @dev convert tokenId to entity
     * @param tokenId tokenId
     * @return entity
     */
    function toEntity(uint256 tokenId) public view returns (uint256) {
        return tokenToEntity(address(this), tokenId);
    }

    function beforeTokenTransfer(uint256 from, uint256 to, uint256 entity)
        public
        onlyOwnerWriter
    {
        _beforeTokenTransfer(from, to, entity);
    }

    function afterTokenTransfer(uint256 from, uint256 to, uint256 entity)
        public
        onlyOwnerWriter
    {
        _afterTokenTransfer(from, to, entity);
        emit Transfer(
            entityToAddress(from), entityToAddress(to), getEntityId(entity)
            );
    }

    function afterApproval(uint256 owner, uint256 approved, uint256 entity)
        public
        onlyApprovalWriter
    {
        _afterApproval(owner, approved, entity);
        emit Approval(
            entityToAddress(owner),
            entityToAddress(approved),
            getEntityId(entity)
            );
    }

    function afterApprovalForAll(uint256 owner, uint256 operator, bool approved)
        public
        onlyOperatorApprovalWriter
    {
        _afterApprovalForAll(owner, operator, approved);
        emit ApprovalForAll(
            entityToAddress(owner), entityToAddress(operator), approved
            );
    }

    function _beforeTokenTransfer(uint256 from, uint256 to, uint256 entity)
        internal
        virtual
    {}

    function _afterTokenTransfer(uint256 from, uint256 to, uint256 entity)
        internal
        virtual
    {}

    function _afterApproval(uint256 owner, uint256 approved, uint256 entity)
        internal
        virtual
    {}

    function _afterApprovalForAll(
        uint256 owner,
        uint256 operator,
        bool approved
    ) internal virtual {}

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

    modifier onlyOwnerWriter() {
        require(
            getOwnerComponent(COMPONENTS).writeAccess(_msgSender()),
            "ERC721: only owner writer"
        );
        _;
    }

    modifier onlyApprovalWriter() {
        require(
            getApprovalComponent(COMPONENTS).writeAccess(_msgSender()),
            "ERC721: only approval writer"
        );
        _;
    }

    modifier onlyOperatorApprovalWriter() {
        require(
            getOperatorApprovalComponent(COMPONENTS).writeAccess(_msgSender()),
            "ERC721: only operator approval writer"
        );
        _;
    }
}

function configERC721ECS(
    ERC721ECS erc721,
    string memory name,
    string memory symbol
) {
    IUint256Component components = erc721.COMPONENTS();
    getApprovalComponent(components).authorizeWriter(address(erc721));
    getBalanceComponent(components).authorizeWriter(address(erc721));
    getNameComponent(components).authorizeWriter(address(erc721));
    getOperatorApprovalComponent(components).authorizeWriter(address(erc721));
    getOwnerComponent(components).authorizeWriter(address(erc721));
    getSymbolComponent(components).authorizeWriter(address(erc721));

    erc721.setName(name);
    erc721.setSymbol(symbol);
}
