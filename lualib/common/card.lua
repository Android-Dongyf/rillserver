-- 扑克通用，定义52张牌
local math = math
local type = type
local ipairs = ipairs
local tostring = tostring
local string = string
local table = table

local Card = {}

--[[    card 的编号从1开始，rank黑红梅方
    1- 52   分别是52张牌
    53 小猴
    54 大猴

    card index类型为uint8 从0 到 256
             除以上其他皆为背面
    card = { suit=1, rank = 1 }
]]

-- 牌的类型
local CARD_SUIT = {
    SPADE   = 1,  -- 黑
    HEART   = 2,  -- 红
    CLUB    = 3,  -- 梅
    DIAMOND = 4,  -- 方
    MONKEY  = 5,  -- 猴
}
Card.CARD_SUIT = CARD_SUIT

-- 扑克基础类
local CARD_RANK = {
    -- 背面
    NONE    = 0,
    TWO     = 1,
    THREE   = 2,
    FOUR    = 3,
    FIVE    = 4,
    SIX     = 5,
    SEVEN   = 6,
    EIGHT   = 7,
    NINE    = 8,
    TEN     = 9,
    JACK    = 10,
    QUEEN   = 11,
    KING    = 12,
    ACE     = 13,

    TWO_TRANS   = 20,   -- 转化过后的2
    MONKEY      = 21,   -- 转化过后的王
    MONKEY1     = 22,   -- 转化过后的小王
    MONKEY2     = 23,   -- 转化过后的大王
}
Card.CARD_RANK = CARD_RANK

-- 价值转换偏移量
local TRANS_OFFEST = CARD_RANK.TWO_TRANS - CARD_RANK.TWO
Card.TRANS_OFFEST = TRANS_OFFEST

local CARD_STR_RANK = {
    -- 背面
    ['2'] = CARD_RANK.TWO,
    ['3'] = CARD_RANK.THREE,
    ['4'] = CARD_RANK.FOUR,
    ['5'] = CARD_RANK.FIVE,
    ['6'] = CARD_RANK.SIX,
    ['7'] = CARD_RANK.SEVEN,
    ['8'] = CARD_RANK.EIGHT,
    ['9'] = CARD_RANK.NINE,
    T = CARD_RANK.TEN,
    J = CARD_RANK.JACK,
    Q = CARD_RANK.QUEEN,
    K = CARD_RANK.KING,
    A = CARD_RANK.ACE,
}
Card.CARD_STR_RANK = CARD_STR_RANK

local CARD_RANK_STR = {
    -- 背面
    [CARD_RANK.TWO] = '2',
    [CARD_RANK.THREE] = '3',
    [CARD_RANK.FOUR] = '4',
    [CARD_RANK.FIVE] = '5',
    [CARD_RANK.SIX] = '6',
    [CARD_RANK.SEVEN] = '7',
    [CARD_RANK.EIGHT] = '8',
    [CARD_RANK.NINE] = '9',
    [CARD_RANK.TEN] = 'T',
    [CARD_RANK.JACK] = 'J',
    [CARD_RANK.QUEEN] = 'Q',
    [CARD_RANK.KING] = 'K',
    [CARD_RANK.ACE] = 'A',
}
Card.CARD_RANK_STR = CARD_RANK_STR

-- 面值特征字符
local CARD_RANK_CHAR = { '2', '3', '4', '5', '6', '7', '8', '9', 'X', 'J', 'Q', 'K', 'A', [CARD_RANK.MONKEY1]='V', [CARD_RANK.MONKEY2]='W'}
Card.CARD_RANK_CHAR = CARD_RANK_CHAR

-- 牌编号对应字符
local CARD_INDEX_CHAR = {'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'A', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'N',
                   'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'a', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'n', '1', '2'}

local CARD_CHAR_INDEX = {}
for i, v in ipairs(CARD_INDEX_CHAR) do
    CARD_CHAR_INDEX[v] = i
end

Card.CARD_INDEX_CHAR = CARD_INDEX_CHAR
Card.CARD_CHAR_INDEX = CARD_CHAR_INDEX

-- 洗牌算法
function Card.shuffle( items )
    local n = #items
    for i = n, 1, - 1 do
        local j = math.random(n)
        items[i], items[j] = items[j], items[i]
        n = n - 1
    end
end

--洗牌并且任何一张牌不在原来的位置
function Card.shuffleCycle(items)
    local n = #items
    for i = n, 1, - 1 do
        local j = math.random(n - 1)
        items[i], items[j] = items[j], items[i]
        n = n - 1
    end
end

-- index转化为card
local cardCache = {}
function Card.indexToCard( index )
    local card = cardCache[index]
    if not card then
        card = {index = index}
        if index > 0 and index <= 54 then
            card.suit = math.ceil( index / 13 )
            card.rank = math.mod( index - 1, 13 ) + 1
            card.str = Card.cardToStr(card)
            card.char = Card.cardToChar(card)
        else
            card.suit = CARD_SUIT.MONKEY
            card.rank = CARD_RANK.NONE
            card.str = '[]'
            card.char = '?'
        end
        cardCache[index] = card
    end
    return card
end

-- card转化成index
function Card.cardToIndex(card)
    if card.index then return card.index end

    local suit = card.suit or 0
    local rank = card.rank or 0

    if suit >= CARD_SUIT.SPADE and suit <= CARD_SUIT.DIAMOND then
        if rank >= CARD_RANK.TWO and rank <= CARD_RANK.ACE then
            return (suit - 1) * 13 + rank
        end
    elseif suit == CARD_SUIT.MONKEY and (rank == 1 or rank == 2) then
        return (suit - 1) * 13 + rank
    end

    return 0
end

-- 牌列表转化成牌编号列表
function Card.cardsToIndices( cards )
    local indices = {}
    for i, card in ipairs(cards) do
        indices[i] = Card.cardToIndex(card)
    end
    return indices
end

-- 花色和面值转成牌编号
function Card.suitRankToIndex( suit, rank )
    return (suit - 1) * 13 + rank
end

-- 转化花色
function Card.suitToStr(suit)
    if suit == CARD_SUIT.DIAMOND then
        return "♦"
    elseif suit == CARD_SUIT.CLUB then
        return "♣"
    elseif suit == CARD_SUIT.HEART then
        return "♥"
    elseif suit == CARD_SUIT.SPADE then
        return "♠"
    end
    return "■"
end

function Card.strToSuit( str )
    if str == "♦" then
        return CARD_SUIT.DIAMOND
    elseif str == "♣" then
        return CARD_SUIT.CLUB
    elseif str == "♥" then
        return CARD_SUIT.HEART
    else
        return CARD_SUIT.SPADE
    end
end

-- 转化大小
function Card.rankToStr(rank)
    return CARD_RANK_STR[rank]
end

-- 单个字符改成rank
function Card.strToRank(str)
    return CARD_STR_RANK[str]
end

-- 将card转化成str
function Card.cardToStr(card)
    -- Logger.log('cardToStr'..tostring(card))
    if not card then
        return "nil"
    end

    if type(card) == 'number' then
        card = Card.indexToCard(card)
    end

    if card.suit == CARD_SUIT.MONKEY then
        if card.rank == 1 then
            return '▲'
        elseif card.rank == 2 then
            return '★'
        else
            return "■"
        end
    end

    return Card.suitToStr(card.suit) .. Card.rankToStr(card.rank)
end

-- 从string到card，测试接口
function Card.strToCard( str )
    local suit = Card.strToSuit( string.sub(str, 1,3) )
    local rank = Card.strToRank( string.sub(str, 4, 4) )

    return Card.cardToIndex( {suit=suit, rank=rank})
end

function Card.cardListToStr(cardList)
    local str = ''
    for i, card in ipairs(cardList) do
        str = str .. ' ' .. Card.cardToStr(card)
    end
    return str
end

--转换成旧版牌值
-- 0 方块，1 梅花，2 红桃，3 黑桃
function Card.cardToOld(index)
    local card = Card.indexToCard(index)
    local suit, rank = card.suit, card.rank
    if rank == 13 then
        rank = 1
    else
        rank = rank + 1
    end
    if suit == CARD_SUIT.DIAMOND then       --方块

    elseif suit == CARD_SUIT.CLUB then      --梅花
        rank = 16 + rank
    elseif suit == CARD_SUIT.HEART then     --红桃
        rank = 32 + rank
    elseif suit == CARD_SUIT.SPADE then     --黑桃
        rank = 48 + rank
    else
        rank = 64 + rank
    end
    -- Logger.log("xxxxxxxxxxxxxx    : ".. index .. " change to " .. string.format("%02x", rank))
    return string.format("%02x", rank)
end

-- 转化牌（或牌编号）面值特征字符
function Card.cardToChar( card )
    if type(card) == 'number' then
        card = Card.indexToCard(card)
    end
    if card.char then return card.char end
    if card.suit == CARD_SUIT.MONKEY then
        return CARD_RANK_CHAR[card.rank + CARD_RANK.MONKEY] or '?'
    end
    return CARD_RANK_CHAR[card.rank] or '?'
end

-- 转换牌组（或牌编号列表）面值特征串
function Card.cardListToChars( cardList )
    local str = ''
    for _, card in ipairs(cardList) do
        str = str .. Card.cardToChar(card)
    end
    return str
end

-- 从牌组（或牌编号列表）中提取给定面值特征串所对应的子牌组（或牌编号列表）
-- @cardList 牌（或牌编号）列表，被提取的牌会删除
-- @chars 面值特征串
-- @return 提取的牌（或牌编号）列表
function Card.pickByChars( cardList, chars )
    local pickList = {}
    for i = 1, #chars do
        local char = string.sub(chars, i, i)
        for j, card in ipairs(cardList) do
            if Card.cardToChar(card) == char then
                table.insert(pickList, card)
                table.remove(cardList, j)
                break
            end
        end
    end
    return pickList
end

-- 转换牌编号列表到牌对应字符串
function Card.cardIndicesToChars( indices )
    local str = ''
    for _, index in ipairs(indices) do
        str = str .. (CARD_INDEX_CHAR[index] or '?')
    end
    return str
end

-- 转换牌对应字符串到牌编号列表
function Card.cardCharsToIndices( chars )
    local indices = {}
    for i = 1, #chars do
        indices[i] = CARD_CHAR_INDEX[string.sub(chars, i, i)] or 0
    end
    return indices
end

return Card