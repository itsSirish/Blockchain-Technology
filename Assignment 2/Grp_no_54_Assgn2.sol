// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract Purchase {
    uint public Cost;
    //seller in this case could be abc.com or xyz.com
    //seller is the person who deploys the smart contract on a product
    //address type variable to store value of sellers address
    //seller locks in twice the cost of item to be sold
    address payable public seller;
    //address type variable to store value of buyers address
    //buyer also locks in twice the cost of item to be sold
    address payable public buyer;

    //we are assuming 4 states of a contract with the enum function.
    //Created - contract enters this state when seller deploys the contract.
    //Locked - contract enters the state when buyer puts in a value equal to twice the cost.
    //Release - contract enters this state when buyer confirms that he received the product.
    //Inactive - contract enters this state when seller is refunded and given the extra paid by buyer.
    enum State { Created, Locked, Release, Inactive }
    State public state;

    //errors for different cases.

    /// Only the buyer can call this function.
    error OnlyBuyer();
    /// Only the seller can call this function.
    error OnlySeller();
    /// The function cannot be called at the current state.
    error InvalidState();
    /// The provided Cost has to be even.
    error CostNotEven();

    //Below are modifiers for different code segments used in functions.
    
    modifier onlyBuyer() {
        if (msg.sender != buyer)
            revert OnlyBuyer();
        _;
    }

    modifier condition(bool condition_) {
        require(condition_);
        _;
    }

    modifier onlySeller() {
        if (msg.sender != seller)
            revert OnlySeller();
        _;
    }

    modifier inState(State state_) {
        if (state != state_)
            revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    constructor() payable {
        seller = payable(msg.sender);
        Cost = msg.value / 2;
        if ((2 * Cost) != msg.value)
            revert CostNotEven();
    }

    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    function Cancel()
        external
        onlySeller
        inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
        // We use transfer here directly. It is reentrancy-safe, because it is the
        // Because it is the last call in this function and we already changed the state.
        seller.transfer(address(this).balance);
    }

    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * Cost` ether.
    /// The ether will be locked until confirmReceived is called.

    function confirmPurchase()
        external
        inState(State.Created)
        condition(msg.value == (2 * Cost))
        payable
    {
        emit PurchaseConfirmed();
        buyer = payable(msg.sender);
        state = State.Locked;
    }

    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    function confirmReceived()
        external
        onlyBuyer
        inState(State.Locked)
    {
        emit ItemReceived();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Release;

        buyer.transfer(Cost);
    }

    /// This function refunds the seller, i.e.
    /// pays back the locked funds of the seller.
    function refundSeller()
        external
        onlySeller
        inState(State.Release)
    {
        emit SellerRefunded();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Inactive;

        seller.transfer(3 * Cost);
    }
}