pragma ton-solidity ^0.45.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "../Debot.sol";
import "../Terminal.sol";
import "../AddressInput.sol";
import "../AmountInput.sol";
import "../ConfirmInput.sol";
import "../Menu.sol";

interface IDeAuditRoot {
    function keysDeAudit() external returns (address[] keysDeAudit);
}

interface IDeAudit {
    function getDetails4Debot() external returns (
        uint32 sequentialNumber4Debot,
        bytes  name4Debot,
        address rootDeAudit4Debot,
        address dataDeAudit4Debot,
        address tokenDeAudit4Debot,
        uint256 timeStart4Debot,
        uint256 colPeriod4Debot,
        uint256 valPeriod4Debot,
        uint128 colStake4Debot,
        uint128 valStake4Debot);
}

interface IDeAuditData {
    function votingCenterKeys() external returns (uint256[] votingCenterKeys);
    function getVotingCenter4Debot(uint256 votingCenterCurrentKey) external returns (
        bytes name4Debot,
        bytes location4Debot,
        uint256[] votes4Debot,
        uint256 idVotingPool4Debot,
        uint256 idMunicipalBody4Debot,
        uint256 idDistrict4Debot,
        bool collationStatus4Debot,
        address[] act4Arr4Debot,
        uint256 votingCenterCurrentKeyD
    );
    function candidateKeys() external returns (uint256[] candidateKeys);
    function getCandidate4Debot(uint256 candidateCurrentKey) external returns (
        bytes name4Debot,
        uint256 votes4Debot,
        uint256 candidateCurrentKeyD
    );
}

interface IParticipant {
    function addCollation(address addressDeAudit, uint256 indexVotingCenter, bytes linkToCollationPhoto, uint256[] voteMatrix, uint128 grams) external returns (uint8 status);
    function activeDeAudits() external returns (address[] activeDeAudits);
    function getCurActivity(address curLaunchedDeAudit) external returns (
        bool reg,
        uint8 atype,
        address[] act4Arr,
        address wallet,
        address curDAactiv
    );
}
interface ITONTokenWallet {
    function balance(uint32 _answer_id) external returns (uint128 value0);
}

interface IVotingAuditDebot {
    function preSstart(address m_participantC) external;
}

contract CLdebot is Debot {

    address m_coreDebot;

    //FLD
    //    address DeAuditRoot = address.makeAddrStd(0, 0xeb29541ddefbe0d27642d031c2831b7f573952f3a002fb5b3a9308f7362c225c);
    //NTD
    address DeAuditRoot = address.makeAddrStd(0, 0x93b7fed94a94f158eb0609317545c692492f150c0ca50450f99c050d8bc9b1c9);
    address m_participant;

    bytes m_icon;

    struct CandidateD {
        bytes name;
        uint256 votes;
        uint256 curVotes;
    }

    mapping (uint256 => CandidateD) public candidateD;
    uint256[] public candidateKeysD;

    struct DetailsParamD {
        uint32 sequentialNumber;
        bytes name;
        address rootDeAudit;
        address dataDeAudit;
        address tokenDeAudit;
        uint256 timeStart;
        uint256 colPeriod;
        uint256 valPeriod;
        uint128 colStake;
        uint128 valStake;
        string status;
//        uint8 iD;
    }

    mapping(address => DetailsParamD) public paramDeAuditD;
    address[] public keysDeAuditDataD;

    struct VotingCenterD {
        bytes name;
        bytes location;
        uint256[] votes;
        uint256 idVotingPool;
        uint256 idMunicipalBody;
        uint256 idDistrict;
        bool collationStatus;
        address[] act4Arr;
//        uint256 countAdditionlPhotoLinks;
//        address[] validatorsArr;
        // bytes collatorPhotoLink;
        // bytes[] additionalPhotoLinkArr;
    }

    mapping (uint256 => VotingCenterD) public votingCenterD;
    uint256[] public votingCenterKeysD;


    struct ActivityD {
        bool reg;
        uint8 atype;
        address[] act4Arr;
        address wallet;
        uint128 walletBalance;
    }

    mapping(address => ActivityD) public activitiesD;
    address[] activeDeAuditsD;


    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }
    function preStart(address partic) public {
        m_participant = partic;
        m_coreDebot = msg.sender;
        fetchDA();
        fetchActivities();
        CLmenu();
    }
    function pstart(uint32 index) public {
        fetchDA();
        fetchActivities();
        CLmenu();
    }

    function start() public functionID(0x01) override {
        fetchDA();
        fetchActivities();
        CLmenu();
    }
    /*
        fetch activities
    */

    function fetchActivities() public {
        optional(uint256) pubkey;
        IParticipant(m_participant).activeDeAudits{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchActivities),
        onErrorId : tvm.functionId(someError)
        }();
    }
    function SCfetchActivities(address[] activeDeAudits) public {
        activeDeAuditsD = activeDeAudits;
        for(uint8 i = 0; i < activeDeAuditsD.length; i++){
            fetchCurAvtivity(activeDeAuditsD[i]);
        }
    }

    function fetchCurAvtivity(address curDeAuditforActivD) public {
        optional(uint256) pubkey;
        IParticipant(m_participant).getCurActivity{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchCurAvtivity),
        onErrorId : tvm.functionId(someError)
        }(curDeAuditforActivD);
    }

    function SCfetchCurAvtivity(
        bool reg,
        uint8 atype,
        address[] act4Arr,
        address wallet,
        address curDAactiv
    ) public {
        ActivityD at = activitiesD[curDAactiv];
        at.reg = reg;
        at.atype = atype;
        at.act4Arr = act4Arr;
        at.wallet = wallet;
        activitiesD[curDAactiv] = at;
    }

/*
    fetch wallet info
*/

    function fetchWalletInfo(address wallet) public {
        optional(uint256) pubkey;
        ITONTokenWallet(wallet).balance{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchWalletInfo),
        onErrorId : tvm.functionId(someError)
        }(0);
    }

    function SCfetchWalletInfo(
        uint128 value0
    ) public {
        for(uint8 i = 0; i < activeDeAuditsD.length; i++){
            address curAvtiv = activeDeAuditsD[i];
            ActivityD at = activitiesD[curAvtiv];
            if(at.wallet == msg.sender){
                at.walletBalance = value0;
                activitiesD[curAvtiv] = at;
            }
        }
    }

/*
    Fetch candidates
*/

    function fetchCD(address deAuditAddress) public {
        optional(uint256) pubkey;
        IDeAuditData(deAuditAddress).candidateKeys{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchCD),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchCD(uint256[] candidateKeys) public {
        candidateKeysD = candidateKeys;

        for(uint8 i = 0; i < candidateKeysD.length; i++){
            uint256 curCD = candidateKeysD[i];
            getCDdata(curCD);
        }
    }

    function getCDdata(uint256 curDAD) public {
        optional(uint256) pubkey;
        IDeAuditData(curDADadd).getCandidate4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCgetCDdata),
        onErrorId : tvm.functionId(someError)
        }(curDAD);
    }

    function SCgetCDdata(
        bytes name4Debot,
        uint256 votes4Debot,
        uint256 candidateCurrentKeyD
    ) public {
        CandidateD cd = candidateD[candidateCurrentKeyD];
        cd.name = name4Debot;
        cd.votes = votes4Debot;
        candidateD[candidateCurrentKeyD] = cd;
    }
/*
    FETCH DA
*/
    function fetchDA() public {
        optional(uint256) pubkey;
        IDeAuditRoot(DeAuditRoot).keysDeAudit{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchDA),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchDA(address[] keysDeAudit) public {
        keysDeAuditDataD = keysDeAudit;

        for(uint8 i = 0; i < keysDeAuditDataD.length; i++){
            address curDAD = keysDeAuditDataD[i];
            getDADdata(curDAD);
        }
    }

    function getDADdata(address curDAD) public {

        optional(uint256) pubkey;
        IDeAudit(curDAD).getDetails4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCgetDADdata),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCgetDADdata(
        uint32 sequentialNumber4Debot,
        bytes  name4Debot,
        address rootDeAudit4Debot,
        address dataDeAudit4Debot,
        address tokenDeAudit4Debot,
        uint256 timeStart4Debot,
        uint256 colPeriod4Debot,
        uint256 valPeriod4Debot,
        uint128 colStake4Debot,
        uint128 valStake4Debot
    ) public {
        DetailsParamD dd = paramDeAuditD[msg.sender];
        dd.sequentialNumber = sequentialNumber4Debot;
        dd.name = name4Debot;
        dd.rootDeAudit = rootDeAudit4Debot;
        dd.dataDeAudit = dataDeAudit4Debot;
        dd.tokenDeAudit = tokenDeAudit4Debot;
        dd.timeStart = timeStart4Debot;
        dd.colPeriod = colPeriod4Debot;
        dd.valPeriod = valPeriod4Debot;
        dd.colStake = colStake4Debot;
        dd.valStake = valStake4Debot;
        paramDeAuditD[msg.sender] = dd;
    }
/*
    fetch VC
*/

    function fetchVC(address DADaddress) public {
        optional(uint256) pubkey;
        IDeAuditData(DADaddress).votingCenterKeys{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchVC),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchVC(uint256[] votingCenterKeys) public {
        votingCenterKeysD = votingCenterKeys;

        for(uint8 i = 0; i < votingCenterKeysD.length; i++){
            uint256 curVC = votingCenterKeysD[i];
            getVCdata(curVC);
        }
    }
    function getVCdata(uint256 curVC) public {
        optional(uint256) pubkey;
        IDeAuditData(curDADadd).getVotingCenter4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCgetVCstruct),
        onErrorId : tvm.functionId(someError)
        }(curVC);
    }

    function SCgetVCstruct(
        bytes name4Debot,
        bytes location4Debot,
        uint256[] votes4Debot,
        uint256 idVotingPool4Debot,
        uint256 idMunicipalBody4Debot,
        uint256 idDistrict4Debot,
        bool collationStatus4Debot,
        address[] act4Arr4Debot,
        uint256 votingCenterCurrentKeyD
    ) public {
        VotingCenterD vc = votingCenterD[votingCenterCurrentKeyD];
        vc.name = name4Debot;
        vc.location = location4Debot;
        vc.votes = votes4Debot;
        vc.idVotingPool = idVotingPool4Debot;
        vc.idMunicipalBody = idMunicipalBody4Debot;
        vc.idDistrict = idDistrict4Debot;
        vc.act4Arr = act4Arr4Debot;
        votingCenterD[votingCenterCurrentKeyD] = vc;
    }

    function displayColInfo(uint32 index) public {
        for(uint8 i = 0; i < activeDeAuditsD.length; i++){
            address curAvtiv = activeDeAuditsD[i];
                ActivityD at = activitiesD[curAvtiv];
            Terminal.print(0,format("atype:{} wallet: {} democracy tokens: {}",at.atype,at.wallet,at.walletBalance));

            address[] Act4arr = at.act4Arr;

            for(uint8 i = 0; i < Act4arr.length; i++){
                Terminal.print(0,format("Act4arr: {}",Act4arr[i]));
            }

        }
        CLmenu();
    }

    function CLmenu() public {
        Menu.select("Welcome to Collator menu", "", [
            MenuItem("Refresh data", "",tvm.functionId(pstart)),
            MenuItem("Display Collator info", "",tvm.functionId(displayColInfo)),
            MenuItem("Add collation", "", tvm.functionId(onAddCollation)),
            MenuItem("Back to main menu", "", tvm.functionId(goToCore)),
            MenuItem("Quit", "", 0)
            ]);
    }

/*
    add collation
*/
    function onAddCollation(uint32 index) public {
        MenuItem[] m_menu;
        for(uint8 i = 0; i < keysDeAuditDataD.length; i++){
            address curDA = keysDeAuditDataD[i];
            DetailsParamD da = paramDeAuditD[curDA];
            string status;
                if(uint256(now) >= da.timeStart && (uint256(now) <= (da.colPeriod + da.timeStart + da.valPeriod))){
                    status = "Collation";
                    da.status = status;
                    paramDeAuditD[curDA] = da;
                    string curVdata = format(" - {} -\nStatus: Collation period, Sequential №: {} Collation stake: {} nanoTONs, DeAudit address: {}\n",da.name, da.sequentialNumber,da.colStake,curDA);
                    m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedDA)));
                }else{
                    status = "All other";
                    da.status = status;
                    paramDeAuditD[curDA] = da;
                    string curVdata = format(" - {} -\nStatus: All other, Sequential №: {}, Collation stake: {} nanoTONs, DeAudit address: {}\n",da.name, da.sequentialNumber,da.colStake,curDA);
                    m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedDA)));
                }
        }
        m_menu.push(MenuItem("Back to menu", "", tvm.functionId(pstart)));
        Menu.select("Choose DeAudit:", "",m_menu);
    }


address curDAAddressD;
uint256 curSN;
uint128 CLstake;
address curDADadd;
    function setTouchedDA(uint32 index) public {
        index = index;
        curDAAddressD = keysDeAuditDataD[index];
        DetailsParamD da = paramDeAuditD[curDAAddressD];

        if(da.status != "Collation"){
            Terminal.print(0, "Error take from collation period available");
            onAddCollation(1);
        }else{
            curSN = da.sequentialNumber;
            uint128 stakeBase = uint128(da.colStake);
            curDADadd = da.dataDeAudit;
//            Terminal.print(0, format("DeAudit data address: {}",curDADadd));
            CLstake = stakeBase + 1600000000;
            fetchCD(curDADadd);
            fetchVC(curDADadd);
            Terminal.print(tvm.functionId(onSetLink), format("Selected DeAudit name: {} Sequential №: {} Collation stake: {} nanoTONs\n",da.name, curSN,CLstake));
        }
    }

    function onSetVC() public {
        MenuItem[] m_menu;
        for(uint8 i = 0; i < votingCenterKeysD.length; i++){
            uint256 curVC = votingCenterKeysD[i];
            VotingCenterD vc = votingCenterD[curVC];

            string curVdata = format("{},  Location: {}\n",vc.name, vc.location);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedVC)));
        }
        m_menu.push(MenuItem("Back to menu", "", tvm.functionId(pstart)));
        Menu.select("Choose Voting center:", "",m_menu);
    }

uint256 curVCIndexD;

    function setTouchedVC(uint32 index) public {
        index = index;
        curVCIndexD = votingCenterKeysD[index];
        VotingCenterD vc = votingCenterD[curVCIndexD];
        Terminal.print(tvm.functionId(onSetVoteMatrix), format("Selected Voting Center: {}\n",vc.name));
    }


    function onSetLink2() public {
        onSetLink();
    }
    function onSetLink() public {
        Terminal.input(tvm.functionId(setLink), "Set link to your collation:\n",false);
    }
bytes link;
    function setLink(string value) public {
        link = bytes(value);
        onSetVC();
    }


    function onSetVoteMatrix() public {
        MenuItem[] m_menu;
        for(uint8 i = 0; i < candidateKeysD.length; i++){
            uint256 curCD = candidateKeysD[i];
            CandidateD cd = candidateD[curCD];

            string curVdata = format("Candidate name: {}\n",cd.name);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedCD)));
        }
        m_menu.push(MenuItem("Set link", "", tvm.functionId(onSetLink2)));
        m_menu.push(MenuItem("Deploy Act4", "", tvm.functionId(addCandOnchainCheck)));
        m_menu.push(MenuItem("Back to menu", "", tvm.functionId(pstart)));
        Menu.select("Please enter the vote count for candidates:", "",m_menu);
    }


uint256 curCDIndexD;
bytes canName;

    function setTouchedCD(uint32 index) public {
        index = index;
        curCDIndexD = candidateKeysD[index];
        CandidateD cd = candidateD[curCDIndexD];
        canName = cd.name;

        AmountInput.get(tvm.functionId(saveCandidateVotes), format("Candidate name: {}\n",cd.name),0,0,1000000000000);
    }
    function saveCandidateVotes(uint128 value) public {
        uint256 newValue = uint256(value);

        CandidateD cd = candidateD[curCDIndexD];
        cd.curVotes = newValue;
        candidateD[curCDIndexD] = cd;

        Terminal.print(tvm.functionId(onSetVoteMatrix), format("Selected candidate: {}\n Votes: {}\n", canName,value));
    }

uint256[] VoteMatrixD;
    function addCandOnchainCheck(uint32 index) public {
            for(uint8 i = 0; i < candidateKeysD.length; i++){
                CandidateD cd = candidateD[i];
                VoteMatrixD.push(cd.curVotes);
            }
            ConfirmInput.get(tvm.functionId(checkAns), "Are you sure to deploy Act4?");
    }

    function checkAns(bool value) public {
            if(value){
                addCandOnchain();
            }else{
                CLmenu();
            }

    }
    function addCandOnchain() public {

            optional(uint256) pubkey;
            IParticipant(m_participant).addCollation{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire: 0x123,
            callbackId : tvm.functionId(SCcall),
            onErrorId : tvm.functionId(someError)
            }(curDAAddressD,curVCIndexD,link,VoteMatrixD,CLstake);

    }


/*
    go to core debot
*/
    function goToCore(uint32 index) public {
        IVotingAuditDebot(m_coreDebot).preSstart(m_participant);
    }

/*
    utils
*/

    function SCcall(uint8 status) public {
        if(status == 1){
            Terminal.print(0, "Success, your message sended to blockchain");
            start();
        }else{
            Terminal.print(0, "Error, try again");
            start();
        }
    }

    function someError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("sdkError: {}\nexitCOde:{}", sdkError, exitCode));
        Terminal.print(0, "Back to menu...");
        CLmenu();
    }
    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "RT Voting Audit System 1.0 [Collator]";
        version = "0.1.0";
        publisher = "Radiance Team";
        caption = "DeBot for DeAudit by Radiance Team";
        author = "Radiance Team";
        support = address.makeAddrStd(0, 0x841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94);
        hello = "That's debot for Voting Audit. Developed by Radiance Team";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID ];
    }

}
