pragma solidity^0.4.19;
//import '/node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
//import './SafeMath.sol';
contract Token{//base
	mapping(address => uint256) public BalanceOf;
	string public name;
	string public symbol;
	uint8 public decimal;
	uint256 public totalSupply;
	event Transfer(address indexedFrom, address indexedTo, uint256 value);
	 function Token  (uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits)public{
		BalanceOf[msg.sender] = initialSupply;
		totalSupply = initialSupply;
		decimal = decimalUnits;
		symbol = tokenSymbol;

		name = tokenName;
	
	}
	
	function transfer(address _to, uint256 _value)public{
	    require(BalanceOf[msg.sender] >_value);
		//if(BalanceOf[msg.sender] < _value) throw;
		require(BalanceOf[_to]+ _value > BalanceOf[_to]);
	//	if(BalanceOf[_to] + _value < BalanceOf[_to]) throw;
		
		BalanceOf[msg.sender] -=_value;
		BalanceOf[_to] += _value;
		emit Transfer(msg.sender, _to, _value);
}
}
contract admined{
	address public admin;
	function admined()public{
		admin = msg.sender;
	}
	modifier OnlyAdmin(){
	    require(msg.sender == admin);
		//if(msg.sender != admin) throw;
		_;
	}
	
	function transferAdmin(address newAdmin) OnlyAdmin()public{
		admin = newAdmin;
	}
}

contract preIcoAmToken is admined, Token{
	function preIcoAmToken(uint256 _initialSupply, string _name, string _symbol, uint8 _decimal, address centralAdmin) Token(0, _name, _symbol, _decimal)public{
		totalSupply = _initialSupply;
		if (centralAdmin != 0){
			admin = centralAdmin;
		}
		else{
			admin = msg.sender;
		}
}
		
	function mintToken(address target, uint256 mintedAmount) OnlyAdmin public{
		BalanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		emit Transfer(0,this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
}
function() payable public { }
	/*function(address _to, uint256 _value) public{
		require(BalanceOf[msg.sender] >= _value);
		
		//if(BalanceOf[msg.sender]< _value) thrw;
		require(BalanceOf[msg.sender] > 0);
		//if(BalanceOf[msg.sender] < 0) throw;
		
		BalanceOf[msg.sender] -=_value;
		BalanceOf[_to] += _value;
		
		emit Transfer(msg.sender, _to, _value);

}*/


}



