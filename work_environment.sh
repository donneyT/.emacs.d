
checklist=(
git git
the_silver_searcher ag
nodejs node
pm2 pm2
python python
percol percol
w3m w3m
redis redis-server 
lua lua 
)
install=()

function find_package() {
if which $2 &>/dev/null; then
    echo "checking $1 ... yes!"
else
    echo "checking $1 ... no!"
    install[${#install[*]}]=$1
fi
}

function install_result() {
  if test $2 -eq 0; then
    echo "installing $1 ... success!"
  else 
    echo "installing $1 ... failed!"
  fi
}

function copy_result() { 
  if test $2 -eq 0; then
    echo "copying $1 ... success!"
  else 
    echo "copying $1 ... failed!"
  fi
}


echo "+===================================+"
echo "|start ... checking work environment|"
echo "+===================================+"
for (( i = 0 ; i < ${#checklist[@]} ; i+=2 )) do
  find_package ${checklist[i]} ${checklist[i+1]}
done

echo "+===================================+"
echo "|start ... install useful pkgs      |"
echo "+===================================+"
for var in ${install[@]};
do
  echo "wating..."
  if test $var = "percol"; then
    cd percol_master
    python setup.py install 
    install_result $var $? 
  elif test $var = "pm2"; then
    npm install -g pm2 &>/dev/null
    install_result $var $?
  else
    yum install -y $var &>/dev/null
    install_result $var $?
  fi
done

echo "+===================================+"
echo "|start ... copy useful configs      |"
echo "+===================================+"
dir=`pwd`
cd ~
cp .bashrc{,.bak}
cd $dir
cp .bashrc ~/ && source ~/.bashrc
copy_result .bashrc $?
cp -R percol-master/.percol.d ~/
copy_result .percol.d $?
#todo
