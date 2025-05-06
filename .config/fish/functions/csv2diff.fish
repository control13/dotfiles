function csv2diff --description 'interactive csv diff'
  set res (csvdiff $argv | string split '\n')
  set -p res "Name,eingestellt,Lebensdaten,url"
  set full (string join -- '\n' $res)
  set url "a"
  while test $url
    set url (echo -e $full | csvlens --echo-column url)
    if test $url
      echo $url
      firefox $url
    end
  end
end
