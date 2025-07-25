#!/bin/bash
if [ ! -f ${STEAMCMD_DIR}/steamcmd.sh ]; then
    echo "SteamCMD not found!"
    wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz 
    tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz
    rm ${STEAMCMD_DIR}/steamcmd_linux.tar.gz
fi

echo "---Update SteamCMD---"
if [ "${USERNAME}" == "" ]; then
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login anonymous \
    +quit
else
    ${STEAMCMD_DIR}/steamcmd.sh \
    +login ${USERNAME} ${PASSWRD} \
    +quit
fi

updateserver()
{
    USER="${USERNAME:-Anonymous}"
    PWD="${PASSWRD:+ ${PASSWRD}}"
    PARAMS="${GAME_ID}${UPDATE_PARAMS:+ ${UPDATE_PARAMS}}"

    if [ "${VALIDATE}" == "true" ]; then
        echo "---Validating installation---"
        PARAMS+=" validate"
    fi

    ${STEAMCMD_DIR}/steamcmd.sh \
        +force_install_dir ${SERVER_DIR} \
        +login ${USER} ${PWD} \
        +app_update ${PARAMS} \
        +quit
}

echo "---Update Server---"
updateserver

echo "---Prepare Server---"
if [ ! -f ${DATA_DIR}/.steam/sdk32/steamclient.so ]; then
	if [ ! -d ${DATA_DIR}/.steam ]; then
    	mkdir ${DATA_DIR}/.steam
    fi
	if [ ! -d ${DATA_DIR}/.steam/sdk32 ]; then
    	mkdir ${DATA_DIR}/.steam/sdk32
    fi
    cp -R ${STEAMCMD_DIR}/linux32/* ${DATA_DIR}/.steam/sdk32/
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Server ready---"

echo "---Start Server---"
cd ${SERVER_DIR}
${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}