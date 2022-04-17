local M = {}

local stringx = require('pl.stringx')

function M.get_popen_output(command)
  -- yadm diff-index --quiet HEAD --
  -- local command = "yadm diff-index HEAD --"
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return stringx.strip(result)
end

function M.get_execute_output(command)
  output, status, c_type, rc = hs.execute(command, true)
  return stringx.strip(output)
end

function M.is_ahead()
  command = "yadm status -sb"
  output = M.get_execute_output(command)
  print(output)
  return string.find(output, "ahead [0-9]+") ~= nil
end

function M.is_behind()
  command = "yadm status -sb"
  output = M.get_execute_output(command)
  print(output)
  return string.find(output, "behind [0-9]+") ~= nil
end

function M.get_modified_files()
  modified_files = {}
  local command_output = M.get_execute_output("yadm diff-index HEAD --")
  local result = stringx.strip(command_output)

  local line_list = stringx.split(result, '\n')

  for i = 1, line_list:len() do
    local line = line_list[i]
    local line_separated = stringx.split(line)
    local line_file = line_separated[#line_separated]
    modified_files[#modified_files + 1] = line_file
  end

  return modified_files
end

return M
