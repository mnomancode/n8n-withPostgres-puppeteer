# n8n with PostgreSQL

Starts n8n with PostgreSQL as database.

## Start


docker-compose up -d      

To start n8n with PostgreSQL simply start docker-compose by executing the following
command in the current folder.

**IMPORTANT:** But before you do that change the default users and passwords in the [`.env`](.env) file!

```
docker-compose up -d
```

To stop it execute:

```
docker-compose stop
```

## Configuration

The default name of the database, user and password for PostgreSQL can be changed in the [`.env`](.env) file in the current directory.

## Installing yt-dlp in n8n Container

To use yt-dlp for downloading videos via n8n workflows, install it inside the n8n container:

```bash
# Access the n8n container
docker-compose exec n8n sh

# Install Python3 (required for yt-dlp)
apk update
apk add python3

# Create local bin directory and download yt-dlp
mkdir -p ~/.local/bin
wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
source ~/.profile

# Verify installation
yt-dlp --version
```

**Note:** This installation is temporary and will be lost when the container is recreated. For persistent installations, add the yt-dlp installation steps to the `Dockerfile`.

