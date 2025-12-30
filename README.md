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

```
docker-compose down
```

To stop it execute:

```
docker-compose stop
```

## Configuration

The default name of the database, user and password for PostgreSQL can be changed in the [`.env`](.env) file in the current directory.

## Installing yt-dlp in n8n Container

yt-dlp is pre-installed in the Docker image for downloading videos via n8n workflows. To verify the installation:

```bash
# Access the n8n container
docker-compose exec n8n sh

# Verify installation
yt-dlp --version
```

If you need to update yt-dlp to the latest version manually:

```bash
# Update using yt-dlp's built-in updater (requires root access)
docker-compose exec -u root n8n yt-dlp -U

# Or manually download the latest version
docker-compose exec -u root n8n sh
wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /usr/local/bin/yt-dlp
chmod a+rx /usr/local/bin/yt-dlp
```

