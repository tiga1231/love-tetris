utils = {}

function utils.emptyBoard(rows, cols)
    local board = {}
    for i=1,rows do
        board[i] = {}
        for j=1,cols do
            board[i][j] = '_'
        end
    end
    return board
end


function utils.union(board, currentPiece, offset)
    local ROWS = #board
    local COLS = #board[1]
    
    local res = {}

    for i=1, ROWS do
        res[i] = {}
        for j=1, COLS do

            -- overlaped part
            if i>offset.y and i<=offset.y+#currentPiece and j>offset.x and j<=offset.x+#currentPiece[1] then
                res[i][j] = utils.add(board[i][j], currentPiece[i-offset.y][j-offset.x])
            else
                res[i][j] = board[i][j]
            end
        end
    end

    return res
end


function utils.add(s1, s2)
    if s1=='_' and s2=='_' then
        return '_'
    elseif s1~='_' then
        return s1
    elseif s2~='_' then
        return s2
    else
        print('assertion error: blocks overlaped')
    end
end


function utils.increase(i, n)
    return i%n + 1
end

function utils.isGameOver(board, currentPiece, offset)
    if utils.isTop(board, currentPiece, offset) 
        and utils.isCollapse(board, currentPiece, {x=offset.x, y=offset.y+1}) then
        return true
    else
        return false
    end
end


function utils.isTop(board, currentPiece, offset)
    for i=1, #currentPiece do
        for j=1, #currentPiece[1] do
            local p = currentPiece[i][j]
            local y = offset.y+i
            if p~='_' and y<1 then
                return true
            end
        end
    end
    return false
end


function utils.isLeft(board, currentPiece, offset)
    local ROWS = #board
    local COLS = #board[1]

    for i=1, #currentPiece do
        for j=1, #currentPiece[1] do
            local p = currentPiece[i][j]
            local x = offset.x+j
            local y = offset.y+i
            if p~='_' then
                if x-1<=0 or y>=1 and board[y][x-1]~='_' then
                    return true
                end 
            end
        end
    end
    return false
end


function utils.isRight(board, currentPiece, offset)
    local ROWS = #board
    local COLS = #board[1]

    for i=1, #currentPiece do
        for j=1, #currentPiece[1] do
            local p = currentPiece[i][j]
            local x = offset.x+j
            local y = offset.y+i
            if p~='_' then
                if x+1>COLS or y>=1 and board[y][x+1]~='_' then
                    return true
                end 
            end
        end
    end
    return false
end


function utils.isCollapse(board, currentPiece, offset)
    local ROWS = #board
    local COLS = #board[1]

    for i=1, #currentPiece do
        for j=1, #currentPiece[1] do
            local p = currentPiece[i][j]
            local x = offset.x+j
            local y = offset.y+i

            if 1<=x and x<=COLS and 1<=y and y<=ROWS then
                local b = board[y][x]
                if p~='_' and b~='_'then
                    return true
                end
            elseif p~='_' and (x<1 or x>COLS or y>ROWS) then
                return true
            end
        end
    end
    return false
end

function utils.cancelLines(board, score)
    local ROWS = #board
    local COLS = #board[1]

    local newBoard = {}
    local r = ROWS
    for i=ROWS,1,-1 do
        local isCancel = true
        local row = {}
        for j=1,COLS do
            row[j] = board[i][j]
            if board[i][j] == '_' then
                isCancel = false
            end
        end

        if not isCancel then
            newBoard[r] = row
            r = r-1
        else
            score = score + 10
        end
    end

    for i=r,1,-1 do
        newBoard[i] = {}
        for j=1,COLS do
            newBoard[i][j] = '_'
        end
    end

    return newBoard, score
end















