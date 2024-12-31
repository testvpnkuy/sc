#!/bin/bash

module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "https://raw.githubusercontent.com/rudi9999/Herramientas/main/module/module" &>/dev/null
[[ ! -e ${module} ]] && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){
  rm -rf ${module}; exit
}

if [[ ! $(id -u) = 0 ]]; then
  clear
  msg -bar
  print_center -ama "ERROR DE EJECUCION"
  msg -bar
  print_center -ama "DEVE EJECUTAR DESDE EL USUSRIO ROOT"
  msg -bar
  CTRL_C
fi

trap "CTRL_C" INT TERM EXIT

ADMRufu="/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
tmp="${ADMRufu}/tmp" && [[ ! -d ${tmp} ]] && mkdir ${tmp}
SCPinstal="$HOME/install"

#rm -rf /etc/localtime &>/dev/null
#ln -s /usr/share/zoneinfo/America/Argentina/Tucuman /etc/localtime &>/dev/null
cp -f $0 ${ADMRufu}/install.sh
rm $(pwd)/$0 &> /dev/null

stop_install(){
  title "INSTALACION CANCELADA"
  exit
 }

time_reboot(){
  print_center -ama "REINICIANDO VPS EN $1 SEGUNDOS"
  REBOOT_TIMEOUT="$1"
  
  while [ $REBOOT_TIMEOUT -gt 0 ]; do
     print_center -ne "-$REBOOT_TIMEOUT-\r"
     sleep 1
     : $((REBOOT_TIMEOUT--))
  done
  reboot
}

repo_install(){
  link="https://raw.githubusercontent.com/rudi9999/ADMRufu/main/Repositorios/$VERSION_ID.list"
  case $VERSION_ID in
    8*|9*|10*|11*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*) [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back
                                                                    wget -O /etc/apt/sources.list ${link} &>/dev/null;;
  esac
}

dependencias(){
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip openssl screen cron iptables lsof nano at mlocate gawk grep bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat sqlite3 libsqlite3-dev"

  for install in $soft; do
    leng="${#install}"
    puntos=$(( 21 - $leng))
    pts="."
    for (( a = 0; a < $puntos; a++ )); do
      pts+="."
    done
    msg -nazu "      instalando $install $(msg -ama "$pts")"
    if apt install $install -y &>/dev/null ; then
      msg -verd "INSTALL"
    else
      msg -verm2 "FAIL"
      sleep 2
      del 1
      if [[ $install = "python" ]]; then
        pts=$(echo ${pts:1})
        msg -nazu "      instalando python2 $(msg -ama "$pts")"
        if apt install python2 -y &>/dev/null ; then
          [[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python2 /usr/bin/python
          msg -verd "INSTALL"
        else
          msg -verm2 "FAIL"
        fi
        continue
      fi
      print_center -ama "aplicando fix a $install"
      dpkg --configure -a &>/dev/null
      sleep 2
      del 1
      msg -nazu "      instalando $install $(msg -ama "$pts")"
      if apt install $install -y &>/dev/null ; then
        msg -verd "INSTALL"
      else
        msg -verm2 "FAIL"
      fi
    fi
  done
}

verificar_arq(){
  unset ARQ
  case $1 in
    menu|menu_inst.sh|tool_extras.sh|chekup.sh|bashrc)ARQ="${ADMRufu}";;
    ADMRufu)ARQ="/usr/bin";;
    message.txt)ARQ="${tmp}";;
    *)ARQ="${ADM_inst}";;
  esac
  mv -f ${SCPinstal}/$1 ${ARQ}/$1
  chmod +x ${ARQ}/$1
}

error_fun(){
  msg -bar3
  print_center -verm "ERROR de enlace VPS<-->GENERADOR"
  msg -bar3
  [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
  exit
}

post_reboot(){
  echo 'clear; sleep 2; /etc/ADMRufu/install.sh --continue' >> /root/.bashrc
  title "INSTALADOR ADMRufu"
  print_center -ama "La instalacion continuara\ndespues del reinicio!!!"
  msg -bar
}

install_start(){
  title "INSTALADOR ADMRufu"
  print_center -ama "A continuacion se actualizaran los paquetes\ndel systema. Esto podria tomar tiempo,\ny requerir algunas preguntas\npropias de las actualizaciones."
  msg -bar3
  read -rp "$(msg -verm2 " Desea continuar? [S/N]:") " -e -i S opcion
  [[ "$opcion" != @(s|S) ]] && stop_install
  title "INSTALADOR ADMRufu"
  print_center -ama 'Esto modificara la hora y fecha automatica\nsegun la Zona horaria establecida.'
  msg -bar
  read -rp "$(msg -ama " Modificar la zona horaria? [S/N]:") " -e -i N opcion
  [[ "$opcion" != @(n|N) ]] && source <(curl -sSL "https://raw.githubusercontent.com/rudi9999/ADMRufu/main/online/timeZone.sh")
  title "INSTALADOR ADMRufu"
  repo_install
  mysis=$(echo "$VERSION_ID"|cut -d '.' -f1)
  #[[ ! $mysis = '22' ]] && add-apt-repository -y ppa:ondrej/php &>/dev/null
  apt update -y; apt upgrade -y
  [[ "$VERSION_ID" = '9' ]] && source <(curl -sL https://deb.nodesource.com/setup_10.x)
}

install_continue(){
  title "INSTALADOR ADMRufu"
  print_center -ama "$PRETTY_NAME"
  print_center -verd "INSTALANDO DEPENDENCIAS"
  msg -bar3
  dependencias
  msg -bar3
  print_center -azu "Removiendo paquetes obsoletos"
  apt autoremove -y &>/dev/null
  [[ "$VERSION_ID" = '9' ]] && apt remove unscd -y &>/dev/null
  sleep 2
  tput cuu1 && tput dl1
  print_center -ama "si algunas de las dependencias falla!!!\nal terminar, puede intentar instalar\nla misma manualmente usando el siguiente comando\napt install nom_del_paquete"
  enter
}

source /etc/os-release; export PRETTY_NAME

while :
do
  case $1 in
    -s|--start)install_start; post_reboot; time_reboot "15";;
    -c|--continue)sed -i '/Rufu/d' /root/.bashrc
                  install_continue
                  break;;
    -u|--update)install_start
                rm -rf /etc/ADMRufu/tmp/style
                install_continue
                break;;
    -t|--test)break;;
    *)exit;;
  esac
done

title "INSTALADOR ADMRufu"
fun_ip

msg -ne " Verificando Datos: "
cd $HOME

arch='ADMRufu
bashrc
budp.sh
cert.sh
chekup.sh
chekuser.sh
confDNS.sh
domain.sh
filebrowser.sh
limitador.sh
menu
menu_inst.sh
openvpn.sh
PDirect.py
PGet.py
POpen.py
PPriv.py
PPub.py
sockspy.sh
squid.sh
swapfile.sh
tcpbbr.sh
tool_extras.sh
userHWID
userSSH
userTOKEN
userV2ray.sh
userWG.sh
v2ray.sh
wireguard.sh
ws-cdn.sh
WS-Proxy.js
WSREv.sh'

[[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}

for arqx in $arch; do
  msg -ne "."

  if ! wget --no-check-certificate -O ${SCPinstal}/${arqx} "https://raw.githubusercontent.com/rudi9999/ADMRufu/main/${arqx}" &>/dev/null ; then
    error_fun
  fi
  verificar_arq "${arqx}"
done
rm -rf ${SCPinstal}
msg -verd "  - VERIFICADO"

#cp -f /etc/ADMRufu/bashrc /etc/bash.bashrc &>/dev/null
cd ${ADM_inst}

[[ -e ${ADM_inst}/message.txt ]] && print_center -azu "$(cat ${ADM_inst}/message.txt)"

msg -bar3
print_center -ama "Perfecto, continuemos con la instalacion"
msg -bar3
rm ${ADMRufu}/install.sh
print_center -verd "INSTALADO CON EXITO"
msg -bar
enter
menu
