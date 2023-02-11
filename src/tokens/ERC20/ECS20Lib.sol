// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "solecs/interfaces/IUint256Component.sol";
import "solecs/utils.sol";
import "secs/utils/entity.sol";
import "../components/AllowanceComponent.sol";
import "../components/BalanceComponent.sol";
import "../components/NameComponent.sol";
import "../components/SymbolComponent.sol";
import "../components/TotalSupplyComponent.sol";
import "./IECS20Hooks.sol";

library ECS20Lib {
    /**
     * @dev Returns the name of the token.
     */
    function name(IUint256Component components)
        internal
        view
        returns (string memory)
    {
        // return _name;
        return getNameComponent(components).getValue(thisEntity());
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol(IUint256Component components)
        internal
        view
        returns (string memory)
    {
        // return _symbol;
        return getSymbolComponent(components).getValue(thisEntity());
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals(IUint256Component components)
        internal
        view
        returns (uint8)
    {
        // return 18;
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply(IUint256Component components)
        internal
        view
        returns (uint256)
    {
        // return _totalSupply;
        return getTotalSupplyComponent(components).getValue(thisEntity());
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(
        IUint256Component components,
        uint256 token,
        uint256 account
    ) internal view returns (uint256) {
        // return _balances[account];
        return getBalanceComponent(components).getValue(
            hashEntities(token, account)
        );
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 spender
    ) internal view returns (uint256) {
        // return _allowances[owner][spender];
        return getAllowanceComponent(components).getValue(
            hashEntities(token, owner, spender)
        );
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        IUint256Component components,
        uint256 token,
        uint256 from,
        uint256 to,
        uint256 amount
    ) internal {
        // require(from != address(0), "ERC20: transfer from the zero address");
        // require(to != address(0), "ERC20: transfer to the zero address");
        require(from != 0, "ERC20: transfer from the zero address");
        require(to != 0, "ERC20: transfer to the zero address");

        // _beforeTokenTransfer(from, to, amount);
        _beforeTokenTransfer(token, from, to, amount);

        BalanceComponent balanceComponent = getBalanceComponent(components);
        // uint256 fromBalance = _balances[from];
        // require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 fromBalance =
            balanceComponent.getValue(hashEntities(token, from));
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        // unchecked {
        //     _balances[from] = fromBalance - amount;
        //     // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        //     // decrementing then incrementing.
        //     _balances[to] += amount;
        // }
        balanceComponent.set(hashEntities(token, from), fromBalance - amount);
        balanceComponent.increment(hashEntities(token, to), amount);

        // emit Transfer(from, to, amount);

        // _afterTokenTransfer(from, to, amount);
        _afterTokenTransfer(token, from, to, amount);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(
        IUint256Component components,
        uint256 token,
        uint256 account,
        uint256 amount
    ) internal {
        // require(account != address(0), "ERC20: mint to the zero address");
        require(account != 0, "ERC20: mint to the zero address");

        // _beforeTokenTransfer(address(0), account, amount);
        _beforeTokenTransfer(token, 0, account, amount);

        // _totalSupply += amount;
        getTotalSupplyComponent(components).increment(token, amount);
        // unchecked {
        //     // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
        //     _balances[account] += amount;
        // }
        getBalanceComponent(components).increment(
            hashEntities(token, account), amount
        );

        // emit Transfer(address(0), account, amount);

        // _afterTokenTransfer(address(0), account, amount);
        _afterTokenTransfer(token, 0, account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(
        IUint256Component components,
        uint256 token,
        uint256 account,
        uint256 amount
    ) internal {
        // require(account != address(0), "ERC20: burn from the zero address");
        require(account != 0, "ERC20: burn from the zero address");

        // _beforeTokenTransfer(account, address(0), amount);
        _beforeTokenTransfer(token, account, 0, amount);

        // uint256 accountBalance = _balances[account];
        // require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        BalanceComponent balanceComponent = getBalanceComponent(components);
        uint256 entityBalance =
            balanceComponent.getValue(hashEntities(token, account));
        require(entityBalance >= amount, "ERC20: burn amount exceeds balance");

        // unchecked {
        //     _balances[account] = accountBalance - amount;
        //     // Overflow not possible: amount <= accountBalance <= totalSupply.
        //     _totalSupply -= amount;
        // }
        balanceComponent.set(
            hashEntities(token, account), entityBalance - amount
        );
        getTotalSupplyComponent(components).decrement(token, amount);

        // emit Transfer(account, address(0), amount);

        // _afterTokenTransfer(account, address(0), amount);
        _afterTokenTransfer(token, account, 0, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 spender,
        uint256 amount
    ) internal {
        // require(owner != address(0), "ERC20: approve from the zero address");
        // require(spender != address(0), "ERC20: approve to the zero address");
        require(owner != 0, "ERC20: approve from the zero address");
        require(spender != 0, "ERC20: approve to the zero address");

        // _allowances[owner][spender] = amount;
        getAllowanceComponent(components).set(
            hashEntities(token, owner, spender), amount
        );

        // emit Approval(owner, spender, amount);
        _afterApproval(token, owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 spender,
        uint256 amount
    ) internal {
        // uint256 currentAllowance = allowance(owner, spender);
        uint256 currentAllowance = getAllowanceComponent(components).getValue(
            hashEntities(token, owner, spender)
        );

        // if (currentAllowance != type(uint256).max) {
        //     require(currentAllowance >= amount, "ERC20: insufficient allowance");
        //     unchecked {
        //         _approve(owner, spender, currentAllowance - amount);
        //     }
        // }
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(
                components, token, owner, spender, currentAllowance - amount
            );
        }
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
    function _increaseAllowance(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 spender,
        uint256 addedValue
    ) internal returns (bool) {
        // address owner = _msgSender();
        // _approve(owner, spender, allowance(owner, spender) + addedValue);
        getAllowanceComponent(components).increment(
            hashEntities(token, owner, spender), addedValue
        );
        // return true;
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
    function _decreaseAllowance(
        IUint256Component components,
        uint256 token,
        uint256 owner,
        uint256 spender,
        uint256 subtractedValue
    ) internal returns (bool) {
        // address owner = _msgSender();
        // uint256 currentAllowance = allowance(owner, spender);
        // require(
        //     currentAllowance >= subtractedValue,
        //     "ERC20: decreased allowance below zero"
        // );
        uint256 currentAllowance = getAllowanceComponent(components).getValue(
            hashEntities(token, owner, spender)
        );
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        // unchecked {
        //     _approve(owner, spender, currentAllowance - subtractedValue);
        // }
        _approve(
            components,
            token,
            owner,
            spender,
            currentAllowance - subtractedValue
        );

        return true;
    }

    function _setName(IUint256Component components, string memory name_)
        internal
    {
        getNameComponent(components).set(addressToEntity(address(this)), name_);
    }

    function _setSymbol(IUint256Component components, string memory symbol_)
        internal
    {
        getSymbolComponent(components).set(
            addressToEntity(address(this)), symbol_
        );
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        uint256 token,
        uint256 from,
        uint256 to,
        uint256 amount
    ) internal {
        IECS20Hooks(entityToAddress(token)).beforeTokenTransfer(
            from, to, amount
        );
    }

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        uint256 token,
        uint256 from,
        uint256 to,
        uint256 amount
    ) internal {
        IECS20Hooks(entityToAddress(token)).afterTokenTransfer(from, to, amount);
    }

    function _afterApproval(
        uint256 token,
        uint256 owner,
        uint256 spender,
        uint256 amount
    ) internal {
        IECS20Hooks(entityToAddress(token)).afterApproval(
            owner, spender, amount
        );
    }

    function thisEntity() internal view returns (uint256) {
        return addressToEntity(address(this));
    }
}
