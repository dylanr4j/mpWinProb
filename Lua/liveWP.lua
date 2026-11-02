local ADDR = {
    turn    = 0x8029151C,  -- turn counter address

    p1_star = 0x80290CD1, p1_coin = 0x80290CBF,
    p2_star = 0x80290DE1, p2_coin = 0x80290DCF,
    p3_star = 0x80290EF1, p3_coin = 0x80290EDF,
    p4_star = 0x80291001, p4_coin = 0x80290FEF,
}

local TOTAL_TURNS = 15
local TURNS_PATH  = "mario_party_log.csv"

-- MODEL COEFFICIENTS -- 
local W_TURNS_REMAINING = -0.04
local W_STAR_DIFF       = 0.77
local W_COIN_DIFF       = 0.0025
local INTERCEPT         = -0.49

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

local function sigmoid(z)
    return 1 / (1 + math.exp(-z))
end

local function compute_win_probs(state)
    local stars = {state.p1_star, state.p2_star, state.p3_star, state.p4_star}
    local coins = {state.p1_coin, state.p2_coin, state.p3_coin, state.p4_coin}
    local turns_remaining = TOTAL_TURNS - state.turn

    local raw = {}
    for i = 1, 4 do
        local best_other_star = -999
        local best_other_coin = -999
        for j = 1, 4 do
            if j ~= i then
                if stars[j] > best_other_star then best_other_star = stars[j] end
                if coins[j] > best_other_coin then best_other_coin = coins[j] end
            end
        end
        local star_diff = stars[i] - best_other_star
        local coin_diff = coins[i] - best_other_coin

        local z = W_TURNS_REMAINING * turns_remaining
                + W_STAR_DIFF * star_diff
                + W_COIN_DIFF * coin_diff
                + INTERCEPT

        raw[i] = sigmoid(z)
    end

    local total = raw[1] + raw[2] + raw[3] + raw[4]
    local probs = {}
    for i = 1, 4 do
        probs[i] = raw[i] / total
    end
    return probs
end

function onScriptStart()
    SetScreenText("Mario Party tracker: starting...")
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
        last_turn = state.turn
    elseif state.turn ~= last_turn then
        local completed_turn = last_turn
        if completed_turn >= 1 and completed_turn <= TOTAL_TURNS then
            write_turn_row(completed_turn, state)
        end
        last_turn = state.turn
    end

    local probs = compute_win_probs(state)
    SetScreenText(string.format(
        "Turn %d/%d\nP1: %d star %d coin (%.1f%%)\nP2: %d star %d coin (%.1f%%)\nP3: %d star %d coin (%.1f%%)\nP4: %d star %d coin (%.1f%%)",
        state.turn, TOTAL_TURNS,
        state.p1_star, state.p1_coin, probs[1] * 100,
        state.p2_star, state.p2_coin, probs[2] * 100,
        state.p3_star, state.p3_coin, probs[3] * 100,
        state.p4_star, state.p4_coin, probs[4] * 100
    ))
end

function onScriptCancel()
    SetScreenText("Tracker stopped.")
end
