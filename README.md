# PhoenixBits 

One container for LNbits + Phoenix + Traefik SSL HTTPS certificates.

## Docker
Install Docker if needed:
```
curl -fsSL https://get.docker.com -o install-docker.sh
```
```
sudo sh install-docker.sh
```
Verify if Docker & Docker compose are installed:
```
docker -v
Docker version 25.0.3, build 4debf41
```
```
docker compose version
Docker Compose version v2.24.6
```
Cloning the repo:
```
git clone https://github.com/PastaGringo/PhoenixBits.git && cd PhoenixBits
```
Update the .env file with your info:
```
nano .env
```
Content:
```
# You need to add the phoenixbits domain otherwise Trefik won't be able to serve PhoenixBits on HTTPS
PHOENIXBITS_DOMAIN=
# Let's Encrypt contact email
LE_EMAIL=
LNBITS_SITE_TITLE=
LNBITS_SITE_TAGLINE=
```
Here the docker-compose.yml file content (you don't have to modify something):
```
# version: '3.8'
services:

  phoenixbits:
    container_name: phoenixbits
    #image: pastagringo/lnbits-phoenixbits
    build:
      context: .
    volumes:
      - ./phoenixbits/lnbits/data:/app/data
    environment:
      - LNBITS_SITE_TITLE=${LNBITS_SITE_TITLE}
      - LNBITS_SITE_TAGLINE=${LNBITS_SITE_TAGLINE}
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.phoenixbits.rule=Host(`${PHOENIXBITS_DOMAIN}`)"
      - "traefik.http.services.phoenixbits.loadbalancer.server.port=5000"
      - "traefik.http.routers.phoenixbits.service=phoenixbits"
      - "traefik.http.routers.phoenixbits.entrypoints=websecure"
      - "traefik.http.routers.phoenixbits.tls.certresolver=selfhostedservices"
#      - "traefik.http.routers.phoenixbits.middlewares=accesscontrol@docker"

  traefik:
    image: "traefik:latest"
    container_name: "traefik"
    restart: unless-stopped
    command:
      - "--accesslog=false"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--certificatesresolvers.selfhostedservices.acme.tlschallenge=true"
#      - "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory" # Uncomment to use test SSL cert
      - "--certificatesresolvers.selfhostedservices.acme.email=${LE_EMAIL}"
      - "--certificatesresolvers.selfhostedservices.acme.storage=/letsencrypt/acme.json"
      - "--api.insecure=true"
      - "--api.dashboard=true"
      - "--providers.docker"
      - "--log.level=INFO"
    ports:
      - target: 80
        published: 80
        mode: host
      - target: 443
        published: 443
        mode: host
      - target: 8080
        published: 8080
        mode: host
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
```

Once done, you can compose the PhoenixBits docker compose stack (CTRL+C to exit docker compose logs):
```
docker compose up -d && docker compose logs -f phoenixbits
#docker compose up -d && docker compose logs -f <<< to troubleshoot Traefik issues with your domain
```
```
phoenixbits  | 
phoenixbits  |     ____  __                     _      ____  _ __      
phoenixbits  |    / __ \/ /_  ____  ___  ____  (_)  __/ __ )(_) /______
phoenixbits  |   / /_/ / __ \/ __ \/ _ \/ __ \/ / |/_/ __  / / __/ ___/
phoenixbits  |  / ____/ / / / /_/ /  __/ / / / />  </ /_/ / / /_(__  ) 
phoenixbits  | /_/   /_/ /_/\____/\___/_/ /_/_/_/|_/_____/_/\__/____/  
phoenixbits  |                                                         
phoenixbits  | > Starting PhoenixBits...
phoenixbits  | 
phoenixbits  | >>> PhoenixBits is started for the first time!
phoenixbits  | 
phoenixbits  | > Starting Phoenixd... 🚀
phoenixbits  | 
phoenixbits  | Generating new seed...done
phoenixbits  | Generating default api password...done
phoenixbits  | 2024-05-07 14:58:25 datadir: /root/.phoenix
phoenixbits  | 2024-05-07 14:58:25 chain: Mainnet
phoenixbits  | 2024-05-07 14:58:25 autoLiquidity: 2000000 sat
phoenixbits  | 2024-05-07 14:58:25 nodeid: 0231f9a790fe8017209d6ab16602afc6886fcc99be1c5d6fca4d6f749a6d0b6d50
phoenixbits  | 2024-05-07 14:58:25 connecting to lightning peer...
phoenixbits  | 2024-05-07 14:58:25 connected to lightning peer
phoenixbits  | 2024-05-07 14:58:25 listening on http://0.0.0.0:9740
phoenixbits  | 
phoenixbits  | Getting phoenixd API key...
phoenixbits  | API KEY: 28239c6fe72ae8f58da5ebde917db4cb8d3ff07c95e8c9318aca203b43a8b411
phoenixbits  | 
phoenixbits  | > Updating LNbits configuration file...
phoenixbits  | 
phoenixbits  | - Updating LNBITS_SITE_TITLE...
phoenixbits  | - Updating LNBITS_SITE_TAGLINE...
phoenixbits  | - Enabling ADMIN_UI for first run...
phoenixbits  | - Injecting Phoenixd API KEY into LNbits Phoenixd wallet configuration...
phoenixbits  | - Setting Phoenixd as LNbits default fund source...
phoenixbits  | 
phoenixbits  | > Starting LNbits... 🚀
phoenixbits  | 
phoenixbits  | 2024-05-07 14:58:38.48 | INFO | Started server process [38]
phoenixbits  | 2024-05-07 14:58:38.51 | INFO | Waiting for application startup.
```

You should be able to access PhoenixBits on the domain you configured into the .env file 🎉

![image](https://github.com/PastaGringo/PhoenixBits/assets/16828964/4495080e-b18b-485c-b4d1-4c49bf55347c)

Well done 🎉⚡
