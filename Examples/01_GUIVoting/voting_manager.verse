using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }


voting_manager := class(creative_device):

    @editable
    VoteGUITrigger : trigger_device = trigger_device{}

    # Each trigger in this list will be used to increment the vote for the corresponding weapon type
    # 0 = All Weapons
    # 1 = Shotguns Only
    # 2 = Snipers Only
    # 3 = Chapter5 Only
    # 4 = Machine Guns Only
    # 5 = Not a gun Only
    @editable
    ModeVoteTriggers : []trigger_device = array{}

    # Each trigger in this list will be used to increment the vote for the corresponding map
    # 0 = Pirates
    # 1 = Tilted
    @editable
    MapVoteTriggers : []trigger_device = array{}

    var VotingData<private> : voting_data = voting_data{}

    var PlayerData : [player]player_data = map{}

    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        
        # Initialization
        VotingData.Init()
        InitSpawners()
        InitVoteTriggers()

        spawn {ShowVotingGUI()}

    # Set each vote trigger to increment the corresponding weapon type
    InitVoteTriggers():void=
        if (ModeVoteTriggers[0].TriggeredEvent.Subscribe(OnVoteForAll)){}
        if (ModeVoteTriggers[1].TriggeredEvent.Subscribe(OnVoteForShotguns)){}
        if (ModeVoteTriggers[2].TriggeredEvent.Subscribe(OnVoteForSnipers)){}
        if (ModeVoteTriggers[3].TriggeredEvent.Subscribe(OnVoteForChapter5)){}
        if (ModeVoteTriggers[4].TriggeredEvent.Subscribe(OnVoteForMachineGuns)){}
        if (ModeVoteTriggers[5].TriggeredEvent.Subscribe(OnVoteForNotAGun)){}

        if (MapVoteTriggers[0].TriggeredEvent.Subscribe(OnVoteForPirates)){}
        if (MapVoteTriggers[1].TriggeredEvent.Subscribe(OnVoteForTilted)){}

    # Grab every spawner in the world, and subscribe to the SpawnedEvent
    InitSpawners():void=
        # Give each spawner an OnSpawned event
        Spawners := GetCreativeObjectsWithTag(spawner{})
            for (Obj : Spawners):
                if (Spawner := player_spawner_device[Obj]):
                    Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    # Any time anyone is spawned, either from death or new spawn, this is called
    InitPlayer(Player : player):void=
        if: 
            Agent := agent[Player]
            Fort := Agent.GetFortCharacter[]
        then:
            # If the player already exists, do nothing
            if (Existing := PlayerData[Player]){}
            else: # Otherwise, create a new player data object
                # Create a new player data object, initialized with the Player object
                PD := player_data{Player := Player}
                PD.Init()

                # Store the new player data object in the map
                if (set PlayerData[Player] = PD) {}

    # Shows every active player the voting GUI
    ShowVotingGUI()<suspends>:void =
        Sleep(0.0)
        for (Player -> PD : PlayerData):
            if:
                Agent := agent[Player]
                Fort := Agent.GetFortCharacter[]
            then:
                VoteGUITrigger.Trigger(Agent)

    GetVotingData()<transacts>:voting_data=
        return VotingData


        
    # -----------------------------           
    # Events
    # - OnVoteForAll
    # - OnVoteForShotguns
    # - OnVoteForSnipers
    # - OnVoteForPistols
    # - OnVoteForMachineGuns
    # - OnVoteForNotAGun
    # - OnVoteFotChapter5
    # - OnPlayerSpawned
    # - OnPlayerLeftServer
    # -----------------------------
    OnVoteForAll(Agent : ?agent):void = VotingData.VoteMode(0)
    OnVoteForShotguns(Agent : ?agent):void = VotingData.VoteMode(1)
    OnVoteForSnipers(Agent : ?agent):void = VotingData.VoteMode(2)
    OnVoteForPistols(Agent : ?agent):void = VotingData.VoteMode(3)
    OnVoteForMachineGuns(Agent : ?agent):void = VotingData.VoteMode(4)
    OnVoteForNotAGun(Agent : ?agent):void = VotingData.VoteMode(5)
    OnVoteForChapter5(Agent : ?agent):void = VotingData.VoteMode(3)

    OnVoteForPirates(Agent : ?agent):void = VotingData.VoteMap(0)
    OnVoteForTilted(Agent : ?agent):void = VotingData.VoteMap(1)

    # Initializes player on spawn
    OnPlayerSpawned(Agent : agent):void=
        if (Player := player[Agent]):
            InitPlayer(Player)

    # When the player leaves, dispose of their player data object
    OnPlayerLeftServer(PlayerLeaving : player):void=
        if (PD := PlayerData[PlayerLeaving]):
            PD.Dispose()

            # Remove the player from the PlayerData map to free up memory
            var NewPlayerDataMap : [player]player_data = map{}

            for (Key -> Value : PlayerData, Key <> PlayerLeaving):
                set NewPlayerDataMap = ConcatenateMaps(NewPlayerDataMap, map{Key => Value})
            
            set PlayerData = NewPlayerDataMap

