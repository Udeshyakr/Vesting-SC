// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Vesting is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 private token;

    uint256 private totalTokenVested;
    uint256 private cliffDuration;
    uint256 private vestingTime;
    uint256 public vestingStartTime;
    bool isVestingStarted;
    uint constant deno = 100;

    uint256 public totalAdvisors;
    uint256 public totalPartner;
    uint256 public totalMentors;

    // // per individual token
    // uint256 public tokenPerAdvisor;
    // uint256 public tokenPerPartner;
    // uint256 public totalPerMentors;

    enum Roles {Advisor, Partner, Mentors}
    Roles public role;
    mapping(Roles => uint) private percentTokenForRole;
    mapping(Roles => uint) private tokenPerBenificiary;
    mapping(Roles => uint) private totalBenificiaryForRole;
    
    struct Benificiary{
        Roles role;
        bool isBenificiary;
        address benificiary;
        uint256 totalTokenClaimed;
    }
    mapping(address => Benificiary) private benificiaries;
     
    event benificiaryData(
        address indexed addr,
        Roles role,
        uint256 time
    );

    constructor(
        IERC20 _token,
        // 2
        uint256 _tokenForAdvisor,
        uint256 _tokenForPartner,
        uint256 _tokenForMentors
    )
    {
        token = IERC20(_token);
        // cliffDuration = _cliffDuration;
        // vestingTime = _vestingDuration;
        percentTokenForRole[Roles.Advisor] = _tokenForAdvisor;
        percentTokenForRole[Roles.Partner] = _tokenForPartner;
        percentTokenForRole[Roles.Mentors] = _tokenForMentors;
        // totalTokenVested = _tokenForAdvisor + _tokenForMentors + _tokenForPartner;
    }

    event delBenificiaryData(
        address indexed addr,
        uint256 indexed role
    );

    function startvesting() external onlyOwner{
        require(!isVestingStarted,"Vesting already started");
        totalTokenVested = token.balanceOf(address(this));
        isVestingStarted = true;
        vestingStartTime = block.timestamp;
        calculateToken();

    }

    function calculateToken() public{
        uint advisor = (totalTokenVested * percentTokenForRole[Roles.Advisor]) / deno;
        uint partner = (totalTokenVested * percentTokenForRole[Roles.Partner]) / deno;
        uint mentor = (totalTokenVested * percentTokenForRole[Roles.Mentors]) / deno;
        if(totalAdvisors > 0){
            tokenPerBenificiary[Roles.Advisor] = advisor/totalAdvisors;
        }
        else if(totalAdvisors > 0){
            tokenPerBenificiary[Roles.Partner] = partner/ totalPartner;
        }
        else{
            tokenPerBenificiary[Roles.Mentors] = mentor/ totalMentors;
        }


    }

    function addBenificiary(address _addr, Roles _role) public {
        require(benificiaries[_addr].isBenificiary != true, "you are already a benificiary");
        require(_addr != address(0),"benificiary cannot be zero address");
        benificiaries[_addr].isBenificiary = true;
        benificiaries[_addr].role = _role;
        //totalBenificiaryForRole[_role] += 1;
    
        emit benificiaryData(_addr, _role, block.timestamp);
        if(Roles(benificiaries[_addr].role) == Roles.Advisor){
            totalBenificiaryForRole[_role] += 1;
        }
        else if(Roles(benificiaries[_addr].role) == Roles.Partner){
            totalBenificiaryForRole[_role] += 1;
        }
        else
        {
            totalBenificiaryForRole[_role] += 1;
        }
    }




} 