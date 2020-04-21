-- Small blackjack game that I made while learning lua
------------------------------------------------------------------------------
-- Sprite credit: https://simplegametutorials.github.io/blackjack/
------------------------------------------------------------------------------
-- Open-source @ github.com/davidp-ro

-- Made with the LÖVE framework (https://love2d.org/)
------------------------------------------------------------------------------
--[[ MIT License | Copyright (c) 2020 David Pescariu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]-- end of license.
------------------------------------------------------------------------------

-- love_21/main.lua

-------------------------------------------
-- Create the deck of cards.
-- Deck: 2-10 normal, 1-A, 11-J, 12-Q, 13-K
-- LOVE framework function
-------------------------------------------
function love.load()
    -- Globales:
    deck = {}
    roundDone = false
    -- playerHand, dealerHand

    for suitIndex, suit in ipairs({'club', 'diamond', 'heart', 'spade'}) do
        for rank = 1, 13 do
            -- print('suit: '..suit..', rank: '..rank)
            table.insert(deck, {suit = suit, rank = rank})
        end
    end
    -- print('Total number of cards in deck: '..#deck)

    -------------------------------------------------------
    -- Insert card into hand.
    -- @param handToInsert Witch hand to insert a card into
    -------------------------------------------------------
    function insertCard(handToInsert)
        table.insert(handToInsert, table.remove( deck, love.math.random(#deck) ))
    end

    -- Initial hand for the player
    playerHand = {}
    insertCard(playerHand)
    insertCard(playerHand)

    -- Initial hand for the dealer
    dealerHand = {}
    insertCard(dealerHand)
    insertCard(dealerHand)

    -- Images:
    images = {}
    for nameIndex, name in ipairs({
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
        'pip_heart', 'pip_diamond', 'pip_club', 'pip_spade',
        'mini_heart', 'mini_diamond', 'mini_club', 'mini_spade',
        'card', 'card_face_down',
        'face_jack', 'face_queen', 'face_king',
    }) do
        images[name] = love.graphics.newImage('images/'..name..'.png')
    end

end --love.load()

-----------------------------------------------
-- Check for a keypresses and:
--  Reload if game is done
--  Check if the player has gone bust or has 21
--  Give the dealer cards, until he gets 17
-- LOVE framework function
-- @param key Pressed key.
-----------------------------------------------
function love.keypressed(key)
    if not roundDone then
        if key == 'h' then
            -- Hit:
            insertCard(playerHand)
            -- Check to see if the player has 21 or has gone bust:
            if getSum(playerHand) >= 21 then
                roundDone = true
            end
        elseif key == 's' then
            --Stand:
            roundDone = true
        end
        -- If player is standing, the dealer will take cards until he gets at least 17
        if roundDone then
            while getSum(dealerHand) < 17 do
                insertCard(dealerHand)
            end
        end
    else --If round is done and a key gets pressed, reload
        love.load()
    end --if not roundDone

end --love.keypressed()

----------------------------------------
-- Draw the windows and elements within.
-- LOVE framework function
----------------------------------------
function love.draw()
    local output = {}
    local hasAce = false
    
    -----------------------------------------------------------
    -- Calculate the sum of a given hand.
    -- J/Q/K considered 10 | A - 11 if sum<=21 && 1 if sum > 21
    -- @param hand the hand to calculate the sum from.
    -----------------------------------------------------------
    function getSum(hand)
        local sum = 0
        for cardIndex, card in ipairs(hand) do
            -- Deal with letters:
            if card.rank > 10 then
                sum = sum + 10
            else
                sum = sum + card.rank
            end

            -- Check to see if an ace is present in the hand
            if card.rank == 1 then
                hasAce = true
            end

        end --for cards in hand

        -- Deal with aces:
        if hasAce and sum <= 11 then
            sum = sum + 10  -- Not 11 bcs. 1 was already added before.
        end

        return sum
    end --getSum

    table.insert(output, 'Player hand:' )
    for cardIndex, card in ipairs(playerHand) do
        table.insert(output,  'suit: '..card.suit..', rank: '..card.rank)
    end
    table.insert(output, 'Total:'..getSum(playerHand)..'\n')

    table.insert( output, 'Dealer hand:' )
    for cardIndex, card in ipairs(dealerHand) do
        if not roundDone and cardIndex == 1 then
            -- Hide the first card from the dealer
            table.insert( output,  'Card hidden')
        else
            table.insert( output,  'suit: '..card.suit..', rank: '..card.rank)
        end
    end
    if roundDone then
        -- Hide the dealer total until the round is over
        table.insert(output, 'Total:'..getSum(dealerHand)..'\n')
    end

    --[[ Show winner: ]]--
    if roundDone then
        table.insert(output, '\n')

        local playerSum = getSum(playerHand)
        local dealerSum = getSum(dealerHand)

        local function whoWon(checkedHand, comparisonHand)
            checkedSum = getSum(checkedHand)
            comparisonSum = getSum(comparisonHand)
            
            return checkedSum <= 21
            and (
                comparisonSum > 21
                or checkedSum > comparisonSum
            )
        end --whoWon

        if whoWon(playerHand, dealerHand) then
            table.insert( output, 'Player wins' )
        elseif whoWon(dealerHand, playerHand) then
            table.insert( output, 'Dealer wins' )
        else
            table.insert( output, 'Draw' )
        end
    end -- if roundDone

    love.graphics.print(table.concat( output, "\n" ), 15, 15 )

end --love.draw()
