#MC # key bindings of closing windows
{ ... }: {
  programs.neovim = {
    extraConfig = ''
      function CloseWindowsAbove()
        let l:curwin = winnr()
        while winnr('1k') != l:curwin
          wincmd k
          close
          let l:curwin -= 1
        endwhile
      endfunction
      function CloseWindowsBelow()
        let l:curwin = winnr()
        wincmd j
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

      " quit all
      nnoremap ZA :qa!<CR>
    '';
  };
}
