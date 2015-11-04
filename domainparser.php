<?php

require_once 'vendor/autoload.php';

$pslManager = new Pdp\PublicSuffixListManager();
$parser = new Pdp\Parser($pslManager->getList());

$domains = @file('stripped_emails.txt');
$domains = str_replace("\n", "", $domains);
$domains = str_replace("\r", "", $domains);
$domains = preg_replace('/\.tld$/i', "", $domains);

foreach ($domains as $domain) {
	var_dump($parser->getRegisterableDomain($domain));
}

//var_dump($parser->getRegisterableDomain('mozilla.org'));


?>