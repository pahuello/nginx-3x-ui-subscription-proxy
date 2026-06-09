# nginx-3x-ui-subscription-proxy

Updated reverse proxy configuration for Nginx to dynamically handle and aggregate [3x-UI](https://github.com/MHSanaei/3x-ui?tab=readme-ov-file) subscriptions from multiple servers.

🇷🇺 [Russian version README](README_RU.md)

🇺🇸 [Orignal README](README_ORIGINAL.md)

## Changes

Added static subscription information for x-ray clients:
+ Subscription (Profile) title
+ Subscription announce
+ Subscription update interval
+ Enable/disable routing
+ Routing rules

## Setup Instructions

#### 1. Clone the Repository
```bash
git clone https://github.com/pahuello/nginx-3x-ui-subscription-proxy.git
cd nginx-3x-ui-subscription-proxy
```

#### 2. Copy the Environment File
```bash
cp .env.template .env
```

#### 3. Configure Environment Variables
Edit the `.env` file and fill in the following variables with your own data:

| Variable        | Description                                                                                     |
|-----------------|-------------------------------------------------------------------------------------------------|
| `TLS_MODE`  | Enables or disables SSL. Default set `off`. When set to `on`, SSL certificates must be generated (e.g., via Certbot), and their paths must be specified in the `PATH_SSL_KEY` variable. |
| `PATH_SSL_KEY`  | Path to the directory containing your SSL certificate and private key (e.g., `/etc/letsencrypt/live/your_site/`). |
| `SITE_HOST`     | Domain name for your Nginx server (e.g., `subserver.example`).                                           |
| `SITE_PORT`     | Port number where Nginx will listen for requests (e.g., `443`).                                |
| `SERVERS`       | List of 3x-UI server URLs to aggregate subscriptions from (e.g., `https://server1.com/sub/ https://server2.com/sub/`). |
| `SUB`           | Static part of the subscription path (e.g., `sub`).                                             |
| `PROFILE_TITLE`           | Subscription (Profile) title                                             |
| `ANNOUNCE`           | Announce for clients                                             |
| `PROFILE_UPDATE_INTERVAL`           | Subscription update interval in hours (e.g., `12`).                                             |
| `ROUTING_ENABLE`           | Enable/disable routing on client (e.g., `true` / `yes` / `1` or `false` / `no` / `0`)                                             |
| `ROUTING_RULES`           | link for routing rules (e.g., `happ://routing/add/...`)                                             |

###### Subscription URL Format

Once you've configured the environment variables, your subscription URL will look like this:
`https://subserver.example/sub/subscription_ID`

Where:
- `subserver.example` is the domain you set in the `SITE_HOST` variable.
- `sub` is the static part of the subscription path, set in the `SUB` variable.
- `subscription_ID` is the unique ID for each client from 3x-ui.

#### 4. Start the Application
Run the following command to start the application:
```bash
docker compose up -d
```

This will build and start the Nginx container with the provided configuration.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contributing
Contributions are welcome! Feel free to open an issue or submit a pull request.
