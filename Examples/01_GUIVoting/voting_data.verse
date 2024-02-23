using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

voting_data := class<unique>():

    var ModeVoteTotals<private> : []int = array{}

    var MapVoteTotals<private> : []int = array{}

    Init():void=
        set ModeVoteTotals = array{0, 0, 0, 0, 0, 0}
        set MapVoteTotals = array{0, 0}

    # Increase a vote total by 1
    # 0 = All Granters
    # 1 = Shotguns Only
    # 2 = Snipers Only
    # 3 = Chapter5 Only
    # 4 = Machine Guns Only
    # 5 = Not A Gun Only
    VoteMode(Mode : int):void=
        if (set ModeVoteTotals[Mode] += 1){}

    VoteMap(Map : int):void=
        if (set MapVoteTotals[Map] += 1){}

    # Get the current winner of the vote
    # If no one has voted, pick a random gun mode
    # If there is a tie, choose the first one numerically
    GetModeWinner():int=
        # Set up temporary variables
        var Index : int = 0
        
        # Set up variables to keep track of the current "winner"
        var BiggestVote : int = 0
        var BiggestVoteIndex : int = 0

        # Loop through the vote totals to find the biggest vote
        for (Score : ModeVoteTotals):
            # If the current score is bigger than the current biggest vote, update the biggest vote
            if (Score > BiggestVote):
                set BiggestVote = Score
                set BiggestVoteIndex = Index
            set Index = Index + 1

        # Now, if the biggest vote is 0 (no votes), we will randomly pick a gun mode instead
        if (BiggestVote = 0):
            set BiggestVoteIndex = GetRandomInt(0, 5)
        
        return BiggestVoteIndex


    GetMapWinner():int=
        # Set up temporary variables
        var Index : int = 0
        
        # Set up variables to keep track of the current "winner"
        var BiggestVote : int = 0
        var BiggestVoteIndex : int = 0

        # Loop through the vote totals to find the biggest vote
        for (Score : MapVoteTotals):
            # If the current score is bigger than the current biggest vote, update the biggest vote
            if (Score > BiggestVote):
                set BiggestVote = Score
                set BiggestVoteIndex = Index
            set Index = Index + 1

        # Now, if the biggest vote is 0 (no votes), we will randomly pick a gun mode instead
        if (BiggestVote = 0):
            set BiggestVoteIndex = GetRandomInt(0, 1)
        
        Print("BiggestVoteIndex: {BiggestVoteIndex}")
        
        return BiggestVoteIndex




