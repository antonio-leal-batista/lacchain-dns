pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";

contract DNSRegistry is OwnableUpgradeSafe {

	struct DIDStruct {
		string entity; // base64 x509 PEM
		bool status;
	}

	function initialize() public initializer {
		OwnableUpgradeSafe.__Ownable_init();
	}

	mapping(address => DIDStruct) private dids;
	address[] public addresses;

	event DIDAdded( address indexed did );
	event DIDRevoked( address indexed did );
	event DIDRemoved( address indexed did );
	event DIDEnabled( address indexed did );

	function addDID(address did, string calldata entity) onlyOwner external returns (bool) {
		DIDStruct storage _did = dids[did];
		//require( !_did.status, "DID already exists");
		_did.entity = entity;
		_did.status = true;

		dids[did] = _did;
		addresses.push( did );
		emit DIDAdded(did);
		return true;
	}

	function revokeDID(address did) onlyOwner external returns (bool)  {
		DIDStruct storage _did = dids[did];
		require(_did.status, "DID is not enabled");

		_did.status = false;

		dids[did] = _did;

		emit DIDRevoked(did);
		return true;
	}

	function enableDID(address did) onlyOwner external returns (bool)  {
		DIDStruct storage _did = dids[did];
		require(_did.status, "DID is not enabled");

		_did.status = true;

		dids[did] = _did;

		emit DIDEnabled(did);
		return true;
	}

	function removeDID(uint index) onlyOwner external returns (bool)  {
		require(index > 0 && index < addresses.length, "Invalid index");

		address did = addresses[index];

		require(did != address(0), "Invalid DID");

		DIDStruct storage _did = dids[did];

		_did.status = false;
		_did.entity = "";

		dids[did] = _did;
		delete addresses[index];

		emit DIDRemoved(did);
		return true;
	}

	function getDID(address did) public view returns (DIDStruct memory) {
		return dids[did];
	}

	function getDIDs() public view returns (address[] memory){
		return addresses;
	}

}
