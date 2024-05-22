#!/bin/sh
echo
echo "    ____  __                     _      ____  _ __      ";
echo "   / __ \/ /_  ____  ___  ____  (_)  __/ __ )(_) /______";
echo "  / /_/ / __ \/ __ \/ _ \/ __ \/ / |/_/ __  / / __/ ___/";
echo " / ____/ / / / /_/ /  __/ / / / />  </ /_/ / / /_(__  ) ";
echo "/_/   /_/ /_/\____/\___/_/ /_/_/_/|_/_____/_/\__/____/  ";
echo "                                                        ";
echo "> Starting PhoenixBits..."
echo
if [ -f "docker_setup_done" ]; then
    echo ">>> PhoenixBits has already been configured. Nothing to configure."
    echo
    echo "> Starting Phoenixd... 🚀"
    echo
    /phoenixd/phoenixd --version
    nohup /phoenixd/phoenixd --agree-to-terms-of-service --http-bind-ip 0.0.0.0 &
    sleep 5
    echo 
    echo "> Starting LNbits... 🚀"
    echo
    poetry run lnbits --port $LNBITS_PORT --host $LNBITS_HOST
else
    echo ">>> PhoenixBits is started for the first time!"
    echo
    echo "> Starting Phoenixd... 🚀"
    echo
    /phoenixd/phoenixd --version
    nohup /phoenixd/phoenixd --agree-to-terms-of-service --http-bind-ip 0.0.0.0 &
    sleep 5
    echo 
    phoenix_conf=$(cat /root/.phoenix/phoenix.conf)
    api_key=$(echo $phoenix_conf | cut -d'=' -f2)
    echo "Getting phoenixd API key..."
    echo "API KEY: $api_key"
    echo
    echo "> Updating LNbits configuration file..."
    mv .env.example .env
    echo
    if [ "$LNBITS_SITE_TITLE" ]; then
        echo "- Updating LNBITS_SITE_TITLE..."
        sed -i "s/^LNBITS_SITE_TITLE=\"LNbits\"/LNBITS_SITE_TITLE=\"$LNBITS_SITE_TITLE\"/" .env
    else
        echo "LNBITS_SITE_TITLE var has not been initialized. Skipping."
    fi
    if [ "$LNBITS_SITE_TAGLINE" ]; then
        echo "- Updating LNBITS_SITE_TAGLINE..."
        sed -i "s/^LNBITS_SITE_TAGLINE=\"LNbits\"/LNBITS_SITE_TAGLINE=\"$LNBITS_SITE_TAGLINE\"/" .env
    else
        echo "LNBITS_SITE_TITLE var has not been initialized. Skipping."
    fi
    echo "- Enabling ADMIN_UI for first run..."
    sed -i "s/^LNBITS_ADMIN_UI=false/LNBITS_ADMIN_UI=true/" .env
    echo "- Injecting Phoenixd API KEY into LNbits Phoenixd wallet configuration..."
    sed -i "s/^PHOENIXD_API_PASSWORD=PHOENIXD_KEY/PHOENIXD_API_PASSWORD=$api_key/" .env
    echo "- Setting Phoenixd as LNbits default fund source..."
    sed -i "s/^LNBITS_BACKEND_WALLET_CLASS=VoidWallet/LNBITS_BACKEND_WALLET_CLASS=PhoenixdWallet/" .env
    echo
    echo "> Starting LNbits... 🚀"
    echo
    touch docker_setup_done
    poetry run lnbits --port $LNBITS_PORT --host $LNBITS_HOST
fi