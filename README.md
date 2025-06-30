# The Giant Bomb Wiki

...

## Running the wiki for the first time

- Have docker desktop installed and running
- Run `chmod +x ./entrypoint.sh` in the root of this repo - might not need this.
- Run `docker compose up -d` in the root of this repo.
- Go to http://localhost:8080/ in your browser. The installer will run automatically on first start.
- The values you need for the database connection are in the docker-compose.yml file - "db" is your host, etc.
- Make your admin account, and save the password!
- Check Semantic MediaWiki when you see the option to add it to extensions.
- You will get to a screen that will save a LocalSettings.php file to your Downloads folder. Move that into the /config folder.
- Before doing anything else, run `docker compose restart`.
- You should now be able to access the wiki at http://localhost:8080/ and you should see the Gamepress skin enabled.

# Added Semantic MediaWiki
- Uses mounted html which might be slow to use
- Runs php patch on every restart, need to see how to run on just first launch.
- Go to http://localhost:8080/index.php/Special:Version to verify Semantic MeidiaWiki is listed as extension.
