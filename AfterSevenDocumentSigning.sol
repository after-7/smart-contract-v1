// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AfterSevenDocumentSigning {
    address public owner;
    address public feeReceiver; // Carteira recebedora da tarifa
    uint256 public feeAmount;   // Valor da tarifa em wei

    struct Document {
        address signer;
        string md5;
        string sha256Hash;
        string sha512Hash;
    }

    mapping(bytes32 => Document) public documents;

    event DocumentSigned(bytes32 indexed documentHash, address indexed signer, uint256 feePaid, string md5, string sha256Hash, string sha512Hash);
    event FeeReceiverChanged(address indexed newFeeReceiver);
    event FeeAmountChanged(uint256 newFeeAmount);
    event OwnerChanged(address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        feeReceiver = msg.sender; // Inicialmente, a carteira recebedora é o proprietário
        feeAmount = 1000;            // Inicialmente, a tarifa é zero
    }

    function signDocument(
        bytes32 documentHash,
        string memory md5,
        string memory sha256Hash,
        string memory sha512Hash
    ) public payable {
        // Verifica se o documento já foi assinado
        require(!isDocumentSigned(documentHash), "Document already signed");

        if (msg.sender != owner) {
            require(msg.value >= feeAmount, "Insufficient fee");
            // Transfere a tarifa para o recebedor
            payable(feeReceiver).transfer(feeAmount);
        }

        // Armazena o documento como assinado
        documents[documentHash] = Document(msg.sender, md5, sha256Hash, sha512Hash);

        // Emitir eventos indicando que a tarifa foi paga e o documento foi assinado
        emit DocumentSigned(documentHash, msg.sender, msg.value, md5, sha256Hash, sha512Hash);
    }
    function isDocumentSigned(bytes32 documentHash) public view returns (bool) {
        return documents[documentHash].signer != address(0);
    }

    function getDocumentSigned(bytes32 documentHash) public view returns (Document memory) {
        return documents[documentHash];
    }

    function changeFeeReceiver(address newFeeReceiver) public onlyOwner {
        feeReceiver = newFeeReceiver;
        emit FeeReceiverChanged(newFeeReceiver);
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function changeFeeAmount(uint256 newFeeAmount) public onlyOwner {
        feeAmount = newFeeAmount;
        emit FeeAmountChanged(newFeeAmount);
    }
}
