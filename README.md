# Ground Control Redux
---
This is my personal fork of the Ground Control gamemode for Garry's Mod. It'll have a few updates to it.

Ground Control Redux can be found on the Steam workshop [here](https://steamcommunity.com/sharedfiles/filedetails/?id=2034529088).

## Expanded Features:
- Helmets supported
- More armor vest options
- Loadout point-buy system, where your point limit increases with your score in the game
- New gamemodes, VIP Escort and Intel Retrieval
- (Planned) UI update
- (Planned) Support ArcCW, TFA bases

## Code style:
---
This is as much a reminder for myself as it is for anyone who's thinking of contributing a PR.
1. Use [this glua linter](https://marketplace.visualstudio.com/items?itemName=goz3rr.vscode-glualint)
2. `!` for negation instead of `not`
3. `!=` for not equals instead of `~=`
4. `PascalCase` for functions (this is more or less the convention on the Gmod wiki)
5. `camelCase` for variables unless they're constants, in which case use `ALL_CAPS`
6. 4-space indents
7. `func(var1, var2, var3)`,  `{var1, var2, var3}`, `var1 = var2 / var3`.  
Basically: 
    - No spaces next to any sort of bracket
    - Spaces between comma-separated values
    - Spaces between operators
