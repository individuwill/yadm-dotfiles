function checkStatus()
  -- hs.notify.new({title="Hammerspoon", informativeText="Hello World"}):send()
  stringx = require('pl.stringx')
  ys = require('yadm_status')
  modified_files = ys.get_modified_files(
    ys.get_execute_output('yadm diff-index HEAD -- ')
  )

  if #modified_files > 0 then
    print('need to alert')
    file_list_str = '* ' .. stringx.join('\n* ', modified_files)
    print(file_list_str)
    hs.notify.new({title="Yadm status", informativeText= file_list_str}):send()
  end
end

checkStatus()

hs.timer.doEvery(60, checkStatus)
