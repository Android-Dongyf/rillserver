local utils = require('base.utils')
-- 控制52张牌的类

local Card = Card
local print = print
local table = table
local Table = Table
local makeClass = utils.makeClass
local math = math
local ipairs = ipairs

local Cards = {}
makeClass( Cards )


--初始化扑克牌,ncards 可以初始化多少副
function Cards.init( self, num, ncards )

    -- 52则不包括大小猴，54则包括
    ncards = ncards or 1
    num = num or 52

    self.num = num
    self.ncards = ncards

    self.cards = {}
    for j = 1, ncards do
        for i = 1, num do
            self.cards[ (j-1) * num + i] = i
        end
    end

    self.lastCards = {}

    self:shuffle()
end

--洗牌
function Cards.shuffle( self )
    Card.shuffle( self.cards )
end

--保存当前的牌
function Cards.saveCards( self )
    if #self.cards ~= self.num * self.ncards then
        print('error card only', #self.cards)
        return
    end

    self.lastCards = {}
    for i=1, self.num * self.ncards do
        self.lastCards[i] = self.cards[i]
    end
end

-- 装载最后一次的牌
function Cards.loadCards( self )
    for i=1, self.num * self.ncards do
        self.cards[i] = self.lastCards[i]
    end
end

function Cards.save( self )
    local tab = {}
    tab.num = self.num
    tab.ncards = self.ncards
    tab.cards = self.cards
    tab.lastCards = self.lastCards
    return tab
end

function Cards.load( self, tab )
    self.num = tab.num
    self.ncards = tab.ncards
    self.cards = tab.cards
    self.lastCards = tab.lastCards
end

-- 发牌n为发牌数目，默认都是从末尾拿
function Cards.deal(self, n)
    local num = #self.cards
    if n > num or n < 1 then
        print("error card deal card:", num, " want:",n )
        return
    end

    local ret = {}
    for i = num, num - n + 1, -1 do
        table.insert(ret, self.cards[i])
        self.cards[i] = nil
    end

    return ret
end

-- 发一张牌
function Cards.dealOne(self)
    local n = self:deal( 1 )
    if n then
        return n[1]
    end
end

-- 随机插回一张牌
function Cards.giveBack( self, tb)
    for i,v in ipairs( tb ) do
        if v > 0 then
            table.insert( self.cards, math.random(1, #(self.cards)), v )
        end
    end
end

function Cards.giveOne( self, c )
    self:giveBack( { c } )
end

-- 发一个suit的
function Cards.dealSuit( self, suit )
    -- 对于随机来讲，前后都一样，所以无所谓
    local num = self:getCardNum()

    local x = math.random(1, num )
    local idx = x
    for i = 1, num do
        idx = x + i - 1
        if idx > num then
            idx = idx % num
        end

        if suit == Card.indexToCard( self.cards[ idx ] ).suit then
            break
        end
    end

    local card = self.cards[idx]
    table.remove(self.cards, idx)
    return card
end

-- 发一个rank的
function Cards.dealRank( self, rank )
    -- 对于随机来讲，前后都一样，所以无所谓
    local num = self:getCardNum()

    local x = math.random(1, num )
    local idx = x
    for i = 1, num do
        idx = x + i - 1
        if idx > num then
            idx = idx % num
        end

        if rank == Card.indexToCard( self.cards[ idx ] ).rank then
            break
        end
    end

    local card = self.cards[idx]
    table.remove(self.cards, idx)
    return card
end

-- 发一个固定牌，有牌则返回c,无则返回空
function Cards.dealSuitRank( self, suit, rank )
    local c = Card.cardToIndex( {suit=suit, rank=rank})
    local idx = 0
    for i, v in ipairs(self.cards) do
        if v == c then
            idx = i
            break
        end
    end
    if idx > 0 then
        table.remove(self.cards, idx)
        return c
    end
end

-- 获取剩余的牌
function Cards.getCardNum(self)
    return #self.cards
end

-- 发了多少张
function Cards.getDealNum( self )
    return self.num * self.ncards - #self.cards
end

-- 查找特定牌
function Cards.find( self, suit, rank )
    return Table.getIndex(self.cards, Card.suitRankToIndex(suit, rank))
end

-- 添加特定牌
function Cards.add( self, suit, rank )
    table.insert(self.cards, Card.suitRankToIndex(suit, rank))
end

-- 删掉特定牌
function Cards.remove( self, suit, rank )
    local index = self:find(suit, rank)
    if index > 0 then
        table.remove(self.cards, index)
        return true
    end
    return false
end

return Cards
