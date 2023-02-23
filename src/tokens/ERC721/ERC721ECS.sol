// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "solecs/interfaces/IWorld.sol";
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

contract ERC721ECS is System, IERC721ECS {
    using ERC721ECSLib for IUint256Component;
    using SystemDelegateCall for address;

    IUint256Component public immutable SYSTEMS;

    constructor(IWorld world, uint256 id) System(world, id) {
        SYSTEMS = world.systems();
    }

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity) public virtual {
        _mint(to, entity);
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
        virtual
        onlyOwnerWriter
    {}

    function afterTokenTransfer(uint256 from, uint256 to, uint256 entity)
        public
        virtual
        onlyOwnerWriter
    {
        emit Transfer(
            entityToAddress(from), entityToAddress(to), getEntityId(entity)
            );
    }

    function afterApproval(uint256 owner, uint256 approved, uint256 entity)
        public
        virtual
        onlyApprovalWriter
    {
        emit Approval(
            entityToAddress(owner),
            entityToAddress(approved),
            getEntityId(entity)
            );
    }

    function afterApprovalForAll(uint256 owner, uint256 operator, bool approved)
        public
        virtual
        onlyOperatorApprovalWriter
    {
        emit ApprovalForAll(
            entityToAddress(owner), entityToAddress(operator), approved
            );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        _mint(addressToEntity(to), tokenId);
    }

    function _mint(uint256 to, uint256 tokenId) internal virtual {
        COMPONENTS._mint(to, toEntity(tokenId));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(addressToEntity(to), tokenId);
    }

    function _safeMint(uint256 to, uint256 tokenId) internal virtual {
        COMPONENTS._safeMint(
            addressToEntity(_msgSender()), to, toEntity(tokenId)
        );
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data)
        internal
        virtual
    {
        _safeMint(addressToEntity(to), tokenId, data);
    }

    function _safeMint(uint256 to, uint256 tokenId, bytes memory data)
        internal
        virtual
    {
        COMPONENTS._safeMint(
            addressToEntity(_msgSender()), to, toEntity(tokenId), data
        );
    }

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
