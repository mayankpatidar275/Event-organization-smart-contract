// Event organization smart contract
// Features:-
// Organizer creates an event
// Organizer can create offer on their event on the basis of quantity of tickets bought
// The buyer can buy the tickets of created event as per the availability 
// The buyer can transfer the ticket to any other address

//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;
 
contract EventContract {
 struct Event{
   address payable organizer;
   string name;
   uint date; 
   uint price;
   uint ticketCount;  
   uint ticketRemain;
   uint discounted_price;
 }
 
 mapping(uint=>Event) public events;
 mapping(address=>mapping(uint=>uint)) public tickets;
 uint public nextId;

 function createEvent(string memory name,uint date,uint price,uint ticketCount) external{
   require(date>block.timestamp,"You can organize event for future date");
   require(ticketCount>0,"You can organize event only if you create more than 0 tickets");
   events[nextId] = Event(payable(msg.sender),name,date, price ,ticketCount,ticketCount, price);
   nextId++;
 }

 function createOffer(uint id, uint offer) external {
  Event storage _event = events[id];
  require(msg.sender == _event.organizer); 
  _event.discounted_price = _event.price - (_event.price*offer)/100;
 }
 
 function buyTicket(uint id,uint quantity) external payable{
   require(events[id].date!=0,"Event does not exist");
   require(events[id].date>block.timestamp,"Event has already occured");
   Event storage _event = events[id];
   uint total_cost = _event.price;
   if(quantity>10){
    total_cost = _event.discounted_price;
   }
   require(msg.value==(total_cost*quantity),"Ethere is not enough");
   require(_event.ticketRemain>=quantity,"Not enough tickets");
   _event.ticketRemain-=quantity;
   tickets[msg.sender][id]+=quantity;
   _event.organizer.transfer(quantity*total_cost);
 }

 function transferTicket(uint id,uint quantity,address to) external{
   require(events[id].date!=0,"Event does not exist");
   require(events[id].date>block.timestamp,"Event has already occured");
   require(tickets[msg.sender][id]>=quantity,"You do not have enough tickets");
   tickets[msg.sender][id]-=quantity;
   tickets[to][id]+=quantity;
 }
}
