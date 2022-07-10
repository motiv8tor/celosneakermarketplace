
import './App.css';

import { NavigationBar } from './components/navbar';
import { AddSneaker } from './components/addSneakers';
import { Sneakers } from './components/sneakers';
import { useState, useEffect, useCallback } from "react";


import Web3 from "web3";
import { newKitFromWeb3 } from "@celo/contractkit";
import BigNumber from "bignumber.js";


import celosneakers from "./contracts/celosneakers.abi.json";
import IERC from "./contracts/IERC.abi.json";


const ERC20_DECIMALS = 18;



const contractAddress = "0xAb921aE548a9131e30540BBDfDF81D957033e2d9";
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1";



function App() {
  const [contract, setcontract] = useState(null);
  const [address, setAddress] = useState(null);
  const [kit, setKit] = useState(null);
  const [cUSDBalance, setcUSDBalance] = useState(0);
  const [sneakers, setSneakers] = useState([]);
  


  const connectToWallet = async () => {
    if (window.celo) {
      try {
        await window.celo.enable();
        const web3 = new Web3(window.celo);
        let kit = newKitFromWeb3(web3);

        const accounts = await kit.web3.eth.getAccounts();
        const user_address = accounts[0];
        kit.defaultAccount = user_address;

        await setAddress(user_address);
        await setKit(kit);
      } catch (error) {
        console.log(error);
      }
    } else {
      alert("Error Occurred");
    }
  };

  const getBalance = useCallback(async () => {
    try {
      const balance = await kit.getTotalBalance(address);
      const USDBalance = balance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2);

      const contract = new kit.web3.eth.Contract(celosneakers, contractAddress);
      setcontract(contract);
      setcUSDBalance(USDBalance);
    } catch (error) {
      console.log(error);
    }
  }, [address, kit]);



  const getSneakers = useCallback(async () => {
    const sneakersLength = await contract.methods.getsneakersLength().call();
    const sneakers = [];
    for (let index = 0; index < sneakersLength; index++) {
      let _sneakers = new Promise(async (resolve, reject) => {
      let sneaker = await contract.methods.getSneaker(index).call();

        resolve({
          index: index,
          owner: sneaker[0],
          image: sneaker[1],
          brand: sneaker[2],
          description: sneaker[3],
          price: sneaker[4],
          availableSneakers: sneaker[5],
          sneakersReturned: sneaker[6], 
          sneakersSold: sneaker[7], 
          feedbacks: sneaker[8] 
        });
      });
      sneakers.push(_sneakers);
    }


    const _sneakers = await Promise.all(sneakers);
    setSneakers(_sneakers);
  }, [contract]);


  const addSneaker = async (
    _image,
    _brand,
    _description,
    _price,
    _availableSneakers
 
  ) => {
    let price = new BigNumber(_price).shiftedBy(ERC20_DECIMALS).toString();
    try {
      await contract.methods
        .addSneaker(_image, _brand, _description, price, _availableSneakers)
        .send({ from: address });
      getSneakers();
    } catch (error) {
      alert(error);
    }
  };


  const returnSneaker = async (
    _index,
    _feedback
  ) => {
    try {
      await contract.methods
        .returnSneaker(_index, _feedback)
        .send({ from: address });
      getSneakers();
    } catch (error) {
      alert(error);
    }
  };



  const deleteSneakerlisting = async (
    _index
  ) => {
    try {
      await contract.methods
        .deleteSneaker(_index)
        .send({ from: address });
      getSneakers();
    } catch (error) {
      alert(error);
    }
  };


  const buySneaker = async (_index) => {
    try {
      const cUSDContract = new kit.web3.eth.Contract(IERC, cUSDContractAddress);
      const cost = sneakers[_index].price;
      await cUSDContract.methods
        .approve(contractAddress, cost)
        .send({ from: address });
      await contract.methods.buySneaker(_index).send({ from: address });
      getSneakers();
      getBalance();
      alert("you have successfully bought this sneaker");
    } catch (error) {
      alert(error);
    }};

    const repayBuyer = async (_index, _address) => {
      try {
        const cUSDContract = new kit.web3.eth.Contract(IERC, cUSDContractAddress);
        const cost = sneakers[_index].price;
        await cUSDContract.methods
          .approve(contractAddress, cost)
          .send({ from: address });
        await contract.methods.repayBuyer(_index, _address).send({ from: address });
        getSneakers();
        getBalance();
        alert("you have repay the buyer");
      } catch (error) {
        alert(error);
      }};


  useEffect(() => {
    connectToWallet();
  }, []);

  useEffect(() => {
    if (kit && address) {
      getBalance();
    }
  }, [kit, address, getBalance]);

  useEffect(() => {
    if (contract) {
      getSneakers();
    }
  }, [contract, getSneakers]);
  
  return (
    <div className="App">
      <NavigationBar cUSDBalance={cUSDBalance} />
      <Sneakers 
      sneakers={sneakers} 
      buySneaker={buySneaker} 
      walletAddress={address} 
      deleteSneakerlisting={deleteSneakerlisting} 
      returnSneaker={returnSneaker} 
      repayBuyer={repayBuyer} />
      <AddSneaker addSneaker={addSneaker} />
    </div>
  );
}

export default App;