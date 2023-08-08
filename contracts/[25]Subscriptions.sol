// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

// a merchant can create a plan for a subscription
// a user can subscribe to the plan and pay according to the plan frequency
// a subscription can also be cancelled
// the pay function manages if the user doesn't pay in frequency, the he's charged according to the new duration

contract Subscriptions {
    IERC20 token;
    // each plan has a different id
    uint public nextPlanId;

    struct Plan {
        address merchant;
        uint amount;
        uint frequency;
    }

    struct Subscription {
        address subscriber;
        uint startedAt;
        uint nextPayment;
    }

    // mapping of plan id to plan
    mapping(uint => Plan) public plans;
    // address of subscriber to id to subscription
    mapping(address => mapping(uint => Subscription)) public subscriptions;

    event PlanCreated(address merchant, uint planId, uint date);
    event SubscriptionCreated(address subscriber, uint planId, uint date);
    event SubscriptionCancelled(address subscriber, uint planId, uint date);
    event PaymentSent(
        address from,
        address to,
        uint amount,
        uint planId,
        uint date
    );

    function createPlan(uint _amount, uint _frequency) external {
        require(_amount > 0, "amount can't be 0");
        require(_frequency > 0, "frequency can't be 0");

        plans[nextPlanId] = Plan(msg.sender, _amount, _frequency);
        nextPlanId++;
    }

    function subscribe(uint planId) external {
        Plan storage plan = plans[planId];
        require(plan.merchant != address(0), "this plan does not exist");

        token.transferFrom(msg.sender, plan.merchant, plan.amount);
        emit PaymentSent(
            msg.sender,
            plan.merchant,
            plan.amount,
            planId,
            block.timestamp
        );

        subscriptions[msg.sender][planId] = Subscription(
            msg.sender,
            block.timestamp,
            block.timestamp + plan.frequency
        );
        emit SubscriptionCreated(msg.sender, planId, block.timestamp);
    }

    function cancel(uint planId) external {
        Subscription storage subscription = subscriptions[msg.sender][planId];
        require(
            subscription.subscriber != address(0),
            "this subscription does not exist"
        );
        delete subscriptions[msg.sender][planId];
        emit SubscriptionCancelled(msg.sender, planId, block.timestamp);
    }

    function pay(uint planId) external {
        Subscription storage subscription = subscriptions[subscriber][planId];
        Plan storage plan = plans[planId];

        require(
            subscription.subscriber != address(0),
            "this subscription does not exist"
        );
        require(block.timestamp > subscription.nextPayment, "not due yet");

        token.transferFrom(subscriber, plan.merchant, plan.amount);

        emit PaymentSent(
            subscriber,
            plan.merchant,
            plan.amount,
            planId,
            block.timestamp
        );
        subscription.nextPayment = subscription.nextPayment + plan.frequency;
    }
}
