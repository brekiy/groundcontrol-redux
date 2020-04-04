bot_profiles = {
    {name = "Ranger", accuracy = 1},
    {name = "Doomguy", accuracy = 1},
    {name = "Blazko", accuracy = 1},
    {name = "Visor", accuracy = 0.8},
    {name = "Anarki", accuracy = 0.95},
    {name = "Xaero", accuracy = 0.7},
    {name = "Keel", accuracy = 0.95},
    {name = "Pepe", accuracy = 1},
    {name = "Johnson", accuracy = 0.5},
    {name = "Moore", accuracy = 0.5},
    {name = "Smith", accuracy = 0.5},
    {name = "Bana", accuracy = 0.5},
    {name = "Konig", accuracy = 0.5},
    {name = "Ramirez", accuracy = 0.5},
    {name = "Schmidt", accuracy = 0.5},
    {name = "Golubev", accuracy = 0.5},
}

function getBotName()
    return table.Random(bot_profiles).name
end