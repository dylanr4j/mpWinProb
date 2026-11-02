local ADDR = {
    turn    = 0x8029151C,  -- turn counter address

    p1_star = 0x80290CD1, p1_coin = 0x80290CBF,
    p2_star = 0x80290DE1, p2_coin = 0x80290DCF,
    p3_star = 0x80290EF1, p3_coin = 0x80290EDF,
    p4_star = 0x80291001, p4_coin = 0x80290FEF,
}

local TOTAL_TURNS = 15
local TURNS_PATH  = "mario_party_log.csv"

local GAME_ID = os.time()

local initialized = false
local last_turn = nil

local function write_header_if_needed(path, header)
    local f = io.open(path, "r")
    if f == nil then
        local out = io.open(path, "w")
        out:write(header .. "\n")
        out:close()
    else
        f:close()
    end
end

local function read_state()
    return {
        turn    = ReadValue8(ADDR.turn),
        p1_star = ReadValue8(ADDR.p1_star), p1_coin = ReadValue8(ADDR.p1_coin),
        p2_star = ReadValue8(ADDR.p2_star), p2_coin = ReadValue8(ADDR.p2_coin),
        p3_star = ReadValue8(ADDR.p3_star), p3_coin = ReadValue8(ADDR.p3_coin),
        p4_star = ReadValue8(ADDR.p4_star), p4_coin = ReadValue8(ADDR.p4_coin),
    }
end

local function write_turn_row(completed_turn, state)
    local out = io.open(TURNS_PATH, "a")
    local turns_remaining = TOTAL_TURNS - completed_turn
    out:write(string.format(
        "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
        GAME_ID, completed_turn, turns_remaining,
        state.p1_star, state.p1_coin,
        state.p2_star, state.p2_coin,
        state.p3_star, state.p3_coin,
        state.p4_star, state.p4_coin
    ))
    out:close()
end

function onScriptStart()
    SetScreenText("Mario Party tracker: running...")
end

function onScriptUpdate()
    if not initialized then
        write_header_if_needed(TURNS_PATH,
            "game_id,turn,turns_remaining,p1_star,p1_coin,p2_star,p2_coin,p3_star,p3_coin,p4_star,p4_coin")
        last_turn = nil
        initialized = true
    end

    local state = read_state()

    if last_turn == nil then
        -- First frame we see: nothing has completed yet, just start tracking from here
        last_turn = state.turn
    elseif state.turn ~= last_turn then
        local completed_turn = last_turn
        if completed_turn >= 1 and completed_turn <= TOTAL_TURNS then
            write_turn_row(completed_turn, state)
        end
        last_turn = state.turn
    end

    SetScreenText(string.format(
        "Tracking game %d\nTurn %d/%d | P1:%d★ P2:%d★ P3:%d★ P4:%d★",
        GAME_ID, state.turn, TOTAL_TURNS,
        state.p1_star, state.p2_star, state.p3_star, state.p4_star
    ))
end

function onScriptCancel()
    SetScreenText("Tracker stopped.")
end
