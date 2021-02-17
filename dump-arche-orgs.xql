xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $starting-at := request:get-parameter('starting-at', 0)
let $length := request:get-parameter('length', 100)

let $mapping := $archeutils:org_lookups
let $sourcedoc := doc($app:data||'/'||data($mapping/@source))//tei:body//tei:listOrg
let $items := $sourcedoc//tei:org
let $res := for $item in subsequence($items, $starting-at, $length)
    let $item_probs := archeutils:populate_tei_resource($mapping, $item)
    return
        <acdh:Organisation>
            {$item_probs}
        </acdh:Organisation>

let $RDF := 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        {$res}
    </rdf:RDF>

return $RDF