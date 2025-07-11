#!/bin/bash

#La función help muestra ayuda al usuario en caso de introducir dicho parametro o no introducir nada
#Se crea una función para reutilizar código

function help() {

  cadena_help="info_user.sh [-u usuario][-g grupo][--login][--help]\n
  \t -u usuario   Mostrar información sobre un usuario especificado
  \t -g grupo     Mostrar usuarios asociados al grupo especificado
  \t --login      Mostrar los 5 últimos usuarios que han accedido al sistema
  \t --help       Mostrar ayuda"
echo -e "$cadena_help"
return;

}


{
  #Mostramos el nombre del que ejecuta el script,fecha,y bash usada

  echo -e "`whoami`,`date | cut -d ' ' -f 1-9`, $BASH_VERSION \n"


  #Si se pasa mas de dos caracteres saltará un error, notificando la causa y saliendo del programa con codigo de error correpondiente
  if test $# -gt 2
  then

    echo "Error:El número de parametros pasados es incorrectos"
    exit 1

  elif test $# -eq 1
  then


    #Si el parametro pasado es --login mostrará las últimas 5 conexiones locales y remotas de los usuarios

    if test "$1" == "--login"
    then
      echo "Las últimas conexiones REMOTAS son:"
      echo "-----------------------------------"
      grep  "Accepted" /var/log/auth.log | tail -5 | cut -d ' ' -f 1,2,9,11
      echo -e "\n"
      echo "Las últimas conexiones LOCALES son:"
      echo "-----------------------------------"
      grep -E "su: pam_unix\(su:session\): session opened |systemd-user:session\): session opened" /var/log/auth.log | tail -5 | cut -d ' ' -f 1,2,3,11


    #Si el parametro pasado es --help mostrará información

    elif test "$1" == "--help"
    then
      help

      #Si solo se pasa el modificador -u o -g sin el parámetro se notifica el error y se revuelve un código de error

  elif test "$1" == "-u"
  then
    echo "Error:Se debe proporcionar el nombre de usuario con el parametro -u"
    exit 2
  elif test "$1" == "-g"
  then
    echo "Error:Se debe proporcionar el nombre del grupo con el parámetro -g"
    exit 3
    #Al igual que pasar un parámetro no permitido
    else
      echo "Error: Opción no valida.Use --help para obtener ayuda."
      exit 4
    fi

  elif test $# -eq 2
  then

    #Aqui tenemos dos opciones
    # Si el primer parametro pasado es -u el segundo debe estar asociado a un nombre de usuario
    if test "$1" == "-u"
    then
        STRING=`grep $2 /etc/passwd`
        if  test -z "$STRING"
        then
          echo "El usuario $2 no existe en el sistema"
        else
          LOGGED=`who | grep $2`
          CONNECTED=""
          if ! test -z "$LOGGED"
          then
            CONNECTED="El usuario $2 esta conectado actualmente"
          else
            CONNECTED="El usuario $2 no esta conectado"
          fi

           GRUPOS=`grep $2 /etc/group | tr ":" " " | cut -d ' ' -f 1 | tr '\n' ' '`
           NUM_FILES=`find /home/"$2" -size +1M | wc -l`

          echo "$CONNECTED"
          echo "Las últimas conexiones REMOTAS son:"
          echo "-----------------------------------"
          grep  "Accepted password for $2" /var/log/auth.log | tail -5 | cut -d ' ' -f 1,2,3,11
          echo -e "\n"
          echo "Las últimas conexiones LOCALES son:"
          echo "-----------------------------------"
          grep -E "su: pam_unix\(su:session\): session opened for user $2|systemd-user:session\): session opened for user $2" /var/log/auth.log | tail -5 | cut -d ' ' -f 1,2,3
          echo "El usuario $2 pertenece a los siguientes grupos:$GRUPOS"
          echo "Espacio ocupado por la carpeta "home"/$2 : `du /home/"$2" -sh | tr "/" " " | cut -d ' ' -f 1`"
          echo "Contiene $NUM_FILES ficheros mayores de 1MB en la carpeta "home/"$2"

        fi

      #Si el segundo paraemtro pasado es -g el segundo parametro debe estar asociado a un grupo
    elif test "$1" == "-g"
    then
        if test -z `grep "$2:x:" /etc/group`
        then
          echo "El grupo $2 no existe en el sistema"
        else
          STRING_2=`grep "$2:x:" /etc/group | tr ":" " " | cut -d ' ' -f 4`

          if test -z "$STRING_2"
          then
            echo "El grupo $2 no contiene usuarios"
          else
            echo "Los usuarios del grupo $2 son : $STRING_2"

        fi
      fi

    else
      echo "Los parametros pasados no estan aceptados.Use --help para obtener ayuda"
      exit 5
    fi

  else
    help
  fi

} | tee -a /var/log/info_user.log
