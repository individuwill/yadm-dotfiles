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
  if ys.is_ahead() then
    print("we're ahead")
    hs.notify.new({title="Yadm remote", informativeText="You need to push."}):send()
  end

  if ys.is_behind() then
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

hs.timer.doEvery(60, checkStatus)
