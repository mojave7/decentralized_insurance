// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Assurance is ERC721Enumerable, Ownable, Pausable {
    struct Evenement {
        uint256 id;
        uint256 maxSubscribers;
        uint256 timeLimit;
        uint256 EventPrice;
        uint256 InsurancePrice;
        string link;
        bool active;
    }

    struct Subscription {
        uint256 nftId;
        uint256 eventId;
        uint256 subscriptionDate;
        address subscriber;
    }

    //events
    mapping(uint256 => address[]) public RefundLists;
    mapping(uint256 => address[]) public RefundedLists;
    //list des events sur les quels un wallet est inscrit ...)
    mapping(address => uint256[]) public subscriberToEventList;
    //informations de l'events par id
    mapping(uint256 => Evenement) public EventToStruct;
    //liste des nfts pour chaque event (...)
    mapping(uint256 => uint256[]) public EventToNFTs;
    //struct (infos) pour chaque nft
    mapping(uint256 => Subscription) public NFTIdToSubscription;
    //list des wallets inscrits pour un event donné
    mapping(uint256 => address[]) public EventToSubscribers;
    //nombre total d'events
    uint256 totalEvents = 0;

    constructor() ERC721("Event NFTS", "ENFT") {}

    function creatEvent(
        uint256 maxSubscribers,
        uint256 timeLimit,
        uint256 InsurancePrice,
        uint256 EventPrice,
        string memory link
    ) public whenNotPaused onlyOwner {
        totalEvents += 1;
        uint256 id = totalEvents;
        Evenement memory evenement = Evenement(
            id,
            maxSubscribers,
            timeLimit,
            EventPrice,
            InsurancePrice,
            link,
            true
        );
        EventToStruct[id] = evenement;
    }

    function subscribe(uint256 id) public payable whenNotPaused {
        //address valide (...)
        require(
            msg.sender != address(0),
            "ENFT: zero address can not mint an event"
        );
        //event existe
        require(id <= totalEvents, "ENFT: The event is not created yet");
        require(EventToStruct[id].active == true, "ENFT: Event not active");
        //places disponibles
        require(
            EventToSubscribers[id].length < EventToStruct[id].maxSubscribers,
            "ENFT: Event max wubscriptions already reached"
        );
        //date limite valide
        require(
            block.timestamp < EventToStruct[id].timeLimit,
            "ENFT: Event expired !"
        );
        //premium price
        require(
            msg.value == EventToStruct[id].InsurancePrice,
            "ENFT: not correspending value"
        );
        for (uint256 i; i < EventToSubscribers[id].length; i++) {
            if (EventToSubscribers[id][i] == msg.sender) {
                revert("ENFT: user already subscribed");
            }
        }
        EventToSubscribers[id].push(msg.sender);
        subscriberToEventList[msg.sender].push(id);
        //create nft and edit EventToNFTs

        uint256 nftId = mint(msg.sender);
        Subscription memory subscription = Subscription(
            nftId,
            id,
            block.timestamp,
            msg.sender
        );
        EventToNFTs[id].push(nftId);
        NFTIdToSubscription[nftId] = subscription;
    }

    function mint(address user) internal whenNotPaused returns (uint256) {
        require(
            msg.sender != address(0),
            "IDF: zero address can not mint an event"
        );
        uint256 supply = totalSupply();
        _safeMint(user, supply + 1);
        return supply + 1;
    }

    string json_part1 =
        '{"name":"Decentralized Insurance","Description":"Assurance decentralisee dans le cadre du projet G1G2 defi","image":"';

    string json_part2 = '","infos":{"event_id":"';
    string json_part3 = '","insurancePrice":"';
    string json_part4 = '","eventPrice":"';
    string json_part5 = '","subscriptionDate":"';
    string json_part6 = '","subscriber":"0x';
    string json_part7 = '"}}';

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        Subscription memory subscription = NFTIdToSubscription[tokenId];
        Evenement memory evenement = EventToStruct[subscription.eventId];

        string memory link = evenement.link;
        uint256 eventId = evenement.id;
        uint256 insurancePrice = evenement.InsurancePrice;
        uint256 eventPrice = evenement.EventPrice;
        uint256 subscriptionDate = subscription.subscriptionDate;
        string memory subscriber = Strings.toHexString(
            uint160(subscription.subscriber),
            20
        );

        string memory One = string(
            abi.encodePacked(
                json_part1,
                link,
                json_part2,
                eventId,
                json_part3,
                insurancePrice,
                json_part4
            )
        );

        string memory Two = string(
            abi.encodePacked(
                eventPrice,
                json_part5,
                subscriptionDate,
                json_part6,
                subscriber,
                json_part7
            )
        );

        return string(abi.encodePacked(One, Two));
    }

    /**
     * @notice Pause function implemented from Pausable openzepplin
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice unPause function implemented from Pausable openzepplin
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    function withdrawAll() public onlyOwner whenPaused {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawAmount(uint256 amount) public payable whenNotPaused {
        require(address(this).balance > amount, "ENFT: not enough liquidity!");
        payable(msg.sender).transfer(amount);
    }

    function addLiquidity() public payable onlyOwner {
        require(msg.value > 0, "ENFT: addLiquidity requires msg.value>0");
    }

    function claimRefund(uint256 id) public {
        //verifier que l event n'est pas arrive a maturite (ou apres 24h)
        //verifier que que le client est inscrit
        require(id <= totalEvents, "ENFT: The event is not created yet");
        require(EventToStruct[id].active == true, "ENFT: Event not active");
        address client = msg.sender;
        bool isClient = false;
        uint256 totalSub = EventToSubscribers[id].length;
        for (uint256 i = 0; i < totalSub; i++) {
            if (EventToSubscribers[id][i] == client) {
                isClient = true;
            }
        }
        require(isClient, "ENFT: client is not subscribed to this event");
        uint256 totalRefund = RefundLists[id].length;
        bool isRefunded = false;
        for (uint256 i = 0; i < totalRefund; i++) {
            if (RefundLists[id][i] == client) {
                isRefunded = true;
            }
        }
        require(!isRefunded, "ENFT: client already refunded");
        //le remboursement est desactive apres 24h de l expiration
        require(
            block.timestamp < EventToStruct[id].timeLimit + 86400,
            "ENFT: Event refunding expired !"
        );
        RefundLists[id].push(client);
    }

    function approuveRefund(
        uint256 id,
        address client,
        bool fullRefund
    ) public payable onlyOwner {
        uint256 totalRefund = RefundLists[id].length;
        bool hasClaimed = false;
        for (uint256 i = 0; i < totalRefund; i++) {
            if (RefundLists[id][i] == client) {
                hasClaimed = true;
            }
        }
        require(hasClaimed, "ENFT: client didnt claim refund");
        // verify already refunded clients
        uint256 totalRefunded = RefundedLists[id].length;
        bool isRefunded = false;
        for (uint256 i = 0; i < totalRefunded; i++) {
            if (RefundedLists[id][i] == client) {
                isRefunded = true;
            }
        }
        require(!isRefunded, "ENFT: client already refunded");

        // 1 =>  70%
        // 2 => 100%
        if (fullRefund) {
            require(
                address(this).balance > EventToStruct[id].EventPrice,
                "ENFT: not enough liquidity!"
            );
            payable(client).transfer(EventToStruct[id].EventPrice);
            RefundedLists[id].push(client);
        } else {
            require(
                address(this).balance >
                    (((EventToStruct[id].EventPrice) * 7) / 10),
                "ENFT: not enough liquidity!"
            );
            payable(client).transfer(((EventToStruct[id].EventPrice) * 7) / 10);
            RefundedLists[id].push(client);
        }
    }

    function getEvent(uint256 id) public view returns (Evenement memory) {
        return EventToStruct[id];
    }

    function getTotalEvents() public view returns (uint256) {
        return totalEvents;
    }

    function getEventList() public view returns (uint256[] memory) {
        return subscriberToEventList[msg.sender];
    }

    function getSubscriberList(uint256 id)
        public
        view
        returns (address[] memory)
    {
        return EventToSubscribers[id];
    }

    function getSubscriptions(uint256 id)
        public
        view
        returns (Subscription memory)
    {
        return NFTIdToSubscription[id];
    }

    function getNfts(uint256 id) public view returns (uint256[] memory) {
        return EventToNFTs[id];
    }
}
