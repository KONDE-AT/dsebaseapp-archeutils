xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $starting-at := request:get-parameter('starting-at', 1)
let $length := request:get-parameter('length', 10)
let $col_name := request:get-parameter('col-name', 'editions')

let $mentions_lookup := $archeutils:constants//acdh:Mentions[@collection=$col_name]/*

let $docs := collection($app:data||"/"||$col_name)//tei:TEI[@xml:id and @xml:base]
let $sample := subsequence($docs, $starting-at, $length)

let $res :=
    for $item in $sample
        let $doc_id := $item/@xml:base||'/'||$item/@xml:id
        return 
        <acdh:Resource rdf:about="{$doc_id}">
        {
        for $prop in $mentions_lookup
            let $el_name := name($prop)
            let $el_xpath := $prop/text()
            let $el_value := util:eval($el_xpath)
            for $mention in $el_value
                let $men_id := 
                    switch ($el_name)
                    case 'acdh:hasActor' return $archeutils:persons_url||'/'||substring-after($mention, '#')
                    default return $archeutils:places_url||'/'||substring-after($mention, '#')
                return
                    element {$el_name} {attribute rdf:resource { $men_id }}
        }
        </acdh:Resource>
return 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        {$res}
    </rdf:RDF>
