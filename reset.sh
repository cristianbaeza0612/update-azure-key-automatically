#!binbash

# Variables
CREDENTIALS_FILE_PATH=${1}  # Ruta al archivo credentials, pasada como argumento

if [ -z $CREDENTIALS_FILE_PATH ]; then
  echo Por favor, proporciona la ruta al archivo credentials.
  exit 1
fi

# Comprobar si el archivo existe
if [ ! -f $CREDENTIALS_FILE_PATH ]; then
  echo El archivo $CREDENTIALS_FILE_PATH no existe.
  exit 1
fi

# Leer ACCESS_KEY y SECRET_KEY del archivo credentials
APP_ID=$(grep ^APP_ID= $CREDENTIALS_FILE_PATH  awk -F'=' '{print $2}')
OBJECT_ID=$(grep ^OBJECT_ID= $CREDENTIALS_FILE_PATH  awk -F'=' '{print $2}')
KEY_ID=$(grep ^KEY_ID= $CREDENTIALS_FILE_PATH  awk -F'=' '{print $2}')
CLIENT_SECRET=$(grep ^CLIENT_SECRET= $CREDENTIALS_FILE_PATH  awk -F'=' '{print $2}')
TENANT_ID=$(grep ^TENANT_ID= $CREDENTIALS_FILE_PATH  awk -F'=' '{print $2}')

if [ -z $APP_ID ]  [ -z $OBJECT_ID ]  [ -z $KEY_ID ]  [ -z $CLIENT_SECRET ]  [ -z $TENANT_ID ]; then
  echo APP_ID o OBJECT_ID o KEY_ID o CLIENT_SECRET o TENANT_ID no encontrados en el archivo credentials.
  exit 1
fi

# Creamos variable
export AZURE_CLIENT_SECRET=$CLIENT_SECRET

# Verificar las credenciales configuradas
echo Iniciando sesion...
.mgc login --tenant-id $TENANT_ID --client-id $APP_ID --strategy Environment --scopes Application.ReadWrite.All

echo Creando clave...
# Creamos nueva clave
RESPONSE=$(.mgc applications add-password post --application-id $OBJECT_ID --body '{passwordCredential {displayName ACCESS-KEY}}')
echo $RESPONSE

# Recogemos el nuevo secret y el id sin jq
RAW_CLIENT_SECRET=$(echo $RESPONSE  grep -oP 'secretText K[^,}]+')
RAW_KEY_ID=$(echo $RESPONSE  grep -oP 'keyIdK[^,}]+')

NEW_CLIENT_SECRET=$(echo $RAW_CLIENT_SECRET  sed 's^ ;s $;s^;s$')
NEW_KEY_ID=$(echo $RAW_KEY_ID  sed 's^ ;s $;s^;s$')

echo $NEW_CLIENT_SECRET
echo $NEW_KEY_ID

if [ -z $NEW_CLIENT_SECRET ]  [ -z $NEW_KEY_ID ]; then
  echo Failed to retrieve secretText or keyId from the response
  exit 1
fi

# Pausa para permitir la propagacion de las nuevas credenciales
echo Esperando 10 segundos para permitir la propagacion de las nuevas credenciales...
sleep 10

#Probamos a subir los datos nuevos y hacer login
export AZURE_CLIENT_SECRET=$NEW_CLIENT_SECRET

.mgc login --tenant-id $TENANT_ID --client-id $APP_ID --strategy Environment --scopes Application.ReadWrite.All

# Sobrescribir el archivo credentials con las nuevas credenciales
sed -i s^CLIENT_SECRET=.CLIENT_SECRET=${NEW_CLIENT_SECRET} $CREDENTIALS_FILE_PATH
sed -i s^KEY_ID=.KEY_ID=${NEW_KEY_ID} $CREDENTIALS_FILE_PATH

# Step 6 Eliminamos el antiguo acceso
.mgc applications remove-password post --application-id $OBJECT_ID --body {keyId $KEY_ID}

echo Script completed successfully