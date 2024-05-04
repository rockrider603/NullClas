// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract crowdtank{
    //struct used to store all project details
    address public admin; // Admin address
    constructor() {
        admin = msg.sender;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    struct Project{
        //contains all the details of the person who wants to raise funds.
        address creator;
        string name;
        string description;
        //uint only stores the positive integers
        uint FundingGoal;
        uint deadline;
        uint amountraised;
        bool projectfunded;
        uint Commission;
    }
    //used to map the values to each detail of the project
    // unit refers to the project id.
    uint Commissions=0;
    mapping(uint => Project ) public project;
    mapping(uint => mapping(address=> uint)) public Contributor;
    // this mapping is used to store each contributors details 
    // first uint is for project id, then address is for the user address and last uint is for the amount of money.
    mapping(uint => mapping( address => uint)) public ContributorsContribution;
    //this mapping is done to check whether the given id is used 
    mapping(uint => bool) public isIDUsed;
    //event created when some action is done
    event ProjectCreated(uint indexed ProjectId, address indexed creator, string name,string description,uint FundingGoal,uint deadline);
    event ProjectFunded(uint indexed ProjectId, address indexed contributor, uint amount );
    // the withdrawer type is for finding out whether the contributor or the creator has withdrawn
    event Withdrawal(uint indexed ProjectId, address indexed withdrawer, uint amount, string withdrawertype);
    function CreateProject(string memory _name , string memory _description, uint256 _fundinggoal, uint _durationSeconds, uint _id) external {
    require(!isIDUsed[_id], "Project Id is already used");
    isIDUsed[_id]=true;
    project[_id]=Project({
        creator: msg.sender,
        name: _name,
        description: _description,
        FundingGoal: _fundinggoal,
        deadline: block.timestamp + _durationSeconds,
        amountraised:0,
        projectfunded: false,
        Commission:0
        });
    emit ProjectCreated(_id, msg.sender, _name, _description, _fundinggoal,block.timestamp+ _durationSeconds );
    
}
    
    function ContributorWithDrawFund(uint ProjectId) external payable{
        Project storage project=project[ProjectId];
        require(project.amountraised<= project.FundingGoal, "Full funding reached, User can't withdraw");
        require(block.timestamp<= project.deadline, "Deadline is reached, can't withdraw");
        uint fundsgiven= ContributorsContribution[ProjectId][msg.sender];
        require(fundsgiven>0,"Must send some value of Ether");
        project.amountraised -= fundsgiven;
        payable(msg.sender).transfer(fundsgiven);   
}
    function CreatorWithDrawFunds(uint ProjectId) external payable{
        Project storage project=project[ProjectId];
        uint TotalFundingRaised=project.amountraised;
        require(project.projectfunded, "Project Not funded fully");
        //only creator should be able to call this method
        require( project.creator==msg.sender, "Only Creator can withdraw money");
        require(block.timestamp>= project.deadline, "Deadline not yet reached");
        payable(msg.sender).transfer(TotalFundingRaised);

    }
    function fundProject(uint projectId) external payable {
        Project storage project=project[projectId];
        require(msg.value > 0, "Must send some value of ether");
        require(project.deadline > block.timestamp, "Project deadline has passed");
        
        uint256 scalingFactor = 100; // Choose a scaling factor (e.g., 100 for two decimal places)
        project.Commission += (5 * Contributor[projectId][msg.sender])/scalingFactor;
        Commissions+=project.Commission;
        uint256 Contribution = (95 * Contributor[projectId][msg.sender]) / scalingFactor;
        project.amountraised+=Contribution;
        if (project.amountraised< project.FundingGoal){
            
            payable(project.creator).transfer(Contribution);


        }
        if (project.amountraised>= project.FundingGoal){
            project.projectfunded=true;
        }
        if(project.projectfunded==true){
            uint256 extrafundsgiven= (project.amountraised)-project.FundingGoal;
            payable(project.creator).transfer(Contribution-extrafundsgiven);
            payable(msg.sender).transfer(extrafundsgiven);
            
        }
    }
    function HowMuchFundsRequired(uint projectId) external view returns(uint){
        Project storage project=project[projectId];
        require(project.amountraised<=project.FundingGoal,"0");
        uint MoneyRemaining=(project.FundingGoal)-(project.amountraised);
        return (MoneyRemaining);
    }
    function AdminCollectCommission() external payable onlyAdmin{
        require(Commissions>0,"No commission collected till now.");
        payable(admin).transfer(Commissions);
        Commissions=0;
    }
    function ViewTotalCommission(uint projectId) external view returns(uint){
        return Commissions;
    }
    


    }

