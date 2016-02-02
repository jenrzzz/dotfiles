nnoremap <Leader>rs :call RunNearestSpec()<CR>
nnoremap <Leader>br :!bundle exec rspec --require="~/.rspec-formatters/vim_formatter.rb" --format VimFormatter --out quickfix.out --format progress %:p<CR>
