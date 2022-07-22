// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IFightPunks.sol";

contract FightPunksToken is ERC20, Ownable {
    //instance of fightpunk nft
    IFightPunks fightPunksNFT;

    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdClaimed;

    // Price of one Funky punk token
    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give the user 10 tokens
    // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
    // is actually equal to (10 ^ -18) tokens.
    // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    uint256 public constant tokensPerNFT = 10 * 10**18;

    // the max total supply is 10000 for Fight punks Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    constructor(address _fightpunksContract) ERC20("Fight Punk Token", "FP") {
        fightPunksNFT = IFightPunks(_fightpunksContract);
    }

    /**
     * @dev Mints `amount` number of FightPunk Tokens
     * Requirements:
     * - `msg.value` should be equal or greater than the tokenPrice * amount
     */
    function mint(uint256 amount) public payable {
        uint256 requiredAmount = tokenPrice * amount;
        require(msg.value >= requiredAmount, "Ether sent is incorrect");
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            totalSupply() + amountWithDecimals <= maxTotalSupply,
            "Exceed the maximum supply available"
        );
        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /**
     * @dev Mints tokens based on the number of NFT's held by the sender
     * Requirements:
     * balance of Fight punk NFT's owned by the sender should be greater than 0
     * Tokens should have not been claimed for all the NFTs owned by the sender
     */
    function claim() public {
        address sender = msg.sender;

        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;

        //get the number of fight punk nft owned by the address
        uint256 balance = fightPunksNFT.balanceOf(sender);

        // If the balance is zero, revert the transaction
        require(balance > 0, "You do not have any Fight punk NFT");

        // loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = fightPunksNFT.tokenOfOwnerByIndex(sender, i);

            // if the tokenId has not been claimed, increase the amount
            if (!tokenIdClaimed[tokenId]) {
                amount += 1;
                tokenIdClaimed[tokenId] = true;
            }
        }
        // If all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have claimed all the tokens");

        // call the internal function from Openzeppelin's ERC20 contract
        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /**
     * @dev withdraws all ETH and tokens sent to the contract
     * Requirements:
     * wallet connected must be owner's address
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
