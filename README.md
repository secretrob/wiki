# The Giant Bomb Wiki

...

## Running the wiki for the first time

- Have docker desktop installed and running
- Run `chmod +x ./entrypoint.sh` in the root of this repo - might not need this.
- Run `docker compose up -d` in the root of this repo.
- Go to http://localhost:8080/ in your browser. The installer will run automatically on first start.
- The values you need for the database connection are in the docker-compose.yml file - "db" is your host, etc.
- Make your admin account, and save the password!
- You will get to a screen that will save a LocalSettings.php file to your Downloads folder. Move that into the /config folder.
- Before doing anything else, run `docker compose restart`.
- You should now be able to access the wiki at http://localhost:8080/ and you should see the Gamepress skin enabled.

## Backlinks - Test Example

- After site is running navigate to: http://localhost:8080/index.php/MediaWiki:Common.css
- Paste the following:

`/* CSS placed here will be applied to all skins */
.backlinks {
    background-color: #f9f9f9;
    border: 1px solid #ccc;
    border-radius: 5px;
    padding: 20px;
    margin: 10px 0;
    width: 90%;
    box-sizing: border-box;
}

.backlinks h2 {
    color: #333;
    font-size: 24px;
    font-weight: bold;
    margin-bottom: 10px;
}

.backlinks ul {
    list-style: none;
    padding: 0;
    margin: 0;
}

.backlinks ul li {
    padding: 5px 0;
}

.backlinks ul li a {
    text-decoration: none;
    color: #007bff;
}

.backlinks ul li a:hover {
    color: #0056b3;
    text-decoration: underline;
}`

- Then open your LocalSettings.php and add the following to the end and restart your container.
`# BACKLINKS
$wgHooks['SkinAfterContent'][]='backlinks_func';

function backlinks_func( &$data, Skin $skin ) {
	$title = $skin->getTitle()->getPrefixedText();
	print_r($title);
	$url = 'http://host.docker.internal:8080/api.php';	
	$params = [
		"action" => "query",
		"generator" => "backlinks",
		"gbltitle" => $title,
		"prop" => "categories",
		"format" => "json"
	];

	$url = $url . "?" . http_build_query($params);

	$ch = curl_init( $url );

	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );

	session_write_close();

	$output = curl_exec( $ch );

	if (curl_errno($ch)) {
    	$error = curl_error($ch);
    	print($error);
	}
	curl_close( $ch );

	session_start();

	$result = $output;	

	if( $result ) {
		$obj = json_decode($result);
		$found = false;
		if( isset($obj) && isset($obj->query) ) {
			$pages = $obj->query->pages;
			
			$out = '<div id="backlinks" class="backlinks"><h2>Games</h2><ul>';
			foreach ($pages as $key => $page) {
				$match=false;
				if(isset($page->categories)) {
					foreach($page->categories as $cat) {
						if( $cat->title == "Category:Game" ) {
							$match=true;
							break;
						}
					}			
				}
				if( $match ) {
					$title = Title::newFromText($page->title);
			        if ($title) {
			        	$found = true;
			            $url = $title->getFullURL();
			            $out .= "<li><a href='" . htmlspecialchars($url) . "'>" . htmlspecialchars($title->getFullText()) . "</a></li>";						
					}
				}
			}
			$out .= '</ul></div>';

			if( $found )
		    	$data = $out . $data;
		}
	}

    return true;
}`