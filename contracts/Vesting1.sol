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

    uint256 private totalToken;

    uint256 private immutable Advisor = 4;
    uint256 private immutable Partner = 10;
    uint256 private immutable Mentor = 20;

    uint256 private cliffTime = 60 ;
    uint256 private vestingDuration = 305 ;
    uint256 private _start;
    uint256 private _cliff;
    uint256 private _vestingDuration;
    bool isVested;

    uint256 constant deno = 100;

    uint256 public totalAdvisor;
    uint256 public totalPartner;
    uint256 public totalMentor;
    
    // tokenperRole
    uint256 public totalPerAdvisor;
    uint256 public totalPerPartner;
    uint256 public totalPerMentor;

    enum Roles {Advisor, Partner, Mentor}
    Roles public role;

    mapping(Roles => uint) public totalBenificiaryByRoles;

    struct Benificiary{
        address benificiary;
        bool isBenificiary;
        uint256 tokenClaimed;
        uint256 role;
    }

    mapping(address => Benificiary) private benificiaries;

    event benificiaryData(
        address indexed addr,
        uint256 role,
        uint256 time
    );

    constructor(IERC20 _token)
    {
        require(cliffTime < vestingDuration, "cliff cannot be longer than current time");
        require(vestingDuration > 0 , "vesting duration should be greater than 0 days");
        token = IERC20(_token);
        //vestingDuration;
        //_cliff = start.add(cliffTime);
        //_start = start;
    }   
    event delBenificiaryData(
        address indexed addr,
        Roles role
    );

    event vestingStarted(uint256 indexed time);

    

    function startvesting() external onlyOwner{
        require(isVested == false,"Vesting already started");
        totalToken = token.balanceOf(address(this));
        isVested = true;
        _start = block.timestamp;
        calculateToken();
        emit vestingStarted(block.timestamp);

    }

    function calculateToken() private {
        totalPerAdvisor = (totalToken* Advisor)/(deno * totalAdvisor);
        totalPerPartner = (totalToken* Partner)/(deno * totalPartner);
        totalPerMentor = (totalToken* Mentor)/(deno * totalMentor);
    }

    function AddBenificiary(address _addr, uint256 _role) external onlyOwner{
        require(benificiaries[_addr].isBenificiary == false, "Already a benificiray");
        require(_addr != address(0), "benificiary cannot be zero address");
        require(_role < 3, "roles cannot be more than 3");
        benificiaries[_addr].isBenificiary = true;
        benificiaries[_addr].role = _role;
        if(_role == 0){
            totalAdvisor++;
        }
        else if(_role == 1){
            totalPartner++;
        }
        else {
            totalMentor++;
        }
        emit benificiaryData(_addr, _role, block.timestamp);
    }

    function trackToken() private view returns(uint256) {
        
        uint256 roleStatus = benificiaries[msg.sender].role;
        //uint256 tokenAvailable;
        uint256 claimToken = benificiaries[msg.sender].tokenClaimed;
        //uint256 timeStatus = block.timestamp - _start - _cliff;

        if(roleStatus == 0){
            return ((totalPerAdvisor - claimToken) * (block.timestamp - _start - cliffTime))/ (vestingDuration);
        }
        else if(roleStatus == 1){
            return ((totalPerPartner - claimToken) * (block.timestamp - _start - cliffTime))/ (vestingDuration);
        }
        else {
            return ((totalPerMentor - claimToken) * (block.timestamp - _start - cliffTime))/ (vestingDuration);
        }

    }

    function claimTokens() external vestingPhase {
        require(benificiaries[msg.sender].isBenificiary == true, "you are not benificiary");
        //require(block.timestamp >= cliffTime + _start, "vesting is under cliff period");
        uint256 roleStatus = benificiaries[msg.sender].role;
        uint256 claimToken = benificiaries[msg.sender].tokenClaimed;

        if(roleStatus == 0){
            require(claimToken <= totalPerAdvisor, "you have claimed all token");
        }
        else if(roleStatus == 1){
            require(claimToken <= totalPerPartner, "you have claimed all token");
        }
        else {
            require(claimToken <= totalPerMentor, "you have claimed all token");
        }

        uint256 collectToken = trackToken();
        benificiaries[msg.sender].tokenClaimed += collectToken;

        token.safeTransfer(msg.sender, collectToken);
    }

    modifier vestingPhase{
        require(isVested == true,"vesting not started");
        require(block.timestamp >= cliffTime + _start, "vesting is under cliff period");
        _;
    }

    function contractTokenBalance() external view onlyOwner returns(uint256){
        return token.balanceOf(address(this));
    }

    function tokensClaimedBy(address _addr) external view onlyOwner returns(uint256) {
        return benificiaries[_addr].tokenClaimed;
    }

    



} 