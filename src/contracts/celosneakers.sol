// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CeloSneaker {
    uint256 private sneakersLength = 0;
    address private cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    /// @dev Feedback structure when returning sneakers
    /// @param owner is the feedback's creator
    /// @param feedbackDescription is the description of the feedback
    /// @param repaid is the status of whether the feedback has been refunded
    /// @param amountReturned is the amount of sneakers returned, it is also used to to calculate the amount of funds to return
    struct Feedback {
        address owner;
        string feedbackDescription;
        bool repaid;
        uint256 amountReturned;
    }

    /// @dev Structure of a sneaker
    /// @param returnedFeedback stores the feedbacks of a Sneaker
    /// @param userBought keeps tracks of the amount of sneakers a user has bought
    struct Sneaker {
        address payable owner;
        string image;
        string brand;
        string description;
        uint256 price;
        uint256 availableSneakers;
        uint256 sneakersReturned;
        uint256 sneakersSold;
        mapping(uint256 => Feedback) returnedFeedback;
        // mapping(uint256 => address) feedbackOwner;
        mapping(address => uint256) userBought;
    }

    mapping(uint256 => Sneaker) private sneakers;

    /// @dev keeps track of sneaker's id that exists
    mapping(uint256 => bool) public exist;

    modifier exists(uint256 _index) {
        require(exist[_index], "Sneaker doesn't exist");
        _;
    }

    /// @dev checks if caller can buy sneaker having id of _index
    modifier isValidCustomer(uint256 _index) {
        require(
            msg.sender != sneakers[_index].owner,
            "Owner cannot return sneaker"
        );
        _;
    }
    /// @dev checks if caller is the owner of sneaker having id of _index
    modifier isOwner(uint256 _index) {
        require(msg.sender == sneakers[_index].owner, "Not owner");
        _;
    }

    /// @dev checks if there is enough sneakers available for purchase
    modifier inStock(uint256 _index, uint256 _amount) {
        require(
            _amount <= sneakers[_index].availableSneakers,
            "Out of stock or not enough sneakers in stock"
        );
        _;
    }

    event Deleted(uint index);
    event SneakerReturned(uint index, uint amount, address customer);
    event Repaid(uint index, uint feedbackId, address customer);
    event Restocked(uint _index, uint inStock);

    /// @dev this function will implement and add a new sneaker to the sneakers mapping
    /// @param _availableSneakers is the number of sneakers available in stock
    function addSneaker(
        string memory _image,
        string memory _brand,
        string memory _description,
        uint256 _price,
        uint256 _availableSneakers
    ) public {
        require(bytes(_image).length > 0, "Invalid image url");
        require(bytes(_brand).length > 0, "Empty brand name");
        require(bytes(_description).length > 0, "Invalid description");
        require(_availableSneakers > 0, "Availability has to be at least one");
        require(_price > 0, "Invalid price");
        Sneaker storage newSneaker = sneakers[sneakersLength];
        exist[sneakersLength] = true;
        sneakersLength++;
        newSneaker.owner = payable(msg.sender);
        newSneaker.image = _image;
        newSneaker.brand = _brand;
        newSneaker.description = _description;
        newSneaker.price = _price;
        newSneaker.availableSneakers = _availableSneakers;
    }

    /// @dev get sneaker from the mapping
    function getSneaker(uint256 _index)
        public
        view
        returns (
            address payable owner,
            string memory image,
            string memory brand,
            string memory description,
            uint256 price,
            uint256 availableSneakers,
            uint256 sneakersReturned,
            uint256 sneakersSold
        )
    {
        owner = sneakers[_index].owner;
        image = sneakers[_index].image;
        brand = sneakers[_index].brand;
        description = sneakers[_index].description;
        price = sneakers[_index].price;
        availableSneakers = sneakers[_index].availableSneakers;
        sneakersReturned = sneakers[_index].sneakersReturned;
        sneakersSold = sneakers[_index].sneakersSold;
    }

    /// @dev returns all the returned feedbacks of a sneaker
    function getSneakerFeedbacks(uint256 _index)
        public
        view
        exists(_index)
        returns (Feedback[] memory)
    {
        uint256 id = sneakers[_index].sneakersReturned;
        Feedback[] memory allFeedbacks = new Feedback[](id);
        for (uint256 i = 0; i < id; i++) {
            allFeedbacks[i] = sneakers[_index].returnedFeedback[i];
        }
        return allFeedbacks;
    }

    /// @dev this function will delete a sneaker with id of _index from the mapping
    function deleteSneaker(uint256 _index)
        external
        exists(_index)
        isOwner(_index)
    {
        // ensures user has paid back returning sneakers first before they can delete to prevent scams
        require(sneakers[_index].sneakersReturned == 0, "You have to pay back any due repayment first");
        delete sneakers[_index];
        exist[_index] = false;
        emit Deleted(_index);
    }

    /// @dev allows a valid customer to return bought sneaker/sneakers
    /// @param _feedback is the reason for returning the sneaker/s
    /// @param _amount is the number of sneakers returned
    /// @notice resets hasn't been made in number of stock, as seller has to pay back the buyer first
    function returnSneaker(
        uint256 _index,
        string memory _feedback,
        uint256 _amount
    ) external isValidCustomer(_index) {
        require(
            sneakers[_index].userBought[msg.sender] > 0,
            "You haven't bought any sneakers"
        );
        require(
            _amount > 0 && sneakers[_index].userBought[msg.sender] >= _amount,
            "Invalid amount"
        );
        bool repaid = false;
        uint256 id = sneakers[_index].sneakersReturned;
        sneakers[_index].sneakersReturned++;
        sneakers[_index].returnedFeedback[id] = Feedback(
            msg.sender,
            _feedback,
            repaid,
            _amount
        );
        sneakers[_index].userBought[msg.sender] -= _amount;
        emit SneakerReturned(_index, _amount, msg.sender);
    }

    /// @dev allows the sneaker owner to pay back a customer his due repayment
    /// @param feedbackId is the index of the feedback in returnedFeedbacks
    function repayBuyer(uint256 _index, uint256 feedbackId)
        public
        payable
        exists(_index)
        isOwner(_index)
    {
        // checks if feedback hasn't been paid yet
        require(
            !sneakers[_index].returnedFeedback[feedbackId].repaid &&
                sneakers[_index].returnedFeedback[feedbackId].amountReturned >
                0,
            "Already repaid"
        );

        Feedback storage currentFeedback = sneakers[_index].returnedFeedback[
            feedbackId
        ];
        // resets are made to reduce the risk of reentrancy attacks
        uint amount = currentFeedback.amountReturned * sneakers[_index].price; // repaid amount
        sneakers[_index].sneakersReturned -= currentFeedback.amountReturned;
        sneakers[_index].availableSneakers += currentFeedback.amountReturned;
        currentFeedback.amountReturned = 0;
        currentFeedback.repaid = true;
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                currentFeedback.owner,
                amount
            ),
            "Transfer failed."
        );
        
        
        emit Repaid(_index, feedbackId, msg.sender);
    }

    /// @dev allows a valid customer to buy a sneaker
    /// @notice one is hardcoded as param for inStock since you can only buy one sneaker with this function
    function buySneaker(uint256 _index)
        public
        payable
        exists(_index)
        isValidCustomer(_index)
        inStock(_index, 1)
    {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                sneakers[_index].owner,
                sneakers[_index].price
            ),
            "Transfer failed."
        );
        sneakers[_index].userBought[msg.sender]++;
        sneakers[_index].sneakersSold++;
        sneakers[_index].availableSneakers--;
    }

    /// @dev allows a valid customer to buy several amount of a sneaker
    /// @param _amount the number of sneakers the buyer wants
    /// @notice that the price charged is calculated first in totalPrice
    function buyManySneaker(uint256 _index, uint256 _amount)
        external
        payable
        exists(_index)
        isValidCustomer(_index)
        inStock(_index, _amount)
    {
        require(_amount >= 2, "Amount has to be equal or greater than two");
        uint256 totalPrice = _amount * sneakers[_index].price;
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                sneakers[_index].owner,
                totalPrice
            ),
            "Transfer failed."
        );
        sneakers[_index].userBought[msg.sender] += _amount;
        sneakers[_index].sneakersSold += _amount;
        sneakers[_index].availableSneakers -= _amount;
    }

    /// @dev allows a seller to update the stock of a sneaker
    function reStock(uint256 _index, uint _amount)
        external
        exists(_index)
        isOwner(_index)
    {
        require(_amount > 0, "Invalid restocking amount");
        sneakers[_index].availableSneakers += _amount;
    }

    /// @dev gets the length of all sneakers in the mapping
    function getsneakersLength() public view returns (uint256) {
        return (sneakersLength);
    }
}
