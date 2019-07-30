require('data')
require('utils')


function love.load()
    math.randomseed(os.time())

    board = utils.emptyBoard(20,10)
    tempBoard = board
    ROWS = #board
    COLS = #board[1]

    pieceNames = {"i", "o","j","l","t","s","z"}
    pieceName = pieceNames[math.random(1, #pieceNames)]
    pieceState = 1
    currentPiece = blocks[pieceName][pieceState]
    
    nextPieceName = pieceNames[math.random(1, #pieceNames)]
    nextPiece = blocks[nextPieceName][1]
    
    initOffset = {x=3, y=-3}
    offset = {x=initOffset.x, y=initOffset.y}
    
    keyDownTimer = 0
    pieceDownTimer = 0
    score = 0

    love.graphics.setNewFont(50)
    bgColor = utils.colors.black
    love.graphics.setBackgroundColor(bgColor)

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    margin = width * 0.15
    blockSize = (width - 2*margin) / COLS
   
    level = 1
    colors = utils.colorscheme[level]
    print(colors['s'][1])
end


function handleKeyDown(dt)
    local T = 0.02
    if love.keyboard.isDown(keys.down) then
        if keyDownTimer > T  then
            pieceDown()
            keyDownTimer = 0
        else
            keyDownTimer = keyDownTimer + dt
        end
    end
end


function handlePieceDown(dt)
    local T = 0.4
    pieceDownTimer = pieceDownTimer + dt
    if pieceDownTimer>T then
        if utils.isCollapse(board, currentPiece, {x=offset.x, y=offset.y+1}) then

            tempBoard = utils.union(board, currentPiece, offset)
            board = tempBoard

            pieceName =  nextPieceName
            pieceState = math.random(1, #blocks[pieceName])
            currentPiece = blocks[pieceName][pieceState]

            nextPieceName = pieceNames[math.random(1, #pieceNames)]
            nextPiece = blocks[nextPieceName][1]

            offset = {x=initOffset.x, y=initOffset.y}
            board, score = utils.cancelLines(board, score)
        else
            offset.y=offset.y+1
        end
               
        if utils.isGameOver(board, currentPiece, offset) then
            reset()
        end

        pieceDownTimer = pieceDownTimer % T
    else
        currentPiece = blocks[pieceName][pieceState]
        tempBoard = utils.union(board, currentPiece, offset)
    end
end


function love.update(dt)
    handleKeyDown(dt)
    handlePieceDown(dt)
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
    -- draw board frame
    local x = margin
    local y = height-margin-ROWS*blockSize
    drawFrame(x,y, blockSize*COLS, blockSize*ROWS)

    for i=1,ROWS do
        for j=1,COLS do
            drawBlock(i,j,colors[ board[i][j] ])
        end
    end

end


function drawFrame(x,y,width,height)
    local m = 4
    love.graphics.setColor(utils.colors.black)
    love.graphics.setLineWidth(m)
    love.graphics.rectangle('line', x, y, width, height)

    love.graphics.setColor(utils.colors.lightgrey)
    love.graphics.setLineWidth(m)
    love.graphics.rectangle('line', x-m, y-m, width+2*m, height+2*m)

    love.graphics.setColor(utils.colors.black)
    love.graphics.setLineWidth(m)
    love.graphics.rectangle('line', x-2*m, y-2*m, width+4*m, height+4*m)

    love.graphics.setColor(utils.colors.darkgrey)
    love.graphics.setLineWidth(m)
    love.graphics.rectangle('line', x-3*m, y-3*m, width+6*m, height+6*m, m, m)

end


function drawBlock(i, j, color)

    local x = margin + (j-1)*blockSize
    local y = height-margin-ROWS*blockSize + (i-1)*blockSize


    love.graphics.setColor(color)
    blockMargin = 6
    love.graphics.rectangle('fill', 
        x+blockMargin/2, y+blockMargin/2, 
        blockSize-blockMargin, blockSize-blockMargin)

    -- love.graphics.setColor(utils.colors.black)
    -- love.graphics.setLineWidth(6)
    -- love.graphics.rectangle('line', x, y, blockSize, blockSize)

    if color == utils.colors.white then
        love.graphics.setColor(utils.colors.blue)
        love.graphics.setLineWidth(blockMargin)
        love.graphics.rectangle('line', 
            x+blockMargin, y+blockMargin, 
            blockSize-blockMargin*2, blockSize-blockMargin*2)
    end

    local hlWidth=6
    local hlHeight=8
    local hlSide=6

    if color[4] ~= 0 then
        --highlight
        love.graphics.setColor(utils.colors.white)
        love.graphics.setLineWidth(0)
        love.graphics.rectangle('fill', x+blockMargin/2, y+blockMargin/2, hlWidth, hlHeight)
        love.graphics.rectangle('fill', x+blockMargin/2+hlWidth, y+blockMargin+hlHeight-4, hlSide, hlSide)
        love.graphics.rectangle('fill', x+blockMargin/2+hlWidth, y+blockMargin+hlHeight+hlSide-4, hlSide,hlSide)
        love.graphics.rectangle('fill', x+blockMargin/2+hlWidth+hlSide, y+blockMargin+hlHeight-4, hlSide,hlSide)
    end
end


function drawNext(nextPiece)

    local x = margin + 3*blockSize
    local y = height - margin - ROWS*blockSize - 5*blockSize
    drawFrame(x,y, blockSize*5, blockSize*4)

    for i=1,4 do
        for j=1,4 do
            drawBlock(i-5,j+3+0.5, colors[nextPiece[i][j]], false)
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
    right='right',
    bottom='rshift',
}


function love.keypressed(key)
    print(key)
    if key == keys.up then
        pieceRotate()
    elseif key==keys.left then
        pieceLeft()
    elseif key==keys.right then
        pieceRight()
    elseif key == keys.bottom then
        pieceBottom()
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
    local nextState = utils.increase(pieceState, #blocks[pieceName])
    local rotatePiece = blocks[pieceName][nextState]

    if not utils.isCollapse(board, rotatePiece, offset) then
        pieceState = nextState
    else
        if not utils.isCollapse(board, rotatePiece, {x=offset.x+1, y=offset.y}) then
            offset.x = offset.x+1
            pieceState = nextState
        elseif not utils.isCollapse(board, rotatePiece, {x=offset.x-1, y=offset.y}) then
            offset.x = offset.x-1
            pieceState = nextState
        end
    end
end


function pieceDown()
    if not utils.isCollapse(board, currentPiece, {x=offset.x, y=offset.y+1}) then
        offset.y = offset.y+1
    end
end

function pieceBottom()
    while not utils.isCollapse(board, currentPiece, {x=offset.x, y=offset.y+1}) do
        offset.y = offset.y+1
    end
end