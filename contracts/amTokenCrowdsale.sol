pragma solidity^0.4.19;


contract token { function transfer(address receiver, uint amount) public ;
                 function mintToken(address target, uint mintedAmount) public ;
                }

contract CrowdSale {
    enum State {
        Fundraising,
        Successful,
        Closed
    }
    State public state = State.Fundraising;

    struct Contribution {
        uint amount;
        address contributor;
    }
    Contribution[] contributions;

    
    
    uint public totalRaised;
    uint public currentBalance;
    uint public deadline;
    uint public completedAt;
    uint public priceInWei;
    uint public fundingMinimumTargetInWei; 
    uint public fundingMaximumTargetInWei; 
    token public tokenReward;
    address public creator;
    address public beneficiary; 
    string campaignUrl;
    byte constant version = "1";

    
    event LogFundingReceived(address addr, uint amount, uint currentTotal);
    event LogWinnerPaid(address winnerAddress);
    event LogFundingSuccessful(uint totalRaised);
    event LogFunderInitialized(
        address creator,
        address beneficiary,
        string url,
        uint _fundingMaximumTargetInEther, 
        uint256 deadline);


    modifier inState(State _state) {
        require(state == _state) ;
        _;
    }

     modifier isMinimum() {
        require(msg.value > priceInWei) ;
        _;
    }

    modifier inMultipleOfPrice() {
        require(msg.value%priceInWei == 0) ;
        _;
    }

    modifier isCreator() {
        require(msg.sender == creator) ;
        _;
    }

    
    modifier atEndOfLifecycle() {
        if(!((state == State.Successful) && completedAt + 1 hours < now)) {
            revert();
        }
        _;
    }

    
    function CrowdSale(
        uint _timeInMinutesForFundraising,
        string _campaignUrl,
        address _ifSuccessfulSendTo,
        uint _fundingMinimumTargetInEther,
        uint _fundingMaximumTargetInEther,
        token _addressOfTokenUsedAsReward,
        uint _etherCostOfEachToken) public
    {
        creator = msg.sender;
        beneficiary = _ifSuccessfulSendTo;
        campaignUrl = _campaignUrl;
        fundingMinimumTargetInWei = _fundingMinimumTargetInEther * 1 ether; 
        fundingMaximumTargetInWei = _fundingMaximumTargetInEther * 1 ether; 
        deadline = now + (_timeInMinutesForFundraising * 1 minutes);
        currentBalance = 0;
        tokenReward = token(_addressOfTokenUsedAsReward);
        priceInWei = _etherCostOfEachToken * 1 ether;
        LogFunderInitialized(
            creator,
            beneficiary,
            campaignUrl,
            fundingMaximumTargetInWei,
            deadline);
    }

    function contribute()
    public
    inState(State.Fundraising) isMinimum() inMultipleOfPrice() payable returns (uint256)
    {
        uint256 amountInWei = msg.value;

        
        contributions.push(
            Contribution({
                amount: msg.value,
                contributor: msg.sender
                }) 
            );

        totalRaised += msg.value;
        currentBalance = totalRaised;


        if(fundingMaximumTargetInWei != 0){
            
            tokenReward.transfer(msg.sender, amountInWei / priceInWei);
        }
        else{
            tokenReward.mintToken(msg.sender, amountInWei / priceInWei);
        }

        LogFundingReceived(msg.sender, msg.value, totalRaised);

        

        return contributions.length - 1; 
    }

    
    

        function payOut()
        public
        inState(State.Successful)
        {
            
            if(!beneficiary.send(this.balance)) {
                revert();
            }

            state = State.Closed;
            currentBalance = 0;
            LogWinnerPaid(beneficiary);
        }

        

        function removeContract()
        public
        isCreator()
        atEndOfLifecycle()
        {
            selfdestruct(msg.sender);
            
        }

        function () public { revert(); }
}
