import { useState, useEffect } from "react";
import { ethers } from "ethers";
import societyABI from "../artifacts/contracts/SocietyOz.sol/SocietyManagement.json";

export default function SocietyManagementApp() {
  const [ethWallet, setEthWallet] = useState(undefined);
  const [account, setAccount] = useState(undefined);
  const [contract, setContract] = useState(undefined);
  const [balance, setBalance] = useState(undefined);
  const [memberDetails, setMemberDetails] = useState({});
  const [newMemberName, setNewMemberName] = useState("");
  const [newMemberFlat, setNewMemberFlat] = useState("");
  const [paymentAmount, setPaymentAmount] = useState("");

  // Replace with your deployed contract address
  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const abi = societyABI.abi;

  useEffect(() => {
    if (window.ethereum) {
      setEthWallet(window.ethereum);
      window.ethereum.on("accountsChanged", handleAccountsChanged);
      getWallet();
    } else {
      console.log("Please install MetaMask!");
    }

    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener("accountsChanged", handleAccountsChanged);
      }
    };
  }, []);

  useEffect(() => {
    if (ethWallet && account) {
      getContract();
    }
  }, [ethWallet, account]);

  const getWallet = async () => {
    if (ethWallet) {
      try {
        const accounts = await ethWallet.request({ method: "eth_accounts" });
        handleAccounts(accounts);
      } catch (error) {
        console.error("Error fetching accounts:", error);
      }
    }
  };

  const handleAccounts = (accounts) => {
    if (accounts && accounts.length > 0) {
      setAccount(accounts[0]);
    }
  };

  const connectAccount = async () => {
    if (!ethWallet) {
      alert("MetaMask wallet is required to connect");
      return;
    }

    try {
      const accounts = await ethWallet.request({ method: "eth_requestAccounts" });
      handleAccounts(accounts);
    } catch (error) {
      console.error("Error connecting account:", error);
    }
  };

  const getContract = () => {
    const provider = new ethers.providers.Web3Provider(ethWallet);
    const signer = provider.getSigner();
    const societyContract = new ethers.Contract(contractAddress, abi, signer);
    setContract(societyContract);
  };

  const getBalance = async () => {
    if (contract) {
      try {
        const contractBalance = await contract.getSocietyBalance();
        setBalance(ethers.utils.formatEther(contractBalance));
      } catch (error) {
        console.error("Error fetching balance:", error);
      }
    }
  };

  const addMember = async () => {
    if (contract && newMemberName && newMemberFlat) {
      try {
        const tx = await contract.addMember(account, newMemberName, parseInt(newMemberFlat));
        await tx.wait();
        alert("Member added successfully!");
        setNewMemberName("");
        setNewMemberFlat("");
      } catch (error) {
        console.error("Error adding member:", error);
      }
    }
  };

  const makePayment = async () => {
    if (contract && paymentAmount) {
      try {
        const amountInWei = ethers.utils.parseEther(paymentAmount);
        const tx = await contract.makePayment({ value: amountInWei });
        await tx.wait();
        alert("Payment made successfully!");
        setPaymentAmount("");
        getBalance();
      } catch (error) {
        console.error("Error making payment:", error);
      }
    }
  };

  const getMemberDetails = async () => {
    if (contract) {
      try {
        const details = await contract.getMemberDetails(account);
        setMemberDetails({
          name: details[0],
          flatNumber: details[1].toString(),
          duesPaid: ethers.utils.formatEther(details[2]),
        });
      } catch (error) {
        console.error("Error fetching member details:", error);
      }
    }
  };

  const handleAccountsChanged = (accounts) => {
    if (accounts.length === 0) {
      console.log("Please connect to MetaMask.");
    } else {
      setAccount(accounts[0]);
    }
  };

  const initUser = () => {
    if (!ethWallet) {
      return <p>Please install MetaMask in order to use this Dapp.</p>;
    }

    if (!account) {
      return <button onClick={connectAccount}>Connect Wallet</button>;
    }

    if (balance === undefined) {
      getBalance();
    }

    return (
      <div>
        <p>Account: {account}</p>
        <p>Contract Balance: {balance} ETH</p>

        <div>
          <h3>Add a New Member</h3>
          <input
            type="text"
            placeholder="Name"
            value={newMemberName}
            onChange={(e) => setNewMemberName(e.target.value)}
          />
          <input
            type="number"
            placeholder="Flat Number"
            value={newMemberFlat}
            onChange={(e) => setNewMemberFlat(e.target.value)}
          />
          <button onClick={addMember}>Add Member</button>
        </div>

        <div>
          <h3>Make a Payment</h3>
          <input
            type="text"
            placeholder="Amount (ETH)"
            value={paymentAmount}
            onChange={(e) => setPaymentAmount(e.target.value)}
          />
          <button onClick={makePayment}>Pay Dues</button>
        </div>

        <div>
          <h3>Member Details</h3>
          <button onClick={getMemberDetails}>Get Details</button>
          {memberDetails.name && (
            <div>
              <p>Name: {memberDetails.name}</p>
              <p>Flat Number: {memberDetails.flatNumber}</p>
              <p>Dues Paid: {memberDetails.duesPaid} ETH</p>
            </div>
          )}
        </div>
      </div>
    );
  };

  return (
    <main>
      <h1>Society Management Dapp</h1>
      {initUser()}
    </main>
  );
}
