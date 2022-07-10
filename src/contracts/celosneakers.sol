// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CeloSneaker {
    uint internal sneakersLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;


     struct Feedback {
         uint Id;
         address payable owner;
        string feedbackDescription;
    }

    struct Sneaker{
        address payable owner;
        string image;
        string brand;
        string description;
        uint price;
        uint availableSneakers;
        uint sneakersReturned;
        uint sneakersSold;
    }

     mapping (uint => Sneaker) internal sneakers;
     mapping (uint => Feedback[]) internal feedbacksmapping;


// this function will implement and add a new sneaker to the sneakers mapping
    function addSneaker(
        string memory _image,
        string memory _brand,
        string memory _description,
        uint _price,
        uint _availableSneakers
    ) public {
        uint _sneakersReturned = 0;
         uint _sneakersSold = 0;
        sneakers[sneakersLength] = Sneaker(
            payable(msg.sender),
            _image,
            _brand,
            _description,
            _price,
            _availableSneakers,
            _sneakersReturned,
            _sneakersSold
        );
        sneakersLength++;
    }


    // get sneaker from the mapping
    function getSneaker(uint _index) public view returns (
        address payable, 
        string memory, 
        string memory,      
        string memory, 
        uint,
        uint,
        uint,
        uint,
        Feedback[] memory
    ) {
        Sneaker memory s = sneakers[_index];
        Feedback[] memory feedbacks = feedbacksmapping[_index];
        return (
            s.owner,
            s.image,
            s.brand,
            s.description,
            s.price,
            s.availableSneakers,
            s.sneakersReturned,
            s.sneakersSold,
            feedbacks
        );
    }

     // this function will delete a sneaker from the mapping
        function deleteSneaker(uint _index) external {
	        require(msg.sender == sneakers[_index].owner, "can't delete sneaker, not the owner");         
            sneakers[_index] = sneakers[sneakersLength - 1];
            delete sneakers[sneakersLength - 1];
            sneakersLength--; 
	 }


// returning a sneaker
    function returnSneaker(uint _index, string memory _feedback) public{
        require(msg.sender != sneakers[_index].owner, "Owner cannot return sneaker");
        feedbacksmapping[_index].push(Feedback(_index, payable(address(msg.sender)), _feedback));
     sneakers[_index].sneakersReturned++;
    }


    

    //pay back sneaker returnee
    function repayBuyer(uint _index, address payable _address) public payable  {
        require(msg.sender == sneakers[_index].owner, "Not owner");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            payable (_address),
            sneakers[_index].price
          ),
          "Transfer failed."
        );
    }

       //buying a sneaker
    function buySneaker(uint _index) public payable  {
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
             msg.sender,
             sneakers[_index].owner,
             sneakers[_index].price
          ),
          "Transfer failed."
        );
        sneakers[_index].sneakersSold++;
    }

    
    // to get the length of all sneakers in the mapping
    function getsneakersLength() public view returns (uint) {
        return (sneakersLength);
    }
}