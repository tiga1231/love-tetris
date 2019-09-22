function love.conf(t)
  io.stdout:setvbuf("no")
  t.window.highdpi = true

  keys = {
      up='up',
      down='down',
      left='left',
      right='right',
      bottom='rshift',
  }

  -- t.window.width = 800
  -- t.window.height = 800*2.2
end