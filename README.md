# sigic-bundle


git clone https://github.com/CentroGeo/sigic-bundle.git
git submodule update --init --recursive --remote
git submodule update --remote --merge --recursive


--env_type=prod default 

python3 create-envfile.py --email=info@cesarbenjamin.net --https / --externalhttps \
--hostname=geosuite.demo.cesarbenjamin.net  
--oidc_provider_url=https://geosuite.demo.cesarbenjamin.net/iam/realms/sigic
--useoidc --usefrontendadmin --usefrontendapp --usellm --homepath=app


docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile llm down 
docker compose --profile oidc --profile llm --profile frontend-admin --profile frontend-pub build --no-cache
docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile llm up -d --remove-orphans

python3 create-envfile.py --env_type=prod --hostname=dv-sigic.snic.secihti.mx --useoidc --oidc_provider_url=https://dv-sigic.snic.secihti.mx/iam/realms/sigic --homepath=app --externalhttps --email=sigic@secihti.mx 

todo:      COMPOSE_PROFILES=geonode,oidc,https,ia,ollama docker compose pull
ia remoto: COMPOSE_PROFILES=geonode,oidc,https docker compose pull

COMPOSE_PROFILES=frontend-admin,frontend-app docker compose build --no-cache
COMPOSE_PROFILES=geonode,oidc,frontend-admin,frontend-app docker compose up -d


entrar a keycloak, en realm master crear usuario admin y ponerle password, asignarle rol admin en role-mappings de ese realm
crear realm sigic
en realm sigic, crear cliente sigic-admin con access type confidential, y token exchange enabled, cambiar datos en .env
en realm sigic, crear cliente sigic-app con access type confidential, y token exchange enabled, cambiar datos en .env
en realm sigic, crear cliente sigic-geonode con access type confidential, y token exchange enabled, conservar secret

realm settings:

general:
    realm name: sigic
    show name: SIGIC
    html name: <div class="kc-logo-text"><span>SIGIC</span></div>
    

login: 
  user registration: ?
  forgot password: ok
  remember me: ok
  email as username: ok
  login with email: ok
  verify email: ?

email: 
  configurar smtp con algun servicio real (mailgun, sendgrid, etc)

theme:
  login theme: sigic-theme

localizacion:
  default locale: es-MX
  supported locales: es-MX, en

entrar a /geonode-admin con admin password sacado del .env (GEONODE_ADMIN_PASSWORD, linea 123 aprox)
Aplicaciones de redes sociales -> agregar nueva aplicación
id de proveedor: sigic-geonode
nombre: sigic-geonode
cliente id: sigic-geonode
cliente secreto: (el que se generó en keycloak)
guardar

dv-sigic.snic.secihti.mx

---

docker compose --profile oidc --profile frontend-admin --profile frontend-pub --profile llm down 

docker compose build --no-cache --profile core    # postgres y nginx general (no el nginx del ia-lb)
docker compose build --no-cache --profile ia      # todo lo de ia

docker compose build --no-cache --profile ia-db     # solo la base de datos de ia sobre el postgres del bundle
docker compose build --no-cache --profile ia-lb      # solo el load balancer de ia (openresty con lua y redis)
docker compose build --no-cache --profile ia-engine  # solo el engine de ia

docker compose --profile ia up -d
docker compose --profile ia-db up -d
docker compose --profile ia-lb up -d
docker compose --profile ia-engine up -d