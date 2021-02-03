pragma solidity ^0.5.16;

/**
 * @title New Hall Of Fame
 */
contract NHOF {
    string public constant name = "New Hall Of Fame";
    string public constant symbol = "NHOF";
    uint8 public constant decimals = 8;
    uint96 public constant totalSupply = 1_000_000_000e8;
	address public owner;
	uint internal code;
	
	struct Seat {
        string name;
        address owner;
        uint code;
        string info;
    }

    /* This creates an array with all balances */
    mapping (address => uint96) internal balances;
    /* This creates an array with all seats */
    mapping (uint => Seat) internal seats;
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor () public {
        balances[msg.sender] = totalSupply;// Give the creator all initial tokens
		owner = msg.sender;
		code = 0;
		seats[0] = Seat("Pangu", owner, 0, "Pangu breaks the ground.");
    }
    /**
     * @notice Change the owner address  inducted into Hall of Fame
     * @param _owner The address of the new owner
     */
    function setMinter(address _owner) external {
        require(msg.sender == owner, "NHOF::setMinter: only the owner can change the owneraddress");
        owner = _owner;
    }
    
    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint96 amount) external returns (bool) {
        amount = safe96(amount, "NHOF::transfer: amount exceeds 96 bits");
        require(amount > 0, "amount must be greater than 0.");
        require(balances[msg.sender] > amount, "sender has not enough balance."); // Check if the sender has enough
        _transferTokens(msg.sender, dst, amount);
        return true;
    }
    
    function inductedIntoHOF(string calldata _name, string calldata _info) external returns(uint) {
        require(bytes(_name).length <= 64, "_name byte length cannot be greater than 64.");
        require(bytes(_info).length <= 256, "_info byte length cannot be greater than 256.");
        require(getAvailableSeats() > 0, "HOF has not enough seat.");
        uint96 fee = 1e8;
        require(balances[msg.sender] >= fee, "sender has not enough balance.");
        code = code + 1;
        seats[code] = Seat(_name, msg.sender, code, _info);
        balances[msg.sender] = sub96(balances[msg.sender], fee, "NHOF::inductedIntoHOF: transfer amount exceeds balance");
        return code;
    }
    
    function changeSeatInfoByCode(uint _code, string calldata _name, string calldata _info) external returns(bool) {
        require(bytes(_name).length <= 64, "_name byte length cannot be greater than 64.");
        require(bytes(_info).length <= 256, "_info byte length cannot be greater than 256.");
        Seat memory s = seats[_code];
        require(s.owner == msg.sender, "Insufficient permissions.");
        seats[_code].name = _name;
        seats[_code].info = _info;
        return true;
    }
    
    function changeSeatOwnerByCode(uint _code, address _owner) external returns(bool) {
        Seat memory s = seats[_code];
        require(s.owner == msg.sender, "Insufficient permissions.");
        seats[_code].owner = _owner;
        return true;
    }
    
    function getSeatByCode(uint _code) external view returns (string memory _name, string memory _info, address _owner) {
        Seat memory s = seats[_code];
        _name = s.name;
        _info = s.info;
        _owner = s.owner;
    }
    
    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }
    
    function getAvailableSeats() public view returns (uint) {
        uint totalSeats = _getTotalSeats();
        uint availableSeats = totalSeats - code;
        return availableSeats;
    }
    
    function _transferTokens(address src, address dst, uint96 amount) internal {
        require(src != address(0), "NHOF::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "NHOF::_transferTokens: cannot transfer to the zero address");

        balances[src] = sub96(balances[src], amount, "NHOF::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "NHOF::_transferTokens: transfer amount overflows");

    }
    
    function _getTotalSeats() internal view returns (uint) {
        return block.number / 5;
    }
    
    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }
}