// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "secs/tokens/libraries/ComponentGetter.sol";
import "secs/utils/entity.sol";
import "./IECS721Hooks.sol";

library ECS721Lib {
    using ComponentGetter for IUint256Component;
    using Address for address;

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(IUint256Component components, uint256 owner)
        internal
        view
        returns (uint256)
    {
        require(owner != 0, "ERC721: address zero is not a valid owner");
        return components.balanceComponent().getValue(
            hashEntities(addressToEntity(address(this)), owner)
        );
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(IUint256Component components, uint256 entity)
        internal
        view
        returns (uint256)
    {
        uint256 owner = _ownerOf(components, entity);
        require(owner != 0, "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name(IUint256Component components)
        internal
        view
        returns (string memory)
    {
        return
            components.nameComponent().getValue(addressToEntity(address(this)));
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol(IUint256Component components)
        public
        view
        returns (string memory)
    {
        return components.symbolComponent().getValue(
            addressToEntity(address(this))
        );
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(IUint256Component components, uint256 entity)
        internal
        view
        returns (uint256)
    {
        return components.approvalComponent().getValue(entity);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 operator
    ) internal view returns (bool) {
        return components.operatorApprovalComponent().getValue(
            hashEntities(token, owner, operator)
        );
    }

    function _setName(IUint256Component components, string memory name_)
        internal
    {
        components.nameComponent().set(addressToEntity(address(this)), name_);
    }

    function _setSymbol(IUint256Component components, string memory symbol_)
        internal
    {
        components.symbolComponent().set(
            addressToEntity(address(this)), symbol_
        );
    }

    /**
     * @dev Safely transfers `entity` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `entity` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        IUint256Component components,
        uint256 operator,
        uint256 from,
        uint256 to,
        uint256 entity,
        bytes memory data
    ) internal {
        _transfer(components, from, to, entity);
        require(
            _checkOnERC721Received(
                entityToAddress(operator),
                entityToAddress(from),
                entityToAddress(to),
                getEntityId(entity),
                data
            ),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns the owner of the `entity`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(IUint256Component components, uint256 entity)
        internal
        view
        returns (uint256)
    {
        return components.ownerComponent().getValue(entity);
    }

    /**
     * @dev Returns whether `entity` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(IUint256Component components, uint256 entity)
        internal
        view
        returns (bool)
    {
        return _ownerOf(components, entity) != 0;
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `entity`.
     *
     * Requirements:
     *
     * - `entity` must exist.
     */
    function _isApprovedOrOwner(
        IUint256Component components,
        uint256 spender,
        uint256 entity
    ) internal view returns (bool) {
        uint256 owner = ownerOf(components, entity);
        uint256 token = getEntityToken(entity);
        return owner == spender
            || isApprovedForAll(components, token, owner, spender)
            || getApproved(components, entity) == spender;
    }

    /**
     * @dev Safely mints `entity` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `entity` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        IUint256Component components,
        uint256 operator,
        uint256 to,
        uint256 entity
    ) internal {
        _safeMint(components, operator, to, entity, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        IUint256Component components,
        uint256 operator,
        uint256 to,
        uint256 entity,
        bytes memory data
    ) internal {
        _mint(components, to, entity);
        require(
            _checkOnERC721Received(
                entityToAddress(operator),
                address(0),
                entityToAddress(to),
                getEntityId(entity),
                data
            ),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `entity` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `entity` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(IUint256Component components, uint256 to, uint256 entity)
        internal
    {
        require(to != 0, "ERC721: mint to the zero address");
        require(!_exists(components, entity), "ERC721: token already minted");
        _beforeTokenTransfer(0, to, entity);

        require(!_exists(components, entity), "ERC721: token already minted");

        // Increment balance
        components.balanceComponent().increment(
            hashEntities(getEntityToken(entity), to), 1
        );

        // Set owner
        components.ownerComponent().set(entity, to);

        _afterTokenTransfer(0, to, entity);
    }

    /**
     * @dev Destroys `entity`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `entity` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(IUint256Component components, uint256 entity) internal {
        OwnerComponent ownerComponent = components.ownerComponent();
        uint256 owner = ownerComponent.getValue(entity);

        _beforeTokenTransfer(owner, 0, entity);

        // Clear approvals
        components.approvalComponent().remove(entity);

        // Decrement balance
        components.balanceComponent().decrement(
            hashEntities(getEntityToken(entity), owner), 1
        );

        // Delete owner
        ownerComponent.remove(entity);

        _afterTokenTransfer(owner, 0, entity);
    }

    /**
     * @dev Transfers `entity` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `entity` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        IUint256Component components,
        uint256 from,
        uint256 to,
        uint256 entity
    ) internal {
        require(
            ownerOf(components, entity) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != 0, "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, entity);

        // Check that entity was not transferred by `_beforeTokenTransfer` hook
        require(
            ownerOf(components, entity) == from,
            "ERC721: transfer from incorrect owner"
        );

        // Clear approvals from the previous owner
        components.approvalComponent().remove(entity);

        // Move balance from old owner to new owner
        uint256 token = getEntityToken(entity);
        BalanceComponent balanceComponent = components.balanceComponent();
        balanceComponent.decrement(hashEntities(token, from), 1);
        balanceComponent.increment(hashEntities(token, to), 1);

        // Update owner
        components.ownerComponent().set(entity, to);

        _afterTokenTransfer(from, to, entity);
    }

    /**
     * @dev Approve `to` to operate on `entity`
     *
     * Emits an {Approval} event.
     */
    function _approve(IUint256Component components, uint256 to, uint256 entity)
        internal
    {
        components.approvalComponent().set(entity, to);
        _afterApproval(ownerOf(components, entity), to, entity);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 operator,
        bool approved
    ) internal {
        require(owner != operator, "ERC721: approve to caller");

        if (approved) {
            components.operatorApprovalComponent().set(
                hashEntities(token, owner, operator)
            );
        } else {
            components.operatorApprovalComponent().remove(
                hashEntities(token, owner, operator)
            );
        }
    }

    /**
     * @dev Reverts if the `entity` has not been minted yet.
     */
    function _requireMinted(IUint256Component components, uint256 entity)
        internal
        view
    {
        require(_exists(components, entity), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(
                operator, from, tokenId, data
            ) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(uint256 from, uint256 to, uint256 entity)
        internal
    {
        IECS721Hooks(getEntityTokenAddress(entity)).beforeTokenTransfer(
            from, to, entity
        );
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(uint256 from, uint256 to, uint256 entity)
        internal
    {
        IECS721Hooks(getEntityTokenAddress(entity)).afterTokenTransfer(
            from, to, entity
        );
    }

    function _afterApproval(uint256 owner, uint256 to, uint256 entity)
        internal
    {
        IECS721Hooks(getEntityTokenAddress(entity)).afterApproval(
            owner, to, entity
        );
    }

    function _afterApprovalForAll(
        uint256 token,
        uint256 owner,
        uint256 operator,
        bool approved
    ) internal {
        IECS721Hooks(getEntityTokenAddress(token)).afterApprovalForAll(
            owner, operator, approved
        );
    }
}
