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
const { ParticipantContract } = require("./Participant.js");

const pathJsonRoot = './DeAuditRoot.json';
const pathJsonParticipants = './Participants.json';

const indexPartisipant = 0;


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

  let pubkeyCreator = '0x'+rootKeys.keys.public;
  response = await rootAcc.runLocal("getParticipantAddress", {_answer_id:0, pubkeyParticipant:pubkeyCreator});
  console.log("creatorAddr:", response.decoded.output);

  const creatorAcc = new Account(ParticipantContract, {
    address: response.decoded.output.value0,
    signer: rootKeys,
    client,
  });

  // response = await creatorAcc.runLocal("rootDeAudit", {});
  // console.log("Contract reacted to your rootDeAudit:", response.decoded.output);
  //
  // response = await creatorAcc.runLocal("initiatedDeAuditData", {});
  // console.log("Contract reacted to your initiatedDeAuditData:", response.decoded.output);



  let resultArr = JSON.parse(fs.readFileSync(pathJsonParticipants,{encoding: "utf8"}));
  const participantAddress = resultArr[indexPartisipant].address;
  const participantKeys = resultArr[indexPartisipant].keys;
  console.log("participantAddress:", participantAddress);

  const participantAcc = new Account(ParticipantContract, {
    address: participantAddress,
    signer: participantKeys,
    client,
  });


  response = await creatorAcc.run("initVoteAddActionTeamMember", {participantAddr:participantAddress,grams:1000000000});
  console.log("Contract reacted to your initVoteAddActionTeamMember:", response.decoded.output);


  // for (const item of resultArr) {
  //   const participantAddress = item.address;
  //   const participantKeys = item.keys;
  //   let pubkey = '0x'+participantKeys.keys.public;
  //
  //   const participantAcc = new Account(ParticipantContract, {
  //     address: participantAddress,
  //     signer: participantKeys,
  //     client,
  //   });
  //
  //   response = await participantAcc.runLocal("rootDeAudit", {});
  //   console.log("Contract reacted to your rootDeAudit:", response.decoded.output);
  //
  //   response = await participantAcc.runLocal("initiatedDeAuditData", {});
  //   console.log("Contract reacted to your initiatedDeAuditData:", response.decoded.output);
  //
  // }




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