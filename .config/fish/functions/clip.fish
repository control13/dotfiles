function clip --wraps='kitten clipboard' --description 'alias clip=kitten clipboard'
  tr -d '\n' | kitten clipboard $argv
end
