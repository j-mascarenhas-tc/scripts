#!/usr/bin/env bash

##################################
#### SCRIPT DE BACKUP FREENAS ####
#### DESENV POR JOSEMAR       ####
#### VER 1.0    	          ####
##################################


### VARIAVEIS ###



DATA=$(date +%Y-%m-%d.%H.%M.%S)
DIASEMANA=$(date +%w)

ORIGEM="/home/josemar/Downloads"
DESTINO="/tmp/backup"
LOGLOCAL="/tmp/backup/log"

LOGFULLOUT="${LOGLOCAL}/backup-full.${DATA}.${DIASEMANA}.log"
LOGFULLERR="${LOGLOCAL}/backup-full.${DATA}.${DIASEMANA}.err"
LOGCTRL="${LOGLOCAL}/controle.txt"

LOGINCOUT="${LOGLOCAL}/backup-incremental.${DATA}.${DIASEMANA}.log"
LOGINCERR="${LOGLOCAL}/backup-incremental.${DATA}.${DIASEMANA}.err"

FULLFILE="backup-full.${DATA}.${DIASEMANA}.tar"
INCRFILE="backup-incremental.${DATA}.${DIASEMANA}.tar"

DIAFULL="5"
RETENCAOFULL="30"
RETENCAOINCR="14"
EMAIL="josemar@josemar.com.br" #  kkk altere para seu email 
##
# MONTANDO PASTA REMOTA, ALTERE DE ACORDO COM SEU AMBIENTE
# USER="root"
# REMOTESERVER="192.168.1.21"

# mount_smbfs -I ${REMOTESERVER} //${USER}@${REMOTESERVER}/backup ${DESTINO}
# echo "Pasta remota montada!"



### FUNCOES ###
backup_full() {
	tar vvvcf ${DESTINO}/${FULLFILE} --exclude=${ORIGEM}/Completo ${ORIGEM} > ${LOGFULLOUT} 2> ${LOGFULLERR}
}

controle() {
	awk '{print $6}' ${LOGFULLOUT} > ${LOGCTRL}
}

backup_incremental() {
	tar vvvcf ${DESTINO}/${INCRFILE} -g ${LOGCTRL} ${ORIGEM} > ${LOGINCOUT} 2> ${LOGINCERR}
}

mail_full() {
	mailx -s "Log de backup full - ${DATA}" ${EMAIL} < ${LOGFULLOUT}
}

mail_full_err() {
	mailx -s "Log de backup full com erro - ${DATA}" ${EMAIL} < ${LOGFULLERR}
}

mail_incr() {
	mailx -s "Log de backup incremental - ${DATA}" ${EMAIL} < ${LOGINCOUT}
}

mail_incr_err() {
	mailx -s "Log de backup incremental com erro - ${DATA}" ${EMAIL} < ${LOGINCERR}
}

limpa_log_full() {
	find ${LOGLOCAL} -type f -regex "backup-full\.*\.(err|log)" -mtime +${RETENCAOFULL} -exec rm -f '{}' \;
}

limpa_bkp_full() {
	find ${DESTINO} -type f -regex "backup-full\.*\.tar" -mtime +${RETENCAOFULL} -exec rm -f '{}' \;
}

limpa_log_incr() {
	find ${LOGLOCAL} -type f -regex "backup-incremental\.*\.(err|log)" -mtime +${RETENCAOINCR} -exec rm -f '{}' \;
}

limpa_bkp_incr() {
	find ${DESTINO} -type f -regex "backup-incremental\.*\.tar" -mtime +${RETENCAOINCR} -exec rm -f '{}' \;
}

### EXECUCAO BACKUP ####
if [ $DIAFULL -eq ${DIASEMANA} ]; then
	backup_full
	controle
	mail_full
	if [ -s ${LOGFULLERR} ]; then
		mail_full_err
	fi
else
	backup_incremental
	mail_incr
	if [ -s ${LOGINCERR} ]; then
		mail_incr_err
	fi
fi

### LIMPEZA ###
limpa_log_full
limpa_log_incr
limpa_bkp_full
limpa_bkp_incr