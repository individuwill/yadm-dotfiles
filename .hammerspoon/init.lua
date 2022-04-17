stringx = require('pl.stringx')
ys = require('yadm_status')

function checkModifiedFiles()
  modified_files = ys.get_modified_files(
    ys.get_execute_output('yadm diff-index HEAD -- ')
  )

  if #modified_files > 0 then
    print('need to alert')
    file_list_str = '* ' .. stringx.join('\n* ', modified_files)
    print("modified files:\n" .. file_list_str)
    hs.notify.new({title="Yadm status", informativeText= file_list_str}):send()
  end
end

function checkRemoteStatus()
  command = "yadm status -sb"
  output, status, c_type, rc = hs.execute(command, true)
  print(output)
  print(string.find(output, "ahead [0-9]+") ~= nil)
  if string.find(output, "ahead [0-9]+") ~= nil then
    print("we're ahead")
    hs.notify.new({title="Yadm remote", informativeText="You need to push."}):send()
  end

  if string.find(output, "behind [0-9]+") ~= nil then
    print("we're behind")
    hs.notify.new({title="Yadm status", informativeText="You need to pull."}):send()
  end
end

function checkStatus()
  -- hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
  checkModifiedFiles()
  checkRemoteStatus()
end

checkStatus()

hs.timer.doEvery(10, checkStatus)
