local BossRewardsMod = RegisterMod("Boss Rewards Mod", 1)

-- Cada jugador guardará sus propios bonus dentro de su GetData()

local recompensas_stats = {
    CacheFlag.CACHE_DAMAGE,
    CacheFlag.CACHE_FIREDELAY,
    CacheFlag.CACHE_SPEED,
    CacheFlag.CACHE_LUCK,
    CacheFlag.CACHE_RANGE,
    CacheFlag.CACHE_SHOTSPEED
}

local nombres_stats = {
    [CacheFlag.CACHE_DAMAGE] = "Daño",
    [CacheFlag.CACHE_FIREDELAY] = "Cadencia",
    [CacheFlag.CACHE_SPEED] = "Velocidad",
    [CacheFlag.CACHE_LUCK] = "Suerte",
    [CacheFlag.CACHE_RANGE] = "Rango",
    [CacheFlag.CACHE_SHOTSPEED] = "Velocidad de disparo"
}

local pendingCheck = false

local function AlMorirEnemigo(_, npc)
    if npc:IsBoss() then
        pendingCheck = true
    end
end

local function ComprobarSalaLimpia(_)
    if not pendingCheck then return end

    local room = Game():GetRoom()

    if room:GetAliveEnemiesCount() > 0 then
        Isaac.DebugString("BossRewardsMod: aun quedan enemigos, ignorando")
        return
    end

    pendingCheck = false

    Isaac.DebugString("BossRewardsMod: combate terminado, dando recompensa")

    local game = Game()
    local hud = game:GetHUD()
    local numJugadores = game:GetNumPlayers()

    for i = 0, numJugadores - 1 do
        local player = Isaac.GetPlayer(i)

        if not player:IsCoopGhost() then

            -- Obtenemos (o creamos si no existe) la tabla de bonus de este jugador
            local data = player:GetData()
            if not data.bossBonus then
                data.bossBonus = {
                    damage = 0,
                    tears = 0,
                    speed = 0,
                    luck = 0,
                    range = 0,
                    shotSpeed = 0
                }
            end

            local tipo_recompensa = math.random(1, 2)

            if tipo_recompensa == 1 then
                Isaac.DebugString("BossRewardsMod: dando vida al jugador")
                local tipo_vida = math.random(1, 3)

                if tipo_vida == 1 then
                    player:AddHearts(2)
                    hud:ShowItemText("Boss Reward", "+1 Corazon rojo")
                elseif tipo_vida == 2 then
                    player:AddSoulHearts(2)
                    hud:ShowItemText("Boss Reward", "+1 Corazon de alma")
                else
                    player:AddBlackHearts(2)
                    hud:ShowItemText("Boss Reward", "+1 Corazon negro")
                end

                SFXManager():Play(SoundEffect.SOUND_1UP, 1, 0, false, 1)

            elseif tipo_recompensa == 2 then
                Isaac.DebugString("BossRewardsMod: dando stat al jugador")
                local stat_elegido = recompensas_stats[math.random(1, #recompensas_stats)]

                if stat_elegido == CacheFlag.CACHE_DAMAGE then
                    data.bossBonus.damage = data.bossBonus.damage + 1

                elseif stat_elegido == CacheFlag.CACHE_FIREDELAY then
                    data.bossBonus.tears = data.bossBonus.tears + 0.5

                elseif stat_elegido == CacheFlag.CACHE_SPEED then
                    data.bossBonus.speed = data.bossBonus.speed + 0.25

                elseif stat_elegido == CacheFlag.CACHE_LUCK then
                    data.bossBonus.luck = data.bossBonus.luck + 1

                elseif stat_elegido == CacheFlag.CACHE_RANGE then
                    data.bossBonus.range = data.bossBonus.range + 10

                elseif stat_elegido == CacheFlag.CACHE_SHOTSPEED then
                    data.bossBonus.shotSpeed = data.bossBonus.shotSpeed + 0.75
                end

                player:AddCacheFlags(stat_elegido)
                player:EvaluateItems()

                local nombreStat = nombres_stats[stat_elegido] or "Stat"
                hud:ShowItemText("Boss Reward", "+" .. nombreStat)
                SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1, 0, false, 1)
            end

        end
    end
end

local function AplicarStats(_, player, cacheFlag)

    local data = player:GetData()
    local bonus = data.bossBonus

    -- Si este jugador aún no ha matado ningún boss, no tiene tabla de bonus todavía
    if not bonus then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + bonus.damage

    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay - bonus.tears

    elseif cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + bonus.speed

    elseif cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + bonus.luck

    elseif cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + bonus.range

    elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + bonus.shotSpeed
    end
end

-- La probabilidad de Angel Room se aplica AL ENTRAR en la sala de boss,
-- antes de que empiece el combate, para que le de tiempo al juego de tenerla
-- en cuenta cuando decide qué puerta abrir al matar al boss.
local function AlEntrarSala()
    local room = Game():GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS and not room:IsClear() then
        if math.random(1, 3) == 3 then
            local nivel = Game():GetLevel()
            Isaac.DebugString("BossRewardsMod: dando probabilidad de angel room al entrar en sala de boss")
            nivel:AddAngelRoomChance(0.50)
        end
    end
end

local json = require("json")

local function GuardarProgreso(_)
    local data = {}
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local pdata = player:GetData()
        if pdata.bossBonus then
            data[tostring(i)] = pdata.bossBonus
        end
    end
    BossRewardsMod:SaveData(json.encode(data))
end

local function CargarProgreso(_, isContinued)
    if not isContinued then
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            local pdata = player:GetData()
            pdata.bossBonus = {
                damage = 0, tears = 0, speed = 0,
                luck = 0, range = 0, shotSpeed = 0
            }
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
        Isaac.DebugString("BossRewardsMod: partida nueva, reiniciando bonus")
        return
    end

    if not BossRewardsMod:HasData() then return end
    local data = json.decode(BossRewardsMod:LoadData())
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local pdata = player:GetData()
        if data[tostring(i)] then
            pdata.bossBonus = data[tostring(i)]
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
    end
end

BossRewardsMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GuardarProgreso)
BossRewardsMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CargarProgreso)
BossRewardsMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, AlMorirEnemigo)
BossRewardsMod:AddCallback(ModCallbacks.MC_POST_UPDATE, ComprobarSalaLimpia)
BossRewardsMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AplicarStats)
BossRewardsMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, AlEntrarSala)