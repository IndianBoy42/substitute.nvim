local wrappers = {}

function wrappers.linewise(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)
    local type = vim.fn.getregtype(state.register)

    vim.fn.setreg(state.register, body, "l")

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, type)
  end
end

function wrappers.charwise(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)
    local type = vim.fn.getregtype(state.register)

    local reformated_body = body:gsub("\n$", "")
    vim.fn.setreg(state.register, reformated_body, "c")

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, type)
  end
end

function wrappers.blockwise(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)
    local type = vim.fn.getregtype(state.register)

    vim.fn.setreg(state.register, body, "b")

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, type)
  end
end

function wrappers.trim(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)

    local reformated_body = body:gsub("^%s*", ""):gsub("%s*$", "")
    vim.fn.setreg(state.register, reformated_body, vim.fn.getregtype(state.register))

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, vim.fn.getregtype(state.register))
  end
end

function wrappers.join(next)
  return function(state, callback)
    local body = vim.fn.getreg(state.register)

    local reformated_body = body:gsub("%s*\r?\n%s*", " ")
    vim.fn.setreg(state.register, reformated_body, vim.fn.getregtype(state.register))

    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    vim.fn.setreg(state.register, body, vim.fn.getregtype(state.register))
  end
end

function wrappers.change(change, next)
  return function(state, callback)
    if nil == next then
      callback(state)
    else
      next(state, callback)
    end

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd(string.format("silent '[,']normal! %s", change))
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end
end

function wrappers.build(chain)
  local wrapper = nil

  for index = #chain, 1, -1 do
    if vim.tbl_contains({ "==", ">>", "<<" }, chain[index]) then
      wrapper = wrappers.change(chain[index], wrapper)
    else
      wrapper = wrappers[chain[index]](wrapper)
    end
  end

  return wrapper
end

return wrappers
