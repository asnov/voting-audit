const {TonClient, abiContract, signerKeys} = require("@tonclient/core");
const { libNode } = require("@tonclient/lib-node");
const { Account } = require("@tonclient/appkit");
const fs = require('fs');
const dotenv = require('dotenv').config();
const networks = ["http://localhost",'net.ton.dev','main.ton.dev','rustnet.ton.dev','https://gql.custler.net'];
const hello = ["Hello localhost TON!","Hello dev net TON!","Hello main net TON!","Hello rust dev net TON!","Hello fld dev net TON!"];
const networkSelector = process.env.NET_SELECTOR;

const { GiverContract } = require("./Giver.js");
const { DeAuditRootCode } = require("./DeAuditRootCode.js");


const { DeAuditRootContract } = require("./DeAuditRoot.js");
const { DeAuditContract } = require("./DeAudit.js");
const { DeAuditDataContract } = require("./DeAuditData.js");
const { ParticipantContract } = require("./Participant.js");
const { Act4Contract } = require("./Act4.js");
const { TONTokenWalletContract } = require("./TONTokenWallet.js");




const pathJsonRoot = './DeAuditRoot.json';
const pathJsonParticipants = './Participants.json';

const hex = require('ascii-hex');
const hex2ascii = require('hex2ascii');

function toHex(input) {
  let output = '';
  for (i = 0; i < input.length; i ++){output += hex(input[i]).toString(16)}
  return String(output);
}


TonClient.useBinaryLibrary(libNode);

async function logEvents(params, response_type) {
  // console.log(`params = ${JSON.stringify(params, null, 2)}`);
  // console.log(`response_type = ${JSON.stringify(response_type, null, 2)}`);
}

async function main(client) {
  let response;
  const rootKeys = JSON.parse(fs.readFileSync(pathJsonRoot,{encoding: "utf8"})).keys;
  const rootAddr = JSON.parse(fs.readFileSync(pathJsonRoot,{encoding: "utf8"})).address;
  console.log("rootAddr:", rootAddr);

  const rootAcc = new Account(DeAuditRootContract, {
    address:rootAddr,
    signer: rootKeys,
    client,
  });

  // let pubkeyCreator = '0x'+rootKeys.keys.public;
  // response = await rootAcc.runLocal("getParticipantAddress", {_answer_id:0, pubkeyParticipant:pubkeyCreator});
  // console.log("creatorAddr:", response.decoded.output);
  //
  // const creatorAddr = response.decoded.output.value0;
  // const creatorAcc = new Account(ParticipantContract, {
  //   address: creatorAddr,
  //   signer: rootKeys,
  //   client,
  // });
  //
  // response = await creatorAcc.runLocal("rootDeAudit", {});
  // console.log("Contract reacted to your rootDeAudit:", response.decoded.output);
  //
  // response = await creatorAcc.runLocal("initiatedDeAuditData", {});
  // console.log("Contract reacted to your initiatedDeAuditData:", response.decoded.output);


  response = await rootAcc.runLocal("keysDeAudit", {});
  console.log("keysDeAudit[0]:", response.decoded.output.keysDeAudit[2]);
  let deauditAddr = response.decoded.output.keysDeAudit[0];


  let resultArr = JSON.parse(fs.readFileSync(pathJsonParticipants,{encoding: "utf8"}));
  const participantAddr = resultArr[1].address;
  const participantKeys = resultArr[1].keys;
  const participantAcc = new Account(ParticipantContract, {
    address: participantAddr,
    signer: participantKeys,
    client,
  });

  console.log("collator address:", participantAddr);

  response = await participantAcc.runLocal("getBalance", {_answer_id:0});
  console.log("collator getBalance:", response.decoded.output);
  //
  // let keysDeAuditData = response.decoded.output.keysDeAuditData;
  // console.log("Contract reacted to your keysDeAuditData[0]:", keysDeAuditData[0]);
  //
  //
  // let deauditDataAddr1 = keysDeAuditData[0];
  //
  const deauditAcc = new Account(DeAuditContract, {
    address: deauditAddr,
    // signer: participantKeys,
    client,
  });
  //
  response = await deauditAcc.runLocal("colStake", {});
  console.log("deauditAcc colStake:", response.decoded.output);

  response = await deauditAcc.runLocal("dataDeAudit", {});
  console.log("deauditAcc dataDeAudit:", response.decoded.output);

  let deauditdataAddr = response.decoded.output.dataDeAudit;

  const deauditDataAcc = new Account(DeAuditDataContract, {
    address: deauditdataAddr,
    // signer: participantKeys,
    client,
  });

  response = await deauditDataAcc.runLocal("launchedDeAudit", {});
  console.log("deauditDataAcc launchedDeAudit:", response.decoded.output);


  response = await deauditDataAcc.runLocal("votingCenterKeys", {});
  // console.log("deauditDataAcc votingCenterKeys:", response.decoded.output);

  let indexVC = response.decoded.output.votingCenterKeys[1];
  console.log("deauditDataAcc votingCenterKeys[1]:", indexVC);



  response = await deauditDataAcc.runLocal("votingCenter", {});
  console.log("deauditDataAcc votingCenter:", response.decoded.output.votingCenter[indexVC]);

  response = await deauditDataAcc.runLocal("act4ForVotingCenter", {});
  let act4Addr = response.decoded.output.act4ForVotingCenter[indexVC];
  console.log("act4ForVotingCenter votingCenter:", act4Addr);

  const act4Acc = new Account(Act4Contract, {
    address: act4Addr,
    // signer: participantKeys,
    client,
  });

  response = await act4Acc.runLocal("collator", {});
  console.log("act4Acc collator:", response.decoded.output);

  response = await act4Acc.runLocal("collatorPhotoLink", {});
  console.log("act4Acc collatorPhotoLink:", hex2ascii(response.decoded.output.collatorPhotoLink));

  response = await act4Acc.runLocal("voteMatrix", {});
  console.log("act4Acc voteMatrix:", response.decoded.output);


  response = await deauditAcc.runLocal("stakeOf", {});
  console.log("deauditAcc stakeOf:", response.decoded.output);

  response = await deauditAcc.runLocal("walletOf", {});
  let collatorWallet = response.decoded.output.walletOf[participantAddr];
  console.log("collatorWallet:", collatorWallet);

  const tokenWalletAcc = new Account(TONTokenWalletContract, {
    address: collatorWallet,
    // signer: participantKeys,
    client,
  });

  response = await tokenWalletAcc.runLocal("balance", {_answer_id:0});
  console.log("tokenWalletAcc balance:", response.decoded.output);


  // response = await participantAcc.run("addCollation", {
  //   addressDeAudit:deauditAddr,
  //   indexVotingCenter:indexVC,
  //   linkToCollationPhoto:toHex("https://drive.google.com/file/d/1CbJuffTxds3iooRkKWuVdMO5ENMHAiIh/view?usp=sharing"),
  //   voteMatrix:[0,1,46,0],
  //   grams:5000000000
  // });
  // console.log("Contract reacted to your addCollation:", response.decoded.output);





}

(async () => {
  const client = new TonClient({network: { endpoints: [networks[networkSelector]],},});
  try {
    console.log(hello[networkSelector]);
    await main(client);
    process.exit(0);
  } catch (error) {
    if (error.code === 504) {
      console.error(`Network is inaccessible. Pls check connection`);
    } else {
      console.error(error);
    }
  }
  client.close();
})();
