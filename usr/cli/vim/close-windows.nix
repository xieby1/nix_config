#MC # key bindings of closing windows
{ ... }: {
  programs.neovim = {
    extraConfig = ''
      function CloseWindowsAbove()
        let l:curwin = winnr()
        while winnr('1k') != l:curwin
          wincmd k
          close
          let l:curwin = winnr()
        endwhile
      endfunction
      function CloseWindowsBelow()
        let l:curwin = winnr()
        wincmd j
        while winnr() != l:curwin
          close
        endwhile
      endfunction
      function CloseWindowsLeft()
        let l:curwin = winnr()
        while winnr('1h') != l:curwin
          wincmd h
          close
          let l:curwin = winnr()
        endwhile
      endfunction
      function CloseWindowsRight()
        let l:curwin = winnr()
        wincmd l
        while winnr() != l:curwin
          close
        endwhile
      endfunction

      command CloseWindowsAbove call CloseWindowsAbove()
      command CloseWindowsBelow call CloseWindowsBelow()
      nnoremap Z<Up> :call CloseWindowsAbove()<CR>
      nnoremap Z<S-Up> :call CloseWindowsAbove()<CR>
      nnoremap Z<Down> :call CloseWindowsBelow()<CR>
      nnoremap Z<S-Down> :call CloseWindowsBelow()<CR>
      command CloseWindowsLeft call CloseWindowsLeft()
      command CloseWindowsRight call CloseWindowsRight()
      nnoremap Z<Left> :call CloseWindowsLeft()<CR>
      nnoremap Z<S-Left> :call CloseWindowsLeft()<CR>
      nnoremap Z<Right> :call CloseWindowsRight()<CR>
      nnoremap Z<S-Right> :call CloseWindowsRight()<CR>

      " quit all
      nnoremap ZA :qa!<CR>
    '';
  };
}
