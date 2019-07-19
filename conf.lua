function love.conf(t)
    io.stdout:setvbuf("no")
    t.window.highdpi = true
    t.window.width = 400
    t.window.height = t.window.width*1.618
end