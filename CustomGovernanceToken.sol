// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";   

contract GovernanceToken is Initializable, ERC20Upgradeable, AccessControlUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable {

            using SafeMath for uint256; 

                uint256 public ownerFee;
                uint256 public daoAmount;
                uint256 public minDeposit;
                uint256 public maxDeposit;
                address tresuryAddress;
                address public ownerAddress;
                address public constant tokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;      
                bool feeUSDC; 
                bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
                constructor()   {
                                _disableInitializers();
                                }

        function initialize(address treasury, address owner,
                string calldata name, string calldata symbol,
                uint fee, uint minDep, uint maxDep, bool _feeUSDC) initializer public {
                        tresuryAddress = treasury;
                        ownerAddress = owner;
                        ownerFee = fee;
                        minDeposit = minDep;
                        maxDeposit = maxDep;
                        feeUSDC = _feeUSDC;
                        __ERC20_init(name, symbol);
                        __AccessControl_init();
                        __ERC20Permit_init(name);
                        __ERC20Votes_init();
                        _grantRole(DEFAULT_ADMIN_ROLE, owner);
                        _grantRole(MINTER_ROLE, owner);
        }

        function burn(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
                _burn(to, amount);
        }

        function updateMinDeposit (
                uint256 _minDeposit
                ) external onlyRole(MINTER_ROLE)  returns (bool){
        minDeposit = _minDeposit;
                return true;
        }

        function updateMaxDeposit (
                uint256 _maxDeposit
                ) external onlyRole(MINTER_ROLE)  returns (bool){
        maxDeposit = _maxDeposit;
                return true;
        }

        function updateOwnerFee (
                uint256 _ownerFee
                ) external onlyRole(MINTER_ROLE)  returns (bool){
                // require(depositIntilize, "Failed to update due to deposit initialized");
                ownerFee = _ownerFee;
                return true;
        }

        function depositEthOnly () external payable {
                require(!hasRole(MINTER_ROLE, msg.sender), "Owner can not deposit");
                require(msg.value > minDeposit, "Amount should be higher than minimum deposit");
                require(msg.value > maxDeposit, "Amount should be lower than maximum deposit");
                uint amt = msg.value - ownerFee;
                payable(ownerAddress).transfer(ownerFee);
                payable(tresuryAddress).transfer(amt);
                _mint(msg.sender, amt);
                if (delegates(msg.sender) == address(0)){
                        _delegate(msg.sender, msg.sender);
                }
                daoAmount = daoAmount + amt;
        }

        // The following functions are overrides required by Solidity.

        function _afterTokenTransfer(address from, address to, uint256 amount)
                internal
                override(ERC20Upgradeable, ERC20VotesUpgradeable)
        {
        super._afterTokenTransfer(from, to, amount);
        }

        function _mint(address to, uint256 amount)
                internal
                override(ERC20Upgradeable, ERC20VotesUpgradeable)
        {
        super._mint(to, amount);
        }

        function _burn(address account, uint256 amount)
                internal
                override(ERC20Upgradeable, ERC20VotesUpgradeable)
        {
        super._burn(account, amount);
        }

       
        }
