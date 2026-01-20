unit PluginConst;

interface

const
  TARGET_TIME = 2000;
type
  PIcoInfo = ^TIcoInfo;
  TIcoInfo = record
    Size: Cardinal;
    Data: Pointer;
  end;

  TL2Status = (lsOff, lsOffline, lsOnline);
  TL2Race = (rtHuman, rtElf, rtDarkElf, rtOrc, rtDwarf, rtKamael, rtErthea, rtUnknown);
  TL2Class = (lcError, lcDrop, lcNpc, lcPet, lcChar, lcUser, lcBuff, lcSkill, lcItem);
  TLootType = (ldLooter, ldRandom, ldRandomSpoil, ldOrder);
  TStoreType = (stNone, stSell, stPrepareSell, stBuy, stPrepareBuy, stManufacture,
                stPrepareManufacture, stObservingGames, stSellPackage);

  TL2Action = (laNull, laSpawn, laDelete, laPetSpawn, laPetDelete, laPetJoin,
               laPetLeave, laCharJoin, laInvite, laDie, laRevive, laMyRevive, laStats,
               laMyTarget, laMyUnTarget, laTarget, laUnTarget, laInGame, laBuffs, laPartyBuffs,
               laSkills, laConfirmDlg, laDlg, laSysMsg,
               laMoveType, laWaitType, laMyWaitType, laStart, laStop, laStartAttack,
               laStopAttack, laCast, laCancelCast, laMyCancelCast, laCastFailed, laMyCastFailed, laTeleport, laInvUpdate,
               laAutoSoulShot, laNpcTrade, laChat, laKey, laCharSelect, laLeaveParty,
               laPost, laLearn,
               laAll, laMyCast, laDelay, laStatus, laAuction, laAuctionSL, atCaptcha,
               atMail, atTaxRate, laLoginState);

  TL2Actions = set of TL2Action;

  TL2ChatType = (ctALL, ctSHOUT, ctPRIVATE, ctPARTY, ctCLAN, ctSYSTEM, ctPETITION,
                 ctCONSULTANT, ctTRADE, ctALLIANCE, ctANNOUNCEMENT, ctFERRY,
                 ctFRIEND, ctMSN, ctPARTY_ROOM, ctCOMMANDER, ctCOMMAND_CHANNEL,
                 ctHERO, ctCRITICAL_ANNOUNCEMENT, ctSCREEN_ANNOUNCEMENT,
                 ctTERRITORY, ctMULTI_PARTY, ctNPC_LOCAL, ctNPC_SHOUT);

  TWaitTypeObj =(owMobs, owSkeepMob, owSkeepOffZone,
                 owDropSkeep, owDropSkeepMobs, owDropSkeepInFight,
                 owSkeepMobHP, owSkeepMobAgroHP, owSkeepMobInv);

  TRestartType = (rtTown, rtClanHall, rtCastle, rtFort, rtFlags);

  TZoneType = (ztGeneral, ztPeace, ztPvP, ztSiege, ztSevenSigns, ztAlt, ztUnknown);

  TStorageLimit = record
    Inventory   : Cardinal;
    WareHouse   : Cardinal;
    Freight     : Cardinal;
    PrivateSell : Cardinal;
    PrivateBuy  : Cardinal;
    DwarfRecipe : Cardinal;
    CommonRecipe: Cardinal;
  end;

  TXYZ = packed record
    X, Y, Z: Integer;
  end;

  TVector = record
    X, Y, Z: Single;
  end;
  TMessageType = (mtSystem, mtAll, mtPrivate, mtParty, mtClan, mtFriend, mtShout, mtScreen);

implementation

end.
