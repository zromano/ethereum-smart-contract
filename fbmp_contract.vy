price: public(wei_value)
duration: (timedelta)
seller: public(address)
buyer: public(address)
sold: public(bool)
shipped: public(bool)
received: public(bool)
damaged: public(bool)
expiration_date: public(timestamp)
end_date: public(timestamp)
purchase_date: public(timestamp)
ship_date: public(timestamp)
deposit: public(uint256)

@public
@payable
def __init__(_price: uint256, _duration: timedelta):
    self.seller = msg.sender
    self.deposit = as_unitless_number(msg.value)
    self.price = _price
    self.end_date = block.timestamp + _duration
 
@public
@payable
def purchase_item():
    assert block.timestamp < self.end_date
    assert self.price == msg.value
    assert not self.sold
    
    self.buyer = msg.sender
    self.purchase_date = block.timestamp
    self.sold = True
    
@public
def cancel_sale():
    assert self.seller == msg.sender
    assert not self.sold
    assert block.timestamp < self.end_date
    
    selfdestruct(self.seller)
 
@public
def refund_purchase():
    assert block.timestamp < self.end_date
    assert self.buyer == msg.sender
    assert not self.shipped
    
    send(msg.sender, self.price)
    
    self.buyer = 0x0000000000000000000000000000000000000000
    self.sold = False

@public
def ship_item():
    assert self.seller == msg.sender
    
    self.ship_date = block.timestamp
    self.shipped = True
 
@public
def was_received():
    assert self.shipped
    assert msg.sender == self.buyer
    
    send(self.seller, self.price)
    self.received = True
    selfdestruct(self.seller)


 # assert the item was shipped using the ‘shipped’ flag
 # assert the person marking the item as ‘received’ is the buyer
 # use send() to send the profits to the seller
 # use selfdestruct() to return the deposit to the seller
 # set the ‘received’ flag to True
 
@public
def mark_damaged():
    assert block.timestamp > self.end_date
    assert msg.sender == self.buyer
    assert not self.received
    
    self.damaged = True
    
    send(self.seller, self.price / 2)
 # assert the current date/time is after the sale’s end date
 # assert the person making the claim is the buyer
 # assert the ‘received’ flag is False
 # set the ‘damaged’ flag to True
 # use send() to return half of the seller’s deposit to the seller
 
@public
def finalize_sale():
    assert self.shipped
    assert block.timestamp > (self.end_date + 864000)
    assert msg.sender == self.seller
    assert self.sold
    assert not self.received
    assert not self.damaged
    
    selfdestruct(self.seller)

 # assert the item has been shipped
 # assert current date/time is at least 10 days after ‘ship_date’
 # assert the person finalizing the sale is the seller
 # assert the item has been marked as ‘sold’
 # assert the item has not been marked as ‘received’
 # assert the item has not been marked as ‘damaged’
 # user selfdestruct() to return the deposit to the seller
