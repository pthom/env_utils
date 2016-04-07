

function filename_extension() {
  local filename=$1
  extension="${filename##*.}"
  echo $extension
}

function filename_withoutextension() {
  local filename=$1
  filename="${filename%.*}"
  echo $filename
}

function find_in_folder() {
  if [[  "$#" -lt 3 ]]; then
    echo "Usage: $0 folder_to_search files_extension what_to_search "
    return
  fi
  folder_to_search=$1
  files_extension=$2
  what_to_search=$3
  cmd="find $folder_to_search -iname \"*$files_extension\" -print0 | xargs -I{} -0 grep -n \"$what_to_search\" \"{}\" /dev/null" # /dev/null is a trick to force grep to display the file name
  echo "Will run : "$cmd
  eval $cmd
}


#
#
SRC_FILES_EXTENSIONS="js|ts|cpp|c|h|hpp|php|py|sh|cs|sql|json|ini|xml|conf"
#
function find_source_files() {
  if [[ "$#" -eq 0 ]]; then
    echo "$0 will list sources files (having extensions $SRC_FILES_EXTENSIONS)"
    echo "Usage :"
    echo "$0 folder"
    return
  fi
  local folder=$1
  unamestr=$(uname)
  if [[ $unamestr == 'Darwin' ]]; then
    #specific case for Mac OSX
    find -E $folder -iregex '.*\.('$SRC_FILES_EXTENSIONS')'
  else
    #Rhahhh, lovely
    local extensions_escaped=$(echo $SRC_FILES_EXTENSIONS | sed s/\|/\\\\\|/g)
    #echo "extensions_escaped:$extensions_escaped"
    find $folder -iregex '.*\.\('$extensions_escaped'\)$'
  fi
}


function find_in_source_files() {
  if [[  "$#" -lt 2 ]]; then
    echo "Usage: $0 folder_to_search what_to_search "
    return
  fi
  folder_to_search=$1
  what_to_search=$2
  for f in $(find_source_files $folder_to_search); do grep -n "$what_to_search" $f /dev/null; done
}


#
#
function trim_trailing_space() {
  local nbargs=$#
  if [[ $nbargs -eq 0 ]]; then
    echo "$FUNCNAME will trim (in place) trailing spaces in the given file (remove unwanted spaces at end of lines)"
    echo "Usage :"
    echo "$FUNCNAME file"
    return
  fi
  local file=$1
  unamestr=$(uname)
  if [[ $unamestr == 'Darwin' ]]; then
    #specific case for Mac OSX
    sed -E -i ''  's/[[:space:]]*$//' $file
  else
  sed -i  's/[[:space:]]*$//' $file
  fi
}
#
function trim_trailing_space_all_source_files() {
  for f in $(find_source_files .); do trim_trailing_space $f;done
}

if [[ $(uname) == 'Darwin' ]]; then  # xdg-open is the linux equivalent of OSX's open
  alias xdg-open=open
fi



