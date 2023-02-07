// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "solecs/interfaces/IWorld.sol";
import "solecs/utils.sol";
import "../libraries/ComponentGetter.sol";
import "../libraries/DelegateCall.sol";
import "../libraries/ECS721Lib.sol";
import "../libraries/SystemGetter.sol";
import "../utils/entity.sol";
import "./IECS721.sol";

contract ECS721 is System, IECS721 {
    using ComponentGetter for IUint256Component;
    using SystemGetter for IUint256Component;
    using ECS721Lib for IUint256Component;
    using DelegateCall for address;

    IUint256Component public immutable SYSTEMS;

    constructor(IWorld world, uint256 id) System(world, id) {
        SYSTEMS = world.systems();
    }

    function execute(bytes memory args) public virtual returns (bytes memory) {
        (uint256 to, uint256 entity) = abi.decode(args, (uint256, uint256));

        executeTyped(to, entity);
    }

    function executeTyped(uint256 to, uint256 entity)
        public
        virtual
        returns (bytes memory)
    {
        COMPONENTS._mint(to, entity);
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
        return COMPONENTS.balanceOf(addressToEntity(owner));
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
        //         addressToEntity(address(this))
        //     );
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address(SYSTEMS.approveSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR,
                abi.encode(addressToEntity(to), toEntity(tokenId))
            )
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
        address(SYSTEMS.setApprovalForAllSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR,
                abi.encode(
                    addressToEntity(address(this)),
                    addressToEntity(operator),
                    approved
                )
            )
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
        return COMPONENTS.isApprovedForAll(
            addressToEntity(address(this)),
            addressToEntity(owner),
            addressToEntity(operator)
        );
    }

    function burn(uint256 tokenId) public virtual override {
        address(SYSTEMS.burnSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR, abi.encode(toEntity(tokenId))
            )
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
        address(SYSTEMS.transferFromSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR,
                abi.encode(
                    addressToEntity(from),
                    addressToEntity(to),
                    toEntity(tokenId)
                )
            )
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

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        address(SYSTEMS.safeTransferFromSystem()).functionDelegateCall(
            abi.encodeWithSelector(
                EXECUTE_SELECTOR,
                abi.encode(
                    addressToEntity(from),
                    addressToEntity(to),
                    toEntity(tokenId),
                    data
                )
            )
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
    {}

    function afterTokenTransfer(uint256 from, uint256 to, uint256 entity)
        public
        virtual
    {
        emit Transfer(
            entityToAddress(from), entityToAddress(to), getEntityId(entity)
            );
    }

    function afterApproval(uint256 owner, uint256 approved, uint256 entity)
        public
        virtual
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
    {
        emit ApprovalForAll(
            entityToAddress(owner), entityToAddress(operator), approved
            );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        COMPONENTS._mint(addressToEntity(to), toEntity(tokenId));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        COMPONENTS._safeMint(
            addressToEntity(_msgSender()),
            addressToEntity(to),
            toEntity(tokenId)
        );
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data)
        internal
        virtual
    {
        COMPONENTS._safeMint(
            addressToEntity(_msgSender()),
            addressToEntity(to),
            toEntity(tokenId),
            data
        );
    }

    function setName(string memory name_) public virtual onlyOwner {
        COMPONENTS._setName(name_);
    }

    function setSymbol(string memory symbol_) public virtual onlyOwner {
        COMPONENTS._setSymbol(symbol_);
    }
}
