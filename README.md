# Hockey Stat Filter Tool

A command line tool to filter yearly hockey stats for players since 2007.

I wrote this to help a little with my fantasy hockey. It allows me to find which players meet my desired criteria for a draft.
I also wanted to learn a little awk and this seemed like a task that it is well suited for.
Though probably not most peoples first choice for working with statistical data :)

Example:
```
$> ./stats "g=30" "a=40" "hits=50"
-- Conditions: A>=40, G>=30, S>=300, 

Player                POS  GP   G    A    PTS  DIF  PPP  S    BLK  Year
-----------------------------------------------------------------------
Zach Parise           C    81   38   44   82   24   26   347  34   2009
Zach Parise           LW   82   45   49   94   30   30   364  17   2008
Vincent Lecavalier    C    81   40   52   92   -17  29   318  21   2007
Phil Kessel           RW   82   37   43   80   -5   20   305  30   2013
Patrick Sharp         LW   82   34   44   78   13   25   313  27   2013
Jarome Iginla         RW   82   50   48   98   27   33   338  10   2007
James Neal            LW   80   40   41   81   6    30   329  15   2011
Ilya Kovalchuk        LW   77   37   46   83   -9   29   310  18   2011
Henrik Zetterberg     C    77   31   42   73   13   30   309  31   2008
Henrik Zetterberg     LW   75   43   49   92   30   36   358  16   2007
----------------  10  -------------------------------------------------
Evgeni Malkin         C    75   50   59   109  18   34   339  41   2011
Eric Staal            C    82   38   44   82   -2   35   310  33   2007
Alex Ovechkin         LW   72   50   59   109  45   36   368  20   2009
Alex Ovechkin         LW   79   56   54   110  8    46   528  32   2008
Alex Ovechkin         LW   79   32   53   85   24   24   367  23   2010
----------------  15  -------------------------------------------------

-- Players with multiple seasons --
Alex Ovechkin          2008, 2009, 2010, 
Zach Parise            2008, 2009, 
Henrik Zetterberg      2007, 2008,
```

# Categories
all conditions are entered with an = sign for simplicity. This will return all records that have a value >= the value given.
- "player"
- "age"
- "pos" -> position
- "tm" -> team
- "gp" -> games played
- "g" -> goals
- "a" -> assists
- "pts" -> points
- "p/gp" -> points per game
- "dif" -> +/- (goal differntial)
- "pim" -> penaty minutes
- "evg" -> even strength goals
- "ppg" -> power play goals
- "shg" -> short handed goals
- "gwg" -> game winning goals
- "eva" -> even strength assists
- "ppa" -> power play assists
- "sha" -> short handed goals
- "ppp" -> power play points (ppg + ppa)
- "s" -> shots
- "spr" -> shooting percentage
- "toi" -> total time on ice (season)
- "avt" -> average ice time per game
- "blk" -> blocks
- "hit" -> hits
- "fow" -> face offs won
- "fol" -> face offs lost
- "fpr" -> face off percentage
- "year"
- "fpt" -> fan points
- "f/g" -> fan ponts per game

# Configuration
There is also a configuration file to allow default display behaviour and fan point values.
More information is available in config file.

**\#stats** -> Default categories to show when printing results.
- show == 1  - Print specified categories. (default)
- show == 0  - Only print the categories specified when running the script.
- sort player  - The category to sort by. Only uses the first argument. (default player)
- columns pos gp g a pts dif ppp s blk  - The categories to print. (default pos gp g a pts dif ppp s blk)
The values must be seperated by a space. The desired categories should all be on the same line.

**\#fpts** -> Values used for fpts and f/g calculations.
Defaults:
- g=3
- a=2
- dif=1
- pim=0.4
- ppp=1
- s=0.4
- blk=0.4
They must be seperated with only an '=' and listed on its own line.
