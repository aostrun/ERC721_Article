pragma solidity ^0.4.21;

// https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721BasicToken.sol

class Cryptomon is ERC721{

    enum RarityEnum {Common, Rare, Epic, Legendary}
    enum CryptomonTypeEnum {Fire, Wind, Electricity, Earth, Magic}
    struct Cryptomon{
      string name;
      RarityEnum rarity;
      CryptomonTypeEnum type;
      string attack1;
      string attack2;
      uint8 strength;
    }


    /*
      Array that keeps all tokens created in this contract
    */
    uint256[] internal allTokens;

    /*
      Mapping from user address to array of tokenIDs
      Store tokends that user owns
    */
    mapping(address => uint256[]) ownedTokens;

    /*
      Mapping from tokenID to owner's address
      Store who is the owner of specific token
    */
    mapping(uint256 => address) internal tokenOwner;

    /*
      Mapping from tokenID to approved address
      Only one address can be approved at one time
    */
    mapping(uint256 => address) internal tokenApprovals;

    /*
      Mapping from address to the number of tokens that
      specifid address owns
    */
    mapping(address => uint256) internal ownedTokensCount;

    /*
      Mapping from address to the mapping of addresses
      Specify which addresses can opearate on behalf of specific address
    */
    mapping(address => mapping(address => bool)) internal operatorApprovals;

    /*
      Mapping from token ID to the Cryptomon
      Returns Cryptomon structure from token ID
     */
    mapping(uint256 => Cryptomon) internal tokenCryptomon;

    /*
      Guarantee that msg.senser is owner of the specified token
    */
    modifier onlyOwner(uint256 _tokenID){
      require(ownerOf(_tokenID) == msg.sender);
      _;
    }

    /*
      Check if msg.sender can transfer a specified token
    */
    modifier canTransfer(uint256 _tokenID){
      require(isApprovedOrOwner(msg.sender, _tokenID));
    }



    /*
      Trigger whenever a token's ownership moves from one address to another
    */
    //event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    /*
      TODO: Description
      Trigger whenever
    */
    //event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    /*
      TODO: Description

    */
    //event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);


    function createCryptomon(uint _tokenId, string _name, uint _rarity, uint _type, string _attack1, string _attack2, uint _strength)
      external
    {
      addTokenTo(msg.sender, _tokenId);
      Cryptomon newCryptomon;
      newCryptomon.name = _name;
      newCryptomon.rarity = RarityEnum(_rarity);
      newCryptomon.type = CryptomonTypeEnum(_type);
      newCryptomon.attack1 = _attack1;
      newCryptomon.attack2 = _attack2;
      newCryptomon.strength = _strength;

      tokenCryptomon[_tokenId] = newCryptomon;
    }

    /**
    * Get the balance of specified address
    * @param  _owner  address to get balance of
    * @return uint256   the ammount of tokens owned by the specified address
    */
    function balanceOf(address _owner) external view returns (uint256){
      require(_owner != address(0));
      return ownedTokensCount[_owner];
    }

    /**
     * Get the owner of the specified token
     * @param  _tokenId uint256 ID of token to get owner of
     * @return address  owner of the specified token
     */
    function ownerOf(uint256 _tokenId) external view returns (address){
      address owner = tokenOwner[_tokenId];
      require(owner != address(0));
      return owner;
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable{

    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable canTransfer(_tokenId){

      require(_from != address(0));
      require(_to != address(0));

      clearApproval(_from, _tokenId);
      removeTokenFrom(_from, _tokenId);
      addTokenTo(_to, _tokenId);

      emit Transfer(_from, _to, _tokenId);

    }

    /**
     * @dev Internal function to clear current approval of a given token ID
     * @dev Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function clearApproval(address _owner, uint256 _tokenId) internal{
      require(ownerOf(_tokenId) == _owner);
      if(tokenApprovals[_tokenId] != address(0)){
        tokenApprovals[_tokenId] = address(0);
        emit Approval(_owner, address(0), _tokenId);
      }
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param _to address representing the new owner of the given token ID
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function addTokenTo(address _to, uint256 _tokenId) internal {
      require(tokenOwner[_tokenId] == address(0));
      tokenOwner[_tokenId] = _to;
      ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param _from address representing the previous owner of the given token ID
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
      require(ownerOf(_tokenId) == _from);
      ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
      tokenOwner[_tokenId] = address(0);
    }

    /**
     * Approve another address to transfer the given token ID.
     * Zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param  _approved address to be approved for the specified token
     * @param  _tokenId uint256 ID of the token to be approved
     */
    function approve(address _approved, uint256 _tokenId) external payabl{
      address owner = ownerOf(_tokenId);
      require(_approved != owner);
      require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

      if(getApproved(_tokenId) != address(0) || _to != address(0)){
        tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
      }
    }

    /**
     * Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param _operator address to set the approval
     * @param _approved bool    value of the approval to be set
     */
    function setApprovalForAll(address _operator, bool _approved) external{
      require(_operator != msg.sender);
      operatorApprovals[msg.sender][_to] = _approved;
      emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * Gets the approved address for specified token ID, or zero if address is not set
     * @param _tokenId uint256 ID of the token to get approval of
     * @return address    currently approved for specified token ID
     */
    function getApproved(uint256 _tokenId) external view returns (address){
      return tokenApprovals[_tokenId];
    }

    /**
     * Check if the operator is approved for a given owner
     * @param  _owner  address which you want to get the approval of
     * @param  _operator  address which you want to check approval of
     * @return bool       approval of the operator for a given owner address
     */
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
      return operatorApprovals[_owner][_operator];
    }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

}
