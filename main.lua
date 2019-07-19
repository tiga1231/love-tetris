require('data')
require('utils')


function love.load()
    board = utils.emptyBoard(16,10)
    tempBoard = board
    ROWS = #board
    COLS = #board[1]

    piecesQueue = {'i','o','j','l','t','s','z'}
    pieceIndex = 1
    pieceState = 1
    currentPiece = blocks[piecesQueue[pieceIndex]][pieceState]
    nextPiece = blocks[piecesQueue[pieceIndex+1]][1]
    
    initOffset = {x=3, y=-3}
    offset = {x=initOffset.x, y=initOffset.y}
    
    timer = 0
    score = 0

    love.graphics.setNewFont(50)
    bgColor = {220,220,220}
    love.graphics.setBackgroundColor(bgColor)

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    margin = width * 0.15
    blockSize = (width - 2*margin) / COLS
   

    colors = {
        i={102,194,165},
        o={252,141,98},
        j={141,160,203},
        l={231,138,195},
        t={166,216,84},
        s={255/3*2,217/3*2,47/3*2},
        z={229,196,148},
        _={200,200,200}
    }

end

function love.update(dt)
    local T = 0.4
    timer = timer + dt
    if timer>T then
        if utils.isCollapse(board, currentPiece, {x=offset.x, y=offset.y+1}) then
            tempBoard = utils.union(board, currentPiece, offset)
            board = tempBoard
            pieceIndex = utils.increase(pieceIndex, #piecesQueue)
            pieceState = 1
            currentPiece = blocks[piecesQueue[pieceIndex]][1]   
            nextPiece = blocks[piecesQueue[utils.increase(pieceIndex, #piecesQueue)]][1]
            offset = {x=initOffset.x, y=initOffset.y}

            board, score = utils.cancelLines(board, score)

        else
            offset.y=offset.y+1
        end
               
        if utils.isGameOver(board, currentPiece, offset) then
            reset()
        end

        timer = timer % T
    else
        currentPiece = blocks[piecesQueue[pieceIndex]][pieceState]
        tempBoard = utils.union(board, currentPiece, offset)
    end


end


function reset()
    board = utils.emptyBoard(ROWS, COLS)
    offset = {x=initOffset.x, y=initOffset.y}
    tempBoard = board
    timer = 0
    pieceState = 1
    score = 0
end


function debugBoard(b)
    for i=1,#b do
        print(table.concat(b[i], ' '))
    end
    print()
end


function love.draw()
    drawBoard(tempBoard)
    drawNext(nextPiece)
    drawScore(score)
end


function drawScore(score)
    love.graphics.setColor({50,50,100})
    love.graphics.print(score, margin/2, margin/2)
end


function drawBoard(board)
    for i=1,ROWS do
        for j=1,COLS do
            drawBlock(i,j,colors[ board[i][j] ])
        end
    end
end


function drawBlock(i, j, color, transparent)
    transparent = transparent or false

    local x = margin + (j-1)*blockSize
    local y = height-margin-ROWS*blockSize + (i-1)*blockSize

    if transparent and color == colors['_'] then
        love.graphics.setColor(bgColor)
    else
        love.graphics.setColor(color)
    end
    love.graphics.rectangle('fill', x, y, blockSize, blockSize)

    love.graphics.setColor(bgColor)
    love.graphics.setLineWidth(4)

    love.graphics.rectangle('line', x, y, blockSize, blockSize)
end


function drawNext(nextPiece)
    for i=1,4 do
        for j=1,4 do
            drawBlock(i-4,j+3,colors[nextPiece[i][j]], true)
        end
    end
end


-- keys = {
--     up='i',
--     down='k',
--     left='j',
--     right='l'
-- }

keys = {
    up='up',
    down='down',
    left='left',
    right='right'
}


function love.keypressed(key)
    print(key)
    if key == keys.up then
        pieceRotate()
    elseif key == keys.down then
        pieceDown()
    elseif key==keys.left then
        pieceLeft()
    elseif key==keys.right then
        pieceRight()
    end
end


function pieceLeft()
    if not utils.isCollapse(board, currentPiece, {x=offset.x-1, y=offset.y}) then
        offset.x = offset.x-1
    end
end


function pieceRight()
    if not utils.isCollapse(board, currentPiece, {x=offset.x+1, y=offset.y}) then
        offset.x = offset.x+1
    end
end


function pieceRotate()
    local statesCount = #blocks[piecesQueue[pieceIndex]]
    local nextState = utils.increase(pieceState, statesCount)
    local rotatePiece = blocks[piecesQueue[pieceIndex]][nextState]

    if not utils.isCollapse(board, rotatePiece, offset) then
        pieceState = utils.increase(pieceState, statesCount)
    end
end


function pieceDown()
    while not utils.isCollapse(board, currentPiece, {x=offset.x, y=offset.y+1}) do
        offset.y = offset.y+1
    end
end