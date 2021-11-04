// SPDX-License-Identifier: CC-BY-SA-4.0
// Version of Solidity compiler this program was written for 
pragma solidity ^0.8.9;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract Voting is Ownable {
    
    // variables
    address public administrateur;
    
    enum WorkflowStatus { RegisteringVoters, ProposalsRegistrationStarted, ProposalsRegistrationEnded, VotingSessionStarted, VotingSessionEnded, VotesTallied}
    WorkflowStatus etape;
    WorkflowStatus public defaultstate = WorkflowStatus.RegisteringVoters;
    
    
    
    struct Voter {
        bool isRegistered; // si true, enregistré
        bool hasVoted; // si true, déjà voté
        uint votedProposalId; // index la proposition choisie
    }
    
    
    struct Proposal {
        string description;
        uint voteCount; //nbre de votes cumulés
    }
    
        //events
    event VoterRegistered(address voterAddress); // utiliser pour les logs
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);
    

    // whitelist d'électeurs avec leurs adresses ether
    mapping(address=> bool) public whitelist;
    event Authorized(address _address);
    
    mapping(address => Voter) public voters;
    
    // tableau dynamique pour stocker les propositions
    Proposal[] public proposals;
    
    
    // accès aux votants
    function authorize(address _address) public {
       whitelist[_address] = true;
       emit Authorized(_address);
   }
   
   // admin commence session enregistrement de la proposition
   constructor(string[] memory _proposalId) {
       administrateur = msg.sender;
       voters[administrateur].hasVoted = true;
   
   
   // Création d'un bulletin pour choisir une des proposition
   for (uint i = 0; i < _proposalId.length; i++) {
       proposals.push(Proposal({description: _proposalId[i], voteCount: 0}));
        }
   }
   
    function accesEnregistrementProposition() public {
        etape = WorkflowStatus.ProposalsRegistrationStarted;
    }
    
   
   //  Donnez au votant le droit de voter sur ce bulletin 
   // seulement appelable par administrateur
   function droitDeVote(address _voter) public view {
       require(msg.sender == administrateur, "Seul le president peut donner le droit de vote !");
       require(etape == WorkflowStatus.ProposalsRegistrationStarted);
       require(voters[_voter].isRegistered == true);
       require(!voters[_voter].hasVoted, "L electeur a deja vote.");
       
   }
   
   function fermetureEnregistrementProposition() public {
       etape = WorkflowStatus.ProposalsRegistrationEnded;
   }
   
   function demarrageVoting() public {
       etape = WorkflowStatus.ProposalsRegistrationStarted;
   }
    
    // Voter pour une des propositions
    function vote(uint _proposal) public {
        Voter storage sender = voters[msg.sender];
        require(etape == WorkflowStatus.VotingSessionStarted);
        require(sender.isRegistered == false, "Vous n'avez pas le droit de vote");
        require(sender.hasVoted == true, "Deja vote");
        sender.hasVoted == true;
        sender.votedProposalId = _proposal;
    }
   
   
   function finDesVotes() public {
       etape = WorkflowStatus.VotingSessionEnded;
   }
   
   // Calculer la proposition gagnante à partir des votes
   function winningProposal() public view returns (uint winningProposalId){
       require(etape == WorkflowStatus.VotingSessionEnded);
       uint compteurDeVoteGagnant = 0;
       for (uint p = 0; p < proposals.length; p++) {
           if (proposals[p].voteCount > compteurDeVoteGagnant) {
               compteurDeVoteGagnant = proposals[p].voteCount;
               winningProposalId = p;
           }
       }
   }
   
    function comptageDesVotes() public view {
       require(etape == WorkflowStatus.VotesTallied);
   }
   
   // fonction qui retourne le gagnant
   function getWinner() public view returns (string memory _winnerName) {
       _winnerName = proposals[winningProposal()].description;
   }
   
   
}